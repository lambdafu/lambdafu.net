---
title: Docker trouble
author: Marcus
layout: post
date: 2015-02-25T14:14:26+00:00
url: /2015/02/25/docker-trouble/
categories:
  - Uncategorized

---
[Docker][1] containers are great, and the Dockerfile build process is quite good, but there are pitfalls for newbies who come to Docker with a virtualization mindset. Docker containers are not light-weight VMs, because the abstraction happens at a much higher level. Docker is platform-as-a-service, not system-as-a-service. Here is a short list of issues I encountered migrating a couple of services from bare metal to Docker containers:

  * [Lack of kernel independence][2] with SE Linux
  * Lack of docker internals independence in the [mount table][3].
  * Docker containers have no login session, so there is no TZ, TERM, LC_ALL setting, and changing the system settings in /etc has no effect &#8211; this will surprise some users.
  * The UIDs of the container and the host system are shared (this will probably be fixed with UID/GID mapping soon), encouraging users to run all containers as root just to make images shareable. A security failure in the container isolation leads to privilege escalation.
  * The hostname is randomly generated on each container start (breaking for example carbon-daemon metric logging, which includes the hostname), requiring application patching to set fix imaginary hostnames for reproducible results.
  * Lack of resource isolation, for example with regards to I/O performance. A container utilizing I/O resources heavily can stall a filesystem sync operation in another container.

Some generic issues also arise:

  * Docker images carry a tag, which is an arbitrary label (with the special tag &#8220;latest&#8221; being the silent default). Many use version numbers for labels, but this is an illusion, as tags are not formally inter-related, so Docker does not know if there is a newer version of an image available. This raises the question when images should be rebuild, and how to get noticed of base image updates.
  * There is a private Docker registry container to replace the Dockerhub, but it does not include the automatic building of images from Dockerfiles and assets in git repositories.

 [1]: https://www.docker.io
 [2]: http://www.fewbytes.com/docker-selinux-and-the-myth-of-kernel-indipendence
 [3]: http://tracker.firebirdsql.org/browse/CORE-4624