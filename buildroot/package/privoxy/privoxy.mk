################################################################################
#
# privoxy
#
################################################################################

PRIVOXY_VERSION = 3.0.24
PRIVOXY_SITE = http://downloads.sourceforge.net/project/ijbswa/Sources/$(PRIVOXY_VERSION)%20%28stable%29
PRIVOXY_SOURCE = privoxy-$(PRIVOXY_VERSION)-stable-src.tar.gz
# configure not shipped
PRIVOXY_AUTORECONF = YES
PRIVOXY_DEPENDENCIES = pcre zlib
PRIVOXY_LICENSE = GPLv2+
PRIVOXY_LICENSE_FILES = LICENSE

$(eval $(autotools-package))
