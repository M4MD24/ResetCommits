# ResetCommits

A Bash script for cleaning a Git branch history by replacing the existing commit history with a single commit while preserving the current project files.

## Features

- Uses the current branch automatically.
- Accepts an optional target directory (defaults to current directory).
- Accepts an optional custom commit message as a second argument.
- If no custom message is provided, uses the latest commit message.
- Verifies that the target is a Git repository.
- Verifies that a valid current branch exists.
- Prevents execution when uncommitted changes exist.
- Excludes the script itself from the new commit.
- Recreates the branch with exactly one commit.
- Displays the command required to overwrite the remote history safely.

## Usage

Make the script executable:

```bash
chmod +x reset-git-history.sh
```

Run it from the repository (uses latest commit message):

```bash
./reset-git-history.sh
```

Or specify a Git repository directory:

```bash
./reset-git-history.sh "/path/to/repository"
```

Or specify both directory and a custom commit message:

```bash
./reset-git-history.sh "/path/to/repository" "Your new commit message"
```

If you only want to set a custom message for the current directory:

```bash
./reset-git-history.sh "" "Your new commit message"
```

## Requirements

- Bash
- Git
- A valid Git repository
- A clean working tree with no staged or unstaged changes

## How It Works

1. Determines the target directory (from first argument or current directory).
2. Verifies that the directory is a Git repository.
3. Detects the current branch.
4. Gets the latest commit message (unless a custom message is provided as second argument).
5. Ensures there are no uncommitted changes.
6. Creates an orphan branch.
7. Stages the current project files.
8. Excludes the script itself from staging.
9. Creates a new commit using the selected message (custom or latest).
10. Deletes the original branch.
11. Renames the temporary branch to the original branch name.

After completion, the branch contains exactly one commit.

### Remote Repository

The script does not automatically push the rewritten history.

It prints the recommended command:

```bash
git push --force-with-lease origin <branch>
```

Review the result before overwriting the remote history.

## Warning

This script rewrites Git history. Existing commits on the current branch will no longer be part of the branch history after it finishes.

Make sure you understand the consequences before running it, especially when working with a shared remote repository.
