#!/usr/bin/perl
use strict;
use lib "/cbsapp1/_tmp/ych/tool/perl_lib/lib64/site_perl";
use Net::SSH::Expect;
use Getopt::Long;


our %host_hash = (
     'fscbe1'  =>  ['10.252.19.1' ,1],   'fscbe2'  =>  ['10.252.19.2' ,2],
     'fscbe3'  =>  ['10.252.19.3' ,1],   'fscbe4'  =>  ['10.252.19.4' ,2],
     'fscbe5'  =>  ['10.252.19.5' ,1],   'fscbe6'  =>  ['10.252.19.6' ,2],
     'zscbe1'  =>  ['10.252.19.7' ,1],   'zscbe2'  =>  ['10.252.19.8' ,2],
     'zhcbe1'  =>  ['10.252.19.9' ,1],   'zhcbe2' =>  ['10.252.19.10',2],
     'fsabm1'  =>  ['10.252.19.11',1],   'fsabm2'  =>  ['10.252.19.12',2],
     'fsabm3'  =>  ['10.252.19.13',1],   'fsabm4'  =>  ['10.252.19.14',2],
     'fsabm5'  =>  ['10.252.19.15',1],   'fsabm6'  =>  ['10.252.19.16',2],
     'zsabm1'  =>  ['10.252.19.17',1],   'zsabm2'  =>  ['10.252.19.18',2],
     'zhabm1'  =>  ['10.252.19.19',1],   'zhabm2' =>  ['10.252.19.20',2],

     'stcbe1'  =>  ['10.252.23.1' ,1],   'stcbe2'  =>  ['10.252.23.2' ,2],
     'jycbe1'  =>  ['10.252.23.3' ,1],   'jycbe2'  =>  ['10.252.23.4' ,2],
     'swcbe1'  =>  ['10.252.23.5' ,1],   'swcbe2'  =>  ['10.252.23.6' ,2],
     'stcbe3'  =>  ['10.252.23.5' ,1],   'stcbe4'  =>  ['10.252.23.6' ,2],
     'czcbe1'  =>  ['10.252.23.7' ,1],   'czcbe2'  =>  ['10.252.23.8' ,2],
     'stabm1'  =>  ['10.252.23.11',1],   'stabm2'  =>  ['10.252.23.12',2],
     'jyabm1'  =>  ['10.252.23.13',1],   'jyabm2'  =>  ['10.252.23.14',2],
     'swabm1'  =>  ['10.252.23.15',1],   'swabm2'  =>  ['10.252.23.16',2],
     'stabm3'  =>  ['10.252.23.15',1],   'stabm4'  =>  ['10.252.23.16',2],
     'czabm1'  =>  ['10.252.23.17',1],   'czabm2'  =>  ['10.252.23.18',2],

     'qycbe1' =>  ['10.252.23.9' ,1],    'qycbe2' =>  ['10.252.23.10',2],
     'yfcbe1' =>  ['10.252.23.33',1],    'yfcbe2' =>  ['10.252.23.34',2],
     'sgcbe1' =>  ['10.252.23.33',1],    'sgcbe2' =>  ['10.252.23.34',2],
     'zqcbe1' =>  ['10.252.23.37',1],    'zqcbe2' =>  ['10.252.23.38',2],
     'qyabm1' =>  ['10.252.23.19',1],    'qyabm2' =>  ['10.252.23.20',2],
     'yfabm1' =>  ['10.252.23.35',1],    'yfabm2' =>  ['10.252.23.36',2],
     'sgabm1' =>  ['10.252.23.35',1],    'sgabm2' =>  ['10.252.23.36',2],
     'zqabm1' =>  ['10.252.23.39',1],    'zqabm2' =>  ['10.252.23.40',2],

     'szcbe1'  =>  ['10.252.25.1' ,1],   'szcbe2'  =>  ['10.252.25.2' ,2],
     'szcbe3'  =>  ['10.252.25.3' ,1],   'szcbe4'  =>  ['10.252.25.4' ,2],
     'szcbe5'  =>  ['10.252.25.5' ,1],   'szcbe6'  =>  ['10.252.25.6' ,2],
     'szcbe7'  =>  ['10.252.25.7' ,1],   'szcbe8'  =>  ['10.252.25.8' ,2],
     'szcbe9'  =>  ['10.252.25.9' ,1],   'szcbe10' =>  ['10.252.25.10',2],
     'szcbe11' =>  ['10.252.25.11',1],   'szcbe12' =>  ['10.252.25.12',2],
     'szcbe13' =>  ['10.252.25.13',1],   'szcbe14' =>  ['10.252.25.14',2],
     'szcbe15' =>  ['10.252.25.15',1],   'szcbe16' =>  ['10.252.25.16',2],
     'szabm1'  =>  ['10.252.25.17',1],   'szabm2'  =>  ['10.252.25.18',2],
     'szabm3'  =>  ['10.252.25.19',1],   'szabm4'  =>  ['10.252.25.20',2],
     'szabm5'  =>  ['10.252.25.21',1],   'szabm6'  =>  ['10.252.25.22',2],
     'szabm7'  =>  ['10.252.25.23',1],   'szabm8'  =>  ['10.252.25.24',2],
     'szabm9'  =>  ['10.252.25.25',1],   'szabm10' =>  ['10.252.25.26',2],
     'szabm11' =>  ['10.252.25.27',1],   'szabm12' =>  ['10.252.25.28',2],
     'szabm13' =>  ['10.252.25.29',1],   'szabm14' =>  ['10.252.25.30',2],
     'szabm15' =>  ['10.252.25.31',1],   'szabm16' =>  ['10.252.25.32',2],
);

