# nginx searchbots
This repo contains Nginx config snippets definitions for classifying client's request based on user-agent field as a human or as a bot. This marker can be used later as
* logging
* logging and log processing with tools like Collectd and visualized with tools like Grafana
* using in `if ...` expressions inside Nginx config for implementing logic

# Idea
Sometimes it's hard to say why there is a extra site load happens - night time and users should be sleeping. Several times it was found that indexing is happening and that required to take a look into Nginx's logs, instead of lazy way of just checking dashboard graphs. So to help myself, I ( Roman Ovchinnikov / @CoolCold ) added the most known bots UA into the list and made graphs.

# TL;DR - how to use it?
TODO: 
*  add copy-pastable commands for files
*  add Debian and sublings packages
  *  make automated builds with tests for that, gain CI/CD experience
  
# Installation
## Nginx
put both files into nginx's `conf.d` directory, in your vhost log definition, use like this:
```
access_log /var/log/nginx/exammple.org.collectd.access.log collectd_prepared buffer=64k flush=10s;
```
## Collectd
TODO - add sample `tail` plugin config excerpt
## Grafana
TODO - add sample graph
## other ways
Feel free to contribute via opening issue for this project.

# Implementation
## Classifier
Couple of maps applied to `$http_user_agent` field, producing 2 results
1.  variable `$isbotengine` - default is `0`, if bot then `1`
2.  variable `$botengine` - default is `user`, if known as big engine, like Google or Bing, then it's name, for most of small/local engines is set to `unclassified` for now. Fill issue with data updates.

Sample for bot/not bot:
```
# this conf is to mark request as coming from bot and what engine is it
map $http_user_agent $isbotengine {
        default 0;
        "~*360spider" 1;
        "~Aboundex/0.3" 1;
}
```

Sample for bot type:
```
map $http_user_agent $botengine {
        default 'user';
        "~*360spider" 'unclassified';
        "~Aboundex/0.3" 'unclassified';
        "~GimmeUSAbot/1.0" 'unclassified';
        "~Googlebot-Image/1.0" 'Google';
        "~Googlebot-Mobile/2.1" 'Google';
        "~Googlebot/2.1" 'Google';
        "~HaosouSpider" 'unclassified';
}
```

## Logging
Coupled with logging, provides easy way to check who is nagging your website/service, be it `tail -f` or like ElasticSearch.
Sample for logging:
```
user@server:~$ cat /etc/nginx/conf.d/logformat_collectd_prepared.conf
log_format collectd_prepared 'status=$status bbs=$body_bytes_sent rt=$request_time urt="$upstream_response_time" $remote_addr "$request" "$http_referer" "$http_user_agent" "$host" "$time_local" isbotengine=$isbotengine botengine=$botengine caching_status=$upstream_cache_status';
```
Sample for processing:

**ADD ME**
# Accuracy
## detection
consists of two parts
*  number of known user agents listed in this files
*  the way it's so easy to spoof user agent, so apply with care.

Much better accuracy can be achievied with combining UA field with IP of client, but that required more work and not implemented. See #improvements section

## measurement
Measurement is very accurate, as it logs of your webserver, not a uBlock shunned JS script reporting back somewhere.

# Questions
## Does it affect performance?
Short answer - no. Long asnwer - until you have something like 1000 requests per second ( special note for Singapore - 60*1000 requests per minute), you may not care. If you have more, than that, better consult with your system administrator to make sure about disk io.
## Bot definition is missing, how to add?
Submit issue here

# log collector
here comes log collector with ![pixel](http://gh-tracker.extp.coolcold.org/tracker.gif) image.
