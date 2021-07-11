Swag Badge Battery Pack.
========================

At LCA 2021, many attendees were given a [Swag
Badge](http://www.openhardwareconf.org/wiki/Swagbadge2021).  
The swag badge has an ESP32 with WiFi and Bluetooth (it can't connect
to WPA-Enterprise networks though!), a couple of Oled displays, and a
heap of connectivity possibilities.

It can be powered from a micro-USB connector.

But if it is to be used as a _badge_ it needs portable power.

I'm trying to design a battery holder for an 1100mAH LiPo (usually used
for small RC helicopters). These usually come with a Molex 15001 connector;
the Swag Badge has a JST RCY connector. Either cut it off and replace, it,
or use an adapter.

[This battery](https://www.ebay.com.au/itm/174761665304?ssPageName=STRK%3AMEBIDX%3AIT&_trksid=p2060353.m2749.l2649)
is 45mm long. 26mm wide, and 9mm thick, and should be compatible.

Spectrum Chat
-------------

https://spectrum.chat/lca2021-swagbadge/general?tab=posts

Licence
=======

Code licensed under Creative Commons Attribution Share-Alike,
non-Commercial, version 4.0 International.
(CC-By-SA-NC 4.0)
You may freely copy, adapt, and share this code for non-commercial
purposes, providing you acknowledge the author(s) of it, and relicense
under the same terms.

Versions and Printing Notes
===========================
The initial version does not work.  The pins are too fat for the 2.5mm⌀ holes; 
and the clearance is insufficient for the shell to slide onto the plate.
Do not build this version!

Current head of tree works, but you need to use M2.5 nuts and bolts to attach
the battery pack to the SwagBadge.
