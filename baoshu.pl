#!/usr/bin/perl
use strict;

my $count;                  ######ÿ��������Ա��λ�ñ���
my @all_match;              ######��������ƥ�����ı�����Ա��λ������
my %count_hash;             ######������������������������Ա������һ�±�����λ��HASH
my $last_reply;             ######��ʱ������һ�α���λ�ñ���
my $count_loop=1;           ######��������������������������
my $first_reply_continuous; ######��ʱ�����һ�±�����λ�ñ���


######����100000�Σ�ȡ��ƥ���������Ա��λ�ü�¼��������
for(my $count=1;$count<=100000;$count++)  
{
if ($count%7==0 || $count=~/^\w7.*/)
{
push @all_match,$count;
}
}

for(my $i=0;$i<@all_match;$i++)
{
	           #######ѭ����һ�μ�¼
                if($i==0)             
                {
                $last_reply=$all_match[0];
                $first_reply_continuous=$last_reply;
                chomp $last_reply;
                chomp $first_reply_continuous;
        }
        #######ѭ���ǵ�һ�μ�¼
    if($i!=0)                         
    {
    	    #######�����������������ʱ�������������ۼ�
        if($all_match[$i]-$last_reply==1)   
        {
                $count_loop+=1;
                $first_reply_continuous=$last_reply if $count_loop==2;
                }
           #######���������������������ʱ���Ѽ��������ս�����ص�HASHֵ�У��ѵ�һ�±�����λ�ü��ص�HASH��KEY�У�����ʼ���������͵�һ�±�����λ�ñ���
                else                       
                {
                        $count_hash{$first_reply_continuous}=$count_loop;
                        $count_loop=1;
                        $first_reply_continuous="";
                        }
                        #######�ѱ��α���λ�ü��ص���һ�α���λ�ñ���
                        $last_reply=$all_match[$i]; 
                        chomp $last_reply;
}
        }
        
        
sub by_hash{
$count_hash{$b}<=>$count_hash{$a}
}             

print "���������е�һ�±�����λ��|������������\n";
foreach my $key (sort by_hash keys %count_hash)
{
print "$key|$count_hash{$key}\n";
}