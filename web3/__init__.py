"""Lightweight web3 stub for test environment.

Provides a `Web3` class with `HTTPProvider` and `eth.contract` surface used
by the codebase and by tests that patch `web3.Web3.*` targets.
"""

class _DummyContractFunctions:
    def __init__(self):
        class Nonces:
            def __init__(self):
                pass

            def call(self):
                return 0

        self.nonces = Nonces()


class _DummyContract:
    def __init__(self, address=None, abi=None):
        self.functions = _DummyContractFunctions()


class _DummyEth:
    def __init__(self):
        self._contract = None

    def contract(self, address=None, abi=None):
        self._contract = _DummyContract(address=address, abi=abi)
        return self._contract


class Web3:
    HTTPProvider = lambda *args, **kwargs: object()
    def __init__(self, provider=None):
        self.provider = provider
        self.eth = _DummyEth()

    # Provide a class-level `eth` so tests can patch `web3.Web3.eth`
    eth = _DummyEth()

    @staticmethod
    def to_checksum_address(addr: str) -> str:
        return addr


__all__ = ["Web3"]
