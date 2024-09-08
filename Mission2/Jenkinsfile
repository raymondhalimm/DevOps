pipeline {
    agent any
    
    environment {
        PATH = "$PATH:/usr/local/bin"
    }

    stages {
        stage('Checkout Blockscout Helm Chart Repo') {
            steps {
                sh 'helm version'
                dir ('helm-repo') {
                    // Clone the Helm chart repository
                    git branch: 'main', url: 'https://github.com/blockscout/helm-charts.git'
                }
                
            }
        }

        stage('Checkout My Mission2 YAML Repo') {
            steps {
                dir ('my-repo') {
                    // Clone the my Mission2 YAML repository
                    git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/raymondhalimm/DevOps.git'
                }
                
            }
        }
        
        stage('Package Helm Chart + My YAML files') {
            steps {
                sh '''
                echo 'Packaging Helm chart with the additional YAML file...'
                mkdir -p temp-chart
                cp -r helm-repo/charts/blockscout-stack/* temp-chart/
                cp my-repo/Mission2/myvalues.yaml temp-chart/
                cp my-repo/Mission2/hpa.yaml temp-chart/templates/
                helm package ./temp-chart
                '''
            }
        }

        stage('Build Helm Chart') {
            steps {
                echo 'Building and packaging Helm chart...'
                // Package and Build the helm chart with myvalues.yaml from my repository
                sh 'helm install my-blockscout ./helm-repo/charts/blockscout-stack -f ./my-repo/Mission2/myvalues.yaml'
            }
        }

        stage('Deploy Helm Chart with HPA') {
            steps {
                echo 'Deploying Helm chart and HPA...'
                // Apply deployment with HPA YAML file
                sh 'kubectl apply -f ./my-repo/Mission2/hpa.yaml'
            }
        }
    }

    post {
        always {
            echo "Pipeline completed!"
        }
    }
}
