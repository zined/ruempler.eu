---
title:  PuppetConf 2013 recap
---
Mi
25
Sep
2013

Better late then never. Here's my little puppetconf 2013 recap.

## Day 1

### [AWS Architecting for resilience & cost at scale](http://www.slideshare.net/jiboumans/aws-architecting-for-resilience-cost-at-scale)

Really great talk with common hints for avoiding costs and failure.

* Autoscaling and AWS
* Hybrid stuff: CI Build AMIs
* using puppetmaster behind ELB for scaleout
* Also some insights into their graphite-on-AWS setup: Using a c1.xlarge.

### [Nobody Has To Die Today: Keeping The Peace With The Other Meat Sacks](http://www.slideshare.net/PuppetLabs/nobody-has-to-die-today-puppet-conf-2013)

Most impressive talk for me. The speaker came in from the back with a loud signal-horn a few minutes late. Shocking silence immediately. This man knows how to get the audience!  
  
People actually suck at everything. We cannot see, hear, smell ... and communicate very good, only average. The only thing we have is failing and learning from failures. People might call this
"intelligent". We suck at communication, because we are not aware of contextes. Context of people is different. So how can we get better at communicating? Correct, clear, concise, consistent,
comprehensive. For example "<software X\> sucks" might be correct, but not clear. "<software X\> sucks, because I had the following problems: ..." is much more clear and
comprehensive.  
My personal experience has shown that it's even better to avoid the word "be" or its forms. You are less offending if you say "for me <software x\> seems" or "last time i looked it was like
...". Also reminded me of Jon Allpaws "[On being a senior engineer](http://www.kitchensoap.com/2012/10/25/on-being-a-senior-engineer/)"

### [Puppet Module Reusability - What I Learned from Shipping to the Forge](http://www.slideshare.net/PuppetLabs/garethrushgrove-puppetconf)

* stop the fork!
* use rspec-puppet travis and test matrixes
* use puppet-rspec-system for integration tests (serverspec is another alternative)
* os specific stuff in default parameters classes

### [Puppet at GitHub](https://speakerdeck.com/wfarr/puppet-at-github-puppetconf-2013)

Some random facts from this talk:

* unicorn as webserver for puppetmaster
* currently managing 600 nodes
* pull deployment (cron executes puppet each hour) - distributed over some minutes in order to avoid overloads (the same we are doing at Jimdo for our nodes)
* puppetdb / nagiosdb
* filtergendb for iptables
* gpanel as dashboard
* augeas in order to avoid the need to define every config var as a puppet param
* test-queue to run tests parallel: it iteratively finds out the best test distribution

And last but not least my favorite quote: "No software is better than no software". A nice explanation for this 'total cost of ownership' thingy. Keep it simple, stupid!

### [Multi-Provider Vagrant: AWS, VMware, and More](http://www.slideshare.net/PuppetLabs/multiprovider-vagrant)

The most impressive part of this presentation for me have been the insights into 'packer'. It bridges the gap between Configuration Management and Golden images. It builds images for several
target platforms from a single source template. Ok, boring? But wait! It has provisioners, so the same concept as vagrant. You can use your existing configuration management to build a golden, or
maybe just a 'silver' image: With a hybrid approach, e. g. a continuous base image building with e. g. updated packages, but also an active config management you can get the best from both
worlds:  

* Fast bootstrapping of new nodes because the initial cfg mgmt run only takes seconds
* enables for autoscaling concept
* nodes get cfg updates and hotfixes (e. g. security updates) via config management, no rotation of entire environment nodes necessary as it would be in golden-image scenario.
* Pure rotation concept still possible in the future
* great for migration phase from cfgmgmt-only to ephemeral nodes
* No manual steps for image building, knowledge is externalized into code (templates).

  
There's also netflix aminator, which does not need a running ec2 instance to build AMIs, a current packer limitation AFAIK.

### [Building Data-Driven Infrastructure with Puppet](https://speakerdeck.com/jfryman/building-data-driven-infrastructure-with-puppet)

James Fryman is searching for recurring patterns in IT. Like everyone else searching for the holy grail of wisdom, he ended up with systems theory and systems thinking. Most things we do day by
day in operations are repetitive.  
  
Interesting concept of codifying the state of nodes or systems via hubot. E. g. use puppet to seed initial facts in /etc/facter/facter.d, then toggle them via puppet/hubot/...

## Day 2

### [Anatomy of a Reuseable Module](http://www.slideshare.net/PuppetLabs/alessandro-franceschi-new)

A really good overview from Alessandro (the example42 guy) how to write reusable puppet modules including the following patterns:  
let the user decide how to manage config files, e. g. provide good defaults but make them overloadable  
let the user decide how system users are managed  
even make included classes overloadable. This ensures maximum flexibility.  
  
I learned that puppet allows you to dynamically include classes like include $classname, at least in puppet 3.0\.  
I also like the standardization initiative. Have a look at the example42 standardized modules.

### [The Road to the White House with Puppet and AWS](http://www.slideshare.net/PuppetLabs/the-road-to-the-white-house-with-puppet-aws)

* Once again Asgard
* random puppet tips:
  * use a base class to include common stuff on all nodes
  * store credentials not on servers but in S3 and use IAM policies to define roles which have access
  * use s3 based package repositores so you don't have to care for: load balacing, monitoring, security, os upgrades (remember: total cost of ownership!) [maybe like this](http://zcox.wordpress.com/2012/08/13/hosting-a-private-apt-repository-on-s3/)

### [DevOps isn't just for WebOps: The guerrilla's guide to cultural change](https://speakerdeck.com/stahnma/devops-isnt-just-for-webops)

I really enjoyed this war-story from Michael.  
DevOps is not about hipster technology, 10 deploys a day etc and writing your own tools (NIH syndrome). It's first about changing your org step by step to make it a better place for you, your
coworkers and also your customers!  
When you automate or optimize, focus on system bottlenecks, don't automate or optimize stuff with little (local) impact. Even things that might look worth to be automated at a first glance, might
be no real system bottlenecks. But we all tend to see our own problems first and it's also harder to focus on bigger bottlenecks because you usually need to work together(!) with other people or
teams. Uhhh!

Next rule: Reduce variability. Thus you have to measure variability first or make it explicit. I had to smile about the fact that they reduced database downtime and increased customer
satisfaction by just taking the database down in a SCHEDULED maintenance to apply changes instead of waiting for the unscheduled incident. So a small process change (no software development
needed!) made the situation better, not a hipster devops tool.

Share the pain: Developers with a pager tend to make better design decisions. :-) This might be a controversial topic, though.

