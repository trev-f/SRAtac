#!/usr/bin/env python3
"""
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-02-06
Purpose: Parse input design file for nextflow pipeline
"""

import argparse
import sys
import os
# import pytest


# --------------------------------------------------
def get_args():
    """Get command-line arguments"""

    parser = argparse.ArgumentParser(
        description='Parse input design file for nextflow pipeline',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        'design',
        metavar='DESIGN',
        nargs='+',
        type=argparse.FileType('rt'),
        help='Input csv design file'
    )


    args = parser.parse_args()

    return args


# --------------------------------------------------
def main():
    """main program"""

    args = get_args()

    for in_fh in args.design:

        # read design file into a list of lists
        dsgn_in = [line.rstrip().split(',') for line in in_fh]

        # pull header into its own object
        header_in = dsgn_in.pop(0)

        # check header and get output header
        header_out, in_type = check_header(header=header_in)

        if in_type == 'reads':
            # check read types are all the same
            check_read_type(header=header_in, design=dsgn_in)

            # create output design
            dsgn_out = organize_reads(dsgn_in)
        
        elif in_type == 'alignments':
            # create output design
            dsgn_out = organize_alignments(dsgn_in)

        # write output to file
        outfile = f'{os.path.splitext(in_fh.name)[0]}_parsed.csv'
        out_fh = open(outfile, 'wt')
        out_fh.write(f'{header_out}\n{dsgn_out}\n')
        out_fh.close()


# --------------------------------------------------
def print_error(error, context):
    """Print error message"""

    error_msg = f"ERROR: Samplesheet -> {error}\n\tLINE: {context}"
    sys.exit(error_msg)


def test_print_error():
    """Test print_error"""

    error_str = f"ERROR: Samplesheet -> Invalid number of columns.\n\tLINE: wt_L1,HSL-1.fastq.gz"

    with pytest.raises(SystemExit) as out:
        print_error(error="Invalid number of columns.", context="wt_L1,HSL-1.fastq.gz")

    assert out.type == SystemExit
    assert out.value.code == error_str


# --------------------------------------------------
def check_header(header):
    """
    Check design file has proper header format:

    lib_ID,sample_name,replicate,reads1,reads2

    Note: reads2 column is optional to handle single end reads
    Note: also take bam input header
    """

    VALID_HEADERS =[
        'lib_ID,sample_name,replicate,reads1'.split(','),
        'lib_ID,sample_name,replicate,reads1,reads2'.split(','),
        'lib_ID,sample_name,replicate,bam,tool_IDs'.split(',')
    ]

    if header not in VALID_HEADERS:
        print_error(error="Missing or invalid header.", context=','.join(header))
    elif header == VALID_HEADERS[0]:
        return "lib_ID,sample_rep,fq1", 'reads'
    elif header == VALID_HEADERS[1]:
        return "lib_ID,sample_rep,fq1,fq2", 'reads'
    elif header == VALID_HEADERS[2]:
        return "lib_ID,sample_rep,bam,tool_IDs", 'alignments'


def test_check_header():
    """Test check_header"""

    # test no or incorrect header
    error_str = f"ERROR: Samplesheet -> Missing or invalid header.\n\tLINE: HSL-1,wt_control,1,data/HSL-1_R1.fastq.gz"
    with pytest.raises(SystemExit) as out:
        check_header(['HSL-1', 'wt_control', '1', 'data/HSL-1_R1.fastq.gz']) 
    assert out.type == SystemExit
    assert out.value.code == error_str

    # test correct header output
    assert check_header(['lib_ID', 'sample_name', 'replicate', 'reads1']) == ("lib_ID,sample_rep,fq1", 'reads')
    assert check_header(['lib_ID', 'sample_name', 'replicate', 'reads1', 'reads2']) == ("lib_ID,sample_rep,fq1,fq2", 'reads')
    assert check_header(['lib_ID', 'sample_name', 'replicate', 'bam', 'tool_IDs']) == ("lib_ID,sample_rep,bam,tool_IDs", 'alignments')


