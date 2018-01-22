FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

# Add sources.
RUN \
  echo "deb http://ftp.de.debian.org/debian/ stretch main non-free contrib" > /etc/apt/sources.list && \
  echo "deb-src http://ftp.de.debian.org/debian/ stretch main non-free contrib" >> /etc/apt/sources.list && \
  echo "deb http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb-src http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
  apt-get -qq update && apt-get -qqy upgrade


# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d


# Install tools.
RUN \
    apt-get update && \
	apt-get install -y nano --no-install-recommends && \
	rm -rf /var/lib/apt/lists/*


# Install Apache.
RUN \
    apt-get update && \
	apt-get install -y --no-install-recommends \
	apache2 && \
	rm -rf /var/lib/apt/lists/*


# Configure Apache.
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod proxy_fcgi


# Set repository.
RUN apt-get update && \
	apt-get install -y apt-transport-https ca-certificates curl gnupg --no-install-recommends && \
	rm -rf /var/lib/apt/*
RUN curl https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo 'deb https://packages.sury.org/php/ stretch main' > /etc/apt/sources.list.d/deb.sury.org.list


# install PHP 7.1
RUN \
    apt-get update && \
	apt-get install -y --no-install-recommends \
	php7.1 \
	php7.1-cli \
	php7.1-fpm && \
	rm -rf /var/lib/apt/lists/*


# install PHP 5.6
RUN \
    apt-get update && \
	apt-get install -y --no-install-recommends \
	php5.6 \
	php5.6-cli \
	# php5.6-dev \
	php5.6-fpm && \
	# php5.6-mbstring \
	# php5.6-mcrypt \
	# php5.6-mysql \
	# php5.6-zip \
	# php5.6-gd \
	#php5.6-xml && \
	rm -rf /var/lib/apt/lists/*


# Verify versions.
RUN php7.1 -v
RUN php5.6 -v
RUN php -v

# You can switch the default version using update-alternatives, just run the following command and pick the version you prefer:
# $ update-alternatives --config php

RUN mkdir /var/www/php71
COPY index71.php /var/www/php71/index.php

RUN mkdir /var/www/php56
COPY index56.php /var/www/php56/index.php


# (Docker-specific) install supervisor so we can run everything together
RUN apt-get update && \
	apt-get install -y supervisor --no-install-recommends && \
	rm -rf /var/lib/apt/lists/*
COPY supervisor.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /run/php

EXPOSE 8871 8856
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]