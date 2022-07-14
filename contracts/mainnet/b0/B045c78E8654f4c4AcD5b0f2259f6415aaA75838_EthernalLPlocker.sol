/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-26
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

contract EthernalLPlocker {
    
address public V1TokenAddress;
address public MainWallet;  
bool public Swapping_Enabled;

uint256 public totalV1deposited;
uint256 public totalV2claimed;


mapping (address => uint256) public V1Deposited;


    
modifier onlyMain() {
      require(msg.sender == MainWallet);
      _;
   }    
   
   
     constructor(address V1TokenAddr) {
        MainWallet = msg.sender;
        V1TokenAddress = V1TokenAddr;
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
 
     function GetLPBALANCE() public view returns (uint256)
 {
    uint256 bal = IERC20(V1TokenAddress).balanceOf(address(this));
    return bal;
 } 
 
 
  
 
 
      function MyLPBalance() public view returns (uint256)
 {
    uint256 bal = IERC20(V1TokenAddress).balanceOf(msg.sender);
    return bal;
 } 
 

 
       function GetBNBBalance() public view returns (uint256)
 {
    return address(this).balance;
 }
 
 
    
}