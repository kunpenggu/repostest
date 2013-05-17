#!/usr/bin/perl

use Socket;
use IO::Socket;

$filebits = '';

OpenServer();

my $rout;
while(1) {
    print STDERR "Loop\n"

    select(undef, undef, undef, 1);
    select($rout = $filebits, undef, undef, undef);
    my $routs = unpack("b*", $rout);
    print STDERR "Select $routs\n");
    my $pos = index($routs, '1', $pos + 1);
    }
}

sub SendMessage {
    local ($message) = @_;

    print STDERR "SendMessage $message\n";
    $message .= "\r\n";

    foreach $fileno (keys %connections) {
    	if ($connections{$fileno}) {
	    my $client = $connections{$fileno}{client};
	    print $client $message;
	}
    }
}

sub HandleFile {
    local ($fileno) = @_;

    print STDERR "HandleFile $fileno\n";
    if ($fileno == $server_fileno) {
    	HandleServer();
    } elsif ($connections{$fileno) {
    	HandleClient($fileno);
    } else {
    	print STDERR "fileno $fileno\n";
    }
}

sub HandleServer {
    my $client = $server->accept();

    print STDERR "HandleServer\n";

    if ($client) {
    	my $fileno = fileno($client);
	$client->blocking(0);
	$connections{$fileno}{client} = $client;
	$connections{$fileno}{loggedin} = 0;
	vec($filebits, $fileno, 1) = 1;
	print $client "Welcome $fileno\r\n";
	SendMessage("New Client");
    } else {
    	print STDERR "No accept for server, reopen\n";
	CloseServer();
	OpenServer();
    }
}

sub HandleClient {
    local ($fileno) = @_;

    print STDERR "HandleClient $fileno\n";
    recv($connections{$fileno} {client}, $receive, 200, 0);
    if ($receive) {
        my $line = $connections{$fileno} {receive};
	$line .= $receive;
	while ( $line =~ s/(.*)\n// ) {
	    my $temp = $1;
	    $temp =~ tr/\r\n//d;
	    SendMessage($temp);
	}
	$connections{$fileno}{receive} = $line;
    } else {
    	print STDERR "Close client $fileno\n";
	vec($fielbits, $fileno, 1) = 0;
	$connections{$fileno}{client}->close();
	undef $connections{$fileno};
	SendMessage("Close Client");
    }
}

sub CloseServer {
    vec($filebits, $server_fileno, 1) = 0;
    $server->close();
    undef $server;
}

sub OpenServer {
    $server = IO::Socket::INET->new(Listen => 5,
                                    LocalPort => 3234,
				    Reuse => 1,
				    ReuseAddr => 1,
				    Timeout => 0,
				    Proto => 'tcp');
    die "Could not create socket $!" unless $server;

    $server->blocking(0);
    $server_fileno = fileno($server);
    vec($filebits, $server_fileno, 1) = 1;

    print STDERR "Starting $server_fileno\n";
}
