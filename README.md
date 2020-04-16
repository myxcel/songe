## Description

Songe is a naive file signer and verifier, adapted to sign files in a per-project context:
each project directory can have its own keys to directly sign project files. Songe currently
uses **RbNaCl**, which uses **libsodium**. A light version, Songev, only allow to quick
verify signatures, doesn't use **RbNaCl**, but the light **Ed25519** library.

Verify and signing are thus Ed25519 32-bytes keys. The signing key (starting with 'K') is
encrypted with the user passphrase before saved on disk. The verify key (starting with 'P')
is joined to the signing key saved on disk and to all signatures (so to verify a file, you
just need the file and the signature `.sgsig` file). Key pair is saved to `.songe.key`.

Trusted recipients' verify keys may be added to a trusted keys list saved to `.songe.trust`
to add confidence when verifiyng files signed by them. The trusted keystore is managed by
songe commands and signed at each editing access by the personal signing key. Although the
trust keystore is signed, it is up to the user to check the recipient's key.

## Features

 * Sign and verify files easily with Ed25519 keys
 * Manage trusted keys

## Installation

You will need to install the following library / ruby gems:

For the full version **songe**

 * [libsodium](https://github.com/jedisct1/libsodium)
 * [RbNaCl](https://github.com/RubyCrypto/rbnacl)
 * [digest-crc](https://github.com/postmodern/digest-crc)
 * [highline](https://github.com/JEG2/highline)
 * [base32](https://github.com/stesla/base32)

For the light (verify only) version **songev**

 * [ed25519](https://github.com/RubyCrypto/ed25519)
 * [digest-crc](https://github.com/postmodern/digest-crc)
 * [base32](https://github.com/stesla/base32)

## Usage examples

```bash
  # Generate a new signing key (writes the key to `./.songe.key`)
  songe --generate

  # Sign a file with the new key (writes the signature to `./myfile.txt.sgsig`)
  songe --message 'first release' --sign 'myfile.txt'

  # Add a verify key to the trusted list (please use a full string key)
  songe --add-key PABCDE...FGHIJK

  # Verify a downloaded file `yourfile.txt` (signature is `./yourfile.txt.sgsig`)
  songe --verify 'yourfile.txt'
  songe --verbose --verify 'yourfile.txt'   # displays more information
  # or for the songev version
  songev 'yourfile.txt'
```

## License

Copyright (c) 2020 Micaël P. - Distributed under the MIT License.

See [LICENSE](https://github.com/CodeEspritLibre/songe/blob/master/LICENSE) for further details.

