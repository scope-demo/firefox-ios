pipeline {
    agent {
      label 'mac'
    }

    stages {
        stage('Build') {
            steps {
                sh 'xcrun xcodebuild -scheme Fennec -sdk iphonesimulator -destination \'platform=iOS Simulator,name=iPhone X,OS=12.2\' SYMROOT=$(PWD)/build test'
            }
        }
    }
}
