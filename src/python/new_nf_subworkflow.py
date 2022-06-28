#!/usr/bin/env python3
"""
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Purpose: Python program to write a Nextflow module
"""

import argparse
import os
import platform
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

from typing import NamedTuple


class Args(NamedTuple):
    program: str
    name: str
    email: str
    purpose: str
    overwrite: bool


# --------------------------------------------------
def get_args() -> Args:
    """Get arguments"""

    parser = argparse.ArgumentParser(
        description='Create Python argparse program',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    username = os.getenv('USER') or 'Anonymous'
    hostname = os.getenv('HOSTNAME') or 'localhost'

    parser.add_argument('program', help='Program name', type=str)

    parser.add_argument('-n',
                        '--name',
                        type=str,
                        default='Trevor F. Freeman',
                        help='Name for docstring')

    parser.add_argument('-e',
                        '--email',
                        type=str,
                        default='trvrfreeman@gmail.com',
                        help='Email for docstring')

    parser.add_argument('-p',
                        '--purpose',
                        type=str,
                        default='Nextflow subworkflow',
                        help='Purpose for docstring')

    parser.add_argument('-f',
                        '--force',
                        help='Overwrite existing',
                        action='store_true')

    args = parser.parse_args()

    args.program = args.program.strip().replace('-', '_')

    if not args.program:
        parser.error(f'Not a usable filename "{args.program}"')

    return Args(args.program, args.name, args.email, args.purpose, args.force)


# --------------------------------------------------
def main() -> None:
    """Make a jazz noise here"""

    args = get_args()
    program = args.program

    if os.path.isfile(program) and not args.overwrite:
        answer = input(f'"{program}" exists.  Overwrite? [yN] ')
        if not answer.lower().startswith('y'):
            sys.exit('Will not overwrite. Bye!')

    print(body(args), file=open(program, 'wt'), end='')

    if platform.system() != 'Windows':
        subprocess.run(['chmod', '+x', program], check=True)

    print(f'Done, see new script "{program}."')


# --------------------------------------------------
def body(args: Args) -> str:
    """ The program template """

    today = str(date.today())
    subworkflow_name = os.path.splitext(os.path.basename(args.program))[0]

    return f"""/*
Author : {args.name}{' <' + args.email + '>' if args.email else ''}
Date   : {today}
Purpose: {args.purpose}
*/

include {"{  }"} from \"\"

workflow {subworkflow_name} {{
    take:

    main:

    emit:
}}
"""


# --------------------------------------------------
if __name__ == '__main__':
    main()
