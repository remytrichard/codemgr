#!/bin/bash

# Code Manager (codemgr) - An utility to manage source code repositories.

##### Script initialisation

arg1="$1"
arg2="$2"
arg3="$3"
# Will exit the script if it try to use an uninitialised variable.
set -o nounset
# Tells bash that it should exit the script if any statement returns a
# non-true return value.
set -o errexit

##### Variables initialisation

# Remote machine hosting the Git repositories.
gitHost='[USER]@[MACHINE]'
# Path to the Git repositories on the remote machine.
# /!\ Use absolute path: no variable, no tilde ~.
gitRoot='/home/user/git'
# Path to the git repositories on the local machine.
localRoot="${HOME}/Code"
# Name of the template Git repository.
tplName='git_template.git'
# Description of the template Git repository.
tplDesc="${tplName}                Template for (empty) Git repositories."

##### Functions

function init
{
	# Initialises a Git repository hosting on the remote machine.
	mkdir -p "${localRoot}"
	git init --bare "${localRoot}/${tplName}"
	ssh ${gitHost} "mkdir -p ${gitRoot} && echo '${tplDesc}' > ${gitRoot}/repos.txt"
	scp -r "${localRoot}/${tplName}/" "${gitHost}:$gitRoot"
	rm -rf "${localRoot}/${tplName}"
}

function create_repo
{
	# Creates a new repository.
	if [[ -n "$arg2" ]]; then
		if [[ -n "$arg3" ]]; then
			if [[ `ssh ${gitHost} "test -d ${gitRoot}/${arg2}.git && echo exists"` ]]; then
				echo 'Error: A repository with the same name already exist.'
			else
				cmd="cp -r ${gitRoot}/${tplName} ${gitRoot}/${arg2}.git"
				cmd="${cmd} && echo '${arg2} 				${arg3}' >> ${gitRoot}/repos.txt"
				cmd="${cmd} && sort ${gitRoot}/repos.txt --output=\"${gitRoot}/repos.txt\""
				ssh ${gitHost} "${cmd}"
				clone_repo
			fi
		else
			echo 'Error: Please, enter a repository description.'
		fi
	else
		echo 'Error: Please, enter a repository name.'
	fi
}

function list_repos
{
	# Lists all repositories.
	ssh ${gitHost} "cat ${gitRoot}/repos.txt" | less
}

function show_repo
{
	# Shows info about one repository.
	if [[ -n "$arg2" ]]; then
		ssh ${gitHost} "grep ${arg2} ${gitRoot}/repos.txt"
	else
		echo 'Error: Please, enter a repository name to query.'
	fi
}

function clone_repo
{
	# Clones a repository.
	if [[ -n "$arg2" ]]; then
		mkdir -p "$localRoot"
		cd "$localRoot"
		if [[ -d "${localRoot}/${arg2}" ]]; then
			echo 'Error: That repository already exist on the local machine.'
		else
			git clone "${gitHost}:${gitRoot}/${arg2}.git"
			cd "${localRoot}/${arg2}"
		fi
	else
		echo 'Error: Please, enter a repository name to clone.'
	fi
}

function display_help
{
	# Display help.
	echo 'Parameters allowed:'
	echo '	init,'
	echo ' 	new REPO_NAME "DESCRIPTION",'
	echo '	list,'
	echo '	info REPO_NAME,'
	echo '	clone REPO_NAME,'
	echo '	help.'
}

function display_error
{
	# Display an error message.
	echo 'An error occurred, the script was interrupted unexpectedly.'
}

##### Main

trap 'display_error; exit' INT TERM EXIT
# Handles the command line arguments.
case "$arg1" in
	init)
		init;
		;;
	new)
		create_repo;
		;;
	list)
		list_repos;
		;;
	info)
		show_repo;
		;;
	clone)
		clone_repo;
		;;
	help)
		display_help;
		;;
	*)
		echo "Parameter '${arg1}' is invalid.";
		display_help;
		;;
esac
trap - INT TERM EXIT
exit 0
