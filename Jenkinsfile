pipeline {
    agent {
      label 'mac'
    }

    stages {
        stage('Build') {
            steps {
                sh 'carthage update ScopeAgent --platform iOS'
                sh './bootstrap.sh'
                sh 'xcrun xcodebuild -scheme Fennec -sdk iphonesimulator -destination \'platform=iOS Simulator,name=iPhone X\' SYMROOT=$(PWD)/build test'
            }
        }
    }
}
