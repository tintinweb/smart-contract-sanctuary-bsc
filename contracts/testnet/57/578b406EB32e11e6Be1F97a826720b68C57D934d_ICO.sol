/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract Ownable {
  address public owner;
  constructor ()  {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}
interface Token{
    function transfer(address _to, uint256 _value) external  returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address from,address _to, uint256 _value) external  returns (bool);
}
contract ICO is Ownable
{ 
     using SafeMath for uint256;
     Token token;
     uint256 public amount;
  
    uint256 public initial_value = 0.004 ether ;   //bnb
    uint256 public token_rate  = 132;
    uint256 public max_cap = 1230 ;   //bnb
    uint256 public duration =  10;        //1230 hour = 1230*60*60  = 4428000
    uint256 public startTime;
    mapping(address => bool) result1;
     mapping(address => bool) result2;
      mapping(address => bool) result3; 

          bool public initialized = false;  
          uint256 public raisedamount = 0; 
       event BoughtTokens(address indexed to, uint256 value); 


       modifier whenSaleIsActive1()
        {  
          require(initialized == true,"initialized must be true" );
          _; 
           }
        modifier whenSaleIsActive2()
        {
        require(block.timestamp <= startTime.add(duration), "time ") ;
        _;
        }
        modifier whenSaleIsActive3()
       {  
         require(goalReached() == false , " goal should not be reached");  
       _;
         }   
       
  
    constructor(Token _token)
    {
        require(address(_token) != address(0), "address must be available");
        token = _token;  
        owner == msg.sender;       
    }   
     function initializeICO(uint256 _amount) public  onlyOwner 
    {
        require(_amount != 0);
        amount = _amount;
         initialized = true; 
         startTime = block.timestamp ;
        token.transferFrom(msg.sender, address(this),_amount);
    } 

  function goalReached() public view returns (bool) {
    return (raisedamount >= max_cap * 1 ether);
  }
  receive () external payable           // use to reduce gas fee. 
   {
    buy();
 }     

   function buy()public payable whenSaleIsActive1 whenSaleIsActive2 whenSaleIsActive3 
   {
       require(msg.value > 0 , "can not enter 0 value");
       require(msg.sender != owner ,"owner can not buy");
       require(msg.value >= initial_value , "value must = or greater than given amount");
       uint256 uservalue = msg.value;
       uint256 value = uservalue/initial_value;
       uint256  tokens = value.mul(token_rate); 
      
         if(result1 [msg.sender] == false)
        {
              token.transferFrom(address(this), msg.sender,tokens);
       raisedamount = raisedamount.add(msg.value);
       payable(owner).transfer(msg.value);
        }
        else if(result2[msg.sender]== false)
        {
              token.transferFrom(address(this), msg.sender,tokens);
       raisedamount = raisedamount.add(msg.value);
       payable(owner).transfer(msg.value);
        }
         else if(result3[msg.sender]== false)
        {
            token.transferFrom(address(this), msg.sender,tokens);
       raisedamount = raisedamount.add(msg.value);
       payable(owner).transfer(msg.value);
        }
        else if(result3[msg.sender]==true)
        { 
            require( result2[msg.sender]==false && result1[msg.sender]==false && result3[msg.sender]==false,"you can not claim more than 3 times.");
        } 
        emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
   }
    
  function SetTokenRate (uint256 _rate) external onlyOwner {
    token_rate = _rate;
  }
   function SetMinPurchase (uint256 _minimumInvestment) external onlyOwner {
       initial_value = _minimumInvestment;
  }
  function SetCap (uint256 _cap) external onlyOwner {
    max_cap = _cap;
  }
  function SetTime (uint256 _Time) external onlyOwner {
    duration = _Time;
  }
  
  function remove()public onlyOwner                          
  {
    // Transfer tokens back to owner
    uint256 balance = token.balanceOf(address(this));
    assert(balance > 0);
    token.transfer(owner, balance);
    // There should be no bnb in the contract but just in case
    selfdestruct(payable(owner));             //owner himself destroy it.
  } 
  function getraisedamount()public view returns (uint256)
  {
      return raisedamount;
  }
    function update_initialize (uint256 Amount) public onlyOwner
     {
       token.transferFrom(msg.sender,address(this),Amount);
       amount = amount + Amount;
     }
 
   }