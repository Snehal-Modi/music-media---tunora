# Safe Repository & History Maintenance Guide

This guide explains how to safely maintain the repository and purge legacy commits that previously contained tracked credentials.

---

## 1. Always Make a Local Backup First

Before rewriting Git history, create a complete, isolated local backup of the project folder:

```bash
cp -r /path/to/music-media---tunora /path/to/music-media---tunora-backup
```

---

## 2. Security Rules (Never Commit Signing Keys)

1. **Never commit keystores (`*.jks`, `*.keystore`) or `key.properties` to Git.**
2. All signing secrets should exist solely on your local machine and in GitHub Actions Repository Secrets (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`).
3. Root and Android `.gitignore` files are configured to block all keystore files automatically.

---

## 3. Purging Exposed Keys from Git History (Optional Clean State)

If you wish to completely remove the old commits from GitHub so that past commit history does not contain the old signing files:

### Step A: Verify Backup
Ensure your backup directory exists and is intact outside the repository.

### Step B: Create a Clean Single-Commit Branch
Inside your project folder:

```bash
# Ensure working tree is clean
git status

# Create an independent orphan branch containing the current clean code
git checkout --orphan clean-main

# Stage all project files (ignoring keys via .gitignore)
git add -A

# Commit the clean codebase
git commit -m "Tunora v1.3.0 - Clean release architecture"

# Point main branch to this clean commit
git branch -M main
```

### Step C: Verification Before Push
Verify that no keys or properties are in the commit:
```bash
git ls-files | grep -E '\.(jks|properties)$'
```
*(The above command should return no sensitive files)*

### Step D: Update GitHub (Only With Explicit Approval)
```bash
git push -f origin main
```
> **Warning:** A force-push replaces commit history on GitHub. Ensure all contributors or devices have backed up their work before running this command.
