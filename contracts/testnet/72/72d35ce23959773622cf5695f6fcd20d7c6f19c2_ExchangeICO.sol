/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.5.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

contract ExchangeICO{
  
    using SafeMath for uint256;
    IBEP20 private BUSD;
    IBEP20 private VPAY;  
    address payable public owner;
    uint public token_price = 1*1e16;    
    uint public  MINIMUM_SALE = 10 ;
    uint public  MAXIMUM_SALE = 1000000 ;
  	uint public sale_status = 1;
    event TokenSell(address user,uint256 tokenQty,uint256 aanaQty);
   
    constructor(address payable ownerAddress,IBEP20 _BUSD,IBEP20 _VPAY) public
    {
        owner = ownerAddress;  
        BUSD = _BUSD;
        VPAY = _VPAY;
    }
    
     
	function sellToken(uint256 tokenQty) public payable 
	{
    require(sale_status>=1,"Sale Not Allow");
    require(tokenQty>=MINIMUM_SALE,"Invalid minimum quatity");
    require(tokenQty<=MAXIMUM_SALE,"Invalid maximum quatity");
    require(VPAY.balanceOf(msg.sender)>=tokenQty);
    uint256 Token_amt=(tokenQty*(token_price/1e18));
    require(BUSD.balanceOf(address(this))>=Token_amt,"Balance is Low");
    VPAY.transferFrom(msg.sender ,owner, tokenQty);
    BUSD.transfer(msg.sender ,Token_amt);
    emit TokenSell(msg.sender,tokenQty,Token_amt);	
			
	 }
      function Buy_setting(uint min_sell,uint max_sell) public payable
        {
           require(msg.sender==owner,"Only Owner");
        	  MINIMUM_SALE = min_sell ;
            MAXIMUM_SALE = max_sell;
 		
        }

        function Price_setting(uint256 token_rate) public payable
        {
           require(msg.sender==owner,"Only Owner");
            token_price=token_rate;
			
        }
	 function sale_setting(uint start_sale) public payable
        {
           require(msg.sender==owner,"Only Owner");
            sale_status=start_sale;
        }
        
         function getPrice() public view returns(uint256)
        {
              return uint256(token_price);
			
        }

    function withdrawLost(uint256 WithAmt) public {
        require(msg.sender == owner, "onlyOwner");
        owner.transfer(WithAmt*1e18);
    }
    
  
	function withdrawLostTokenFromBalance(uint QtyAmt,IBEP20 _TOKEN) public 
	{
        require(msg.sender == owner, "onlyOwner");
        _TOKEN.transfer(owner,(QtyAmt*1e18));
	}
	
}


/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}