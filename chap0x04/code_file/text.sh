wget -O data https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/worldcupplayerinfo.tsv
awk -F '\t' '
  BEGIN{
    young = 0
    middle = 0
    old = 0
  }
  $6!="Age"{
    if($6<20){young+=1}
    else if($6<=30){middle+=1}
    else {old+=1}
  }
  END{
    printf("age<20\t20<=age<=30\tage>30\n")
    printf("%-6d\t%-11d\t%-6d\n",young,middle,old)
  }
  ' data

awk -F '\t' '
$5!="Position"{
  P[$5]+=1
}
END{
  printf("Position  \tTotal\tProportion\n")
  for(name in P)
  {
    printf("%-10s\t%-5d\t%-10f\n",name,P[name],P[name]/(NR-1))
  }
}' data

awk -F '\t' '
$9!="Player"{
  len=length($9)
  if(NR==2){
    names[$9]="shortest";
    names["a"]="longest";
    temp=$9;
    next;
  }
  for(name in names)
  {
    #判断新加入的元素是否是最长的，或者是不是并列最长的
    # printf("本轮比较的是%s和%s\n",name,$9);
    # printf("当前name有：");
    # for(i in names)
    # {
    #   printf("%s:%s\n",i,names[i])
    # }
    # printf("***************\n");
    if(names[name]=="longest" && len>=length(name) && name!=$9)
    {
      names[$9]="longest";
      if(len>length(name))
      {
        delete names[name];
      }
    }
    #判断新加入的元素是否是最短的，或者是不是并列最短的
    if(names[name]=="shortest"&&len<=length(name))
    {
      names[$9]="shortest";
      if(len<length(name)){
        delete names[name];}
    }
  }
}
END{
  flag=0
  for(name in names)
  {
    if(names[name]=="shortest")
    {
      printf("名字最短的人（之一）：%s\n",name);
      delete names[name];
    }
  }
  for(name in names)
  {
    if(names[name]=="longest")
    {
      if(length(temp)>length(name))
      {
        printf("名字最长的人：%s\n",temp);
        break;
      }
      else if(length(temp)==length(name))
      {
        printf("名字最长的人之一：%s\n",name);
        flag=1;
      }
      else {printf("名字最长的人之一：%s\n",name);}
     }
  }
  if(flag==1){printf("名字最长的人之一：%s\n",temp);}
}' data

awk -F '\t' '
  BEGIN{
    onum=0;
    ynum=0;
    icounter=1;
    jcounter=1;
    counter=0;
  }
  $6!="Age"{
    if(NR==2)
    {
      OP[onum]=$9;#存储年龄最大人名
      YP[ynum]=$9;#存储年龄最小人名
      oage=$6;#最大的年龄
      yage=$6;#最小的年龄
      next;
    }
    if($6>oage)
    {
      OP[0]=$9;
      for(icounter;icounter<onum;icounter++)
      {
        delete OP[i];
      }
      onum=0;
      oage=$6;
    }
    else if($6==oage)
    {
      OP[onum+1]=$9;
      onum+=1;
    }
    else if($6==yage)
    {
       YP[ynum+1]=$9;
       ynum+=1;
    }
    else if($6<yage)
    {
      YP[0]=$9;
      for(jcounter;jcounter<ynum;jcounter++)
      {
        delete YP[j];
      }
      ynum=0;
      yage=$6;
    }
  }
END{
    printf("年龄最大的球员\t\t\t\t年龄最小的球员\n");
    printf("======================================================\n");
    min=ynum<onum?ynum:onum;
    for(counter;counter++;counter<min);
    {printf("%-26s%-26s\n",OP[counter],YP[counter]);}
    if(onum>ynum)
    {
      for(counter;counter<onum;counter++)
      {
        printf("%-26s\n",OP[counter]);
      }
    }
    else if(ynum>onum)
    {
      for(counter;counter<onum;counter++)
      {
        printf("%*s%-26s\n",26,"",YP[counter]);
      }
    }
  }' data