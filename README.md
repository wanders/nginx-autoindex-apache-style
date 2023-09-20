Apache-style NGINX autoindex
============================

This intends to make NGINX's automatic directory index (as generated
by [ngx_http_autoindex_module][1]) look and feel like Apache's
FancyIndex (as generated by [mod_autoindex][2]).

[1]: http://nginx.org/en/docs/http/ngx_http_autoindex_module.html
[2]: https://httpd.apache.org/docs/current/mod/mod_autoindex.html

This is mainly for when switching from apache to nginx and there are
software that scrapes these pages, or when users have a hard time
coping with changes.

It intends to keep look and feel, as well as links (including sorting
specifiers) identical to apache.

Installation/Configuration
==========================

Installation is two parts the style.xsl file and nginx
configuration. The style.xsl file can be placed anywhere in the filesystem, the nginx config needs to be something like this:

```
      location / { # or whatever location
          autoindex on;
          autoindex_format xml;
          xslt_stylesheet /path/to/this/file/style.xsl;
          set $sortC M;
          set $sortO D;
          if ($args ~ 'C=(.)' ) {
              set $sortC $1;
          }
          if ($args ~ 'O=(.)' ) {
              set $sortO $1;
          }

          xslt_string_param sort-C $sortC;
          xslt_string_param sort-O $sortO;
          xslt_string_param location $uri;
      }
```

Demo/Development
================

The `demo` subdir contains a bash script that will start nginx in a
docker container, listening on port 8080 and providing directory index
for the directory specified as argument.