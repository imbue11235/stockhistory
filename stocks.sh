#!/bin/bash

symbols="./symbols.txt"
api_key="$API_KEY"
stocks_api_url="https://www.alphavantage.co"

main() {
  while read -r symbol
  do
    get_stock_data "$symbol"
  done < "$symbols"

  echo "Done"
}

# Get stock data from Alpha Vantage API
get_stock_data() {
  symbol="$1"

  query=$(get_request_url "$symbol")
  timestamp=$(date +%F)
  folder="./data/$symbol"
  # Create folder if it doesn't exist
  mkdir -p "$folder"

  # Define file name
  target="$folder/$timestamp.json"

  # If no data for today, get it
  if [ ! -f "$target" ]; then
    curl -s "$stocks_api_url/$query" > "$target"

    # Then commit it
    git add "$target"
    git commit -m "Add $symbol data for $timestamp"
    git push origin main

    # To prevent reaching the rate limit of 5 per minute
    # we will sleep for 12 seconds between each request
    sleep 12
    return
  fi

  echo "skipping $symbol for $timestamp as data already exists"
}

get_request_url() {
    local query="query?function=TIME_SERIES_INTRADAY&symbol=$1&interval=5min&apikey=$api_key"
    echo "$query"
}

main