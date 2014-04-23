#!/bin/sh

#
#  OpenTVOnDemand
#
#  Copyright (c) 2014 Cai, Zhi-Wei. All rights reserved.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#--------------------  Configurations  --------------------

# OS Setting. [Darwin/Linux/CYGWIN_NT-5.1]
# Currently, only Mac OS X(Darwin) and Lunix are supported.
# Default(Auto detect): "$(uname -s)"
readonly CONST_OS="$(uname -s)"

# Debug Mode. [0|1]
# If 1 and Debug Output Path is not empty, func_log will output to debug output path.
# Default: 0
readonly CONST_DEBUG_MODE=0

# Debug Output Path. (Absolute Path Only.)
# If Debug Mode is 1 and this is not empty, func_log will output to debug output path.
readonly CONST_DEBUG_PATH="${HOME}/OpenTVOnDemand.log"

# Server Mode. [0|1]
# Server will upload files to FTP instead of asking for playback.
# Default: 0
readonly CONST_IS_SERVER=0

# FTP setting.
# FTP server used in Server Mode.
readonly CONST_REMOTE_FTP_HOST="my.host.com"
readonly CONST_REMOTE_FTP_PORT="21"
readonly CONST_REMOTE_FTP_USER="user"
readonly CONST_REMOTE_FTP_PASS="password"
readonly CONST_REMOTE_FTP_PATH="/"

# VPN Name.
# For Darwin only. The VPN connection names to use to bypass the geo lockdown.
readonly CONST_VPN_NAME_US="My VPN Connection - US"
readonly CONST_VPN_NAME_GB="My VPN Connection - UK"
readonly CONST_VPN_NAME_CA="My VPN Connection - CA"
readonly CONST_VPN_NAME_AU="My VPN Connection - AU"

# HTTP Proxy Sever.
# e.g. 1.2.3.4:3128. Leave Blank to ignore.
# Default: 
readonly CONST_PROXY=

# Search Results.
# The max number of results to display in search. Greater the number will significantly increase the loading time.
# Default: 8
readonly CONST_SEARCH_MAX=8

# CURL Threads Per Session.
# The max number of threads CURL uses when catupring streams. > 10 might cause problem.
# Default: 5
readonly CONST_FETCH_THREADS=5

# Working Path. (Without Ending Slash!)
# Temp storing location path.
# Default: "/tmp"
readonly CONST_WORK_PATH="/tmp"

# Download Path. (Without Ending Slash!)
# Location for sucessful downloads.
# Default: "${HOME}/Movies"
readonly CONST_STORE_PATH="${HOME}/Movies"

# User-Agent.
# Use only in some cases.
# Default: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36"
readonly CONST_CURL_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36"


#--------------------  Configurations  --------------------

# DO NOT TOUCH ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!!!
# DO NOT TOUCH ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!!!
# DO NOT TOUCH ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!!!
# DO NOT TOUCH ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!!!
# DO NOT TOUCH ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!!!

#--------------------      Consts      --------------------

# Job control.
set -m

# Window Size.
readonly originalColumns=$(tput cols)
readonly originalLines=$(tput lines)
printf "\033[8;40;120t"

# Timezone.
readonly timezone=$(date +%Z)

if [ "${CONST_OS}" == "Darwin" ]; then
	readonly CONST_DATE_BIN="gdate" # OS X
else
	readonly CONST_DATE_BIN="date" # Linux
fi

# Colors.
readonly COLOR_NONE="\033[m"
readonly COLOR_RED="\033[0;32;31m"
readonly COLOR_LIGHT_RED="\033[1;31m"
readonly COLOR_GREEN="\033[0;32;32m"
readonly COLOR_LIGHT_GREEN="\033[1;32m"
readonly COLOR_BLUE="\033[0;32;34m"
readonly COLOR_LIGHT_BLUE="\033[1;34m"
readonly COLOR_DARY_GRAY="\033[1;30m"
readonly COLOR_CYAN="\033[0;36m"
readonly COLOR_LIGHT_CYAN="\033[1;36m"
readonly COLOR_PURPLE="\033[0;35m"
readonly COLOR_LIGHT_PURPLE="\033[1;35m"
readonly COLOR_BROWN="\033[0;33m"
readonly COLOR_YELLOW="\033[1;33m"
readonly COLOR_LIGHT_GRAY="\033[0;37m"
readonly COLOR_WHITE="\033[1;37m"
readonly COLOR_BG_RED="\033[41m"
readonly COLOR_BG_DARY_GRAY="\033[40m"
readonly COLOR_BG_LIGHT_CYAN="\033[46m"
readonly COLOR_BG_LIGHT_PURPLE="\033[1;45m"
readonly CURSOR_HIDE="\033[?25l"
readonly CURSOR_SHOW="\033[?25h"
readonly TEXT_BLINK="\033[5m"
readonly TEXT_UNDERLINE="\033[4m"
readonly TEXT_HIGHLIGHT="\033[1m"

readonly TEXT_PADDING='                              '
readonly TABS="\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t"
readonly BACKSPACES="\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"

