#!/bin/bash
#version 1.0

function shaw(){
 case $1 in
        "apis")
            echo "Opening POSTMAN link for GoApi documents" 
            open ""
        ;;
         "deployment")
            cd /
            echo "Opening Jenkins"
            open ""
        ;;
        "repo")
            cd /
            echo "Opening PipIndex in Github"
            open ""
        ;;
        "tickets")
            echo "Opening JIRA"        
            open ""
        ;;
        "logs")  
            echo "Opening Loggly"        
            open https://logshawacademy.loggly.com
        ;;
        "script")
            cd /
            echo "Opening $BASH_SOURCE"
            open "$BASH_SOURCE"
        ;;
        "source")
            cd /
            echo "Sourcing $BASH_SOURCE"
            source "$BASH_SOURCE"
        ;;
        "hr")
            echo "Opening GreyHR"        
            open ""
        ;;
        "help"|"h"|"--help"|"-h")
            echo "Commands available"
            echo "apis"
            echo "logs"
            echo "jenkins"
            echo "repo"
            echo "script"
            echo "source"
            echo "tickets"
        ;;
        
  esac
}
