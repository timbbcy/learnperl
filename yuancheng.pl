#!/usr/bin/perl 
use strict; 
use lib "/cbsapp1/_tmp/ych/tool/perl_lib/lib64/site_perl";
use Net::SSH::Expect;
use Net::SSH::Expect; 
my @ssh_list; 
my $1ssh_txt='ip_list.txt'; 
my $command_txt='command_txt'; 
open FH,$ssh_txt; 
while(<FH>)
	{ @ssh_list=split; 
		print "正在登陆".$ssh_list[0]."...\n"; 
		&ssh_conn("$ssh_list[0]","$ssh_list[1]","$ssh_list[2]","$ssh_list[3]"); 
		} 
close FH; 
			
sub    ssh_conn()
{ 
my($host,$port,$user,$pass) = @_; 
my $ssh = Net::SSH::Expect->new( host => $host, port => $port, user => $user, password => $pass, no_terminal => 0, raw_pty =>1, timeout => 3, ); 
$ssh->debug(0); 
$ssh->run_ssh() or die "SSH process coundn't start:$!"; 
$ssh->waitfor( '\(yes\/no\)\?$', 1 ); 
#交互式修改密码，给予2秒的时间 
$ssh->send("yes\n"); 
$ssh->waitfor( 'password:\s*$/', 1); $
ssh->send("$ssh_list[3]"); 
#$ssh->send("/usr/local/bin/sudo -u ngboss -s"); 
#$ssh->waitfor( 'password:\s*$/', 1); 
#$ssh->send("$ssh_list[4]"); 
#$ssh->waitfor("#\s*",2); 

open F1,$command_txt; 
while(<F1>)
	{ 
		my @command=split/\n/,$_; 
		print "$command[0]-->    "; 
		$ssh->exec("$command[0]"); 
		print "$ssh_list[0]命令执行完毕\n"; 
		} 
close F1; 
$ssh->close(); 
		
"""						
下面是2个文件内容。 
[root@nagios script]# cat ip_list.txt 
192.168.2.101    22    mcshell psswd    server1 
192.168.2.101    22    mcshell psswd    server1 
192.168.2.102    22    mcshell psswd    server2 
192.168.2.103    22    mcshell psswd    server3 

[root@nagios script]# cat command_txt.txt 
touch /home/mcshell/file1 
touch /home/mcshell/file2 
"""
						
						   
               
               
               
               
               
               
               
               
               
               
               
               
               
               
            
            
            
            
            
            
            
 
            
            
            
            
            
            