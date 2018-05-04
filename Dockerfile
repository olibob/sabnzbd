FROM alpine:3.7

ARG SABv=2.3.3
ARG PAR2v=0.8.0

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm'

# Create user and group for SABnzbd.
RUN addgroup -S -g 1000 sabnzbd \
    && adduser -S -u 1000 -G sabnzbd -h /sabnzbd -s /bin/sh sabnzbd 

RUN apk -U upgrade \
    && apk -U add --no-cache ca-certificates py-pip git python make gcc g++ \
    python-dev openssl-dev libffi-dev unzip unrar p7zip \
    && pip --no-cache-dir install --upgrade setuptools \
    && pip --no-cache-dir install cheetah \
    && pip --no-cache-dir install cryptography \
    && pip --no-cache-dir install sabyenc

RUN apk add --no-cache build-base automake autoconf python-dev \
    && wget -O- https://github.com/Parchive/par2cmdline/archive/v${PAR2v}.tar.gz | tar -zx \
    && cd par2cmdline-${PAR2v} \
    && aclocal \
    && automake --add-missing \
    && autoconf \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf par2cmdline-${PAR2v} \
    && pip --no-cache-dir install --upgrade sabyenc \
    && apk del build-base automake autoconf python-dev

RUN wget -O- https://github.com/sabnzbd/sabnzbd/releases/download/${SABv}/SABnzbd-${SABv}-src.tar.gz | tar -xz \
    && mv SABnzbd-*/* sabnzbd \
    && mkdir -p datadir \
    && touch datadir/sabnzbd.ini \
    && chown -R sabnzbd: sabnzbd datadir
    
EXPOSE 8080

# Start SABnzbd.
WORKDIR /sabnzbd
ADD start.sh /sabnzbd/start.sh
CMD ["./start.sh"]
