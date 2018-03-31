#!/usr/bin/perl

use strict;

my ($src_file,$fix_key)=@ARGV;


if( @ARGV != 2){

   print "Usage: $0 src_file fix_key\n";

    exit;

}

#my $my_path="/usr1/monk/bin/";
my $my_path="./";
chomp $my_path;
my $src_all=$my_path.$src_file;
print "$src_all\n";
my $src_unlock_file="./".$src_file.".unlock";
print "$src_unlock_file\n";


        if(-e $src_all)
        {
        open FH,"$src_all" or "can't open $src_all!\n";
        open FO,">$src_unlock_file" or die "$!";
        while(<FH>)
        { 
        	my $row=$_;
          my @arr=split /#/,$row;
        	foreach my $num(@arr){
        		chomp $num;
        		#print "$num\n";
            my $aft_str=chr($num/$fix_key);
        		print FO "$aft_str";
        		
        	}
        }

        	        close FH;
        	        
        	       }
        	       close FO;
        	       
        	       system("perl $src_unlock_file");
        	       system("rm -f $src_unlock_file");


