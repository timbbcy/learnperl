#!/usr/bin/perl
use strict;
if( @ARGV != 1){
                print "Usage: $0 tar_file\n";
                exit;
}
                my $tar_file=$ARGV[0];
sub load_hash()
{
                my %hash;      ####��������ΪKEY��HASH ���ڴ������������
                my $mark=1;    ####��ǰ��
                my @domain;    ####��������������
                my @item;      ####��������������
                open FH,"$tar_file" or die $!;
while(<FH>){
        my $row=$_;
        chomp $row;
        ####��һ��ƥ��������ʱ ���domain���� suffix����Ϊ�����±�
        if($row=~/\[(.+)\]/ && $mark==1)
                { my $suffix=$mark-1;
                        $domain[$suffix]=$1;
            $mark++;                    
                        }
        ####ƥ��������ʱ ���item����
        if($row!~/\[.+\]/)
                {
                        push @item,$row;                
                        }
        ####�ǵ�һ��ƥ��������ʱ ����һ��ƥ�䵽��������������� д����һ���������Ӧ��HASH
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
####���һ���д����߼�
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