---
title:  "Streaming Geoblocked Contents without VPN"
banner: "/images/streaming-geoblocked-contents-without-vpn/banner.png"
description: "An alternate method of watching geoblocked contents without the overhead of the VPN protocol."
date:   2016-06-19 15:22:00 +0900
---

So the UEFA Euro cup 2016 is on and I am sitting here in Tokyo wanting to watch the games.
I could get cable or go to sport bars.
Getting cable just for the games is not worth the money and hanging around in bars at night (the games will show from around 11pm to 5am here) is not a favorable option as well.

Luckily everything can be streamed by the internet nowadays.
However, it is difficult to get access to free streams (that are legal).
Germany's public television stations ARD and ZDF provide such streams but due to [geoblocking](https://en.wikipedia.org/wiki/Geo-blocking) they can only be watched from within the country.

So what options do I have to access these streams from Tokyo?

## 1. The VPN approach

The simplest solution is to get a VPN server in Germany, setup the client on my local machine and access the stream as I would in Germany.
Most tutorials on the internet seem to advocate this.

It didn't work out for me though.
I tried to setup an OpenVPN client and server and accessed the stream.
It was playing for about 15-30 seconds before the stream disconnected.
Maybe I have a bad internet connection or should have tried different settings.

Eventually I gave up in favor of the following solution.

## 2. Relaying the streams with VLC

The ARD/ZDF streams are not encrypted nor require any special software to be played.
It is possible to access them from a server in Germany with [VLC](http://www.videolan.org/vlc/) and re-stream the data (without geoblocking).

### Getting the stream URLs

The URLs can be found by a quick [Google search](https://www.google.com/search?q=ard+zdf+streams).

~~~bash
http://daserste_live-lh.akamaihd.net/i/daserste_de@91204/master.m3u8
http://zdf_hds_de-f.akamaihd.net/i/de14_v1@147090/master.m3u8
~~~

These playlists reveal the raw HTTP stream URLs in different qualities.
For example the ARD playlist contains:

~~~bash
#EXTM3U
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=184000,RESOLUTION=320x180,CODECS="avc1.66.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_184_av-p.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=184000,RESOLUTION=320x180,CODECS="avc1.66.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_184_av-b.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=320000,RESOLUTION=480x270,CODECS="avc1.66.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_320_av-p.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=320000,RESOLUTION=480x270,CODECS="avc1.66.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_320_av-b.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=608000,RESOLUTION=512x288,CODECS="avc1.77.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_608_av-p.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=608000,RESOLUTION=512x288,CODECS="avc1.77.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_608_av-b.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1216000,RESOLUTION=640x360,CODECS="avc1.77.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_1216_av-p.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1216000,RESOLUTION=640x360,CODECS="avc1.77.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_1216_av-b.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1992000,RESOLUTION=960x540,CODECS="avc1.77.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_1992_av-p.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1992000,RESOLUTION=960x540,CODECS="avc1.77.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_1992_av-b.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2691000,RESOLUTION=960x540,CODECS="avc1.77.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_2692_av-p.m3u8?sd=10&rebase=on
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2691000,RESOLUTION=960x540,CODECS="avc1.77.30, mp4a.40.2"
http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_2692_av-b.m3u8?sd=10&rebase=on
~~~

### Getting a server in Germany and install VLC

Fortunatly, renting a server with root access is cheap nowadays.
[DigitalOcean](https://m.do.co/c/655a91648817) has VPS servers starting from $5 a month.
As they charge by hour, just watching the soccer games will almost cost nothing.
The only thing we have to be aware of is to create the server in the Frankfurt datacenter.

After logging into a root terminal, the following command will install VLC:

~~~bash
apt-get install vlc-nox
~~~

`vlc-nox` provides a headless VLC without GUI.
Basically it is just an alias to `vlc -I dummy`.

### Using VLC to relay the stream

VLC can both access the stream and send it out simultaneously with a build-in HTTP server.
That is basically all we have to tell it to do, it is plain simple.

~~~bash
#!/bin/bash
FILE="http://daserste_live-lh.akamaihd.net/i/daserste_int@91203/index_2692_av-b.m3u8?sd=10&rebase=on"
cvlc -vvv $FILE --network-caching=15000 --sout "#standard{access=http,mux=ts,dst=:8080/ard}"
~~~

With `--network-caching=15000` a very conservative buffer of 15 seconds is used.
`--sout "#standard{access=http,mux=ts,dst=:8080/ard}"` does the magic of creating a HTTP server that listens on port `8080` and makes the stream available at URL `http://<your-servers-ip>:8080/ard`.

##Conclusion

By relaying the stream with VLC, geoblocking could be avoided.
Compared to a VPN solution I could even get a much more stable stream without sacrificing quality.

On the down side, this technique may not work in cases where the stream is not easily accessible or encrypted.
VPN or more serious hacking has to be used to relay such streams.