# My .emacs File

Official Repository: https://github.com/richmit/emacs-config

## Introduction

My Emacs configuration file (i.e. my "`.emacs` or "`init.el`" file).
I've put this on GitHub because seeing how I configure the options for
the Emacs packages I have published helps people get up to speed.

## Package Configuration Examples

I expect most people who find themselves here are looking for insight
regarding how I configure the various Emacs packages I have published:

 - `el-vergo`                 (https://github.com/richmit/el-vergo)
 - `mjr-apply-dired-magic`    (https://github.com/richmit/mjr-apply-dired-magic)
 - `mjr-buffer-directory`     (https://github.com/richmit/mjr-buffer-directory)
 - `mjr-code-tools`           (https://github.com/richmit/mjr-code-tools)
 - `mjr-compile`              (https://github.com/richmit/mjr-compile)
 - `mjr-embedded-debug`       (https://github.com/richmit/mjr-embedded-debug)
 - `mjr-eval`                 (https://github.com/richmit/mjr-eval)
 - `mjr-flow`                 (https://github.com/richmit/mjr-flow)
 - `mjr-misc-emacs-goodies`   (https://github.com/richmit/mjr-misc-emacs-goodies)
 - `mjr-numbers-in-column`    (https://github.com/richmit/mjr-numbers-in-column)
 - `mjr-preview`              (https://github.com/richmit/mjr-preview)
 - `mjr-show-buffer`          (https://github.com/richmit/mjr-show-buffer)
 - `mjr-thingy-lookeruper`    (https://github.com/richmit/mjr-thingy-lookeruper)
 - `mjr-zotero`               (https://github.com/richmit/mjr-zotero)
 - `mrscpi-in-emacs`          (https://github.com/richmit/mrscpi-in-emacs)
 
On that front look near the end of the `init.el` file for lines like
        (mjr-dotfile-message "PKG SETUP: NAME-OF-PACKAGE")
or
        (with-eval-after-load "NAME-OF-PACKAGE"

## Installing This Config

The parts of my Emacs config that are suitable for public consumption
have been broken out into packages (listed above).  What is left in my
`init.el` file is very specific to my particular way of working and
the computing environments I use.  An Emacs configuration is a very
personal thing.  I can't imagine anyone pulling this configuration
down and using it wholesale.  Seriously.  It's a bad idea.  Just
don't...

That said, here is how I would bootstrap a new Emacs config:

 - Put the files in place

git clone https://github.com/richmit/dot-emacs
           cd dot-emacs
           test -e ~/.emacs.d || mkdir ~/.emacs.d
           cp dot-emacs/init.el ~/.emacs.d/init.el
           cp dot-emacs/alias ~/.emacs.d/alias

 - Start up Emacs

 - Let it install anything it asks about

 - Restart Emacs
