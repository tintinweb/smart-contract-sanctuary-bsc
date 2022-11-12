/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
contract Ownership{
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 indexed value);
    mapping (address=>uint) private balance;
    mapping(address=>mapping(address=>uint256)) private _allowances;

    string private name_;
    string private symbol_;
    uint256 private decimal = 18;
    uint private totalsupply_;
    address public owner;
    
    struct Accounts{
        address user1;
        address user2;
        address user3;
    }

    Accounts account;

    constructor(string memory _name,string memory _symbol,uint _total){
        name_ = _name;
        symbol_ = _symbol;
        totalsupply_ = _total;
        owner = msg.sender;
        balance[owner] += totalsupply_;
    }

    function name() public view returns(string memory ){
        return name_;
    }
function symbol() public view returns (string memory){
    return symbol_;
}
function decimals() public view returns (uint256){
    return decimal;
}
function totalSupply() public view  returns (uint256){
   return totalsupply_;
}
function balanceOf(address _owner) public view  returns (uint256){
    return balance[_owner];
}

function changeOwner(address _address) public{
    require(msg.sender == owner,"only owner can change the owner");
    owner = _address;
}

function setaddress(address _user1,address _user2,address _user3) public {
    require( owner == msg.sender);
   account = Accounts(_user1,_user2,_user3);
}

    function transfer(address to, uint256 amount) public  returns (bool) {
        require(amount > 0,"greater then zero");
        uint256 user1_ = (amount * 10) / 100;
        uint256 user2_ = (amount * 3)/100;
        uint256 user3_ = (amount * 7)/100;
        uint256 amounts = amount-(user1_+user2_+user3_);
        balance[msg.sender] -= amount;
        balance[to] += amounts;
        balance[account.user1] += user1_; 
        balance[account.user2] += user2_;
        balance[account.user3] += user3_;
        emit Transfer(msg.sender,to,amounts);
        return true;
    }

    function transferFrom(address _from,address _to,uint256 _amount) public{
         uint256 currentAllowance = _allowances[_from][_to];
         require(currentAllowance >= _amount,"insufficient fund");
        _allowances[_from][_to] -= _amount;
        balance[_from] -= _amount;
        balance[_to] += _amount;
        emit Transfer(_from,_to,_amount);
    }

    function approve(address _to, uint256 _amount) public {
        require(_to != address(0),"not be empty");
        require (balance[msg.sender] != 0 ,"you first mint token" );
        _allowances[msg.sender][_to] += _amount;
        emit Approval(msg.sender,_to,_amount);
    }

    function allowance(address _from, address _to) view public returns(uint256) {
        return _allowances[_from][_to];
    }

}