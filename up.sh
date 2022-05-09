#!/bin/bash
cd /app/pyr/clients/monat
echo "Starting rails server"
rails s puma -b 0.0.0.0
