// contracts/RewardToken.sol
/* SPDX-License-Identifier: GPL-3.0
Authored by Luis Ignacio Callero
With great help from 
    Greg DappUniversity https://www.youtube.com/watch?v=sCE-fQJAVQ4
    Austin Griffith https://github.com/scaffold-eth/scaffold-eth/blob/staking-app/packages/hardhat/contracts/Staker.sol
    https://medium.com/@tnhollan/how-to-implement-staking-in-solidity-cdb1d0506ef6
*/
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol"; // Here I updated the contract location for solidity 0.8.4
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol"; // to be used with remix
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RewardToken.sol";

/*
    Staker contract for ETB Projects #2
    ===================================
    Based on Sushiswap MasterChef.
    The basic idea is to keep an accumulating pool "share balance" (accumulatedRewardPerShare):
    Every unit of this balance represents the proportionate reward of a single wei which is staked in the contract.
    This balance is updated in updateRewards() (which is called in each deposit/withdraw/claim)
        according to the time passed from the last update and in proportion to the total tokens staked in the pool.
        Basically: accumulatedRewardPerShare = accumulatedRewardPerShare + (seconds passed from last update) * (rewards per second) / (total tokens staked)
    We also save for each user an accumulation of how much he has already claimed so far.
    And so to calculate a user's rewards, we basically just need to calculate:
    userRewards = accumulatedRewardPerShare * (user's currently staked tokens) - (user's rewards already claimed) 
    And updated the user's rewards already claimed accordingly.
*/
contract Staker2 is Ownable {
    string public name = "Luisca Staking Application";
    using SafeMath for uint256;

    struct UserInfo {
        uint256 deposited;
        uint256 rewardsAlreadyConsidered;
    }

    mapping (address => UserInfo) users;
    
    IERC20 public rewardToken;
    // We are not using rewardToken.balanceOf in order to prevent DOS attacks (attacker can make the total tokens staked very large)
    // and to add a skim() functionality with which the owner can collect tokens which were transferred outside the stake mechanism.
    uint256 public totalStaked;

    uint256 public rewardPeriodEndTimestamp;
    uint256 public rewardPerSecond; // multiplied by 1e7, to make up for division by 24*60*60

    uint256 public lastRewardTimestamp;
    uint256 public accumulatedRewardPerShare; // multiplied by 1e12, same as MasterChef

    event SetRewards(uint256 amount, uint256 lengthInSeconds);
    event ClaimReward(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Skim(uint256 amount);
    

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    // Owner should have approved ERC20 before.

/*    function addRewards(uint256 _rewardsAmount, uint256 _lengthInSeconds)
    external onlyOwner {
        require(block.timestamp > rewardPeriodEndTimestamp, "Staker: can't add rewards before period finished");
        updateRewards();
        rewardPeriodEndTimestamp = block.timestamp.add(_lengthInSeconds);
        rewardPerSecond = _rewardsAmount.mul(1e7).div(_lengthInSeconds);
        
        //Here I have changed original require from eattheblocks since the RWT tokens are already all in the Staking Contract
        require(rewardToken.transferFrom(msg.sender, address(this), _rewardsAmount), "Staker: transfer failed");
        
        emit AddRewards(_rewardsAmount, _lengthInSeconds);
    }
*/
    /*
    Here I have updated original function addRewards from eattheblocks since all RWT tokens are already in the Staking Contract
    Function only used to update the reward period and amount
    Also _lengthInDays replaced with _lengthInSeconds
    */ 
    function setRewards(uint256 _rewardsAmount, uint256 _lengthInSeconds) external onlyOwner {
        //require(block.timestamp > rewardPeriodEndTimestamp, "Staker: can't add rewards before period finished");
        updateRewards();
        rewardPeriodEndTimestamp = block.timestamp.add(_lengthInSeconds);
        rewardPerSecond = _rewardsAmount.mul(1e7).div(_lengthInSeconds);
        emit SetRewards(_rewardsAmount, _lengthInSeconds);
    }

    // Main function to keep a balance of the rewards.
    // Is called before each user action (stake, unstake, claim).
    // See top of file for high level description.
    // Here I changed it from public to Internal (no sense if it is only called by other functions )
    function updateRewards() internal {
        // If no staking period active, or already updated rewards after staking ended, or nobody staked anything - nothing to do
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }
        if ((totalStaked == 0) || lastRewardTimestamp > rewardPeriodEndTimestamp) {
            lastRewardTimestamp = block.timestamp;
            return;
        }

        // If staking period ended, calculate time delta based on the time the staking ended (and not after)
        uint256 endingTime;
        if (block.timestamp > rewardPeriodEndTimestamp) {
            endingTime = rewardPeriodEndTimestamp;
        } else {
            endingTime = block.timestamp;
        }
        uint256 secondsSinceLastRewardUpdate = endingTime.sub(lastRewardTimestamp);
        uint256 totalNewReward = secondsSinceLastRewardUpdate.mul(rewardPerSecond); // For everybody in the pool
        // The next line will calculate the reward for each staked token in the pool.
        //  So when a specific user will claim his rewards,
        //  we will basically multiply this var by the amount the user staked.
        accumulatedRewardPerShare = accumulatedRewardPerShare.add(totalNewReward.mul(1e12).div(totalStaked));
        lastRewardTimestamp = block.timestamp;
        if (block.timestamp > rewardPeriodEndTimestamp) {
            rewardPerSecond = 0;
        }
    }

    // Will deposit specified amount and also send rewards.
    // User should have approved ERC20 before.
    /*
    Here I have changed original function from eattheblocks to use ETH instead of LP token
        function deposit(uint256 _amount) external {
    */
    function deposit() external payable {
        UserInfo storage user = users[msg.sender];
        updateRewards();
        // Send reward for previous deposits
        if (user.deposited > 0) {
            uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered);
            require(rewardToken.transfer(msg.sender, pending), "Staker: transfer failed");
            emit ClaimReward(msg.sender, pending);
        }
        user.deposited = user.deposited.add(msg.value);
        totalStaked = totalStaked.add(msg.value);
        user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7);
        /*
        Here I have remove original require from eattheblocks since I am using ETH instead of a token
            require(rewardToken.transferFrom(msg.sender, address(this), msg.value), "Staker: transferFrom failed");
        */
        emit Deposit(msg.sender, msg.value);
    }
    

    // Will withdraw the specified amount and also send rewards.
    function withdraw(uint256 _amount)
    external {
        UserInfo storage user = users[msg.sender];
        require(user.deposited >= _amount, "Staker: balance not enough");
        updateRewards();
        // Send reward for previous deposits
        uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered);
        require(rewardToken.transfer(msg.sender, pending), "Staker: reward transfer failed");
        emit ClaimReward(msg.sender, pending);
        user.deposited = user.deposited.sub(_amount);
        totalStaked = totalStaked.sub(_amount);
        user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7);
        require(rewardToken.transfer(msg.sender, _amount), "Staker: deposit withdrawal failed");
        emit Withdraw(msg.sender, _amount);
    }

    // Will just send rewards.
    function claim()
    external {
        UserInfo storage user = users[msg.sender];
        if (user.deposited == 0)
            return;

        updateRewards();
        /*
        uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered);
        require(rewardToken.transfer(msg.sender, pending), "Staker: transfer failed");
        emit ClaimReward(msg.sender, pending);
        user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7);
        */
    }

    // Will collect rewardTokens (LP tokens) that were sent to the contract
    //  Outside of the staking mechanism.
    function skim()
    external onlyOwner {
        uint256 rewardTokenBalance = rewardToken.balanceOf(address(this));
        if (rewardTokenBalance > totalStaked) {
            uint256 amount = rewardTokenBalance.sub(totalStaked);
            require(rewardToken.transfer(msg.sender, amount), "Staker: transfer failed");
            emit Skim(amount);
        }
    }

    /* 
        ####################################################
        ################## View functions ##################
        ####################################################
    */

    // Return the user's pending rewards.
    function pendingRewards(address _user)
    public view returns (uint256) {
        UserInfo storage user = users[_user];
        uint256 accumulated = accumulatedRewardPerShare;
        if (block.timestamp > lastRewardTimestamp && lastRewardTimestamp <= rewardPeriodEndTimestamp && totalStaked != 0) {
            uint256 endingTime;
            if (block.timestamp > rewardPeriodEndTimestamp) {
                endingTime = rewardPeriodEndTimestamp;
            } else {
                endingTime = block.timestamp;
            }
            uint256 secondsSinceLastRewardUpdate = endingTime.sub(lastRewardTimestamp);
            uint256 totalNewReward = secondsSinceLastRewardUpdate.mul(rewardPerSecond);
            accumulated = accumulated.add(totalNewReward.mul(1e12).div(totalStaked));
        }
        return user.deposited.mul(accumulated).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered);
    }

    // Returns misc details for the front end.
    function getFrontendView()
    external view returns (uint256 _rewardPerSecond, uint256 _secondsLeft, uint256 _deposited, uint256 _pending) {
        if (block.timestamp <= rewardPeriodEndTimestamp) {
            _secondsLeft = rewardPeriodEndTimestamp.sub(block.timestamp); 
            _rewardPerSecond = rewardPerSecond.div(1e7);
        } // else, anyway these values will default to 0
        _deposited = users[msg.sender].deposited;
        _pending = pendingRewards(msg.sender);
    }
}