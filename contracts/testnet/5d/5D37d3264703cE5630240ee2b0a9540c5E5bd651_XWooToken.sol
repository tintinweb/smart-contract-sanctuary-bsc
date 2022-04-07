/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract ERC20 is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Solidity by Example";
    string public symbol = "SOLBYEX";
    uint8 public decimals = 18;

    address public OWNER;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        OWNER = msg.sender;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(address user, uint amount) public {
        require(msg.sender == OWNER, "You are not the owner");
        balanceOf[user] += amount;
        totalSupply += amount;
        emit Transfer(address(0), user, amount);
    }

    function burn(address user, uint amount) public {
        require(msg.sender == OWNER, "You are not the owner");
        balanceOf[user] -= amount;
        totalSupply -= amount;
        emit Transfer(user, address(0), amount);
    }
}



contract XWooToken is ERC20 {

    struct HolderInfo {
        string name;
        string boa;
        uint8  age;
        uint32 voteCount;
    }

    mapping(address => HolderInfo) public holdInfos;    // user => info

    mapping(address => mapping(address => bool)) voted; // (userA, userB) => voted 

    address[] public users;

    constructor() 
        ERC20('Woo Test Token', 'xWoo') {
    }

    // ---------- Admin Methods ------------ //

    function addUser(address user, string memory name, string memory boa, uint8 age) external {
        require(msg.sender == OWNER, "You are not the owner");
        holdInfos[user] = HolderInfo(name, boa, age, 0);
        users.push(user);
    }

    function printToken(address user, uint256 balance) external {
        require(msg.sender == OWNER, "You are not the owner");
        mint(user, balance);
    }

    function reduceToken(address user, uint256 balance) external {
        require(msg.sender == OWNER, "You are not the owner");
        burn(user, balance);
    }

    // ---------- External Methods ------------ //

    function voteFor(address user) external {
        require(!voted[msg.sender][user], "Already voted");
        voted[msg.sender][user] = true;
        holdInfos[user].voteCount += 1;
    }

    function allHolders() external view returns (HolderInfo[] memory) {
        HolderInfo[] memory holders = new HolderInfo[](users.length);
        for (uint i = 0; i < users.length; i++) {
            holders[i] = holdInfos[users[i]];
        }
        return holders;
    }
}