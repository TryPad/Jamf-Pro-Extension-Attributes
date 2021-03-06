#!/bin/bash

# Purpose: to grab iCloud Drive status.
# If Drive has been setup previously then values should be: "false" or "true"
# If Drive has NOT been setup previously then values will be: "iCloud Account Enabled, Drive Not Enabled" or "iCloud Account Disabled"

#Variable to determine major OS version
OSver="$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d . -f 2)"

#Determine OS is 10.12 or greater as Doc Sync is only available on 10.12+
if [ "$OSver" -ge "12" ]; then
	#Path to PlistBuddy
	plistBud="/usr/libexec/PlistBuddy"

	#Determine logged in user
	loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

	#Determine whether user is logged into iCloud
	if [[ -e "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" ]]; then
		iCloudStatus=$("$plistBud" -c "print :Accounts:0:LoggedIn" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist 2> /dev/null )

		#Determine whether user has enabled Drive enabled. Value should be either "false" or "true"
		if [[ "$iCloudStatus" = "true" ]]; then
			DriveStatus=$("$plistBud" -c "print :Accounts:0:Services:2:Enabled" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist 2> /dev/null )
			if [ -z "$DriveStatus" ]; then
				DriveStatus="iCloud Account Enabled, Drive Not Enabled"
			fi
		fi
		if [[ "$iCloudStatus" = "false" ]] || [[ -z "$iCloudStatus" ]]; then
			DriveStatus="iCloud Account Disabled"
		fi
	else
		DriveStatus="iCloud Account Disabled"
	fi
else
	DriveStatus="OS Not Supported"
fi

/bin/echo "<result>$DriveStatus</result>"