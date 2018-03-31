#!/usr/bin/perl
BEGIN{push (@INC,"/usr1/monk/bin/perl/lib")};

use Time::Local;
use POSIX qw(strftime);
use NgBoss::DB;


if( @ARGV != 3){
                print "Usage: $0 tar_file AMS node\n";
                exit;
}
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

        my $dbh;
				my $tar_file=$ARGV[0];
				my $opt_a=$ARGV[1];
				my $opt_n=$ARGV[2];
				my $opt_d = $node_info{$opt_n}[1];
				my $user = substr($opt_d,0,2)."hsc";
        $opt_a    = "/*".$opt_a."*/" if $opt_a;
        my $now   = strftime "%Y%m%d%H%M%S", localtime(time);
        
        
        # 工作目录
				#my $work_dir = "balance_res";
                
                
sub query_res {
      my ($SUBS_ID,$SUBS_BALANCE_ITEM_ID,$DETAIL_ID,$new_balance_id) = @_;
      my $sth_res = $dbh->prepare(qq{select $opt_a * from ${user}.SUBS_BALANCE_RES where SUBS_ID= ? and SUBS_BALANCE_ITEM_ID= ? and DETAIL_ID= ?;}) || die $dbh->errstr ;
			$sth_res->bind_param(1,$SUBS_ID);
			$sth_res->bind_param(2,$SUBS_BALANCE_ITEM_ID);
			$sth_res->bind_param(3,$DETAIL_ID);
      $sth_res->execute() || die $dbh->errstr ;
      my @res_return = $sth_res->fetchrow_array();
      $sth_res->finish();
      return @res_return;
}


sub main()
{
	   #my $ins_file = "${work_dir}/_${now}_${opt_d}_insert_after.sql";
	   my $ins_file = "./_${now}_${opt_d}_insert_after.sql";
	   #system("mkdir -m 777 $work_dir") unless -e $work_dir;
	   # TT数据库连接
     my $dsn = "DBI:TimesTen:DSN=$opt_d;UID=monk;PWD=monk";
     my %db_attr = ( "RaiseError" => 1, "PrintError" => 1, "AutoCommit" => 0,);
     $dbh = DBI->connect($dsn,undef,undef,\%db_attr) or die $DBI::err ;
     				     				print "$ins_file\n";
                open FH,"$tar_file" or die $!;
                open(INS,">>$ins_file") or die $!;
                while(<FH>){
                chomp;
                my @res_rec=split/\|/,$_;
                my ($SUBS_ID,$SUBS_BALANCE_ITEM_ID,$DETAIL_ID,$new_balance_id)=($res_rec[0],$res_rec[1],$res_rec[2],$res_rec[12]);
                my @free_row=&query_res($SUBS_ID,$SUBS_BALANCE_ITEM_ID,$DETAIL_ID,$new_balance_id);
                	      my $ins_sql = "insert into $opt_a ${user}.SUBS_BALANCE_RES values ($free_row[0],$new_balance_id,$free_row[2],$free_row[3],'$free_row[4]','$free_row[5]','$free_row[6]',$free_row[7],$free_row[8],$free_row[9],sysdate,$free_row[11]);";
                	      print INS "$ins_sql\n";
                } 
                close(FH);
                     close(INS);
                     $dbh->disconnect() and print "Done.\n";
}
&main;
                	
                	
                
                	
                	