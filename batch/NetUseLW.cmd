REM Windows (auch PE) gestattet keine net use Verbindung mehr ohne Account
REM ist das Share auf demm Server anonmyn kann man irgendeinen Account eintragen
net use * \\Server\Share1 /user:user password 
net use * \\Server\Share2  
