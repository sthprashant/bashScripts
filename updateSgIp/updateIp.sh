#!/bin/bash

### Description:
### Simple script to add AWS SSH ingress for current IP

#   Pre-requisites
#   1. Download and Install aws cli
#   2. configure credentails for aws cli
#   3. Add "cli_pager=" to your aws profile


group_id=""
protocol="tcp"
sshPort="22"
httpPort="8080"
IP=$(curl -s https://checkip.amazonaws.com)
profile=""
aws_output_file_path="./aws_output.out"
last_ip_file_path="last_ip.out"

if [ "$IP" == $(awk '{print $0}' "$last_ip_file_path") ]
then

    echo "There may be existing SSH INGRESS for your current IP - $IP, Please reconfirm."
else
    #rm ./aws_output.txt
    echo "Adding SSH INGRESS for $IP/32"
    aws ec2 authorize-security-group-ingress --group-id $group_id --protocol $protocol --port $sshPort --cidr "$IP/32"  --output text --profile $profile > "$aws_output_file_path" 2>&1
    aws ec2 authorize-security-group-ingress --group-id $group_id --protocol $protocol --port $httpPort --cidr "$IP/32"  --output text --profile $profile > "$aws_output_file_path" 2>&1
    success=$(sed -n /True/p "$aws_output_file_path")

    if [ "$success" == "True" ]
    then
        echo "$IP" > "$last_ip_file_path"
        echo "SSH INGRESS for $IP/32 has been added."
    else
        cat "$aws_output_file_path"
    fi
fi