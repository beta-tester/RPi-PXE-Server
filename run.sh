#!/bin/bash


########################################################################
script_dir=$(dirname "${BASH_SOURCE:?}")


########################################################################
FILE_LAST_RUN="${script_dir:?}/.run_last"
RUN=
PASS=

########################################################################
if [[ -f "${FILE_LAST_RUN}" ]]; then
	LAST_RUN=$(<"${FILE_LAST_RUN:?}")

	case "${LAST_RUN}" in
		"install")
			RUN="setup"
			;;
		"setup")
			RUN="update"
			;;
		"update")
			RUN="update"
			;;
		*)
			RUN="install"
			;;
	esac
else
	RUN="install"
fi


########################################################################
if ! [[ -z "${1}" ]]; then
	RUN="${1:?}"
fi


########################################################################
case "${RUN}" in
	"install")
		PASS="p0"
		;;
	"setup")
		PASS="p1"
		;;
	"update")
		PASS="p2"
		;;
	*)
		;;
esac


########################################################################
echo "Available actions:"
echo
echo "'install'"
echo "    This will run script 'p0-install.sh'"
echo "    to install required packages"
echo
echo "'setup'"
echo "    This will run script 'p1-setup.sh'"
echo "    to setup / configure services"
echo
echo "'update'"
echo "    This will run script 'p2-update.sh'"
echo "    to download and mount images"
echo "    or unmount and remove images"
echo "    and update menue items"
echo
echo "Automatic next action will be '${RUN}'"
echo
read -p "Do you want to continue with: '${RUN}' [y|N]? " CHOICE
echo
case "${CHOICE}" in
	Y|y) ;;
	*)	echo "To override automatic action, you can give the script 'run.sh' one of the above actions"
		exit 1
		;;
esac


########################################################################
. "${script_dir:?}/${PASS:?}-${RUN:?}.sh"


########################################################################
echo "${RUN:?}" > "${FILE_LAST_RUN:?}"
