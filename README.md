## Description

Welcome to Songe.

Songe is a naive file signer and verifier, adapted to sign files in a per-project context:
each project directory can have its own keys to directly sign project files. Songe currently
uses **RbNaCl**, which uses **libsodium**. A light version, Songev, only allow to quick
verify signatures, doesn't use **RbNaCl**, but use the light **Ed25519** library.

Verify and sign files are made with Ed25519 32-bytes keys. The signing key (starting with
'K') is encrypted with the user passphrase before saved on disk. The verify key (starting
with 'P') is joined to the signing key saved on disk and to all signatures (so to verify a
file, you just need the file and the signature `.sgsig` file). Key pair is saved to
`.songe.key`.

Trusted recipients' verify keys may be added to a trusted keys list saved to `.songe.trust`
to add confidence when verifiyng files signed by them. The trusted keystore is managed by
songe commands and signed at each editing access by the personal signing key. Although the
trust keystore is signed, it is up to the user to check the recipient's key.

## Features and benefits

 * Sign and verify files easily with Ed25519 keys (detached or embedded signatures)
 * Manage a simple keystore of trusted recipients public keys for secure verifications
 * Dead simple to use (sign and verify) and yet secure (based on RbNaCl/libsodium)
 * Possibility to attach a comment to the signature (will be signed as well)
 * No need to get/share the verify key to verify a file (included in signature)
 * Very small and friendly signature files (comment, datetime and signature in Yaml format)

## Installation

Songe is written in [Ruby](https://www.ruby-lang.org/), and requires it to run. You will
also need to install the following library / [ruby gems](https://rubygems.org/):

For the full version **songe**

 * [libsodium](https://github.com/jedisct1/libsodium)
 * [RbNaCl](https://github.com/RubyCrypto/rbnacl)
 * [digest-crc](https://github.com/postmodern/digest-crc)
 * [highline](https://github.com/JEG2/highline)
 * [base32](https://github.com/stesla/base32)

 ```bash
 # run as admin
 apt install libsodium23
 gem install rbnacl digest-crc highline base32
 ```

For the light (verify only) version **songev**

 * [ed25519](https://github.com/RubyCrypto/ed25519)
 * [digest-crc](https://github.com/postmodern/digest-crc)
 * [base32](https://github.com/stesla/base32)

 ```bash
 # run as admin
 gem install ed25519 digest-crc base32
 ```

**songe** and **songev** are executable Ruby script files. They should be placed into a
PATH-indexed system or user `bin/` directory. On Unix-like systems, make sure that they are
marked as executable (`chmod +x songe songev`), or run them as arguments of the Ruby command
(example: `ruby songe -s file`).

## Simple usage examples

```bash
  # Generate a new signing key (writes the key to `./.songe.key`)
  # The first asks to choose a passphrase, the second generates a secure one
  songe --generate
  songe --secure --generate

  # Or import an existing signing key (then paste the key KABCDE...)
  songe --import-key

  # With a signing key available, display the verification key
  songe --verifkey
  # ... or even the signing key (then enter the passphrase)
  songe --signkey

  # Sign a file with the new key (writes the signature to `./myfile.txt.sgsig`)
  # The third signs with a signed comment, the fourth makes an embedded signature
  songe --sign 'myfile.txt'
  songe --verbose --sign 'myfile.txt'       # displays more information
  songe --message 'first release' --sign 'myfile.txt'
  songe --embed --sign 'myfile.txt'
  # Real example of embedded signature (only share the file `SHASUM.sgsig`)
  sha256sum files.* > SHASUM && songe --embed --sign SHASUM && rm SHASUM

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
  # Real example of embedded signature (you only got one file `SHASUM.sgsig`)
  songev SHASUM | sha256sum --check      # yes, that's all!
```

## Questions

- Should I use `songe` or `songev` ?

If you can (and want to) install *libsodium*, then use *songe*, otherwise or if you just
have to verify signatures, use *songev*.

- Here is said that I can add the recipient's verify key to a trusted list. Do I need it
to verify a signature?

No, for the verification, you **do not** need the verify key, since it is already included
in the signature file `.sgsig`. Adding the key to the trusted list is only an additional
layer of security: it allows you to check the sender's key only once.

- I sign a file in embedded signature (`--embed` option), and the verification fails. Why?

For security reasons, the verification first checks if a file without `.sgsig` extension
exists, and if not, uses the embedded data in signature file. So checking an embedded
signature requires that **no** original file name remains in the same directory (example:
after signing the `SHASUM` file in embedded mode, a `SHASUM.sgsig` file is created
containing the signed data, so please remove the original `SHASUM` file).

## Check scripts integrity

First, commits are signed with PGP key `6F9F 349C D9DB 0B1A A0EC B6DE 2EA0 CCE6 2860 3945`
and are automatically verified by GitHub.

Additionally, `songe` and `songev` files [SHA-256 sums](https://en.wikipedia.org/wiki/SHA-2)
are computed and the sums are then clear-signed with Keybase PGP and Songe itself keys. You
can choose to only verify sums, or sums with sums signatures. The commands below apply to
the Unix-like environments.

To only verify SHA-256 sums:

```
grep ' songe' SHASUM.asc | sha256sum -c
```

To verify sums _as well as_ sums signature:

The Keybase PGP signing key belongs to [espritlibredev](https://keybase.io/espritlibredev)
(fingerprint `AA77 7903 6281 D0E9 209B E8B9 2627 39EB A36C EB3E`).

Go to https://keybase.io/verify and paste the content of the `SHASUM.asc` file, then (if
valid signature) manually check the two sums

**or** if the [keybase app](https://keybase.io/download) is installed, simply type the following
command in the downloaded Songe directory:

```bash
keybase pgp verify -i SHASUM.asc && grep ' songe' SHASUM.asc | sha256sum -c
```

**or** if you prefer to use GnuPG:

```bash
curl https://keybase.io/espritlibredev/key.asc | gpg --import && \
  gpg --verify SHASUM.asc && grep ' songe' SHASUM.asc | sha256sum -c
```

**or** with Songe itself (key `PAVVKNVPOCLDAZHGQOI5L476MEPR4ITZ2G6SA2Q2TYZLEGNWP46RGG7G`):

```bash
songev SHASUM | sha256sum -c
```

## License

Copyright (c) 2020 Micaël P. - Distributed under the MIT License. See
[LICENSE](https://github.com/CodeEspritLibre/songe/blob/master/LICENSE) for further details.

If you like Songe, pay me a coffee ([Stellar](https://www.stellar.org/)
_espritlibredev*keybase.io_)

