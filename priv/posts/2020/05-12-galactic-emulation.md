%{
  title: "Galactic emulation",
  author: "Daniel King",
  tags: ~w(software emulation games reverse-engineering swg),
  description: "Reverse engineering the server-side code of dead MMO games"
}
---
Preserving old media seems like a worthwhile task, assuming you think it has some cultural value.

Take a 35mm reel of film for example, you can "preserve" it by making copies and storing them in a safe environment. The film can be considered preserved as long as you have the print and the equipment to project or [transfer](//en.wikipedia.org/wiki/Telecine) it.

If your media starts out digital you need specific software, and in some cases hardware, to consider it preserved.

To play a digital film you need software that can read the file container format (AVI, MOV, MP4, etc.) as well as the [video codec](//en.wikipedia.org/wiki/Video_codec) (MPEG-4 etc.). If no one bothers write a player for your legacy video format in the future your media remains trapped on old technology.

## Preserving software

Things get a little trickier when the media you want to preserve, like a video game, was itself released as software. The released [binary](//en.wikipedia.org/wiki/Executable) will have been built for particular hardware, and in many cases won't run on newer hardware without some work.

A Nintendo 64 binary was compiled to run on the Nintendo 64, not your modern laptop or phone. If you had access to the original source code, or could cleverly [reverse engineer](//www.retroreversing.com/N64Reversing) your way to it, you could rebuild for new hardware and preserve the game that way.

However, in many cases you won't have access to that original source code, leaving you with the options of [recreating](//github.com/MiSTer-devel/Main_MiSTer/wiki) or emulating the original hardware that the binary ran on.

Emulation for classic games consoles has been around for decades, I've attempted to write emulators [myself](//github.com/northerner?tab=repositories) a couple of times, they make for interesting little hobby projects. If the hardware is relatively simple, most of the work in writing an emulator is in mapping the memory and hardware addresses of the original console.

An emulator recreates the behavior of the target hardware in software.

## Emulation without the original software

I recently got back in to [Star Wars Galaxies](//swglegends.com/) (SWG), an [MMO](//en.wikipedia.org/wiki/Massively_multiplayer_online_role-playing_game) released in 2003 that was shutdown in 2011, and this is where my inspiration for this post originates.

<figure>
  <img decoding="async" src="/images/swg_ui-1024x429.jpg" alt="Star Wars Galaxies - UI"/>
  <figcaption>The very busy UI of Star Wars Galaxies, quite typical of MMOs of this era.</figcaption>
</figure>

There is no reason to emulate SWG on modern PCs, thanks to the relative stability of Windows as a platform you can still run games well over 20 years old. However, a lot of the logic in an MMO lives on the server, that's code you never have access to.

When you're playing a multiplayer game in a persistent world you need a server that's on 24/7 preserving the state of the world. The server has to decide where to spawn the AI creatures and characters of the world, the items they have to loot, the location and state of all the players, along with any other state that makes the world feel alive.

Since players never have access to this server code, any community that wants to preserve and continue playing a game after it is officially shut down have to reverse engineer it.

As a game client your interface to the server code is over the network, so most MMO server emulation starts with [packet sniffing](//en.wikipedia.org/wiki/Packet_analyzer) the game's network activity before the official servers are closed. Your new server then needs to recreate this same interface. Although we're not talking about hardware emulation is the same sense of the Nintendo 64 example, this is still emulation.

Reverse engineering a game's network protocol is not easy, particularly if actions in the game do not give predicable, easily identifiable network traffic, as was apparently the case with the [Matrix Online](//www.vice.com/en_us/article/53g5dk/the-death-and-rebirth-of-the-matrix-online).

In the case of Star Wars Galaxies their are [several projects](//massivelyop.com/2019/03/20/hyperspace-beacon-which-star-wars-galaxies-emulator-should-i-try-first/) running unofficial servers, some [emulating from scratch](//github.com/swgemu), and others using parts of the original server source.

## The legal issues

Unfortunately the [legal status of these emulators is still not clear](//massivelyop.com/2019/05/18/lawful-neutral-what-dmca-exemption-victories-really-mean-for-mmo-preservation/), which is a problem for organizations like museums that want to preserve games in their original working state.

![WoW Classic Molten Core](/images/WoW_Classic_Molten_Core_3840x2160-1024x576.jpg)

The best these organizations might hope for is for game developers to open source their server code when they officially shut down their games. However, the recent success of [WoW Classic](//worldofwarcraft.com/en-us/wowclassic) might have game publishers thinking of potential reboots for their old games, and cashing in on any nostalgia could put them off supporting community-run servers.

But if the creators keep their games running, maybe server emulation won't be so important.
