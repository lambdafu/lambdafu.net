+++
abstract = "This paper is first a presentation of the Hurd's design goals and a characterization of its architecture primarily as it represents a departure from Unix's. We then critique the architecture and assess it in terms of the user environment of today focusing on security. Then follows an evaluation of Mach, the microkernel on which the Hurd is built, emphasizing the design constraints which Mach imposes as well as a number of deficiencies its design presents for multi-server like systems. Finally, we reflect on the properties such a system appears to require."
abstract_short = ""
authors = ["Neal H. Walfield", "Marcus Brinkmann"]
date = "2007-07-01"
image = ""
image_preview = ""
math = true
publication = "In *SIGOPS Operating Systems Review* 41, 4 (July 2007), 30-39, ACM"
publication_short = "In *SIGOPS Oper. Syst. Rev.* (July 2007)"
title = "A Critique of the GNU Hurd Multi-Server Operating System"
#url_code = "#"
#url_dataset = "#"
url_pdf = "papers/200707-walfield-critique-of-the-GNU-Hurd.pdf"
#url_project = ""
#url_project = ""
#url_slides = "#"
#url_video = "#"

[[url_custom]]
name = "ACM"
url = "http://doi.acm.org/10.1145/1278901.1278907"

+++

## GNU Hurd

The GNU Hurd's design was motivated by a desire to rectify a number of
observed shortcomings in Unix. Foremost among these is that many
policies that limit users exist simply as remnants of the design of
the system's mechanisms and their implementation. To increase
extensibility and integration, the Hurd adopts an object-based
architecture and defines interfaces, in particular those for the
composition of and access to name spaces, that are virtualizable.


