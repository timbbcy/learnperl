#!/usr/bin/perl
# 20130501 tanfengwei 创建
# 20151016 添加新CBE主机

package NgBoss::Info;

use strict;

my %ip_list;

my %tt_info_hash = (
           'GDBOSS-TPC1'    => ['gd' ,2901], 'GDBOSS-TPC2'    => ['gd' ,2901],
           'GDBOSS-ABM1'    => ['gd' ,2901], 'GDBOSS-ABM2'    => ['gd' ,2901],
           'GDBOSS-CBE1'    => ['gd' ,2901], 'GDBOSS-CBE2'    => ['gd' ,2901],

           'FSBOSS-CBE1'    => ['fs1',2002], 'FSBOSS-CBE2'    => ['fs1',2002],
           'FSBOSS-CBE3'    => ['fs2',2003], 'FSBOSS-CBE4'    => ['fs2',2003],
           'FSBOSS-CBE5'    => ['fs3',2004], 'FSBOSS-CBE6'    => ['fs3',2004],
           'FSBOSS-CBE7'    => ['zs1',2005], 'FSBOSS-CBE8'    => ['zs1',2005],
           'FSBOSS-CBE9'    => ['zh' ,2001], 'FSBOSS-CBE10'   => ['zh' ,2001],
           'FSBOSS-CBE11'   => ['zs2',2005], 'FSBOSS-CBE12'   => ['zs2',2005],
           'STBOSS-CBE1'    => ['st1',2006], 'STBOSS-CBE2'    => ['st1',2006],
           'STBOSS-CBE3'    => ['jy' ,2010], 'STBOSS-CBE4'    => ['jy' ,2010],
           'STBOSS-CBE5-ST' => ['st2',2007], 'STBOSS-CBE6-ST' => ['st2',2007],
           'STBOSS-CBE5-SW' => ['sw' ,2008], 'STBOSS-CBE6-SW' => ['sw' ,2008],
           'STBOSS-CBE7'    => ['cz' ,2009], 'STBOSS-CBE8'    => ['cz' ,2009],
           'STBOSS-CBE9'    => ['qy' ,2013], 'STBOSS-CBE10'   => ['qy' ,2013],
           'STBOSS-CBE11-SG'=> ['sg' ,2012], 'STBOSS-CBE12-SG'=> ['sg' ,2012],
           'STBOSS-CBE11-YF'=> ['yf' ,2014], 'STBOSS-CBE12-YF'=> ['yf' ,2014],
           'STBOSS-CBE13'   => ['zq' ,2011], 'STBOSS-CBE14'   => ['zq' ,2011],
           'SZBOSS-CBE1'    => ['sz1',2021], 'SZBOSS-CBE2'    => ['sz1',2021], 
           'SZBOSS-CBE3'    => ['sz2',2022], 'SZBOSS-CBE4'    => ['sz2',2022], 
           'SZBOSS-CBE5'    => ['sz3',2023], 'SZBOSS-CBE6'    => ['sz3',2023], 
           'SZBOSS-CBE7'    => ['sz4',2024], 'SZBOSS-CBE8'    => ['sz4',2024], 
           'SZBOSS-CBE9'    => ['sz5',2025], 'SZBOSS-CBE10'   => ['sz5',2025], 
           'SZBOSS-CBE11'   => ['sz6',2026], 'SZBOSS-CBE12'   => ['sz6',2026], 
           'SZBOSS-CBE13'   => ['sz7',2027], 'SZBOSS-CBE14'   => ['sz7',2027], 
           'SZBOSS-CBE15'   => ['sz8',2028], 'SZBOSS-CBE16'   => ['sz8',2028], 
                      
           'FSBOSS-ABM1'    => ['fs1',2002], 'FSBOSS-ABM2'    => ['fs1',2002],
           'FSBOSS-ABM3'    => ['fs2',2003], 'FSBOSS-ABM4'    => ['fs2',2003],
           'FSBOSS-ABM5'    => ['fs3',2004], 'FSBOSS-ABM6'    => ['fs3',2004],
           'FSBOSS-ABM7'    => ['zs' ,2005], 'FSBOSS-ABM8'    => ['zs' ,2005],
           'FSBOSS-ABM9'    => ['zh' ,2001], 'FSBOSS-ABM10'   => ['zh' ,2001],
           'STBOSS-ABM1'    => ['st1',2006], 'STBOSS-ABM2'    => ['st1',2006],
           'STBOSS-ABM3'    => ['jy' ,2010], 'STBOSS-ABM4'    => ['jy' ,2010],
           'STBOSS-ABM5-ST' => ['st2',2007], 'STBOSS-ABM6-ST' => ['st2',2007],
           'STBOSS-ABM5-SW' => ['sw' ,2008], 'STBOSS-ABM6-SW' => ['sw' ,2008],
           'STBOSS-ABM7'    => ['cz' ,2009], 'STBOSS-ABM8'    => ['cz' ,2009],
           'STBOSS-ABM9'    => ['qy' ,2013], 'STBOSS-ABM10'   => ['qy' ,2013],
           'STBOSS-ABM11-SG'=> ['sg' ,2012], 'STBOSS-ABM12-SG'=> ['sg' ,2012],
           'STBOSS-ABM11-YF'=> ['yf' ,2014], 'STBOSS-ABM12-YF'=> ['yf' ,2014],
           'STBOSS-ABM13'   => ['zq' ,2011], 'STBOSS-ABM14'   => ['zq' ,2011],
           'SZBOSS-ABM1'    => ['sz1',2021], 'SZBOSS-ABM2'    => ['sz1',2021], 
           'SZBOSS-ABM3'    => ['sz2',2022], 'SZBOSS-ABM4'    => ['sz2',2022], 
           'SZBOSS-ABM5'    => ['sz3',2023], 'SZBOSS-ABM6'    => ['sz3',2023], 
           'SZBOSS-ABM7'    => ['sz4',2024], 'SZBOSS-ABM8'    => ['sz4',2024], 
           'SZBOSS-ABM9'    => ['sz5',2025], 'SZBOSS-ABM10'   => ['sz5',2025], 
           'SZBOSS-ABM11'   => ['sz6',2026], 'SZBOSS-ABM12'   => ['sz6',2026], 
           'SZBOSS-ABM13'   => ['sz7',2027], 'SZBOSS-ABM14'   => ['sz7',2027], 
           'SZBOSS-ABM15'   => ['sz8',2028], 'SZBOSS-ABM16'   => ['sz8',2028], 

           'STBOSS_STCBE1'  => ['nst1',2100],'STBOSS_STCBE2'  => ['nst1',2100], #待定
           'STBOSS_STCBE3'  => ['nst1',2100],'STBOSS_STCBE4'  => ['nst1',2100],
           'STBOSS_STCBE5'  => ['nst1',2100],'STBOSS_STCBE6'  => ['nst1',2100],
           'STBOSS_JYCBE1'  => ['nst1',2100],'STBOSS_JYCBE2'  => ['nst1',2100],
           'STBOSS_JYCBE3'  => ['nst1',2100],'STBOSS_JYCBE4'  => ['nst1',2100],
           'STBOSS_SWCBE1'  => ['nst1',2100],'STBOSS_SWCBE2'  => ['nst1',2100],
           'STBOSS_SGCBE1'  => ['nst1',2100],'STBOSS_SGCBE2'  => ['nst1',2100],
           'STBOSS_YFCBE1'  => ['nst1',2100],'STBOSS_YFCBE2'  => ['nst1',2100],
           'SZBOSS_SZCBE7'  => ['nst1',2100],'SZBOSS_SZCBE8'  => ['nst1',2100],
           'SZBOSS_SZCBE17' => ['nst1',2100],'SZBOSS_SZCBE18' => ['nst1',2100],
           'FSBOSS_ZHCBE1'  => ['nst1',2100],'FSBOSS_ZHCBE2'  => ['nst1',2100],
);

