#!/usr/bin/env bash
#
# Dependencies: aria2, jinja2-cli

usage () {
  echo "Usage: $0 -v [Unity version] -t [template to use]"
  echo "Example:"
  echo "  $0 -v 2020.3.18f1 -t unity-ios_.rb"
}

while getopts ":v:t:s:" OPTS; do
  case $OPTS in
    v)
      VERSION="$OPTARG"
      ;;
    t)
      TEMPLATE="$OPTARG"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

# Print usage and exit if we don't provide any args.
if [[ "$#" -lt 1 ]]; then
  usage
  exit 1
fi

# Make sure we specify the minimum args or exit if we don't.
if [[ -z "$VERSION" ]] || [[ -z "$TEMPLATE" ]]; then
  echo "Both -v and -t options with values are required."
  exit 1
fi

               # Scrape the HTML for the hash of the version of the package that we are interested in.
VERSION_HASH=$(curl -s https://unity3d.com/get-unity/download/archive | grep "unityhub://"$VERSION"" | \
               # Remove the text preceeding the hash string.
               sed "s%^ *<a href=\"unityhub://"$VERSION"/%%" | \
               # Remove the text following the hash string.
               sed 's%\" class=.*$%%')

echo "Version hash for Unity $VERSION is: $VERSION_HASH"

# Notice we strip the .rb suffix of $TEMPLATE.
NEWFILE="${TEMPLATE%.rb}$VERSION.rb"

# Dump our populated casks here.
mkdir newcasks

if [[ "$TEMPLATE" == 'unity_.rb' || "$TEMPLATE" == 'unity-ios_.rb' || "$TEMPLATE" == 'unity-android_.rb' ]]; then
  # These casks download a different package for each release so we calculate
  # the SHA256 sum.  Since parsing the URL is too problematic, we just
  # hard-code them here.
  case "$TEMPLATE" in
    'unity_.rb')
      DOWNLOAD_URL="https://download.unity3d.com/download_unity/$VERSION_HASH/MacEditorInstaller/Unity-$VERSION.pkg"
      ;;
    'unity-ios_.rb')
      DOWNLOAD_URL="https://netstorage.unity3d.com/unity/$VERSION_HASH/MacEditorTargetInstaller/UnitySetup-iOS-Support-for-Editor-$VERSION.pkg"
      ;;
    'unity-android_.rb')
      DOWNLOAD_URL="https://netstorage.unity3d.com/unity/$VERSION_HASH/MacEditorTargetInstaller/UnitySetup-Android-Support-for-Editor-$VERSION.pkg"
      ;;
  esac

  # The URL has the name of the archive that we are downloading at the very end
  # so we use sed to remove all of the text preceeding that.
  DOWNLOAD_ARCHIVE="$(echo $DOWNLOAD_URL | sed 's%.*/%%')"

  # Download the archive to the current dir so that we can get the correct
  # SHA256 sum.
  aria2c --max-connection-per-server=5 "$DOWNLOAD_URL"

  SHA256=$(shasum -a 256 "$DOWNLOAD_ARCHIVE" | awk '{print $1}')

  echo "SHA256 sum is: $SHA256"

  jinja2 -D package_sha="$SHA256" -D unity_version="$VERSION" -D unity_version_hash="$VERSION_HASH" templates/casks/"$TEMPLATE" -o newcasks/"$NEWFILE"
else
  # Populate the template for casks that are more static.  Most of our casks
  # are the same download for each Unity version.
  jinja2 -D unity_version="$VERSION" -D unity_version_hash="$VERSION_HASH"
  templates/casks/"$TEMPLATE" -o newcasks/"$NEWFILE"
fi
