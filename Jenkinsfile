pipeline {
    agent any

    environment {
        GITHUB_CRED      = 'github-cred'
        SONAR_CRED       = 'sonarqube-cred'
        SONAR_URL        = 'http://192.168.103.2:32000'
        DOCKER_CRED      = 'docker-cred'
        IMAGE_NAME       = 'ahmedsayedtalib/website'
        KUBERNETES_CRED  = 'kubernetes-cred'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: GITHUB_CRED, url: 'https://github.com/ahmedsayedtalib/website.git'
            }
            post {
                success { echo '✅ Git checkout succeeded' }
                failure { echo '❌ Git checkout failed' }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def sonarHome = 'sonar-scanner' // define sonar scanner path
                    withSonarQubeEnv('sonarqube') {
                        withCredentials([string(credentialsId: SONAR_CRED, variable: 'SONAR_TOKEN')]) {
                            sh """
                            ${sonarHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=website \
                                -Dsonar.host.url=${SONAR_URL} \
                                -Dsonar.token=${SONAR_TOKEN} \
                                -Dsonar.sources=. \
                                -Dsonar.inclusions=**/*.html,**/*.css,**/*.js
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
                script {
                    // Generate Docker image tag here
                    def IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Docker image tag: ${IMAGE_TAG}"

                    withCredentials([usernamePassword(credentialsId: DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        """
                    }

                    // Update Kubernetes manifests immediately after pushing
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
                success { echo '✅ Docker image pushed and K8s manifests updated' }
                failure { echo '❌ Docker/K8s stage failed' }
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
