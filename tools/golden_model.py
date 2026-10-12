"""Bit-exact software model for the educational RTL ISP pixel pipeline."""
from __future__ import annotations


def pixel(r: int, g: int, b: int, gain_q4: int = 16, threshold: int = 128) -> tuple[int, int]:
    for value in (r, g, b, gain_q4, threshold):
        if not isinstance(value, int) or not (0 <= value <= 255):
            raise ValueError('all inputs must be integers from 0 through 255')
    luma = (77 * r + 150 * g + 29 * b + 128) >> 8
    adjusted = min(255, (luma * gain_q4) >> 4)
    return adjusted, int(adjusted >= threshold)
