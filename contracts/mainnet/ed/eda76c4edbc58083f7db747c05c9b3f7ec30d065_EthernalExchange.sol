/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-27
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: MIT
interface IERC20 {
    function totalSupply() external view returns (uint _totalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface DAPP {
    
}


//exclude this contract address from tax system in both v1 and v2 contracts

contract EthernalExchange {
    
address public V1TokenAddress;
address public V2TokenAddress;
address public MainWallet;  
uint256 public ExchangeRate;
bool public Swapping_Enabled;

uint256 public totalV1deposited;
uint256 public totalV2claimed;


mapping (address => uint256) public V1Deposited;
mapping (address => uint256) public V2ReadytoClaim;
mapping (address => uint256) public V2Claimed;

    
modifier onlyMain() {
      require(msg.sender == MainWallet);
      _;
   }    
   
   
     constructor(address V1TokenAddr) {
        MainWallet = msg.sender;
        ExchangeRate = 100;
        V1TokenAddress = V1TokenAddr;
     }

     
 function SetV2TokenAddress(address v2) public onlyMain()  
 {
    V2TokenAddress = v2; 
 }
 
  function TransferOwnership(address NewMainWallet) public onlyMain()
 {
     MainWallet = NewMainWallet;
 }
 
   function UnlockSwap() public onlyMain()
 {
     Swapping_Enabled = true;
 }
 
    function LockSwap() public onlyMain()
 {
     Swapping_Enabled = false;
 }
 
     function SetExchangeRate(uint256 rate) public onlyMain() // 100 = 100% => 1:1
 {
     ExchangeRate = rate;
 }
 
 
/*      function ApproveTokenRecovery(address TokenAddress, uint256 amount) public onlyMain()
 {
    IERC20(TokenAddress).approve(address(this),amount); //?
 }*/
 
     function RecoverTokens(address TokenAddress, uint256 amount) public onlyMain()
 {
    IERC20(TokenAddress).transfer(MainWallet, amount);
 }
 
    function RecoverBNB(uint256 amountBNB) public onlyMain() returns (bool)
 {
     uint256 bal = GetBNBBalance();
     require (bal>=amountBNB);
    (bool success, ) = MainWallet.call{ value: amountBNB }(new bytes(0));

  return success;

 }
 
     function GetV1Balance() public view returns (uint256)
 {
    uint256 bal = IERC20(V1TokenAddress).balanceOf(address(this));
    return bal;
 } 
 
 
      function GetV2Balance() public view returns (uint256)
 {
     uint256 bal = IERC20(V2TokenAddress).balanceOf(address(this));
    return bal;
 }
 
 
      function MyV1Balance() public view returns (uint256)
 {
    uint256 bal = IERC20(V1TokenAddress).balanceOf(msg.sender);
    return bal;
 } 
 
 
      function MyV2Balance() public view returns (uint256)
 {
     uint256 bal = IERC20(V2TokenAddress).balanceOf(msg.sender);
    return bal;
 }
 
/*       function MyV1Deposited() public view returns (uint256)
 {
    return V1Deposited[msg.sender];
 }*/
 
/*        function MyV2Claimed() public view returns (uint256)
 {
    return V2Claimed[msg.sender];
 }*/
 
       function GetBNBBalance() public view returns (uint256)
 {
    return address(this).balance;
 }
 
 //remember to call approve function on the V1 contract first.
 //call this function to swap total balance of V1 tokens to V2
 function SwapAllV1toV2() public
 {
    uint256 v1bal = IERC20(V1TokenAddress).balanceOf(msg.sender);
      require(v1bal>0,"You do not have any V1 tokens left");
      SwapV1toV2(v1bal);
 }

//Call this function to swap a portion of V1 tokens to V2. Remember to include decimals
     function SwapV1toV2(uint256 tokenAmount) public 
 {  require(Swapping_Enabled,"Swapping locked");
    require(IERC20(V1TokenAddress).balanceOf(msg.sender)>=tokenAmount,"Requested amount exceeds holder V1 balance");

      require(tokenAmount>0,"Token amount needs to be greater than zero");
     bool V1success = IERC20(V1TokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
     
     require(V1success,"V1 transferFrom failed");
 
      V1Deposited[msg.sender] += tokenAmount;
      totalV1deposited += tokenAmount;

     uint256 V2amount = tokenAmount * ExchangeRate / 100;
     require(GetV2Balance()>=V2amount,"Insufficient V2 balance for swap");

      V2Claimed[msg.sender] += V2amount;
      
      totalV2claimed += V2amount;
     require(IERC20(V2TokenAddress).transfer(msg.sender, V2amount),"V2 transfer failed");
     // V2ReadytoClaim[msg.sender] += v1bal * ExchangeRate / 100;
     
    }


  /*    function ApproveV1() public 
 {
      uint256 v1bal = IERC20(V1TokenAddress).balanceOf(msg.sender);
      
      require(v1bal>0);
      IERC20(V1TokenAddress).approve(address(this),v1bal);
 } */
 /*
      function DepositV1() public 
 {  require(Swapping_Enabled,"Swapping locked");

      uint256 v1bal = IERC20(V1TokenAddress).balanceOf(msg.sender);
      require(v1bal>0);
     bool V1success = IERC20(V1TokenAddress).transferFrom(msg.sender, address(this), v1bal);
     
     if(V1success)
     {
      V1Deposited[msg.sender] = v1bal;
      totalV1deposited += v1bal;

      V2ReadytoClaim[msg.sender] += v1bal * ExchangeRate / 100;
     
     } 
    }
 */

/* function ClaimV2() public
  { require(Swapping_Enabled,"Swapping locked");
   uint256 v2claim = V2ReadytoClaim[msg.sender];
   
   require(V2ReadytoClaim[msg.sender]>0,"Please deposit V1 first"); 
  if(IERC20(V2TokenAddress).transfer(msg.sender, v2claim))
  {
     V2ReadytoClaim[msg.sender] = 0;
      V2Claimed[msg.sender] += v2claim;
      
      totalV2claimed += v2claim;
  }  
  }*/
   
/*  function CheckV1Allowance(address addr) public view returns (uint256)
  {
      uint256 alw = IERC20(V1TokenAddress).allowance(msg.sender, address(this));
      return alw;
  }*/
    
}