#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations 329
cat 201402-citibike-tripdata.csv | cut -d, -f4,8 | tr , '\n' |tail -n +3| sort | uniq | wc -l
# count the number of unique bikes 5699
cat 201402-citibike-tripdata.csv | cut -d, -f12 |tail -n +2| sort | uniq | wc -l
# count the number of trips per day
cat 201402-citibike-tripdata.csv | cut -d, -f2 | cut -d' ' -f1 | tail -n +2 | sort| uniq -c

# find the day with the most rides
cat 201402-citibike-tripdata.csv | cut -d, -f2 | cut -d' ' -f1 | tail -n +2 | sort| uniq -c| sort -rn | head -1
# find the day with the fewest rides
cat 201402-citibike-tripdata.csv | cut -d, -f2 | cut -d' ' -f1 | tail -n +2 | sort| uniq -c| sort -rn | tail -1
# find the id of the bike with the most rides
cat 201402-citibike-tripdata.csv | cut -d, -f12 | tail -n +2 | sort| uniq -c| sort -rn | head -1
# count the number of rides by gender and birth year
cat 201402-citibike-tripdata.csv | awk -F, '{counts[$14 $15]++} END {for (k in counts) print counts[k]"\t" k }'

# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...)
cat 201402-citibike-tripdata.csv | cut -d, -f5 | tail -n +2 | grep '.*[0-9].* & .*[0-9].*'|wc -l
# compute the average trip duration
cat 201402-citibike-tripdata.csv | tail -n +2| cut -d, -f1 | awk -F'"' '{sum += $2}; END {print sum/NR}'
