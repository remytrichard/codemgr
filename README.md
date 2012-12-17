# An utility to manage source code repositories.

A small script to manage git source code repositories on a server.

## Disclaimer

This is just a small script that helps me manage my repos, I share it here
in case it could be useful to someone else.

## Configuration

Edit line 19 & 22 to fit your server set up.

## Usage

	git clone git://github.com/remytrichard/codemgr.git
	./codemgr.sh init

### Create a new repo

	./codemgr.sh new REPO\_NAME "DESCRIPTION"

### List repos on the server

	./codemgr.sh list

### Get infos on a repo

	./codemgr.sh info REPO\_NAME

### Clone a repo

	./codemgr.sh clone REPO\_NAME

## License

Public Domain
