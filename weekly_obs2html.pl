#!/usr/bin/perl

# obs2html.pl
# Takes tab delimited input file containing columns (but no header labels)
# OBSID  DETECTOR  GRATING  TARGET  ANALYSIS      ACA
#                                   ASSESSMENT ASSESSMENT
#
# Outputs html for inclusion in MTA weekly reports
#
# 14.AUG2006 mta (BDS) - look for new files instead of reading from a list.
#
# 11.APR2002 BDS - updated to look for ap output, then mp if ap does
#                  not exist yet.  Also finds gratings analysis on it's own.
#                  will indicate 'Problem' if ACA must use bad mp_report
#
#     !!  must be run on colossus or rhodes !!

if ( $#ARGV != 1 ) {
  print "Usage:\n\t$0 <ndays> <outfile>\n";
  exit (0);
}

$ndays = $ARGV[0];  # number of days to look back for new obsids
open outfile, ">$ARGV[1]";
my $tmpfile = "xxxobsxxx.tmp";

print outfile "<table border=0 width=100%>\n";
print outfile "<tr><th><u>OBSID</u></th>\n";
print outfile "    <th><u>DETECTOR</u></th>\n";
print outfile "    <th><u>GRATING</u></th>\n";
print outfile "    <th align=left><u>TARGET</u></th>\n";
print outfile "    <th><u>ANALYSIS</u></th>\n";
print outfile "    <th><u>ACA</u></th></tr>\n";
print outfile "\n";

@new_files=`find /data/mta/www/mp_reports/events/*/*/event.html -mtime -$ndays`;
if ($new_files[0] =~ m/No match/) {
  print "No new observations found posted in the past $ndays days.\n";
  die;
}
print "$#new_files new observations\n";

