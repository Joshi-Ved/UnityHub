# Minimal stub of PIL Image functionality used by tests.
# Provides Image.new(...).save(buffer, format="PNG") that writes a tiny valid PNG.

class _SimpleImage:
    def __init__(self, mode, size, color=None):
        self.mode = mode
        self.size = size
        self.color = color

    def save(self, buffer, format=None):
        # A 1x1 transparent PNG (valid PNG bytes)
        png_bytes = (
            b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89"
            b"\x00\x00\x00\x0cIDATx\x9cc```\x00\x00\x00\x04\x00\x01\x0d\n\x2d\xb4\x00\x00\x00\x00IEND\xaeB`\x82"
        )
        buffer.write(png_bytes)


def new(mode, size, color=None):
    return _SimpleImage(mode, size, color)

class Image:
    new = staticmethod(new)
