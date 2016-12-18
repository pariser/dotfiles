#!/usr/bin/env python
# Script:      remove_jpg_if_raw_exists.py
#
# Description: This script looks in all sub directories for
#              pairs of JPG and RAW files.
#              For each pair found the JPG is moved to a
#              waste basket directory.
#              Otherwise JPG is kept.
#
# Author:      Thomas Dahlmann
# Modified by: Renaud Boitouzet
# Modified by: Andrew Pariser

import os
import sys
import shutil
from termcolor import colored

# define your file extensions here, case is ignored.
# Please start with a dot.
# multiple raw extensions allowed, single jpg extension only
raw_extensions = (".dng", ".cr2", ".nef", ".crw")
jpg_extension = ".jpg"

# define source and waste directories. Include trainling slash or backslash.

# source_root = "/Volumes/Blackthorne/Photos/"
# waste_root = "/Volumes/Blackthorne/Photos-JPG/"

source_root = "/Users/pariser/Pictures/"
waste_root = "/Users/pariser/Pictures-JPG/"

##### do not modify below ##########

# find files
def locate(folder, extensions):
    '''Locate files in directory with given extensions'''
    for filename in os.listdir(folder):
        if filename.endswith(extensions):
            yield os.path.join(folder, filename)

# make waste basket dir
if not os.path.exists(waste_root):
    os.makedirs(waste_root)

# Make search case insensitive
raw_ext = tuple(map(str.lower,raw_extensions)) + tuple(map(str.upper,raw_extensions))
jpg_ext = (jpg_extension.lower(), jpg_extension.upper())

os.chdir(source_root)

#find subdirectories
for path, dirs, files in os.walk(os.path.abspath(source_root)):
    print path
    relative_path = os.path.relpath(path, source_root)
    waste_path = os.path.normpath(os.path.join(waste_root, relative_path))

    raw_hash = {}

    for raw in locate(path, raw_ext):
        base_name = os.path.basename(raw)
        base_name = os.path.splitext(base_name)[0]
        raw_hash[base_name] = True

    # find pairs and move jpgs of pairs to waste basket
    for jpg in locate(path, jpg_ext):
        base_name = os.path.basename(jpg)
        base_name, extension = os.path.splitext(base_name)

        if base_name in raw_hash:
            new_jpg = waste_path + '/' + base_name + extension
            print "%s => %s" % (colored(jpg, 'red'), colored(new_jpg, 'green'))

            if not os.path.exists(waste_path):
                os.makedirs(waste_path)

            if os.path.exists(new_jpg):
                os.remove(jpg)
            else:
                shutil.move(jpg, new_jpg)
