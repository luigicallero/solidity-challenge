// contracts/Staker.sol
/* SPDX-License-Identifier: GPL-3.0
Authored by Luis Ignacio Callero
With great help from Greg DappUniversity https://www.youtube.com/watch?v=sCE-fQJAVQ4
    and Austin Griffith https://github.com/scaffold-eth/scaffold-eth/blob/staking-app/packages/hardhat/contracts/Staker.sol 
*/

pragma solidity ^0.8.4;

import "./RewardToken.sol";

contract Staker {
    string public name = "Luisca Staking Application";
    RewardToken public RWT;

    event Stake(address staker, uint256 amount);

    uint256 public constant threshold = 1 ether;

    mapping ( address => uint256 ) public balances;

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