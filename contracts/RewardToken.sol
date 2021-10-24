// contracts/RewardToken.sol
/* SPDX-License-Identifier: GPL-3.0
Authored by Luis Ignacio Callero
*/

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable{

    uint256 public fee;
    constructor(uint256 initialSupply) ERC20("Rewards Token", "RWT") {
        _mint(msg.sender, initialSupply);
        fee = 0;
    }

    // Pending Fee
    function updateFee(uint _newFee) public onlyOwner {
        fee = _newFee;
    }
}