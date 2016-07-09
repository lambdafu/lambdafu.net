---
title: A better iterator for couchdb-python
author: Marcus
date: 2011-09-17T14:14:18+00:00
url: /2011/09/17/a-better-iterator-for-python-couchdb/
categories:
  - Uncategorized
tags:
  - couchdb
  - couchdb-python
  - performance
  - programming
  - Python

---
The most used python library for CouchDB seems to be [couchdb-python][1]. It is a simple little library that makes accessing a couch database a breeze, but it has a serious limitation when using views: The first thing it always does is to fetch all rows in the view. Then it processes them and keeps them as a list in memory. Because it is using simple data types (as opposed to a C extension or at least records), these lists have a huge overhead of about 1 KB per row (ouch!). And, this does not only affect custom views, but also the `_all_docs` view that is used to iterate over all documents in the database.

The bottom line is that a simple program such as the following can bring couchdb-python to a crawling halt as it tries to load all document ids into memory:

```python
import couchdb
couch = couchdb.Server()
db = couch['mydatabase']<br /> <br /> # This is dangerous.<br /> for doc in db:<br /> &nbsp; &nbsp; pass
  </div>
</div>

The problem is that this is the code shown in the documentation, and that it works just fine for small databases (say, up to 100,000 rows). But once you scale up the workload in your database, it starts to degrade. Python programmers will recognize that this is the same problem as with the `range` function, and that was fixed by `xrange`. Unfortunately, the authors of couchdb-python repeated this mistake. This is not good. Database software is all about scaling, and it is easy enough to design your software from ground up around that principle.

To show how it can be done, I wrote a paginating iterator for couchdb-python. Now, [pagination in CouchDB is slightly convoluted][2], but not terribly so. It's only a couple lines of code:

```
def couchdb_pager(db, view_name='_all_docs',
                  startkey=None, startkey_docid=None,
                  endkey=None, endkey_docid=None, bulk=5000):
    # Request one extra row to resume the listing there later.
    options = {'limit': bulk + 1}
    if startkey:
        options['startkey'] = startkey
        if startkey_docid:
            options['startkey_docid'] = startkey_docid
    if endkey:
        options['endkey'] = endkey
        if endkey_docid:
            options['endkey_docid'] = endkey_docid
    done = False
    while not done:
        view = db.view(view_name, **options)
        rows = []
        # If we got a short result (< limit + 1), we know we are done.
        if len(view) <= bulk:
            done = True
            rows = view.rows
        else:
            # Otherwise, continue at the new start position.
            rows = view.rows[:-1]
            last = view.rows[-1]
            options['startkey'] = last.key
            options['startkey_docid'] = last.id

        for row in rows:
            yield row.id
```

It is used like this (but could also be integrated in couchdb-python as the `__iter__` method):

```
import couchdb
couch = couchdb.Server()
db = couch['mydatabase']

# This is always safe.
for doc in couchdb_pager(db):
    pass
```

The important concept in the implementation is the `bulk` size that specifies how many records should be requested at once. I have measured wall time and memory use of the above code as a function of the number of records per request. The couchdb-python implementation behaves as if `bulk` is infinite, which puts it at the far right of the diagram.

{{< figure src="/wp-content/uploads/2011/09/couchdb-perf-nt.png" >}}

The diagram does not show the whole truth: Even though couchdb-python is at the far right, that does not mean it is the fastest solution, for two reasons:

  * At high memory pressure, the performance of the operating system degrades. I can't show this in the diagram, as I have more RAM than python needs for my database. But for small RAM or large database configurations, the performance will get bad very quickly as the system starts to swap pages in and out of memory.
  * The diagram does not show the latency of the implementation. The latency is the time between processing any two rows. The higher the number of records per request is, the higher is the latency between the last row of a batch and the first row of the next one. There are various aspects to latency (maximum lag, jitter, etc). The latency behavior of couchdb-python is the most uneven possible: First it loads all rows into memory, then processes them all. That means you have to wait a long time until you can process the first row, although then you can process all rows immediately. Most of the time it's better to process data more evenly in smaller bursts.

A couple of notes on the measured performance data: For small bulk sizes, the overhead due to the high number of small requests increases quickly. The workload shifts towards the CouchDB server (1.6 times the CPU usage of Python). For average bulk sizes, the throughput approaches its optimum, and the workload evens out at 1.2 times the CPU usage of Python for the CouchDB server. Memory usage in Python increases linearly with the bulk size once the initial allocation at 10 MB is exhausted. CouchDB has constant memory use at 20 MB throughout the whole measurement, no matter what the bulk size.

So, what is the optimum bulk size? Clearly, too small bulk sizes increase the overhead due to the high number of small requests. But too large bulk sizes increase the memory footprint and latency problems. The right value is somewhere in the middle. Where exactly? For the given machine configuration, I put it at 5000. There is no increase in throughput for larger bulk sizes, while for smaller bulk sizes, there is a measurable decrease in throughput. Also, I favor real time over memory use, for a simple reason: The only way I can reduce the wall time is by increasing the bulk size. But memory use can be optimized in Python by a factor of 100 by using better data structures to store the row data. So, throughput and latency are the important factors, while memory use is only a secondary concern.

 [1]: http://code.google.com/p/couchdb-python/
 [2]: http://guide.couchdb.org/draft/recipes.html#Fast%20Paging%20%28Do%29
 [3]: http://blog.marcus-brinkmann.de/wp-content/uploads/2011/09/couchdb-perf-nt.png