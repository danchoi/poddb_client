# poddb

_Podcatching for nerds, Zen minimalists, and Unix fanatics_.

Poddb lets you browse, search, and download podcasts from the Unix command line
and Vim.

[screenshots]


## Why

I wanted a fast and easy way to search for and download podcasts in any Unix
environment, without resorting to a GUI application or web browser.  I also
wanted to start crowdsourcing and publishing podcast download statistics to
make it easier to spot popular podcasts and podcast episodes. Finally, I wanted
a more streamlined way to search for NPR podcasts than through the NPR website
or iTunes. Poddb serves these three goals.


## Prerequisites

* Vim (7.2 or later)
* Ruby 1.9.x
* wget
* curl
* mplayer or another media player

To install Ruby 1.9.2, I recommend using the [RVM Version Manager][rvm].

[rvm]:http://rvm.beginrescueend.com

Poddb assumes a Unix (POSIX) environment.


## Install

Poddb can be installed as a Ruby gem. Please note that while the tool is called
**poddb**, the gem is called **poddb_client**.

    gem install poddb_client

Test your installation by typing `poddb -h`. You should see poddb's help.

On some systems you may run into a PATH issue, where the system can't find the
`poddb` command after installation. You might want to try 

    sudo gem install poddb_client

to see if that puts `poddb` on your PATH.

If you ever want to uninstall Poddb from your system, just execute this command:

    gem uninstall poddb_client

This will remove all traces of Poddb, except for the application-specific files
it creates in a directory called `~/.poddb`. These you'll have to remove
manually.

To update Poddb to the latest version, just run `gem install poddb_client`
again.

## How to use it

You invoke `poddb` from command line interface, passing it flags and search
terms. Poddb will send the query over the internet to the poddb server. (So you
must be online to use Poddb, though once you've downloaded some podcast audio
or video files you can play them entirely offline.) The server will send back
data, and poddb will launch Vim to let you navigate and interact with the query
results.

Here is a partial synopsis of the command line interface. A more detailed guide
to using Poddb follows.

    Usage: poddb [options] [query]

        -f, --from-favorites             Show all recent episodes from favorite podcasts
        -a, --add PODCAST_URL            Add podcast with PODCAST_URL to the poddb database
        -l, --list [QUERY]               List all podcasts in the poddb database
                                         (If QUERY is supplied, will return matching podcasts)
        -F, --favorite-podcasts          Show favorite podcasts
        -o, --order ORDER                Sort results by ORDER
                                         The only option right now is 'popular'. Default order is pubdate.
        -d, --days DAYS                  Limit results to episodes published since DAYS days ago
        -t, --type MEDIA_TYPE            Return episodes of MEDIA_TYPE only (audio,video)

## Browse and search for podcasts

To see all the podcasts in the poddb database:

    poddb -l
    
Type `poddb -l QUERY` to see if any podcasts matching the QUERY string are in
the database. E.g.

    poddb -l music 

will return all the podcasts in the Poddb database with the word "music" in the
title or podcast description.

Press `ENTER` on a podcast to see its episodes.  See **Navigate and download
podcast episodes** below for instruction on how to view and download episodes.


## Add podcasts to the database

If you don't see a favorite podcast of yours in the list returned by `poddb -l`,
you can add the podcast to the Poddb database with this command:

    poddb -a PODCAST_URL

E.g.,

    poddb -a http://www.philosophybites.libsyn.com/rss

The `-a` command will also add the podcast to your favorites.


## Favorite podcasts

When viewing a list of podcasts returned by `poddb -l`, you can add a podcast
to your favorites by putting the cursor over it and pressing `f`. Press `f`
again to remove the podcast from your favorite podcasts.  Favorite podcasts
have a `@` sign in the left margin.

    @ NPR Programs: Fresh Air from WHYY                            |     16 |      0 |  Sep 15 2011 | 
      NPR Programs: Talk of the Nation                             |     41 |      0 |  Sep 15 2011 | 
    @ NPR Programs: Tell Me More Podcast                           |     20 |      0 |  Sep 15 2011 |
      NPR Programs: Wait Wait... Don't Tell Me! Podcast            |     10 |      0 |  Sep 10 2011 | 
      NPR Series: Alt.Latino Podcast                               |     21 |      0 |  Sep 14 2011 | 
      NPR Series: From Scratch                                     |     16 |      0 |  Sep 14 2011 | 
      NPR Series: Talk of the Nation Opinion Page Podcast          |     10 |      0 |  Sep 05 2011 |
      NPR Series: World Cafe: Next from WXPN Podcast               |     10 |      0 |  Sep 12 2011 | 
      NPR Topics: Business Story of the Day Podcast                |     21 |      0 |  Sep 16 2011 | 
      NPR Topics: Economy Podcast                                  |     11 |      0 |  Sep 13 2011 |
      NPR Topics: Education Podcast                                |     12 |      0 |  Sep 15 2011 | 
      NPR Topics: Environment Podcast                              |     11 |      0 |  Sep 15 2011 | 
    @ NPR Topics: Food Podcast                                     |     11 |      0 |  Sep 15 2011 | 

Once you have a few favorite podcasts, you can list and navigate them with
the command

    poddb -F

