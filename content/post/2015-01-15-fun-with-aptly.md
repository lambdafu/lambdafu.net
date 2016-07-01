---
title: Fun with aptly
author: Marcus
layout: post
date: 2015-01-15T09:33:37+00:00
url: /2015/01/15/fun-with-aptly/
categories:
  - DevOps

---
[aptly][1] (by Andrey Smirnov) seems to be a swiss army knife for Debian/Ubuntu repositories. You can create (partial) mirrors, snapshot them, merge snapshots and push them to an apt-get'able repository. You can also upload packages to a local repository and snapshot and/or publish that, too. Andrey is rocking the Debian world with this, thanks a lot!

To illustrate the work-flows that this tool enables, here is an example that extracts firebird 2.5.1 and its dependencies from Ubuntu precise (12.04) and injects it into a published repository for trusty (14.04) installations (which have only firebird 2.5.2).

```
# aptly mirror create -filter=firebird2.5-superclassic -filter-with-deps -architectures=amd64 ubuntu-precise-firebird http://archive.ubuntu.com/ubuntu/ precise universe
# aptly mirror update ubuntu-precise-firebird
# aptly snapshot create firebird from mirror ubuntu-precise-firebird

# aptly mirror create -filter=libicu48 -architectures=amd64 ubuntu-precise-libicu48 http://archive.ubuntu.com/ubuntu/ precise main
# aptly mirror update ubuntu-precise-libicu48
# aptly snapshot create libicu48 from mirror ubuntu-precise-libicu48

# aptly snapshot merge firebird2.5.1 firebird libicu48
# aptly publish snapshot -distribution trusty -component firebird firebird2.5.1
```

Now you can use this repository (assuming the files are available on localhost:80) with

```
# echo "deb http://localhost:80/ trusty firebird" >> /etc/apt/sources.list
# apt-get install firebird2.5-superclassic=2.5.1.26351.ds4-2build1 firebird2.5-common=2.5.1.26351.ds4-2build1 firebird2.5-server-common=2.5.1.26351.ds4-2build1 firebird2.5-classic-common=2.5.1.26351.ds4-2build1 firebird2.5-common-doc=2.5.1.26351.ds4-2build1 libfbembed2.5=2.5.1.26351.ds4-2build1 libib-util=2.5.1.26351.ds4-2build1 libfbclient2=2.5.1.26351.ds4-2build1
```

I am not sure why apt needs so much hand-holding, maybe there is an easier way.

This is super-easy to figure out, thanks to the excellent online help and superb diagnostic output. <s>I'd suggest that Andrey</s> [This repository][2] adds bash tab completion to the commands for easier typing, as there are a lot of options and you might have many mirrors, snapshots and repositories.

If you have anything to do with maintaining a larger set of Debian/Ubuntu installations, check it out!

By the way, here is a condensed docker file that may be useful (aptly.conf is just the default config file in my case):

```
FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes
# Based on https://registry.hub.docker.com/u/mikepurvis/aptly/
RUN echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list; \
apt-key adv --keyserver keys.gnupg.net --recv-keys 2A194991; \
apt-get update; \
apt-get install aptly -y
COPY aptly.conf /etc/aptly.conf
# Will contain db, pool and public directories.
VOLUME ["/aptly"]
# Install a basic SSH server
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd
# There is no sane way to insert an authorized_keys file by volumes
# due to permission mismatch (ssh requires 0600 root, which docker
# can't read), so for now just add the file in the build.
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 0700 /root/.ssh
RUN chmod 0600 /root/.ssh/authorized_keys
# Tab completion is useful.
RUN wget https://github.com/aptly-dev/aptly-bash-completion/raw/master/aptly -O /etc/bash_completion.d/aptly
RUN apt-get update && apt-get install -y bash-completion
RUN echo ". /etc/bash_completion" >> /root/.bashrc
# Default signing key for aptly (used automatically).
COPY gnupg-private.txt /root/gnupg-private.txt
RUN gpg --import /root/gnupg-private.txt
# Standard SSH port
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

 [1]: http://www.aptly.info/
 [2]: https://github.com/aptly-dev/aptly-bash-completion