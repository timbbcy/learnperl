#!/usr/bin/perl
use strict;

my $count;                  ######每个报数人员的位置标量
my @all_match;              ######保存所有匹配规则的报数人员的位置数组
my %count_hash;             ######保存连续听到报数几声的人员数及第一下报数者位置HASH
my $last_reply;             ######临时保存上一次报数位置标量
my $count_loop=1;           ######保存连续报数次数计数器标量
my $first_reply_continuous; ######临时保存第一下报数者位置标量


######遍历100000次，取出匹配规则报数人员的位置记录保存数组
for(my $count=1;$count<=100000;$count++)  
{
if ($count%7==0 || $count=~/^\w7.*/)
{
push @all_match,$count;
}
}

for(my $i=0;$i<@all_match;$i++)
{
	           #######循环第一次记录
                if($i==0)             
                {
                $last_reply=$all_match[0];
                $first_reply_continuous=$last_reply;
                chomp $last_reply;
                chomp $first_reply_continuous;
        }
        #######循环非第一次记录
    if($i!=0)                         
    {
    	    #######当出现连续报数情况时，计数器进行累加
        if($all_match[$i]-$last_reply==1)   
        {
                $count_loop+=1;
                $first_reply_continuous=$last_reply if $count_loop==2;
                }
           #######当本次连续报数情况结束时，把计数器最终结果加载到HASH值中，把第一下报数者位置加载到HASH得KEY中，并初始化计数器和第一下报数者位置标量
                else                       
                {
                        $count_hash{$first_reply_continuous}=$count_loop;
                        $count_loop=1;
                        $first_reply_continuous="";
                        }
                        #######把本次报数位置加载到上一次报数位置标量
                        $last_reply=$all_match[$i]; 
                        chomp $last_reply;
}
        }
        
        
sub by_hash{
$count_hash{$b}<=>$count_hash{$a}
}             

print "连续报数中第一下报数者位置|连续报数次数\n";
foreach my $key (sort by_hash keys %count_hash)
{
print "$key|$count_hash{$key}\n";
}