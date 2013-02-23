Name: 		rctc
Version: 	1.15
Release:	1%{?dist}
Summary:	Run rctc
BuildArch: 	noarch

Group:		ETN
License:	GPL
#URL:		http://upstream-url.org/path
Source0: 	rctc-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires:	sed
Requires:	cronic

%description
no description

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%config(noreplace) %attr(644,root,root) /etc/init.d/rctc-ALL
%config(noreplace) %attr(644,root,root) /etc/rctc.conf
%config(noreplace) %attr(644,root,root) /etc/logrotate.d/rctc-catalinaout
%config(noreplace) %attr(644,root,root) /etc/cron.d/rctc-catalinaout-logrotate
%config(noreplace) %attr(644,root,root) /etc/cron.d/rctc
/usr/bin/rctc
/usr/sbin/rctc
/usr/libexec/rctc/run.sh
/usr/lib/rctc/instance-template/rctc.tgz
/usr/sbin/gzip-all-tc-logs.sh
/usr/sbin/archive-all-tc-logs.sh
/usr/bin/rctc-run-conf-vs-template-diff.sh
%doc README.txt scripts CHANGELOG.txt UPGRADE.txt



%changelog

* Fri Dec 21 2012 <jahor@jhr.cz> 1.15-1
- updated jnptemplate with initialSize in jdbc definitions

* Fri Dec 07 2012 <jahor@jhr.cz> 1.15-0
- tc server.xml generator filename changed
- inform when thread-dump is disabled
- detecting missing instance dir during thread-dump before any dir usage
- psiprobe package changed location of instance template tarball
- do not reference tomcat version-specific instance template in instance-template dir
- instance dir should contain prepared war conf/app folders and default ROOT.xml symlink

* Tue Dec 04 2012 <jahor@jhr.cz> 1.14-0
- fix: swallow non-important output from subshells to not affect parsing

* Tue Dec 04 2012 <jahor@jhr.cz> 1.13-0
- possibility to toggle on/off for thread dump on stop/kill per instance
- java env for jstack set in instances run.conf not in global rctc.conf

* Wed Nov 07 2012 <jahor@jhr.cz> 1.12-0
- explicitne definovany rozsah uid a gid pri zakladani uzivatele

* Sun Nov 04 2012 <jahor@jhr.cz> 1.11-0
- possibilty to restart instance which is the user traversing with H token

* Thu Oct 11 2012 <jahor@jhr.cz> 1.10-0
- java 7 as a default
- configurable purging of webapps dir by setting CLEAN_WEBAPPS_DIR
- fix debug port to propagate corectly to catalina.sh
- important upgrade steps in UPGRADE.txt

* Wed Sep 28 2012 <jahor@jhr.cz> 1.9-0
- oprava pojmenovani threaddumpu aby zpracovavane archivaci logu
- oprava kontroly na run.conf pri nekterych operacich nad instancema
- oprava cd do instance pri kill akci

* Fri Aug 24 2012 <jahor@jhr.cz> 1.8-0
* Fri Aug 24 2012 <jahor@jhr.cz> 1.8-0
- oprava prace s Dtcid aby pri kontrole vyzdovalo na konci mezeru (resi kolizi jmen)
- by default thread-dump jen pri restartu
- fast-restart jako nahrada za force-restart ktery odstranen s force-stop

* Wed Aug 9 2012 <jahor@jhr.cz> 1.7-0
- oprava ukoncovani killem

* Wed Aug 8 2012 <jahor@jhr.cz> 1.6-0
- preusporadani parametru pro gc a jvm, defaultne zapnuti
- server.xml generovany i pri inicializaci pomoci rctc init, param CONTEXT_GENERATOR
- pouzivani jpda start pro remote debug, params REMOTE_DEBUG REMOTE_DEBUG_PORT
- nahrada JAVA_OPTS za CATALINA_OPTS
- uprava vypinani tc vs kill
- opet by default parametry pro jstack a rozsireno o dalsi
- run.sh presun mimo instanci, v instanci jen pro specialni pripady

* Wed Aug 8 2012 <jahor@jhr.cz> 1.5-0
- thread-dump signatura jmena aby pobral archivator

* Wed Aug 8 2012 <jahor@jhr.cz> 1.4-0
- jstack pod tc uzivatelem
- thred dump i pri explicitnim volani do logu a ne na vystup
- vypsani jako INFO do ktereho souboru thread-dump

* Wed Jun 18 2012 <jahor@jhr.cz> 1.3-0
- fix chkconfig poradi startovani

* Tue Jun 4 2012 <jahor@jhr.cz> 1.2-0
- odstraneni sample cfg log4j a server.xml

* Tue Jun 4 2012 <jahor@jhr.cz> 1.1-0
- konfigurovatelnost instancovacich sablon - INSTANCE_TEMPLATE_FILES
- rctc catalinaout logrotate i ukazkovy cron pro desetiminutove/hodinove
- fix chkconfig, zakladni chkconfig hlavicka, zatim ne lsb compliant
- fix killovani vs thread-dump - neprepisovani prom tcname
- fix doubleslash v definici INSTANCES_DIR
- fix posunuti casu prubehu cron tasku - 1:00 gzip, 2:00 archive
- pridan fragment pro relokaci truststore z javy
- oprava cest k jave a tomcatu, default tomcat7
- pridana funkce init-user

* Thu Apr 12 2012 <jahor@jhr.cz> 1.0-0
- logs/logs.ARCHIVE soucasti instance-dir sablony

* Wed Jan 18 2012 <jahor@jhr.cz> 0.9-0
- pripravene jmx parametry v run.conf pro monitoring apod
- pro tc5.5+ nutny presun Xmx a Xms do JAVA_OPTS
- pripravene parametry pro tuning jvm
- detekovani symlinkovanych instanci pro globalni ALL
- init skript start/stop/restart vsech instanci a ne jen prvni v seznamu
- konfigurovatelne THREAD_DUMP_JSTACK_PARAMS aby mozno volit podle verze jdk/jstack

* Tue Oct 25 2011 <jahor@jhr.cz> 0.8-1
- prava na cfg

* Tue Oct 11 2011 <jahor@jhr.cz> 0.8-0
- upstream update

* Fri Oct 07 2011 <jahor@jhr.cz> 0.7-0
- upstream update

* Fri Aug 05 2011 <jahor@jhr.cz> 0.6-1
- upstream update, fix "su -" aby i s cd

* Fri Jul 18 2011 <jahor@jhr.cz> 0.5-1
- repackaging

