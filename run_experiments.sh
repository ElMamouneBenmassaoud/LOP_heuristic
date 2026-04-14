BINARY="./lop"
INSTANCES_DIR="./instances"
BEST_KNOWN_FILE="./best_known/best_known.txt"
OUTPUT_FILE="./results/raw_data.txt"

mkdir -p results

get_best_known() {
    awk -v inst="$1" '$1 == inst {print $NF}' "$BEST_KNOWN_FILE"
}

printf "algo\tpivot\tneighborhood\tinit\tinstance\tsize\tfinal_cost\trpd\ttime_sec\n" > "$OUTPUT_FILE"

total=0
errors=0

run_one() {
    local algo="$1" pivot="$2" neigh="$3" init="$4" flags="$5"

    for instance_path in "$INSTANCES_DIR"/*; do
        instance=$(basename "$instance_path")
        size=$(echo "$instance" | grep -o '[0-9]*$')

        output=$("$BINARY" -i "$instance_path" $=flags 2>/dev/null)
        final_cost=$(echo "$output" | grep "Final cost"   | awk '{print $NF}')
        time_sec=$(echo  "$output" | grep "Time elapsed" | awk '{print $NF}')

        bk=$(get_best_known "$instance")

        if [[ -n "$bk" && -n "$final_cost" ]]; then
            rpd=$(awk "BEGIN { printf \"%.6f\", 100.0 * ($bk - $final_cost) / $bk }")
        else
            rpd="NA"
            (( errors++ ))
        fi

        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
            "$algo" "$pivot" "$neigh" "$init" \
            "$instance" "$size" "$final_cost" "$rpd" "$time_sec" \
            >> "$OUTPUT_FILE"
        (( total++ ))
    done
    echo "  done: $algo $pivot $neigh $init"
}

for pivot in first best; do
    for neigh in transpose exchange insert; do
        for init in random cw; do
            echo "Running: II --${pivot} --${neigh} --${init}"
            run_one "II" "$pivot" "$neigh" "$init" "--${pivot} --${neigh} --${init}"
        done
    done
done

for vnd in vnd1 vnd2; do
    echo "Running: VND --${vnd} --cw"
    run_one "VND" "$vnd" "-" "cw" "--${vnd} --cw"
done

echo ""
echo "Done. Results saved to $OUTPUT_FILE"
echo "Total runs : $total"
echo "Missing RPD: $errors"
