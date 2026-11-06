pipeline{
    agent any
    stages{
        stage("A"){
            steps{
                echo "========executing A========"
            }}
        stage("B"){
            steps{
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_cred']]){
                bat "terraform init -reconfigure"
                bat "terraform fmt"
                
            }
        }
        }
        stage("c"){
            steps{
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_cred']]){
                bat "terraform validate"
            }
        }
        }
        stage("d"){
            steps{
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_cred']]){
                bat "terraform plan"
            }
            }
        }
    }
        post{
            success{
                echo 'successfull'
            }
            failure{
                echo 'failure'
            }
        }
    }