/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

pragma solidity >= 0.5.0;

interface IERC20 {
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

contract GOAT_ICO{
  
     using SafeMath for uint256;
    IERC20 private GOAT; 
    address payable public owner;
    uint public token_price = 22;    //0.5 Paisa
    uint public  MINIMUM_BUY = 10 ;
     uint public  MAXIMUM_BUY = 1000000 ;
	   uint public  MINIMUM_SALE = 10 ;
     uint public  MAXIMUM_SALE = 1000000 ;
	 uint public sale_status = 1;
    event BuyToke(uint256 tokenQty , address indexed sender,uint256 bnb_amt);
    event SellToke(uint256 tokenQty , address indexed sender,uint256 bnb_amt);
   
    constructor(address payable ownerAddress,IERC20 _GOAT) public
    {
        owner = ownerAddress;  
        GOAT = _GOAT;
    }
    
    function BuyToken(uint tokenQty) public payable
	{
		require(tokenQty>=MINIMUM_BUY,"Invalid minimum quatity");
		require(tokenQty<=MAXIMUM_BUY,"Invalid maximum quatity");
		uint256 bnb_amt=(tokenQty*(token_price/1000000))*1e18;   
		
		require(msg.value>=bnb_amt,"Invalid buy amount");
		GOAT.transfer(msg.sender , (tokenQty*1e18));
    emit BuyToke(tokenQty , msg.sender,bnb_amt);
 
	}
    
	function sellToken(uint tokenQty,address payable _userAddress) public payable 
	{
			require(sale_status>=1,"Sale Not Allow");
	        require(tokenQty>=MINIMUM_SALE,"Invalid minimum quatity");
	        require(tokenQty<=MAXIMUM_SALE,"Invalid maximum quatity");
	     	require(GOAT.balanceOf(msg.sender)>=tokenQty*1e18);
			uint bnb_amt=((tokenQty)*(token_price)/1000000)*1e18;
			GOAT.transferFrom(msg.sender ,address(this), (tokenQty*1e18));
		_userAddress.transfer(bnb_amt);
    emit SellToke(tokenQty ,msg.sender,bnb_amt);
			
			
	 }
      function Buy_setting(uint min_buy, uint max_buy, uint min_sell,uint max_sell) public payable
        {
           require(msg.sender==owner,"Only Owner");
              MINIMUM_BUY = min_buy ;
              MAXIMUM_BUY = max_buy;
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
        owner.transfer(WithAmt);
    }
    
  
	function withdrawLostTokenFromBalance(uint QtyAmt,IERC20 _TOKEN) public 
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