/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract transferAnyToken {
    address public owner;
    uint256 public amount;
    
    mapping(address => bool) public admin;
    
    constructor (uint256 _amt) {
        amount = _amt;
        owner = msg.sender;
        admin[msg.sender] = true;
    }
    
    function addAdmin(address[] memory _admAddr) public {
        require(msg.sender == owner, "Only Owner can call this function");
        for (uint256 i = 0; i < _admAddr.length; i ++) {
            address _admin = _admAddr[i];
            admin[_admin] = true;
        }
    }
    
    function transfer_To_Multi_Wallet(address token, address[] memory _user, uint256[] memory amt) public {
        require(admin[msg.sender] == true, "Caller is not an admin");
        for (uint256 i = 0; i < _user.length; i++) {
            address wallet = _user[i];
            IERC20(token).transferFrom(owner, wallet, amt[i]);
        }
    }

    function transfer_To_Multi_Wallet_EqualAmount(address token, address[] memory _user) public {
        require(admin[msg.sender] == true, "Caller is not an admin");
        for (uint256 i = 0; i < _user.length; i++) {
            address wallet = _user[i];
            IERC20(token).transferFrom(owner, wallet, amount);
        }
    }

    function transfer_Native_To_Multi_Wallet_EqualAmount(address[] memory _user) public payable{
        require(admin[msg.sender] == true, "Caller is not an admin");
        for (uint256 i = 0; i < _user.length; i++) {
            address wallet = _user[i];
            payable(wallet).transfer(msg.value);
        }
    }

    function withdraw(address tok, uint256 amt) external {
        require(admin[msg.sender] == true, "Caller is not an admin");
        IERC20(tok).transfer(msg.sender, amt);
    }
    
    function setAmount(uint256 _newAmount) public {
        require(admin[msg.sender] == true, "Caller is not an admin");
        amount = _newAmount;
    }
}