#! /usr/bin/perl -w
# formats html telemetry table for weekly reports

# BDS 21 mar 2003
# BDS 15 jul 2003

$recfile="/data/mta4/MTA/data/Weekly/track.tab"; # tab of record highs and lows, 
                      #  maybe it should be user-named - later

$PROGRAM_NAME=$0;
$help="$PROGRAM_NAME formats html telemetry table for weekly reports.\n";
$help.="*** Usage:\n";
$help.=" $PROGRAM_NAME <infile> <outfile> [<limit file>] [-notab]\n";
$help.="   > see telem.txt see example of input format.\n";
$help.="   > user limit file may be specified \n";
$help.="     - must have format of op_limits.db\n";
$help.="     - defaults to local op_limits.db\n";
$help.="   > optional -notab flag may be set to prevent update of $recfile\n";
$help.="     - default is to update\n";

if ($#ARGV < 1) {
  die($help);
}

$update=1;    # default is to update $recfile
# -notab flag can be in any position, so find flag and move other (positional)
#  args to right places
for ($i=0;$i<=$#ARGV;$i++) {
  if (! $update) {$ARGV[$i-1]=$ARGV[$i];} # notab flag found, so move rest
                                          # of args up one position
  if ($ARGV[$i] eq "-notab") {
    $update=0;  #turn off update $recfile
  } # if ($ARGV[$i] eq "-notab") {
} # for ($i=0;$i<=$#ARGV;$i++) {
if (! $update) {@ARGV=@ARGV[0..$i-2];} # delete last element
  
$infile=$ARGV[0];  # infile is pipe delimited list of daily max/mins 
                   #  see telem.txt for exact format
$outfile=$ARGV[1]; # output html table for inclusion in weekly report
#$limfile=$ARGV[2] || "./op_limits.db"; # where to look up limits
$limfile=$ARGV[2] || "/data/mta4/MTA/data/op_limits/op_limits.db"; # where to look up limits

$newrecord=0; # this gets set if there is a new record high or low

# even if -notab, still need to read $recfile to mark html newlims,
#  maybe -notab means don't mark newlims, but that's harder right now
%h = &read_recfile($recfile);
# index msids
for ($j=0;$j<=$#{$h{"MSID"}};$j++) {
  $msid{$h{MSID}[$j]}=$j;
} # for ($j=0;$j<=$#{$h{"MSID"}};$j++) {

