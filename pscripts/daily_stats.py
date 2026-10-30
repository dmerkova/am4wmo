#!/usr/bin/env python3
"""Run daily aircraft monitoring stats for temperature, wind, or humidity.

Examples:
  python daily_stats.py --date 2024010100 --type temp
  python daily_stats.py --date 2024010100 --type wind
  python daily_stats.py --date 2024010100 --type humidity
  python daily_stats.py --date 2024010100 --type temp --type wind --type humidity
"""

import argparse
import os
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from netCDF4 import Dataset, chartostring


BASE_DIR = Path(os.environ.get('DIAGFILES', '.'))
OUTPUT_ROOT = Path(os.environ.get('AM4WMO_DATA_ROOT', Path('/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/MONaircft') / 'data'))


def station_ids(stid):
    try:
        values = chartostring(stid[:])
    except Exception:
        values = [i.tobytes(fill_value='/////', order='C') for i in stid]
        values = np.array([''.join(i.decode('UTF-8', 'ignore').split()) for i in values])
    return values


def build_frame(dataset, obs_fields, label):
    lats = dataset.variables['Latitude']
    lons = dataset.variables['Longitude']
    prs = dataset.variables['Pressure']
    stid = dataset.variables['Station_ID']
    obstype = dataset.variables['Observation_Type']
    dtime = dataset.variables['Time']
    nobs = len(lats)

    def safe_var(name, fill_value=0):
        if name in dataset.variables:
            return dataset.variables[name][:]
        return np.full(nobs, fill_value, dtype=np.int32)

    iuse = safe_var('Analysis_Use_Flag')
    puse = safe_var('Prep_Use_Flag')
    prepqc = safe_var('Prep_QC_Mark')
    setupqc = safe_var('Setup_QC_Mark')

    stnids = station_ids(stid)

    frames = [
        pd.DataFrame(data=lons[:], columns=['lon']),
        pd.DataFrame(data=lats[:], columns=['lat']),
        pd.DataFrame(data=obstype[:], columns=['obstype']),
        pd.DataFrame(data=dtime[:], columns=['dtime']),
        pd.DataFrame(data=stnids[:], columns=['sid']),
        pd.DataFrame(data=prs[:], columns=['prs']),
        pd.DataFrame(data=iuse, columns=['iuse']),
        pd.DataFrame(data=puse, columns=['puse']),
        pd.DataFrame(data=prepqc, columns=['prepqc']),
        pd.DataFrame(data=setupqc, columns=['setupqc']),
    ]

    for field_name, var in obs_fields.items():
        frames.append(pd.DataFrame(data=var[:], columns=[field_name]))

    df = pd.concat(frames, axis=1)
    return df


def finalize_output(df, data_cols, mydate):
    df = df.copy()
    if 'dtime' not in df.columns:
        df['dtime'] = mydate
    if 'id' not in df.columns:
        df.insert(0, 'id', np.arange(len(df), dtype=int))
    desired = ['id', 'lon', 'lat', 'obstype', 'dtime', 'sid', 'prs'] + list(data_cols) + ['iuse', 'puse', 'setupqc', 'prepqc']
    existing = [c for c in desired if c in df.columns]
    return df[existing]


def run_temperature(mydate):
    ncfile = BASE_DIR / f'diag_conv_t_ges.{mydate}.nc4'
    with Dataset(ncfile, mode='r') as fh:
        obs_fields = {
            'obs': fh.variables['Observation'],
            'omf': fh.variables['Obs_Minus_Forecast_adjusted'],
            'pof': fh.variables['Data_Pof'],
        }
        df = build_frame(fh, obs_fields, 'temperature')

    month = mydate[4:6]
    outdir = OUTPUT_ROOT / month
    outdir.mkdir(parents=True, exist_ok=True)

    df131 = finalize_output(df[df['obstype'] == 131].copy(), ['omf', 'obs', 'pof'], mydate)
    df133 = finalize_output(df[df['obstype'] == 133].copy(), ['omf', 'obs', 'pof'], mydate)

    df131.to_csv(outdir / f'd131-t{mydate}.csv', index=False)
    df133.to_csv(outdir / f'd133-t{mydate}.csv', index=False)
    print(f'Wrote temperature files for {mydate}')


def run_wind(mydate):
    ncfile = BASE_DIR / f'diag_conv_uv_ges.{mydate}.nc4'
    with Dataset(ncfile, mode='r') as fh:
        obs_fields = {
            'obsu': fh.variables['u_Observation'],
            'obsv': fh.variables['v_Observation'],
            'omfu': fh.variables['u_Obs_Minus_Forecast_adjusted'],
            'omfv': fh.variables['v_Obs_Minus_Forecast_adjusted'],
        }
        df = build_frame(fh, obs_fields, 'wind')

    month = mydate[4:6]
    outdir = OUTPUT_ROOT / month
    outdir.mkdir(parents=True, exist_ok=True)

    df231 = finalize_output(df[df['obstype'] == 231].copy(), ['omfv', 'omfu', 'obsu', 'obsv'], mydate)
    df233 = finalize_output(df[df['obstype'] == 233].copy(), ['omfv', 'omfu', 'obsu', 'obsv'], mydate)

    df231.to_csv(outdir / f'd231-w{mydate}.csv', index=False)
    df233.to_csv(outdir / f'd233-w{mydate}.csv', index=False)
    print(f'Wrote wind files for {mydate}')


def run_humidity(mydate):
    ncfile = BASE_DIR / f'diag_conv_q_ges.{mydate}.nc4'
    with Dataset(ncfile, mode='r') as fh:
        obs_fields = {
            'obs': fh.variables['Observation'],
            'omf': fh.variables['Obs_Minus_Forecast_adjusted'],
        }
        df = build_frame(fh, obs_fields, 'humidity')

    month = mydate[4:6]
    outdir = OUTPUT_ROOT / month
    outdir.mkdir(parents=True, exist_ok=True)

    df133 = finalize_output(df[df['obstype'] == 133].copy(), ['omf', 'obs'], mydate)
    df133.to_csv(outdir / f'd133-q{mydate}.csv', index=False)
    print(f'Wrote humidity files for {mydate}')


def parse_args():
    parser = argparse.ArgumentParser(description='Generate daily aircraft monitoring stats.')
    parser.add_argument('--date', required=True, help='YYYYMMDDHH timestamp, example: 2024010100')
    parser.add_argument(
        '--type',
        dest='types',
        action='append',
        choices=['temp', 'wind', 'humidity'],
        default=[],
        help='Stat type to run. Repeat for multiple types. Defaults to all three.',
    )
    return parser.parse_args()


def main():
    args = parse_args()
    selected = args.types or ['temp', 'wind', 'humidity']

    for kind in selected:
        if kind == 'temp':
            run_temperature(args.date)
        elif kind == 'wind':
            run_wind(args.date)
        elif kind == 'humidity':
            run_humidity(args.date)

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
