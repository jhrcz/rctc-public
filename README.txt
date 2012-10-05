VYTVARENI NOVE INSTANCE
----------------------------------------------------------------------

pokud budeme chtit instalovat s parametry:
	id tomcatu: 	test
	uid uzivatele: 	9999

	=> jmeno uzivatele tctest
	=> tc instance v /srv/tc/test

* apt-get install rctc
  => nainistaluje celou jnpplatform (tedy i tomcat, javu a mysql)


* adduser --system --shell /bin/bash --uid 9999 tctest

* rctc init test
  => vytvori adresar pro instanci
  => nastavi prava

* uprava cfg instance tomcatu v /srv/tc/test/conf (pripravena minimalisticka template)
  mozno vygenerovat pomoci template generatoru:
  BASEPORT=15500 /usr/share/doc/rctc/server.xml--minimal.sh

* rctc status test
  => melo by vratit ze je down

* rctc start test

* rctc status test
  => nyni by jiz melo ukazat ze je up

* kontrola logu instance ze je vse OK


DALSI INFORMACE O STAVU
----------------------------------------------------------------------


* rctc list ALL
  => zjistime ktere jiz jsou nakonfigurovane

* rctc running
  => informace o procesech bezicich tomcatu

* ostatni parametry pomoci rctc help


ZOBRAZENI ROZDILU run.conf v instanci proti sablone
----------------------------------------------------------------------

[root@wp3-edit wp3edit]# ~/run-conf-diff-vs-template.sh 
--- /tmp/rctc-runconf-diff.i13364	2011-06-08 09:51:47.000000000 +0200
+++ run.conf	2010-05-18 13:46:52.000000000 +0200
@@ -10,7 +10,7 @@
 export CATALINA_HOME="/srv/tc/$(basename $(pwd))/platform/etnpol-tomcat-5.5.x"
 
 # basic tomcat behavior and memory allocation
-export CATALINA_OPTS="-Dfile.encoding2=Cp1250 -Xmx500m -Xms100m"
+export CATALINA_OPTS="-Dfile.encoding2=Cp1250"
...

LOKALNI UPRAVY run.sh
----------------------------------------------------------------------
do adresare instance lze nakopirovat run.sh (v libexec) ktery nasledne
zacne byt automaticky pouzivan. lze tak pokryt specialni specificke potreby

# EOF

