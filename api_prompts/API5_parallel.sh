i
#!/bin/bash

# Set range
START=24
END=548
JOBS=8  # Number of parallel jobs

# Calculate the total files per job
TOTAL=$((END - START + 1))
PER_JOB=$(( (TOTAL + JOBS - 1) / JOBS ))

for (( j=0; j<JOBS; j++ )); do
    JOB_START=$((START + j * PER_JOB))
    JOB_END=$((JOB_START + PER_JOB - 1))
    if (( JOB_END > END )); then
        JOB_END=$END
    fi

    # Launch each chunk as a background process
    (
    for i in $(seq -f "%04g" $JOB_START $JOB_END); do
        echo "Processing file $i..."
        python3 "API5.txt" --input cancer-$i --output np/np-$i
        sleep 1
    done
    ) &
done

# Wait for all background jobs to complete
wait
echo "All jobs finished!"


