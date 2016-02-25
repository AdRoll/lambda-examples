# Quickstart

## Install requirements

  1. (OS X) `brew install awscli jq`


## Deploy example infrastructure

  1. `make`

  Creates all example infrastructure; see `create_*.sh` scripts for
  details.  `env.sh` contains (name) tuning params; most created
  infrastructure names are prefixed by `lambda-example` (`$PREFIX`).


## Clean up

  1. `make destroy-all`

  Destroys all example infrastructure.
