Complex
=======

Functions for working with complex numbers.

A complex number is represented by the struct `%Complex{}`, with the real part
under key `:r` and the imaginary part under key `:i`.

All functions except `Complex.cis/1` can take any combination of `Complex` and
`number` inputs.

##Operators

Calling
```elixir
use Complex.Operators
```
will replace the builtin operators with their corresponding complex versions.
This is probably a **BAD IDEA**, but it's convenient when you just want to hack
out some code. **Use at your own risk**.

##Testing

Python is required for testing. All tested functions are called on lists
of random inputs. The outputs are compared against the outputs of the
corresponding Python methods.

##License

Copyright © 2015 Ookami Kenrou \<ookamikenrou@gmail.com\>

This work is free. You can redistribute it and/or modify it under the terms of
the Do What The Fuck You Want To Public License, Version 2, as published by
Sam Hocevar. See the LICENSE file or the [WTFPL homepage](http://www.wtfpl.net)
for more details.

