import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from golden_model import pixel
from make_vectors import write_vectors


class TestGoldenModel(unittest.TestCase):
    def test_black(self):
        self.assertEqual(pixel(0, 0, 0), (0, 0))

    def test_white(self):
        self.assertEqual(pixel(255, 255, 255, threshold=255), (255, 1))

    def test_zero_gain(self):
        self.assertEqual(pixel(255, 255, 255, gain_q4=0, threshold=1), (0, 0))

    def test_saturation(self):
        self.assertEqual(pixel(255, 255, 255, gain_q4=255), (255, 1))

    def test_threshold_inclusive(self):
        self.assertEqual(pixel(128, 128, 128, threshold=128), (128, 1))

    def test_invalid(self):
        with self.assertRaises(ValueError):
            pixel(-1, 0, 0)

    def test_vector_count(self):
        import tempfile
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'vectors.txt'
            write_vectors(path, 30, 42)
            self.assertEqual(len(path.read_text().splitlines()), 40)

if __name__ == '__main__':
    unittest.main()
