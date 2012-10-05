SPECVERSION=$(shell awk -F: '/^Version:/{print $$2}' < rctc.spec | awk '{print $$1}' )

test-destdir: step-test-destdir
step-test-destdir:
	#test -d "$(DESTDIR)"
	test -n "$(DESTDIR)"
	touch step-test-destdir

install-bin: step-install-bin
step-install-bin: test-destdir rctc.conf rctc.sh run.conf run.sh
	install -m 644 -D rctc.conf $(DESTDIR)/etc/rctc.conf
	
	# controller script+initscript
	install -D rctc.sh $(DESTDIR)/usr/sbin/rctc
	install -d $(DESTDIR)/etc/init.d/
	(cd $(DESTDIR)/etc/init.d && ln -sf /usr/sbin/rctc rctc-ALL)
	
	mkdir -p tmp-instance-dir/conf

	# logrotate script
	install -D rctc-catalinaout.logrotate $(DESTDIR)/etc/logrotate.d/rctc-catalinaout
	install -D rctc-catalinaout-logrotate.cron $(DESTDIR)/etc/cron.d/rctc-catalinaout-logrotate
	
	# instance script with config
	install -D run.conf 		tmp-instance-dir/run.conf

	# executable
	install -D run.sh $(DESTDIR)/usr/libexec/rctc/run.sh
	
	mkdir -p tmp-instance-dir/logs/logs.ARCHIVE
	
	cd tmp-instance-dir && tar czf ../tmp-instance-dir.tgz . && cd .. && rm -rf tmp-instance-dir
	
	install -D tmp-instance-dir.tgz $(DESTDIR)/usr/lib/rctc/instance-template/rctc.tgz
	cd $(DESTDIR)/usr/lib/rctc/instance-template && ln -sf  /usr/lib/etnpol-tomcat-5.5.23/instance/core.tgz tomcat-core.tgz

	# cron tasks
	install -D rctc.cron $(DESTDIR)/etc/cron.d/rctc
	install -D gzip-all-tc-logs.sh $(DESTDIR)/usr/sbin/gzip-all-tc-logs.sh
	install -D archive-all-tc-logs.sh $(DESTDIR)/usr/sbin/archive-all-tc-logs.sh
	
	# extras
	install -D rctc-run-conf-vs-template-diff.sh $(DESTDIR)/usr/bin/rctc-run-conf-vs-template-diff.sh
	
	touch step-install-bin

install: install-bin

clean:
	rm step-* || true
	rm rctc-*.tar.gz || true
	rm -rf DESTDIR/
	rm -rf tmp-instance-dir/
	rm -f tmp-instance-dir.tgz

dist:
	git archive --format=tar --prefix="rctc-$(SPECVERSION)/" -o rctc-$(SPECVERSION).tar HEAD
	rm rctc-$(SPECVERSION).tar.gz || true
	gzip rctc-$(SPECVERSION).tar

rpm: dist
	cp rctc-$(SPECVERSION).tar.gz ~/rpmbuild/SOURCES/
	rpmbuild -bb --clean rctc.spec

deb:
	fakeroot dpkg-buildpackage -us -uc

