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
        stage('Code Checkout')   {
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
        stage('Running maven cache cleaning') {
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            ./mvnw dependency:purge-local-repository
            popd
            """
          }
        }
        stage('Running maven test') {
          steps {
            sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            ./mvnw clean test -P artifactory
            popd
            """
          }
        }
        stage('Build Jar Package with skip test') {
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            ./mvnw deploy -DskipTests -P artifactory
            echo "--------- listing the artifacts in target folder --------------"
            ls -lrt target/*
            popd
            """
          }
        }
         stage('Docker Packaging') {
          steps {
      	    sh """#!/bin/bash -e
            pushd \${WORKSPACE}/spring-petclinic
            
            echo "Stopping and deleting any previous containers for clean deployment of the app in the pipeline"
            echo ""
            docker ps -a | grep "spring-petclinic" | awk '{print \$1}' | xargs -I {} sh -c 'docker stop {} && docker rm {}'
            echo ""
            docker ps -a | grep "spring-petclinic" || echo "Container not found with the matching name spring-petclinic"
            echo ""
            echo "Deleting images to save space and have clean image list"
            docker images | grep 'spring-petclinic' | awk '{print \$1":"\$2}' | xargs -I {} docker rmi {}
            echo ""
            echo "Building the docker image based on the default Dockerfile in the repo"
            docker build -t spring-petclinic-v\${BUILD_NUMBER}:v\${BUILD_NUMBER} .
            echo ""
            echo "Listing the docker image"
            docker images | grep spring-petclinic
            echo ""
            echo "Creating a tarball of the container image to be shared as artifacts to be used on different machine, will share the steps how to use in seperate document"
            docker save -o \${WORKSPACE}/spring-petclinic/target/spring-petclinic_v\${BUILD_NUMBER}.tar spring-petclinic-v\${BUILD_NUMBER}:v\${BUILD_NUMBER}
            echo ""
            echo ""
            echo "Listing the docker image artifact in the target folder, which can be shared"
            ls -lrt target/spring-petclinic_v\${BUILD_NUMBER}.tar
            popd
            """
          }
        }
        stage('Docker app launch') {
          steps {
      	    sh """#!/bin/bash -e
            echo "Launching the container with the build image on the jenkins worker node for validation, make sure to use the Worker node ip to rach the app"
            docker run -d -p 8080:8080/tcp --name spring-petclinic-v\${BUILD_NUMBER} -it spring-petclinic-v\${BUILD_NUMBER}:v\${BUILD_NUMBER}
            echo ""
            ip_address=`ipconfig getifaddr en0`
            echo "launch URL : http://<worker node ip>:8080"
            echo "Launch URL : http://\${ip_address}:8080"
            """
          }
        }
    }
}
