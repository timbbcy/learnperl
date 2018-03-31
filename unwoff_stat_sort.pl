####多列排序脚本
#!/usr/bin/perl
use strict;

if( @ARGV != 1){
                print "Usage: $0 tar_file\n";
                exit;
}

my $tar_file=$ARGV[0];       ####输入文件
my %hash;                    ####以号码为KEY的HASH 用于累加费用

open FH,"$tar_file" or die $!;
while(<FH>){
        my $row=$_;
        chomp $row;
        my @row=split /\|/,$row;

####累加统计欠费
if(/^1/){
        $hash{$row[0]}+=$row[3];
        }
      }

####排序规则表达式子过程
sub     by_hash{
        $hash{$b}<=>$hash{$a} or $a <=> $b
        }             

####按多列排序规则进行排序并输出结果
        my @sort_arr = sort by_hash keys %hash;
        foreach(@sort_arr){
        print "$_|$hash{$_}\n";
        }
