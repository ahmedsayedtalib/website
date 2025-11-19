pipeline {
    agent any

    environment {
        GITHUB_CRED      = 'gitbuh-cred'           // GitHub token for push
        SONAR_CRED       = 'sonarqube-cred'        // SonarQube token
        SONARQUBE_HOST   = 'http://192.168.103.2:32000'
        DOCKER_CRED      = 'docker-cred'
        IMAGE_NAME       = 'ahmedsayedtalib/website'
    }

    stages {
        stage("Checkout Code") {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    userRemoteConfigs: [[
                        url: 'https://github.com/ahmedsayedtalib/website.git',
                        credentialsId: "${GITHUB_CRED}"
                    ]]
                ])
                script {
                    // Short commit hash for tagging Docker image
                    def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.IMAGE_TAG = commitHash
                    echo "Docker image tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage("SonarQube Static Code Analysis") {
            steps {
                script {
                    echo "Running SonarQube analysis..."
                    def scannerHome = tool 'sonar-scanner'

                    withSonarQubeEnv('sonarqube') {
                        withCredentials([string(credentialsId: "${SONAR_CRED}", variable: "SONAR_TOKEN")]) {
                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                  -Dsonar.projectKey=mypersonalwebsite \
                                  -Dsonar.sources=. \
                                  -Dsonar.inclusions=**/*.html,**/*.css,**/*.js \
                                  -Dsonar.host.url=${SONARQUBE_HOST} \
                                  -Dsonar.login=${SONAR_TOKEN}
                            """
                        }
                    }
                }
            }
        }

        stage("Docker Build & Push") {
            steps {
                script {
                    withCredentials([string(credentialsId: "${DOCKER_CRED}", variable: "DOCKER_PASS")]) {
                        sh """
                            echo $DOCKER_PASS | docker login -u ahmedsayedtalib --password-stdin
                            docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                            docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

        stage("Update K8s Manifests") {
            steps {
                script {
                    // Update image tags in manifests
                    sh """
                        sed -i s|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g k8s/overlays/dev/patch-image.yaml
                        sed -i s|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g k8s/overlays/prod/patch-image.yaml
                    """

                    // Commit and push changes using GitHub token
                    withCredentials([usernamePassword(credentialsId: "${GITHUB_CRED}", usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            git config user.email "jenkins@ci.local"
                            git config user.name "Jenkins CI"
                            git add k8s/overlays/dev/patch-image.yaml k8s/overlays/prod/patch-image.yaml
                            git commit -m "Update image tag to ${IMAGE_TAG} [ci skip]" || echo "No changes to commit"
                            git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@github.com/ahmedsayedtalib/website.git
                            git push origin main
                        """
                    }
                }
            }
        }

        stage("Kubernetes Resources Overview") {
            steps {
                echo "You can add kubectl commands here to verify resources, if needed"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}
