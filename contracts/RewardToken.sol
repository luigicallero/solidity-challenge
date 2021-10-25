// contracts/RewardToken.sol
/* SPDX-License-Identifier: GPL-3.0
Authored by Luis Ignacio Callero
*/

pragma solidity ^0.8.4;

// ERC20 updated to allow Fee
//import "@openzeppelin/contracts/token/ERC20/ERC20_Fee.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract RewardToken is ERC20, Ownable{
    // Initial Fee is 0 WEI of RWT token
    uint256 private _fee = 0;
    address private _creator;

    constructor(uint256 initialSupply ) ERC20("Rewards Token", "RWT" ) {
        _mint(msg.sender, initialSupply);
        _creator = msg.sender;
    }

    // Pending Fee update
    function updateFee(uint256 _newFee) public onlyOwner {
        _fee = _newFee;
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if (msg.sender != _creator) { 
            _transfer(_msgSender(), _creator, _fee);
        }        
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

}