---
title:  puppet-rspec debugging
---
Di
03
Apr
2012

While introducing [rspec-puppet](https://github.com/rodjek/rspec-puppet) into a big and grown puppet codebase at Jimdo we needed to debug stuff and get more verbose
output while writing the first tests. As the interwebs aren't very chatty about the topic, here for all the distressed googlers:

Configure debug output and a console logger in your test (or helper or somewhere):

    
    it "should do stuff" do
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
      should ...
    end
    

hth :)

[Kommentar schreiben](#)

Kommentare: _2_ 

* **\#1**

**jojo** (_Donnerstag, 26 September 2013 18:47_)

danke!
* **\#2**

**Juan** (_Dienstag, 28 April 2015 11:18_)

Thanks a lot!
* 
1 Gilt für Lieferungen in folgendes Land: Deutschland. Lieferzeiten für andere Länder und Informationen zur Berechnung des Liefertermins siehe hier: [Liefer- und Zahlungsbedingungen](http://www.ruempler.eu/j/shop/deliveryinfo)  

[Impressum](/about/) | [Datenschutz](/j/privacy) 

[Abmelden ](https://e.jimdo.com/app/cms/logout.php)
|
[Bearbeiten](https://a.jimdo.com/app/auth/signin/jumpcms/?page=966846648)