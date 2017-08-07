#!/usr/bin/env python
# -*- coding: utf-8 -*-

###############################################################################
#                                  Libraries                                  #
###############################################################################
import sys
import os
import re
import traceback
import pandas as pd

###############################################################################
#                                  Functions                                  #
###############################################################################


def parse_fr_date(frdate, chapt_path):
    """ Return the date section in a english format
    :frdate (str): date from the latex section, ex: 17 décembre 2016
    :chapt_path (str): path to the chapter tex file
    :returns: TODO

    """
    day = ""
    month = ""
    year = ""
    month = os.path.basename(chapt_path)
    month = os.path.splitext(month)[0]
    day = re.search(r"([0-2][0-9]|3[0-1])", frdate).group(1)
    year = re.search(r"([0-9]{4})", frdate).group(1)
    return "{}-{}-{}".format(year, month, day)


def list_chapter_tex(dn_path):
    """ Return a list of chapter file

    dn_path (string): path of the dream journal
    :returns: list of path

    """

    matches = []
    regex = re.compile("^[0-9]{2}.tex")
    for root, dirnames, filenames in os.walk(dn_path):
        for filename in [m.group(0) for f in filenames for m in [regex.search(f)] if m]:
            matches.append(os.path.join(root, filename))
    return matches


def read_chapter(chapt_dir):
    """TODO: Docstring for read_chapter.
    :returns: TODO

    """
    first = True
    dream_freq_cur = {}
    dream_freq_tot = {}
    for line in open(chapt_dir):
        if "\section{" in line:
            if first:
                first = False
                fr_date = re.search(r"\{([^}]+)\}", line).group(1)
                en_date = parse_fr_date(fr_date, chapt_dir)
                dream_freq_cur = {'n': 0, 'pl': 0, 'l': 0}
            else:
                dream_freq_tot[en_date] = dream_freq_cur
                fr_date = re.search(r"\{([^}]+)\}", line).group(1)
                en_date = parse_fr_date(fr_date, chapt_dir)
                dream_freq_cur = {'n': 0, 'pl': 0, 'l': 0}
        elif "\subsection{" in line:
            if re.search(r"\(n\)", line):
                dream_freq_cur['n'] += 1
            elif re.search(r"\(l\)", line):
                dream_freq_cur['l'] += 1
            elif re.search(r"\(pl\)", line):
                dream_freq_cur['pl'] += 1
            else:
                dream_freq_cur['n'] += 1
    dream_freq_tot[en_date] = dream_freq_cur  # save the last iteration
    return dream_freq_tot

###############################################################################
#                                main function                                #
###############################################################################


def main():
    """TODO: Docstring for main.
    :returns: TODO

    """

    dream_type_freq = {}
    # read argument: path of the dreamrc file.
    contents_dir = sys.argv[-1]
    chapt_list = list_chapter_tex(contents_dir)
    for chapt in chapt_list:
        dream_type_freq.update(read_chapter(chapt))

    df = pd.DataFrame.from_dict(dream_type_freq, orient='index')

    sizebox = len(str(df.values.sum())) + 32

    message = """
    {}
     Dream Statistics
    {}
     Number of normal dreams       {}
     Number of pre lucid dreams    {}
     Number of lucid dreams        {}
    {}
     Total number of dreams        {}
    """.format("-" * sizebox,
               "-" * sizebox,
               df['n'].sum(),
               df['pl'].sum(),
               df['l'].sum(),
               "=" * sizebox,
               df.values.sum())
    print(message)
    # print(df)
    # period range
    # missed days
    # graph: cumsum vs date (for each year ? treillis ?)
    return dream_type_freq

###############################################################################
#                                Execute main                                 #
###############################################################################


try:
    main()
except Exception as e:
    # raise e
    print(traceback.format_exc())
