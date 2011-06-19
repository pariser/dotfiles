#!/usr/bin/python

import re, sys

hosts = set()

print_hosts = re.match('--no-hosts', ' '.join(sys.argv[1:])) is None

for entry in open('/Users/pariser/.ssh/config', 'r').read().split('Host '):
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

