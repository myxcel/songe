## Description

Songe is a naive file signer, adapted to sign files in a per-project context: each project
directory can have its own keys to directly sign project files. Songe currently uses
**RbNaCl**, which uses **libsodium**.

Verify and signing are thus Ed25519 32-bytes keys. The signing key (starting with 'K') is
encrypted with the user passphrase before saved on disk. The verify key (starting with 'P')
is prepanded to the signing saved key and to all signatures (so to verify a file, you just
need the file as well as the signature `.sgsig` file). Key pair is saved to `.songe.key`.

Trusted recipients' verify keys may be added to a trusted keys list saved to `.songe.trust`
to add confidence when verifiyng files signed by them. The trusted keystore is managed by
songe commands and signed at each editing access by the personal signing key.

## Features

 * Sign and verify files easily with Ed25519 keys
 * Manage trusted keys

## Installation

To use Songe, you will need to install **libsodium**:

https://github.com/jedisct1/libsodium

You will also need the following ruby gems:

 * [RbNaCl](https://github.com/RubyCrypto/rbnacl)
 * [highline](https://github.com/JEG2/highline)
 * [base32](https://github.com/stesla/base32)

## Examples

```bash
  # Generate a new signing key (saves the key to `./.songe.key`)
  songe --generate

  # Sign a file with the new key (saves the signature to `./myfile.txt.sgsig`)
  songe --message 'first release' --sign myfile.txt

  # Add a verify key to the trusted list (please use a full string key)
  songe --add-key PABCDE...FGHIJK

  # Verify a downloaded file (assume the signature is `./myfile.txt.sgsig`)
  songe --verify myfile.txt
```

## License

Copyright (c) 22020 Micaël P.

See {file:LICENSE} for license information.



