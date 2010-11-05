SITE_HTML = \
  faq.html	\
  getting-started.html	\
  index.html	\
  manual.html	\
  overview.html	\
  setup-hbase.html	\


all: $(SITE_HTML)

%.html: %.content
	sed '/^<!--.*-->$$/d' $< | cat header - footer >$@-t
	title=`sed -n 's/<!--title: *\([^>]*\) *-->/\1 - /p' $<` && \
	  sed "s/<title>/&$$title/" $@-t >$@
	rm -f $@-t

$(SITE_HTML): header footer

clean:
	rm -f $(SITE_HTML:.html=.html-t)

distclean: clean
	rm -f $(SITE_HTML)

.PHONY: all clean distclean
