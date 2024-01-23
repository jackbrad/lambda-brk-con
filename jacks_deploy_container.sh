docker build --platform linux/amd64 -t docker-image:brk_sum .

#Set the --region value to the AWS Region where you want to create the Amazon ECR repository.
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 767825916199.dkr.ecr.us-east-1.amazonaws.com

#create the repository for the image 
aws ecr create-repository --repository-name brk_sum --region us-east-1 --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE

#tag container
docker tag docker-image:brk_sum 767825916199.dkr.ecr.us-east-1.amazonaws.com/brk_sum:latest

#upload container to ECR repository
docker push 767825916199.dkr.ecr.us-east-1.amazonaws.com/brk_sum:latest

#create the function
aws lambda create-function --function-name brk_sum3 --package-type Image --code ImageUri=767825916199.dkr.ecr.us-east-1.amazonaws.com/brk_sum:latest --role arn:aws:iam::767825916199:role/service-role/bedrock_summary_claude_v2-role-liuoaokd --timeout 30 --memory-size 1024  

#Update 
aws lambda update-function-code --function-name brk_sum3 --image-uri 767825916199.dkr.ecr.us-east-1.amazonaws.com/brk_sum:latest