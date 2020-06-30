#!/usr/bin/env bash

log_info() {
  local log_text=$1

  echo "---> $log_text"
}

log_warning() {
  local log_text=$1

  echo "---> WARNING $log_text"
}
