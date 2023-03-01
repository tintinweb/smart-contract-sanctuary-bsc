/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface BEP20Interface {
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint balance);
}

contract TokenMigration {
    address public oldToken;
    address public newToken;
    address public owner;

    event Migration(address indexed user, uint amount);

    constructor(address _oldToken, address _newToken) {
        oldToken = _oldToken;
        newToken = _newToken;
        owner = msg.sender;
    }

    function changeContractAddresses(address _oldToken, address _newToken) public {
        require(msg.sender == owner, "Only the owner can change contract addresses");
        oldToken = _oldToken;
        newToken = _newToken;
        _oldToken = address(0x893535ED1b5C6969E62a10bABfED4F5fF8373278);
        _newToken = address(0xf6A342881756c924aBcb6E8340813e4068a9181F);
    }

function migrate(uint amount) public {
    require(amount > 0, "Amount must be greater than zero");

    BEP20Interface oldTokenContract = BEP20Interface(oldToken);
    BEP20Interface newTokenContract = BEP20Interface(newToken);

    // Transfer the old tokens from the user to this contract
    require(oldTokenContract.transferFrom(msg.sender, address(this), amount), "Transfer failed");

    // Approve the new token contract to spend the old tokens
    require(oldTokenContract.approve(newToken, amount), "Approval failed");
    require(oldTokenContract.approve(address(this), amount), "Approval failed");

    // Transfer the new tokens from this contract to the user
    address payable newTokenPayable = payable(address(uint160(newToken)));
    newTokenPayable.transfer(amount);

    emit Migration(msg.sender, amount);
}


    function balanceOfOldToken(address user) public view returns (uint) {
        BEP20Interface oldTokenContract = BEP20Interface(oldToken);
        return oldTokenContract.balanceOf(user);
    }

    function balanceOfNewToken(address user) public view returns (uint) {
        BEP20Interface newTokenContract = BEP20Interface(newToken);
        return newTokenContract.balanceOf(user);
    }
}