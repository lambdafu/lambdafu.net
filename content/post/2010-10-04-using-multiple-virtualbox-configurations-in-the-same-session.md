---
title: Using multiple VirtualBox configurations in the same session
author: Marcus
date: 2010-10-04T13:38:05+00:00
url: /2010/10/04/using-multiple-virtualbox-configurations-in-the-same-session/
categories:
  - Uncategorized
tags:
  - configuration
  - virtual machines
  - virtualbox

---
If you want to use multiple VirtualBox configuration directories in the same sesssion (by setting `VBOX_USER_HOME` to some other `.VirtualBox` directory than the default), you will stumble upon this problem: If you have a running instance of a virtual machine of some configuration, subsequent invocations of VirtualBox will always refer to that machine's configuration environment, and ignore your HOME settings. This is because VirtualBox behaves differently on the first start than on subsequent starts: It first checks if a server is already running. If yes, it just connects to that server. And only if no server is running it will start a new server with your settings.
  
The server is looked for under the path `/tmp/.vbox-USERNAME-ipc`. The `USERNAME` part is derived from the following information in that order:

  1. the content of the environment variable `VBOX_IPC_SOCKETID`
  2. the user name from the password database with the UID of the current process
  3. the content of the environment variable `LOGNAME`
  4. the content of the environment variable `USER`

The last three are essentially the same in any standard configuration, but the first is usually empty. By setting `VBOX_IPC_SOCKETID` to some unique identifier you can make VirtualBox start a new server and thus load another configuration instance. The identifier should not be the name of a different user on the same system, as that could lead to collisions. Just use your username and add something to it, for example:

```python
$ VBOX_USER_HOME=~/work/VirtualBox VBOX_IPC_SOCKETID=marcus-work
$ VBOX_USER_HOME=~/work/tests/VirtualBox VBOX_IPC_SOCKETID=marcus-tests
```

Why would anybody want to do this? Multiple configuration directories can happen if you want to access backup copies of your old configurations, or you make a copy of your configuration for some testing. In these cases you will have to adjust some paths in the configuration first, though! Another important use case is keeping some virtual machines in an encrypted file system.