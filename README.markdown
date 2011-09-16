# poddb

Poddb lets you find, track, and download podcasts from the Unix command line
and Vim.

[screenshots]


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

    gem install poddb_client

Test your installation by typing `poddb -h`. You should see poddb's help.

On some systems you may run into a PATH issue, where the system can't find the
`poddb` command after installation. You might want to try 

    sudo gem install poddb

to see if that puts `poddb` on your PATH.

If you ever want to uninstall Poddb from your system, just execute this command:

    gem uninstall poddb

This will remove all traces of Poddb, except for the application-specific files
it creates in a directory called `~/.poddb`. These you'll have to remove
manually.


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

        -f, --from-favorites             Show all recent items from favorite podcasts
        -a, --add PODCAST_URL            Add podcast with PODCAST_URL to the poddb database
        -l, --list [QUERY]               List all podcasts in the poddb database
                                         (If QUERY is supplied, will return matching podcasts)
        -F, --favorite-podcasts          Show favorite podcasts
        -o, --order ORDER                Sort results by ORDER
                                         The only option right now is 'popular'. Default order is pubdate.
        -d, --days DAYS                  Limit results to items published since DAYS days ago
        -t, --type MEDIA_TYPE            Return items of MEDIA_TYPE only (audio,video)

## Browse and search podcasts

To see all the podcasts in the poddb database:

    poddb -l
    
Type `poddb -l QUERY` to see if any podcasts matching the QUERY string are in
the database. E.g.

    poddb -l music 

will return all the podcasts in the Poddb database with the word "music" in the
title or podcast description.

Press `ENTER` on a podcast to see its items (i.e. episodes).  See **Podcast
items** below for instruction on how to view and download items.


## Add podcasts to the database

If you don't see a favorite feed of yours in the list returned by `poddb -l`,
you can add the feed to the Poddb database with this command:

    poddb -a PODCAST_URL

E.g.,

    poddb -a http://www.philosophybites.libsyn.com/rss

The `-a` command will also add the podcast to your favorites.


## Favorite podcasts

When viewing a list of podcasts returned by `poddb -l`, you can add a podcast
to your favorites by putting the cursor over it and pressing `f`. Press `f`
again to remove the podcast from your favorite podcasts.  Favorite podcasts
have a `@` sign in the left margin.

Once you have a few favorite podcasts, you can list and navigate them with
the command

    poddb -F

You can also aggregate all the most recent items from your favorite items by
launching Poddb with the command

    poddb -f

Your favorite podcasts are stored in `~/.poddb/favorites` as a simple list of
podcast ids. The ids are internal to Poddb's PostgreSQL database.


## Podcast items

When you see a list of items (i.e. podcast episodes), you can use the following
key commands, in addition to Vim's standard cursor commands:

* `l` or `ENTER` show item detail
* `d` mark item for download
* `D` start downloading item and play with mplayer or `PODDB_MEDIA_PLAYER` 
* `p` show all items for this podcast 
* `CTRL-j` show next item
* `CTRL-k` show previous item

If you press `p` to show all the items for the podcast, you can navigate back to the
previous screen with `CTRL-o` and return forward again with `CTRL-i`. In other words, 
feel free to use Vim's jump-list navigation commands. 

When you press `l` or `ENTER`, more information about the item will appear in a split
window below the list.

If you mark items for downloading, Poddb will download them as soon as you quit
the Vim interface with `:qa` or some similar command.

If you press `D`, Poddb will quit the Vim interface immediately and begin
downloading the item that was under the cursor. After the download is complete,
Poddb will automatically start playing the item with `mplayer` or whatever
command you specify using the `PODDB_MEDIA_PLAYER` environment variable.

When you're looking at an item list, if you see a `D` on the left margin of an
item, that means that you've already downloaded that podcast item into the
current directory.

Poddb uses `wget` to download items.


## Bug reports and feature requests

Please submit them here:

* <https://github.com/danchoi/poddb_client/issues>


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




