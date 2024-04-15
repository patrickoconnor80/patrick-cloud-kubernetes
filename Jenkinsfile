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
                        env.OLD_IMAGE_TAG = sh (script: 'cat cfg/dbt.yaml | grep image: | cut -d \':\' -f 3 | cut -d \'"\' -f 1', returnStdout: true)
                        sh "sed -i 's+948065143262.dkr.ecr.us-east-1.amazonaws.com/patrick-cloud-dev-dbt-docs:[0-9,A-Z]*+948065143262.dkr.ecr.us-east-1.amazonaws.com/patrick-cloud-dev-dbt-docs:${env.DOCKERTAG}+g' cfg/dbt.yaml"
                        sh "cat cfg/dbt.yaml"
                        sh "git add ."
                        sh "git commit -m 'Done by Jenkins Job changemanifest: ${env.BUILD_NUMBER}'"
                        sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/${GIT_USERNAME}/patrick-cloud-kubernetes.git HEAD:main"
      }
    }
  }
}
}