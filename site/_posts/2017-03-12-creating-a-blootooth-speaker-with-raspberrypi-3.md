---
title:  "Making Bluetooth Audio Work Properly on the Raspberry Pi 3"
banner: "/images/making-bluetooth-audio-work-properly-on-the-raspberry-pi-3/banner.png"
description: "An A2AP/AVRCP implementation in Python that uses the BlueZ5 DBUS interface."
date:   2017-03-12 14:32:00 +0900
---

The Raspberry Pi 3 ships with a Bluetooth chip which is awesome.
It can be used for many purposes but the first thing that comes into my mind is to transform it into a portable speaker.

By doing a quick Google search, everybody suggest the same solution (such as [here](http://www.instructables.com/id/Turn-your-Raspberry-Pi-into-a-Portable-Bluetooth-A/)) by setting up a few config file and let PulseAudio handle the rest.
But this solution has some serious drawbacks, I was unsatisfied with the following points:

- There is a significant audio delay of 1-3 seconds
- Sound quality is bad due to remixing or resampling within PulseAudio (and I couldn't fix it)
- Remote volume control is not working
- Clients have to be paired manually

Some of this problems might get fixed in future releases of PulseAudio, but it seems it was never designed to run on ARM devices in the first place.
So I had to come up with a better working solution.

*For the impatient:*

I uploaded the whole solution on [Github](https://github.com/lukasjapan/bt-speaker) and the speaker daemon can be installed (on raspbian) with the following command:

```bash
curl -s https://raw.githubusercontent.com/lukasjapan/bt-speaker/master/install.sh | sudo bash
```

For everybody else, keep reading to learn about the internals.

## Linux Bluetooth system (BlueZ)

First we need to understand what we are working with.
Let's start with the Linux Bluetooth stack.
It is implemented by the volunteers of the [BlueZ project](http://www.bluez.org/).

![Diagram representing the BlueZ architecture](/images/making-bluetooth-audio-work-properly-on-the-raspberry-pi-3/diagram1.png)

The Bluetooth hardware is controlled by interacting with Bluez's daemon via its [DBUS interface](https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc) (more info about DBUS [here](https://www.freedesktop.org/wiki/Software/dbus/)).
Basic operations such as connecting or pairing devices can be done with [hcitool](https://linux.die.net/man/1/hcitool) which is an interactive tool for the command line.
Under the hood, it also uses the DBUS interface, thus all of its logic can be implemented into any other application rather easily.

Actual functionality is provided by other applications that also have to use the DBUS interface.
For example the [PulseAudio Bluetooth Modules](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/) which will simply collect all music streams from connected clients and pass them to the default audio sink.

## Bluetooth profiles

Next, we need to think about how we can use BlueZ to achieve what we want.

Bluetooth itself defines a set of protocols that are called [profiles](https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles).
The profiles that we can use with BlueZ are listed [here](http://www.bluez.org/profiles/).

To build a speaker we can use A2DP (Advanced Audio Distribution Profile) for transferring the audio stream and AVRCP (Audio/Video Remote Control Profile) for noticing changes in volume.
Naturally, the client (such as a smartphone) also has to support these profiles.
This is normally the case and can be verified for iOS devices [here](https://support.apple.com/en-kw/HT204387) and for Android devices with a little bit of searching [here](https://developer.android.com/reference/android/bluetooth/package-summary.html).

## Bluetooth Speaker Implementation

Now, we can start to build an application that uses A2DP and AVRCP to turn the Pi into a speaker.

I found the great [BT-Manager](https://github.com/liamw9534/bt-manager) library for Python and am going to build upon that.
Unfortunately it was written for the DBUS interface of Bluez Version 4 which is outdated by now.
So I had to rewrite a lot of parts to make them work with Bluez Version 5 in the process.

From now on, I am trying to keep the following a bit more general for better understanding.
Please read the [source code](https://github.com/lukasjapan/bt-speaker)  and [API documents](https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc) if you want to know about the nasty details.

### Connection of the Client Devices

The first thing to do is to make connections of client devices more practical.
Currently all devices have to be paired manually via `hcitool` before they are allowed to stream audio.
That is quite bothersome.

By using the BlueZ DBUS API, a callback can be registered that will be executed whenever a client wants to connect with a profile.
Inside the callback, it can be decided if a client should be accepted or rejected.

The logic I implemented lets a single client connect unconditionally with the A2AP/ACRPC profiles and reject all other clients until it disconnects.
I enable the visibility of the device by default but am hiding it when a client is connected.

The result of this simple logic is that the speaker works on a first come first served basis.
This is not typical for Bluetooth.
Normally the device will not let any client connect while being paired with another one.
However, since there is no convenient way to tell the Raspberry Pi to unpair the current client, this logic works out quite well here.

### Retrieving the Audio Stream

Bluetooth's A2AP profile allows MPEG-1 and AAC streams but also defines its own codec, the [SBC codec](https://en.wikipedia.org/wiki/SBC_(codec)).
Implementation of this codec is mandatory for any device using the A2AP profile.

After letting Bluez know what kind of streams the application can handle, another callback is registered.
This callback will receive a file descriptor once an audio stream is ready to be transferred.
It looks like that the file descriptor transports the stream in RPT packets which contain the SBC encoded data.
More detail about this can be found in the articles from the [Light of Dawn blog](http://www.lightofdawn.org/blog/?viewCat=Bluetooth).

These packets will be decoded by a [small C-library](https://github.com/lukasjapan/bt-speaker/tree/master/codecs) which finally produces raw audio that can be passed to ALSA or processed otherwise if desired.

It turns out that the decoding process just uses about 5-10% of the Raspberry Pi's CPU power which leaves more than enough space for other applications.

### Volume Control

When a client is connected with the AVRCP profile, changes in volume and also current audio track information are broadcasted on the DBUS.

All that needs to be done is to listen to these messages and react to them appropriately.
I forward changes in volume directly to the primary ALSA mixer.

## Conclusion

The final application works much better than the PulseAudio solution.
I got improvements in speed, performance and can now also control the volume from my smartphone.
Not having to install the complete PulseAudio suite is quite nice too.

However, one thing that still bothers me is the sound quality.
It has definitely been improved but is not perfect yet.

I am using the 3.5mm headphone jack and there is constant high pitch interference noise.
It seems to be a [problem with the Raspberry Pi](https://www.raspberrypi.org/forums/viewtopic.php?f=38&t=37038) itself.
Maybe an external soundboard could make things better.

Also, compared to connecting my phone directly to the speaker, the quality is just not as good.
This may be a side effect from using the SBC codec but I won’t know for sure unless I try to stream the audio in MPEG-1 or AAC.

## The source code

The full source code of this project is available on [Github](https://github.com/lukasjapan/bt-speaker).
In most cases it will be sufficient to edit [bt_speaker.py](https://github.com/lukasjapan/bt-speaker/blob/master/bt_speaker.py) if you want to add your own logic.

So, that's it!
I hope my work makes your life a bit easier and realizes some great Raspberry Pi powered speaker projects.
Thanks for reading and stay tuned for more!
