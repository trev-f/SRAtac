#!/usr/bin/env python3
"""
Author : trvrfreeman <trvrfreeman@localhost>
Date   : 2022-04-11
Purpose: Convert merged peaks files to a standard format e.g. SAF or bed
"""

import argparse
import pandas as pd
import os


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

    headers = {
        'homer' : 'name,chromosome,start,end,strand,score,original_file,number_peaks_merged'.split(',')
    }

    pd.set_option('display.max_columns', 30)

    df = pd.read_csv(args.file, sep='\t', skiprows=1, header=None).iloc[:, 0:8]
    df.columns = SAFify_header(headers[args.tool])
    outfile = f'{os.path.splitext(args.file.name)[0]}.saf'
    df.to_csv(outfile, sep='\t', header=True, index=False)


# --------------------------------------------------
def SAFify_header(header):
    header[header.index('name')]       = 'GeneID'
    header[header.index('chromosome')] = 'Chr'
    header[header.index('start')]      = 'Start'
    header[header.index('end')]        = 'End'
    header[header.index('strand')]     = 'Strand'

    return header


# --------------------------------------------------
if __name__ == '__main__':
    main()
