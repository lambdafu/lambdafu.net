---
title: User Interface Design failure common in Mac OS X, Ubuntu Unity and Gnome Shell 3
author: Marcus
date: 2011-10-17T01:43:00+00:00
url: /2011/10/17/user-interface-design-failure-common-in-mac-os-x-ubuntu-unity-and-gnome-shell-3/
categories:
  - Uncategorized

---
It is not news by now that **Canonical Unity** and **Gnome Shell 3** are considered flawed by many GNU/Linux developers (such as [Linus Torvalds][1], [Eric Raymond][2], and many passionate people with less known names). There are many flaws that hinder the short term adoption of these. Flaws that are fixable, but make them unusable until they have been developed beyond their current pre-alpha quality.

Let's first talk about the **shoddy programming quality**. The crashes I have seen in Gnome Shell 3 have been spectacular, to the point of not being able to log in anymore at all (with all extensions disabled). Ubuntu never had high software quality (memory leaks in the system monitor, race conditions in ibus, misconfigured kernels, etc). Clearly, there is not enough man power behind these efforts to sustain both the design and the implementation work. Users shouldn&#8217;t be allowed anywhere near these projects for a long time, but, given enough interest in developing these ideas, these problems could be fixed if enough effort is made. So, although a show stopper at the moment, implementation quality does not need to be a problem for adoption in the future.

Second, let's consider **feature incompleteness**. Breaking backwards compatibility is absolutely inexcusable for a shell. The irresponsibility on display here by both the Gnome Shell project and Canonical is staggering. They both break panel applet support, which disables high value productivity tools such as the [hamster time tracker][3]. Clearly, the reason is lack of resources. If they can&#8217;t even ensure that their own software works, hoping for them to support the software of others is certainly optimistic. Again, over time, the missing functionality can be regained, and then this does not need to be a critical flaw. Again, users shouldn&#8217;t be let anywhere near the Gnome Shell 3 and Unity until all the functionality is provided.

Third, any radical design change will struggle to achieve **consistency**. Here, Gnome Shell 3 seems to do okay from my limited experience with it, but Ubuntu has dropped the ball on this for quite some time. Like in the good old days of the emerging graphical desktop in GNU/Linux systems, we can now enjoy disturbing differences such as three different types of scroll bars, menu bars that are sometimes global and sometimes per window, and broken themes. In fact, theme support is now so terrible that installing any non-default theme is downright dangerous. I have seen irregular crashes and 100% cpu time consumption from choosing a non-default theme. This problem can be very hard to track down. But, over time, consistency can be achieved again, by doing the necessary hard work to fix all those little inconsistencies. This does not need to be a problem forever. Until then, users shouldn't be allowed anywhere near Ubuntu.

Fourth, there is a lack of **principled design and evaluation**. The Gnome Shell 3 [design page][4] makes a lot of claims but provides no hard data to back it up. The usability testing plans are [stuck in phase I][5] indefinitely. And Ubuntu seems to progress on its &#8220;desktop experience&#8221; without taking a clue out of the limited [usability][6] [testing][7] they do. These systems want to be used by millions of people, yet they base their radical design changes on usability testing with zero (Gnome Shell) or two dozen (Canonical Unity) people. Again, this is probably due to limited resources, but again users shouldn't be let anywhere near until the designs are proven, and then they should be marketed only towards the target groups for which they have proven themselves.

Sometimes, these problems go hand in hand. Gnome Shell 3 gets particularly instable if you use third party extensions, which you must in order to gain feature completeness. And there is no hope for consistency as long as these projects try to radically transform the &#8220;desktop experience&#8221; in the way they do.

Now, all these flaws must not persist forever. There may be a time when these problems are worked out, and then Gnome Shell 3 or Unity may actually be usable for some user group. Until then, these systems are unfortunately just another example of [cargo-cult programming][8]. They both imitate some of the features of a Mac OS X 10 GUI. Here are some examples that one or both copy:

  * The ALT-Tab behavior that switches between applications instead of windows.
  * The system preferences under a corner menu (Mac OS X: Under the apple logo in the upper left corner, Gnome Shell and Unity under the login menu in the upper right).
  * The Expose style application switcher.
  * The dock. Here, Gnome Shell diverges in that it makes the dock visible in the expose mode and not in the regular mode.
  * The icons in the dock, which do not start the program but move it up front. Plus an indication in the dock which applications are running.
  * In Unity, the global menu bar.

The big question will be if Gnome Shell 3 and Canonical Unity can overcome the above limitations and be more than a cargo cult.

