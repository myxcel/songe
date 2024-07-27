## Description

Welcome to Songe.

Songe (pronounced "songe") is a naive file signer and verifier tool, designed to sign files in a per-project context: each project directory can have its own keys to directly sign project files. Songe currently uses **RbNaCl**, which uses the excellent **libsodium**. A light version, Songev, only allow to quick verify signatures, doesn't use **RbNaCl**, but use the light Ruby **Ed25519** library.

Verify and sign files are made with Ed25519 32-bytes keys using SHA-512. The signing key (base32-encoded starting with 'K') is encrypted with the user passphrase before saved on disk. The verify key (base32-encoded starting with 'P') is joined to the signing key saved on disk and to all signatures (so to verify a file, you just need the file and the signature `.sgsig` file). Key pair is saved into a local `.songe.key` file.

Trusted recipients' verifying keys may be added to a trusted keys list saved to a `.songe.trust` local file to add confidence when verifiyng files signed by them. The trusted keystore is managed by songe commands and signed at each editing access by the personal signing key. Although the trust keystore is signed, it is up to the user to check whether the recipient's key belongs to the recipient.

`.songe.key` and `.songe.trust` are stored in the local directory when generated (and when password is changed)). At usage time, the key is looked up in: 1. the local directory, 2. the `$SONGE_HOME` directory and 3. the user `$HOME` directory. This way, each project can have its own songe key, or there can be an unique songe key for all projects.

## Features and benefits

 * Sign and verify files easily with Ed25519 keys (detached or embedded signatures)
 * Manage a simple keystore of trusted recipients public keys for secure verifications
 * Dead simple to use (sign and verify) and yet very secure (based on RbNaCl/libsodium)
 * Possibility to attach a comment to the signature (will be signed as well)
 * No need to get/share the verify key to verify a file (included in signature)
 * Very small and user-friendly signature files (comment, datetime and signature in Yaml format)

## Installation

Songe is written in [Ruby](https://www.ruby-lang.org/), and requires it to run. You will also need to install the following libraries / [ruby gems](https://rubygems.org/):

For the full version **songe**

 * [libsodium](https://github.com/jedisct1/libsodium)
 * [RbNaCl](https://github.com/RubyCrypto/rbnacl)
 * [digest-crc](https://github.com/postmodern/digest-crc)
 * [highline](https://github.com/JEG2/highline)
 * [base32](https://github.com/stesla/base32)
 * [strong_password](https://github.com/bdmac/strong_password)

 ```bash
 # run as admin
 apt install libsodium23
 gem install rbnacl digest-crc highline base32 strong_password
 ```
 
On Ubuntu, for example, you can install the libraries by running:
```bash
rake install
```

For the light (verify only) version **songev**

 * [ed25519](https://github.com/RubyCrypto/ed25519)
 * [digest-crc](https://github.com/postmodern/digest-crc)
 * [base32](https://github.com/stesla/base32)

 ```bash
 # run as admin
 gem install ed25519 digest-crc base32
 ```

**songe** and **songev** are executable Ruby script files. They should be placed into a PATH-indexed system or user `bin/` directory. On Unix-like systems, make sure that they are marked as executable (`chmod +x songe songev`), or run them as arguments of the Ruby command (example: `ruby songe -s file`).

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

If you can (and want to) install *libsodium*, then use *songe*, otherwise or if you just have to verify signatures, use *songev*.

- Here is said that I can add the recipient's verify key to a trusted keystore. Do I need it to verify a signature?

No, for the verification, you **do not** need the verify key, since it is already included in the signature file `.sgsig`. Adding the key to the trusted keystore is only an additional layer of security: it allows you to check the sender's key trust level only once.

- I sign a file in embedded signature (`--embed` option), and the verification fails. Why?

For security reasons, the verification first checks if a file without `.sgsig` extension exists, and if not, uses the embedded data in signature file. So checking an embedded signature requires that **no** original file name remains in the same directory (example: after signing the `SHASUM` file in embedded mode, a `SHASUM.sgsig` file is created containing the signed data, so please remove the original `SHASUM` file).

## Check scripts integrity

First, commits are signed with my PGP key [466F B094 B95C 3589](https://gist.githubusercontent.com/myxcel/8dc88878af2eea1d02e52ae55c694fc0/raw/myxcel-466FB094B95C3589.asc) and are automatically verified by GitHub. Second, the release `songe-x.x.x.zip` itself is OpenPGP-signed with the same key.

Additionally, `songe` and `songev` files [SHA-256 sums](https://en.wikipedia.org/wiki/SHA-2) are computed and the sums are then clear-signed with Songe itself. You can choose to only verify sums, or sums with sums signatures. The commands below apply to the Unix-like environments.

To only verify SHA-256 sums:

```bash
grep ' songe' SHASUM.asc | sha256sum -c
```

To verify sums _as well as_ sums signature with Songe itself (key **PCINJUEXO6IVL44** `PCINJUEXO6IVL44KLEBNTXG7GMHWVNAAOOUVZTXC5R7KAT67DTKXX3CO`):

```bash
rake verify
```

or

```bash
songev SHASUM | sha256sum -c
```

Note that you can then add my key in your personal trust keystore after generating your key 🙂

```bash
songe --generate
songe --add-key PCINJUEXO6IVL44KLEBNTXG7GMHWVNAAOOUVZTXC5R7KAT67DTKXX3CO
```

## License

Micaël P. - Distributed under the MIT License. See
[LICENSE](https://github.com/myxcel/songe/blob/master/LICENSE) for further details.

If you like Songe, please buy me a coffee, or a pizza ☕🍕 😃

<a href="https://www.buymeacoffee.com/myxcel" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 170px !important;" ></a>
<a href="https://liberapay.com/myxcel/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a>

