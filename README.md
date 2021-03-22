# AutoGit
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg?logo=gnu)](https://www.gnu.org/licenses/gpl-3.0)
[![Forked](https://img.shields.io/badge/Forked-black?logo=github)](https://gist.github.com/mnem/1438396)

 Bash script for fetching and pulling all repos in the executed folder

## Differences :eyes:
| | `git_fetch_pull_all_subfolders.sh` | `git_fetch_pull_all_subfolders_all_local_branches.sh` |
| ------ | ------ | ------ |
| Fetch | `--all --prune` | `--all --prune` |
| Branche | Active branch | All branches found by `git branch --format='%(refname:short)`, at the end check out the active branch.|
| Pull | If no modification, checked by `git status --porcelain` | If no modification, checked by `git status --porcelain` |

## Usage :alien:
### Without parameter
Put the file in the parent folder `[PATH]` of your repos:
```
[PATH]
> [PATH/REPO1]
> [PATH/REPO2]
> [PATH/REPO3]
```
Double click on it :godmode:

### With the parameter
Put the file where you want and when you call it add the `[PATH]` parameter:
```
[PATH]
> [PATH/REPO1]
> [PATH/REPO2]
> [PATH/REPO3]
```

Launch the following command: `[PATH_TO_FILE]\git_fetch_pull_all_subfolders.sh [PATH]` :hurtrealbad:
