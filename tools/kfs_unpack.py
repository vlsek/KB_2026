#!/usr/bin/env python3
"""Распаковщик .kfs (формат King's Bounty / Katauri). .kfs = обычный ZIP.
Использование: python tools/kfs_unpack.py <файл.kfs> [папка_вывода]
Без папки вывода — только список файлов. Имена в cp437/utf-8 не требуют перекодировки.
"""
import sys, zipfile, os

def main():
    if len(sys.argv) < 2:
        print(__doc__); return 1
    z = zipfile.ZipFile(sys.argv[1])
    if len(sys.argv) < 3:
        for i in z.infolist():
            print(f"{i.file_size:>10}  {i.filename}")
        return 0
    out = sys.argv[2]
    z.extractall(out)
    print(f"{len(z.namelist())} файлов -> {out}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