my ($user,$config,$node,$execute,$help);
GetOptions(
        "user=s"        =>  \$user,
        "node=s"       =>   \$node,
        "execute=s"       =>   \$execute,
        "config=s"      =>      \$config,
        "help"         =>    \$help,
);


if( (! defined $node && ! defined $config) || (! defined $user && ! defined $config) || (! defined $execute && ! defined $config)  || (! defined $execute && ! defined $config &&! defined $node && ! defined $user)  || $help) {
print <<usage;
\n     Usage : $0 [OPTIONS]
             user :      -u    Զ�����������û���,ע�ⲻ��ʹ��ngboss,eg:cxzzh
             node :      -n    Զ���������,eg:fsabm1
             execute :   -e    Զ��ִ������ű�,�ű���д����·�� eg:ls -lrt
             config :    -c    ��������Զ��ִ������Ӧ�����ļ�,�����ļ����ݸ�ʽ:����IP|�ű�������|�����û� \n
             
             ע���:���ڵ�Զ��ִ��������user|node|execute
                    ��ڵ�����Զ��ִ������configָ�����ļ�����������,��ʽΪ:����IP|�ű�������|�����û�
usage
       exit;
}

if(($user eq "ngboss") || (!($user=~/cx.../))){
        print "��ֹʹ��ngboss�ʺ�,��ʹ�ø����ʺ�ִ��\n";
        }
        
        $user = ! defined $user ? 'cxzzh' : $user;
        
if($config){
        if(-e $config){
        my @ssh_list;
        open FH,$config;
        while(<FH>)
                { 
                        chomp;      
                        @ssh_list=split/\|/,$_;
                        print "����ִ�нڵ�".$ssh_list[0]."ָ��".$ssh_list[1]."...\n";
                        system("ssh -l $ssh_list[2] $ssh_list[0] /usr/local/bin/sudo -u ngboss $ssh_list[1]");
                        #print "ssh -l $ssh_list[2] $ssh_list[0] /usr/local/bin/sudo -u ngboss $ssh_list[1]\n";
                        }
                        close    FH;
                      }
}
else{
                                print "����ִ�нڵ�".$node."ָ��".$execute."...\n";
                                system("ssh -l $user $host_hash{$node}[0] /usr/local/bin/sudo -u ngboss $execute");
}



