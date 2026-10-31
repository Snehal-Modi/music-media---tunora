# Remove other names from the GitHub Contributors list

GitHub builds the Contributors list from the **author and co-author lines stored in
every commit** on `main`. Nothing in the app or in repository settings can hide a
name. The only way is to replace the history with commits that carry one name.

This guide makes **one clean commit** by Snehal-Modi and replaces `main` with it.
It is a one-time job. Old commits disappear from `main` (the code stays exactly
the same). Do it from the project folder, after you unzip the new version into it.

> A force-push cannot be undone. Make a backup first: copy the whole folder to
> another place before you start.

## 0. Check the signing key is in the folder (important)

`android/app/smusic.jks` is the key that signs every APK. The zip already contains
it. If it is missing, the next build makes a **new** key and phones must uninstall
the old app before they can update. In PowerShell, inside the project folder:

```powershell
Test-Path android/app/smusic.jks
```

It must print `True`. If it prints `False`, open the repo on GitHub, open
`android/app/smusic.jks`, download it, and put it in that folder.

## 1. Find your GitHub no-reply email

Open https://github.com/settings/emails in the browser where **Snehal-Modi** is
signed in, and turn on **Keep my email addresses private**. Copy the address that
looks like `12345678+Snehal-Modi@users.noreply.github.com`.

This keeps your real email out of the commit and links the commit to Snehal-Modi.

## 2. Run these commands (PowerShell, inside the project folder)

```powershell
git config user.name  "Snehal-Modi"
git config user.email "12345678+Snehal-Modi@users.noreply.github.com"

git checkout --orphan clean-main
git add -A
git add -f android/app/smusic.jks
git commit -m "Tunora 1.3.0"
git branch -M main
git push -f origin main
```

Replace the email in the second line with the one from step 1.

What it does: `--orphan` starts a branch with no history, `git add` takes all files
as they are now (the `-f` line makes sure the signing key is included), the commit
is authored only by Snehal-Modi, and `push -f` replaces `main` on GitHub.

## 3. Check

- The Actions tab starts a build. When it is green the release is created.
- The Contributors box can take a few hours to update. It should end up with only
  **Snehal-Modi**.
- Old releases (v1.1.0, v1.2.0) still point at old commits and keep working. Delete
  them on the Releases page if you want them gone; the next build makes a new one.

## From now on

Keep the two `git config` lines above. Every normal commit then carries only your
name:

```powershell
git add .
git commit -m "What changed"
git push
```

Do not add `Co-Authored-By` lines to commit messages.
