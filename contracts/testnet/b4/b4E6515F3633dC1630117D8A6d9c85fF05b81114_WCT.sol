/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WCT {

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    string public constant name = "Wildcard WCT";
    string public constant symbol = "WCT";

    uint8 public constant decimals = 18;

    uint256 public totalSupply_;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;


    address owner;
    
    mapping(address => bool) whitelistedAddresses;


    constructor() {
        totalSupply_ = 20 * 1000 * 1000 * 1000 * (10 ** decimals);
        balances[msg.sender] = totalSupply_;

        owner = msg.sender;
    }


    /*
        Verify msg sender is Owner of contract, or not.
        It means admin.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not owner");
        _;
    }

    // modifier isWhitelisted(address _address) {
    //     require(whitelistedAddresses[_address], "You need to be whitelisted");
    //     _;
    // }

    /**
        Add Whitelist by only owner
     */
    function adminAddWhitelist(address _address) public onlyOwner {
        whitelistedAddresses[_address] = true;
    }

    /**
        Remove Whitelist by only owner
     */
    function adminRemoveWhitelist(address _address) public onlyOwner {
        whitelistedAddresses[_address] = false;
    }

    function verifyWhitelistAddress(address _whiteListedAddress) public view returns (bool) {
        bool userIsWhiteListed = whitelistedAddresses[_whiteListedAddress];
        return userIsWhiteListed;
    }

    function whitelistMemberBuy(address receiver, uint256 amount) public {
        require(balances[msg.sender] >= amount, "WhitelistMemberBuy: insufficient tokens amount");
        require(verifyWhitelistAddress(msg.sender), "WhitelistMemberBuy: invalid verified user");

        amount = amount * (10 ** decimals);

        transferFrom(address(this), receiver, amount);

    }

    function transfer(address receiver, uint256 amount) public {
        require(receiver != address(0), "Transfer: Invalid receiver");
        require(balances[msg.sender] >= amount, "Transfer: insufficient tokens amount");
        require(amount > 0, "Transfer: invalid amount");
        
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
    }

    function transferFrom(address sender, address receiver, uint256 amount) public {
        require(receiver != address(0) && sender != address(0), "Transfer From: Invalid addressed");
        require(balances[sender] > balances[receiver], "Transfer From: insufficient amount");
        require(amount > 0, "Transfer From: invalid amount");

        require(allowance(sender, receiver) >= amount, "Transfer From: Not approved");

        balances[sender] -= amount;
        balances[receiver] += amount;
        allowed[sender][receiver] = allowed[sender][receiver] - amount;
        emit Transfer(sender, receiver, amount);
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address ownerAddress, address delegate) public view returns (uint) {
        return allowed[ownerAddress][delegate];
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
}