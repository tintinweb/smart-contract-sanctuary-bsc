/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract RaBot is ERC20Interface{
    string public name = "RaBotTest";
    string public symbol = "RaTST";
    uint public decimals = 18;
    uint public override totalSupply;
    bool Enable;
    struct Black{
        address BlackedBy;
        bool Blacked;
        uint BlacklistBlock;
    }

    address public Owner;
    mapping(address => uint) public balances;
    mapping(address => uint) public LastTransferTime;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) LastTxBlock;
    mapping(address => Black) public Blacklist;

    constructor(){
        totalSupply = 600000000000000000000000000;
        Owner = msg.sender;
        balances[Owner] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns(bool success){
        require(balances[msg.sender] >= tokens);
        require(Enable,"Trading isn't enabled yet");
        require(Blacklist[msg.sender].Blacked == false,"You have been blacklisted, You can make your appeal in our Telegram Channel");
        LastTransferTime[to] = block.timestamp;
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender,to,tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) view public override returns(uint){
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint tokens) public override returns (bool success){
        require(tokens > 0,"Amount Can't be Zero(0)");
        require(Enable,"Trading isn't enabled yet");

        allowed[msg.sender][spender] = tokens;
        
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        require(Enable,"Trading isn't enabled yet");
        require(allowed[from][msg.sender] >= tokens,"Amount Not Allowed");
        require(balances[from] >= tokens,"Owner Doesn't Have That Many Tokens");
        require(Blacklist[from].Blacked == false,"You have been blacklisted, You can make your appeal by sending us an e-mail");
        LastTransferTime[to] = block.timestamp;
        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][msg.sender] -= tokens;
        
        emit Transfer(from, to, tokens);
        LastTxBlock[msg.sender] = block.number;

        return true;
    }

    function ToggleTrading(bool _Enable) public returns (bool success){
        require(Owner == msg.sender,"Needs Owner Priviliges");
        Enable = _Enable;
        return true;
    }

    function SetToBlacklist(address _Address) public returns (bool success){
        Blacklist[_Address].BlackedBy = msg.sender;
        Blacklist[_Address].Blacked = true;
        Blacklist[_Address].BlacklistBlock = block.number;
        return true;
    }

    function ChangeOwner(address _Owner) public returns (bool success){
        require(Owner == msg.sender,"Needs Owner Priviliges");
        Owner = payable(_Owner);
        return true;
    }

    function ForgiveAndLetLive(address Blacklisted,bool BlackListed) public returns (bool success){
        require(Owner == msg.sender,"Needs Owner Priviliges");
        Blacklist[Blacklisted].Blacked = BlackListed;
        return true;
    }

    function Burn(uint Amount) public returns (bool success){
        require(balances[msg.sender] >= Amount,"Not Enough Tokens");
        balances[msg.sender] -= Amount;
        totalSupply -= Amount;
        return true;
    }
}