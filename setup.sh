#!/usr/bin/env bash
workdir=$(pwd -P)
export ANSIBLE_CONFIG="$workdir/ansible.cfg"
VENV="$workdir/.venv"

_venvactivate() {
  pip install virtualenv
  virtualenv $VENV
  source  $VENV/bin/activate
}

prepare() {
  _venvactivate
  pip install --upgrade pip
  pip install -Ur ansible/requirements/pip.txt
}

_run-playbook() {
  ansible-playbook -v -b "$workdir/pg.yml" \
  -i $workdir/host.ini \
  --vault-password-file $workdir/ansible_pass.txt \
  "$@"
}
deploy() {
   prepare
   echo "install  on server  "
   _run-playbook
}

run() {
   tar -czvf install.tar.gz ./
   cp -r install.tar.gz tf/
   cd tf 
   terraform init 
   tarrafrom plan 
   tarraorm apply
}

case "$1" in
  deploy)  shift; deploy "$@" ;;
  run)  shift; run "$@" ;;
  *) print_help; exit 1
esac