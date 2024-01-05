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
            ./mvnw package
            ls -lrt target/*
            popd
            """
          }
        }
         stage('Docker Packaging') {
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            docker build -t spring-petclinic-\${BUILD_NUMBER}:v\${BUILD_NUMBER} .
            docker images
            docker save -o \${WORKSPACE}/spring-petclinic/target/spring-petclinic_\${BUILD_NUMBER}.tar spring-petclinic-\${BUILD_NUMBER}:v\${BUILD_NUMBER}
            popd
            """
          }
        }
    }
}
