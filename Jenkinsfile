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
                 git branch: 'main', url: 'https://github.com/TheOpenSuite/Team-Availability.git' 
            }
        }

        stage('Check Prerequisites') {
            steps {
                script{
                    docker.withTool('docker') {
                        echo "Docker is installed and ready."
                    }
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('TeamavailTest(edited)') {
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
                dir('TeamavailTest(edited)') {
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
                dir('TeamavailTest(edited)') {
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
                sh 'docker build -t teamavail:local -f TeamavailTest(TeamavailTest)/Dockerfile ./TeamavailTest(TeamavailTest)'
            }
        }

        stage('Docker Compose') {
            steps {
                script {
                    if (fileExists('/docker-compose.yml')) {
                        echo "### Starting with docker compose"
                        sh 'docker compose -f /docker-compose.yml up -d --build'
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
