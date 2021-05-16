#!/usr/bin/env bash
set -e

AWS_PROFILE=pedro
S3_BUCKET=ukn.com.br
CLOUDFRONT_ID=E2USKOXQ4UROD
SOURCE_DIR=public

echo "Building"
cd ${S3_BUCKET}
hugo
#TODO
sed -i 's/Opala 75 - Opala 75/Opala/g' ${SOURCE_DIR}/index.html

echo "Removing all files on bucket"
aws s3 rm s3://${S3_BUCKET} --recursive --profile ${AWS_PROFILE}

echo "Attempting to upload site .."
aws s3 sync ${SOURCE_DIR}/ s3://${S3_BUCKET}/ --profile ${AWS_PROFILE}

echo "Invalidating cloudfrond distribution to get fresh cache"
aws cloudfront create-invalidation --distribution-id=${CLOUDFRONT_ID} --paths / --profile ${AWS_PROFILE}

echo "Distribution status:"  
timeout=5
for i in $(seq 1 ${timeout}) ; do
	echo "[${i}/${timeout}] checking"
	status=$(aws cloudfront list-distributions --profile ${AWS_PROFILE} | jq -r ".DistributionList.Items[] | select(.Id ==\"$CLOUDFRONT_ID\") | .Status")
	if [ "${status}" == "Deployed" ] ; then
		echo "Deployment completed!"
		exit 0
	fi
	sleep 1
done

exit 1

# latest photo number
#find assets/ -type f -iname 'photo_*' | awk -F '/' '{ print $NF }' | tr -d '[a-z]' | tr -d '.' | tr -d '_' | sort -n | tail -n 1
