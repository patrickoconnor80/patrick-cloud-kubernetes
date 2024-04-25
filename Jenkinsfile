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
            cd ../..
        """
    }

    stage('Apply Manifests for base infra') {
        sh """
            sudo curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
            sh bin/k8s_apply_base_infra.sh
        """
    }

}