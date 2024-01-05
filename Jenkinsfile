pipeline {
	  agent {
        label 'Mac-slave'
    }
    stages {
        stage('WorkSpace Cleanup') {
          steps {
            // Clean before build
            cleanWs()
          }
        }
        stage('checkout')   {
          steps   {
              checkout([
                  $class: 'GitSCM',
                  branches: [[name: "*/main"]],
                  extensions: [
                      [
                          $class: 'CleanBeforeCheckout'
                      ],
                      [
                          $class: 'RelativeTargetDirectory',
                          relativeTargetDir: 'spring-petclinic'
                      ]
                  ],
                  userRemoteConfigs: [
                      [
                          url: 'https://github.com/ashishujjain/spring-petclinic.git'
                      ]
                  ]
              ])
          }
        }
        stage('test') {
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            ./mvnw test
            popd
            """
          }
        }
  	    stage('Build Jar Package') {
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            ./mvnw package -DskipTests
            ls -lrt target/*
            popd
            """
          }
        }
         stage('Docker Packaging') {
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            
            docker ps -a | grep "spring-petclinic" | awk '{print \$1}' | xargs -I {} docker stop {}
            docker ps -a | grep "spring-petclinic" | awk '{print \$1}' | xargs -I {} docker rm {}
            docker images | grep 'spring-petclinic' | awk '{print \$1":"\$2}' | xargs -I {} docker rmi {}

            docker build -t spring-petclinic-v\${BUILD_NUMBER}:v\${BUILD_NUMBER} .
            docker images | grep spring-petclinic
            docker save -o \${WORKSPACE}/spring-petclinic/target/spring-petclinic_v\${BUILD_NUMBER}.tar spring-petclinic-v\${BUILD_NUMBER}:v\${BUILD_NUMBER}
            ls -lrt target/spring-petclinic_v\${BUILD_NUMBER}.tar
            popd
            """
          }
        }
        stage('Docker app launch') {
          steps {
      	    sh """#!/bin/bash -e
            docker run -d -p 8080:8080/tcp --name spring-petclinic-v\${BUILD_NUMBER} -it spring-petclinic-v\${BUILD_NUMBER}:v\${BUILD_NUMBER}
            """
          }
        }
    }
}
