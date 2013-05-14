# ProMan

The proxy manager. Manage multiple proxies and for which hosts they
are enabled through a PAC file.

## Run it

    foreman start

Navigate to [localhost:3554](http://localhost:3554).

## Bookmarklet

Use this bookmarklet to have a handy way of bringing up the ProMan configuration.

    javascript:(function(){window.open('http://localhost:3554', 'proman', 'status=no,directories=no,location=no,resizable=no,menubar=no,width=400,height=1000,toolbar=no');})()
