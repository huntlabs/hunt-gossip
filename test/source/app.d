import std.stdio;

import test.TestGossipService;
import std.getopt;
import std.algorithm.searching;
import std.array;

int main(string[] args)
{
	writeln("Edit source/app.d to start your project.");
	int listenPort ;
	if(!initConfig(args,listenPort))
		return -1;

	TestGossipService.startGossip(listenPort);
	return 0;
}

bool initConfig(string[] args, out int listenPort)
{
	auto opt = getopt(args,"port|p","set listen port",&listenPort);

	if (opt.helpWanted){
		defaultGetoptPrinter("Test Gossip service",
			opt.options);
		return false;
	}

	if (find([6000,6001,6002,6003],listenPort).empty)
	{
		writeln("the port must be one of them : [6000,6001,6002,6003]");
		return false;
	}
	else
		return true;
	
}