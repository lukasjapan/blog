---
title:  "Building a R2D2 Themed Bluetooth Speaker"
banner: "/images/building-a-r2d2-bluetooth-speaker/banner.png"
description: "My R2D2 Bluetooth Speaker made out of a popcorn bucket from Tokyo Disneyland."
date:   2017-03-30 23:12:00 +0900
---

My girlfriend brought [a R2D2 shaped popcorn bucket](https://www.google.co.jp/search?q=r2d2+popcorn+bucket&tbm=isch) from Tokyo Disneyland the other day.
Turns out that it's pretty much useless, once the popcorn is gone... so I took my freedom to build something out of it.
And all I needed were some tools and a Raspberry Pi 3.

I proudly present my R2D2 Bluetooth Speaker!

![The finished R2D2 Speaker!](/images/building-a-r2d2-bluetooth-speaker/r2d21.png)

So how to build this thing?

The most important parts for building a speaker is the speaker unit itself and of course an amplifier.
Luckily everything can be bought on the internet nowadays.
I got a [10cm full range speaker unit](https://www.amazon.co.jp/gp/product/B009V58142/ref=oh_aui_detailpage_o01_s00?ie=UTF8&psc=1) from Amazon (~15$).
And also the [amp](https://www.amazon.co.jp/gp/product/B00K67WI9I/ref=od_aui_detailpages00?ie=UTF8&psc=1) that was even cheaper (~4$).

Lets have a look at the schematics:

![R2D2s circuit](/images/building-a-r2d2-bluetooth-speaker/circuit.png)

There is not much to explain here, its basically just soldering the parts and a few connectors together.
Since the amp runs on 12V I needed to add a converter that steps down the input voltage for the Raspberry Pi which runs on 5V.

First of all, I gave R2D2 a surgery:

![R2D2 before the surgery ...](/images/building-a-r2d2-bluetooth-speaker/r2d2_1.png)
![... and after the surgery](/images/building-a-r2d2-bluetooth-speaker/r2d2_2.png)

To connect the speaker unit with the bucket I got a block of balsa wood.
Balsa is super easy to process.
As you can see in the pictures below, I attached the speaker unit to the balsa and afterwards the whole thing to the bucket.
I used some sharp screws that easily go through the plastic.
Finally I filled the gaps with a glue gun.
This is needed to prevent an acoustic short circuit.

![The block of balsa wood and some tools](/images/building-a-r2d2-bluetooth-speaker/r2d2_3.png)
![After preparation the speaker unit is ready to be mounted](/images/building-a-r2d2-bluetooth-speaker/r2d2_5.png)
![Connecting the speaker unit from the inside](/images/building-a-r2d2-bluetooth-speaker/r2d2_6.png)

I couldn't wait, so I hooked up the amp with the speaker and my phone.
Works great so far!

![Testing the speaker unit](/images/building-a-r2d2-bluetooth-speaker/r2d2_12.png)

Open cables are not cool, so I have to tidy things up.
I started with the power cables.
The DC connector goes underneath R2D2.

![This little guy...](/images/building-a-r2d2-bluetooth-speaker/r2d2_7.png)
![... can now be used to connect a 12V power source to R2D2](/images/building-a-r2d2-bluetooth-speaker/r2d2_9.png)
![It is fixed with the glue gun on the inside](/images/building-a-r2d2-bluetooth-speaker/r2d2_8.png)

For a bit more comfort, R2D2 also gets a power switch.

![It is placed right under the speaker unit at the outside ...](/images/building-a-r2d2-bluetooth-speaker/r2d2_11.png)
![... and looks like this from the inside](/images/building-a-r2d2-bluetooth-speaker/r2d2_10.png)

Next, I want to put the amp inside R2D2.
I mounted it on a prepared piece of plywood that will cover the bucket.
The DCDC converter is quite bulky and I want to hide it as well, so I also screwed it underneath the plate.

![The wooden plate with the DCDC converter and amp underneath ...](/images/building-a-r2d2-bluetooth-speaker/r2d2_14.png)
![... covers R2D2s body and hides the inner parts](/images/building-a-r2d2-bluetooth-speaker/r2d2_15.png)

The Raspberry Pi will be mounted on the top of the plate.
It is R2D2s brain!
Once mounted, I just have to connect it to the 5V power source and the headphone jack with the amplifier.

![R2D2 now has a brain!](/images/building-a-r2d2-bluetooth-speaker/r2d2_16.png)
![The remaining gaps have been sealed off with tape](/images/building-a-r2d2-bluetooth-speaker/r2d2_17.png)

The last task is to make the Raspberry Pi accept Bluetooth connections and output the music to the headphone jack.
By using [bt-speaker](https://github.com/lukasjapan/bt-speaker), a library that I wrote for this project, it can be done with a single command.
I wrote a rather technical article about how it works [here](/2017/creating-a-blootooth-speaker-with-raspberrypi-3/).

R2D2 is powered by 12V direct current.
Luckily this is pretty common for small home electronics and I had an unused power adapter lying around.
For outdoor parties I also bought him a battery.
The battery lasts for around 10h at a pretty crazy volume.

![R2D2 and his power sources](/images/building-a-r2d2-bluetooth-speaker/r2d2_18.png)

As a gimmick, I also added some beeps when a device connects or disconnects from R2D2.
Pretty cool.

OK thats it!
I hope you had fun reading this article and start building your own R2D2 now!
