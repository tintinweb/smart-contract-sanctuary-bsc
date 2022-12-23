/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NXT {
    string public constant name = "NXT TOKEN";
    string public constant symbol = "NXT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1000000000 * 10 ** decimals;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    mapping(address => bool) public isOwnerAddress;
    
    // Blacklisted addresses will not be allowed to aquire new token.
    // They can still move / sell token if they already have aquired it before adding.

    mapping(address => bool) public isBlackListed;
    address[] private blackList;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        isOwnerAddress[msg.sender] = true;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier onlyOwner() {
        require(isOwnerAddress[msg.sender] , "Only owner!");
        _;
    }

    function addOwner(address _address) public onlyOwner {
        isOwnerAddress[_address] = true;
    }
    function removeOwner(address _address) public onlyOwner {
        require (_address != owner, "Restricted Address");
        isOwnerAddress[_address] = false;
    }

    function addToBlackList(address _address) public onlyOwner {
        require (!isBlackListed[_address] , "address exsit in blackList");     
        isBlackListed[_address] = true;
        blackList.push(_address);
    }

    function removeFromBlackList(address _address) public onlyOwner {
        require (isBlackListed[_address] , "address doesnot exsit in blackList");
        isBlackListed[_address] = false;
        uint len = blackList.length;
        for(uint i = 0; i < len; i++) {
            if(blackList[i] == _address) {
                blackList[i] = blackList[len-1];
                blackList.pop();
                break;
            }
        }
    }

    function getBlackList() public view returns (address[] memory list){
        list = blackList;
    }
    function getBlackListLength() public view returns (uint256) {
        return blackList.length;
    }

    // ERC20 Functions

    function burnFrom(address from, uint256 value) public onlyOwner {
        require (balances[from]>=value, "insuffincent burn amount");
        balances[from] -= value;
        balances[address(0)] += value;
        emit Transfer(from, address(0), value);
    }
    
    function balanceOf(address inqAddress) public view returns (uint256) {
        return balances[inqAddress];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    function transfer(address receiver, uint256 amount) public returns (bool) {
        return transfer(msg.sender, receiver, amount);
    }

    function transferFrom(address tokenOwner, address receiver, uint256 amount) public returns (bool) {
        require(amount <= allowed[tokenOwner][msg.sender],"Invalid number of tokens allowed by owner");
        allowed[tokenOwner][msg.sender] -= amount;
        return transfer(tokenOwner, receiver, amount);
    }

    function transfer(address sender, address receiver, uint256 amount) internal returns (bool) {
        require(sender!= address(0) && receiver!= address(0), "invalid send or receiver address");
        require(amount <= balances[sender], "Invalid number of tokens");
        require(!isBlackListed[receiver] , "Address is blacklisted and cannot own this token");

        balances[sender] -= amount;
        balances[receiver] += amount;

        emit Transfer(sender, receiver, amount);
        return true;
    }
}