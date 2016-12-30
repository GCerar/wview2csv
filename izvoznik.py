#!/usr/bin/env python2
# -*- coding: UTF-8 -*-

"""
Dokumentacija:
--------------

Z velikimi crkami so napisane rezervirane besede/funkcionalnosti SQL jezika.
To je samo zaradi preglednosti; SQL ne loci med `DATETIME()` in `datetime()`

Podatek `dateTime` pretvori iz unixtime (int32) v string, ki je v lokalnem casu.
Zapis bo v obliki ISO8601. Berljiv cloveku in lahko ga sortiramo, ceprav je string.

°F => °C ---- (F - 32) * (5/9)

ROUND(real vrednost, int decimalna_mesta)
"""

# Za vsak primer, ce bos delal s Python2.7 in nizjim
from __future__ import division, print_function, unicode_literals

import logging

# Parsanje parametrov
import sys, getopt

from os import path

# SQLite3 modul, ki je del Pythona
import sqlite3

# Manipuliranje z *.csv datotekam (za Excel podobna zadeva)
import csv

# Enostavno delo s casom
from datetime import datetime, timedelta


# Metapodatki projekta
__author__ = 'Matic Cankar, Gregor Cerar'
__copyright__ = 'Copyright 2016, Matic Cankar'

__version__ = (1, 5, 0)
__maintainer__ = 'Gregor Cerar'
__email__ = 'grega90@gmail.com'
__status__ = 'Development'


# Logging format
FORMAT = '%(asctime)-15s - %(levelname)-6s - %(message)s'
DT_FORMAT = '%Y-%m-%d %H:%M:%S'

# Logging:
formatter = logging.Formatter(FORMAT, DT_FORMAT)

ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
ch.setFormatter(formatter)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(ch)


# SQL stavki


def extract_data(db_path, hilow_db_path, year_month):
    # SQL queries
    query_script = open('./queries/archive_query.sql').read()
    query_script = query_script.format(year_month=year_month, hilow_db_path=hilow_db_path)

    logger.debug('Accessing SQLite3 file.')
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    cur.executescript(query_script)

    cur.execute('SELECT * FROM allData')
    rezultat = cur.fetchall()
    opis = map(lambda x: x[0], cur.description)


    conn.commit()
    conn.close()
    return rezultat, opis


def write_data(vrstice, year_month, station_name, opis=[], output_directory='./'):
    output_directory = path.abspath(output_directory)
    ime_csv_datoteke = '%s-%s.csv' % (year_month, station_name)

    lokacija_datoteke = path.join(output_directory, ime_csv_datoteke)
    logger.debug('Building CSV file.')

    with open(lokacija_datoteke, 'wb') as csvfile:
        pisanje = csv.writer(csvfile)
        pisanje.writerow(opis)  # Prva vrstica = imena stolpcev
        for vrstica in vrstice:
            pisanje.writerow(vrstica)


if __name__ == '__main__':
    HELP_MESSAGE = '''
        Arguments:

        -d, --debug     Show debug messages. Default: False
        -h, --help      Prints this message
        -t, --time=     (YYYY-MM) Export data for specific month. Default is previous month
        -l, --label=     Label or name of weather station. Example: Lubnik

        -i, --input=    (REQUIRED) Path to SQLite3 database file. Example: ./wview-archive.sdb
            --hilow=    (REQUIRED) Path to SQLite3 database. Example: ./wview-hilow.sdb
        -o, --output=   Path to output directory for processed files. Default is scripts directory
    '''

    INPUT_DATABASE = None
    HILOW_DATABASE = None
    OUTPUT_DIRECTORY = None
    YEAR_MONTH = None
    STATION_NAME = ''

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'i:o:t:l:dh', ['input=', 'hilow=', 'output=', 'time=', 'location=', 'debug', 'help'])
    except getopt.GetoptError:
        print(HELP_MESSAGE)
        sys.exit(2)

    for opt, arg in opts:

        if opt in ('-h', '--help'):
            print(HELP_MESSAGE)
            sys.exit()

        elif opt in ('-d', '--debug'):
            logger.setLevel(logging.DEBUG)
            ch.setLevel(logging.DEBUG)
            logger.debug('DEBUG mode ...')

        elif opt in ('-i', '--input'):
            INPUT_DATABASE = arg

        elif opt in ('--hilow', ):
            HILOW_DATABASE = arg

        elif opt in ('-o', '--output'):
            OUTPUT_DIRECTORY = arg

        elif opt in ('-t', '--time'):
            YEAR_MONTH = arg.replace('.', '-')

        elif opt in ('-l', '--location'):
            STATION_NAME = arg


    if not INPUT_DATABASE:
        print('-i or --input= is required.')
        print(HELP_MESSAGE)
        sys.exit(2)

    if not HILOW_DATABASE:
        print('--hilow= is required.')
        print(HELP_MESSAGE)
        sys.exit(2)

    if not OUTPUT_DIRECTORY:
        OUTPUT_DIRECTORY = './'

    if not YEAR_MONTH:
        ts = datetime.now().replace(day=1) - timedelta(days=1)
        YEAR_MONTH = ts.strftime('%Y-%m')


    logger.info('Input database is:\t\t%s', INPUT_DATABASE)
    logger.info('Output directory will be:\t%s', OUTPUT_DIRECTORY)
    logger.info('Will look for month:\t\t%s', YEAR_MONTH)

    # Do the job
    rezultat, opis = extract_data(db_path=INPUT_DATABASE, hilow_db_path=HILOW_DATABASE, year_month=YEAR_MONTH)
    write_data(rezultat, opis=opis, station_name=STATION_NAME, year_month=YEAR_MONTH, output_directory=OUTPUT_DIRECTORY)
    logger.debug('Extraction is complete.')






