####��������ű�
#!/usr/bin/perl
use strict;

if( @ARGV != 1){
                print "Usage: $0 tar_file\n";
                exit;
}

my $tar_file=$ARGV[0];       ####�����ļ�
my %hash;                    ####�Ժ���ΪKEY��HASH �����ۼӷ���

open FH,"$tar_file" or die $!;
while(<FH>){
        my $row=$_;
        chomp $row;
        my @row=split /\|/,$row;

####�ۼ�ͳ��Ƿ��
if(/^1/){
        $hash{$row[0]}+=$row[3];
        }
      }

####���������ʽ�ӹ���
sub     by_hash{
        $hash{$b}<=>$hash{$a} or $a <=> $b
        }             

####��������������������������
        my @sort_arr = sort by_hash keys %hash;
        foreach(@sort_arr){
        print "$_|$hash{$_}\n";
        }
