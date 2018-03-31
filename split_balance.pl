
#!/usr/bin/perl
# 20140319 tfw 免费资源账本割接
# 20140402 tfw 修改第3步免费资源取数的逻辑
# 产品（有产品包则提供产品包，无产品包则提供子产品）、更改前优惠代码、更改前帐本，更改后优惠代码（可能同更改前优惠代码），更改后帐本
# 1、根据新旧的dis_code分别查找赠送规则的新旧规则标识rule_id
# 2、由旧rule_id确定counterpre_log中的log_id字段，修改新账本标识和新规则标识
# 3、由log_id和prodid确定balance_res， 如果免费资源中的prodid不存在割接产品列表中，再根据relation_id查询discount表的子产品prodid字段，若存在割接产品列表中则符合条件，修改免费资源表新账本标识

BEGIN{push (@INC,"/usr1/monk/bin/perl/lib")};

use Time::Local;
use Getopt::Std;
use POSIX qw(strftime);
use NgBoss::DB;
use vars qw($opt_f $opt_a $opt_h $opt_n); 
getopts('f:a:hn:');

# 输入参数校验
&PrintUsage if ( ! $opt_f || ! $opt_a || ! $opt_n || $opt_h);

# 节点信息
my %node_info = (
           2001  =>  ['zhabm1' ,'zhabm2' ],
           2002  =>  ['fsabm1' ,'fsabm2' ],
           2003  =>  ['fsabm3' ,'fsabm4' ],
           2004  =>  ['fsabm5' ,'fsabm6' ],
           2005  =>  ['zsabm1' ,'zsabm2' ],
           2006  =>  ['stabm1' ,'stabm2' ],
           2007  =>  ['stabm3' ,'stabm4' ],
           2008  =>  ['swabm1' ,'swabm2' ],
           2009  =>  ['czabm1' ,'czabm2' ],
           2010  =>  ['jyabm1' ,'jyabm2' ],
           2011  =>  ['zqabm1' ,'zqabm2' ],
           2012  =>  ['sgabm1' ,'sgabm2' ],
           2013  =>  ['qyabm1' ,'qyabm2' ],
           2014  =>  ['yfabm1' ,'yfabm2' ],
           2021  =>  ['szabm1' ,'szabm2' ],
           2022  =>  ['szabm3' ,'szabm4' ],
           2023  =>  ['szabm5' ,'szabm6' ],
           2024  =>  ['szabm7' ,'szabm8' ],
           2025  =>  ['szabm9' ,'szabm10'],
           2026  =>  ['szabm11','szabm12'],
           2027  =>  ['szabm13','szabm14'],
           2028  =>  ['szabm15','szabm16'],
);

# 每1024行commit一次，每commit3次sleep 1s
my $commit_num = 1024;
my $sleep_num  = 3;

# 工作目录
my $work_dir = "balance_res";

# 获取当前系统时间
my $now   = strftime "%Y%m%d%H%M%S", localtime(time);
my $opt_d = $node_info{$opt_n}[1];
my $user  = substr($opt_d,0,2)."hsc";
my ($dbh,%cnt,%file);
$opt_a    = "/*".$opt_a."*/" if $opt_a;


sub PrintUsage{
print <<usage;
\n       Usage: $0   [OPTIONS]
              -f   产品与账本对应关系文件
              -n   节点号
              -a   AMS单号 \n
usage
      exit 0;
}

# 根据优惠代码查询赠送规则表，返回对应的规则标识
sub query_res_rule {
      my ($old_code) = @_;
      my $sth_res = $dbh->prepare(qq{select $opt_a FREERES_RULE_ID from GDHSC.IB_RU_RESOURERULE where DISCOUNT_CODE = ?;}) || die $dbh->errstr ;
      $sth_res->execute($old_code) || die $dbh->errstr ;
      my $rule_id = $sth_res->fetchrow_array();
      $sth_res->finish();
      return $rule_id;
}

# 根据规则标识查询赠送日志表
sub query_counterpre_log {
      my ($rule_id) = @_;
      my $sth_res = $dbh->prepare(qq{select $opt_a * from ${user}.COUNTERPRES_LOG where FREERES_RULE_ID = ?;}) || die $dbh->errstr ;
      $sth_res->execute($rule_id) || die $dbh->errstr ;
      my $counterpre_log = $sth_res->fetchall_arrayref();
      return $counterpre_log;
}

# 根据赠送日志标识和产品ID查询免费资源表
sub query_free_res {
      my ($subsid,$log_id) = @_;
      my $sth_res = $dbh->prepare(qq{select $opt_a * from ${user}.SUBS_BALANCE_RES where SUBS_ID = ? and INIT_CHGLOG_ID = ?;}) || die $dbh->errstr ;
      $sth_res->execute($subsid,$log_id) || die $dbh->errstr ;
      my $free_res = $sth_res->fetchall_arrayref();
      return $free_res;
}

# 根据关系标识查询优惠订购，取出产品ID
sub query_discount {
      my ($relation_id) = @_;
      my $sth_res = $dbh->prepare(qq{select $opt_a PRODID from ${user}.HSC_SUBS_DISCOUNT${opt_n} where SUBS_RELATION_ID = ?;}) || die $dbh->errstr ;
      $sth_res->execute($relation_id) || die $dbh->errstr ;
      my $dis_prodid = $sth_res->fetchrow_array();
      return $dis_prodid;
}

