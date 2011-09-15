# poddb

Poddb lets you find, track, and download podcasts from the Unix command line and Vim.

[screenshots]

Benefites

## Prerequisites

* Vim (7.2 or later)
* Ruby 1.9 
* wget
* curl
* mplayer or another media player

To install Ruby 1.9.2, I recommend using the [RVM Version Manager][rvm].

[rvm]:http://rvm.beginrescueend.com

poddb assumes a Unix (POSIX) environment.


## Installation

    gem install poddb_client

Test your installation by typing `poddb -h`. You should see poddb's help.

On some systems you may run into a PATH issue, where the system can't find the
`poddb` command after installation. You might want to try 

    sudo gem install vmail

to see if that puts `poddb` on your PATH.

If you ever want to uninstall poddb from your system, just execute this command:

    gem uninstall poddb

and all traces of poddb will removed, except the application-specific files it
creates during execution. These files are created in a directory called `~/.poddb`.


## Bug reports and feature requests

Please submit these at either of these places:

* <https://github.com/danchoi/poddb_client/issues>
* <http://groups.google.com/group/poddb-users>


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




