"""Generate reproducible RGB stimulus + golden expected outputs for HDL simulation."""
from __future__ import annotations
import argparse
import random
from pathlib import Path
from golden_model import pixel


def write_vectors(path: Path, count: int, seed: int) -> None:
    rng = random.Random(seed)
    corners = [
        (0, 0, 0, 16, 0), (255, 255, 255, 16, 255),
        (255, 0, 0, 16, 128), (0, 255, 0, 16, 128),
        (0, 0, 255, 16, 128), (255, 255, 255, 255, 128),
        (255, 255, 255, 0, 0), (128, 128, 128, 16, 128),
        (1, 1, 1, 16, 1), (255, 255, 255, 16, 0),
    ]
    samples = corners + [tuple(rng.randrange(256) for _ in range(5)) for _ in range(count)]
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8') as fp:
        for r, g, b, gain, threshold in samples:
            lum, bright = pixel(r, g, b, gain, threshold)
            fp.write(f'{r:02x} {g:02x} {b:02x} {gain:02x} {threshold:02x} {lum:02x} {bright:x}\n')
    print(f'Wrote {len(samples)} vectors to {path}')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--count', type=int, default=1000, help='additional random vectors')
    parser.add_argument('--seed', type=int, default=42)
    parser.add_argument('--output', type=Path, default=Path('tb/vectors.txt'))
    args = parser.parse_args()
    if args.count < 0:
        parser.error('--count must be non-negative')
    write_vectors(args.output, args.count, args.seed)

if __name__ == '__main__':
    main()
