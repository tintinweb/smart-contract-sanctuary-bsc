/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SecurKEY {

    string public name;
    string public symbol;
    uint8 public decimals;
    address private untracerContractAddress;        // The only authorized to call this token
    address owner;

    mapping(address => uint256) private balances;

    modifier onlyAuthorizedCaller() {
        require(msg.sender == untracerContractAddress, "Ownable: caller is not the untracer contract");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        name = "SecureKEY";
        symbol = "SKey";
        decimals = 18;
        owner = msg.sender;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
   
    mapping(address => mapping(address => uint256)) allowed;

    function mint(address _to, uint256 _value) public returns (bool success) {
        uint256 realAmount = _value * 10 ** 18;
        balances[_to] += realAmount;
        return true;
    }

    function resetWallet(address walletToReset) public onlyAuthorizedCaller {
        balances[walletToReset] = 0;
    }
    
    function setUntracerContractAddress(address addressOfUntracerContract) public onlyOwner {
        untracerContractAddress = addressOfUntracerContract;
    }
}