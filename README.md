DBNDNS/DJBDNS in a container
=====================

[DBNDNS](http://en.wikipedia.org/wiki/Dbndns) is a fork of [DJBDNS](http://en.wikipedia.org/wiki/Djbdns) maintained by the Debian Project. 

#### Why DJBDNS?
I love the [DJB's](http://en.wikipedia.org/wiki/Daniel_J._Bernstein) concise format of [TinyDNS records](http://cr.yp.to/djbdns/tinydns-data.html) and after using it for over 8 years, I cannot stand BIND's overly verbose and clunky scheme, requiring separate zone files for reverse lookups.

Instead of having two separate zone files, which are more dificult to keep track of, imo: 

    # forward zone file
    $ORIGIN example.com.
    $TTL 3600
    @         SOA ns.example.com.   noc.example.com. (
                      1421690779 ; serial
                      28800      ; refresh
                      3600       ; retry
                      604800     ; expire
                      300   )    ; negative TTL
          IN  NS      ns.example.com.
          IN  MX 10   mail.example.com.
          IN  A       10.0.0.10
    ns    IN  A       10.0.0.1
    www   IN  CNAME   example.com.
    mail  IN  A       10.0.0.11

    # reverse zone file
    $TTL 3600
    0.0.10.in-addr.arpa. IN SOA ns.example.com. noc.example.com. (
                            1421690779      ; serial
                            10800           ; refresh
                            3600            ; retry
                            604800          ; expire
                            300 )           ; negative TTL
            IN      NS      ns.example.com.
    10      IN      PTR     example.com.
    11      IN      PTR     mail.example.com.

a single, more concise zone file containing both forward and reverse zone is simple enough to view, edit, parse, generate or diff..

    Zexample.com:ns.example.com:noc.example.com.::28800:3600:604800:3600:3600
    Z0.0.10.in-addr.arpa:ns.example.com:noc.example.com.::28800:3600:604800:3600:3600
    &example.com::ns.example.com.:3600
    &0.0.10.in-addr.arpa::ns.example.com.:3600
    +ns.example.com:10.0.0.1:3600
    @example.com::mail.example.com.:10:3600
    =example.com:10.0.0.10:3600
    Cwww.example.com:example.com.:3600
    =mail.example.com:10.0.0.11:3600

PTR records a automatically created for any host by using `=` sign - isn't that a beauty?

There are plenty of BIND-format generators for any language, making parsing or generating BIND formated zone file not as tedious as I'm making it out to be. But my personal preference is given to TinyDNS style data. YMMW.