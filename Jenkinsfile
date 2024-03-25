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
                        sh "cat cfg/simple_app.yaml"
                        sh "sed -i 's+patrickoconnor80/simple-app.*+patrickoconnor80/simple-app:${DOCKERTAG}+g' cfg/simple_app.yaml"
                        sh "cat cfg/simple_app.yaml"
                        sh "git add ."
                        sh "git commit -m 'Done by Jenkins Job changemanifest: ${env.BUILD_NUMBER}'"
                        sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/${GIT_USERNAME}/patrick-cloud-kubernetes.git HEAD:main"
      }
    }
  }
}
}