FROM centos:6.9

LABEL maintainer "ewill.leung@outlook.com"

ENV NGINX_VERSION 1.12.0
ENV NGINX_CONFIG \
	--prefix=/home/nginx \
	--sbin-path=/home/nginx/sbin/nginx \
	--conf-path=/home/nginx/conf/nginx.conf \
	--error-log-path=/home/nginx/logs/error.log \
	--http-log-path=/home/nginx/logs/access.log \
	--pid-path=/var/run/nginx/nginx.pid \
	--lock-path=/var/run/nginx/nginx.lock \
	--user=nginx \
	--group=nginx \
	--with-pcre \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_stub_status_module \
	--with-threads \
	--with-stream \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module \
	--with-stream_realip_module \
	--with-compat \
	--with-file-aio \
	--with-http_v2_module

RUN	yum install -y \
		openssh-server.x86_64 \
		openssl-devel.x86_64 \
		pcre-devel.x86_64 \
		zlib-devel.x86_64 \
		zlib.x86_64 \
		curl.x86_64 \
		crontabs.noarch \
		gcc.x86_64 \
		autoconf.noarch \
		automake.noarch \
		&& groupadd nginx \
		&& useradd -s /sbin/nologin -g nginx nginx \
		&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
		&& mkdir -p /usr/src \
		&& tar -zxvf nginx.tar.gz -C /usr/src \
		&& rm nginx.tar.gz \
		&& cd /usr/src/nginx-$NGINX_VERSION \
		&& ./configure $NGINX_CONFIG \
		&& make -j$(getconf _NPROCESSORS_ONLN) \
		&& make install \
		&& rm -rf /usr/src/nginx-$NGINX_VERSION \
		&& mkdir /home/nginx/conf.d/ \
		&& mkdir /home/nginx/scripts/ \
		&& ln -s /home/nginx/sbin/nginx /usr/sbin/nginx

COPY nginx_split_log.sh /home/nginx/scripts/nginx_split_log.sh
COPY nginx_crontab.conf /home/nginx/scripts/nginx_crontab.conf
COPY nginx.conf /home/nginx/conf/nginx.conf
COPY nginx.vh.default.conf /home/nginx/conf.d/default.conf

RUN	service sshd start \
		&& chown -R nginx:nginx /home/nginx \
		&& chmod +x /home/nginx/scripts/nginx_split_log.sh \
		&& crontab < /home/nginx/scripts/nginx_crontab.conf

EXPOSE 22 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
