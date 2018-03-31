#!/usr/bin/perl
use strict;
if( @ARGV != 1){
                print "Usage: $0 tar_file\n";
                exit;
}
                my $tar_file=$ARGV[0];
sub load_hash()
{
                my %hash;      ####以配置域为KEY的HASH 用于存放域下配置项
                my $mark=1;    ####当前行
                my @domain;    ####存放配置域的数组
                my @item;      ####存放配置项的数组
                open FH,"$tar_file" or die $!;
while(<FH>){
        my $row=$_;
        chomp $row;
        ####第一次匹配配置域时 存进domain数组 suffix标量为数组下标
        if($row=~/\[(.+)\]/ && $mark==1)
                { my $suffix=$mark-1;
                        $domain[$suffix]=$1;
            $mark++;                    
                        }
        ####匹配配置项时 存进item数组
        if($row!~/\[.+\]/)
                {
                        push @item,$row;                
                        }
        ####非第一行匹配配置域时 对上一组匹配到的配置项进行排序 写入上一个配置域对应的HASH
        if($row=~/\[(.+)\]/ && $mark>1)
                {
                        my $suffix=$mark-1;
                        my $suffix_last=$mark-2;
                        $domain[$suffix]=$1;
                        my @item_sort=sort(@item);
                        $hash{$domain[$suffix_last]}= [@item_sort];
                        @item=();
                        $mark++;
                        }
}
####最后一个行处理逻辑
my $suffix=$mark-2;
my @item_sort=sort(@item);
$hash{$domain[$suffix]}= [@item_sort];
close FH;
foreach my $key (sort keys %hash)
{
        print "[$key]\n";
        for(@{$hash{$key}})
                {
                        print "$_\n";
                        }
}
}
sub main()
{
&load_hash;
}
&main;