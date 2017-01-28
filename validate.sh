#!/bin/bash

validate () {
        is=$2
        should_be=$3

        if [[ $is -eq $should_be ]]; then
                echo -e "\e[92m[$1]\tPassed.\e[0m"
        else
                echo -e "\e[31m[$1]\tFailed. Should be $should_be, is $is\e[0m"
        fi
}

latest_comic_id=$(/web/consolia-backend/arr.py latest);
amount_of_comics=$latest_comic_id

# API
printf "API\n"
validate "$amount_of_comics comics in api/comics/" $(curl -X GET "http://consolia-comic.com:8080/api/comic/" -s | sed 's/,/\n/g' | grep '"id"' | wc -l) $amount_of_comics
validate "200 OK api/comic/" $(curl -X GET "http://consolia-comic.com:8080/api/comic/" -si | grep HTTP | awk '{print $2}') 200
validate "latest comic in api" $(curl -X GET "http://consolia-comic.com:8080/api/comic/$latest_comic_id" -si | grep HTTP | awk '{print $2}') 200
validate "301 on api/comic" $(curl -X GET "http://consolia-comic.com:8080/api/comic" -si | grep HTTP | awk '{print $2}') 301
validate "404 on api/comic/cake" $(curl -X GET "http://consolia-comic.com:8080/api/comic/cake" -si | grep HTTP | awk '{print $2}') 404
validate "api returns content type json" $(curl -X GET "http://consolia-comic.com:8080/api/comic/" -si | grep "Content-Type" | grep "application/json" | wc -l) 1

# Website
printf "\nWebsite\n"
validate "id=comic in /" $(curl -X GET "http://consolia-comic.com:8080/" -s | grep 'id="comic"' | wc -l) 1
validate "comic img in /" $(curl -X GET "http://consolia-comic.com:8080/" -s | sed 's/"/\n/g' | grep "static.consolia-comic.com" | grep "/comics/" | wc -l) 3
validate "comic img returns 200" $(curl -sI $(curl -X GET "http://consolia-comic.com:8080/" -s | sed 's/"/\n/g' | grep "static.consolia-comic.com" | grep "/comics/") | grep HTTP | awk '{print $2}') 200
validate "200 OK /archive" $(curl -X GET "http://consolia-comic.com:8080/archive" -si | grep HTTP | awk '{print $2}') 200
validate "200 OK /about" $(curl -X GET "http://consolia-comic.com:8080/about" -si | grep HTTP | awk '{print $2}') 200
validate "404 /cake" $(curl -X GET "http://consolia-comic.com:8080/cake" -si | grep HTTP | awk '{print $2}') 404
validate "303 /random" $(curl -X GET "http://consolia-comic.com:8080/random" -si | grep HTTP | awk '{print $2}') 303
validate "latest comic in /" $(curl -X GET "http://consolia-comic.com:8080" -si | grep "#$latest_comic_id" | wc -l) 1

# RSS
printf "\nRSS\n"
validate "200 OK /rss.xml" $(curl -X GET "http://consolia-comic.com:8080/rss.xml" -si | grep HTTP | awk '{print $2}') 200
validate "rss.xml begins w/ xml" $(curl -X GET "http://consolia-comic.com:8080/rss.xml" -s | grep '^<?xml version="1.0" encoding="utf-8"?>' | wc -l) 1

# Varnish
printf "\nVarnish\n"
validate "200 OK on /" $(curl -X GET "http://consolia-comic.com/" -si | grep HTTP | awk '{print $2}') 200
validate "cache hit on /" $(curl -X GET "http://consolia-comic.com/" -si | grep "X-Cache:" | grep HIT | wc -l) 1
validate "/random not cached" $(curl -X GET "http://consolia-comic.com/random" -si | grep "X-Cache:" | grep MISS | wc -l) 1
validate "/random not cached" $(curl -X GET "http://consolia-comic.com/random" -si | grep "X-Cache:" | grep MISS | wc -l) 1

# SSL
printf "\nSSL / nginx\n"
validate "200 OK on SSL /" $(curl -X GET "https://consolia-comic.com/" -si | grep HTTP | awk '{print $2}') 200
validate "gzip on SSL /" $(curl -X GET -H 'Accept-Encoding: gzip,deflate' "https://consolia-comic.com" -sI | grep -i "Content-Encoding" | grep gzip | wc -l) 1

# static.consolia.com
printf "\nstatic.consolia.com\n"
validate "/ is forbidden" $(curl -X GET "https://static.consolia-comic.com/" -si | grep HTTP | awk '{print $2}') 403
validate "/comics/ is forbidden" $(curl -X GET "https://static.consolia-comic.com/comics/" -si | grep HTTP | awk '{print $2}') 403
validate "/assets/ is forbidden" $(curl -X GET "https://static.consolia-comic.com/assets/" -si | grep HTTP | awk '{print $2}') 403
validate "/assets2.0/ is forbidden" $(curl -X GET "https://static.consolia-comic.com/assets2.0/" -si | grep HTTP | awk '{print $2}') 403
validate "200 OK on SSL logo" $(curl -X GET "https://static.consolia-comic.com/assets/logo.svg" -si | grep HTTP | awk '{print $2}') 200
