/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

//  _____    ______   ____    ____ 
// |_   _|  |_   _ \ |_   \  /   _|
//   | |      | |_) |  |   \/   |  
//   | |   _  |  __/.  | |\  /| |  
//  _| |__/ |_| |__) |_| |_\/_| |_ 
// |________|_______/|_____||_____|

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.6.0;

contract WLBM {
    string public name = "Wrapped LifeBoat Marketing";
    string public symbol = "WLBM";
    uint8 public decimals = 18;

    event Approval(address indexed source, address indexed spender, uint256 value);
    event Transfer(address indexed source, address indexed destination, uint256 value);
    event Deposit(address indexed destination, uint256 value);
    event Withdrawal(address indexed source, uint256 value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;
        msg.sender.transfer(value);
        emit Withdrawal(msg.sender, value);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address destination, uint256 value) public returns (bool) {
        return transferFrom(msg.sender, destination, value);
    }

    function transferFrom(
        address source,
        address destination,
        uint256 value
    ) public returns (bool) {
        require(balanceOf[source] >= value);

        if (source != msg.sender && allowance[source][msg.sender] != uint256(-1)) {
            require(allowance[source][msg.sender] >= value);
            allowance[source][msg.sender] -= value;
        }

        balanceOf[source] -= value;
        balanceOf[destination] += value;

        emit Transfer(source, destination, value);

        return true;
    }
}