pipeline {
    agent any

    environment {
        SSH_KEY_DIR = "/var/lib/jenkins/.ssh"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/ShradhaKulkarni2003/terraform-demo.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                sh '''
                cd terraform
                terraform init
                terraform apply -auto-approve
                '''
            }
        }

        stage('Extract EC2 IP') {
            steps {
                script {
                    EC2_IP = sh(script: "cd terraform && terraform output -raw public_ip", returnStdout: true).trim()
                    sh "echo ${EC2_IP} > ec2_ip.txt"
                }
            }
        }

        stage('Update Ansible Inventory') {
            steps {
                sh '''
                sed -i "s/EC2_IP/$(cat ec2_ip.txt)/" ansible/inventory
                '''
            }
        }

        stage('Run Ansible') {
            steps {
                sh '''
                ansible-playbook -i ansible/inventory ansible/playbook.yml
                '''
            }
        }
    }
}
