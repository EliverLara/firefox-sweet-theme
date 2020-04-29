#!/bin/bash

THEMEDIRECTORY=$(cd "$(dirname "$0")" && cd ../ && pwd)
FIREFOXFOLDER="$HOME/.mozilla/firefox"
PROFILENAME=""
GNOMISHEXTRAS=false

# Get options.
while getopts 'f:p:g' flag; do
	case "${flag}" in
	f) FIREFOXFOLDER="${OPTARG}" ;;
	p) PROFILENAME="${OPTARG}" ;;
	g) GNOMISHEXTRAS=true ;;
	*) echo "Incorrect flag used" && exit 1 ;;
	esac
done

# Define profile folder path.
if test -z "$PROFILENAME"; then
	pattern="$FIREFOXFOLDER/*.default*"

	# Tried to use mapfile and read -a, but didn't get desired results. Disabling shellcheck on this one.
	# shellcheck disable=SC2206
	files=($pattern)

	if [ -d "${files[0]}" ]; then
		PROFILEFOLDER="${files[0]}"
	else
		echo "${files[0]} detected as firefox profile, but the directory wasn't found." && exit 1
	fi
else
	if [ -d "$FIREFOXFOLDER/$PROFILENAME" ]; then
		PROFILEFOLDER="$FIREFOXFOLDER/$PROFILENAME"
	else
		echo "$FIREFOXFOLDER/$PROFILENAME was not found." && exit 1
	fi
fi

# Enter Firefox profile folder.
if cd "$PROFILEFOLDER"; then
	echo "Installing theme in $PWD"
else
	echo "We could not enter ${PROFILEFOLDER}. Exiting." && exit 1
fi

# Create a chrome directory if it doesn't exist.
mkdir -p ./chrome || {
	echo "We could not create  ./chrome. Exiting."
	exit 1
}
cd ./chrome || {
	echo "We could not enter  ./chrome. Exiting."
	exit 1
}

# Copy theme repo inside
echo "Copying files to $PWD"

# If rsync is in $PATH, we should use that to avoid copying entire git repos into our theme folder
if [ -x "$(command -v rsync)" ]; then
	rsync -aq --progress "$THEMEDIRECTORY" "$PWD" --exclude ".git"
else
	cp -R "$THEMEDIRECTORY" "$PWD"
fi

# Create single-line user CSS files if non-existent or empty.
[[ -s userChrome.css ]] || echo >>userChrome.css

# Import this theme at the beginning of the CSS files.
sed -i '1s/^/@import "firefox-sweet-theme\/userChrome.css";\n/' userChrome.css

# If GNOMISH extras enabled, import it in customChrome.css.
if [ "$GNOMISHEXTRAS" = true ]; then
	echo "Enabling GNOMISH extra features"
	[[ -s customChrome.css ]] || echo >>firefox-sweet-theme/customChrome.css
	sed -i '1s/^/@import "theme\/hide-single-tab.css";\n/' firefox-sweet-theme/customChrome.css
	sed -i '2s/^/@import "theme\/matching-autocomplete-width.css";\n/' firefox-sweet-theme/customChrome.css
fi

# Symlink user.js to firefox-sweet-theme one.
echo "Set configuration user.js file"
ln -sf ./chrome/firefox-sweet-theme/configuration/user.js ../user.js

echo "Done."
