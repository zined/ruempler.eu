# Integrating Google SSL Search into your Firefox Searchbar
Mo
24
Mai
2010

[Google search is now also possible via SSL](http://googleblog.blogspot.com/2010/05/search-more-securely-with-encrypted.html). If you are paranoid like me you might
wanna have it enabled by default - while there are [several firefox plugins](https://addons.mozilla.org/en-US/firefox/addon/161901/) around there, here's how to do it
on your own:

1. Copy an existing Google Search Plugin XML into your Profile under "searchplugins" (maybe the diectory has to be created first). In Ubuntu for example it's placed
/usr/lib/firefox-addons/searchplugins/<your locale\>/google.xml  
Your own Firefox Profile is located in $HOME/.mozilla/firefox/<Profile Name/ (Ubuntu).
2. Edit the freshly copied google.xml within your profile, change the ShortName to e. g. "My SSL Google" and `<Url type="text/html" method="GET"
    template="http://www.google.com/search"`to  
`<Url type="text/html" method="GET" template="https://www.google.com/search">`
3. Restart Firefox and switch to your new own Goodle Search Profile (the scrolldown thingy with wikipedia, google, yahoo etc.)

This tutorial is also valid for other OSes, but you may have to find the appropiate locations / directories yourself ;)

I've been using my own google search xml for ages anyway to change the default language to english because it's annoying to have auto-geo-autodetected language search results everytime esp. if
you search for technical things most of your time (Yes you could also set your preferred language in google, stay logged in all the time, let your cookies survive browser restarts etc, but that's
no option for me). To accomplish this, just add a param line to the xml file like this: `<Param name="hl" value="en"/>  
`

[Kommentar schreiben](#)

Kommentare: _0_ 

* 1 Gilt für Lieferungen in folgendes Land: Deutschland. Lieferzeiten für andere Länder und Informationen zur Berechnung des Liefertermins siehe hier: [Liefer- und Zahlungsbedingungen](http://www.ruempler.eu/j/shop/deliveryinfo)  

[Impressum](/about/) | [Datenschutz](/j/privacy) 

[Abmelden ](https://e.jimdo.com/app/cms/logout.php)
|
[Bearbeiten](https://a.jimdo.com/app/auth/signin/jumpcms/?page=274749614)