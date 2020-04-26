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

 * Sign and verify files easily with Ed25519 keys (detached or embedded signatures)
 * Manage a keystore of trusted recipients public keys

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

## Simple usage examples

```bash
  # Generate a new signing key (writes the key to `./.songe.key`)
  # The first asks for a choosing a passphrase, the second generates a secure one
  songe --generate
  songe --secure --generate

  # Or import an existing signing key (then paste the key KABCDE...)
  songe --import-key

  # With a signing key available, display at any time the verification key...
  songe --verifkey
  # ... or even the signing key (then enter the passphrase)
  songe --signkey

  # Sign a file with the new key (writes the signature to `./myfile.txt.sgsig`)
  # The second signs with a signed comment, the third make an embedded signature
  songe --sign 'myfile.txt'
  songe --verbose --sign 'myfile.txt'       # displays more information
  songe --message 'first release' --sign 'myfile.txt'
  songe --embed --sign 'myfile.txt'
  # Real example of embedded signature (only share the file `SHA256SUM.sgsig`)
  sha256sum files.* > SHA256SUM && songe --embed --sign SHA256SUM && rm SHA256SUM

  # Add the sender verify key to the trusted list (please use a full string key)
  songe --add-key PABCDE...FGHIJK
  # Yes you can manage the trusted keystore
  songe --trusted             # lists all trusted keys
  songe --trusted ABCD        # lists trusted keys containing `ABCD`
  songe --del-key PABCDE...   # deletes the key from the trusted list

  # Verify a downloaded file `yourfile.txt` (signature is `./yourfile.txt.sgsig`)
  songe --verify 'yourfile.txt'
  songe --verbose --verify 'yourfile.txt'   # displays more information
  # Or verify an embedded signature
  songe --verify 'yourfile.txt'             # yes, it is the same command
  # And for the songev version
  songev 'yourfile.txt'
  # Real example of embedded signature (you only got one file `SHA256SUM.sgsig`)
  songev SHA256SUM | sha256sum --check      # yes, that's all!
```

## Questions

Should I use `songe` or `songev` ?

If you can (and want to) install *libsodium*, then use *songe*, otherwise or if you just
have to verify signatures, use *songev*.

I sign file in embedded signature (`--embed` option), and the verification fails. Why?

In the embedded mode, the signature requires a file (can not be signed from `stdin`) but the
verification first checks if a file without `.sgsig` extension exists, and if not, uses the
embedded data in signature file. So checking an embedded signature requires that **no**
original file name remains in the same directory.

## Check scripts integrity

First, commits are signed with PGP key `6F9F 349C D9DB 0B1A A0EC B6DE 2EA0 CCE6 2860 3945`
and are automatically verified by GitHub.

Additionally, `songe` and `songev` files [SHA-256 sums](https://en.wikipedia.org/wiki/SHA-2)
are computed and the sums are then clear-signed with Keybase PGP and Songe itself keys. You
can choose to only verify sums, or sums with sums signatures. The commands below apply to
the Unix-like environments.

To only verify SHA-256 sums :

```
grep ' songe' SHA256SUM.asc | sha256sum -c
```

The next steps help to verify sums as well as sums signature.

The Keybase PGP signing key belongs to [espritlibredev](https://keybase.io/espritlibredev)
(fingerprint `AA77 7903 6281 D0E9 209B E8B9 2627 39EB A36C EB3E`).

Go to https://keybase.io/verify and paste the content of the `SHA256SUM.asc` files, or
if you are using [keybase](https://keybase.io), simply type the following command to verify
the two scripts integrity:

```bash
keybase pgp verify -i SHA256SUM.asc && grep ' songe' SHA256SUM.asc | sha256sum -c
```

or if you prefer to use GnuPG:

```bash
curl https://keybase.io/espritlibredev/pgp_keys.asc | gpg --import && \
  gpg --verify SHA256SUM.asc && grep ' songe' SHA256SUM.asc | sha256sum -c
```

or with Songe itself (key `PAVVKNVPOCLDAZHGQOI5L476MEPR4ITZ2G6SA2Q2TYZLEGNWP46RGG7G`):

```bash
songev SHA256SUM | sha256sum -c
```

## License

Copyright (c) 2020 Micaël P. - Distributed under the MIT License.

See [LICENSE](https://github.com/CodeEspritLibre/songe/blob/master/LICENSE) for further
details.

