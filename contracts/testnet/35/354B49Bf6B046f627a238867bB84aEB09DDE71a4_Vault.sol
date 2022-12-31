//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

contract Vault {
    mapping(address => uint) balances;

    receive() external payable {}

    function deposit() external payable {
        require((balances[msg.sender] + msg.value) >= balances[msg.sender]);
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) external {
        require(balances[msg.sender] >= amount, "So du ban khong du de rut");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}