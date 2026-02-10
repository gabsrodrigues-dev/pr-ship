(From Gabriel Rodrigues to Gabriel Rodrigues file)

# Releasing updates to the Launchpad PPA (pr-ship)

This is a practical, repeatable checklist to publish a new version to Launchpad PPA.

## Preconditions

- You have a Launchpad PPA created.
- Your GPG/OpenPGP key is configured in Launchpad.
- Your key can sign packages locally.

## 0) One-time local setup (recommended)

Set your Debian maintainer identity (must match a UID on your secret key):

```bash
export DEBEMAIL="gabrielrod.ifmg@gmail.com"
export DEBFULLNAME="Gabriel Rodrigues"
```

Check your signing key is available:

```bash
gpg --list-secret-keys --keyid-format=long
```

If you want to force a specific key (optional):

```bash
export DEBSIGN_KEYID="C5881877AD8436A6"
```

## 1) Choose the Ubuntu series (suite)

Pick the suite you want to build for (examples):

- `jammy` (22.04)
- `noble` (24.04)

Suites supported by Launchpad PPAs are listed here:

https://launchpad.net/ubuntu/+ppas

### Publishing for Ubuntu 24.04 (noble)

If your target machines are Ubuntu 24.04, you must publish for `noble`.

Recommended version pattern for `noble` (keeps versions unique and sortable):

- `1.0.1-1~ppa1~ubuntu24.04.1`

And set the suite to `noble` in `debian/changelog`.

## 2) Bump version in `debian/changelog`

Use `dch` to bump the version and set the suite.

Example for a new release on jammy:

```bash
dch -i -D jammy "Release <VERSION>"
```

Recommended version pattern for PPA builds:

- `1.0.1-1~ppa1` (first upload of 1.0.1)
- `1.0.1-1~ppa2` (re-upload/fix for the same upstream version)

## 3) Create the orig tarball (first upload of a new upstream version)

If you are using `3.0 (quilt)`, Launchpad expects an `.orig.tar.*` for the first upload of a new upstream version.

From the repo root:

```bash
VERSION="$(dpkg-parsechangelog -S Version | sed 's/-.*//')"
PKG="$(dpkg-parsechangelog -S Source)"

tar --exclude-vcs --exclude='./debian' -czf "../${PKG}_${VERSION}.orig.tar.gz" .
```

Notes:

- You normally exclude `debian/` from the orig tarball.
- The orig tarball is created in the **parent directory**.

## 4) Build the signed source package

From the repo root:

```bash
debuild -S -sa
```

### Re-uploading without re-sending the `.orig.tar.gz`

Launchpad may reject multiple uploads of the same `.orig.tar.gz`.

- First upload of an upstream version (e.g. first time uploading `1.0.1`): use `-sa`
- Fixing/re-uploading the same upstream version (e.g. `~ppa2`, `~ppa3`): use `-sd`

Example:

```bash
debuild -S -sd
```

Outputs will be generated in the **parent directory** (`../`), including:

- `../<pkg>_<version>_source.changes`

## 5) Upload to Launchpad (dput)

Run `dput` with the `.changes` file path.

Example:

```bash
dput ppa:gabsrodrigues-dev/pr-ship ../<pkg>_<version>_source.changes
```

Important:

- The `.changes` file is usually in `../`, not inside the repo.
- `dput` requires a filename that matches `*.changes`.

## 6) Verify build/publish

In Launchpad:

- Check the PPA build queue
- Wait for “Successfully built”

If it fails:

- read the build log
- bump `~ppaN` in `debian/changelog`
- rebuild + reupload

## Common errors and fixes

### bad-distribution-in-changes-file (stable)
Your changelog suite must be a supported Ubuntu series (e.g. `jammy`, `noble`).

### malformed-debian-changelog-version (for native)
Happens when the package is treated as `3.0 (native)` while the version has a Debian revision like `-1`.
Use `3.0 (quilt)` for PPA packaging.

### debsign failed: no secret key
Your `debian/changelog` / `debian/control` maintainer email must match a UID on your secret key, or set `DEBSIGN_KEYID`.
