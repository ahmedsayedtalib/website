pipeline {
    agent any

    environment {
        GITHUB_CRED      = 'github-cred'
        SONAR_CRED       = 'sonarqube-cred'
        SONARQUBE_HOST   = 'http://192.168.103.2:32000'
        DOCKER_CRED      = 'docker-cred'
        IMAGE_NAME       = 'ahmedsayedtalib/website'
        KUBERNETES_CRED  = 'kubernetes-cred'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: GITHUB_CRED, url: 'https://github.com/ahmedsayedtalib/website.git'
                script {
                    env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Docker image tag: ${env.IMAGE_TAG}"
                }
            }
            post {
                success { echo '✅ Git checkout succeeded' }
                failure { echo '❌ Git checkout failed' }
            }
        }

        stage("SonarQube Static Code Analysis") {
            steps {
                script {
                    echo "Running SonarQube analysis..."

                    // Path to Jenkins-installed SonarScanner tool
                    def scannerHome = tool 'sonar-scanner'

                    // Inject SonarQube environment variables
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
            post {
                success { echo '✅ SonarQube analysis passed' }
                failure { echo '❌ SonarQube analysis failed' }
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
            post {
                success { echo '✅ Docker image pushed successfully' }
                failure { echo '❌ Docker image push failed' }
            }
        }

        stage('Update K8s Manifests') {
            steps {
                script {
                    sh """
                    sed -i "s|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" k8s/overlays/dev/patch-image.yaml
                    sed -i "s|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" k8s/overlays/prod/patch-image.yaml

                    git config user.email "jenkins@ci.local"
                    git config user.name "Jenkins CI"
                    git add k8s/overlays/dev/patch-image.yaml k8s/overlays/prod/patch-image.yaml
                    git commit -m "Update image tag to ${IMAGE_TAG} [ci skip]" || echo "No changes to commit"
                    git push origin main
                    """
                }
            }
            post {
                success { echo '✅ K8s manifests updated with new image tag' }
                failure { echo '❌ Failed to update manifests' }
            }
        }

        stage('Kubernetes Resources Overview') {
            steps {
                withKubeConfig([credentialsId: KUBERNETES_CRED, contextName: 'minikube']) {
                    echo "Resources in DEV namespace:"
                    sh "kubectl get deployments,services,ingress -n dev -o wide | grep ${IMAGE_NAME} || echo 'No matching resources in dev'"

                    echo "Resources in PROD namespace:"
                    sh "kubectl get deployments,services,ingress -n prod -o wide | grep ${IMAGE_NAME} || echo 'No matching resources in prod'"
                }
            }
            post {
                success { echo '✅ Kubernetes resources listed successfully' }
                failure { echo '❌ Failed to list Kubernetes resources' }
            }
        }
    }

    post {
        always { echo 'Pipeline finished' }
        success { echo '✅ Pipeline completed successfully' }
        failure { echo '❌ Pipeline failed' }
    }
}
