---
title: Query Semantic MediaWiki with Angular through CORS
author: Marcus
date: 2014-10-16T12:28:53+00:00
url: /2014/10/16/query-semantic-mediawiki-with-angular-through-cors/
categories:
  - Programming
tags:
  - angularjs
  - CORS
  - CSRF
  - mediawiki
  - programming
  - webapp

---
I have a private [MediaWiki][1] with the [Semantic MediaWiki][2] extensions, to keep some personal data. Wouldn't it be nice to query that data from some other server, or from a web app? Semantic MediaWiki has a nice [API][3] that allows us to get data in JSON format. But we need to defeat the <a href="http://de.wikipedia.org/wiki/Same-Origin-Policy"</a>Same-Origin-Policy</a> that protects our servers from [evil code][4]. JSONP is a well-known method that works, but only for anonymous requests on public wikis. Here is another approach that works with closed wikis, too.

### MediaWiki

In LocalSettings.php, you need to [allow][5] [CORS][6]. You can use the *-wildcard or a list of allowed domains to query your MediaWiki instance:

```
$wgCrossSiteAJAXdomains = array( '*' );
```

Also, all API requests will take an `origin` parameter that repeats the domain from which the request came. This is very annoying, but the MediaWiki developers were concerned about implemented [caching properly and efficiently][7], and this is the solution they came up with.

I am running the example code in a local server with

```
python -m SimpleHTTPServer 8000
```

so the origin parameter should be `http://localhost:8000` and I don't need to disable strict origin policy checking for file URIs in my browser.

### AngularJS

Here you need to configure the http service provider to allow cross-domain requests. We also configure it to send credentials along with a request globally.

```
   app.config(function($httpProvider) {
        $httpProvider.defaults.useXDomain = true;
        $httpProvider.defaults.withCredentials = true;
   });
```

### Logging in

To [log in][8], you need to send a POST request to the MediaWiki API, and follow it up with another POST request to confirm (older versions only require one step). I put this in a controller:

```
$http.post('http://example.com/wiki/api.php', '',
           { params: { origin: 'http://localhost:8000',
                       format: 'json',
                       action: 'login',
                       lgname: 'marcus',
                       lgpassword: 'secretpassword' },
             /* Prevent CORS preflight.  */
             headers: { "Content-Type": "text/plain" }
            }).success(function(data) {
              if (data.login.result == 'NeedToken') {
                $http.post('http://example.com/wiki/api.php', '',
                           { params: { origin: 'http://localhost:8000',
                                       format: 'json',
                                       action: 'login',
                                       lgname: 'marcus',
                                       lgpassword: 'secretpassword',
                                       lgtoken: data.login.token },
                             /* Prevent CORS preflight.  */
                             headers: { "Content-Type": "text/plain" }
                            }).success(function(data) {
                              $http.get('http://example.com/wiki/api.php',
                                        { params: { origin: 'http://localhost:8000',
                                                    format: 'json',
                                                    action: 'ask',
                                                    query: '[[Category:Contact]]'
                                                  }
                                       }).success(function(data){
                                         pim.contacts = data.query.results;
                                       });
                            });
              }
            });
```

Not the prettiest of code. There is a lot of error handling missing, and so on. But it should get you going. The login process will store session cookies in the http service provider, which are sent in the following API requests. Of course, you can also query wiki pages with the parse action, etc., as normal.

The special content-type header prevents the pre-flight OPTIONS requests that are specified by CORS, and that are not supported by MediaWiki. If you see unhandled OPTIONS requests in your network log, then you need to take a closer look at the content-type header. I don't know yet if that is a concern for downloading images from the MediaWiki server. If you try it, leave a comment!

 [1]: http://www.mediawiki.org/wiki/MediaWiki
 [2]: https://semantic-mediawiki.org/
 [3]: http://semantic-mediawiki.org/wiki/Ask_API
 [4]: http://de.wikipedia.org/wiki/Cross-Site-Request-Forgery
 [5]: http://www.mediawiki.org/wiki/API:Cross-site_requests#CORS_usage
 [6]: http://en.wikipedia.org/wiki/Cross-origin_resource_sharing
 [7]: https://bugzilla.wikimedia.org/show_bug.cgi?id=20814#c6
 [8]: http://www.mediawiki.org/wiki/API:Login