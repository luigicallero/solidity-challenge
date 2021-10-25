// contracts/RewardToken.sol
/* SPDX-License-Identifier: GPL-3.0
Authored by Luis Ignacio Callero
*/

pragma solidity ^0.8.4;

// ERC20 updated to allow Fee
import "@openzeppelin/contracts/token/ERC20/ERC20_Fee.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable{
    // Initial Fee is 100 WEI of RWT token
    uint256 private _fee = 100;
    constructor(uint256 initialSupply ) ERC20("Rewards Token", "RWT", _fee ) {
        _mint(msg.sender, initialSupply);
    }

    // Pending Fee update
    function updateFee(uint256 _newFee) public onlyOwner {
        _fee = _newFee;
    }
}