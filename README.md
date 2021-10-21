#
# 🤩 LUISCA STAKING REWARDS 🤩
-----------------------------------------
> This staking DApp will provide the environment for a new Token and rewarding mechanism for all stakers


#
## RewardToken.sol
This contract defines an ERC20 token used for staking/rewards. 

Contract owner is able to mint the token, change reward rates and enable/disable withdraw fees (also modifiable)
#
## Requirements:

  **GIT** to be able to download (clone) our repossitory from Github (GitHub is a code hosting platform for version control and collaboration. It lets you and others work together on projects from anywhere)
  
  **NodeJS** to install and manage all required modules and dependencies in your machine (specifically on the repossitory that will be created when you clone our repo).
#
## Clone this Repo:
On a terminal execute:
```
git clone https://github.com/luigicallero/SOLIDITY-CHALLENGE
cd SOLIDITY-CHALLENGE
npm install
```
## Create Truffle local Blockchain instance
On a different terminal execute the following:
```
truffle develop
```

## Deploying the Contract for TOKEN (ERC20) based on OpenZeppelin standards
Back to original terminal:
```
truffle migrate -f 2
```
#
## Tools used
- Truffle
- Remix
- web3.js/ethers.js
- Visual Studio Code
- Git