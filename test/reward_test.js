const { assert } = require('chai');

const RewardToken = artifacts.require("RewardToken");
const Staker = artifacts.require("Staker");

var should = require('chai').should() 

function tokens(n) {
  return web3.utils.toWei(n, 'ether');
}

contract('Staker', (accounts) => {
  let RewardTokenContract, StakerContract

  before(async () => {
    RewardTokenContract = await RewardToken.new(tokens('1000000'))
    StakerContract = await Staker.new(RewardToken.address)
    // Transfer all tokens to Staker (1 million)
    await RewardTokenContract.transfer(StakerContract.address, tokens('1000000'))
  })

  describe('Contracts deployment', async () => {
    it('Staker contract has a name', async () => {
      const name = await StakerContract.name()
      assert.equal(name, 'Luisca Staking Application')
    })
  })

  describe('Tokens in Staker Contract', async () => {
    it('Stacker contract received 1Million tokens', async () => {
        const balance = await RewardTokenContract.balanceOf(StakerContract.address)
        assert.equal(balance, tokens('1000000'))
    })

  })


})