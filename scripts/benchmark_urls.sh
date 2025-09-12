#!/bin/bash
set -euo pipefail

# Default number of runs
RUNS=100

# Parse CLI options
while getopts "n:" opt; do
  case $opt in
    n) RUNS=$OPTARG ;;
    *) echo "Usage: $0 [-n runs] url1 url2 ..." >&2; exit 1 ;;
  esac
done
shift $((OPTIND -1))

# 0-based nearest-rank index for integer percent p (e.g., 50, 90, 95)
percentile_index() {
  local n=$1 p=$2
  echo $(( ((n * p) + 99) / 100 - 1 ))
}

benchmark_url() {
  local URL=$1
  local -a times=()
  local total_time=0
  local min_time=999999
  local max_time=0

  echo "🚀 Benchmarking $URL"
  echo "Running $RUNS requests..."
  echo ""
  echo -n "Progress: "

  for i in $(seq 1 $RUNS); do
      if [ $((i % 10)) -eq 0 ]; then
          echo -n "."
      fi

      time_taken=$(curl -s -o /dev/null -w "%{time_total}\n" "$URL")
      time_ms=$(echo "$time_taken * 1000" | bc -l)

      times+=($time_ms)
      total_time=$(echo "$total_time + $time_ms" | bc -l)

      if (( $(echo "$time_ms < $min_time" | bc -l) )); then
          min_time=$time_ms
      fi
      if (( $(echo "$time_ms > $max_time" | bc -l) )); then
          max_time=$time_ms
      fi
  done

  echo ""
  echo ""

  average=$(echo "$total_time / $RUNS" | bc -l)
  min_formatted=$(printf "%.2f" $min_time)
  max_formatted=$(printf "%.2f" $max_time)
  avg_formatted=$(printf "%.2f" $average)

  echo "📊 Results for $RUNS requests to:"
  echo "   $URL"
  echo ""
  echo "⚡ Minimum time:  ${min_formatted} ms"
  echo "🐌 Maximum time:  ${max_formatted} ms"
  echo "📈 Average time:  ${avg_formatted} ms"
  echo ""

  sorted_times=($(printf '%s\n' "${times[@]}" | sort -n))

  p50_index=$(percentile_index "$RUNS" 50)
  p90_index=$(percentile_index "$RUNS" 90)
  p95_index=$(percentile_index "$RUNS" 95)

  p50=$(printf "%.2f" ${sorted_times[$p50_index]})
  p90=$(printf "%.2f" ${sorted_times[$p90_index]})
  p95=$(printf "%.2f" ${sorted_times[$p95_index]})

  echo "📊 Percentiles:"
  echo "   50th percentile (median): ${p50} ms"
  echo "   90th percentile:          ${p90} ms"
  echo "   95th percentile:          ${p95} ms"
  echo ""

  fast_count=0
  medium_count=0
  slow_count=0
  for time in "${times[@]}"; do
      if (( $(echo "$time < 200" | bc -l) )); then
          ((fast_count++))
      elif (( $(echo "$time < 500" | bc -l) )); then
          ((medium_count++))
      else
          ((slow_count++))
      fi
  done

  echo "🎯 Speed Distribution:"
  echo "   Fast (<200ms):      $fast_count requests"
  echo "   Medium (200-500ms): $medium_count requests"
  echo "   Slow (>500ms):      $slow_count requests"
  echo ""
  echo "✅ Benchmark complete!"
  echo ""
}

# Require at least one URL
if [ $# -eq 0 ]; then
  echo "Usage: $0 [-n runs] url1 url2 ..."
  exit 1
fi

# Loop through all URLs passed as args
for url in "$@"; do
  benchmark_url "$url"
done
