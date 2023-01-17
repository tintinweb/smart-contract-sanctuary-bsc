/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

pragma solidity ^0.5.17;

library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a);
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0);
    c = a / b;
  }
}

contract BEP20Interface {
    
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  
}


contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract Owned {
  address public Admininstrator;


  constructor() public {
    Admininstrator = msg.sender;
  }

  modifier onlyAdmin {
    require(msg.sender == Admininstrator, "Only authorized personnel");
    _;
  }

}

contract SELFDROP is Owned{
    
  using SafeMath for uint;
 
  address public token;
  
  uint public selfdropAmount = 35000000000000*10**18;
 
  address payable wallet;
  
  bool public startSelfdrop = false;
 
  mapping(address => uint256) public claimed;
  
  uint256 public maxPurchase = 0.4 ether;
  
  uint256 public minPurchase = 0.1 ether;
  uint256 public purchasedAmount;
  uint256 public purchasedAmount2;

  constructor() public { Admininstrator = msg.sender; }
   
  //========================================CONFIGURATIONS======================================
 
 function () external payable {
        getTokens();
     }
 
 function setWallet(address payable _wallet) public onlyAdmin{wallet = _wallet;}
 function setToken(address _tokenaddress) public onlyAdmin{token = _tokenaddress;}
 function setSelfdropAmount(uint256 _amount) public onlyAdmin{selfdropAmount = _amount*(10**18);}
 
 function AllowSelfdrop(bool _status) public onlyAdmin{
     require(wallet != 0x0000000000000000000000000000000000000000, "Wallet has not been set up");
     startSelfdrop = _status;
     
 }
	
 
 function getTokens() public payable returns(bool){
     
     require(startSelfdrop == true, "Currently not initialized");
     require(msg.value >= minPurchase, "Invalid amount");
     require(BEP20Interface(token).balanceOf(address(this)) >= selfdropAmount, "Insufficient token balance");
     require(claimed[msg.sender].add(msg.value) <= maxPurchase, "Maximum amount per wallet allowed would be exceeded");
     
     purchasedAmount = selfdropAmount.mul(msg.value);
     purchasedAmount = purchasedAmount.div(10**18);
     require(BEP20Interface(token).transfer(msg.sender, purchasedAmount), "Transaction failed");
     claimed[msg.sender] += msg.value;
     wallet.transfer(address(this).balance);
     
 }

 
 function RetrieveToken(uint256 _amount) public onlyAdmin returns(bool){
      
      require(wallet != 0x0000000000000000000000000000000000000000, "Wallet has not been set up");
      require(BEP20Interface(token).transfer(wallet, _amount), "Transaction failed");
      
  }
 
 
}