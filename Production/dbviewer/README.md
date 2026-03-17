Running the dbviewer
====================

Get `OMEGACEN_CREDENTIALS` from https://metis.strw.leidenuniv.nl/wiki/doku.php?id=ait:archive.

Also get ssh instructions  from https://metis.strw.leidenuniv.nl/wiki/doku.php?id=ait:archive.

Ssh into dbviewer server with dbviewer account.

```
export OMEGACEN_CREDENTIALS=username:password
```

Build the image
---------------
```
podman build --secret=id=OMEGACEN_CREDENTIALS,type=env -t metis_dbviewer .
```

Deploy image
------------
TODO.  Currently the image needs to be build on the machine itself.



Run image
---------

Ensure linger is set if a systemd server is used.

```
nohup podman run -it --network=host --replace --name metis_dbviewer metis_dbviewer &
```

A private key and certificate are required to use SSL, a self-signed
certificate is created automatically.

Debug dbviewer
--------------

You can enter the running container with something like
```
podman exec -ti metis_dbviewer tmux
```


