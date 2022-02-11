/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract bank {
    address owner;

    struct user {
        string name;
        uint256 balance;
        bool exists;
    }

    uint256 bank_liquidity;
    uint256 fees;

    mapping(address => user) public Users;

    constructor() {
        owner = msg.sender;
    }

    function collect_fees(address payable _receiver) public {
        require(msg.sender == owner);
        _receiver.transfer(fees);
        fees = 0;
    }

    function show_fees() public view returns (uint256) {
        return fees;
    }

    function register(string memory _name) public {
        Users[msg.sender] = user(_name, 0, true);
    }

    function deposit(address _receiver) external payable {
        require(msg.value > 0 && Users[msg.sender].exists);
        Users[_receiver].balance += msg.value;
    }

    function withdraw(uint256 _amount, address payable _receiver) external {
        require(_amount > 0 && _amount <= Users[msg.sender].balance);
        uint256 amt = (_amount * 99) / 100;
        _receiver.transfer(amt);
        Users[msg.sender].balance -= amt;
        fees += _amount - amt;
    }

    function transferTo(address payable _to, uint256 _amount) external {
        require(_amount > 0 && _amount <= Users[msg.sender].balance);
        require(Users[msg.sender].exists && Users[_to].exists);
        uint256 amt = (_amount * 95) / 100;
        _to.transfer(_amount);
        Users[msg.sender].balance -= amt;
        Users[_to].balance += amt;
        fees += _amount - amt;
    }

    function balanceOf() public view returns (uint256) {
        return Users[msg.sender].balance;
    }

    fallback() external {
        revert();
    }
}