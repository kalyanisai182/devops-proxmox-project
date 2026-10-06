pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        IMAGE_NAME = 'kalyanisai182/demo-app'
    }

    stages {
        stage('Prepare') {
            steps {
                script {
                    env.IMAGE_TAG = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
                }
                echo "Building ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Build & Test') {
            agent {
                docker {
                    image 'maven:3.9-eclipse-temurin-21'
                    args '-e HOME=/tmp'
                    reuseNode true
                }
            }
            steps {
                dir('app') {
                    sh 'mvn -B -Dmaven.repo.local=$WORKSPACE/.m2/repository clean verify'
                }
            }
            post {
                always {
                    junit 'app/target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'maven:3.9-eclipse-temurin-21'
                    args '-e HOME=/tmp'
                    reuseNode true
                }
            }
            steps {
                withSonarQubeEnv('sonarqube') {
                    dir('app') {
                        sh 'mvn -B -Dmaven.repo.local=$WORKSPACE/.m2/repository org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.token=$SONAR_AUTH_TOKEN'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build --build-arg APP_VERSION=$IMAGE_TAG -t $IMAGE_NAME:$IMAGE_TAG -t $IMAGE_NAME:latest app'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                        docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
            sh 'docker image rm $IMAGE_NAME:$IMAGE_TAG || true'
        }
        success {
            echo "Pushed ${IMAGE_NAME}:${IMAGE_TAG}"
        }
    }
}