# --------------------------------------------------
def check_read_type(header: list, design: list):
    """
    Check that all read types are the same i.e. all single end or all paired end reads
    """

    # get number of columns in header and design rows
    header_len = len(header)
    design_lens = [len(line) for line in design]

    if all(design_len == header_len for design_len in design_lens):
        return
    else:
        design_bad = filter(lambda dsgn: len(dsgn) != header_len, design)
        print_error(error = "Mixed read types.", context = '\n\t'.join([','.join(x) for x in design_bad])) 


def test_check_read_type():
    """test check_read_type"""

    # test mix of read types
    error_str = f"ERROR: Samplesheet -> Mixed read types.\n\tLINE: HSL-3,wt_DMSO,1,data/HSL-3_R1.fastq.gz,data/HSL-3_R2.fastq.gz\n\tHSL-4,wt_DMSO,2,data/HSL-4_R1.fastq.gz,data/HSL-4_R2.fastq.gz"
    with pytest.raises(SystemExit) as out:
        check_read_type(header=['lib_ID', 'sample_name', 'replicate', 'reads1'], design=[['HSL-3', 'wt_DMSO', '1', 'data/HSL-3_R1.fastq.gz', 'data/HSL-3_R2.fastq.gz'], ['HSL-4', 'wt_DMSO', '2', 'data/HSL-4_R1.fastq.gz', 'data/HSL-4_R2.fastq.gz']])
    assert out.type == SystemExit
    assert out.value.code == error_str


# --------------------------------------------------
def organize_reads(design: list):
    """
    Organize reads 
    """

    samples = []

    for sample in design:
        reads = ','.join(sample[3:])
        samples.append(f'{sample[0]},{sample[1]}_rep{sample[2]},{reads}')

    return '\n'.join(samples)


def test_organize_reads():
    """test organize_reads"""

    SE_design = [['HSL-3', 'wt_DMSO', '1', 'data/HSL-3_R1.fastq.gz'], ['HSL-4', 'wt_DMSO', '2', 'data/HSL-4_R1.fastq.gz']]
    SE_expected = ('HSL-3,wt_DMSO_rep1,data/HSL-3_R1.fastq.gz\n'
                   'HSL-4,wt_DMSO_rep2,data/HSL-4_R1.fastq.gz')
    PE_design = [['HSL-3', 'wt_DMSO', '1', 'data/HSL-3_R1.fastq.gz', 'data/HSL-3_R2.fastq.gz'], ['HSL-4', 'wt_DMSO', '2', 'data/HSL-4_R1.fastq.gz', 'data/HSL-4_R2.fastq.gz']]
    PE_expected = ('HSL-3,wt_DMSO_rep1,data/HSL-3_R1.fastq.gz,data/HSL-3_R2.fastq.gz\n'
                   'HSL-4,wt_DMSO_rep2,data/HSL-4_R1.fastq.gz,data/HSL-4_R2.fastq.gz')
                   
    assert organize_reads(design=SE_design) == SE_expected.strip()
    assert organize_reads(design=PE_design) == PE_expected.strip()


# --------------------------------------------------
def organize_alignments(design: list):
    """
    Organize alignments
    """

    samples = []

    for sample in design:
        samples.append(f'{sample[0]},{sample[1]}_rep{sample[2]},{sample[3]},{sample[4]}')
    
    return '\n'.join(samples)


def test_organize_alignments():
    """test organize_alignments"""

    bam_design = [
        ['HSL-3', 'wt_DMSO', '1', 'data/HSL-3.bam', 'bwM'],
        ['HSL-4', 'wt_DMSO', '2', 'data/HSL-4.bam', '']
    ]
    bam_expected = (
        'HSL-3,wt_DMSO_rep1,data/HSL-3.bam,bwM\n'
        'HSL-4,wt_DMSO_rep2,data/HSL-4.bam,'
    )

    assert organize_alignments(design=bam_design) == bam_expected.strip()

# --------------------------------------------------
if __name__ == '__main__':
    main()
