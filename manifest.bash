#!/bin/bash

function write_xml() {
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  echo "<ROM>"
  echo "  <RomName>$product</RomName>"
  echo "  <VersionName><![CDATA[ $version ]]></VersionName>"
  echo "  <VersionNumber type=\"integer\">"$(date +%Y%m%d)"</VersionNumber>"
  echo "  <DirectUrl>https://excellmedia.dl.sourceforge.net/project/cosmic-os/$device/${version}.zip</DirectUrl>"
  echo "  <HttpUrl>https://sourceforge.net/projects/cosmic-os/files/$device</HttpUrl>"
  echo "  <Android>$android</Android>"
  echo "  <CheckMD5>"$(md5sum $OUT/$version.zip | awk '{print $1}')"</CheckMD5>"
  echo "  <FileSize type=\"integer\">"$(stat --printf="%s" $OUT/${version}.zip)"</FileSize>"
  echo "  <Developer>$MAINTAINER</Developer>"
  echo "  <WebsiteURL nil=\"true\">cosmic-os.com</WebsiteURL>"
  echo "  <DonateURL nil=\"true\"/>"
  echo "  <Changelog>$CHANGELOG</Changelog>"
  echo "</ROM>"
}

function update_target() {
  if [ "$COS_RELEASE" == true ]; then
    mkdir -p $(gettop)/vendor/ota/changelogs
    touch changelogs/${version}.txt
    "${editor:-nano}" $(gettop)/vendor/ota/changelogs/${version}.txt

    CHANGELOG="$(cat $(gettop)/vendor/ota/changelogs/${version}.txt)"

    if [ -z "$MAINTAINER" ]; then
      echo "Who are you?"
      read MAINTAINER
      echo "Hello ${MAINTAINER}!"
    fi
    
    for var in "$@"
    do
      if [ "$var" == "-S" ]; then
        GPG_SIGN=true
      fi
    done

    version="$COS_VERSION"
    device=$(echo $version | cut -d _ -f 2)
    android=$(echo $version | cut -d _ -f 3)
    product=${version%_*}
    product=${product%_*}
    date=$(echo $version | cut -d _ -f 3 | cut -d . -f 1)
    write_xml > $product.xml
    git add -A
    if [ "$GPG_SIGN" == true ]; then
      git commit -S -m "Update $device ($date)"
    else
      git commit -m "Update $device ($date)"
    fi
    echo "Please push the commit and open a PR."
  else
    echo "Device is not official."
  fi
}