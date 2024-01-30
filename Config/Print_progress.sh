#!/bin/bash

# 进度条长度
BAR_LENGTH=50

# 函数：打印进度条
print_progress() {
    local progress=$(( $1 * BAR_LENGTH / 100 ))
    printf "["
    for i in $(seq 1 $BAR_LENGTH); do
        if [ $i -le $progress ]; then
            printf "#"
        else
            printf " "
        fi
    done
    printf "] %d%%\r" "$1"
}

# 任务执行方法
#for i in {1..100}; do
#    print_progress $i
#    #代码执行
#done