However, there is one particular feature where the choice of Gnome Shell 3 and Canonical Unity is piss-poor. That is the imitation of the ALT-Tab behavior of Mac OS X, which switches between applications instead of windows. The reason behind that is very simple: The tasks a user needs to do is not defined by an application, but by a mix of windows from different applications. And a single application can have windows related to different tasks. I might have a gimp window, a browser window and a file explorer open for one task, and a browser window, a file explorer and a text editor for a completely unrelated different task. With application based switching, I have the choice between bringing up gimp, or both browser windows, or both file explorers, or the text editor. (If you are a power user, substitute file explorer with command line terminal).

I switch between windows relatively often. In fact, compared to any other graphical shell task such as starting applications, receiving notifications, or moving and resizing windows, I switch between windows an infinite number of times, while I almost never do any of the other stuff. Yet, switching windows is an insufferable experience on any of Mac OS X, Gnome Shell 3 and Ubuntu Unity. They all share this flaw, and until the computer is much smarter in detecting windows related to the same task, the only proper behavior for ALT-Tab is to switch between windows and not applications. The ALT-Tab behavior in Mac OS X is so bad that people are happy to [pay money to change it][9].

I think of all problems in Gnome Shell 3 and Unity, this problem is the worst, because it is a fundamental error in the design. For Mac OS X, this problem may have been less severe in the past, because Mac OS users have a different application design, where more tasks are integrated in a single application (for example, you can edit pictures in keynote and iphoto, etc, so you would not necessarily run an image editing application and a presentation application at the same time for the same task) and because Mac OS users are probably less heavy keyboard users. But enter GNU/Linux, where applications follow the <a ef="http://en.wikipedia.org/wiki/Unix_philosophy">Unix philosophy</a> of doing one thing and doing it right and people buy keyboards such as [this][10] or [this][11] or even make laptop buying decisions based on the keyboard quality. This is why cargo cult programming is bad: If the assumptions don't hold, the results don&#8217;t work.

Another example of cargo cult programming is the attempt to bring tablet and smartphone user interaction principles to the desktop. On devices that have a keyboard and not a touch screen, and where the screen is about 30 times larger than that of a smart phone, that is just ridiculous. But, I have not focused this article on those attempts, because clearly the current designs are more focused at copying Mac OS X than smartphones and tables. That's a mistake those projects can still make, and it should be prevented when it happens.

There are other problems in Gnome Shell 3 and Unity: The arrogance that is displayed by the designers in that they prioritize their ideas over everything else. The astonishing inability to listen to critical feedback. The violation of their own stated design goals (how does application switching in Gnome Shell 3 &#8220;reduce distraction and interruption&#8221;?). The refusal to perceive the Shell as a platform, that must have a supported way to extend it.

I don't think that user interfaces need to be exclusive. What&#8217;s good for a beginning user should also be good for an advanced, expert user. The ALT-Tab behavior is wrong not because it prioritizes one user over the other, but because it does not serve either. It&#8217;s a gratuitous change in imitation of another successful operating system, without any research into the question if that system is successful because of that behavior or despite of it.

At this stage, Gnome Shell 3 and Unity are rushed projects that are based on imitation instead of innovation, but without the proper execution. No wonder they cause so much friction in the community. The proper resolution will have to wait until these projects have overcome the initial imitation phase and made their own experiences. Unfortunately, due to random accidents in history, these lessons will be made at the expense of many users of Fedora and Ubuntu who are thrown into this mess. For Ubuntu, this is particularly frightening as it was marketed as a good beginner system for a long time. This was only true as long as it was based on the stability and development efforts of the community. There is little evidence so far that Canonical can single handedly revolutionize the &#8220;desktop experience&#8221;. So, as things stand, I have more hopes for Gnome Shell 3 to eventually become a viable solution, given enough iterations. Until then, it's wait and watch.

 [1]: http://www.theregister.co.uk/2011/08/05/linus_slams_gnome_three/
 [2]: http://esr.ibiblio.org/?p=3822
 [3]: http://projecthamster.wordpress.com/2011/02/15/no-hamster-for-gnome-3-0-but-one-for-3-0-2-perhaps/
 [4]: http://live.gnome.org/GnomeShell/Design/
 [5]: http://live.gnome.org/GnomeShell/Design/UsabilityTesting/PhaseI
 [6]: http://design.canonical.com/2010/11/usability-testing-of-unity/
 [7]: http://lwn.net/Articles/438678/
 [8]: http://en.wikipedia.org/wiki/Cargo_cult_programming
 [9]: http://manytricks.com/witch/
 [10]: http://en.wikipedia.org/wiki/Happy_Hacking_Keyboard
 [11]: http://en.wikipedia.org/wiki/Model_M