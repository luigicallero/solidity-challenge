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
    await StakerContract.setRewards( tokens('100'), '5' );
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

  describe('*** Only one Investor depositing in staker contract', async () => {
    it('Investor1 deposits 1 ETH successfully', async () => {
      let depositAmount = tokens('1')
      await StakerContract.deposit({from: accounts[1], value: depositAmount })
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
      // only using claim function to update the rewards info
      await StakerContract.claim({ from: accounts[1] });
      const initialReward = await StakerContract.pendingRewards.call(accounts[1], { from: accounts[1] });
      console.log( "Rewards for Inv1 in RWT tokens: ", web3.utils.fromWei(initialReward))
      const totalStaked = await StakerContract.totalStaked.call();
      console.log( "Total Staked in ETH: ", web3.utils.fromWei(totalStaked))
    })
  })

describe('*** Two Other Investors deposit in staker contract', async () => {
// There is something after accounts[1] was used in above describe that is not allowing it to stake more ETH  
  it('Investor2 deposits 1 ETH successfully', async () => {
    const depositAmount = tokens('1')
    await StakerContract.deposit({from: accounts[2], value: depositAmount })
  })
  
  it('Investor3 deposits 1 ETH successfully', async () => {
    let depositAmount = tokens('1')
    await StakerContract.deposit({from: accounts[3], value: depositAmount })
  })

  it('Investor2 Initial rewards is 0 RWT Tokens', async () => {
    let initialReward = await StakerContract.pendingRewards.call(accounts[2], { from: accounts[2] });
    console.log( "Initial Rewards for Inv2 in RWT tokens: ", web3.utils.fromWei(initialReward))
    //assert.equal(initialReward.toString(), tokens('100') , "User has rewards pending straight after staking");
  })

  it('Investor3 Initial rewards is 0 RWT Tokens', async () => {
    let initialReward = await StakerContract.pendingRewards.call(accounts[3], { from: accounts[3] });
    assert.equal(initialReward.toString(), 0 , "User has rewards pending straight after staking");
  })

  it('Investor2 rewards after 15 seconds is now MORE than 100 RWT Tokens', async () => {
    console.log("Waiting 15s")
    const delay = ms => new Promise(res => setTimeout(res, ms))
    await delay(15000)
    // only using claim function to update the rewards info
    await StakerContract.claim({ from: accounts[1] });
    let initialReward = await StakerContract.pendingRewards.call(accounts[2], { from: accounts[2] });
    console.log( "Rewards for Inv2 in RWT tokens: ", web3.utils.fromWei(initialReward))
  })

  it('Investor3 rewards after 15 seconds is approx 100 RWT Tokens', async () => {
    let initialReward2 = await StakerContract.pendingRewards.call(accounts[3], { from: accounts[3] });
    console.log( "Rewards for Inv3 in RWT tokens: ", web3.utils.fromWei(initialReward2))
    const totalStaked = await StakerContract.totalStaked.call();
    console.log( "Total Staked in ETH: ", web3.utils.fromWei(totalStaked))
  })
  })

})