node {

    stage('Clone Repository') {
        checkout scm
    }

    stage('Checkov Scan') {
       sh '''
            export CHECKOV_OUTPUT_CODE_LINE_LIMIT=100
            SKIPS=$(cat 'tf/.checkovignore.json' | jq -r 'keys[]' | sed 's/$/,/' | tr -d '\n' | sed 's/.$//')
            [ ! -d "checkov_venv" ] && python3 -m venv checkov_venv
            . checkov_venv/bin/activate
            pip install checkov
            checkov -d ./tf --skip-check $SKIPS --skip-path tf/.archive
            deactivate
        '''
    }

    stage('Apply Terraform - Volumes') {
        sh """
            cd tf/volumes
            terraform init -backend-config=./env/${ENV}/backend.config -reconfigure
            terraform apply -var-file=./env/${ENV}/${ENV}.tfvars -auto-approve
            cd ../..
        """
    }

    stage('Apply Terraform - EKS') {
        sh """
            cd tf/eks
            terraform init -backend-config=./env/${ENV}/backend.config -reconfigure
            terraform apply -var-file=./env/${ENV}/${ENV}.tfvars -auto-approve
            
            export EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
            export EKS_CLUSTER_ENDPOINT=$(terraform output -raw eks_cluster_endpoint)
            export KARPENTER_QUEUE_NAME=$(terraform output -raw karpenter_queue_name)
            export KARPENTER_IAM_ROLE_ARN=$(terraform output -raw karpenter_iam_role_arn)
            cd ../..
        """
    }

    stage('Apply Manifests for base infra') {
        sh "sh bin/k8s_apply_base_infra.sh"
    }

}