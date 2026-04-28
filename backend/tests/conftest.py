import os
import sys

# Ensure the backend package directory is on sys.path when running tests
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

# Also add repository root so top-level stubs (e.g., google/) are importable
REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)

import asyncio
import inspect


def pytest_pyfunc_call(pyfuncitem):
    """Run async test functions without pytest-asyncio by executing them
    on a temporary event loop. Returns True when the item was executed.
    """
    testfunc = pyfuncitem.obj
    if inspect.iscoroutinefunction(testfunc):
        loop = asyncio.new_event_loop()
        try:
            asyncio.set_event_loop(loop)
            loop.run_until_complete(testfunc(**pyfuncitem.funcargs))
            return True
        finally:
            loop.close()

