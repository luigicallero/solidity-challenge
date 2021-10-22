// contracts/Staker.sol
/* SPDX-License-Identifier: GPL-3.0
Authored by Luis Ignacio Callero
With great help from 
    Greg DappUniversity https://www.youtube.com/watch?v=sCE-fQJAVQ4
    Austin Griffith https://github.com/scaffold-eth/scaffold-eth/blob/staking-app/packages/hardhat/contracts/Staker.sol
    https://medium.com/@tnhollan/how-to-implement-staking-in-solidity-cdb1d0506ef6
*/

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol"; // to be used with remix
import "./RewardToken.sol";

contract Staker {
    string public name = "Luisca Staking Application";
    RewardToken public RWT;
    using SafeMath for uint256;
    uint256 public constant threshold = 1 ether;
    mapping ( address => uint256 ) public balances;
    event Stake(address staker, uint256 amount);
    /**
     * @notice We usually require to know who are all the stakeholders.
     */
    address[] internal stakeholders;
    
    /**
    * @notice A method to check if an address is a stakeholder.
    * @param _address The address to verify.
    * @return bool, uint256 Whether the address is a stakeholder,
    * and if so its position in the stakeholders array.
    */
   function isStakeholder(address _address)
       public
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }   /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
   function addStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
   }   /**
    * @notice A method to remove a stakeholder.
    * @param _stakeholder The stakeholder to remove.
    */
   function removeStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
       if(_isStakeholder){
           stakeholders[s] = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
   }
   
   
   
   /**
    * @notice The stakes for each stakeholder.
    */
   mapping(address => uint256) internal stakes;
   
   
   /**
    * @notice A method to retrieve the stake for a stakeholder.
    * @param _stakeholder The stakeholder to retrieve the stake for.
    * @return uint256 The amount of wei staked.
    */
   function stakeOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder];
   }   /**
    * @notice A method to the aggregated stakes from all stakeholders.
    * @return uint256 The aggregated stakes from all stakeholders.
    */
   function totalStakes()
       public
       view
       returns(uint256)
   {
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
       }
       return _totalStakes;
   }
   
   

    /**
    * @notice The accumulated rewards for each stakeholder.
    */
   mapping(address => uint256) internal rewards;
  
   /**
    * @notice A method to allow a stakeholder to check his rewards.
    * @param _stakeholder The stakeholder to check rewards for.
    */
   function rewardOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return rewards[_stakeholder];
   }   /**
    * @notice A method to the aggregated rewards from all stakeholders.
    * @return uint256 The aggregated rewards from all stakeholders.
    */
   function totalRewards()
       public
       view
       returns(uint256)
   {
       uint256 _totalRewards = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
       }
       return _totalRewards;
   }
   
   
    function stake() public payable {
        emit Stake(msg.sender, msg.value);
        balances[msg.sender] += msg.value;
    }

    /* After `deadline` anyone can call `execute()` function

    uint256 public deadline = now + 0.4 minutes;

    bool public completed;
    bool public failed;

    function execute() public {
        require(!completed, "Already completed");
        require(!failed, "Already failed");
        require(now>=deadline, "Have not reached deadline yet");
        if( address(this).balance >= threshold ){
        exampleExternalContract.complete{value: address(this).balance}();
        completed=true;
        }else{
        failed=true;
        }
    }

    function withdraw(address payable staker) public {
        require(failed, "Cant withdraw until execute fails");
        uint256 amount = balances[staker];
        balances[staker] = 0;
        staker.transfer(amount);
    }

    // `timeLeft()` view function returns the time left before the deadline for the frontend

    function timeLeft() public view returns (uint256) {
        if(now>deadline) return 0;
        return deadline - now;
    }
    */
}