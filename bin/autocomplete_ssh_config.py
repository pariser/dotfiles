#!/usr/bin/python

import re
import sys
import os

hosts = set()

print_hosts = re.match('--no-hosts', ' '.join(sys.argv[1:])) is None

config_path = os.path.expanduser('~/.ssh/config')

config = open(config_path, 'r').read()
clean_config = '\n'.join([line for line in config.split('\n') if line and not line.startswith('#')])

host_entries = clean_config.split('Host ')[1:]

for entry in host_entries:
    host, user = None, None
    for line in ('Host ' + entry).split('\n'):
        match = re.search('\s*(\S+)\s+(\S+)', line)
        if match:
            if   match.group(1) == 'Host': host = match.group(2)
            elif match.group(1) == 'User': user = match.group(2)
    if host is not None:
        hosts.add(host)
        if user is not None:
            print '%s@%s' % (user, host),

if print_hosts:
    for host in hosts:
        print host,
