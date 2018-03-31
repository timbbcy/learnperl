#!/usr/bin/perl
# TanFengwei
BEGIN{push(@INC,"/usr1/monk/bin","/usr1/monk/bin/perl/lib")};

use Time::Local;
use POSIX qw(strftime);
use NgBoss::Info;

my $max_restart_sec = 1800;
my $max_restart_str = $max_restart_sec/3600 < 24 ? ($max_restart_sec/3600)."小时" : (int($max_restart_sec/86400))."天";
my ($etc_dir,%proc_res,%processes,$cf);
our ($city_num,%proc_info,$core_dir);
our ($h_mode) = `hostname` =~ /(GD.+CBE|GD.+ABM|CBE|ABM|TPC|FEP|RBI)/;

my @ps_args = `ps -u ngboss,ngcdr,ngwb -o ppid,etime,args`;
my $warn_str = "\033[5;7mWARN\033[m";


my %judge = ( #操作符 => 匿名子函数(当前进程数,参考进程数,当前父进程数)
        #调用方法:$judge{"$operator"}->(arg1,arg2,arg3);
        'A'  => sub{ print "arg1:$_[0] arg2:$_[1] arg3:$_[2]\n" }, #测试子函数
        '<'  => sub{ ($_[0] <  $_[1]) ? 1 : 0 },
        '<=' => sub{ ($_[0] <= $_[1]) ? 1 : 0 },
        '>'  => sub{ ($_[0] >  $_[1]) ? 1 : 0 },
        '>=' => sub{ ($_[0] >= $_[1]) ? 1 : 0 },
        '!=' => sub{ ($_[0] != $_[1]) ? 1 : 0 },
        '='  => sub{ ($_[0] == $_[1]) ? 1 : 0 },
        '==' => sub{ ( ((($_[0] - $_[2]) % $_[1]) == 0) && ($_[0] > 1) ) ? 1 : 0 }
);

sub coredump {
        my ($c_dir) = @_;
        my %core_res;
        opendir(DIR,$c_dir) or die "cat not open the dir: $!";
        foreach my $file (readdir DIR){
                next unless $file =~ /^core\./;
                my $core_file = $c_dir."/".$file;
                my ($core_proc) = `file $core_file 2>/dev/null` =~ /\, (\S+)/;
                my $file_time = (stat($c_dir."/".$file))[9];
                $core_res{$core_proc}->[0]++ if (time() - $file_time < $max_restart_sec);
                if ( $file_time > $core_res{$core_proc}->[1] ) {
                        $core_res{$core_proc}->[1] = $file_time;
                        $core_res{$core_proc}->[2] = $core_file;
                }
        }
        return %core_res;
}

sub proc {
        my ($process,$match,$not_match,$a_restart,$oper,$value) = @_;
        my (@proc_sec,@proc_sec2,$restart_num,$min_sec);
        my @ps_res  = grep { /$process/i }   @ps_args;
        @ps_res     = grep { /$etc_dir/i }   @ps_res if $process !~ /ftpcp|bridge|monitor_ctrl/i;
        @ps_res     = grep { /$match/i }     @ps_res if $match;
        @ps_res     = grep {!/$not_match/i } @ps_res if $not_match;
        @ps_res     = grep {!/gzip|more/ }   @ps_res;
        my $all_num = @ps_res;
        my $par_num = grep {/^\s+1\s/} @ps_res;
        my $state   = $judge{$oper}->($all_num,$value,$par_num);
        if ($all_num && $a_restart) {
                foreach(@ps_res){
                        s/^\s*//g;
                        my @ps_attr = split(/\s+/,$_);
                        my @time_attr = reverse(split(/\-|\:/,$ps_attr[1]));
                        my $sec = $time_attr[0];
                        $sec += $time_attr[1] * 60    if $time_attr[1];
                        $sec += $time_attr[2] * 3600  if $time_attr[2];
                        $sec += $time_attr[3] * 86400 if $time_attr[3];
                        push @proc_sec, $sec;
                        #$restart_num++ if $sec < $max_restart_sec;
                        #$min_sec = $sec if $sec < $min_sec;
                }
                if ( @proc_sec > 1 ) {
                        my $max_proc_sec = (sort {$b<=>$a} @proc_sec)[0];
                        map { push @proc_sec2,$_ if $_ < 3600 && $max_proc_sec - $_ > $max_restart_sec } @proc_sec;
                        $restart_num = @proc_sec2 ;
                        $min_sec = (sort {$a<=>$b} @proc_sec2)[0];
                } elsif ( $proc_sec[0] < $max_restart_sec ) {
                        $restart_num = 1 ;
                        $min_sec = $proc_sec[0];
                }
        }
        $restart_num =~ s/^(\d)$/$1 / if $restart_num;
        my $min_time = strftime "%Y-%m-%d %H:%M:%S", localtime(time() - $min_sec);
        my $oper_value = $state ? "$oper $value" : "\033[5;7m$oper $value\033[m";
        my $desc = $restart_num ? "[$restart_num个重启$min_time]$warn_str" : ( ! $state ? $warn_str : "OK");
        return ($par_num,$all_num,$oper_value,"",$desc);
}

