/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

//SPDX-License-Identifier: MIT 
 pragma solidity ^0.8.17;

 interface IERC20{
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals()external view returns(uint8);
    function totalsupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256 balance); 
    function transfer(address to,uint256 amount) external returns(bool success);
    function transferFrom(address from,address to,uint256 amount) external returns(bool success);
    function approve(address spender,uint256 amount)external returns (bool success);
    function allowance(address owner,address spender) external returns(uint256 remaining);
    
}
contract Mytoken{
    string public name;
    address public owner;
    uint256 public minbuyToken;
    string public symbol;
    uint8 public decimals;
    uint256 public totalsupply;
    uint256 public feePercentage;
    mapping (address=>uint256) private balances;
    mapping (address=>mapping (address=>uint256)) private allowed;
    mapping(address=>bool) public whitelist;
    mapping(address=>bool) public blacklist;
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(){
       name="Asim";
       symbol="AJ";
       decimals=7;
       totalsupply=1000000e7;
       minbuyToken=500e7;
       owner=msg.sender;
       balances[msg.sender]=totalsupply;
       whitelist[owner]=true;
       feePercentage = 3;
    }
     modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function Blacklist(address adres) public onlyOwner(){
        blacklist[adres]=true;
    }
    
    function Whitelist(address addr)public onlyOwner(){
        whitelist[addr]=true;

    }
    function balanceOf(address _owner) view public returns (uint256) {
        return balances[_owner];
    }
    
    function allowance(address _owner, address _spender) view public returns (uint256) {
      return allowed[_owner][_spender];
    }
    
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require (balances[msg.sender] >=  _amount, "BEP20: user balance is insufficient");
        require( _amount >= minbuyToken, "BEP20: amount can not be zero");
        require(whitelist[msg.sender]==true,"the user is not whitelisted ");
        require(blacklist[_to]!=true,"the user is blacklisted");
        uint256 fee=_amount*feePercentage/100;
        balances[msg.sender]=balances[msg.sender]-( _amount);
        uint256 value=_amount-fee;
        balances[owner]+=fee;
        balances[_to]=balances[_to]+( value);
        emit Transfer(msg.sender,_to, _amount);
        return true;
    }
    
    function transferFrom(address _from,address _to,uint256 _amount) public returns (bool success) {
        require(_amount > 0, "BEP20: amount can not be zero");
        require (balances[_from] >= _amount ,"BEP20: user balance is insufficient");
        require(allowed[_from][msg.sender] >= _amount, "BEP20: amount not approved");
        balances[_from]=balances[_from]-(_amount);
        allowed[_from][msg.sender]=allowed[_from][msg.sender]-(_amount);
        balances[_to]=balances[_to]+(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
  
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(_spender != address(0), "BEP20: address can not be zero");
        require(balances[msg.sender] >= _amount ,"BEP20: user balance is insufficient");
        allowed[msg.sender][_spender]=_amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
}