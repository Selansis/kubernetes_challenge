pipeline {
    agent any

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
                git(
                    url: 'https://github.com/Selansis/kubernetes_challenge.git',
                    branch: 'main' 
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub_id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    script {
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    minikube kubectl -- set image deployment/website-deployment apache=${DOCKER_IMAGE}:${DOCKER_TAG}
                """
                    }
                }
            }
        }
    }
}