#!/usr/bin/python

import sys
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",
                  help="read headerline from FILE", metavar="FILE")
parser.add_option("-F", "--delm", dest="delimiter", default=',', metavar="DELM",
                  help="split headerline on delimiter DELM")
#                  action="store_false", dest="verbose", default=True,
#                  help="don't print status messages to stdout")
parser.add_option("-x", "--example", dest="example", default=False, action="store_true",
                  help="read first line and use it as example data")

(options, args) = parser.parse_args()

options = vars(options)

if options.has_key('filename') and options['filename'] is not None:
    fh = open(options['filename'])
    
    fields = fh.readline().rstrip().split(options['delimiter'])

    len_index  = max([len(str(i+1))  for i in xrange(0, len(fields))])
    len_fields = max([len(fields[i]) for i in xrange(0, len(fields))])

    if options.has_key('example') and options['example']:

        values = fh.readline().rstrip().split(options['delimiter'])

        if len(values) >= len(fields):

            len_values = max([len(values[i]) for i in xrange(0, len(fields))])

            print ('-' * (len_index + 1)) + '+' + ('-' * (len_fields + 2)) + '+' + ('-' * (len_values + 1))

            for i in xrange(0, len(fields)):
                print '%s | %s | %s' % (str(i+1).rjust(len_index), fields[i].ljust(len_fields), values[i].ljust(len_values))

        else:

            len_values = 9
            
            print ('-' * (len_index + 1)) + '+' + ('-' * (len_fields + 2)) + '+' + ('-' * (len_values + 1))

            for i in xrange(0, len(fields)):
                print '%s | %s | <no data>' % (str(i+1).rjust(len_index), fields[i].ljust(len_fields))

    else:
        
        print ('-' * (len_index + 1)) + '+' + ('-' * (len_fields + 1))

        for i in xrange(0, len(fields)):
            print '%s | %s' % (str(i+1).rjust(len_index), fields[i])

else:
    parser.print_help()
