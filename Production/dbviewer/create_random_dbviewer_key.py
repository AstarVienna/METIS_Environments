#!/usr/bin/env python3
"""Create a random key to encrypt dbviewer sessions."""
import random
import base64
print(base64.b64encode(random.randbytes(16)).decode(), end="")
