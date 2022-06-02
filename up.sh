#!/bin/bash
set -x
client="${1}"
cd "/app/pyr/clients/${client}"
rails s puma -b 0.0.0.0
