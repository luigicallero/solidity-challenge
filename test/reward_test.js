const { assert } = require('chai');

const RewardToken = artifacts.require("RewardToken");
const Staker = artifacts.require("Staker");

var should = require('chai').should() 

// Converting tokens from Ether to Wei (or similar metrics for this Token)
function tokens(n) {
  return web3.utils.toWei(n, 'ether');
}

contract('RewardToken and Staker', (accounts) => {
  let RewardTokenContract, StakerContract


  before(async () => {
    // Contracts Deployed
    // 1 Billion RWT Tokens generated and deposited on msg.sender account
    RewardTokenContract = await RewardToken.new(tokens('1000000000'))
    StakerContract = await Staker.new(RewardToken.address)
    // 997 Million RWT Tokens transfered to Staker Contract
    await RewardTokenContract.transfer(StakerContract.address, tokens('997000000'))
    // Transfer rest of tokens to different investors
    await RewardTokenContract.transfer(accounts[1], tokens('1000000'))
    await RewardTokenContract.transfer(accounts[2], tokens('1000000'))
  })

  describe('Contracts deployment', async () => {
    it('Staker contract has a name', async () => {
      const name = await StakerContract.name()
      assert.equal(name, 'Luisca Staking Application')
    })
  })

  describe('Tokens in Staker Contract', async () => {
    it('Stacker contract received 997 Million tokens', async () => {
        const balance = await RewardTokenContract.balanceOf(StakerContract.address)
        assert.equal(balance, tokens('997000000'))
    })
    it('Investors received 1Million tokens each', async () => {
        const balance = await RewardTokenContract.balanceOf(accounts[0])
        assert.equal(balance, tokens('1000000'))
        const balance1 = await RewardTokenContract.balanceOf(accounts[1])
        assert.equal(balance1, tokens('1000000'))
        const balance2 = await RewardTokenContract.balanceOf(accounts[2])
        assert.equal(balance2, tokens('1000000'))
    })
  })

/*  describe('Staking', async () => {
    it('Using stake function to deposit 5000 tokens', async () => {
        // need to make sure this is transfering RWT tokens instead of Ether
        await StakerContract.stake( { from: accounts[0] , value: tokens('5000') })
       // const staked = await RewardTokenContract.balanceOf[ accounts[0] ]
       // assert.equal( tokens(staked) , tokens('5000'))
    })
  })
*/

})