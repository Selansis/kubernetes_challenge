parameters {
    string(name: 'Container_version', defaultValue: 'latest', description: 'Wersja kontenera')
}

environment {
    DOCKER_IMAGE = "selansis/k8s_challenge"
    DOCKER_TAG = "${params.Container_version}"
}

stages {
    stage('Checkout Code') {
        steps {
            git 'https://github.com/Selansis/kubernetes_challenge.git'
        }
    }
    
    stage('Build Docker Image') {
        steps {
            script {
                app = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
            }
        }
    }
    
    stage('Push Docker Image') {
        steps {
            script {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh """
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
    }
    
    stage('Deploy to Kubernetes') {
        steps {)
            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                script {
                    sh "kubectl set image deployment/website-deployment containerName=${DOCKER_IMAGE}:${DOCKER_TAG} --record"
                }
            }
        }
    }
}
