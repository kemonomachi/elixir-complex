import erlport.erlang
import itertools

def setup():
    erlport.erlang.set_encoder(encoder)
    erlport.erlang.set_decoder(decoder)

    return erlport.erlterms.Atom(b'ok')

def encoder(value):
    if isinstance(value, complex):
        value = (value.real, value.imag)

    return value

def decoder(value):
    if isinstance(value, tuple) and value[0] == b'complex':
        value = complex(value[1], value[2])

    return value