main:{
     if (! $opt_d){
           print "节点号[$opt_n]无定义!\n";
           exit 0;
     }
     system("mkdir -m 777 $work_dir") unless -e $work_dir; 
     my $time = time();
     print "$opt_n,$opt_d connecting...\n";
     
     # TT数据库连接
     #$dbh = &NgBoss::DB::TTConnect_EX($opt_d,'monk','monk');
     my $dsn = "DBI:TimesTen:DSN=$opt_d;UID=monk;PWD=monk";
     my %db_attr = ( "RaiseError" => 1, "PrintError" => 1, "AutoCommit" => 0,);
     $dbh = DBI->connect($dsn,undef,undef,\%db_attr) or die $DBI::err ;

     
     $file{'update'} = "${work_dir}/_${now}_${opt_d}_update.sql";
     $file{'delete'} = "${work_dir}/_${now}_${opt_d}_delete.sql";
     $file{'insert'} = "${work_dir}/_${now}_${opt_d}_insert.sql";
     open(FH,$opt_f) or die $!;
     open(UPT,">$file{'update'}") or die $!;
     open(DEL,">$file{'delete'}") or die $!;
     open(INS,">$file{'insert'}") or die $!;
     open(L_BAK,">${work_dir}/_${now}_${opt_d}_counterpre_log.dat") or die $!;
     open(F_BAK,">${work_dir}/_${now}_${opt_d}_subs_balance_res.dat") or die $!;
     
     print UPT "autocommit 0;\n";
     print DEL "autocommit 0;\n";
     print INS "autocommit 0;\n";
     
     while(<FH>){
         chomp;
         next if /^\s*#/;
         print "$_\n";
         my ($prodid,$old_code,$old_balance_id,$new_code,$new_balance_id) = split('\|',$_);
         ## 1、根据新旧的dis_code分别查找赠送规则的新旧规则标识rule_id
         my $old_rule_id = &query_res_rule($old_code);
         my $new_rule_id = &query_res_rule($new_code);
         
         ## 2、由旧rule_id确定counterpre_log中的log_id字段
         my $counterpre_log = &query_counterpre_log($old_rule_id);
         foreach my $log_row(@$counterpre_log){
             my ($log_id,$subsid,$log_relation_id) = ($$log_row[0],$$log_row[1],$$log_row[2]);
             my $log_line = join('|',@$log_row);
             
             ## 3、由log_id和prodid确定balance_res
             ##my $free_res = &query_free_res($subsid,$log_id,$prodid);
             my $free_res = &query_free_res($subsid,$log_id);
             foreach my $free_row(@$free_res){
                 my ($subsid,$free_balance_id,$free_detail_id,$free_prodid) = ($$free_row[0],$$free_row[1],$$free_row[2],$$free_row[6]);
                 
                 ## 如果免费资源中的prodid不存在割接产品列表中，再根据relation_id查询discount表的子产品prodid字段，若存在割接产品列表中则符合条件。
                 if ($free_prodid ne $prodid) {
                     my $dis_prodid = &query_discount($log_relation_id);
                     next if $dis_prodid ne $prodid;
                 }

                 ## 备份赠送日志记录
                 print L_BAK "$log_line\n";
                 ## 将counterpre_log表修改为新账本标识和新规则标识
                 my $upt_sql = "update $opt_a ${user}.COUNTERPRES_LOG set BALANCEID = $new_balance_id, FREERES_RULE_ID = $new_rule_id where LOG_ID = $log_id;";
                 $cnt{'upd'}++;
                 print UPT "$upt_sql\n";
                 print UPT "commit;\n" if $cnt{'upd'} % $commit_num == 0;
                 print UPT "sleep 1;\n" if $cnt{'upd'} % ($commit_num * $sleep_num) == 0;
                 
                 ## 备份免费资源记录
                 my $free_line = join('|',@$free_row);
                 my $free_line1=$free_line."|".$new_balance_id;
                 print F_BAK "$free_line1\n";
                 ## 将balance_res表修改为新账本标识(先删除后插入)
                 my $del_sql = "delete from $opt_a ${user}.SUBS_BALANCE_RES where SUBS_ID = $subsid and SUBS_BALANCE_ITEM_ID = $free_balance_id and DETAIL_ID = $free_detail_id;";
                 my $ins_sql = "insert into $opt_a ${user}.SUBS_BALANCE_RES values ($$free_row[0],$new_balance_id,$$free_row[2],$$free_row[3],'$$free_row[4]','$$free_row[5]','$$free_row[6]',$$free_row[7],$$free_row[8],$$free_row[9],'2014-04-09 02:00:00',$$free_row[11]);";
                 $cnt{'ins'}++;
                 print DEL "$del_sql\n";
                 print INS "$ins_sql\n";
                 print DEL "commit;\n" and print INS "commit;\n" if $cnt{'ins'} % $commit_num == 0;
                 print DEL "sleep 1;\n" and print INS "sleep 1;\n" if $cnt{'ins'} % ($commit_num * $sleep_num) == 0;
             }
         }
     }
     
     print UPT "commit;\n";
     print DEL "commit;\n";
     print INS "commit;\n";
     close(UPT);
     close(DEL);
     close(INS);
     close(L_BAK);
     close(F_BAK);
     $dbh->disconnect() and print "Done.\n";
     my $uu = time() - $time;
     print "Time:${uu}s\n\n";
     print "ttisqlcs -f $file{$_} 'dsn=$node_info{$opt_n}[0];uid=${user};pwd=ttadmin' > ${work_dir}/_${now}_${opt_d}_${_}.log\n" foreach (sort keys %file) ;
}

[cxzzh@FSBOSS-CBE1]/logs/_tmp/_tfw/20140402$ 