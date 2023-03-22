#!/bin/bash
#set -euxo pipefail
set -euo pipefail
# Parse arguments
while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
    fi
    shift
done

if [[ -z "${organization:-}" ]]; then
  read -p "Please, enter the GitHub organization: " organization
fi
if [[ -z "${token:-}" ]]; then
  read -s -p "Please, enter the GitHub token for managing repositories: " token
fi

echo ""

if [[ -z "${pipeline_name:-}" ]]; then
  read -p "Please, enter your pipeline name [default=pipeline]: " pipeline_name
fi

if [[ -z "${step_count:-}" ]]; then
  read -p "Please, enter a number of steps in your pipeline [default=1]: " step_count
fi

GITHUB_ORG="${organization:-}"
GITHUB_TOKEN="${token:-}"
PIPELINE_NAME="${pipeline_name:-pipeline}"
STEP_COUNT="${step_count:-1}"

steps=()
set +e
i=1
while (( $i<=$STEP_COUNT ));
do

if [[ -z "${step_name:-}" ]]; then
  read -p "Please, enter $i step name of your pipeline [default=step$i] : " step_name
fi

STEP_NAME="${step_name:-step$i}"
echo $STEP_NAME
echo "${PIPELINE_NAME}-${STEP_NAME}"

curl \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/orgs/$GITHUB_ORG/repos \
  -d '{"name":"'"$PIPELINE_NAME-$STEP_NAME"'","description":"This is your '"$i"' step in pipeline '"${PIPELINE_NAME}"'","homepage":"https://github.com","private":false,"has_issues":true,"has_projects":true,"has_wiki":true}'

steps+=( $STEP_NAME )

(( i=$i+1 ))
done

read -p "Your pipeline steps will be cloned soon. Would you like to store Git credentials for making it faster? y/n (default=n): " save_git_creds

if [[ ${save_git_creds} == "y" ]]; then
  git config --global credential.helper store  
fi

set -e
for step in ${steps[@]}; do
  git clone --recurse-submodules https://github.com/4-DS/step_template.git $step
  cd $step
  git remote set-url origin https://github.com/$GITHUB_ORG/$PIPELINE_NAME-$step.git
  git reset $(git commit-tree HEAD^{tree} -m "a new Sinara step")
  git push
done

echo 'Now you can go through the steps' folders and declare interfaces as you need'

