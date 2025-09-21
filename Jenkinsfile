pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    tools {
        nodejs 'node-20'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Assuming the code is in a Git repository
                git url: 'https://github.com/TheOpenSuite/Team-Availability.git' 
            }
        }

        stage('Check Prerequisites') {
            steps {
                docker.withTool('docker') {
                    echo "Docker is installed and ready."
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('TeamavailTest') {
                    script {
                        if (fileExists('package.json')) {
                            echo "### Installing Node.js dependencies"
                            sh 'npm ci'
                        } else {
                            echo "No package.json found. Skipping npm steps."
                        }
                    }
                }
            }
        }

        stage('Lint & Format') {
            steps {
                dir('TeamavailTest') {
                    script {
                        def lintStatus = sh(script: "npm run lint || true", returnStatus: true)
                        if (lintStatus == 0) {
                            echo "### Running lint"
                            sh 'npm run lint'
                        } else {
                            echo "No lint script found, skipping this step."
                        }

                        def formatStatus = sh(script: "npm run format || true", returnStatus: true)
                        if (formatStatus == 0) {
                            echo "### Running format"
                            sh 'npm run format'
                        } else {
                            echo "No format script found, skipping this step."
                        }
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                dir('TeamavailTest') {
                    script {
                        def testStatus = sh(script: "npm run test || true", returnStatus: true)
                        if (testStatus == 0) {
                            echo "### Running tests"
                            sh 'npm run test'
                        } else {
                            echo "No test script found, skipping this step."
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "### Building Docker image: teamavail:local"
                sh 'docker build -t teamavail:local -f TeamavailTest/Dockerfile ./TeamavailTest'
            }
        }

        stage('Docker Compose') {
            steps {
                script {
                    if (fileExists('TeamavailTest/docker-compose.yml')) {
                        echo "### Starting with docker compose"
                        sh 'docker compose -f TeamavailTest/docker-compose.yml up -d --build'
                        echo "### Status:"
                        sh 'docker ps --filter "ancestor=teamavail:local" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
                    } else {
                        echo "No docker-compose.yml found. Built image is available as teamavail:local"
                    }
                }
            }
        }
    }
}