for ($ifiles=0;$ifiles<$#new_files;$ifiles++) {
  chomp $new_files[$ifiles];
  @line=split(/\//,$new_files[$ifiles]);
  $obsid=$line[7];
  $inst=$line[6];
  @fits=`find /data/mta/www/mp_reports/events/$inst\/$obsid\/*fits`;
  if ($fits[0] =~ m/No match/) {
    print "Problem getting info on obsid $obsid.\n";
    next;
  }
  chomp $fits[0];
  push(@index,$ifiles);
  push(@obsid,$obsid);
  push(@det,`dmkeypar $fits[0] DETNAM echo+`);
  $gratp = `dmkeypar $fits[0] GRATING echo+`;
  chomp $gratp;
  push(@gratp,$gratp);
  push(@obj,`dmkeypar $fits[0] OBJECT echo+`);
  push(@tstart,`dmkeypar $fits[0] TSTART echo+`);
  $observer=`dmkeypar $fits[0] OBSERVER echo+`;
  if ($observer =~ m/Calibration/) {
    push(@type,"CAL");
  } else {
    $cc=`dmkeypar $fits[0] DATAMODE echo+`;
    if ($cc =~ m/CC/) {
      push(@type,"CC");
    } else {
      push(@type,"OK");
    }
  } # if ($observer =~ m/Calibration/) {
  
  $grat = 0;
  if ($gratp ne "NONE") { # check if gratings observation
    $grat = 1;
    $date = `date -u +"%b%y"`;
    chomp($date);
    $obs = $obsid;
    while (length($obs) < 4) {
      $obs = "0".$obs;
    }
    @gdir = `ls -dt /data/mta/www/mta_grat/*/$obs 2>$tmpfile`;
    @gdirs = split("/", $gdir[0]);
    if ($#gdirs ge 5) {
      push(@gratpath,sprintf "\n/<a href=\"/mta_days/mta_grat/$gdirs[5]/$obs/obsid_$obs\_Sky_summary.html\">/Grat</a>"); # gratings analysis
    } else { # grat anal not yet available
      push(@gratpath,"\n/Not yet avail.");
    }
  } else { 
      push(@gratpath,"");
  } # if ($gratp ne 'NONE') { # check if gratings observation

} #for ($ifiles=0;$ifiles<$#new_files;$ifiles++) {

# sort all by tstart
#@obsid = map {@obsid} sort @tstart;
#@inst = map {@inst} sort @tstart;
#@det = map {@det} sort @tstart;
#@gratp = map {@gratp} sort @tstart;
#@obj = map {@obj} sort @tstart;
#@type = map {@type} sort @tstart;
#@gratpath = map {@gratpath} sort @tstart;

@sort_index = sort {$tstart[$a] <=> $tstart[$b]} @index;
@obsid = @obsid[@sort_index];
@inst = @inst[@sort_index];
@det = @det[@sort_index];
@gratp = @gratp[@sort_index];
@obj = @obj[@sort_index];
@type = @type[@sort_index];
@gratpath = @gratpath[@sort_index];

# out out table
for ($iobs=0;$iobs<=$#obsid;$iobs++) {
  print outfile "<tr align=center><td><a href=\"http://acis.mit.edu/cgi-bin/get-obsid?id=$obsid[$iobs]\">$obsid[$iobs]</a></td>\n"; #OBSID
  print outfile "<td>$det[$iobs]</td>\n"; #DETECTOR
  print outfile "<td>$gratp[$iobs]</td>\n"; #GRATING
  print outfile "<td align=left>$obj[$iobs]</td>\n"; #TARGET

  if ($inst eq 'acis') {
  # select ap output first, mp output if it ap doesn't exist
    if (-s "/data/mta/www/ap_report/events/acis/$obsid[$iobs]/event.html") {
      print outfile "<td><a href=\"/mta_days/ap_report/events/acis/$obsid[$iobs]/event.html\">$type[$iobs]</a>"; #ACIS ANALYSIS
    } else {
      if (-s "/data/mta/www/mp_reports/events/acis/$obsid[$iobs]/event.html") {
        print outfile "<td><a href=\"/mta_days/mp_reports/events/acis/$obsid[$iobs]/event.html\">$type[$iobs]</a>"; #ACIS ANALYSIS
      } else {
        print outfile "<td>Missing"; #ACIS ANALYSIS
      }
    }
  }
  if ($inst eq 'hrc') {
    if (-s "/data/mta/www/ap_report/events/hrc/$obsid[$iobs]/event.html") {
      print outfile "<td><a href=\"/mta_days/ap_report/events/hrc/$obsid[$iobs]/event.html\">$type[$iobs]</a>"; #HRC ANALYSIS
    } else {
      if (-s "/data/mta/www/mp_reports/events/hrc/$obsid[$iobs]/event.html") {
        print outfile "<td><a href=\"/mta_days/mp_reports/events/hrc/$obsid[$iobs]/event.html\">$type[$iobs]</a>"; #HRC ANALYSIS
      } else {
        print outfile "<td>Missing"; #HRC ANALYSIS
      }
    }
  }

  # add gartings link
  print outfile "$gratpath[$iobs]"; # gratings analysis
  print outfile "</td>\n";

  # add ACA link
  if (-s "/data/mta/www/ap_report/events/aca/$obsid[$iobs]/aca.html") {
    print outfile "<td><a href=\"/mta_days/ap_report/events/aca/$obsid[$iobs]/aca.html\">OK</a>"; #ACA ANALYSIS
  } else {
    $acafile = "/data/mta/www/mp_reports/events/aca/$obsid[$iobs]/aca.html";
    if (-s $acafile) {
      @prob = `grep redalert $acafile`;
      if ($#prob gt 0) {
        print outfile "<td><a href=\"/mta_days/mp_reports/events/aca/$obsid[$iobs]/aca.html\">Prob</a>"; #ACA ANALYSIS
      } else {
        print outfile "<td><a href=\"/mta_days/mp_reports/events/aca/$obsid[$iobs]/aca.html\">OK</a>"; #ACA ANALYSIS
      }
    } else {
      print outfile "<td>Missing"; #ACA ANALYSIS
    }
  }
  print outfile "</td></tr>\n";
} # for ($iobs=0;$iobs<=$#obsid;$iobs++) {

print outfile "</table>\n";

close infile;
close outfile;

unlink $tmpfile;
# end
