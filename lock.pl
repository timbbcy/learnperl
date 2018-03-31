#!/usr/bin/perl

use strict;

my ($src_file,$fix_key)=@ARGV;


if( @ARGV != 2){

   print "Usage: $0 src_file fix_key\n";

    exit;

}

my $my_path="/usr1/monk/bin/";
chomp $my_path;
my $src_all=$my_path.$src_file;
print "$src_all\n";
my $src_lock_file="./".$src_file.".lock";
print "$src_lock_file\n";


        if(-e $src_all)
        {
        open FH,"$src_all" or "can't open $src_all!\n";
        open FO,">$src_lock_file" or die "$!";
        while(<FH>)
        { 
                my $row=$_;
                my $len=length($row);
                #print "$len\n";
                foreach(my $i=0;$i<$len;$i++){
                        my @str;
                        my @aft_str;
                        $str[$i]=substr($row,$i,1);
                        $aft_str[$i]=(ord $str[$i])*$fix_key;
                        print FO "$aft_str[$i]#";
                        
                }
        }

                        close FH;
                        
                       }
                       close FO;