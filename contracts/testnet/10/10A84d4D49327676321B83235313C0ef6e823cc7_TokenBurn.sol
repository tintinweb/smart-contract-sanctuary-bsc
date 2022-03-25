/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.12;

contract TokenBurn {
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address owner;
    constructor() public {
        owner = msg.sender;
    }

    event Burned(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function burn(uint256 block_gas) external onlyOwner{
        uint256 burn_amount = block_gas / 2;
        require(address(this).balance >= burn_amount, "Insufficient Token Amount");
        address(uint160(BURN_ADDRESS)).transfer(burn_amount);
        emit Burned(burn_amount);
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function deposit() payable public {

    }
}