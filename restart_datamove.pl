my %dir_path = (
 # 程序目录配置 => [ [接口目录,程序配置目录,节点,地市] ]
'CBE_bin DSU'   => [
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"FS1"  , "FS" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"FS2"  , "FS" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"FS3"  , "FS" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"ZS"   , "ZS" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"ZH"   , "ZH" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"ST1"  , "ST" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"JY"   , "JY" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"CZ"   , "CZ" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"QY"   , "QY" ],
                    ["/cbsapp/restart_Datamove"   ,"/usr1/ngboss/ngabm/etc"     ,"ZQ"   , "ZQ" ],
                    ["/cbsapp/restart_Datamove/ST2"  ,"/usr1/ngboss/abm/stetc"  ,"ST2"  , "ST" ],
                    ["/cbsapp/restart_Datamove/SW"   ,"/usr1/ngboss/abm/swetc"  ,"SW"   , "SW" ],
                    ["/cbsapp/restart_Datamove/YF"   ,"/usr1/ngboss/abm/yfetc"  ,"YF"   , "YF" ],
                    ["/cbsapp/restart_Datamove/SG"   ,"/usr1/ngboss/abm/sgetc"  ,"SG"   , "SG" ]   
                   ]
); 

while (1) {
	
     for(sort keys %dir_path){
           for(@{$dir_path{$_}}){
                &movefile(@{$_});
           }
     }
     sleep 30;
}

sub deal_unwoff
{
  my ($compare_date , $operator) = @_;
  my @zero_unwoff_export_file = glob "${unwoff_dir}/ACCT_UNWOFF*${compare_date}*";
  foreach(@zero_unwoff_export_file)
  {
    open (ZERO_UNWOFF_EXPORT_HANDLE , "cat $_|") or die  "can not open $_!";
    while(<ZERO_UNWOFF_EXPORT_HANDLE>){