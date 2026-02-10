(From Gabriel Rodrigues to Gabriel Rodrigues file)

# Releasing updates to the Launchpad PPA (pr-ship)

This is a practical, repeatable checklist to publish a new version to Launchpad PPA.

export DEBEMAIL="gabrielrod.ifmg@gmail.com" && export DEBFULLNAME="Gabriel Rodrigues" && debuild -S -sa && dput ppa:gabsrodrigues-dev/pr-ship ../pr-ship_<VERSION>-1~ppa2~ubuntu24.04.1_source.changes