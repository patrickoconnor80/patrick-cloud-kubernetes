node {
    def app

    stage('Clone repository') {
        checkout scm
    }

    stage('Update GIT') {
            script {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        //def encodedPassword = URLEncoder.encode("$GIT_PASSWORD",'UTF-8')
                        sh "git config user.email patrickoconnor8014@gmail.com"
                        sh "git config user.name patrickoconnor80"
                        //sh "git switch master"
                        sh "cat cfg/dbt.yaml"
                        sh "sudo snap set system homedirs='/var/lib/jenkins/workspace/dbt-docs-update-manifest'"
                        sh "yq -i '.spec.template.spec.containers[0].image=948065143262.dkr.ecr.us-east-1.amazonaws.com/patrick-cloud-dev-dbt-docs:${DOCKERTAG}' cfg/dbt.yaml"
                        sh "cat cfg/dbt.yaml"
                        sh "git add ."
                        sh "git commit -m 'Done by Jenkins Job changemanifest: ${env.BUILD_NUMBER}'"
                        sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/${GIT_USERNAME}/patrick-cloud-kubernetes.git HEAD:main"
      }
    }
  }
}
}