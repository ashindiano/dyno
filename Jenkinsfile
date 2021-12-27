pipeline {
  agent any
  environment {
    AWS_DEFAULT_REGION = 'ap-southeast-2'
    SLACK_NOTIFY_CHANNEL = 'C020ES5TMNY'
    // NONPROD_SLACK_NOTIFY_CHANNEL = 'C020ES5TMNY'
    // SLACK_NOTIFY_CHANNEL = "C021SU679T4"
    PROJECT_ID = 'vendorportal'
    RETAIN_BRANCH_DEPLOY = 'no' // retain branch deployment for dependent stacks
  }

  options {
    disableConcurrentBuilds() // Prevent name collisions
  }

  stages {
    stage ('Parallel Linting') {
      when {
        expression {
          return BRANCH_NAME =~ 'develop'
        }
      }
      environment {
        ENVIRONMENT = 'dev'
      }
      steps {
        script {
          node {
            deleteDir()
            checkout scm
            
          }
        }
      }
    }
    stage('Dev') {
      when {
        expression {
          return BRANCH_NAME == 'develop'
        }
      }
      environment {
        CFN_ENVIRONMENT = 'dev'
        CFN_AWS_ACC='187628286232'
      }
      steps {
        script {
          node {
            checkout scm
            sh 'echo "HI I am in Development"'
          }
        }
      }
    }
    stage('Nonprod') {
      when {
        expression {
          return BRANCH_NAME =~ 'hotfix.*|release.*'
        }
      }
      environment {
        CFN_ENVIRONMENT = 'nonprod'
        CFN_AWS_ACC='318263296841'
      }
      steps {
        script {
          node {
            checkout scm
            sh 'echo "HI I am in Non Prod"'
          }
        }
      }
    }
    stage('Production') {
      when {
        expression {
          return BRANCH_NAME == 'main'
        }
      }
      environment {
        CFN_ENVIRONMENT = 'prod'
        CFN_AWS_ACC='563000599290'
      }
      steps {
        script {
          node {
            checkout scm
            sh 'echo "HI I am in Production"'
          }
        }
      }
    }
  }
}
