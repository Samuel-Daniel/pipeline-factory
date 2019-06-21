#!/bin/bash

mvn sonar:sonar -Dsonar.login=$SONAR_LOGIN -Dsonar.host.url=$SONAR_HOST