our %diff_hash = (
           'GD' => ['etc','/logs','/appdata'],
           'NG' => ['etc','/fclogs','/cdr','/cbsapp1','/cbsapp2','/usr1/ngboss/cbe/etc/queue','/logs','/cbsapp','/usr1/ngboss/abm/queue'],
          '-ST' => ['stetc','/logs/stcbe','/cdr/stcbe','/cbsapp1/stcbe','/cbsapp2/stcbe','/usr1/ngboss/cbe/stetc/queue','/logs/stabm','/cbsapp/stabm','/usr1/ngboss/abm/stqueue'],
          '-SW' => ['swetc','/logs/swcbe','/cdr/swcbe','/cbsapp1/swcbe','/cbsapp2/swcbe','/usr1/ngboss/cbe/swetc/queue','/logs/swabm','/cbsapp/swabm','/usr1/ngboss/abm/swqueue'],
          '-SG' => ['sgetc','/logs/sgcbe','/cdr/sgcbe','/cbsapp1/sgcbe','/cbsapp2/sgcbe','/usr1/ngboss/cbe/sgetc/queue','/logs/sgabm','/cbsapp/sgabm','/usr1/ngboss/abm/sgqueue'],
          '-YF' => ['yfetc','/logs/yfcbe','/cdr/yfcbe','/cbsapp1/yfcbe','/cbsapp2/yfcbe','/usr1/ngboss/cbe/yfetc/queue','/logs/yfabm','/cbsapp/yfabm','/usr1/ngboss/abm/yfqueue'],
);

### 主备机状态标识 (1主机|-1备机)
my $host_state = -1;

sub Status {
     map{$ip_list{"10.252.16.$_"}=1} qw/25 29 31/;
     map{$ip_list{"10.252.19.$_"}=1} qw/1 3 5 7 9 11 13 15 17 19 33 35/; 
     map{$ip_list{"10.252.23.$_"}=1} qw/1 3 5 7 9 11 13 15 17 19 33 35 37 39 41 43 45 47 49 51 53 55/;
     map{$ip_list{"10.252.25.$_"}=1} qw/1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 45 47/;
     map{if(/inet (10\..+) netmask/ && $ip_list{$1}){$host_state = 1}} qx{ifconfig -a} or die "exec cmd:ifconfig -a:$!";
     return $host_state;
}

sub Host {
     chomp(my $host_name = `hostname`);
#     my @hosts = $host_name=~/STBOSS.+(5|6)/   ? ($host_name."-ST",$host_name."-SW")
#               : $host_name=~/STBOSS.+(11|12)/ ? ($host_name."-SG",$host_name."-YF")
#               : ($host_name);
my @hosts = $host_name;
     return @hosts;;
}

sub Node {
     my ($host) = @_;
     return 0 unless defined $tt_info_hash{$host};
     return @{$tt_info_hash{$host}};
}

sub Dir {
     my ($host_flag) = @_;
     return 0 unless defined $diff_hash{$host_flag};
     return @{$diff_hash{$host_flag}};
}

1;

__END__