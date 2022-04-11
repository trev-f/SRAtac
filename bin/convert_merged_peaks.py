#!/usr/bin/env python3
"""
Author : trvrfreeman <trvrfreeman@localhost>
Date   : 2022-04-11
Purpose: Convert merged peaks files to a standard format e.g. SAF or bed
"""

import argparse


# --------------------------------------------------
def get_args():
    """Get command-line arguments"""

    parser = argparse.ArgumentParser(
        description='Convert merged peaks files to a standard format e.g. SAF or bed',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('file',
                        help='Merged peaks file.',
                        metavar='FILE',
                        type=argparse.FileType('rt'),
                        default=None)

    parser.add_argument('-t',
                        '--tool',
                        help='Tool used for merging peaks.',
                        metavar='TOOL',
                        type=str,
                        choices=['homer'],
                        default='')

    parser.add_argument('-o',
                        '--out_format',
                        help='Output format.',
                        metavar='OUTFORMAT',
                        type=str,
                        choices=['SAF', 'bed'],
                        default='')

    args = parser.parse_args()

    return args


# --------------------------------------------------
def main():
    """main program"""

    args = get_args()


# --------------------------------------------------
if __name__ == '__main__':
    main()
