# Burst on macOS
---
1. [Purpose](#purpose)
2. [Dependencies](#dep)
3. [Wallet](#wallet)
    1. [Restarting the Wallet](#swallet)
    2. [Stopping the Wallet](#twallet)
    3. [Uninstall Wallet](#rwallet) 
    4. [Upgrade Wallet](#uwallet) 

## Purpose <a name="purpose"> </a>
The purpose of this set of scripts is to macOS users in getting the Burst Wallet, Plotter, and Mining software running as quickly and easily as possible.

Please don't hesitate to open an issue if you have any difficulty getting things running.

### ✅  Now supporting BRS wallet 2.0.1!

## Dependencies <a name="dep"> </a>
These scripts assume the following:
- You're running OSX 10.10 or greater
- You have sufficient disk space for the blockchain (and plot files if you choose to do so)
- You are not currently running an existing MariaDB Database
## Setting up your Wallet <a name="wallet"></a>
1. Download the .zip file for this repo.
2. Extract the contents.
3. Open up a terminal window in the `macos_burst-master` directory.
4. Run the following command with a password of your choice.
    ```$ sh macos_burst_install.sh <YOUR_PASSWORD>```
5. Follow the green prompts as the script runs.
6. Once the wallet starts, go to https://localhost:8125/index.html to access your wallet.

![Alt Text](https://media.giphy.com/media/3oFzmkv6II17QkwRSo/giphy.gif)

### Restart your Wallet <a name="swallet"></a>
If your wallet has stopped or you need to restart, rather than running the full script again you can do the following.
1. Open up a terminal window in the `macos_burst` directory.
2. Run the following command.
    ```$ ./macos_burst_install.sh --restart```

### Stop your Wallet <a name="twallet"></a>
If you'd like to stop your wallet you can do the following.
1. Open up a terminal window in the `macos_burst` directory.
2. Run the following command.
    ```$ ./macos_burst_install.sh --stop```

### Removing your Wallet <a name="rwallet"></a>
If you've installed your wallet on macOS using this script and decide you no longer wish to run the wallet and would like to uninstall everything. You can do the following.
1. Open up a terminal window in the `macos_burst-master` directory.
2. Run the following command.
    ```$ ./macos_burst_install.sh --uninstall```

### Migrate from an old install of macos_burst <a name="uwallet"></a>
If you installed a previous version of the Burst wallet using this software, you can use this software to update to the latest version. To do so, follow these steps.
1. Download the .zip file for this repo.
2. Extract the contents.
3. Open up a terminal window in the `macos_burst-master` directory.
4. Find the path of your previous install. You can try running this command to find it 
    ```mdfind burstcoin-1.3.6cg | head -n 1 | cd ../../ | pwd```
5. Run the following command to upgrade to the new wallet version
    ```$ ./macos_burst_install.sh --upgrade {path from step 4}```

#### 🙌 Thanks 
I'd like to thank the folks who wrote the underlying software used here.
- Wallet - PoC Consortium - https://github.com/PoC-Consortium/burstcoin

#### 🎉 Burst XBundle for macOS is coming soon!
I haven't had time to update this project with simple scripts for plotting/mining because I've been spending all my time working on a new bundled application which will allow you to install and run the Burst wallet along with plotting and mining all through a simple, clean user interface. Follow me on twitter [@drownedcoast](https://twitter.com/@drownedcoast) for more news. 

#### 💸 Donations 
If this was helpful to you please consider a small donation. _BURST-Q944-2MY3-97ZZ-FBWGB_
