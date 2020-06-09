#!/bin/bash

THEMEDIRECTORY=$(cd `dirname $0` && cd .. && pwd)
FIREFOXFOLDER=~/.mozilla/firefox/
PROFILENAME=""
GNOMISHEXTRAS=true

# Get options.
while getopts 'f:p:g' flag; do
	case "${flag}" in
		f) FIREFOXFOLDER="${OPTARG}" ;;
		p) PROFILENAME="${OPTARG}" ;;
		g) GNOMISHEXTRAS=true ;;
	esac
done

# Define profile folder path.
if test -z "$PROFILENAME"
	then
		PROFILEFOLDER="$FIREFOXFOLDER/*.default-release-*"
	else
		PROFILEFOLDER="$FIREFOXFOLDER/$PROFILENAME"
fi

# Enter Firefox profile folder.
cd $PROFILEFOLDER
echo "Installing theme in $PWD"

# Create a chrome directory if it doesn't exist.
echo "Removing old theme"
rm -rf chrome
echo "Creating new directory"
mkdir -p chrome
cd chrome

# Copy theme repo inside
echo "Coping repo in $PWD"
cp -rf $THEMEDIRECTORY $PWD

# Create single-line user CSS files if non-existent or empty.
[[ -s userChrome.css ]] || echo >> userChrome.css

# Import this theme at the beginning of the CSS files.
sed -i '1s/^/@import "firefox-sweet-theme\/userChrome.css";\n/' userChrome.css

# If GNOMISH extras enabled, import it in customChrome.css.
if [ "$GNOMISHEXTRAS" = true ] ; then
	echo "Enabling GNOMISH extra features"
    [[ -s customChrome.css ]] || echo >> firefox-sweet-theme/customChrome.css
	sed -i '1s/^/@import "theme\/hide-single-tab.css";\n/' firefox-sweet-theme/customChrome.css
	sed -i '2s/^/@import "theme\/matching-autocomplete-width.css";\n/' firefox-sweet-theme/customChrome.css
fi

# Symlink user.js to firefox-sweet-theme one.
echo "Set configuration user.js file"
ln -srf firefox-sweet-theme/configuration/user.js ../user.js

echo "Done."