And please, shout your failures. By being humble and pointing out your own failures you are leading by example. Maybe others follow and also get a little bit more humble.

### [Monitoring in a IaaS Age](http://www.slideshare.net/KrisBuytaert/monitoring-in-an-infrastructure-ascodeage)

Kris showed us the current state of monitoring in the IAAS world and how concepts are still clashing here. First we had a look why monitoring actually sucks? It's because it's often a manual
process of setting up. And it's always done last and thus might be forgotten (no time, no budget left, or boring). So we need a way to automate the setup in the same way we are automating setting
up services.  
  
So what are services? Is 'service' monitoring == 'service' monitoring? Who cares if an 'service', e. g. apache, is down if the 'service' (exposed to consumers) is still available? Reminded my of
cucumber-nagios.  
  
So lets have a look at the toolchain: With nagios + naginator we have automatic host and "service" monitoring. With some other tools stated (good tool overview!) we also can automate setting up a
metrics based monitoring (e. g. 'are payment requests being processed'). Thus we get a entirely automated service+monitoring+alerting setup.  
One point is left open here for me:  
How to do real service monitoring in a load-balancing cluster with puppet? Puppet is host based so where to add the check for a load balancer? Idea would be a puppet class which is included on
the monitoring host which does checks against various services. But this is a manual step again ;-)  
By also exporting metrics and dashboards we could close the circle for an entire automated service lifecycle management.

At the end of the second day I accidentally joined a crowd to visit and drink beer at the new GitHub HQ 3.0\. Mind. blown. Have a look at the pics ;)

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i47a836e8e37ba9fc/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/icb3c6c69578246ab/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/ie9d96cd111d46fb7/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i628dffbd3db79a68/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i784cf268ee1425a5/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i0439b61e1e0089cc/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/idaa8cdacb04bdb7c/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i1692b4757a8f87fa/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i8dd67261fff0685b/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i7da010047ce6f800/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i511e2fec24477633/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/ie384c5dc2a429247/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/ibcb2286e6c18f7bb/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i26c9fb44ed417e59/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i228f70591e3ef424/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i860bdf1d1e1da2e8/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i5887939ba65f7f98/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i9441837261a3e12c/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/ief0b9a3cb61942ce/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/ia23213bfbef527f9/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/iae498d2204af788d/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i20480cf7c1a9ab14/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/ibd24cabfe32d7c49/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i7135e1238e190f32/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i374885bab8bce335/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/iba57273d605ded42/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i2d8a8239b1de75d3/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i749067bf915f58ce/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/idf69d244a84cba2c/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/i710cb7baff34aa03/version/1391420563/image.jpg)
](javascript:) 

[![](https://image.jimcdn.com/app/cms/image/transf/dimension=90x90:mode=crop:format=jpg/path/sa96aabd4fda6ca54/image/ib6e133b065113951/version/1391420563/image.jpg)
](javascript:) 

[Kommentar schreiben](#)

Kommentare: _0_ 

* 1 Gilt für Lieferungen in folgendes Land: Deutschland. Lieferzeiten für andere Länder und Informationen zur Berechnung des Liefertermins siehe hier: [Liefer- und Zahlungsbedingungen](http://www.ruempler.eu/j/shop/deliveryinfo)  

[Impressum](/about/) | [Datenschutz](/j/privacy) 

[Abmelden ](https://e.jimdo.com/app/cms/logout.php)
|
[Bearbeiten](https://a.jimdo.com/app/auth/signin/jumpcms/?page=1733309993)