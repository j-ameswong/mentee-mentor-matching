Setup Instructions

Enter a terminal and run cd ~/workspace

Clone the project via:
    https git clone https://git.shefcompsci.org.uk/com1001-2024-25/team17/project
ssh git clone git@git.shefcompsci.org.uk:com1001-2024-25/team17/project.git

cd project

To first test the website, we will run sh setup_test.sh (On the very small chance of failure, just run the command again)

Run the sinatra app with sinatra

Follow the link and you will be greeted with a login screen. Login with the user “admin” with the password being the same name. For a mentee, login with “user”, and for mentor, “user1”.

If the testing of features is satisfactory, stop the server and run sh setup.sh

The website will now be ready for use, the only user in the database will be admin 

Run Acceptance Tests

In order to run acceptance tests, simply enter the command: 
rspec 
into the terminal. You can then run the command: 

pushd spec/_coverage/;  python3 -m http.server 9999; popd;


 on the terminal, and then visit the page at http://[::]:9999/#_AllFiles while the command is running to view the coverage statistics for the acceptance tests.
