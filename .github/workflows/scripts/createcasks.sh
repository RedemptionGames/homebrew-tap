#!/usr/bin/env bash
#
# Dependencies: aria2, brew, jinja2-cli, gron

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

# Notice we strip the .rb suffix of $TEMPLATE.
NEWFILE="${TEMPLATE%.rb}$VERSION.rb"

jinja2 -D unity_version="$VERSION" -D unity_version_hash="$VERSION_HASH" templates/casks/"$TEMPLATE" -o Casks/"$NEWFILE"

# We need to calculate the SHA256 sum for some casks.
if [[ "$TEMPLATE" == 'unity_.rb' || "$TEMPLATE" == 'unity-ios_.rb' || "$TEMPLATE" == 'unity-android_.rb' ]]; then
  # Get the entire URL used for download from the 'brew' command.  We use brew
  # for this because it will parse our cask that we just created and can output
  # in JSON.
  DOWNLOAD_URL="$(brew info --json=v2 --cask Casks/$NEWFILE | \
                  # gron is used to make JSON grep-able.
                  gron | \
                  # Find the URL for the archive.
                  grep 'json.casks.*.url' | \
                  # Remove the text preceeding the URL string that we want.
                  sed 's%^.* = \"%%' | \
                  # Remove the text following the URL string that we want.
                  sed 's%\";$%%')"
  # The URL has the name of the archive that we are downloading at the very end
  # so we use sed to remove all of the text preceeding that.
  DOWNLOAD_ARCHIVE="$(echo $DOWNLOAD_URL | sed 's%.*/%%')"

  # Download the archive to the current dir so that we can get the correct
  # SHA256 sum.
  aria2c --max-connection-per-server=5 "$DOWNLOAD_URL"

  SHA256=$(shasum -a 256 "$DOWNLOAD_ARCHIVE" | awk '{print $1}')

  jinja2 -D package_sha="$SHA256" -D unity_version="$VERSION" -D unity_version_hash="$VERSION_HASH" templates/casks/"$TEMPLATE" -o Casks/"$NEWFILE"
fi
