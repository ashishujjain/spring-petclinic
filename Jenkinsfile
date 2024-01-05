pipeline {
	  agent none
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
    	    agent {
      	    docker {
        	  image 'openjdk:21-jdk'
            }
          }
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            ./mvnw test
            popd
            """
          }
        }
  	    stage('Build Package') {
    	    agent {
      	    docker {
        	  image 'openjdk:21-jdk'
            }
          }
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            ./mvnw package
            ls -lrt target/*
            popd
            """
          }
        }
    }
}
