#! /usr/bin/env ksh
#
#This script should install the provided pythonizer along with the perllib
#
#Author: Dudley Overbey
#Date: 25 October 2022
#Program: install_pythonizer
#
# updated to allow for different owner and group to be passed from command line

if [ "${1}" = "-x" ]; then shift 1; set -x; DB="y"; typeset -ft $(typeset +f) ;fi

if [ "${DB}" = "y" ]
  then
	  ECHO=echo
else
	  unset ECHO
fi

PROG=`basename ${0}`

ifHelp="${1}"
case ${ifHelp} in
    -[Hh][eE]*|-?)

    print "Usage: ${PROG} full_path_to_pythonizer"
    print "    example: ${PROG} /home/LoginID/Downloads/pythonizer-master_1.007.zip"
    print "             enter version number or accept the default"
    exit -1
          ;;
esac

# change owner and group to position 1 and 2 or default to pndt
# chown to 
OWNER="${1:-pndt}"
# chgrp to
GROUP="${2:-pndt}"
# save calling location
OPWD="${PWD}"

print "enter full path to new pythonizer file \c"
read pyizer
if [ ! -f "${pyizer}" ]
  then
	  echo "${pyizer} can not be found"
	  echo "exiting ..."
	  exit -255
fi

Q=`basename ${pyizer} .zip | awk -F"_" '{print $2}'`
print "enter version [${Q}] \c"
read vers

### if [ ${vers} = " " ]
if [ -z ${vers} ]
  then
    ver=${Q}
else
    ver=${vers}
fi

cd /usr/local
if [ -d "/usr/local/pythonizer-master" ]
 then
    echo "found directory name we were going to use"
    echo "going to rename it using today's date"
    ${ECHO} sudo mv pythonizer-master pythonizer-master_`date +'%m%d%Y'`
fi

cd /usr/local

# remove the sym link to pythonizer
${ECHO} sudo rm -f pythonizer
# unzip in ascii mode
${ECHO} sudo unzip -a ${pyizer}
# rename the default name to pythonizer_version
${ECHO} sudo mv pythonizer-master pythonizer_${ver}
# create sym-link from pythonizer_version to pythonizer
${ECHO} sudo ln -s /usr/local/pythonizer_${ver}  /usr/local/pythonizer
# change ownership and group to pndt:pndt
# to do - make the owner and group a variable
${ECHO} sudo chown -Rf ${OWNER}:${GROUP} /usr/local/pythonizer_${ver} /usr/local/pythonizer
# change permissions on pythonizer_version and pythonizer to 775
${ECHO} sudo chmod -R 775 /usr/local/pythonizer_${ver} /usr/local/pythonizer

if [ -f `which pip` ]
then
	PIP=`which pip`
elif [ -f `which pip3` ]
then
	PIP=`which pip3`
else
	echo "pip not found"
	echo "may try python -m pip "
fi

# Check for perllib if not found try to install using sudo and remember to 
if [ -f /usr/local/pythonizer/perllib ]
 then
    PLFVER=`awk -F"="  '/__version__/ {print $2}' /usr/local/pythonizer/perllib/__init__.py | sed "s/'//g"`
    PLPVER=`pip show perllib | awk -F":" '/Version/ {print $2}'`
    PLPYVER=`python3 -m pip show perllib | awk -F":" '/Version/ {print $2}'`
fi
## update perllib
pip install perllib -U
sudo pip install perllib -U
python -m pip install perllib -U
sudo python -m pip install perllib -U
pypy -m pip install perllib -U
sudo pypy -m pip install perllib -U
# check permissions and ownership
## The --target directive isn't needed if the install is done as root (sudo)
## ${ECHO} sudo pip3 install --target=/usr/local/ black
${ECHO} sudo ${PIP} install black

if [ -f "/usr/local/bin/black" ]
 then
   echo "looks like a good install"
   echo "let try an upgrade of the black formatter"
   ${ECHO} sudo ${PIP} install black -U
else
   echo "looks wrong - manual check required"
fi

# change ownership and group to pndt:pndt
${ECHO} sudo chown -Rf ${OWNER}:${GROUP} /usr/local/pythonizer_${ver} /usr/local/pythonizer
# change permissions on pythonizer_version and pythonizer to 775
${ECHO} sudo chmod -R 775 /usr/local/pythonizer_${ver} /usr/local/pythonizer
# change ownership and group to pndt:pndt
${ECHO} sudo chown -Rf ${OWNER}:${GROUP} ${HOME}/.local/lib/python*
# change permissions on pythonizer_version and pythonizer to 775
${ECHO} sudo chmod -R 775 ${HOME}/.local/lib/python*

print "Displaying versions of perllib for pip, pypy, and python"
print "for global and local users"
pip show perllib
sudo show perllib
python -m pip show perllib
sudo python -m pip show perllib
pypy -m pip show perllib
sudo pypy -m pip show perllib

# move back to where we came from
cd ${OPWD}
exit 0
