# poddb

Poddb lets you find, track, and download podcasts from the Unix command line and Vim.

[screenshots]


## Benefits

* Search for podcasts from the command line
* Lean Vim interface to navigate, favorite, and download podcasts
* Handle podcasts directly as files; use any tool to play them


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

and all traces of Poddb will removed, except the application-specific files it
creates during execution. These files are created in a directory called `~/.poddb`.


## How to use it

Invoke `poddb` from command line interface, passing it flags and search terms.
After you press ENTER, Poddb will send the query over the internet to the poddb
server. The server will send back data, and poddb will launch Vim to let you
navigate and interact with the results.

The command line interface is as follows:

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
            --download-and-play ITEM_ID  Download item and play with PODDB_MEDIA_PLAYER
            --key-mappings               Show key mappings for Vim navigation interface
        -h, --help                       Show this message
        -v, --version                    Show version number

After you submit a query, Poddb will launch Vim to show you a list of matching
podcasts or podcast episodes. You can navigate this list with standard Vim
motion commands. You can place the cursor over a podcast episode and press
`ENTER` to view more information about it. 


## List of podcasts 

To see all the podcasts in the poddb database, type `poddb -l`. Type `poddb -l
QUERY` to see if any podcasts matching the QUERY string are in the database. If
you don't see a favorite feed of yours in the list, you can add the feed to the
Poddb database with this command:

    poddb -a PODCAST_URL

This command will also add the podcast to your favorites.

When you're viewing a list of podcasts, you can add a podcast to your favorites
by putting the cursor over it and pressing `f`. Press `f` again to remove the
podcast from your favorite podcasts.  Your favorite podcasts are stored in
`~/.poddb/favorites` as a simple list of podcast ids.

Press `ENTER` on a podcast to see its items.


## List of items 

If you see a list of items (i.e. downloadable podcast episodes), the following
key commands apply:

* `l` or `ENTER` show item detail
* `d` mark item for download
* `D` start downloading item and play with mplayer or `PODDB_MEDIA_PLAYER` 
* `p` show all items for this podcast 
* `CTRL-j` show next item
* `CTRL-k` show previous item



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




