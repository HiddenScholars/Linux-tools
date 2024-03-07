#!/bin/bash

# 进度条函数定义
show_progress_bar() {
    local total=$1
    local command_to_execute=$2
     local args="${@:3}"  # 获取除前两个参数外的其他参数

    for ((i=0; i<=total; i++))
    do
        # 执行命令或操作
        $command_to_execute $args

        # 更新进度条
        progress=$((i*100/total))
        progress_bar=$(printf "%.0s=" $(seq 1 $((progress/2))))
        remaining_bar=$(printf "%.0s-" $(seq $((progress/2+1)) 50))

        # 清除当前行并输出进度条和百分比
        echo -ne "\r\033[K\033[32mProgress: [\033[36m${progress_bar}${remaining_bar}\033[32m] ${progress}%\033[0m"
    done

    echo -e "\nOK！"
}

# 调用进度条函数，并传入命令参数
show_progress_bar 1


