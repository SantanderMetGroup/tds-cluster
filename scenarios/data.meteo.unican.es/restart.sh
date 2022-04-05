#!/bin/bash

lxdock destroy -f
lxdock up
lxdock halt
lxdock up --provision