open (IN, "<$infile");
$inline=<IN>;  # read first line - must be dates
chomp $inline;
@date=split(/\|/,$inline);
@testdate=split(/\//,$date[1]);
if ($#testdate != 2) {
  die("ERROR. Specify dates on first line of $infile as mm/dd/yy\n");
}

# start output
open (OUT, ">$outfile");
print OUT "<table border=1>\n";
print OUT "<tr><td>MSID\n";
for ($i=1;$i<=$#date;$i++) {
  print OUT "<td>$date[$i]</td>\n";
} # for ($i=1;$i<=$#date;$i++) {
print OUT "<td><em class='yellow'>yellow limits<br />(lower)<br />upper</em>\n";
print OUT "<td><em class='red'>red limits<br />(lower)<br />upper</em>\n";
print OUT "<td>Units <td>Description\n";

while ($inline=<IN>) {
  $printline=0;
  chomp $inline;
  @line=split(/\s+\|\s+/,$inline);
  #print @line; #degug
  #print "$line[0]\n"; #debug
  $lims=`grep "^$line[0]" $limfile | tail -1`;
  @limit=split(/\s+/,$lims);
  if (! defined $limit[1]) {
    print "*ERROR No limits found for $line[0] - check mnemonic.\n";
    @limit=qw (0 -9999 9999 -9999 9999);
  } # if (! defined $limit[1]) {
  #print @limit; #debug
  #print "lims $limit[1] $limit[2] $limit[3] $limit[4]\n"; #debug
  $describe="";
  for ($i=6 ; $i < $#limit-1 ; $i++) {
    $describe .= " ".$limit[$i];
  }

  if (defined $msid{"$line[0]"}) {
    $outline="<tr><td>$line[0]\n";
  } else { # mark new msid
    $outline="<tr><td class=newlim>$line[0]\n";
    print "New msid $line[0]\n";
  } # if (defined $msid{"$line[0]"}) {

  for ($i=1 ; $i<=$#line ; $i++) {
    $tdtag="<td>";
    $rec_check="none";
    $rec_color="ffffff";
    if ($line[$i] ne "x") {
      if ($line[$i] <= $limit[1] and $line[$i] > $limit[3]) {
        $rec_check="low";
        $rec_color="yellow";
      }
      if ($line[$i] >= $limit[2] and $line[$i] < $limit[4]) {
        $rec_check="high";
        $rec_color="yellow";
      }
      if ($line[$i] <= $limit[3]) {
        $rec_check="low";
        $rec_color="red";
      }
      if ($line[$i] >= $limit[4]) {
        $rec_check="high";
        $rec_color="red";
      }
      if ($rec_check eq "none") { 
        print "*ERROR No violation in $line[0] at $line[$i] on $date[$i] - check input.\n";
      }

      # check for record breakers
      if (defined $msid{"$line[0]"}) {
        $mdex=$msid{"$line[0]"};
        if ($line[$i] == $h{Max_seen}[$mdex] || $line[$i] == $h{Min_seen}[$mdex]) {
          print "Tied record! $line[0] $line[$i] on $date[$i]\n";
          $h{Last_viol}[$mdex]=$date[$i];
          $newrecord = 1;
        }
        if ($rec_check eq "low" && $line[$i] < $h{Min_seen}[$mdex]) {
          print "New record LOW! $line[0] $line[$i] beats $h{Min_seen}[$mdex] on $date[$i]\n";
          $tdtag="<td class=newlim>";
          $h{Min_seen}[$mdex]=$line[$i];
          $h{Last_viol}[$mdex]=$date[$i];
          $newrecord = 1;
        }
        if ($rec_check eq "high" && $line[$i] > ${$h{Max_seen}}[$mdex]) {
          print "New record HIGH! $line[0] $line[$i] beats $h{Max_seen}[$mdex] on $date[$i]\n";
          $tdtag="<td class=newlim>";
          $h{Max_seen}[$mdex]=$line[$i];
          $h{Last_viol}[$mdex]=$date[$i];
          $newrecord = 1;
        }
      } else {  # msid not seen before, add to list
        $indx=$#{$h{"MSID"}}+1; 
        #print keys(%msid); #debugmsid
        $msid{"$line[0]"}=$indx;
        #print "$indx\n"; #debugg
        $newrecord = 1;
        $tdtag="<td class=newlim>";
        # scroll through the table columns, add data I know, put in
        #  spacer (9999) for unknown so that columns can be added
        #  to table externally and this still works.
        foreach $head (keys(%h)) {
          if ($head eq "MSID") {$h{$head}[$indx]=$line[0];next;}
          if ($head eq "Min_seen" && $rec_check eq "low") {$h{$head}[$indx]=$line[$i];next;}
          if ($head eq "Max_seen" && $rec_check eq "high") {$h{$head}[$indx]=$line[$i];next;}
          if ($head eq "Last_viol") {$h{$head}[$indx]=$date[$i];next;}
          if ($head eq "Description") {$h{$head}[$indx]=$describe;next;}
          if ($head eq "lower_yel") {$h{$head}[$indx]=$limit[1];next;}
          if ($head eq "upper_yel") {$h{$head}[$indx]=$limit[2];next;}
          if ($head eq "lower_red") {$h{$head}[$indx]=$limit[3];next;}
          if ($head eq "upper_red") {$h{$head}[$indx]=$limit[4];next;}
          $h{$head}[$indx]="9999";  # none of the above
          #print "$head not found\n"; #debugg
        } # foreach $head (keys(%h)) {
      }  # else # if (defined $msid{"line[0]"}) {
      if ($rec_check eq "low") {
        $outline.="$tdtag <em class='$rec_color'>($line[$i])</em></td>\n";
        $printline=1;
      } else {
        if ($rec_check eq "high") {
          $outline.="$tdtag <em class='$rec_color'>$line[$i]</em></td>\n";
          $printline=1;
        } else {
          $outline.="$tdtag <em class='white'>&#160</em></td>\n";
        } # if ($rec_check eq "high") {
      } # if ($rec_check eq "low") {
    } else {
      $outline.="<td>&#160</td>\n";
    }  # if ($line[$i] ne " ") {
  }  #for $i=1 ; $i<=$#line ; $i++ {
  $outline.="<td>($limit[1])<br />$limit[2]</td><td>($limit[3])<br />$limit[4]</td>\n";
  $outline.="<td>$limit[$#limit-1] </td><td>$describe</td>\n";
  $outline.="</tr>\n";
  if ($printline) {print OUT $outline;}
}
print OUT "</table>\n";
close OUT;

if ($update && $newrecord) { # reprint records file if necessary
  open(REC,">$recfile");
  @keys = keys(%h);
  print REC "$keys[0]";
  foreach $key (@keys[1..$#keys]) {
    print REC "\t$key";
  }
  print REC "\n";
  for ($j=0;$j<=$#{$h{"MSID"}};$j++) {
    print REC "$h{$keys[0]}[$j]";
    foreach $key (@keys[1..$#keys]) {
      #print "\n$key $j a "; #debugg
      print REC "\t$h{$key}[$j]";
    }
    print REC "\n";
  }
  close REC;
}

#} # end

#################################################################
sub guess_date {  # not used - user supplies dates
  # report always go Fri-Thurs, so guess initial start date to be
  # last friday
  return "09/14/25"; # not implemented yet
}

#################################################################
sub read_recfile {
  my %viol;
  $tabdat=$_[0];
  open(TAB,"<$tabdat");
  
  $inline = <TAB>;
  chomp $inline;
  @hdr = split /\t/, $inline;
  #<TAB>;                        # skip second line
  
  $elem=0;
  while ($inline=<TAB>) {  # fill in the rest of the hash
    chomp $inline;
    @vals = split /\t/,$inline;
    $col=0;
    foreach (@hdr) {
      $viol{$_}[$elem] = $vals[$col];
      $col++;
    } # foreach (@hdr) {
    $elem++;
  } # while ($inline=<TAB>) {  # fill in the rest of the hash
  close TAB;
  return %viol;
} 

#################################################################
sub next_day { # not used - user supplies dates
  # return date + n days
  @ndate=split("/",$_[0]);
  $n=$_[1];
  $ndate[1]+=$n;
  @mdays=qw(31 28 31 30 31 30 31 31 30 31 30 31);
  if ($ndate[1] gt $mdays[$ndate[0]]) {
    $ndate[1]=$ndate[1]-$mdays[$ndate[0]];
    $ndate[0]+=1;
    if ($ndate[0] == 13) {
      $ndate[0]=01;
      $ndate[2]+=1;
    }
    #  add leap years, below doesn't quite work
    # works if only adding one day, but function must add n days.
    if ($ndate[0]==2 && $ndate[1]==29 && $ndate[2] % 4 > 0) {
      $ndate[0]=03;
      $ndate[1]=01;
    }
  } # if ($ndate[1] gt $mdays[$ndate[0]]) {
  return join("/",@ndate);
}