main:{
        print "\033[1;1m★ 进程状态监控：进程数、在$max_restart_str之内是否出现重启、是否产生coredump\n";
        my @hosts       = NgBoss::Info::Host();
        my $host_status = NgBoss::Info::Status();
        foreach my $host(@hosts) {
                ($city_num) = NgBoss::Info::Node($host);
                $etc_dir = $host =~ /(ST|SW|SG|YF)$/ ? $1."etc" : "etc";
                do "start.cfg"; 
                do "chk_proc.cfg"; 
                #print "$host: $core_dir\n";
                my %core_res = &coredump($core_dir);
                foreach (keys %core_res) {
                        my ($core_num,$core_sec,$core_file) = @{$core_res{$_}};
                        next unless $core_num;
                        my $core_time = strftime "%Y-%m-%d %H:%M:%S", localtime($core_sec);
                        printf "\n%-18s%-20s%-8s%-22s%-50s%-7s\n%s\033[m\n","Hostname","Process","Num","Time","Core_File","Status","=" x 124 if ! $cf++;
                        printf "%-18s%-20s%-8d%-22s%-50s%-7s\033[m\n",$host,$_,$core_num,$core_time,$core_file,$warn_str;
                }
                foreach my $com(keys %proc_info) {
                        foreach (@{$proc_info{$com}}) {
                                my ($process,$match,$not_match,$a_restart,$a_status,$ha_value) = @{$_};
                                my ($oper,$value) = ('=',0);
                                if ( ! $a_status || $a_status eq $host_status ){
                                        my $oper_value = ${$ha_value}{'ng'};
                                        $oper_value = ${$ha_value}{'sb'} if $host_status == -1 && defined ${$ha_value}{'sb'};
                                        foreach(sort keys %{$ha_value}) {
                                                $oper_value = ${$ha_value}{$_} if $city_num =~ /$_/i;
                                        }
                                        ($oper,$value) = $oper_value =~ /\s*([^\d\s]+)\s*(\d+)/;
                                }
                                push @{$proc_res{$com}{$host}},[&proc($process,$match,$not_match,$a_restart,$oper,$value)];
                                push @{$processes{$com}{$host}},[$process,$match];
                        }
                }
        }
        my $lg = 65 * @hosts - 33;
        printf "\033[1m\n%-35s","Process_name";
        printf "%6s%-8s%-8s%-8s%-35s","","Parent","Total","Rule","Status" foreach(@hosts);
        print "\n","=" x ($lg + 39);
        print "\033[m";
        foreach my $com(sort keys %proc_res) {
                printf "\n\033[1;4m%-35s\033[m",$com;
                printf "\033[1;4m%${lg}s\033[m","";
                print "\n";
                foreach my $i( 0 .. @{$proc_res{$com}{$hosts[0]}} - 1 ) {
                        my $proc_com;
                        foreach (@hosts) {
                                my ($com0,$com1) = @{$processes{$com}{$_}[$i]};
                                if ( /^$hosts[0]$/ ) {
                                        $proc_com = $com0;
                                        $proc_com .= " $com1" if $com1;
                                } elsif ( $com1 ne ${$processes{$com}{$hosts[0]}[$i]}[1]) {
                                        $proc_com .= "|$com1";
                                }
                        }
                        printf "%-35s",$proc_com;
                        foreach (@hosts) {
                                my $len2 = length(${$proc_res{$com}{$_}[$i]}[2]);
                                my $len4 = length(${$proc_res{$com}{$_}[$i]}[4]);
                                my $aa = $len2 > 8 ? 17 : 8;
                                $aa -= $len2;
                                my $bb = /^$hosts[-1]$/ ? $len4 : ($len4 > 2 ? 44 : ($len2 > 8 ? 44 : 35));
                                $bb -= $len4;
                                my $nn = "[$1]" if /(ST|SW|SG|YF)$/;
                                printf "\033[1m%-6s\033[m%-8d%-8d%s%${aa}s%s%${bb}s",$nn,@{$proc_res{$com}{$_}[$i]},"" ;
                        }
                        print "\n";
                }
        }
        print "\n";
}