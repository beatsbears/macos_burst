#!/bin/bash
# Andrew Scott 1/2018

cat << `END`

                      _____ _____  ______                _   _    _       _ _      _   
                     |  _  /  ___| | ___ \              | | | |  | |     | | |    | |  
 _ __ ___   __ _  ___| | | \ `--.  | |_/ /_   _ _ __ ___| |_| |  | | __ _| | | ___| |_ 
| '_ ` _ \ / _` |/ __| | | |`--. \ | ___ \ | | | '__/ __| __| |/\| |/ _` | | |/ _ \ __|
| | | | | | (_| | (__\ \_/ /\__/ / | |_/ / |_| | |  \__ \ |_\  /\  / (_| | | |  __/ |_ 
|_| |_| |_|\__,_|\___|\___/\____/  \____/ \__,_|_|  |___/\__|\/  \/ \__,_|_|_|\___|\__|
                                                                                          
More Info: 
        - https://github.com/PoC-Consortium/burstcoin
        - https://www.burst-coin.org
`END`

if [ "$1" == "-h" -o "$1" == "--help" ]; then
    echo "\n[+] Provide a default password for the Database. This will be used by the Burstcoin process to access your MariaDB instance"
    echo "    Usage: ./macos_burst_install.sh MySecretPassword"
    echo "    To uninstall: ./macos_burst_install.sh --uninstall"
    echo "    To restart: ./macos_burst_install.sh --restart"
    echo "    To stop: ./macos_burst_install.sh --stop"
    echo "    To upgrade: ./macos_burst_install.sh --upgrade 'path of old install macos_burst'"
    echo "        ex.  ./macos_burst_install.sh --upgrade ~/Downloads/macos_burst-master"
    exit 0
fi

if [ "$1" == "--uninstall" ]; then
    echo "\033[92m\n[+] Uninstalling Burst Wallet and MariaDB...\033[0m"
    echo "\033[92m\n[+] Attempting to stop any running processes...\033[0m"
    kill $(ps aux | grep '/usr/bin/java -cp burst.jar:conf brs.Burst' | awk '{print $2}')
    kill $(ps aux | grep '/bin/bash ./burst.sh' | awk '{print $2}')
    brew services stop mariadb
    rm -rf /usr/local/var/mysql
    brew uninstall mariadb
    brew cleanup
    rm -rf burstcoin/
    echo "\033[92m\n[+] Uninstall complete\033[0m"
    exit 0
fi

if [ "$1" == "--restart" ]; then
    echo "\033[92m\n[+] Restarting Burst Wallet...\033[0m"
    # attempt to stop wallet processes
    echo "\033[92m\n[+] Attempting to stop any running processes...\033[0m"
    kill $(ps aux | grep '/usr/bin/java -cp burst.jar:conf brs.Burst' | awk '{print $2}')
    kill $(ps aux | grep '/bin/bash ./burst.sh' | awk '{print $2}')
    sleep 10
    # restart
    echo "\033[92m\n[+] Attempting to to start Wallet.\033[0m"
    if [ ! -d "./burstcoin" ]; then
        echo "\033[0;31m\n[!] Wallet does not appear to be installed. Retry command with -h for help.\033[0m"
        exit 1
    else
        echo "\033[92m\n[+] Starting Wallet, Initialization may take a long time...\033[0m"
        cd ./burstcoin/
        ./burst.sh  >/dev/null 2>&1 &
        sleep 10
        echo "\033[92m[+] Please open a browser and go to http://localhost:8125/index.html\033[0m"
        echo "\033[92m[+] Transactions and current balances will be unavailable until the db is synchronized, but you can set up your wallet in the meantime.\033[0m"
    fi
    exit 0
fi

if [ "$1" == "--stop" ]; then
    echo "\033[92m\n[+] Attempting to stop any running processes...\033[0m"
    kill $(ps aux | grep '/usr/bin/java -cp burst.jar:conf brs.Burst' | awk '{print $2}')
    kill $(ps aux | grep '/bin/bash ./burst.sh' | awk '{print $2}')
    sleep 10
    exit 0
fi 

if [ "$1" == "--upgrade" ]; then
    if [ $# == 1 ]; then
        echo "\033[0;31m\n[!] No Path provided, Exiting...\033[0m"
        echo "\033[0;31m  Use the -h option for help\033[0m"
        exit 1
    fi
    echo "\033[92m\n[+] Attempting upgrade from a previous version of the Burst Wallet to the latest version...\033[0m"
    echo "\033[92m\n[+] Attempting to stop any running processes...\033[0m"
    kill $(ps aux | grep '/usr/bin/java -cp burst.jar:conf brs.Burst' | awk '{print $2}')
    kill $(ps aux | grep '/usr/bin/java -cp burst.jar:conf nxt.Nxt' | awk '{print $2}')
    kill $(ps aux | grep '/bin/bash ./burst.sh' | awk '{print $2}')
    sleep 10
    echo "\033[92m\n[+] checking in old install: $2"
    if [ ! -d "$2/burstcoin" ]; then
        echo "\033[0;31m\n[!] Could not find existing wallet in provided path, Exiting...\033[0m"
        ls -la $2
        exit 1
    else
        if [ -d "$2/burstcoin/burstcoin-1.3.6cg" ]; then
            # get old install details from 1.3.6
            echo "\033[92m\n[+] Old install found (1.3.6cg)!\033[0m"
            PASSWORD=$(cat "$2/burstcoin/burstcoin-1.3.6cg/conf/nxt.properties" | grep nxt.dbPassword | cut -d "=" -f2)
            USERNAME=$(cat "$2/burstcoin/burstcoin-1.3.6cg/conf/nxt.properties" | grep nxt.dbUsername | cut -d "=" -f2)
            CONNECTION=$(cat "$2/burstcoin/burstcoin-1.3.6cg/conf/nxt.properties" | grep nxt.dbUrl | cut -d "=" -f2)
        else
            # get old install details from 2.*
            echo "\033[92m\n[+] Old install found (2.0.0+)!\033[0m"
            PASSWORD=$(cat "$2/burstcoin/conf/brs.properties" | grep DB.Password | cut -d "=" -f2)
            USERNAME=$(cat "$2/burstcoin/conf/brs.properties" | grep DB.Username | cut -d "=" -f2)
            CONNECTION=$(cat "$2/burstcoin/conf/brs.properties" | grep DB.Url | cut -d "=" -f2)
        fi
        # Install Wallet
        echo "\033[92m\n[+] Installing PoC-Consortium Burst Wallet 2.0.2...\033[0m"
        #TODO only get most recent release
        curl -o ./burstcoin.zip -k -L https://github.com/PoC-Consortium/burstcoin/releases/download/2.0.2/burstcoin-2.0.2.zip
        mkdir burstcoin
        unzip burstcoin.zip -d burstcoin
        rm burstcoin.zip
        echo "" > ./burstcoin/conf/brs.properties
        echo "DB.Url=$CONNECTION" >> ./burstcoin/conf/brs.properties
        echo "DB.Username=$USERNAME" >> ./burstcoin/conf/brs.properties
        echo "DB.Password=$PASSWORD" >> ./burstcoin/conf/brs.properties
        cd ./burstcoin/
        chmod +x burst.sh
        echo "\033[92m\n[+] Starting Wallet, Initialization may take a long time...\033[0m"
        echo "\033[92m[+] Please open a browser and go to http://localhost:8125/index.html\033[0m"
        echo "\033[92m[+] Transactions and current balances will be unavailable until the db is synchronized, but you can set up your wallet in the meantime.\033[0m"
        sleep 10
        ./burst.sh  >/dev/null 2>&1 &
        exit 0
    fi
fi 

# Check if password is provided
if [ $# -eq 0 ]; then
    echo "\033[0;31m\n[!] No Database Password Provided, Exiting...\033[0m"
    echo "\033[0;31m  Use the -h option for help\033[0m"
    exit 1
fi

# Check eligable OSX versions
VERSION_MINOR=$(sw_vers -productVersion | grep -E -o '1[0-9]' | tail -n1)
if [ "$VERSION_MINOR" -lt "10" ]; then
    echo "\033[0;31m\n[!] Unsupported version of OSX, Exiting...\033[0m"
    echo "\033[0;31m[!] Homebrew requires 10.10^ \033[0m"
    exit 1
fi

# Install/Update brew
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    echo "\033[92m\n[+] Installing Homebrew...\033[0m"
    echo "\033[92m    Press ENTER when prompted then enter sudo password if asked.\033[0m"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "\033[92m\n[+] Updating Homebrew...\033[0m"
    brew update
fi

# Install MariaDB
echo "\033[92m\n[+] Installing MariaDB...\033[0m"
if brew ls --versions mariadb > /dev/null; then
    MARIA_STATE=$(brew services list | grep mariadb | awk '{ print $2 }')
    if [[ $MARIA_STATE == "started" ]]; then
        echo "\033[0;31m[!] MariaDB is already installed and running\033[0m"
        echo "\033[0;31m  This script will fail if the MariaDB root password has been changed. \033[0m"
        echo "\033[0;31m  This will be fixed in a future update. Exiting...\033[0m"
        exit 1
    fi
    brew upgrade mariadb
else
    brew install mariadb
fi

# Start the DB
echo "\033[92m\n[+] Starting MariaDB...\033[0m"
brew services start mariadb
sleep 5 

# Create Database and reset password
echo "\033[92m\n[+] Resetting Root password for MariaDB...\033[0m"
echo "\033[92m    Press ENTER when prompted.\033[0m"
mysql -u root -p -h localhost << END

USE mysql;
UPDATE user SET password=PASSWORD('$1') WHERE User='root' AND Host = 'localhost';
FLUSH PRIVILEGES;

END
echo "\033[92m\n[+] Creating burstwallet db...\033[0m"
mysql -u root -p$1 -h localhost << END

CREATE DATABASE burstwallet
    CHARACTER SET = 'utf8mb4'
    COLLATE = 'utf8mb4_unicode_ci';
CREATE USER 'burstwallet'@'localhost' IDENTIFIED BY '$1'; 
GRANT ALL PRIVILEGES ON burstwallet.* TO 'burstwallet'@'localhost';

END
echo "\033[92m[+] Database created successfully...\033[0m"

# Install Java 8
echo "\033[92m\n[+] Installing Java 8 JDK...\033[0m"
brew tap caskroom/versions
brew cask search java
brew cask install java8

# Install Wallet
echo "\033[92m\n[+] Installing PoC-Consortium Burst Wallet 2.0.2...\033[0m"
#TODO only get most recent release
curl -o ./burstcoin.zip -k -L https://github.com/PoC-Consortium/burstcoin/releases/download/2.0.2/burstcoin-2.0.2.zip
mkdir burstcoin
unzip burstcoin.zip -d burstcoin
rm burstcoin.zip
echo "DB.Url=jdbc:mariadb://localhost:3306/burstwallet" >> ./burstcoin/conf/brs.properties
echo "DB.Username=burstwallet" >> ./burstcoin/conf/brs.properties
echo "DB.Password=$1" >> ./burstcoin/conf/brs.properties
cd ./burstcoin/
chmod +x burst.sh
echo "\033[92m\n[+] Starting Wallet, Initialization may take a long time...\033[0m"
echo "\033[92m[+] Please open a browser and go to http://localhost:8125/index.html\033[0m"
echo "\033[92m[+] Transactions and current balances will be unavailable until the db is synchronized, but you can set up your wallet in the meantime.\033[0m"
sleep 10
./burst.sh >/dev/null 2>&1 &
exit 0
