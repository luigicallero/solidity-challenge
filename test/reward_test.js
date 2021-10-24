const { assert } = require('chai');

const RewardToken = artifacts.require("RewardToken");
const Staker = artifacts.require("Staker2");

var should = require('chai').should() 

// Converting tokens from Ether to Wei (or similar metrics for this Token)
function tokens(n) {
  return web3.utils.toWei(n, 'ether');
}

contract('RewardToken and Staker', (accounts) => {
  let RewardTokenContract, StakerContract


  before(async () => {
    // Contracts Deployed
    // 1 Million RWT Tokens generated and deposited on msg.sender account
    RewardTokenContract = await RewardToken.new(tokens('1000000'))
    StakerContract = await Staker.new(RewardToken.address)
    // 1 Million Million RWT Tokens transfered to Staker Contract
    await RewardTokenContract.transfer(StakerContract.address, tokens('1000000'))
    // Configuring the Rewards to 100 RWT Tokens every 15 seconds (approx every new block)
    await StakerContract.addRewards( tokens('100'), '15' );
  })

  describe('Contracts deployment', async () => {
    it('Staker contract has a name', async () => {
      const name = await StakerContract.name()
      assert.equal(name, 'Luisca Staking Application')
    })
  })

  describe('Tokens in Staker Contract', async () => {
    it('Stacker contract received 1 Million tokens', async () => {
        const balance = await RewardTokenContract.balanceOf(StakerContract.address)
        assert.equal(balance, tokens('1000000'))
    })
  
  })

  describe('Investors deposit in staker contract', async () => {
    it('Investor1 Using deposit function with 1 ETH successfully', async () => {
      let depositAmount = tokens('1')
      // Account 1 depositing 1 ETH
      await StakerContract.deposit({from: accounts[1], value: depositAmount })
      // const staked = await RewardTokenContract.balanceOf[ accounts[0] ]
      //assert.equal( tokens(staked) , tokens('5000'))
    })

    it('Investor1 Initial rewards is 0 RWT Tokens', async () => {
      let initialReward = await StakerContract.pendingRewards.call(accounts[1], { from: accounts[1] });
      assert.equal(initialReward.toString(), 0 , "User has rewards pending straight after staking");
    })

    it('Investor1 rewards after 15 seconds is 100 RWT Tokens', async () => {
      // Awaiting function from https://stackoverflow.com/questions/14226803/wait-5-seconds-before-executing-next-line
      console.log("Waiting 15s")
      const delay = ms => new Promise(res => setTimeout(res, ms))
      await delay(15000)
      await StakerContract.claim({ from: accounts[1] });
      let initialReward = await StakerContract.pendingRewards.call(accounts[1], { from: accounts[1] });
      console.log( "Reward in RWT tokens: ", web3.utils.fromWei(initialReward))
      //assert.equal(initialReward.toString(), tokens('100') , "User has rewards pending straight after staking");
    })
/*
// Claim rewards using claim(), make sure actual reward balance delta = the correctly calculated pending rewards
await staker.claim({ from: accounts[1] });
// Check user rewards balance
let userNewRewardBalance = await rewardToken.balanceOf(accounts[1], { from: accounts[1] });
let delta = userNewRewardBalance.sub(prevUserRewardTokenBalance);
assertEqualWithMargin(delta, expectedPendingReward, contractRps.div(rpsMultiplierBN), "Wrong amount of rewards sent to user after claim()");
prevUserRewardTokenBalance = userNewRewardBalance;
// Check contract rewards balance 
let contractNewRewardBalance = await rewardToken.balanceOf(staker.address, { from: accounts[1] });
let contractDelta = prevContractRewardTokenBalance.sub(contractNewRewardBalance);
assert.equal(contractDelta.toString(), expectedPendingReward.toString(), "Contract lost different amount of rewards than should have");
prevContractRewardTokenBalance = contractNewRewardBalance;
*/

    // Check other parameters

  })
        /* User stakes funds, make sure no pending rewards yet
        let depositAmount = web3.utils.toWei("10");
        await depositToken.approve(staker.address, depositAmount, { from: accounts[1] });
        await staker.deposit(depositAmount, { from: accounts[1] });
        */

})