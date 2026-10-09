#!/usr/bin/env -S sh
# -*- Mode:Shell-script; Coding:us-ascii-unix; fill-column:158 -*-
#########################################################################################################################################################.H.S.##
##
# @file      update.sh
# @author    Mitch Richling https://www.mitchr.me/
# @brief     Update files in this repository from master dot file repository.@EOL
# @std       sh
# @see       https://github.com/richmit/dot-emacs
# @copyright 
#  @parblock
#  Copyright (c) 2026, Mitchell Jay Richling <https://www.mitchr.me/> All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice, this list of conditions, and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions, and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#  
#  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software
#     without specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
#  DAMAGE.
#  @endparblock
#########################################################################################################################################################.H.E.##

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
SRC_DIR='/c/msys64/home/richmit/world/dotfiles/.emacs.d'
DAFILES='init.el alias'

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
if [ ! -e update.sh ]; then
  echo 'ERROR: Script must be run from base of dot-emacs git repo'
  exit
fi

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
I_FEEL_DIRTY=''
for f in $DAFILES; do
  sf="${SRC_DIR}/${f}--SS-X-X-X-X"
  if [ -e $sf ]; then
    df=$f
    if [ $sf -nt $df ]; then
      I_FEEL_DIRTY='YES'
      echo "update.sh: INFO: COPY TIME $df"
      cp $sf $df
    elif ! diff -q $sf $df >/dev/null; then
      I_FEEL_DIRTY='YES'
      echo "update.sh: INFO: COPY DIFF $df"
      cp $sf $df
    fi
  else
    echo "update.sh: ERROR: Coulud not find source file: $sf"
  fi
done


if [ -z "${I_FEEL_DIRTY}" ]; then
  echo "update.sh: INFO: No updates required"
else
  echo "update.sh: INFO: Recommend doing a git commit & push:"
  echo "   git commit -am 'Automatic Update'"
  echo "   git push"
fi
