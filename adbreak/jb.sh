#!/bin/sh
#
# AdBreak Jailbreak Script, stolen from WinterBreak
# Based on the bridge script from the 1.16.N hotfix package
# Special thanks to HackerDude, Marek, Katadelos and NiLuJe
#
##

if [ "$(id -u)" -ne 0 ]; then
  set-dynconf-value winmgr.vibrancyMode.pref.path "\$(sh $0)"
  lipc-set-prop -s com.lab126.winmgr vibrancyMode "lol"
  exit 1
fi

set-dynconf-value winmgr.vibrancyMode.pref.path ""

###
# Define logging function
###
POS=1
ab_log() {
  echo "${1}" >> /mnt/us/adbreak.log
  eips 0 $POS "${1}"
  echo "${1}"
  POS=$((POS+1))
}

###
# Helper functions
###
make_mutable() {
        local my_path="${1}"
        # NOTE: Can't do that on symlinks, hence the hoop-jumping...
        if [ -d "${my_path}" ] ; then
                find "${my_path}" -type d -exec chattr -i '{}' \;
                find "${my_path}" -type f -exec chattr -i '{}' \;
        elif [ -f "${my_path}" ] ; then
                chattr -i "${my_path}"
        fi
}

make_immutable() {
        local my_path="${1}"
        if [ -d "${my_path}" ] ; then
                find "${my_path}" -type d -exec chattr +i '{}' \;
                find "${my_path}" -type f -exec chattr +i '{}' \;
        elif [ -f "${my_path}" ] ; then
                chattr +i "${my_path}"
        fi
}


###
# Actual JB from here
###
ab_log "**** AdBreak Jailbreak ****"
ab_log "********************** 1.0.0 *"


###
# Main key install functions
###
install_touch_update_key()
{
        ab_log "install_touch_update_key - Copying the jailbreak updater key"
        make_mutable "/etc/uks/pubdevkey01.pem"
        rm -rf "/etc/uks/pubdevkey01.pem"
        cat > "/etc/uks/pubdevkey01.pem" << EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJn1jWU+xxVv/eRKfCPR9e47lP
WN2rH33z9QbfnqmCxBRLP6mMjGy6APyycQXg3nPi5fcb75alZo+Oh012HpMe9Lnp
eEgloIdm1E4LOsyrz4kttQtGRlzCErmBGt6+cAVEV86y2phOJ3mLk0Ek9UQXbIUf
rvyJnS2MKLG2cczjlQIDAQAB
-----END PUBLIC KEY-----
EOF
        # Harmonize permissions
        chown root:root "/etc/uks/pubdevkey01.pem"
        chmod 0644 "/etc/uks/pubdevkey01.pem"
        make_immutable "/etc/uks/pubdevkey01.pem"
}

install_touch_update_key_squash()
{
    ab_log "install_touch_update_key_squash - Copying the jailbreak updater keystore"
    make_mutable "/etc/uks.sqsh"
    local my_loop="$(grep ' /etc/uks ' /proc/mounts | cut -f1 -d' ')"
    umount "${my_loop}"
    losetup -d "${my_loop}"
    cp --verbose -f "/mnt/us/system/.assets/patchedUks.sqsh" "/etc/uks.sqsh"
    mount -o loop="${my_loop}",nodiratime,noatime -t squashfs "/etc/uks.sqsh" "/etc/uks"
    chown root:root "/etc/uks.sqsh"
    chmod 0644 "/etc/uks.sqsh"
    #make_immutable "/etc/uks.sqsh" # This breaks mounting on 12th gen (no, really)
}

# The real fun starts here
mntroot rw

# Check if OTA is disabled and if so enable it so hotfix can later be applied
if [ -f "/usr/bin/otaupd.bck" ] ; then
  mv /usr/bin/otaupd.bck /usr/bin/otaupd
  ab_log "otaupd restored"
fi

if [ -f "/usr/bin/otav3.bck" ] ; then
  mv /usr/bin/otav3.bck /usr/bin/otav3
  ab_log "otav3 restored"
fi

# Install update key in folder
install_touch_update_key
# Verify key installation
if [ -f "/etc/uks/pubdevkey01.pem" ] ; then
ab_log "Developer keys installed successfully (Standard Method)! (pubdevkey01.pem)"
else
  ab_log "ERR - Could not install pubdevkey01.pem (Standard Method)"
fi

# Check if we need to do something with the OTA SQSH keystore
if [ -f "/etc/uks.sqsh" ] && [ -f "/mnt/us/system/.assets/patchedUks.sqsh" ] ; then
  install_touch_update_key_squash

  # Verify key installation
  if [ "$(md5sum "${ROOT}/etc/uks.sqsh" | awk '{ print $1; }')" ==  "$(md5sum "${ROOT}/mnt/us/system/.assets/patchedUks.sqsh" | awk '{ print $1; }')" ] ; then
    ab_log "Developer keys installed successfully! (uks.sqsh)"
    ab_log "$(ls /etc/uks)"
  else
    ab_log "ERR - Could not install uks.sqsh"
    ab_log "$(whoami)"
    ab_log "$(md5sum "/mnt/us/system/.assets/patchedUks.sqsh" | awk '{ print $1; }')"
    ab_log "$(md5sum "/etc/uks.sqsh" | awk '{ print $1; }')"
    ab_log "$(md5sum "${ROOT}/etc/uks.sqsh" | awk '{ print $1; }')"
  fi
fi

# Make sure we can use UYK for OTA packages on FW >= 5.12.x
make_mutable "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC"
rm -rf "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC"
touch "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC"
make_immutable "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC"

if [ -f "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC" ] ; then
    ab_log "Enabled developer flag"
else
    ab_log "Developer flag install FAIL"
fi


touch "/MNTUS_EXEC"
make_immutable "/MNTUS_EXEC"

if [ -f "/MNTUS_EXEC" ] ; then
    ab_log "Enabled mntus exec flag"
else
    ab_log "mntus exec flag install FAIL"
fi

# Bye
mntroot ro

ab_log "                                      "
ab_log "**************************************"
ab_log "*** Finished installing jailbreak! ***"
ab_log "***                                ***"
ab_log "***   Please Install HOTFIX now    ***"
ab_log "**************************************"
ab_log "                                      "
ab_log "                                      "
