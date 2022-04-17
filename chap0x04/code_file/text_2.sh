wget -O web_log.tsv.7z https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z

p7zip -d web_log.tsv.7z

#统计访问来源主机TOP 100和分别对应出现的总次数
function top100host {
    awk -F '\t' '
    BEGIN{
    times=0
    len=0
    }
    $1!="host"{
        hosts[$1]+=1;
    }
    END{
        for(host in hosts)
        {
            if(times<100)
            {
                print host hosts[host] | "sort -r -n -k2"
                times+=1
            }
            break;
        }
        }'
}


while getopts 'hti' opration; do
    case $opration in
    h)
      help
      exit 0 ;;
    t)
      top100host
      exit 0 ;;
    i)
      top100IP
      exit 0 ;;
    /?)
      echo "illegal argument"
      exit 0 ;;
    esac
done