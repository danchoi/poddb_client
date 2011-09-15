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

Invoke Poddb from command line interface, passing it flags and search terms.
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

After you submit a query, Poddb will either show you a list of podcasts, or a
list of matching podcast epidoes.




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




