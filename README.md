# Burst on macOS
---
1. [Purpose](#purpose)
2. [Dependencies](#dep)
3. [Wallet](#wallet)
    1. [Uninstall Wallet](#rwallet)
4. [Plotting](#plot)
5. [Mining](#mine)

## Purpose <a name="purpose"> </a>
The purpose of this set of scripts is to macOS users in getting the Burst Wallet, Plotter, and Mining software running as quickly and easily as possible.

Please don't hesitate to open an issue if you have any difficulty getting things running.

## Dependencies <a name="dep"> </a>
These scripts assume the following:
- You're running OSX 10.10 or greater
- You have sufficient disk space for the blockchain (and plot files if you choose to do so)
- You are not currently running an existing MariaDB Database
## Setting up your Wallet <a name="wallet"></a>
1. Download the .zip file for this repo.
2. Extract the contents.
3. Open up a terminal window in the `macos_burst` directory.
4. Run the following command with a password of your choice.
    ```$ ./macos_burst_install.sh <YOUR_PASSWORD>```
5. Follow the green prompts as the script runs.
6. Once the wallet starts, go to https://localhost:8125/index.html to access your wallet.

![Alt Text](https://media.giphy.com/media/3oFzmkv6II17QkwRSo/giphy.gif)

### Removing your Wallet <a name="rwallet></a>
If you've installed your wallet on macOS using this script and decide you no longer wish to run the wallet and would like to uninstall everything. You can do the following.
1. Open up a terminal window in the `macos_burst` directory.
2. Run the following command.
    ```$ ./macos_burst_install.sh --uninstall```
## Creating Plots <a name="plot"></a>
Coming Soon!
## Start Mining <a name="mine"></a>
Coming Soon!

#### 🙌 Thanks 
I'd like to thank the folks who wrote the underlying software used here.
- Wallet - PoC Consortium - https://github.com/PoC-Consortium/burstcoin

#### 💸 Donations 
If this was helpful to you please consider a small donation. _BURST-Q944-2MY3-97ZZ-FBWGB_
