/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity ^0.4.25;


contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted!');
        _;
    }
    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }
    function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }
    function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}
interface IToken {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}
contract Vault is Whitelist {
    IToken internal token; 
    constructor(address token_addr) public{
        token = IToken(token_addr);
    }

    address public devAddr;
    
    function setDevAddr(address newDevAddr) public onlyOwner {
        devAddr = newDevAddr;

    }

    function withdraw(uint256 _amount) public onlyWhitelisted {
        require(token.transfer(msg.sender, _amount));
    }

    function withdrawWithFee(uint256 _amount) public onlyWhitelisted {
        require(token.transfer(msg.sender, _amount / 100 * 77));
        require(token.transfer(devAddr, _amount / 100 * 23));
   
    }
}