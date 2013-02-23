
# rctc is apache tomcat multi-instance manager

rctc provdes unified way for managing multiple tomcat instances
(with per-instance independent jvm) on one system. this brings
possibility to have different setups for each jvm and do not affect jvms
when restart or application update is required.

## STRUCTURE ON FILESYSTEM

```
/etc/rctc.conf
/srv/tc
      \ 
       *-- {instancedir}
       |              \
       |               *-- run.conf
       |               *-- (run.sh)
       |               |   only if specific changes required)
       |               ...
       |               *-- other tomcat instance dirs
       |                   (conf, tempdir, workdir, logs)
       *...
```

## CREATING NEW INSTANCE

```
rctc init {insancename}
```

there are some rules applied to user and configuration when instance
is created :

  * new user is created with uid and gid based on settings in rctc.conf

  * every instance has its own user, username is tc{instancename}

  * all ports for instance are based on BASEPORT env variable
  
  * server.xml is created from template depending on rctc.conf setup
    ( content of the file depends on the tomcat version )

  * permissions to all files are set to be writable by the created user

## AUTOMATIC TASKS

rctc brings automatic management of log files which use common naming
pattern. logs are rotated, gzip-ed and then archived do archive folder

## HELP

```
Usage:  $0 <cmd> <tclist>"

  cmd "
     * start              no-comment
     * stop               no-comment
     * restart            no-comment

     * fast-restart       no-comment
     * kill               no-comment

     * status             print instance status
     * logtail            log all logs/\*.log logs
     * running            list running instances
     * thread-dump        prints thread dump with jstack 

     * init               initialize new instance
     * init-user          initialize user account for new instance

   where tclist could be
     * <tcname> ... tomcat intsance name
     * ALL ... expanded to all available instances
     * H ... expanded to instance you are traversing now
```

## ADDITINAL INFO

thread dumps could be configured to not be made in some cases

instance init is preconfigured to use instance template for inhouse used
version of tomcat. similar template could be provided based on used
tomcat version and source (upstream binary vs distribution package)

## USAGE EXAMPLES

* start instance
```
rctc start {instancename}
```

* restart instance
```
rctc restart {instancename}
```

* lists all configured instances present in instances dir
```
rctc list
```

* more information with
```
rctc help
```

## INSTANCE SPECIFIC run.conf

(required, created on instance init)

this file contains all preferences for instance like java and tomcat
versions, java env options like Xmx and Xms etc


# showing difference of run.conf and the template

``` 
cd /srv/tc/{instancename} && run-conf-diff-vs-template.sh
```

```
--- /tmp/rctc-runconf-diff.i13364	2011-06-08 09:51:47.000000000 +0200
+++ run.conf	2010-05-18 13:46:52.000000000 +0200
@@ -10,7 +10,7 @@
 export CATALINA_HOME="/srv/tc/$(basename $(pwd))/platform/etnpol-tomcat-5.5.x"
 
 # basic tomcat behavior and memory allocation
-export CATALINA_OPTS="-Dfile.encoding2=Cp1250 -Xmx500m -Xms100m"
+export CATALINA_OPTS="-Dfile.encoding2=Cp1250"
...
```

this command keeps the temporary file in tmp to allow easy merging
for example with vimdiff

## INSTANCE SPECIFIC run.sh

(not required)

in some cases, there is required to have specific run.sh for starting
tomcat instance. in this case, rctc detects presence of run.sh in the
instance dir and uses it for starting the instance

generic run.sh is placed in libexec and used when no instance-specific
is present 

# EOF

