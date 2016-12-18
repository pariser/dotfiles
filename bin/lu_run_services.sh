#!/usr/bin/env bash

LU_ANALYTICS_PATH=/Users/pariser/dev/learnup/analytics
LU_STRAWBERRY_PATH=/Users/pariser/dev/learnup/strawberry

pushd $LU_ANALYTICS_PATH > /dev/null
nodemon $LU_ANALYTICS_PATH/bin/app > "${TMPDIR}learnup-analytics.log" &
analytics_pid=$!
popd 2>&1 > /dev/null

pushd $LU_STRAWBERRY_PATH > /dev/null
nodemon $LU_STRAWBERRY_PATH/lib/strawberry/web.js > "${TMPDIR}learnup-strawberry.log" &
strawberry_pid=$!
popd 2>&1 > /dev/null

tail -f "${TMPDIR}learnup-analytics.log" "${TMPDIR}learnup-strawberry.log"

kill -9 $analytics_pid 2>&1 > /dev/null
kill -9 $strawberry_pid 2>&1 > /dev/null
