/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// File: Dtoken.sol


pragma solidity 0.7.0;

contract DevToken{
  // name
  string public name = "Dev Token";
  // Symbol or Ticker
  string public symbol = "DEV";
  // decimal 
  uint256 public decimals = 18;
  // totalsupply
  uint256 public totalSupply;
  
  // transfer event
  event Transfer(address indexed sender,address indexed to,uint256 amount);

  // Approval
  event Approval(address indexed From , address indexed spender, uint256 amount);
  
 // balance mapping  
  mapping (address => uint256) public balanceOf;
  
  // allowance mapping
  mapping(address => mapping(address => uint256)) public allowance;
//   allowance[msg.sender][_spender] = amount
//  a[msg.sender][_spenderaddres ] = 1000;
  
  constructor(uint256 _totalsupply)  {
      totalSupply = _totalsupply; 
      balanceOf[msg.sender] = _totalsupply;
  }
  
  // transfer function
  function transfer(address _to,uint256 _amount) public returns(bool success){
  // the user that is transferring must have suffiecent balance
  require(balanceOf[msg.sender] >= _amount , 'you have not enough balance');
  // subtracnt the amount from sender
  balanceOf[msg.sender] -= _amount;
  // add the amount to the user transfered
  balanceOf[_to] += _amount;
  emit Transfer(msg.sender,_to,_amount);
  return true;
  }

  // approve function
  function approve(address _spender,uint256 _amount) public returns(bool success){
  // increase allownce
  allowance[msg.sender][_spender] += _amount;
  // emit allownce event
  emit Approval(msg.sender,_spender,_amount);
  return true;
  }
  
  // transferFrom function
  function transferFrom(address _from,address _to,uint256 _amount) public returns(bool success){
  // check the balance of from user
  require(balanceOf[_from] >= _amount,'the user from which money has to deducted doesnt have enough balance');
  // check the allownce of the msg.sender
  require(allowance[_from][msg.sender] >= _amount,'the spender doest have required allownce');
  // subtract the amount from user
  balanceOf[_from] -= _amount;
  // add the amount to user
  balanceOf[_to] += _amount;
  // decrese the allownce
  allowance[_from][msg.sender] -= _amount;
  // emit transfer
  emit Transfer(_from,_to,_amount);
  return true;
  }
 
  
}
// File: sale.sol


pragma solidity ^0.7.0;

interface IERC20 
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


}




contract DevTokenSale   {
    address payable public  admin;
    DevToken public devtoken;
    uint256 public tokenprice;
    uint256 public totalsold; 
     
    event Sell(address sender,uint256 totalvalue); 
   
    // constructor 
    constructor(address _tokenaddress,uint256 _tokenvalue){
        admin  = msg.sender;
        tokenprice = _tokenvalue;
        devtoken  = DevToken(_tokenaddress);
    }
   
    
    function buyTokens() public payable{
    totalsold += msg.value*tokenprice;
    }

    function withdrawCrypto(address payable beneficiary) public  {

    require(msg.sender == admin , ' you are not the admin');
        beneficiary.transfer(address(this).balance);
    }
    function transferOwnership(address payable newOwner) public  {
        require(msg.sender == admin , ' you are not the admin');
        require(newOwner != admin, "Ownable: new owner is the zero address");
        admin = newOwner;
    }
}