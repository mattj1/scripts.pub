#!/usr/bin/env bash
#
# Summary
#   This script is for setting up a desktop workstation
#     running the latest stable release of Ubuntu GNOME.
#
#   This script installs: xclip, git
#     it then, generates an RSA Key Pair, adds it to ssh-agent
#     and finally prints locations of added files, and sends
#     the public key to clipboard (middle mouse/ wheel click)
#
#   TODO: Display on jknightdev.com alongside start.md
#
# ==========================================================

echo "Enter your email address:"
read email
# TODO: validate email address with simple regex

echo "Enter a name for this machine on github:"
read githubMachineName

# TODO: allow re-entry.
echo "You have entered: $email@$githubMachineName continuing install..."

# 1: Install xclip
sudo apt install xclip

# 1: Install git
sudo apt install git

# 2: Creating RSA Key Pair
#    TODO: Parameterise email address and provide as arg to script.
ssh-keygen -t rsa -b 4096 -C "$email"
# Enter file in which to save the key (/home/james/.ssh/id_rsa)
#input-key:<Enter>
#input-passphrase:<Random Gunk, saved somewhere else>

# 3: Set up ssh-agent
pid=$(ssh-agent -s)
sshAgentPID=$(eval $pid | grep -o -E '[0-9]+')

# 3.1: Test that sshAgentPID has been set/exists
if [ -z ${sshAgentPID+x} ]; then
	echo "provision >  sshAgentPID is unset";
	exit 1;
else
	echo "provision >  sshAgentPID is set to '$sshAgentPID'";
fi

# 3.2: if $sshAgentPID is not an empty string or null or something...
if [ $sshAgentPID -gt 0 ]; then
    echo "provision >  pid parsed OK";
    # we now have an integer variable
    ssh-add ~/.ssh/id_rsa
    # You will be prompted to enter your passphrase.
    #
    # Verify this is true...
    echo "Passphrase now unlocked while logged in"
else
    echo "provision >  pid is zero or lower"
    exit 1
fi

# get the screen to echo locations of saved private and public keys etc.

printf "\n==========provision=============\n\n"
printf "The key pair are located at:\n\n"
echo "    " ~/.ssh/id_rsa
echo "    " ~/.ssh/id_rsa.pub
printf "\nPlease upload these to your github account"
printf "\nsee: https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/"

# 'tr -d' strips newline characters
cat ~/.ssh/id_rsa.pub | tr -d '\n' | xclip -i

printf "\nThe public key has been copied to the ('Mouse 3' / 'Mouse Wheel Down') clipboard!\n"
printf "\n================================\n\n"

git config --global user.email "$email"
git config --global user.name "$githubMachineName"
git config --global push.default simple