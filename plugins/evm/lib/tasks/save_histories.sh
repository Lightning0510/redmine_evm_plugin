#!/bin/bash

cd /home/linhtran/workspace/redmine-3.3.1 && /home/linhtran/.rbenv/shims/bundle exec rails runner EvmRecorder.saveEvmHistories -e test
