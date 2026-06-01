#!/bin/bash

# 1. Define all your UVM tests in an array
TESTS=(
    "apb_smoke_test"
    "apb_b2b_test"
    "apb_data_test"
    "apb_error_test"
    "apb_pprot_test"
    "apb_pstrb_test"
    "apb_raw_war_test"
    "apb_wait_test"
)

# Clean up old coverage databases before starting
rm -f *.ucdb
rm -rf regression_report

echo "Starting Regression..."

# 2. Loop through each test and simulate
for TEST in "${TESTS[@]}"; do
    echo "========================================"
    echo " Running UVM Test: $TEST"
    echo "========================================"
    
    # FIX 1: Added '-onfinish stop' to prevent UVM from killing the save command
    vsim.exe -c -coverage top_tb \
         +UVM_TESTNAME=$TEST \
         +UVM_VERBOSITY=UVM_LOW \
         -voptargs="+acc +cover=bcesft" \
         -onfinish stop \
         -do "run -all; coverage save ${TEST}.ucdb; quit -f"
done

echo "========================================"
echo " Regression Complete. Merging Coverage..."
echo "========================================"

# 3. Merge all individual test databases into one master database
vcover.exe merge master_regression.ucdb *.ucdb

echo " Generating HTML Report..."

# FIX 2: Changed '-htmldir' to '-output' to fix the Questa deprecation warning
vcover.exe report -html -output regression_report master_regression.ucdb

echo "Done! Open regression_report/index.html to view combined coverage."