You can also aggregate all the most recent episodes from your favorite episodes by
launching Poddb with the command

    poddb -f

Your favorite podcasts are stored in `~/.poddb/favorites` as a simple list of
podcast ids. The ids are internal to Poddb's PostgreSQL database.

## Search for podcast episodes 

With Poddb, you search for podcast episodes from the command line. If there are
matches, Poddb will launch the Vim navigation interface. If not, you'll just
see a message saying no matches were found.

A basic search like 

    poddb music oud

will return all podcast episodes that match the query words "music" and "oud."

    pubdate      | match | dwnlds | title                                              | podcast             
    -------------+-------+--------+----------------------------------------------------+--------------------
    Sep 01 2011  |  0.99 |      1 | Journeys with the Oud                              | PRI: Afropop Worldw
    Aug 05 2011  |  8.74 |        | Mystics and the Mediterranean (Podcast Edition)    | The latest articles
    Jun 29 2011  |  1.01 |        | Worldview 6.29.11                                  | Worldview Podcast  
    Oct 15 2010  |  0.97 |        | Unusual Collaborations (Weekly Podcast)            | The latest articles


You can also limit the scope of the search by media type:

    poddb -t video ruby

will return all podcast episodes that match the word "ruby" that are video
downloads. 

You can use `-t audio` to limit search results to audio downloads.

Two other command flags that are useful are `-o` and `-d`. `-d n` lets you
limit the scope of the search to episodes published in the last _n_ days. So

    poddb -d 7 libya 

will return all podcast episodes that match the query "libya" published over
the last week.

To sort the search results by most popular episodes first, use the `-o popular`
flag. So

    poddb -d 30 -o popular tiny desk concert

will show the most popular Tiny Desk Concert episodes in the last month

Invoking Poddb with no query words will show you all the most recent 
episodes from all the podcasts in the Poddb database. So to see the most
popular downloads in the last week, you can use

    poddb -d 7 -o popular



## Navigate and download podcast episodes

When you see a list of episodes, you can use the following key commands, in
addition to Vim's standard cursor commands:

* `l` or `ENTER` show episode detail
* `d` mark episode for download
* `D` start downloading episode immediately and play with `mplayer` or `PODDB_MEDIA_PLAYER` 
* `p` show all episodes for this podcast 
* `CTRL-j` show next episode
* `CTRL-k` show previous episode

If you press `p` to show all the episodes for the podcast, you can navigate back to the
previous screen with `CTRL-o` and return forward again with `CTRL-i`. In other words, 
feel free to use Vim's jump-list navigation commands. 

When you press `l` or `ENTER`, more information about the episode will appear in a split
window below the list.

If you mark episodes for downloading, Poddb will place a `*` in their left
margin and download them as soon as you quit the Vim interface with `:qa` or
some similar command.

Poddb uses `wget` to download episodes. The current version downloads all
marked episodes serially. A future version may implement parallel downloading.

Poddb downloads episodes into the current directory and saves them with
filenames that follow the format,

    {title of podcast}.{title of episode}.{poddb internal identifier}.{filetype extension}

Examples:

    Philosophy-Bites.Michael-Sandel-on-Justice.poddb_711_56523.mp3
    NPR-Tiny-Desk-Concerts-Podcast.Diego-Garcia.poddb_312_48461.m4v
    APM-Marketplace.09-14-11-Marketplace.poddb_16_55726.mp3

If you press `D`, Poddb will quit the Vim interface immediately and begin
downloading the episode that was under the cursor. After the download is complete,
Poddb will automatically start playing the episode with `mplayer`.

If you don't want to use `mplayer` or don't have it installed. You can make
Poddb launch a different media player by setting the `PODDB_MEDIA_PLAYER`
environment variable and exporting it. For example, to make Poddb use `totem`: 

    export PODDB_MEDIA_PLAYER=totem
    poddb 

Put the `export` command in your `.bash_profile` if you don't want to keep
typing it.

If you see a `D` on the left margin of an episode while you're looking at a
list of episodes, that means that you've already downloaded that episode into
the current directory.


## Bug reports and feature requests

Please submit them here:

* <https://github.com/danchoi/poddb_client/issues>


## About the app

Poddb has two parts, a client and a server. The client is a hybrid
Ruby/VimScript program packaged as a Ruby gem. The server is a Ruby
[Sinatra][sinatra] app sitting in front of a [PostgreSQL][postgres] database.
Podcast feeds are fetched with [curb][curb] and parsed with
[nokogiri][nokogiri].

[sinatra]:http://www.sinatrarb.com/
[postgres]:http://www.google.com/search?aq=f&sourceid=chrome&ie=UTF-8&q=postgresql
[curb]:http://curb.rubyforge.org/
[nokogiri]:http://nokogiri.org/


## About the developer

My name is Daniel Choi. I make software with Ruby, Rails, MySQL, PostgreSQL,
and iOS. I am based in Cambridge, Massachusetts, USA, and the little software
company I run with Hoony Youn is called [Kaja
Software](http://kajasoftware.com). 

* Company Email: info@kajasoftware.com
* Twitter: [@danchoi][twitter] 
* Personal Email: dhchoi@gmail.com  
* My Homepage: <http://danielchoi.com/software>

[twitter]:http://twitter.com/#!/danchoi


