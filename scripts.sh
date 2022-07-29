set -e

## Deploy base services
echo "Deploying base services"
## sls deploy --config base.services.template.yml --verbose --param="app=tbb"
rm -rf ./.serverless

APP_NAME=$(aws cloudformation describe-stacks --stack-name tbb-base-services --query "Stacks[*].Outputs[?OutputKey=='ApplicationName'].OutputValue" --output text)
S3_BUCKET=$(aws cloudformation describe-stacks --stack-name tbb-base-services --query "Stacks[*].Outputs[?OutputKey=='ServerlessDeploymentBucketName'].OutputValue" --output text)
CICD_ROLE=$(aws cloudformation describe-stacks --stack-name tbb-base-services --query "Stacks[*].Outputs[?OutputKey=='PipelineRoleArn'].OutputValue" --output text)
FRONT_REPO=$(aws cloudformation describe-stacks --stack-name tbb-base-services --query "Stacks[*].Outputs[?OutputKey=='FrontendRepository'].OutputValue" --output text)
BACK_REPO=$(aws cloudformation describe-stacks --stack-name tbb-base-services --query "Stacks[*].Outputs[?OutputKey=='BackendRepository'].OutputValue" --output text)
SERV_REPO=$(aws cloudformation describe-stacks --stack-name tbb-base-services --query "Stacks[*].Outputs[?OutputKey=='ServicesRepository'].OutputValue" --output text)
LAYER=""

echo "Base services deployed succesfull"
echo "APP_NAME = $APP_NAME // Application name"
echo "S3_BUCKET = $S3_BUCKET // Shared deplyment bucket"
echo "CICD_ROLE = $CICD_ROLE // Pipepine Role Arn"
echo "FRONT_REPO = $FRONT_REPO // Frontend git repository"
echo "BACK_REPO = $BACK_REPO // Backend git repository"
echo "SERV_REPO = $SERV_REPO // Services git repository"

# Deploy Backend CICD
LAYER="backend"
echo "Deploying backend cicd"
## sls deploy --config cicd.template.yml --verbose \
##     --param="layer=$LAYER"  \
##     --param="app=$APP_NAME"  \
##     --param="bucket=$S3_BUCKET" \
##     --param="repo=$BACK_REPO"  \
##     --param="roleArn=$CICD_ROLE" 
rm -rf ./.serverless
echo "Backend cicd deployed succesfull"

# Deploy Front CICD
LAYER="frontend"
echo "Deploying frontend cicd"
## sls deploy --config cicd.template.yml --verbose \
##     --param="layer=$LAYER"  \
##     --param="app=$APP_NAME"  \
##     --param="bucket=$S3_BUCKET" \
##     --param="repo=$FRONT_REPO"  \
##     --param="roleArn=$CICD_ROLE" 
rm -rf ./.serverless
echo "Frontend cicd deployed succesfull"

# Deploy Services CICD
LAYER="services"
echo "Deploying services"
##sls deploy --config cicd.template.yml --verbose \
##    --param="layer=$LAYER"  \
##    --param="app=$APP_NAME"  \
##    --param="bucket=$S3_BUCKET" \
##    --param="repo=$SERV_REPO"  \
##    --param="roleArn=$CICD_ROLE" 
rm -rf ./.serverless
echo "Services cicd deployed succesfull"

# Create backend repository folder
mkdir -p ../backend
mkdir -p ../frontend
mkdir -p ../services

# Copy base files
cp -a base/. ../backend/
cp -a base/. ../frontend/
cp -a base/. ../frontend/

# Init backend git proyect
cd ../backend
git init
git checkout -b dev
git add .
git commit -m 'Initial Commit'
git checkout -b master
git merge dev

# Init backend git proyect
cd ../frontend
git init
git checkout -b dev
git add .
git commit -m 'Initial Commit'
git checkout -b master
git merge dev

# Init backend git proyect
cd ../services
git init
git checkout -b dev
git add .
git commit -m 'Initial Commit'
git checkout -b master
git merge dev