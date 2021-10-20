const RewardToken = artifacts.require("RewardToken");
const Staker = artifacts.require("Staker");

module.exports = async function (deployer) {
    await deployer.deploy(RewardToken, '1000000000000000000000000');
    const rwt = await RewardToken.deployed();

    await deployer.deploy(Staker);
    const staker = await Staker.deployed();

    // Transfer all tokens to staking account
    await rwt.transfer( staker.address , '1000000000000000000000000')
};