# Consts.
appversion="v0.1"
appname="OpenTVOnDemand"
applogo="
${TABS:0:$((6*2))}${COLOR_LIGHT_RED}                                              
${TABS:0:$((6*2))} ${COLOR_DARY_GRAY}|${COLOR_LIGHT_RED}\_/${COLOR_DARY_GRAY}|,,${COLOR_LIGHT_RED}___${COLOR_BROWN}__,${COLOR_BROWN}~${COLOR_WHITE}~${COLOR_DARY_GRAY}\`${COLOR_LIGHT_RED}               
${TABS:0:$((6*2))} (${TEXT_BLINK}${COLOR_LIGHT_BLUE}.${COLOR_NONE}${COLOR_DARY_GRAY}\"${TEXT_BLINK}${COLOR_LIGHT_BLUE}.${COLOR_NONE}${COLOR_LIGHT_RED})${COLOR_DARY_GRAY}~~${COLOR_LIGHT_RED}     ${COLOR_BROWN})${COLOR_LIGHT_RED}\`${COLOR_BROWN}~${COLOR_WHITE}}${COLOR_DARY_GRAY}}${COLOR_LIGHT_RED}              
${TABS:0:$((6*2))}  ${COLOR_DARY_GRAY}\./${COLOR_LIGHT_RED}\ /${COLOR_WHITE}--${COLOR_BROWN}-${COLOR_DARY_GRAY}~${COLOR_LIGHT_RED}\\\ ${COLOR_BROWN}~${COLOR_WHITE}}${COLOR_DARY_GRAY}}${COLOR_LIGHT_RED}               
${TABS:0:$((6*2))}    ${COLOR_WHITE}_${COLOR_BROWN}//    ${COLOR_WHITE}_${COLOR_BROWN}// ${COLOR_WHITE}~${COLOR_DARY_GRAY}}${COLOR_LIGHT_RED}               
${TABS:0:$((6*2))}                                ${COLOR_NONE}"
banner="$applogo\n${TABS:0:$((5*2))}     [${COLOR_BG_RED} $appname - $appversion ${COLOR_NONE}]\n"

function func_uuidgen () {
	uuid=$(uuidgen | rev | cut -f 1 -d "-" | tr [:upper:] [:lower:])
}

function func_log () {
	if [[ "${CONST_DEBUG_MODE}" -eq 1 ]] && [[ "${#CONST_DEBUG_PATH}" -gt 0 ]]; then
		touch "${CONST_DEBUG_PATH}" 2>/dev/null
		echo "[$($CONST_DATE_BIN +"%Y-%m-%d %I:%M %p")] $1"  | cat - "${CONST_DEBUG_PATH}" > temp && mv temp "${CONST_DEBUG_PATH}" 2>/dev/null
	fi
}

function func_notification () {
	if [ "${CONST_OS}" == "Darwin" ]; then
		local sound=
		if [[ "$3" -eq 1 ]]; then
			sound="-sound default"
		fi
		terminal-notifier -group "tvondemand-notification-$uuid" -title "${appname}" -subtitle "$2" -message "$1" -activate 'com.apple.Terminal' -sender 'com.apple.Terminal' $sound >/dev/null 2>&1
	fi
}

function func_depandency () {
	printf "\n${TABS:0:$((4*2))}${COLOR_RED}* Checking depandency...${COLOR_NONE}\n\n"
	local allfine=0
	while [[ "$allfine" -ne 1 ]]; do
		func_banner
		printf "\n"
		if [ "${CONST_OS}" == "Darwin" ] && [ "$(which brew)" == "" ]; then
			printf "${TABS:0:$((4*2))}${COLOR_RED}* Installing \"Homebrew\"...${COLOR_NONE}\n\n"
			ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
			brew doctor
		elif [ "${CONST_OS}" == "Darwin" ] && [ "$(which gdate)" == "" ]; then
			printf "${TABS:0:$((4*2))}${COLOR_RED}* Installing \"GNU Core Utilities\"...${COLOR_NONE}\n\n"
			brew install coreutils
		elif [ "$(which rtmpdump)" == "" ]; then
			printf "${TABS:0:$((4*2))}${COLOR_RED}* Installing \"RTMPDump\"...${COLOR_NONE}\n\n"
			if [ "${CONST_OS}" == "Darwin" ]; then
				brew install rtmpdump
			else
				sudo apt-get install rtmpdump
			fi
		elif [ "$(which ffmpeg)" == "" ]; then
			printf "${TABS:0:$((4*2))}${COLOR_RED}* Installing \"FFmpeg\"...${COLOR_NONE}\n\n"
			if [ "${CONST_OS}" == "Darwin" ]; then
				brew install ffmpeg
			else
				sudo apt-get install ffmpeg
			fi
		elif [ "$(which parallel)" == "" ]; then
			printf "${TABS:0:$((4*2))}${COLOR_RED}* Installing \"GNU parallel\"...${COLOR_NONE}\n\n"
			if [ "${CONST_OS}" == "Darwin" ]; then
				brew install parallel
			else
				sudo apt-get install parallel
			fi
		elif [ "$(which jsawk)" == "" ]; then
			printf "${TABS:0:$((4*2))}${COLOR_RED}* Installing \"jsawk\"...${COLOR_NONE}\n\n"
			if [ "${CONST_OS}" == "Darwin" ]; then
				brew reinstall readline --force
				brew install jsawk
			else
				wget http://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz
				tar -zxvf js-1.7.0.tar.gz
				cd js/src
				make BUILD_OPT=1 -f Makefile.ref
				make BUILD_OPT=1 JS_DIST=/usr/local -f Makefile.ref export
				cd ..
				cd ..
				rm -rf js
				curl -L http://github.com/micha/jsawk/raw/master/jsawk > jsawk
				chmod 755 jsawk
				mv jsawk /usr/local/bin/
			fi
		elif [ "${CONST_OS}" == "Darwin" ] && [ "$(which terminal-notifier)" == "" ]; then
			if [ ! -f "/Applications/Xcode.app" ]; then
				printf "${TABS:0:$((4*2))}${COLOR_RED}* Terminal-Notifier requires Xcode in order to build.\n\n${TABS:0:$((4*2))}  However it's not a must if you don't want the notification feature.${COLOR_NONE}"
				sleep 3
				allfine=1
			else
				printf "${TABS:0:$((4*2))}${COLOR_RED}* Installing \"Terminal-Notifier\"...${COLOR_NONE}\n\n"
				brew install terminal-notifier	
			fi
		else
			allfine=1
		fi
	done
}

function func_theplatform_sig () {
	local t=$(($($CONST_DATE_BIN +"%s") + 600))
	local u=$(printf "$1" | xxd -ps)
	local h=$(printf "00%0.2x%s" "$t" "$u" | perl -pe 's/([0-9a-f]{2})/chr hex $1/gie' | openssl dgst -sha1 -hmac "$2")
	local s=$(printf "$3" | xxd -ps)
	sig=$(printf "00%0.2x%s%s" "$t" "$h" "$s")
}

function func_initiate () {
	CURRENT_DIR=$(pwd)
	WORKING_DIR="${CONST_WORK_PATH}/_tvr_$uuid"
	mkdir "${WORKING_DIR}"
	cd "${WORKING_DIR}"
	base64 -D > "_t_$uuid" <<-_DECRYPT
	IyBVc2FnZTogcHl0aG9uIHR0MnNydC5weSBzb3VyY2UueG1sIG91dHB1dC5zcnQKCmZyb20geG1sLmRvbS5taW5pZG9tIGltcG9ydCBwYXJzZQppbXBvcnQgc3lzCmk9MQpkb20gPSBwYXJzZShzeXMuYXJndlsxXSkKb3V0ID0gb3BlbihzeXMuYXJndlsyXSwgJ3cnKQpib2R5ID0gZG9tLmdldEVsZW1lbnRzQnlUYWdOYW1lKCJib2R5IilbMF0KcGFyYXMgPSBib2R5LmdldEVsZW1lbnRzQnlUYWdOYW1lKCJwIikKZm9yIHBhcmEgaW4gcGFyYXM6CiAgICBvdXQud3JpdGUoc3RyKGkpICsgIlxuIikKICAgIG91dC53cml0ZShwYXJhLmF0dHJpYnV0ZXNbJ2JlZ2luJ10udmFsdWUucmVwbGFjZSgnLicsJywnKSArICcgLS0+ICcgKyBwYXJhLmF0dHJpYnV0ZXNbJ2VuZCddLnZhbHVlLnJlcGxhY2UoJy4nLCcsJykgKyAiXG4iKQogICAgZm9yIGNoaWxkIGluIHBhcmEuY2hpbGROb2RlczoKICAgICAgICBpZiBjaGlsZC5ub2RlTmFtZSA9PSAnYnInOgogICAgICAgICAgICBvdXQud3JpdGUoIlxuIikKICAgICAgICBlbGlmIGNoaWxkLm5vZGVOYW1lID09ICcjdGV4dCc6CiAgICAgICAgICAgIG91dC53cml0ZSh1bmljb2RlKGNoaWxkLmRhdGEpLmVuY29kZSgndXRmPTgnKSkKICAgIG91dC53cml0ZSgiXG5cbiIpCiAgICBpICs9IDE=
	_DECRYPT
	mode=
	drmMode=
	pid=
	lastpid=
	quitsession=
	filenameOrig=
	filename=
	searchDone=
	VAR_BANDWIDTH=
	VAR_SIZE_PREDICT=
	VAR_KEY_SIZE=
	VAR_KEY_HEX=
	VAR_M3U_SIZE=
	VAR_SUB_SIZE=
	VAR_CLIPS=
	VAR_FOLDER_SERIES=
	VAR_FOLDER_SEASON=
}

function func_clear_input () {
	while read -t 0 notused; do
	   read input
	   echo "ignoring $input"
	done
}

function func_null_input () {
	local notused=
	read notused
}

function func_clear_line () {
	printf "\r${TEXT_PADDING}${TEXT_PADDING}${TEXT_PADDING}${TEXT_PADDING}${TEXT_PADDING}"
}

function func_copyright () {
	printf "\n${TABS:0:$((5*2))}${COLOR_LIGHT_BLUE}© 2013 Cai. All Rights Reserved.${COLOR_NONE}"
	sleep .1
}

function func_mode () {
	if [[ "${#mode}" -gt 0 ]]; then
		local info=
		local filename_disp=
		local working_pid_disp=
		if [ "$filenameOrig" != "" ]; then
			if [[ "${#filenameOrig}" -gt 23 ]]; then
				filename_disp=$(printf "%s..." "${filenameOrig:0:20}")
			else
				filename_disp=$filenameOrig
			fi
			info="\r${TABS:0:$((5*2))}* Fetching File:       ${COLOR_LIGHT_BLUE}$filename_disp${COLOR_NONE}\n"
		elif [ "$pid" != "" ]; then
			if [[ "${#pid}" -gt 23 ]]; then
				working_pid_disp=$(printf "%s...%s" "${pid:0:17}" "${pid:0:20}")
			else
				working_pid_disp=$pid
			fi
			info="\r${TABS:0:$((5*2))}* Working URL/PID:     ${COLOR_RED}$working_pid_disp${COLOR_NONE}\n"
		fi
		printf "\r${TABS:0:$((5*2))}* Channel:             ${COLOR_LIGHT_BLUE}$mode${COLOR_NONE} ${COLOR_DARY_GRAY}($drmMode)${COLOR_NONE}\n$info"
	fi
}

function func_banner () {
	clear
	printf "$banner\n"
	printf "${TABS:0:$((5*2))}* Operating System:    ${COLOR_LIGHT_BLUE}${CONST_OS}${COLOR_NONE}\n"
	func_mode
	local uuid_disp="-"
	if [[ "${#uuid}" -gt 0 ]]; then
		uuid_disp=$uuid
	fi
	printf "\r${TABS:0:$((5*2))}* Session UUID:        ${COLOR_LIGHT_BLUE}$uuid_disp${COLOR_NONE}\n"
}

function func_cursor_switch () {
	if [[ $1 -ne 0 ]]; then
		printf "${CURSOR_SHOW}"
	else
		printf "${CURSOR_HIDE}${COLOR_NONE}"
	fi
}

function func_size () {
	if [ "${CONST_OS}" == "Darwin" ]; then
		echo "$(stat -f%z "$1")"
	else
		echo "$(stat --format="%s" "$1")"
	fi
}

function func_search_string () {
	local regex=$(printf "(%q)([^%q]+)(%q)" "$2" "$3" "$3")
	shopt -s nocasematch ; [[ $1 =~ $regex ]] ; echo "${BASH_REMATCH[2]}"
}

function func_json_parser () {
	echo "$1" | jsawk "return this.$2" 2>/dev/null
}

function func_urlencode() {
    local length="${#1}"
    for (( i = 0 ; i < length ; i++ )); do
        local c="${1:i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf + ;;
            *) printf '%%%X' "'$c"
        esac
    done
}
 
function func_urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\x}"
}

function func_field_gen () {
	printf "${COLOR_NONE}${COLOR_BG_DARY_GRAY}${TEXT_PADDING:0:$1}${COLOR_NONE}${COLOR_DARY_GRAY}  $2${COLOR_NONE}${COLOR_BG_DARY_GRAY}${BACKSPACES:0:$((($1+${#2}+2)*2))}"
}

function func_air_date () {
	local airtimestamp=
	if [[ $1 -eq 0 ]]; then
		airtimestamp=$($CONST_DATE_BIN --date "$2" +"%s")
	else
		airtimestamp=${2:0:10}
	fi
	local airdatestring=$($CONST_DATE_BIN --date "@$airtimestamp" +"%Y-%m-%d %I:%M %p")
	local daysAgo=$(TZ="$timezone" $CONST_DATE_BIN +"%s")
	local daysAgo=$(( ( $daysAgo - $airtimestamp )/86400 ))
	local days_disp=
	local color_disp=${COLOR_LIGHT_BLUE}
	if [[ "$daysAgo" -eq -1 ]]; then
		days_disp="Tomorrow"
		color_disp=${COLOR_LIGHT_GREEN}
	elif [[ "$daysAgo" -lt 0 ]]; then
		days_disp="In ${daysAgo#-} days"
		color_disp=${COLOR_RED}
	elif [[ "$daysAgo" -eq 1 ]]; then
		days_disp="Yesterday"
		color_disp=${COLOR_YELLOW}
	elif [[ "$daysAgo" -eq 0 ]]; then
		days_disp="Today"
		color_disp=${COLOR_YELLOW}
	elif [[ "$daysAgo" -lt 7 ]]; then
		days_disp="This Week"
		color_disp=${COLOR_PURPLE}
	else
		days_disp="$daysAgo days ago"
	fi
	printf "$color_disp$airdatestring${COLOR_NONE} ${COLOR_DARY_GRAY}$days_disp${COLOR_NONE}\n"
}

function func_vpn_connect () {
	bncMode=
	local vpn_name=
	case "$geoReq" in
		AU ) vpn_name=$CONST_VPN_NAME_AU ;;
		CA ) vpn_name=$CONST_VPN_NAME_CA ;;
		US ) vpn_name=$CONST_VPN_NAME_US ;;
		GB ) vpn_name=$CONST_VPN_NAME_GB ;;
	esac
	if [ "$country" != "$geoReq" ] && [ "$CONST_PROXY" != "" ]; then
		proxy="-x \"http://${CONST_PROXY}\""
		bncMode="Proxy: ${CONST_PROXY}"
		func_geo_ip
	elif [ "$country" != "$geoReq" ]; then
		printf "\r\n${COLOR_RED}${TABS:0:$((4*2))} >> Connecting to VPN...${COLOR_NONE}"
		func_vpn_connect_core >/dev/null 2>&1
		bncMode="VPN: $vpn_name"
		func_geo_ip
	else
		return
	fi
}

function func_vpn_disconnect () {
	func_vpn_disconnect_core >/dev/null 2>&1
	func_geo_ip
}

function func_vpn_connect_core () {
	local vpn_name=
	case "$geoReq" in
		AU ) vpn_name=$CONST_VPN_NAME_AU ;;
		CA ) vpn_name=$CONST_VPN_NAME_CA ;;
		US ) vpn_name=$CONST_VPN_NAME_US ;;
		GB ) vpn_name=$CONST_VPN_NAME_GB ;;
	esac
	if [ "${CONST_OS}" == "Darwin" ]; then
		/usr/bin/env osascript <<-EOF
		tell application "System Events"
		        tell current location of network preferences
		                set VPN to service "$vpn_name" -- your VPN name here
		                if exists VPN then connect VPN
		                repeat while (current configuration of VPN is not connected)
		                    delay 1
		                end repeat
		        end tell
		end tell
		EOF
	else
		nmcli con up id "$vpn_name" >/dev/null 2>&1
	fi
	sleep 1
}

function func_vpn_disconnect_core () {
	local vpn_name=
	case "$geoReq" in
		AU ) vpn_name=$CONST_VPN_NAME_AU ;;
		CA ) vpn_name=$CONST_VPN_NAME_CA ;;
		US ) vpn_name=$CONST_VPN_NAME_US ;;
		GB ) vpn_name=$CONST_VPN_NAME_GB ;;
	esac
	if [ "${CONST_OS}" == "Darwin" ]; then
		/usr/bin/env osascript <<-EOF
		tell application "System Events"
		        tell current location of network preferences
		                set VPN to service "$vpn_name" -- your VPN name here
		                if exists VPN then disconnect VPN
		        end tell
		end tell
		EOF
	else
		nmcli con up down "$vpn_name" >/dev/null 2>&1
	fi
	sleep 1
}

function func_geo_ip () {
	country="$(curl -sL $proxy "http://video.nbcuni.com/geoCountry.xml" | tr "<>" "\n" | sed '5q;d')"
}

function func_geo_show () {
	local color=
	local bnc_disp=
	if [ "$country" != "$geoReq" ]; then
		color="${COLOR_RED}"
		if [[ "${#bncMode}" -gt 0 ]]; then
			if [[ "${#bncMode}" -gt 18 ]]; then
				bnc_disp=$(printf "(%s...%s)" "${bncMode:0:12}" "${bncMode:$((${#bncMode}-3))}")
			else
				bnc_disp="($bncMode)"
			fi
		fi
	else
		color="${COLOR_LIGHT_BLUE}"
	fi
	printf "\r${TABS:0:$((5*2))}* Current Region:      $color$country${COLOR_NONE} ${COLOR_DARY_GRAY}$bnc_disp${COLOR_NONE}\n"
}

function func_continue_searching () {
	printf "\n"
	if [[ "$totalcount" -gt 0 ]]; then
		printf "\r${COLOR_CYAN}${TABS:0:$((4*2))} >> Enter a number to use it's PID: # "
		func_field_gen 3 "(e.g. 3)"
		func_cursor_switch 1
		read -e pidSelect
		func_cursor_switch 0
		tput cuu1
		if [[ "$pidSelect" -gt 0 ]]; then
			pid=${pidArray[$(($pidSelect-1))]}
			searchDone=1;
		fi
		func_clear_line
		if [[ "$(tput cols)" -le 132 ]]; then
			tput cuu1
		fi
	fi
	if [[ "$pidSelect" -lt 1 ]]; then
		printf "\r${COLOR_CYAN}${TABS:0:$((4*2))} >> Search again? "
		func_field_gen 4 "[y|n]"
		func_cursor_switch 1
		read -n 1 -e searchDone
		func_cursor_switch 0
		tput cuu1
		case $searchDone in  
			y|Y) pid=""; searchDone=0 ;;
			*)	 searchDone=1 ;;
		esac
	fi
}

function func_show_recommands () {
	printf "\r\n${COLOR_CYAN}${TABS:0:$((4*2))} >> Want recommands? "
	func_field_gen 4 "[y|n]"
	func_cursor_switch 1
	read -n 1 -e recommands
	func_cursor_switch 0
	tput ccu1
	func_banner
	case $recommands in  
		y|Y) 
			printf "\r\n${TABS:0:$((4*2))} * Processing...${TEXT_PADDING}"
			recommands=1
			;;
		*)	 
			printf "\r\n${TABS:0:$((4*2))} * Searching Canceled.${TEXT_PADDING}"
			recommands=0
			;;
	esac
}

function func_limit_results () {
	if [[ "$totalcount" -gt $CONST_SEARCH_MAX ]] && [[ "$VAR_SEARCH_IGNORE" -eq 0 ]]; then
		totalcount=$CONST_SEARCH_MAX
	fi
}

function func_bandwidth () {
	if [[ "$2" -eq 0 ]]; then
		VAR_BANDWIDTH=$(echo "$1" | tr ',' '\n' | grep "BANDWIDTH" | cut -f2 -d'=' | sort -nr | head -n1 | sed -e s/[^0-9]//g)
	elif [[ "$2" -eq 1 ]]; then
		VAR_BANDWIDTH=$(echo "$1" | tr ' ' '\n' | grep "system-bitrate" | tr -d '"'| cut -f2 -d'=' | sort -nr | head -n1 | sed -e s/[^0-9]//g)
	else
		VAR_BANDWIDTH=$(echo "$1" | tr ' ' '\n' | grep "bitrate" | tr -d '"'| cut -f2 -d'=' | sort -nr | head -n1 | sed -e s/[^0-9]//g)
	fi
}

function func_progress_status () {
	func_banner
	func_geo_show
	toDoList=(
		"Revieving Manifest." #1
		"Capturing Subtitle." #2
		"Capturing M3U." #3
		"Capturing Stream List." #4
		"Capturing DRM Key." #5
		"Capturing Stream." #6
		"Creating File List." #7
		"Generating Local M3U." #8
		"Decrypting Stream." #9
		"Transcoding Stream." #10
		"Removing Cache." #10
		"???") #11
	printf "\n${TABS:0:$((4*2))} * Progress Status:\n\n"
	local y=0
	for i in "${toDoList[@]}"
	do
		y=$((++y))
		local STAGE_MARK=" "
		local STAGE_MARK_COLOR=${COLOR_LIGHT_BLUE}
		local STAGE_COLOR=
		local STAGE_EFFECT=
		if [[ $y -lt $1 ]]; then
			STAGE_MARK="√"
			STAGE_COLOR=${COLOR_LIGHT_BLUE}
		elif [[ $y -eq $1 ]]; then
			STAGE_MARK="-"
			STAGE_MARK_COLOR=${COLOR_YELLOW}
			STAGE_COLOR=${COLOR_RED}
		else
			STAGE_MARK=" "
			STAGE_COLOR=${COLOR_DARY_GRAY}
		fi
		if [[ $y -eq 2 ]] && [ "${VAR_SUB_SIZE}" != "" ]; then
			i=$(printf "%s${COLOR_NONE} ${COLOR_DARY_GRAY}(%d kB)${COLOR_NONE}$STAGE_COLOR" "$i" $(($VAR_SUB_SIZE/1000)))
		elif [[ $y -eq 2 ]] && [[ $y -lt $1 ]]; then
			STAGE_MARK="x"
			STAGE_MARK_COLOR=${COLOR_RED}
			STAGE_COLOR=${COLOR_YELLOW}
		elif [[ $y -eq 3 ]] && [ "${VAR_M3U_SIZE}" != "" ]; then
			i=$(printf "%s${COLOR_NONE} ${COLOR_DARY_GRAY}(%d kB)${COLOR_NONE}$STAGE_COLOR" "$i" $(($VAR_M3U_SIZE/1000)))
		elif [[ $y -eq 4 ]] && [ "${VAR_CLIPS}" != "" ]; then
			i=$(printf "%s${COLOR_NONE} ${COLOR_DARY_GRAY}(%d files)${COLOR_NONE}$STAGE_COLOR" "$i" $VAR_CLIPS)
		elif [[ $y -eq 5 ]] && [ "${VAR_KEY_HEX}" != "" ]; then
			i=$(printf "%s${COLOR_NONE} ${COLOR_DARY_GRAY}(0x%s)${COLOR_NONE}$STAGE_COLOR" "$i" "${VAR_KEY_HEX}")
		elif ([[ $y -ge 4 ]] && [[ $y -le 5 ]] || [[ $y -ge 7 ]] && [[ $y -le 9 ]]) && [ "$drmMode" == "Adobe RTMP" ]; then
			if [[ $y -lt $1 ]]; then
				STAGE_MARK="x"
			fi
			STAGE_MARK_COLOR=${COLOR_DARY_GRAY}
			STAGE_COLOR=${COLOR_DARY_GRAY}
		elif [[ $y -eq 6 ]] && [ "${VAR_BANDWIDTH}" != "" ]; then
			i=$(printf "%s${COLOR_NONE} ${COLOR_DARY_GRAY}(Bandwidth: %d kbps)${COLOR_NONE}$STAGE_COLOR" "$i" $(($VAR_BANDWIDTH/1000)))
		else
			echo 1 >/dev/null 2>&1
		fi
		printf "${TABS:0:$((4*2))}    [$STAGE_MARK_COLOR $STAGE_MARK ${COLOR_NONE}] $STAGE_COLOR%s${COLOR_NONE}\n" "$i"
	done
}

function func_filename () {
	local file=$(/usr/bin/basename "$2")
	if [[ "$1" -eq 0 ]]; then
		echo "${file%.*}"
	else
		echo "${file##*.}"
	fi
}

function func_subtitle () {
	local subUrl="$1"
	local newName="$2"
	local extension=$(func_filename 1 "$subUrl")
	VAR_SUB_ONLY=
	VAR_SUB_NAME="$newName.$extension"
	curl -sL --user-agent "${CONST_CURL_AGENT}" "$subUrl" > "$VAR_SUB_NAME"
	VAR_SUB_SIZE=$(func_size "$VAR_SUB_NAME")
	python _t_$uuid "$VAR_SUB_NAME" "$newName.srt" >/dev/null 2>&1
	func_notification "Subtitle downloaded." "$filename" 0
}

function func_transcoding () {
	local filename_disp=
	local lengthLimit=30
	if [[ "${#filename}" -gt $lengthLimit ]]; then
		filename_disp=$(printf "%s...%s" "${filename:0:$(($lengthLimit-6))}" "${filename:$((${#filename}-3))}")
	else
		filename_disp=$filename
	fi
	printf "\r\n${COLOR_RED}${TABS:0:$((3*2))} >> [${COLOR_NONE}${COLOR_LIGHT_CYAN}${TEXT_BLINK} Transcoding ${COLOR_NONE}${COLOR_RED}]${COLOR_NONE} ${COLOR_DARY_GRAY} \"%s.mp4\" in progress.${COLOR_NONE}${TEXT_PADDING}" $filename_disp
	if [[ "$1" -eq 0  ]]; then
		ffmpeg -loglevel panic -i $filename.mp4.flv -c copy -bsf:a aac_adtstoasc $filename.mp4
	else
		ffmpeg -loglevel panic -f concat -i file_list.txt -c copy -bsf:a aac_adtstoasc $filename.mp4
	fi
	func_notification "Finished transcoding." "$filename" 1
}

function func_download_status () {
	local progressbar='-\|/'
	local start_time=`$CONST_DATE_BIN +%s`
	local i=0
	local percent=0
	local etaTime=
	local elapsedTime=
	local padding='      '
	local t=0
	local h=0
	local m=0
	local s=0
	VAR_STREAM_SIZE=
	func_notification "Download started. (Approx. ${VAR_SIZE_PREDICT} MB)" "$filename" 0
	printf "\n"
	while kill -0 $lastpid >/dev/null 2>&1
	do
		i=$(((i+1)%4))
		local currentSize=$(du -sk)
		currentSize=${currentSize%.*}
		t=$(expr `$CONST_DATE_BIN +%s` - $start_time + 1)
		currentSize=$(echo "scale=2; ${currentSize}/1024" | bc)
		speed=$(echo "scale=2; ${currentSize}*8/${t}" | bc)
		h=$((${t}/3600))
		m=$(((${t}%3600)/60))
		s=$((${t}%60))
		elapsedTime=$(printf "%02d:%02d:%02d" $h $m $s)
		if [[ "$VAR_CLIPS" -lt 1 ]]; then
			if [ "${currentSize:0:1}" == "." ]; then
				currentSize=0.001
			elif [[ "${currentSize%.*}" -lt 1 ]]; then
				currentSize="0$currentSize"
			fi
			t=$(echo "scale=0; ${t}/${currentSize}*(${VAR_SIZE_PREDICT}-${currentSize})" | bc)
			t=$(printf "%d" ${t%.*})
			h=$((${t}/3600))
			m=$(((${t}%3600)/60))
			s=$((${t}%60))
			etaTime=$(printf "%02d:%02d:%02d" $h $m $s)
			percent=$(echo "scale=0; ${currentSize}*100/${VAR_SIZE_PREDICT}" | bc)
			percent=$(printf "%d" ${percent%.*})
			printf "\r${COLOR_RED}${TABS:0:$((2*2))}   >> [${COLOR_NONE}${COLOR_LIGHT_CYAN}${TEXT_BLINK} Capturing %3d%% ${COLOR_NONE}${COLOR_RED}]${COLOR_NONE} ${progressbar:$i:1} ${COLOR_DARY_GRAY} %.2f of %.2f MB in $elapsedTime. (%.2f Mbps, ETA: %s)${COLOR_NONE}${TEXT_PADDING}" $percent $currentSize $VAR_SIZE_PREDICT $speed "$etaTime"
			if [[ "$(tput cols)" -le 132 ]]; then
				tput cuu1
			fi
		else
			currentFiles=$(ls -1 *.ts 2>/dev/null | wc -l)
			if [[ "$currentFiles" -lt 1 ]]; then
				currentFiles=1
			fi
			t=$((${t}/${currentFiles}*(${VAR_CLIPS}-${currentFiles})))
			h=$((${t}/3600))
			m=$(((${t}%3600)/60))
			s=$((${t}%60))
			etaTime=$(printf "%02d:%02d:%02d" $h $m $s)
			percent=$((${currentFiles}*100/${VAR_CLIPS}))
			printf "\r${COLOR_RED}${TABS:0:$((2*2))}  >> [${COLOR_NONE}${COLOR_LIGHT_CYAN}${TEXT_BLINK} Downloading %3d%% ${COLOR_NONE}${COLOR_RED}]${COLOR_NONE} ${progressbar:$i:1} ${COLOR_DARY_GRAY} %.2f of %.2f MB in $elapsedTime. (%.2f Mbps, ETA: %s)${COLOR_NONE}${TEXT_PADDING}" $percent $currentSize $VAR_SIZE_PREDICT $speed "$etaTime"
			if [[ "$(tput cols)" -le 132 ]]; then
				tput cuu1
			fi
		fi
		sleep 1
	done
	printf "\r${TEXT_PADDING}${TEXT_PADDING}${TEXT_PADDING}${TEXT_PADDING}${TEXT_PADDING}${TEXT_PADDING}"
	currentSizeReadable=$(du -sh | awk '{print $1;}')
	VAR_STREAM_SIZE=$(du -sk | awk '{print $1;}')
	if [[ "$(tput cols)" -le 132 ]]; then
		tput cuu1
	fi
	printf "\r${TABS:0:$((4*2))} * Done fetching. ${COLOR_LIGHT_BLUE}$currentSizeReadable${COLOR_NONE} in ${COLOR_RED}$elapsedTime${COLOR_NONE}.${TEXT_PADDING}"
	func_notification "Downloaded $currentSizeReadable in $elapsedTime." "$filename" 0
	sleep .5
}

function func_get_pid () {
	while [[ "${#pid}" -ne $1 ]]; do
		printf "${COLOR_NONE}"
		func_banner
		printf "\r\n${COLOR_NONE}${COLOR_CYAN}${TABS:0:$((4*2))} >> Enter a PID to fetch: "
		func_field_gen $1 "(e.g. $2)"
		func_cursor_switch 1
		read -n $1 -e pid
		tput cuu1
	done
	func_cursor_switch 0
}

function func_decrypt () {
	local iv=0
	local iv_hex=
	local iv_gen=
	local file_in=
	local file_out=
	local key=
	local key_hex=
	local i=0
	printf "\n"
	while read s; do
		if [ ${s:0:30} == "#EXT-X-KEY:METHOD=AES-128,URI=" ]; then
			key=${s#*URI=\"*}
			key=${key%\"*}
			key_hex=$(xxd -p "$key" 2>/dev/null | tr -d '\n')
			iv_gen=0
			iv="$(echo "$s" | grep "IV=" | sed 's/.*IV=//')"
			if [[ ${#iv} -gt 0 ]] && [ ${iv:0:2} == "0x" ]; then
				iv=${iv##*0x}
				iv_hex="${iv:0:32}"
			elif [[ ${#iv} -gt 0 ]]; then
				iv_hex=$(printf "%032x" "$iv" 2>/dev/null)
			else
				iv=0
				iv_hex=$(printf "%032x" "$iv" 2>/dev/null)
				iv_gen=1
			fi
		elif [ ${s:0:15} == "#EXT-X-KEY:NONE" ]; then
				key=
				iv=
				iv_hex=
				iv_gen=0
		elif [ ${s:0:1} != "#" ]; then
			file_in="$s"
			file_out=$(printf "_%s" "$s")
			i=$(($i+1))
			if [[ ${#key} -lt 1 ]]; then
				continue
			fi
			printf "\r${COLOR_RED}${TABS:0:$((4*2))} >> [${COLOR_NONE}${COLOR_LIGHT_CYAN}${TEXT_BLINK} Decrypting ${COLOR_NONE}${COLOR_RED}]${COLOR_NONE} ${COLOR_DARY_GRAY} %d of ${VAR_CLIPS} files.${COLOR_NONE}${TEXT_PADDING}" $i
			openssl aes-128-cbc -d -K $key_hex -iv $iv_hex -nosalt -in $file_in -out $file_out & 2>/dev/null
			if [[ "$iv_gen" -gt 0 ]]; then
				iv=$(($iv+1))
				iv_hex=$(printf "%032x" "$iv" 2>/dev/null)
			fi
		else
			echo "" >/dev/null 2>&1
		fi
	done < "$1"
	func_notification "Decrypted ${VAR_CLIPS} files." "$filename" 0
}

function func_exit_quick () {
	printf "${COLOR_NONE}"
	func_cursor_switch 1
	kill -9 $lastpid >/dev/null 2>&1
	killall -9 parallel >/dev/null 2>&1
	killall -9 curl >/dev/null 2>&1
	killall -9 rtmpdump >/dev/null 2>&1
	rm -rf "${WORKING_DIR}"
	cd "${CURRENT_DIR}"
	clear
	printf "\033[8;${originalLines};${originalColumns}t"
	exit 0
}

# Traps.
trap 'func_exit_quick;' INT

#--------------------      Consts      --------------------

#--------------------      Starts      --------------------

func_main () {
	func_uuidgen
	func_cursor_switch 0
	func_initiate
	geoReq="US"
	func_banner
	local providersList=(
		"ABC" 
		"CBS"
		"FOX" 
		"Lifetime" 
		"NBC"
		"BBC"
		"SyFy" 
		"USA" 
		"Bravo"
		"A&E"
		"Bio"
		"TheCW"
		"GlobalTV"
		"FX"
		"SBS")
	IFS=$'\n' providersList=($(sort <<<"${providersList[*]}"))
	providerid=
	while [[ "$providerid" -lt 1 ]] || [[ "$providerid" -gt ${#providersList[@]} ]]
	do
		func_banner
		printf "\n${TABS:0:$((4*2))} * Avaliable providers:\n\n"
		local n=
		for i in "${providersList[@]}"
		do
			n=$((++n))
			printf "${TABS:0:$((5*2))}[${COLOR_YELLOW} %2d ${COLOR_NONE}] ${COLOR_LIGHT_BLUE}%s${COLOR_NONE}\n" $n "$i"
		done
		printf "\r\n${COLOR_CYAN}${TABS:0:$((4*2))} >> Choose a provider: # "
		func_field_gen 4 "(e.g. 2)"
		func_cursor_switch 1
		read -n 3 -e providerid
		func_cursor_switch 0
	done
	providerid="${providersList[$(($providerid-1))]}"

	#--------------------       Ends       --------------------

	#--------------------  ABC Mode Starts --------------------

	if [ "$providerid" == "ABC" ]; then
	    mode="ABC"
		drmMode="Apple HLS"
	    pidLength=14
	    local pidPrefix="VDKA0_"
		while [[ "$searchDone" -eq 0 ]]; do
			func_banner
			printf "\n${TABS:0:$((3*2))} * Enter a full episode URL or a PID. (Starts with \"${COLOR_CYAN}http://${COLOR_NONE}\" or \"${COLOR_CYAN}$pidPrefix${COLOR_NONE}\")\n"
			printf "\r\n${COLOR_CYAN}${TABS:0:$((4*2))} >> URL/PID: "
			func_field_gen "$pidLength" "VDKA0_hsogkucz"
			func_cursor_switch 1
			read -e pid
			func_cursor_switch 0
			func_banner
			printf "\r\n${TABS:0:$((4*2))} * Searching for PID...\n"
			if [[ "${#pid}" -eq "$pidLength" ]] && [ "${pid:0:${#pidPrefix}}" == "$pidPrefix" ]; then
				func_banner
				printf "\r\n${TABS:0:$((4*2))} * Getting details of PID \"${COLOR_BG_RED}$pid${COLOR_NONE}\"...\n"
			elif [ "${pid:0:7}" == "http://" ] && [ "${pid:0:8}" == "https://" ]; then
				feed=$(curl -sL "$pid" | iconv -f UTF-8 | grep "og:url")
				pid=$(func_search_string "$feed" "/$pidPrefix" "/")
				pid=$(printf "VDKA0_%s" "$pid")
				func_banner
				if [[ "${#pid}" -eq "$pidLength" ]]; then
					printf "\r\n${TABS:0:$((4*2))} * Getting details of PID \"${COLOR_BG_RED}$pid${COLOR_NONE}\"...\n"
				else
					printf "\r\n${TABS:0:$((4*2))} * No PID found.\n"
					sleep 1
				fi
			else
				func_banner
				printf "\r\n${TABS:0:$((4*2))} * Invalid input.\n"
				sleep 1
			fi
			if [[ "${#pid}" -eq "$pidLength"  ]]; then
				pid=$(echo $pid | rev | cut -f1 -d"_" | rev)
				local series_disp=
				local title_disp=
				local season_disp=
				local episode_disp=
				local description_disp=
				local airdate_disp=
				local availdate_disp=
				local expiredate_disp=
				local duration_disp=
				json=$(curl -sL $proxy --cookie-jar cookies.txt "http://api.watchabc.go.com/vp2/ws/s/contents/2015/videos/jsonp/001/001/-1/-1/-1/VDKA0_$pid/-1/-1")
				series_disp=$(func_json_parser "$json" "videos.video.show.title")
				if [[ "${#series_disp}" -gt 0 ]]; then
					title_disp=$(func_json_parser "$json" "videos.video.title")
					season_disp=$(func_json_parser "$json" "videos.video.season[\"@id\"]")
					episode_disp=$(func_json_parser "$json" "videos.video.number")
					description_disp=$(func_json_parser "$json" "videos.video.description")
					airdate_disp=$(func_json_parser "$json" "videos.video.airdates.airdate")
					airdate_disp=$(func_air_date 0 "$airdate_disp")
					availdate_disp=$(func_json_parser "$json" "videos.video.availdate")
					availdate_disp=$(func_air_date 0 "$availdate_disp")
					expiredate_disp=$(func_json_parser "$json" "videos.video.expiredate")
					expiredate_disp=$(func_air_date 0 "$expiredate_disp")
					duration_disp=$(func_json_parser "$json" "videos.video.duration.$")
					if [[ "${#series_disp}" -gt 33 ]]; then
						series_disp=$(printf "%s..." "${series_disp:0:33}")
					fi
					if [[ "${#description_disp}" -gt 49 ]]; then
						description_disp=$(printf "%s..." "${description_disp:0:46}")
					fi
					printf "\n"
					printf "${TABS:0:$((3*2))}    * Series:      ${COLOR_LIGHT_BLUE}$series_disp${COLOR_NONE} ${TEXT_PADDING:${#series_disp}}  [${COLOR_BG_RED}VDKA0_$pid${COLOR_NONE}]\n"
					printf "${TABS:0:$((3*2))}    * Title:       ${COLOR_LIGHT_BLUE}$title_disp${COLOR_NONE}\n"
					printf "${TABS:0:$((3*2))}    * Season:      ${COLOR_LIGHT_BLUE}$season_disp${COLOR_NONE}\n"
					printf "${TABS:0:$((3*2))}    * Episode:     ${COLOR_LIGHT_BLUE}$episode_disp${COLOR_NONE}\n"
					printf "${TABS:0:$((3*2))}    * Duration:    ${COLOR_LIGHT_BLUE}$(($duration_disp/60000)) mins${COLOR_NONE}\n"
					printf "${TABS:0:$((3*2))}    * Air:         $airdate_disp\n"
					printf "${TABS:0:$((3*2))}    * Avaliable:   $availdate_disp\n"
					printf "${TABS:0:$((3*2))}    * Expire:      $expiredate_disp\n"
					printf "${TABS:0:$((3*2))}    * Description: ${COLOR_LIGHT_BLUE}$description_disp${COLOR_NONE}"
				else
					printf "\r\n${TABS:0:$((4*2))} * No episode found."
				fi
				if [[ "${#pid}" -eq "$(($pidLength-${#pidPrefix}))" ]]; then
					printf "\n"
					func_continue_searching
				fi
			fi
		done
		func_progress_status 1
		func_vpn_connect 
		text=$(curl -sL $proxy --cookie-jar cookies.txt "http://www.kaltura.com/p/585231/sp/58523100/playManifest/format/http/entryId/0_$pid/a.f4m?playbackContext=brand%3D001%26device%3D001")
		url=$(func_search_string "$text" "<media url=\"" "\"")
		url=$(echo "$url" | sed 's/&amp;/\&/g' )
		func_progress_status 2
		tturl=$(func_json_parser "$json" "videos.video.closedcaption.src.$")
		if [[ "${#season_disp}" -ne 0  ]]; then
			season_disp=$(printf "S%02d" "$season_disp")
		else
			season_disp=""
		fi
		if [[ "${#episode_disp}" -ne 0  ]]; then
			episode_disp=$(printf "E%02d" "$episode_disp")
		else
			episode_disp=""
		fi
		filenameOrig=$(printf "%s_%s%s_%s_%s" "$series_disp" "$season_disp" "$episode_disp" "$title_disp" "$pid_disp" | sed -e 's/[^A-Za-z0-9._-]/_/g' | sed 's/__*/_/g')
		VAR_FOLDER_SERIES=$(printf "%s" "$series_disp" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/  */ /g')
		VAR_FOLDER_SEASON=$(printf "%s" "$season_disp" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/  */ /g')
		filename=$(printf "%s_%s" "$filenameOrig" "$uuid")
		func_subtitle "$tturl" "$filename"
		cat "$filename.srt" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n01:/\'$'\n00:/g' | sed 's/ --> 01:/\ --> 00:/g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n02:/\'$'\n01:/g' | sed 's/ --> 02:/\ --> 01:/g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n03:/\'$'\n02:/g' | sed 's/ --> 03:/\ --> 02:/g' > "$filename.srt"
		func_progress_status 3
		text=$(curl -sL $proxy --cookie cookies.txt --cookie-jar cookies.txt "$url")
		VAR_BANDWIDTH=
		func_bandwidth "$text" 0
		url=$(echo $text | tr ' ' '\n' | grep -A1 "BANDWIDTH=$VAR_BANDWIDTH" | tr ' ' '\n' | grep "http")
		func_progress_status 4
		curl -sL $proxy --cookie cookies.txt --cookie-jar cookies.txt "$url" > dump.m3u8
		VAR_M3U_SIZE=$(func_size dump.m3u8)
		if [[ "$VAR_M3U_SIZE" -eq 0 ]]; then
			printf "\r\n${TABS:0:$((4*2))}${COLOR_RED} >> [${COLOR_NONE}${COLOR_BG_RED}ERROR${COLOR_NONE}${COLOR_RED}] Incorrect M3U size!${COLOR_NONE} (${COLOR_RED}%d${COLOR_NONE} bytes)\n" $VAR_M3U_SIZE
			printf "\n${TABS:0:$((4*2))} * Press any key to continue..."
			func_null_input
			cd "${CURRENT_DIR}"
			return
		fi
		VAR_CLIPS=$(grep -c ".ts" dump.m3u8)
		text=$(cat dump.m3u8)
		url=$(func_search_string "$text" "#EXT-X-KEY:METHOD=AES-128,URI=\"" "\"")
		func_progress_status 5
		curl -sL $proxy --cookie cookies.txt --cookie-jar cookies.txt "$url" > key
		VAR_KEY_SIZE=$(func_size key)
		VAR_KEY_HEX=$(xxd -p key 2>/dev/null | tr -d '\n')
		if [[ "$VAR_KEY_SIZE" -ne 16 ]] && [ "$url" !="" ]; then
			printf "\r${TABS:0:$((4*2))}${COLOR_RED} >> [${COLOR_NONE}${COLOR_BG_RED}ERROR${COLOR_NONE}${COLOR_RED}] Incorrect key size!${COLOR_NONE} (${COLOR_RED}%d${COLOR_NONE} ${COLOR_LIGHT_BLUE}!=${COLOR_NONE} ${COLOR_RED}16${COLOR_NONE} bytes)\n" $VAR_KEY_SIZE
			printf "\n${TABS:0:$((4*2))} * Press any key to continue..."
			func_null_input
			cd "${CURRENT_DIR}"
			return
		fi
		func_vpn_disconnect
		func_progress_status 6
		VAR_SIZE_PREDICT=$(echo "scale=2; ${VAR_BANDWIDTH}*${duration_disp}/8192000000" | bc)
		grep ".ts?" dump.m3u8 | parallel --no-notice -k -P ${CONST_FETCH_THREADS} 'a={}; o=$(echo "$a" | cut -f1 -d"?" | rev | cut -f1 -d"/" | rev); curl -sL '"$proxy"' --cookie cookies.txt "$a" -o "$o"' 2>/dev/null & lastpid=$!
		func_download_status
		func_progress_status 7
		grep ".ts?" dump.m3u8 | cut -f1 -d"?" | rev | cut -f1 -d"/" | rev | sed "s/^/file '_/" | sed -e "s/$/'/" > file_list.txt
		func_progress_status 8
		cat dump.m3u8 | sed '/.ts/ s/?.*//' | rev | sed '/:ptth/ s/".*//' | sed '/:sptth/ s/".*//' | sed '/:YEK-X-TXE#/ s/,.*//' | sed '/:ptth/ s/\/.*//' | rev | sed '/IV=/ s/^/#EXT-X-KEY:METHOD=AES-128,URI="key"/' > local.m3u8
		func_progress_status 9
		func_decrypt local.m3u8
		func_progress_status 10
		func_transcoding 1

	#--------------------   ABC Mode Ends  --------------------

	#--------------------  CW Mode Starts  --------------------

	elif [ "$providerid" == "TheCW" ]; then
		mode="TheCW"
		drmMode="Adobe RTMP"
		searchDone=""
		while [[ "$searchDone" -eq 0 ]]; do
			func_banner
			printf "\n"
			printf "${TABS:0:$((1*2))} * Enter a PID. If the URL is \"${COLOR_CYAN}http://www.cwtv.com/cw-video/x/?play=113112dd-365e-4231-a1fd-edca3706ad6d${COLOR_NONE}\",\n${TABS:0:$((1*2))}   the ID is \"${COLOR_CYAN}113112dd-365e-4231-a1fd-edca3706ad6d${COLOR_NONE}\".\n"
			printf "\r\n${COLOR_CYAN}${TABS:0:$((4*2))} >> PID: "
			func_field_gen 25 ""
			func_cursor_switch 1
			read -e selectedShow
			func_cursor_switch 0
			selectedShow=$(echo "$selectedShow" | awk '{print tolower($0)}' | sed 's/ /-/g')
			if [ "$selectedShow" != "" ]; then
				func_banner
				local rtmp_feed=
				local rtmp_best_bandwidth=
				local json=
				printf "\r\n${TABS:0:$((4*2))} * Getting details of PID \"${COLOR_BG_RED}$selectedShow${COLOR_NONE}\"...\n"
				local pid_disp=
				local series_disp=
				local season_disp=
				local episode_disp=
				local title_disp=
				local description_disp=
				local airdate_disp=
				local expiredate_disp=
				local availdate_disp=
				local duration_disp=
				json=$(curl -sL $proxy "http://metaframe.digitalsmiths.tv/v2/CWtv/assets/$selectedShow/partner/53?format=json")
				rtmp_feed=$(func_json_parser "$json" "videos.ds900.uri")
				pid_disp=$(func_json_parser "$json" "guid")
				if [[ "${#pid_disp}" -gt 0  ]]; then
					pid=$pid_disp
					series_disp=$(func_json_parser "$json" "assetFields.seriesName")
					title_disp=$(func_json_parser "$json" "assetFields.title")
					description_disp=$(func_json_parser "$json" "assetFields.description")
					season_disp=$(func_json_parser "$json" "assetFields.seasonNumber")
					episode_disp=$(func_json_parser "$json" "assetFields.episodeNumber")
					airdate_disp=$(func_json_parser "$json" "assetFields.originalAirDate")
					airdate_disp=$(func_air_date 0 "$airdate_disp")
					expiredate_disp=$(func_json_parser "$json" "expireTime")
					expiredate_disp=$(func_air_date 0 "${expiredate_disp:0:19}")
					availdate_disp=$(func_json_parser "$json" "startTime")
					availdate_disp=$(func_air_date 0 "${availdate_disp:0:19}")
					duration_disp=$(func_json_parser "$json" "assetFields.duration")
					if [[ "${#description_disp}" -gt 49 ]]; then
						description_disp=$(printf "%s..." "${description_disp:0:46}")
					fi
					if [[ "${#series_disp}" -gt 30 ]]; then
						series_disp=$(printf "%s..." "${series_disp:0:27}")
					fi
					if [[ "${#title_disp}" -gt 49 ]]; then
						title_disp=$(printf "%s..." "${title_disp:0:46}")
					fi
					printf "\n"
					printf "${TABS:0:$((3*2))}    * Name:        ${COLOR_LIGHT_BLUE}$series_disp${COLOR_NONE} ${TEXT_PADDING:${#series_disp}}\n"
					printf "${TABS:0:$((3*2))}    * PID:         [${COLOR_BG_RED}$pid_disp${COLOR_NONE}]\n"
					printf "${TABS:0:$((3*2))}    * Title:       ${COLOR_LIGHT_BLUE}$title_disp${COLOR_NONE}\n"
					printf "${TABS:0:$((3*2))}    * Season:      ${COLOR_LIGHT_BLUE}$season_disp${COLOR_NONE}\n"
					printf "${TABS:0:$((3*2))}    * Episode:     ${COLOR_LIGHT_BLUE}$episode_disp${COLOR_NONE}\n"
					printf "${TABS:0:$((3*2))}    * Duration:    ${COLOR_LIGHT_BLUE}$(($duration_disp/60)) mins${COLOR_NONE}\n"
					printf "${TABS:0:$((3*2))}    * Air:         $airdate_disp\n"
					printf "${TABS:0:$((3*2))}    * Avaliable:   $availdate_disp\n"
					printf "${TABS:0:$((3*2))}    * Expire:      $expiredate_disp\n"
					printf "${TABS:0:$((3*2))}    * Description: ${COLOR_LIGHT_BLUE}$description_disp${COLOR_NONE}"
				else
					printf "\r\n${TABS:0:$((4*2))} * No episode found."
				fi
				printf "\n"
				func_continue_searching
			fi
		done
		pidLength=36
		func_get_pid "$pidLength" "113112dd-365e-4231-a1fd-edca3706ad6d"
		func_geo_ip
		func_progress_status 1
		json=$(curl -sL $proxy "http://metaframe.digitalsmiths.tv/v2/CWtv/assets/$selectedShow/partner/53?format=json")
		series_disp=$(func_json_parser "$json" "assetFields.seriesName")
		title_disp=$(func_json_parser "$json" "assetFields.title")
		season_disp=$(func_json_parser "$json" "assetFields.seasonNumber")
		episode_disp=$(func_json_parser "$json" "assetFields.episodeNumber")
		VAR_BANDWIDTH=$(func_json_parser "$json" "videos.ds900.bitrate")
		rtmp_feed=$(func_json_parser "$json" "videos.ds900.uri")
		base=$(echo "$rtmp_feed" | sed -e 's/mp4:.*//g')
		videosrc=$(echo "$rtmp_feed" | sed -e 's/.*mp4://g')
		func_progress_status 2
		tturl=$(func_json_parser "$json" "assetFields.UnicornCcUrl")
		if [[ "${#season_disp}" -ne 0  ]]; then
			season_disp=$(printf "S%02d" "$season_disp")
		else
			season_disp=""
		fi
		if [[ "${#episode_disp}" -ne 0  ]]; then
			episode_disp=$(printf "E%02d" "$episode_disp")
		else
			episode_disp=""
		fi
		filenameOrig=$(printf "%s_%s%s_%s_%s" "$series_disp" "$season_disp" "$episode_disp" "$title_disp" "$pid_disp" | sed -e 's/[^A-Za-z0-9._-]/_/g' | sed 's/__*/_/g')
		VAR_FOLDER_SERIES=$(printf "%s" "$series_disp" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/  */ /g')
		VAR_FOLDER_SEASON=$(printf "%s" "$season_disp" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/  */ /g')
		filename=$(printf "%s_%s" "$filenameOrig" "$uuid")
		func_subtitle "$tturl" "$filename"
		func_progress_status 6
		VAR_SIZE_PREDICT=$(echo "scale=2; ${VAR_BANDWIDTH}*${duration_disp}/8192000" | bc)
		rtmpdump -q -r $base -s "http://media.cwtv.com/cwtv/digital-smiths/production_player/vsplayer.swf" -y mp4:$videosrc -o $filename.mp4.flv 2>/dev/null & lastpid=$!
		func_download_status
		func_progress_status 10
		func_transcoding 0

	#--------------------    CW Mode Ends   --------------------

	#--------------------  BBC Mode Starts  --------------------

	elif [ "$providerid" == "BBC" ]; then
		geoReq="GB"
		mode="BBC"
		drmMode="Adobe RTMP"
		pidLength=8
		func_banner
		func_vpn_connect
		searchDone=0
		while [[ "$searchDone" -eq 0 ]] || [[ "${#pid}" -ne "$pidLength" ]]; do
			totalcount=0
			pidSelect=0
			func_banner
			func_get_pid "$pidLength" "p01np1b8"
			func_banner
			printf "\r\n${TABS:0:$((4*2))} * Getting details of PID \"${COLOR_BG_RED}$pid${COLOR_NONE}\"...\n"
			local pid_disp=
			local series_disp=
			local season_disp=
			local title_disp=
			local description_disp=
			local airdate_disp=
			local duration_disp=
			text=$(curl -sL $proxy --cookie-jar cookies.txt "http://www.bbc.co.uk/iplayer/playlist/$pid/")
			textProgramme=$(echo "$text" | grep -A10 "kind=\"programme\"")
			pid_disp=$(func_search_string "$textProgramme" "identifier=\"" "\"")
			if [[ "${#pid_disp}" -gt 0  ]]; then
				series_disp=$(echo "$textProgramme" | grep "programmeBrand")
				series_disp=$(func_search_string "$series_disp" ">" "<")
				season_disp=$(echo "$textProgramme" | grep "programmeSeries")
				season_disp=$(func_search_string "$season_disp" ">" "<" | rev | cut -f1 -d" " | rev)
				title_disp=$(func_search_string "$text" "<title>" "<" | rev | cut -f1 -d":" | rev | sed -e 's/^[ \t]*//')
				description_disp=$(func_search_string "$text" "<summary>" "<")
				airdate_disp=$(func_search_string "$text" "<updated>" "<")
				airdate_disp=$(func_air_date 0 "${airdate_disp:0:15}")
				duration_disp=$(func_search_string "$textProgramme" "duration=\"" "\"")
				duration_disp=${duration_disp%.*}
				if [[ "${#description_disp}" -gt 49 ]]; then
					description_disp=$(printf "%s..." "${description_disp:0:46}")
				fi
				if [[ "${#series_disp}" -gt 33 ]]; then
					series_disp=$(printf "%s..." "${series_disp:0:27}")
				fi
				if [[ "${#title_disp}" -gt 49 ]]; then
					title_disp=$(printf "%s..." "${title_disp:0:46}")
				fi
				printf "\n"
				printf "${TABS:0:$((3*2))}    * Series:      ${COLOR_LIGHT_BLUE}$series_disp${COLOR_NONE} ${TEXT_PADDING:${#series_disp}}    [${COLOR_BG_RED}$pid_disp${COLOR_NONE}]\n"
				printf "${TABS:0:$((3*2))}    * Title:       ${COLOR_LIGHT_BLUE}$title_disp${COLOR_NONE}\n"
				printf "${TABS:0:$((3*2))}    * Season:      ${COLOR_LIGHT_BLUE}$season_disp${COLOR_NONE}\n"
				printf "${TABS:0:$((3*2))}    * Duration:    ${COLOR_LIGHT_BLUE}$(($duration_disp/60)) mins${COLOR_NONE}\n"
				printf "${TABS:0:$((3*2))}    * Air:         $airdate_disp\n"
				printf "${TABS:0:$((3*2))}    * Description: ${COLOR_LIGHT_BLUE}$description_disp${COLOR_NONE}"
				pid="$pid_disp"
			else
				printf "\r\n${TABS:0:$((4*2))} * No episode found."
			fi
			printf "\n"
			func_continue_searching
		done
		func_progress_status 1
		text=$(curl -sL $proxy --cookie cookies.txt --cookie-jar cookies.txt "http://www.bbc.co.uk/mediaselector/4/mtis/stream/$pid/")
		local VAR_BANDWIDTH_MAX=$(echo "$text" | tr ">" "\n"  | grep "bitrate" | tr " " "\n" | grep "bitrate" | cut -f2 -d"=" | tr -d "\"" | sort -nr | head -n 1)
		textStream=$(echo "$text" | tr ">" "\n" | grep -A2 "bitrate=\"$VAR_BANDWIDTH_MAX\"")
		textCaption=$(echo "$text" | tr ">" "\n" | grep -A1 "captions" | grep "href")
		textRTMP=$(echo "$textStream" | grep "akamai")
		VAR_BANDWIDTH=$(func_search_string "$textStream" "bitrate=\"" "\"")
		VAR_BANDWIDTH=$(($VAR_BANDWIDTH*1000))
		VAR_SIZE_PREDICT=$(func_search_string "$textStream" "media_file_size=\"" "\"")
		local size_compare=$VAR_SIZE_PREDICT
		local media_file_size="$VAR_SIZE_PREDICT"
		VAR_SIZE_PREDICT=$(($VAR_SIZE_PREDICT/1024000))
		local application="ondemand"
		local authString=$(func_search_string "$textRTMP" "authString=\"" "\"")
		local identifier=$(func_search_string "$textRTMP" "identifier=\"" "\"")
		local protocol=$(func_search_string "$textRTMP" "protocol=\"" "\"")
		local server=$(func_search_string "$textRTMP" "server=\"" "\"")
		func_progress_status 2
		tturl=$(func_search_string "$textCaption" "href=\"" "\"")
		if [[ "${#season_disp}" -ne 0  ]]; then
			season_disp=$(printf "S%02d" "$season_disp")
		else
			season_disp=""
		fi
		if [[ "${#episode_disp}" -ne 0  ]]; then
			episode_disp=$(printf "E%02d" "$episode_disp")
		else
			episode_disp=""
		fi
		filenameOrig=$(printf "%s_%s%s_%s_%s" "$series_disp" "$season_disp" "$episode_disp" "$title_disp" "$pid_disp" | sed -e 's/[^A-Za-z0-9._-]/_/g' | sed 's/__*/_/g')
		VAR_FOLDER_SERIES=$(printf "%s" "$series_disp" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/  */ /g')
		VAR_FOLDER_SEASON=$(printf "%s" "$season_disp" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/  */ /g')
		filename=$(printf "%s_%s" "$filenameOrig" "$uuid")
		func_subtitle "$tturl" "$filename"
		local complete_dump=0
		while [[ "$complete_dump" -ne 1 ]]; do
			func_progress_status 6
			rtmpdump -q -e -r "$protocol://$server/$application" -s "$application?$authString" -y "$identifier" -o $filename.mp4.flv  2>/dev/null & lastpid=$!
			func_download_status
			local checksum=$(du -sk "$filename.mp4.flv" | awk '{print $1;}')
			checksum=$(($size_compare/1024-${checksum}))
			if [[ "${checksum}" -lt 1024 ]]; then
				complete_dump=1
			fi
		done
		func_vpn_disconnect
		func_progress_status 10
		func_transcoding 0

	#--------------------   BBC Mode Ends   --------------------

	#------------------  General Mode Starts  ------------------

	else
		local companyCode=
	    local fetchCode=
	    local feedCode=
	    local smilPattern=
		local searchPattern="mbr=true&format=Script"
	    local pidExample=
	    local pidLength=
	    local vpnKeep=
	    local useSig=
	    local sha_key=
	    local secret_key=
	    local rtmpMode=
	    local season_keyword=
	    local season_keyword_SMIL=
	    local season_keyword_c=
	    local episode_keyword=
	    local episode_keyword_SMIL=
	    local episode_keyword_c=
	    local search_speed_dial=()
	    local search_keyword=
	    local search_pattern_full_episode="&byCustomValue=%7BfullEpisode%7D%7Btrue%7D"
	    local search_pattern_series="&byCategories=Series/%s"
	    local series_keyword="media\$categories[0].media\$name"
	    local series_keyword_c=
	    local series_keyword_SMIL="categories[0].name"
	    local pid_keyword="media\$content"
	    local textstream_keyword="textstream src=\""
	    local keyword_counter=
	    local rtmpBase=
	    local rtmpPlayer=
		local dumpFilter_keep=""
		local dumpFilter_remove="NOTHING_TO_DO_HERE_YO"
	    drmMode="Apple HLS"
	    case "$providerid" in
	    	"CBS") # CBS
				mode="CBS"
	    		companyCode="dJ5BDC"
			    fetchCode="dJ5BDC"
			    feedCode="VxxJg8Ymh8sE"
			    smilPattern="format=SMIL&mbr=true"
			    pidExample="Eh6rpSfJxTSg"
			    season_keyword="cbs\$SeasonNumber"
			    episode_keyword="cbs\$EpisodeNumber"
			    season_keyword_SMIL="cbs\$SeasonNumber"
			    episode_keyword_SMIL="cbs\$EpisodeNumber"
			    search_keyword="NCIS"
			    search_speed_dial=("CSI: Crime Scene Investigation" "NCIS" "NCIS: Los Angeles" "Intelligence" "The Mentalist" "Criminal Minds" "Two and a Half Men" "The Big Bang Theory" "60 Minutes" "MacGyver" "Star Trek - The Original Series" "2 Broke Girls" "Mom")
			    series_keyword="cbs\$SeriesTitle"
			    series_keyword_SMIL="cbs\$SeriesTitle"
			    textstream_keyword="ClosedCaptionURL\" value=\""
			    search_pattern_full_episode=""
			    search_pattern_series="&byCustomValue=%%7BEpisodeFlag%%7D%%7Btrue%%7D,%%7BSeriesTitle%%7D%%7B%s%%7D"
			    pidLength=12
			    vpnKeep=0
			    useSig=0
			    dumpFilter_keep="&isad=False"
				dumpFilter_remove="&isad=True"
			    ;;
			"NBC") # NBC
				mode="NBC"
	    		companyCode="NnzsPC"
			    fetchCode="NnzsPC"
			    feedCode="end_card"
			    smilPattern="mbr=true&manifest=m3u&format=SMIL&formats=MPEG4"
			    pidExample="Eh6rpSfJxTSg"
			    season_keyword="nbcu\$seasonNumber"
			    episode_keyword="nbcu\$airOrder"
			    season_keyword_SMIL="nbcu\$seasonNumber"
			    episode_keyword_SMIL="nbcu\$airOrder"
			    search_keyword="The Blacklist"
			    search_speed_dial=("The Blacklist" "Chicago Fire" "Chicago P.D." "Dracula" "Hannibal" "Late Night with Jimmy Fallon" "The Tonight Show Starring Jimmy Fallon" "Late Night with Seth Meyers" "Saturday Night Live" "The Voice" "Believe" "NBC News")
			    pidLength=12
			    vpnKeep=1
			    useSig=1
			    sha_key="crazyjava"
			    secret_key="s3cr3t"
			    ;;
	    	"Lifetime") # Lifetime
				mode="Lifetime"
	    		companyCode="xc6n8B"
			    fetchCode="xc6n8B"
			    smilPattern="mbr=true&assetTypes=medium_video_s3&switch=hls&manifest=m3u&format=SMIL&formats=M3U,MPEG4"
			    pidExample="r9yNl3hcrMrZ"
			    pidLength=12
			    vpnKeep=0
			    useSig=1
			    sha_key="crazyjava"
			    secret_key="s3cr3t"
			    ;;
			"SyFy") # SyFy
				mode="SyFy"
	    		companyCode="hQNl-B"
			    fetchCode="HNK2IC"
			    feedCode="2g1gkJT0urp6"
			    smilPattern="mbr=true&player=Global%20VOD%20No%20Auth%20Player&manifest=m3u&format=SMIL&Embedded=true&formats=MPEG4"
			    pidExample="zKDCljDsNk6n"
			    series_keyword="media\$categories[1].media\$name"
			    season_keyword="nbcu\$seasonNumber"
			    episode_keyword="nbcu\$episodeNumber"
			    season_keyword_SMIL="nbcu\$seasonNumber"
			    episode_keyword_SMIL="nbcu\$episodeNumber"
			    search_pattern_series="&byCategories=Shows/%s"
			    search_keyword="Helix"
			    search_speed_dial=("Helix" "Being Human" "Bitten" "Face Off" "Naked Vegas" "Opposite Worlds" "Defiance" "Blastr" "Opposite Worlds" "Haven" "Warehouse 13")
			    pidLength=12
			    vpnKeep=0
			    useSig=1
			    sha_key="crazyjava"
			    secret_key="s3cr3t"
			    ;;
			"USA") # USA
				mode="USA"
				drmMode="Apple HLS - Broken"
	    		companyCode="OyMl-B"
			    fetchCode="HNK2IC"
			    feedCode="Y3vAV4MxgwlM"
			    smilPattern="mbr=true&player=USA%20Network%20Video%20Player%20v1.6&manifest=m3u&format=SMIL&formats=MPEG4"
			    pidExample="MEecm8jAspVy"
			    series_keyword="media\$categories[1].media\$name"
			    season_keyword="nbcu\$seasonNumber"
			    episode_keyword="nbcu\$episodeNumber"
			    season_keyword_SMIL="nbcu\$seasonNumber"
			    episode_keyword_SMIL="nbcu\$episodeNumber"
			    search_keyword="White Collar"
			    search_speed_dial=("White Collar" "Suits" "Psych" "Covert Affairs")
			    pidLength=12
			    vpnKeep=0
			    useSig=1
			    sha_key="crazyjava"
			    secret_key="s3cr3t"
			    ;;
			"FOX") # FOX
				mode="FOX"
	    		companyCode="fox.com"
			    fetchCode="fox.com"
			    feedCode="TSyDrDDkKtKH"
			    smilPattern="mbr=true&manifest=m3u&formats=MPEG4"
			    pidExample="2dB0DNhpbaPD"
			    season_keyword="fox\$season"
			    episode_keyword="fox\$episode"
			    season_keyword_SMIL="fox\$season"
			    episode_keyword_SMIL="fox\$episode"
			    search_speed_dial=("Almost Human|\$:LgdTPHHIVlY9" "Hell's Kitchen|!:619426693001" "The Simpsons|!:4ZjKdg7LsmTi" "Family Guy|!:619475277001" "MasterChef|!:619426698001" "The Following")
			    search_keyword="Almost Human"
			    pidLength=12
			    vpnKeep=0
			    useSig=1
			    sha_key="#100FoxLock"
			    secret_key="FoxKey"
			    ;;
	    	"FX") # FX
				mode="FX"
	    		companyCode="fxnetworks"
			    fetchCode="fxnetworks"
			    smilPattern="mbr=true&manifest=m3u&formats=MPEG4"
			    pidExample="g3UGkwM1rjQq"
			    pidLength=12
			    vpnKeep=0
			    useSig=0
			    ;;
	    	"GlobalTV") # GlobalTV
				geoReq="CA"
				mode="GlobalTV"
	    		companyCode="dtjsEC"
			    fetchCode="dtjsEC"
			    feedCode="z6CXpVZXbWTh"
			    smilPattern="mbr=true&manifest=m3u&formats=M3U&format=SMIL"
			    pidExample="DB8jNz0pzy_U"
			    series_keyword="pl1\$show"
			    series_keyword_SMIL="pl1\$show"
			    season_keyword="pl1\$season"
			    episode_keyword="pl1\$episode"
			    season_keyword_SMIL="pl1\$season"
			    episode_keyword_SMIL="pl1\$episode"
			    search_keyword="Sleepy Hollow"
			    search_speed_dial=("Chicago PD" "The Young and the Restless" "Chicago Fire" "Sleepy Hollow" "NCIS" "Elementary" "Rake" "Dracula" "The Blacklist" "Almost Human" "The Millers")
			    search_pattern_full_episode=""
			    search_pattern_series="&byCustomValue=%%7BclipType%%7D%%7Bepisode%%7D,%%7Bshow%%7D%%7B%s%%7D"
			    pidLength=12
			    vpnKeep=0
			    useSig=0
			    ;;
	    	"Bio") # Bio
				mode="Bio"
	    		companyCode="xc6n8B"
			    fetchCode="xc6n8B"
			    smilPattern="mbr=true&assetTypes=medium_video_s3&switch=hls&manifest=m3u&format=SMIL&formats=M3U,MPEG4"
			    pidExample="F4CipTtAdUVO"
			    pidLength=12
			    vpnKeep=0
			    useSig=1
			    sha_key="crazyjava"
			    secret_key="s3cr3t"
			    ;;
	    	"A&E") # A&E
				mode="A&E"
	    		companyCode="xc6n8B"
			    fetchCode="xc6n8B"
			   	smilPattern="mbr=true&assetTypes=medium_video_s3&switch=hls&manifest=m3u&format=SMIL&formats=M3U,MPEG4"
			    pidExample="YougRv_TG2iP"
			    pidLength=12
			    vpnKeep=0
			    useSig=1
			    sha_key="crazyjava"
			    secret_key="s3cr3t"
			    ;;
			"Bravo") # Bravo
				mode="Bravo"
	    		companyCode="PHSl-B"
			    fetchCode="PHSl-B"
			    feedCode="hOMhFl_Iu3_G"
			    smilPattern="mbr=true&player=Global%20VOD%20No%20Auth%20Player&manifest=m3u&format=SMIL&Embedded=true&formats=M3U,MPEG4"
			    pidExample="8C6Hwi08nfUD"
			    search_keyword="Top Chef"
			    search_speed_dial=("Top Chef" "Thicker Than Water" "Vanderpump Rules" "The Real Housewives of Orange County")
			    search_pattern_full_episode=""
			    search_pattern_series="&byCustomValue=%%7BfullEpisode%%7D%%7Btrue%%7D,%%7Bsubtitle%%7D%%7B%s%%7D"
			    season_keyword_c="pl%d\$season[0]"
			    episode_keyword_c="pl%d\$episode[0]"
			    series_keyword_c="pl%d\$subtitle"
			    series_keyword_SMIL="pl1\$subtitle"
			    keyword_counter=1
			    pidLength=12
			    vpnKeep=0
			    useSig=1
			    sha_key="crazyjava"
			    secret_key="s3cr3t"
			    ;;
	    	"SBS") # SBS
				geoReq="AU"
				mode="SBS"
	    		companyCode="Bgtm9B"
			    fetchCode="Bgtm9B"
			    feedCode="sbs-e16qKzBBHt4R"
			    smilPattern="mbr=true&manifest=m3u&format=SMIL&formats=MPEG4"
			    pidExample="KXH_hiH0LxrQ"
			    search_pattern_full_episode=""
			    search_pattern_series="&byCustomValue=%%7BuseType%%7D%%7BFull%%20Episode%%7D,%%7BprogramName%%7D%%7B%s%%7D"
			    search_keyword="Falcon"
			    search_speed_dial=("Falcon" "Generation War" "The Tales Of Nights")
			    season_keyword=""
			    episode_keyword=""
			    series_keyword="pl1\$programName"
			    series_keyword_SMIL="pl1\$programName"
			    pidLength=12
			    vpnKeep=0
			    useSig=0
			    ;;
		esac
		searchDone=0
		if [[ "${#feedCode}" -ne 0 ]]; then
			while [[ "$searchDone" -eq 0 ]]; do
				VAR_SEARCH_IGNORE=0
				VAR_SEARCH_LIMIT=${CONST_SEARCH_MAX}
				pidSelect=0
				func_banner
				printf "\n"
				recommands=1
				if [[ "${#search_speed_dial[@]}" -gt 0 ]]; then
					IFS=$'\n' search_speed_dial=($(sort <<<"${search_speed_dial[*]}"))
					func_banner
					printf "\n${TABS:0:$((4*2))} * Speed-Dial: (e.g. #5)\n\n"
					local n=
					for i in "${search_speed_dial[@]}"
					do
						n=$((++n))
						printf "${TABS:0:$((4*2))}    >> [${COLOR_YELLOW} %2d ${COLOR_NONE}] ${COLOR_LIGHT_BLUE}%s${COLOR_NONE}\n" $n "${i%|*}"
					done
					printf "\n"
				fi
				printf "\r${COLOR_CYAN}${TABS:0:$((4*2))} >> Series Search: "
				func_field_gen 25 "(e.g. $search_keyword)"
				func_cursor_switch 1
				read -e seriesname
				func_cursor_switch 0
				func_banner
				local seriesname_disp=
				local feedCode_disp="$feedCode"
				local search_pattern_full_episode_disp="$search_pattern_full_episode"
				if [ "${seriesname:0:1}" == "!" ]; then
					VAR_SEARCH_IGNORE=1
					VAR_SEARCH_LIMIT=100
					seriesname=${seriesname:1}
				fi
				if [ "${seriesname:0:1}" == "~" ]; then
					search_pattern_full_episode_disp=""
					seriesname=${seriesname:1}
				fi
				if [ "${seriesname:0:1}" == "@" ]; then
					pid="${seriesname:1}"
					break
				elif [ "${seriesname:0:1}" == "#" ]; then
					seriesname=${search_speed_dial[$((${seriesname:1}-1))]}
					seriesname=${seriesname%|*}
				else
					echo 1 >/dev/null 2>&1
				fi
				if [ "${seriesname:0:1}" == "$" ]; then
					feedCode_disp="${seriesname:1}"
					seriesname=""
					printf "\r\n${TABS:0:$((4*2))} * Searching for PID \"${COLOR_BG_RED}$feedCode_disp${COLOR_NONE}\"..."
				elif [ "$seriesname" != "" ]; then
					printf "\r\n${TABS:0:$((4*2))} * Searching for \"${COLOR_BG_RED}$seriesname${COLOR_NONE}\"..."
					seriesname_disp=$(printf " of \"${COLOR_BG_RED}$seriesname${COLOR_NONE}\"")
					seriesname=$(func_urlencode "$seriesname")
					seriesname=$(printf "$search_pattern_series" "$seriesname")
				else
					seriesname_disp=$(printf " from the ${COLOR_RED}JSON feeds${COLOR_NONE}")
					func_show_recommands
				fi
				printf "\n"
				totalcount=0
				if [[ "$recommands" -eq 1 ]]; then
					json=$(curl -sL "http://feed.theplatform.com/f/$companyCode/$feedCode_disp?count=true&form=json$search_pattern_full_episode_disp&sort=availableDate%7Cdesc&range=1-${VAR_SEARCH_LIMIT}$seriesname")
					totalcount=$(func_json_parser "$json" "totalResults")
					totalcountMax=$totalcount
					func_limit_results
					func_banner
					printf "\r\n${TABS:0:$((4*2))} * Getting the latest $totalcount of $totalcountMax episodes$seriesname_disp...\n"
					searchResults=
					pidArray=()
					local i=1
					local i_disp=1
					for ((i=1; i<=$totalcount; i++))
					do
						local pid_disp=
						local series_disp=
						local title_disp=
						local season_disp=
						local episode_disp=
						local airdate_disp=
						local bitrate_max=
						if [[ "$keyword_counter" -ne 0 ]]; then
							local kwc=$i
							season_keyword=$(printf "$season_keyword_c" $kwc)
						    episode_keyword=$(printf "$episode_keyword_c" $kwc)
						    series_keyword=$(printf "$series_keyword_c" $kwc)
						fi
						local j=$(($i-1))
						pid_disp=$(func_json_parser "$json" "entries[$j].$pid_keyword")
						VAR_BANDWIDTH=$(echo "$pid_disp" | jsawk -n "out(this.plfile\$bitrate)" | sort -nr | head -n 1)
						if [[ "${#VAR_BANDWIDTH}" -lt 1 ]]; then
							continue
						fi
						pid_disp=$(echo "$pid_disp" | jsawk "if (this.plfile\$bitrate == ${VAR_BANDWIDTH}) return this.plfile\$url")
						if [[ "${#pid_disp}" -lt 1 ]]; then
							continue
						fi
						pid_disp="${pid_disp##*link.theplatform.com/s/$companyCode/}"
						pid_disp="${pid_disp:0:${pidLength}}"
						season_disp=$(func_json_parser "$json" "entries[$j].$season_keyword")
						episode_disp=$(func_json_parser "$json" "entries[$j].$episode_keyword")
						series_disp=$(func_json_parser "$json" "entries[$j].$series_keyword")
						series_disp=${series_disp##*/}
						title_disp=$(func_json_parser "$json" "entries[$j].title")
						local lengthLimit=18
						local TEXT_PADDING_L_S=${TEXT_PADDING:0:$lengthLimit}
						if [[ "${#series_disp}" -gt $lengthLimit ]]; then
							series_disp=$(printf "%s...%s" "${series_disp:0:$(($lengthLimit-6))}" "${series_disp:$((${#series_disp}-3))}")
						fi
						lengthLimit=28
						local TEXT_PADDING_L_T=${TEXT_PADDING:0:$lengthLimit}
						if [ "${title_disp:0:${#series_disp}}" == "${series_disp}" ]; then
							title_disp=${title_disp:$((${#series_disp}+3))}
						fi
						if [[ "${#title_disp}" -gt $lengthLimit ]]; then
							title_disp=$(printf "%s...%s" "${title_disp:0:$(($lengthLimit-6))}" "${title_disp:$((${#title_disp}-3))}")
						fi
						airdate_disp=$(func_json_parser "$json" "entries[$j].pubDate")
						airdate_disp=$(func_air_date 1 "$airdate_disp")
						printf "\n    ${COLOR_CYAN}# %2d${COLOR_NONE} ${COLOR_LIGHT_BLUE}$series_disp${COLOR_NONE}: ${TEXT_PADDING_L_S:${#series_disp}} ${COLOR_BG_RED}$pid_disp${COLOR_NONE} \"${COLOR_GREEN}$title_disp${COLOR_NONE}\" ${TEXT_PADDING_L_T:${#title_disp}} - " $i_disp
						printf "${COLOR_LIGHT_BLUE}%02d${COLOR_NONE}" $season_disp
						printf "x${COLOR_LIGHT_BLUE}%02d${COLOR_NONE}" $episode_disp
						printf ", $airdate_disp"
						i_disp=$(($i_disp+1))
						pidArray+=("$pid_disp")
					done
					totalcount=$(($i_disp-1))
				fi
				printf "\n"
				func_continue_searching
			done
		fi
		searchDone=0
		while [[ "$searchDone" -eq 0 ]]; do
			totalcount=0
			pidSelect=0
			func_banner
			func_get_pid "$pidLength" "$pidExample"
			func_banner
			printf "\r\n${TABS:0:$((4*2))} * Getting details of PID \"${COLOR_BG_RED}$pid${COLOR_NONE}\"...\n"
			local pid_disp=
			local series_disp=
			local series_file=
			local title_disp=
			local title_file=
			local season_disp=
			local episode_disp=
			local description_disp=
			local airdate_disp=
			local duration_disp=
			json=$(curl -sL $proxy --cookie-jar cookies.txt "http://link.theplatform.com/s/$fetchCode/$pid?$searchPattern")
			pid_disp=$(func_json_parser "$json" "pid")
			if [[ "${#pid_disp}" -gt 0  ]]; then
				series_disp=$(func_json_parser "$json" "$series_keyword_SMIL")
				series_disp=${series_disp##*/}
				series_file="$series_disp"
				title_disp=$(func_json_parser "$json" "title")
				title_file="$title_disp"
				season_disp=$(func_json_parser "$json" "$season_keyword_SMIL")
				episode_disp=$(func_json_parser "$json" "$episode_keyword_SMIL")
				description_disp=$(func_json_parser "$json" "description")
				airdate_disp=$(func_json_parser "$json" "pubDate")
				airdate_disp=$(func_air_date 1 "$airdate_disp")
				duration_disp=$(func_json_parser "$json" "duration")
				if [[ "${#description_disp}" -gt 49 ]]; then
					description_disp=$(printf "%s..." "${description_disp:0:46}")
				fi
				if [[ "${#series_disp}" -gt 33 ]]; then
					series_disp=$(printf "%s..." "${series_disp:0:27}")
				fi
				if [[ "${#title_disp}" -gt 49 ]]; then
					title_disp=$(printf "%s..." "${title_disp:0:46}")
				fi
				printf "\n"
				printf "${TABS:0:$((3*2))}    * Series:      ${COLOR_LIGHT_BLUE}$series_disp${COLOR_NONE} ${TEXT_PADDING:${#series_disp}}    [${COLOR_BG_RED}$pid${COLOR_NONE}]\n"
				printf "${TABS:0:$((3*2))}    * Title:       ${COLOR_LIGHT_BLUE}$title_disp${COLOR_NONE}\n"
				printf "${TABS:0:$((3*2))}    * Duration:    ${COLOR_LIGHT_BLUE}$(($duration_disp/60000)) mins${COLOR_NONE}\n"
				printf "${TABS:0:$((3*2))}    * Air:         $airdate_disp\n"
				printf "${TABS:0:$((3*2))}    * Description: ${COLOR_LIGHT_BLUE}$description_disp${COLOR_NONE}"
			else
				printf "\r\n${TABS:0:$((4*2))} * No episode found."
			fi
			printf "\n"
			func_continue_searching
		done
		VAR_BANDWIDTH=
		func_progress_status 1
		func_vpn_connect
		local sig_disp=
		if [[ "${useSig}" -ne 0  ]]; then
			func_theplatform_sig "$fetchCode/$pid" "$sha_key" "$secret_key"
			sig_disp="&sig=$sig"
		fi
		text=$(curl -sL $proxy --cookie-jar cookies.txt "http://link.theplatform.com/s/$fetchCode/$pid?$smilPattern$sig_disp")
		url=$(func_search_string "$text" "video src=\"" "\"")
		url=$(func_urldecode "$url")
		func_progress_status 2
		tturl=$(func_search_string "$text" "$textstream_keyword" "\"")
		if [[ "${#season_disp}" -ne 0  ]]; then
			season_disp=$(printf "S%02d" "$season_disp")
		else
			season_disp=""
		fi
		if [[ "${#episode_disp}" -ne 0  ]]; then
			episode_disp=$(printf "E%02d" "$episode_disp")
		else
			episode_disp=""
		fi
		filenameOrig=$(printf "%s_%s%s_%s_%s" "$series_file" "$season_disp" "$episode_disp" "$title_file" "$pid_disp" | sed -e 's/[^A-Za-z0-9._-]/_/g' | sed 's/__*/_/g')
		VAR_FOLDER_SERIES=$(printf "%s" "$series_disp" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/  */ /g')
		VAR_FOLDER_SEASON=$(printf "%s" "$season_disp" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/  */ /g')
		filename=$(printf "%s_%s" "$filenameOrig" "$uuid")
		func_subtitle "$tturl" "$filename"
		func_progress_status 3
		if [[ "${rtmpMode}" -ne 0  ]]; then
			if [ "$rtmpBase" != "" ]; then
				base="$rtmpBase"
			else
				base=$(func_search_string "$text" " base=\"" "\"")
			fi
			func_bandwidth "$text" 1
	        video_text=$(echo "$text" | grep "$VAR_BANDWIDTH" | head -n1)
	        videosrc=$(func_search_string "$video_text" "<video src=\"" "\"" | cut -f1 -d"?")
		else
			text=$(curl -sL $proxy --cookie cookies.txt --cookie-jar cookies.txt "$url")
			func_bandwidth "$text" 0
			local url_fix=""
			local url_tmp=$(echo "$text" | grep -A1 "$VAR_BANDWIDTH" | grep "http")
			if [[ "${#url_tmp}" -eq 0 ]]; then
				url_fix=$(printf "%s/" "${url%/*.m3u8?*}")
				url_tmp=$(echo "$text" | grep -A1 "$VAR_BANDWIDTH" | grep ".m3u8")
			fi
			url="$(echo "$url_tmp" | sed -e 's/[^A-Za-z0-9._~:/%?#@!$&()*+,;=-]//g')"
			func_progress_status 4
			curl -sL $proxy --cookie cookies.txt --cookie-jar cookies.txt "$url_fix$url" > dump.m3u8
			VAR_M3U_SIZE=$(func_size dump.m3u8)
			if [[ "$VAR_M3U_SIZE" -eq 0 ]]; then
				printf "\r\n${TABS:0:$((4*2))}${COLOR_RED} >> [${COLOR_NONE}${COLOR_BG_RED}ERROR${COLOR_NONE}${COLOR_RED}] Incorrect M3U size!${COLOR_NONE} (${COLOR_RED}%d${COLOR_NONE} bytes)\n" $VAR_M3U_SIZE
				cd "${CURRENT_DIR}"
				func_vpn_disconnect
				printf "\n${TABS:0:$((4*2))} * Press any key to continue..."
				func_null_input
				return
			fi
			VAR_CLIPS=$(grep "$dumpFilter_keep" dump.m3u8 | grep -c ".ts")
			text=$(cat dump.m3u8)
			url=$(func_search_string "$text" "#EXT-X-KEY:METHOD=AES-128,URI=\"" "\"")
			local noKey=0
			if [[ "${#url}" -ne 0 ]]; then
				func_progress_status 5
				if [ "${url:0:7}" != "http://" ] && [ "${url:0:8}" != "https://" ]; then
					url=$(printf "%s/%s" "${url%/*.m3u8?*}" "$url")
				fi
				curl -sL $proxy --cookie cookies.txt --cookie-jar cookies.txt "$url" > key
				VAR_KEY_SIZE=$(func_size key)
				if [[ "$VAR_KEY_SIZE" -ne 16 ]] && [[ "${#url}" -ne 0 ]]; then
					printf "\r\n${TABS:0:$((4*2))}${COLOR_RED} >> [${COLOR_NONE}${COLOR_BG_RED}ERROR${COLOR_NONE}${COLOR_RED}] Incorrect key size!${COLOR_NONE} (${COLOR_RED}%d${COLOR_NONE} ${COLOR_LIGHT_BLUE}!=${COLOR_NONE} ${COLOR_RED}16${COLOR_NONE} bytes)\n" $VAR_KEY_SIZE
					cd "${CURRENT_DIR}"
					func_vpn_disconnect
					printf "\n${TABS:0:$((4*2))} * Press any key to continue..."
					func_null_input
					return
				fi
				VAR_KEY_HEX=$(xxd -p key 2>/dev/null | tr -d '\n')
			else
				noKey=1
			fi
		fi
		if [[ "$vpnKeep" -ne 1 ]]; then
			func_vpn_disconnect
		fi
		func_progress_status 6
		VAR_SIZE_PREDICT=$(echo "scale=2; ${VAR_BANDWIDTH}*${duration_disp}/8192000000" | bc)
		if [[ "${rtmpMode}" -ne 0  ]]; then
			if [ "$mode" == "NBC" ]; then
				videosrc=$(func_search_string "$videosrc" "/z/" ".")
				videosrc="nbcu/$videosrc.mp4"
			fi
			func_log "rtmpdump -e -r "$base" -s "$rtmpPlayer" -y mp4:$videosrc -o $filename.mp4.flv"
			rtmpdump -q -r "$base" -s "$rtmpPlayer" -y mp4:$videosrc -o $filename.mp4.flv  2>/dev/null & lastpid=$!
		else
			if [[ "$(grep -c "http" dump.m3u8)" -lt 1 ]]; then
				local s=
				while read s; do
					if [ ${s:0:1} == "#" ]; then
						echo $s >> dump_fix.m3u8
					elif [[ ${#s} -gt 0 ]] && [ "${s:0:7}" != "http://" ] && [ "${url:0:8}" != "https://" ]; then
						printf "%s%s\n" "$url_fix" "$s" >> dump_fix.m3u8
					else
						continue
					fi
				done < dump.m3u8
				mv dump_fix.m3u8 dump.m3u8
			fi
			grep ".ts?" dump.m3u8 | grep "$dumpFilter_keep" | parallel --no-notice -k -P ${CONST_FETCH_THREADS} 'a={}; o=$(echo "$a" | cut -f1 -d"?" | sed -e "s/[^A-Za-z0-9._-]/_/g" | sed "s/__*/_/g"); a="$(echo "$a" | sed -e '"'"'s/[^A-Za-z0-9._~:/%?#@!$&()*+,;=-]//g'"'"')"; curl -sL '"$proxy"' --retry 10 --retry-delay 3 --cookie cookies.txt "$a" -o "$o"' 2>/dev/null & lastpid=$!
		fi
        func_download_status
		if [[ "$vpnKeep" -eq 1 ]]; then
			func_vpn_disconnect
		fi
		if [[ "${rtmpMode}" -ne 1  ]]; then
			func_progress_status 7
			local file_prefix=""
			if [[ "${noKey}" -ne 1  ]]; then
				file_prefix="_"
			fi
			func_progress_status 8
			cat dump.m3u8 | sed "/.*$dumpFilter_remove.*/d" | sed '/.ts/ s/?.*//' | sed '/.ts/ s/[^A-Za-z0-9._-]/_/g' | sed  '/.ts/ s/__*/_/g' | sed '/#EXT-X-KEY:METHOD=AES-128,URI=/ s/.*"/#EXT-X-KEY:METHOD=AES-128,URI="key"/' > local.m3u8
			grep ".ts" local.m3u8 | sed "s/^/file '$file_prefix/" | sed -e "s/$/'/" > file_list.txt
			func_progress_status 9
			if [[ "${noKey}" -ne 1  ]]; then
				func_decrypt local.m3u8
			fi
		fi
		func_progress_status 10
		if [[ "${rtmpMode}" -ne 0  ]]; then
			func_transcoding 0
		else
			func_transcoding 1
		fi

	#------------------   General Mode Ends   ------------------

	fi
	func_progress_status 11
	local VAR_MOVE_PATH=
	mkdir "${CONST_STORE_PATH}/${VAR_FOLDER_SERIES}" >/dev/null 2>&1
	mkdir "${CONST_STORE_PATH}/${VAR_FOLDER_SERIES}/${VAR_FOLDER_SEASON}" >/dev/null 2>&1
	if [ -d "${CONST_STORE_PATH}/${VAR_FOLDER_SERIES}/${VAR_FOLDER_SEASON}" ]; then
		VAR_MOVE_PATH="${CONST_STORE_PATH}/${VAR_FOLDER_SERIES}/${VAR_FOLDER_SEASON}"
	elif [ -d "${CONST_STORE_PATH}/${VAR_FOLDER_SERIES}" ]; then
		VAR_MOVE_PATH="${CONST_STORE_PATH}/${VAR_FOLDER_SERIES}"
	else
		VAR_MOVE_PATH="${CONST_STORE_PATH}"
	fi
	mv "$filename.srt" "${VAR_MOVE_PATH}" >/dev/null 2>&1
	mv "$VAR_SUB_NAME" "${VAR_MOVE_PATH}" >/dev/null 2>&1
	mv "$filename.mp4" "${VAR_MOVE_PATH}" >/dev/null 2>&1
	cd "${VAR_MOVE_PATH}" >/dev/null 2>&1
	local keepCache=
	local cacheAsk=1
	if [ ! -f "$filename.mp4" ]; then
		printf "\r\n${COLOR_CYAN}${TABS:0:$((4*2))} >> File seems missing. Remove the cache files? "
	else
		local stream_final_size=$(du -sk "$filename.mp4" 2>/dev/null | awk '{print $1;}')
		local checksum=$(echo "scale=0; (${stream_final_size}-${VAR_STREAM_SIZE})/${VAR_STREAM_SIZE}*100" | bc)
		if [[ "${checksum%.*}" -gt 1 ]]; then
			printf "\r\n${COLOR_CYAN}${TABS:0:$((3*2))} >> File seems corrupt. (%.2f%% difference in size) Remove the cache files? " $checksum
		else
			cacheAsk=0
		fi
	fi
	if [[ "$cacheAsk" -eq 1 ]]; then
		func_field_gen 4 "[y|n]"
		func_cursor_switch 1
		read -n 1 -e keepCache
		func_cursor_switch 0
		tput cuu1
		if [ ! -f "$filename.mp4" ] || [[ "${checksum%.*}" -gt 1 ]]; then
			case $keepCache in  
				y|Y) rm -rf "${WORKING_DIR}" >/dev/null 2>&1 ;;
				*) ;;
			esac
		else
			case $keepCache in  
				y|Y) ;;
				*) rm -rf "${WORKING_DIR}" >/dev/null 2>&1 ;;
			esac
		fi
	else
		rm -rf "${WORKING_DIR}" >/dev/null 2>&1
		local play_disp=
		if [[ "${#filename}" -gt 23 ]]; then
			play_disp=$(printf "%s...%s" "${filename:0:17}" "${filename:$((${#filename}-3))}")
		else
			play_disp=$filename
		fi
		func_progress_status 13
		cd "${CURRENT_DIR}"
		func_notification "Ready for playback." "$filename" 0
		if [[ "${CONST_IS_SERVER}" -eq 1 ]]; then
			printf "\r\n${COLOR_CYAN}${TABS:0:$((4*2))} >> Upload \"${COLOR_RED}$play_disp.mp4${COLOR_CYAN}\" to remote site now? "
		else
			printf "\r\n${COLOR_CYAN}${TABS:0:$((4*2))} >> Play \"${COLOR_RED}$play_disp.mp4${COLOR_CYAN}\" now? "

		fi
		func_field_gen 4 "[y|n]"
		func_cursor_switch 1
		read -n 1 -e playVideo
		func_cursor_switch 0
		tput cuu1
		case $playVideo in  
			y|Y) 
				if [[ "${CONST_IS_SERVER}" -eq 0 ]]; then
					open "${VAR_MOVE_PATH}/$filename.mp4" >/dev/null 2>&1
				else
					ncftpput -DD -R -z -u $CONST_REMOTE_FTP_USER -p $CONST_REMOTE_FTP_PASS -P $CONST_REMOTE_FTP_PORT $CONST_REMOTE_FTP_HOST "$CONST_REMOTE_FTP_PATH" "${VAR_MOVE_PATH}"
				fi
				;;
			*)	 playVideo=1 ;;
		esac
		sleep .5
	fi
}

#--------------------       MAIN       --------------------

func_cursor_switch 0
func_banner
func_copyright
func_depandency
func_geo_ip &
alldone=
while [[ "$alldone" -ne 1 ]]; do
	func_main
done
func_cursor_switch 1