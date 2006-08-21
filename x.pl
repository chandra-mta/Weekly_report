#!/usr/bin/perl

@index=qw(0 1 2 3 4);
@time=qw(3 5 2 1 6);
@data=qw(4 6 3 2 7);

@sort=sort {$time[$a] <=> $time[$b]} @index;

@time_s=$time[@sort];
@data_s=$data[@sort];

for ($i=0;$i<=$#time;$i++) {
print "$sort[$i] x $time_s[$i] $data_s[$i]\n";
}
