#!/usr/bin/perl
use strict;
##by zzh

my $var_date=`date +%Y%m%d%H%M%S`;
chomp $var_date;
my $work_dir="/usr1/monk/bin/chk_main_standby";
our %host_hash = (
'SZBOSS-CBE1' =>  'SZBOSS-CBE2',
'SZBOSS-CBE3' =>  'SZBOSS-CBE4',
'SZBOSS-CBE5' =>  'SZBOSS-CBE6',
'SZBOSS-CBE7' =>  'SZBOSS-CBE8',
'SZBOSS-CBE9' =>  'SZBOSS-CBE10',
'SZBOSS-CBE11' =>  'SZBOSS-CBE12',
'SZBOSS-CBE13' =>  'SZBOSS-CBE14',
'SZBOSS-CBE15' =>  'SZBOSS-CBE16',
'FSBOSS-CBE1' =>  'FSBOSS-CBE2',
'FSBOSS-CBE3' =>  'FSBOSS-CBE4',
'FSBOSS-CBE5' =>  'FSBOSS-CBE6',
'FSBOSS-CBE7' =>  'FSBOSS-CBE8',
'FSBOSS-CBE9' =>  'FSBOSS-CBE10',
'STBOSS-CBE1' =>  'STBOSS-CBE2',
'STBOSS-CBE3' =>  'STBOSS-CBE4',
'STBOSS-CBE7' =>  'STBOSS-CBE8',
'STBOSS-CBE9' =>  'STBOSS-CBE10',
'STBOSS-CBE13' =>  'STBOSS-CBE14',
'STBOSS-CBE5' =>  'STBOSS-CBE6',
'STBOSS-CBE11' =>  'STBOSS-CBE12',
'SZBOSS-ABM1' =>  'SZBOSS-ABM2',
'SZBOSS-ABM3' =>  'SZBOSS-ABM4',
'SZBOSS-ABM5' =>  'SZBOSS-ABM6',
'SZBOSS-ABM7' =>  'SZBOSS-ABM8',
'SZBOSS-ABM9' =>  'SZBOSS-ABM10',
'SZBOSS-ABM11' =>  'SZBOSS-ABM12',
#'SZBOSS-ABM13' =>  'SZBOSS-ABM14',
'SZBOSS-ABM15' =>  'SZBOSS-ABM16',
'FSBOSS-ABM1' =>  'FSBOSS-ABM2',
'FSBOSS-ABM3' =>  'FSBOSS-ABM4',
'FSBOSS-ABM5' =>  'FSBOSS-ABM6',
'FSBOSS-ABM7' =>  'FSBOSS-ABM8',
'FSBOSS-ABM9' =>  'FSBOSS-ABM10',
'STBOSS-ABM1' =>  'STBOSS-ABM2',
'STBOSS-ABM3' =>  'STBOSS-ABM4',
'STBOSS-ABM7' =>  'STBOSS-ABM8',
'STBOSS-ABM9' =>  'STBOSS-ABM10',
'STBOSS-ABM13' =>  'STBOSS-ABM14',
'STBOSS-ABM5' =>  'STBOSS-ABM6',
'STBOSS-ABM11' =>  'STBOSS-ABM12',
'GDBOSS-ABM1' => 'GDBOSS-ABM2',
'GDBOSS-CBE1' => 'GDBOSS-CBE2',
'GDBOSS-TPC1' => 'GDBOSS-TPC2',
);
my %hash_m;

sub max_value {
my $current = shift @_;
#print "$current-------\n";
foreach ( @_ ){
if ( $_ > $current ){
$current = $_;
}
}
return $current;
}

sub max_time{
                my ($works_dir , $main_host,$standby_host) = @_;
#print "$main_host,$standby_host|-|-\n";
                my @all_file = glob "$work_dir/*";
                my @time_array_m;
                my @time_array_s;
      foreach(@all_file){
#print "$_\n";
        if(/$main_host/){
         my @array1=split/\_/,$_;
#print "$array1[5]############\n";
         my @array2=split/\./,$array1[5];
#print "$array2[0]\n";
         push @time_array_m,$array2[0];
}
        if(/$standby_host/){
         my @array1=split/\_/,$_;
         my @array2=split/\./,$array1[5];
         push @time_array_s,$array2[0];
                }
}
#print "$time_array_m[0]|||\n";
my $time_array_m_max=&max_value(@time_array_m);
my $time_array_s_max=&max_value(@time_array_s);
#print "$time_array_m_max|$time_array_s_max\n";
my $final_file_m="CHK_SYN_".$main_host."_".$time_array_m_max.".txt";
my $final_file_s="CHK_SYN_".$standby_host."_".$time_array_s_max.".txt";
return ($final_file_m,$final_file_s);
}


sub main
{
my $log_file="$work_dir/CHK_SYN_$var_date.log";
open FV,">>$log_file" or die "$!";
          foreach my $key( keys %host_hash){
#print "$key|$host_hash{$key}\n";
                my @record_array;
                my($final_file_m,$final_file_s)=&max_time($work_dir , $key,$host_hash{$key});
#print "$final_file_m|$final_file_s\n";
          open FM,"$work_dir/$final_file_m" or die $!;
                while(<FM>){
                chomp;
                my @array=split/\s+/,$_;
                $hash_m{$array[2]}=$array[0].$array[1];
#print "$hash_m{$array[2]}!@#$$\n";
              }
                open FH,"$work_dir/$final_file_s" or die $!;
                        while(<FH>){
                        chomp;
                                my @array1=split/\s+/,$_;
                                my $comp_exp=$array1[0].$array1[1];
#print "$comp_exp\n";
                                my $key_s=$array1[2];
                                if($hash_m{$key_s} eq $comp_exp){next;}
                                else{
                                        push @record_array,$key_s;
                                        print "主机$key与备机$host_hash{$key}应用版本存在差异:【$key_s】请检查 \033[5;7mWARNING\033[0m \n ";
                                        print FV "主机$key与备机$host_hash{$key}应用版本存在差异:【$key_s】请检查 \033[5;7mWARNING\033[0m \n ";
                                        }
                        }
close FM;
          close FH;
#print "$key|$host_hash{key}\n";
          print "主机$key与备机$host_hash{$key}应用版本无差异\n-------------------------------------------------\n" if @record_array==0;
          print FV " 主机$key与备机$host_hash{$key}应用版本无差异\n-------------------------------------------------\n" if @record_array==0;
                }
close FV;
print "汇总结果请见：$log_file\n";
        }
        
&main;