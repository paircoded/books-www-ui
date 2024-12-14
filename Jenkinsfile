def config = [
    terraform_dir: './terraform',
]

def app;

pipeline {
    environment {
        BUILD_NUMBER=/${env.BUILD_NUMBER}/
        TERRAFORM_DIR=/${config.terraform_dir}/
    }

    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build image') {
            steps {
                script {
                    app = docker.build("books-www-ui")
                }
            }
        }

        stage('Push image') {
            steps {
                script {
                    docker.withRegistry('https://docker-registry.poorlythoughtout.com', 'docker registry') {
                        app.push("build-${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                   withCredentials([file(credentialsId: 'k8sKubeConfig', variable: 'secretFile')]) {
                        sh '''
                            # god help me if I ever do anything concurrently
                            rm -rf ~/.kube && mkdir ~/.kube && chmod 700 ~/.kube && rm -f ~/.kube/config && ln -s ${secretFile} ~/.kube/config
                            cd ${TERRAFORM_DIR}
                            terraform init
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
               withCredentials([file(credentialsId: 'k8sKubeConfig', variable: 'secretFile')]) {
                    sh '''
                        # god help me if I ever do anything concurrently
                        rm -rf ~/.kube && mkdir ~/.kube && chmod 700 ~/.kube && rm -f ~/.kube/config && ln -s ${secretFile} ~/.kube/config
                        cd ${TERRAFORM_DIR}
                        terraform plan -var image_tag="build-${BUILD_NUMBER}"
                       '''
               }
            }
        }

        stage('Terraform Apply') {
            steps {
               withCredentials([file(credentialsId: 'k8sKubeConfig', variable: 'secretFile')]) {
                    sh '''
                        # god help me if I ever do anything concurrently
                        rm -rf ~/.kube && mkdir ~/.kube && chmod 700 ~/.kube && rm -f ~/.kube/config && ln -s ${secretFile} ~/.kube/config
                        cd ${TERRAFORM_DIR}
                        terraform apply -auto-approve -var image_tag="build-${BUILD_NUMBER}"
                       '''
               }
            }
        }
    }
}
