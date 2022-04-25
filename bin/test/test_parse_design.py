#!/usr/bin/env python3
"""
tests for parse_design.py
"""


import os
import re
from subprocess import getstatusoutput

prg = '../parse_design.py'

# --------------------------------------------------
def test_exists():
    """exists"""

    assert os.path.isfile(prg)


# --------------------------------------------------
def test_usage():
    """usage"""

    for flag in ['-h', '--help']:
        rv, out = getstatusoutput(f'{prg} {flag}')
        assert rv == 0
        assert re.match("usage", out, re.IGNORECASE)

    
# --------------------------------------------------
def test_missing_header():
    """no header"""

    rv, out = getstatusoutput(f'{prg} PE_design_noHeader.csv')
    assert rv == 1
    expected = f"ERROR: Samplesheet -> Missing or invalid header.\n\tLINE: HSL-1,wt_control,1,data/HSL-1_R1.fastq.gz,data/HSL-1_R2.fastq.gz"
    assert out.strip() == expected


# --------------------------------------------------
def test_check_read_types():
    """mixed read types"""

    rv, out = getstatusoutput(f'{prg} SE_design_mixTypes.csv')
    assert rv == 1
    expected = f"ERROR: Samplesheet -> Mixed read types.\n\tLINE: HSL-3,wt_DMSO,1,data/HSL-3_R1.fastq.gz,data/HSL-3_R2.fastq.gz\n\tHSL-4,wt_DMSO,2,data/HSL-4_R1.fastq.gz,data/HSL-4_R2.fastq.gz"
    assert out.strip() == expected


# --------------------------------------------------
def test_single_end():
    """single end"""

    rv, out = getstatusoutput(f'{prg} SE_design_good.csv')
    
    # check status
    assert rv == 0
    assert out == ''

    # check output file
    expected = (
        'lib_ID,sample_rep,fq1\n'
        'HSL-1,wt_control_rep1,data/HSL-1_R1.fastq.gz\n'
        'HSL-2,wt_control_rep2,data/HSL-2_R1.fastq.gz\n'
        'HSL-3,wt_DMSO_rep1,data/HSL-3_R1.fastq.gz\n'
        'HSL-4,wt_DMSO_rep2,data/HSL-4_R1.fastq.gz'
    )
    out_file = 'SE_design_good_parsed.csv'
    out_text = open(out_file).read().rstrip()
    assert out_text == expected

    # cleanup
    if os.path.isfile(out_file):
        os.remove(out_file)


# --------------------------------------------------
def test_paired_end():
    """paired end"""

    rv, out = getstatusoutput(f'{prg} PE_design_good.csv')

    # check status
    assert rv == 0
    assert out == ''

    # check output file
    expected = (
        'lib_ID,sample_rep,fq1,fq2\n'
        'HSL-1,wt_control_rep1,data/HSL-1_R1.fastq.gz,data/HSL-1_R2.fastq.gz\n'
        'HSL-2,wt_control_rep2,data/HSL-2_R1.fastq.gz,data/HSL-2_R2.fastq.gz\n'
        'HSL-3,wt_DMSO_rep1,data/HSL-3_R1.fastq.gz,data/HSL-3_R2.fastq.gz\n'
        'HSL-4,wt_DMSO_rep2,data/HSL-4_R1.fastq.gz,data/HSL-4_R2.fastq.gz'
    )
    out_file = 'PE_design_good_parsed.csv'
    out_text = open(out_file).read().rstrip()
    assert out_text == expected

    # cleanup
    if os.path.isfile(out_file):
        os.remove(out_file)


# --------------------------------------------------
def test_bam():
    """bam"""

    rv, out = getstatusoutput(f'{prg} bam_design_good.csv')

    # check status
    assert rv == 0
    assert out == ''

    # check output file
    expected = (
        'lib_ID,sample_rep,bam,tool_IDs\n'
        'HSL-1,wt_control_rep1,data/HSL-1.bam,bt2_sSR\n'
        'HSL-2,wt_control_rep2,data/HSL-2.bam,bt2_sSR\n'
        'HSL-3,wt_DMSO_rep1,data/HSL-3.bam,bwM\n'
        'HSL-4,wt_DMSO_rep2,data/HSL-4.bam,'
    )
    out_file = 'bam_design_good_parsed.csv'
    out_text = open(out_file).read().rstrip()
    assert out_text == expected

    # cleanup
    if os.path.isfile(out_file):
        os.remove(out_file)
    