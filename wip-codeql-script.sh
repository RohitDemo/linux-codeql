#!/bin/bash

# DEBUG set to `1` will pause at each step, `0` will continue
DEBUG=0
# REPLACE: Repo and Instance as per requirements
GITHUB_REPO="rohitdemo/linux-codeql"
GITHUB_INSTANCE="https://github.com"
# Git variables
GIT_BRANCH="refs/heads/$(git branch --show-current)"
GIT_HASH=$(git rev-parse HEAD)


echo " ===== Settings for CodeQL ====="
echo "Github - Repo     :: $GITHUB_REPO"
echo "GitHub - Instance :: $GITHUB_INSTANCE"
echo "Git - Branch      :: $GIT_BRANCH"
echo "Git - Commit Hash :: $GIT_HASH"
echo "GitHub - PAT :: Using GITHUB_TOKEN here but you can reference it in other ways for your custom CI"


function runnerwait {
    # This only stops if DEBUG mode is set
    if [[ $DEBUG = 1 ]]; then
        read  -n 1 -p "Enter to Continue..." randominput
    fi
}


echo " ===== Init CodeQL ====="
/codeql/bin/codeql-runner/codeql-runner-linux init \
    --repository $GITHUB_REPO \
    --github-url  $GITHUB_INSTANCE \
    --github-auth $GITHUB_TOKEN \
    --languages "csharp"

# wait if in debug mode
runnerwait


echo " ===== Sourcing CodeQL Environment Traps ====="
# Source the CodeQL Runner enviroment. This is critical to make sure CodeQL
# correctly analyses the compiled code bases and is the main reason for the
# "No Code was found during the build".
. codeql-runner/codeql-env.sh

# wait if in debug mode
runnerwait


echo " ===== Test LD_PRELOAD and DYLD_INSERT_LIBRARIES (CodeQL Tracing) ====="
# Check to see if the CodeQL variables have been set

echo "Current (Linux) :: $LD_PRELOAD"
if [[ $DEBUG = 1 ]]; then
    echo "Example (Linux) :: /root/codeql-runner-tools/CodeQL/0.0.0-20201106/x64/codeql/tools/linux64/${LIB}trace.so"
fi

# Test command
echo "Current (MacOS) :: $DYLD_INSERT_LIBRARIES"


runnerwait    # wait if in debug mode

echo " ===== Build Command ====="
# Build Commands
# REPLACE: This needs updating per requirements


# wait if in debug mode
runnerwait

echo " ===== CodeQL Analyze Step (including upload) ====="
# Analyse
/codeql/bin/codeql-runner/codeql-runner-linux analyze \
    --repository $GITHUB_REPO \
    --github-url  $GITHUB_INSTANCE \
    --github-auth $GITHUB_TOKEN \
    --commit $GIT_HASH \
    --ref $GIT_BRANCH
