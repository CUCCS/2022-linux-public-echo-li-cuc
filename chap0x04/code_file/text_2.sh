#!/usr/bin/env bash
function help {
  echo "usage: bash text_2.sh [operation]"
  echo "-h      show this help"
  echo "-t      show statistics of top100 host and its access times"
  echo "-i      show statistics of top100 host IP and its access times"
  echo "-u      show most frequently accessed top100 URLs"
  echo "-s      show frequency of different statuscode and correspponding proportion"
  echo "-4      show TOP10 URL corresponding to statuscode like 4XX and its frequency"
  echo "-U URL  show TOP100 hosts according to URL"
}

#统计访问来源主机TOP 100和分别对应出现的总次数
function top100host {
  echo "  times names"
  awk -F '\t' '{print $1}' web_log.tsv | sort | uniq -c | sort -r -n -k1 | head -100
}

#统计访问来源主机TOP 100 IP和分别对应出现的总次数
function top100IPs {
  echo "times names"
  awk -F '\t' 'match($1,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]/){print $1}' web_log.tsv | sort | uniq -c |sort -r -n -k1 |head -100
}

#统计最频繁被访问的URL TOP 100
function top100URLs {
  echo "times URL"
  awk -F '\t' '{print $5}' web_log.tsv | sort | uniq -c | sort -r -n -k1 | head -100
}

#统计不同响应状态码的出现次数和对应百分比
function statusCodes {
  awk -F '\t' '$6!="response"{print $6}' web_log.tsv | sort | uniq -c | awk 'BEGIN{total=0}
    {total+=$1 
    status[$2]=$1} 
    END{
      printf("status\ttotal \tpercentage\n")
      for (s in status)
      {
        percentage[s]=status[s]/total 
        printf("%-6d\t%-6d\t%f\n",s,status[s],percentage[s])
      }
    }
  '
}

#分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
#UT4表示‘4’XX的状态码对应的‘U’RL和‘T’imes（次数）
function UT4 {
  echo "404的top10URL" 
  awk -F '\t' '$6=="404" {print $5}' web_log.tsv | sort | uniq -c | sort -n -r -k1 | head -10
  echo "403的top10URL" 
  awk -F '\t' '$6!="response"&&$6==403{print $5}' web_log.tsv | sort | uniq -c | sort -n -r -k1 | head -10
}

#给定URL输出TOP 100访问来源主机
function Utop100 {
  echo "TOP100 hosts for $1"
  awk -F '\t' -vu="$1" '$5==u{print $1}' web_log.tsv | sort | uniq -c |sort -n -r -k1 | head -100
}


while getopts 'htius4U:' operation; do
    case $operation in
    h)
      help
      exit 0 ;;
    t)
      top100host
      exit 0 ;;
    i)
      top100IPs
      exit 0 ;;
    u)
      top100URLs
      exit 0 ;;
    s)
      statusCodes
      exit 0 ;;
    4)
      UT4 
      exit 0 ;;
    U)
      Utop100 "$OPTARG"
      exit 100 ;;
    /?)
      echo "illegal argument"
      exit 0 ;;
    esac
done