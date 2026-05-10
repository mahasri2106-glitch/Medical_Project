from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "apps" / "api"))

from medbill_api.main import app, run  # noqa: E402


if __name__ == "__main__":
    run()
