#!/usr/bin/perl -w
use LWP;

undef @context2;

open(PROXY_SOURCE,"proxy_source.txt");
@proxylist=<PROXY_SOURCE>;
chomp(@proxylist);
close(PROXY_SOURCE);

print("Do you want to retain the original record (Y/other is No) ? ");
$answer1=<STDIN>;
if(lc(chop($answer1)) ne 'y'){
open(PROXYLIST_FIRST,">proxylist.txt");
print PROXYLIST_FIRST "\n";
close(PROXYLIST_FIRST);
}

foreach $proxy_source_single (@proxylist){
	$agent=LWP::UserAgent->new();
	$agent->timeout(15);
	print("Now update PROXYLIST from \'$proxy_source_single\' .\n");
	$request=HTTP::Request->new(GET,$proxy_source_single);
	$response=$agent->request($request);
	if($response->is_success){
		open(PROXYLIST,">>proxylist.txt");
		print PROXYLIST "\n".$response->content;
		close(PROXYLIST);
	}else{
		print "$proxy_source_single:",$response->message,"\n";
	}
}


open(PROXY_CORRECT,"proxylist.txt");
@context1=<PROXY_CORRECT>;
chomp(@context1);
close(PROXY_CORRECT);


foreach $single_record (@context1){
	if($single_record eq ""){
		;
	}else{
		#print "ok!\n";
		$single_record=~s"^\s"";
		$single_record=~s"\s$"";
		push(@context2,"$single_record"."\n");
	}
}

$last=pop(@context2);
chop($last);
push(@context2,$last);

open(PROXY_CORRECT2,">proxylist.txt");
print PROXY_CORRECT2 @context2;
close(PROXY_CORRECT2);
