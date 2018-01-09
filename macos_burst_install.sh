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
    exit 0
fi

if [ "$1" == "--uninstall" ]; then
    brew services stop mariadb
    rm -rf /usr/local/var/mysql
    brew uninstall mariadb
    brew cleanup
    rm -rf burstcoin/
    exit 0
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

CREATE DATABASE burstwallet; 
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
echo "\033[92m\n[+] Installing PoC-Consortium Burst Wallet...\033[0m"
#TODO only get most recent release
curl -o ./burstcoin.zip -k -L https://github.com/PoC-Consortium/burstcoin/releases/download/1.3.6cg/burstcoin-1.3.6cg.zip
mkdir burstcoin
unzip burstcoin.zip -d burstcoin
rm burstcoin.zip
echo "nxt.dbUrl=jdbc:mariadb://localhost:3306/burstwallet" >> ./burstcoin/burstcoin-1.3.6cg/conf/nxt.properties
echo "nxt.dbUsername=burstwallet" >> ./burstcoin/burstcoin-1.3.6cg/conf/nxt.properties
echo "nxt.dbPassword=$1" >> ./burstcoin/burstcoin-1.3.6cg/conf/nxt.properties
cd ./burstcoin/burstcoin-1.3.6cg/
chmod +x burst.sh
echo "\033[92m\n[+] Starting Wallet, Initialization may take a long time...\033[0m"
echo "\033[92m[+] Please open a browser and go to http://localhost:8125/index.html\033[0m"
echo "\033[92m[+] Transactions and current balances will be unavailable until the db is synchronized, but you can set up your wallet in the meantime.\033[0m"
sleep 10
#TODO download blockchain zip and pre-populate wallet
./burst.sh
