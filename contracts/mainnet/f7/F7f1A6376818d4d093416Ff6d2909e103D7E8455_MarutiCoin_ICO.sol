/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-13
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

contract MarutiCoin_ICO{
  
    using SafeMath for uint256;
    IERC20 private BUSD;
    IERC20 private MRC;  
    address payable public owner;
    uint public token_price = 1*1e17;     //0.1 busd
    uint public  MINIMUM_BUY = 10*1e18 ;
    uint public  MAXIMUM_BUY = 1000000*1e18 ;
	event TokenBuy(address user,uint256 tokenQty);
   
    constructor(address payable ownerAddress,IERC20 _BUSD,IERC20 _MRC) public
    {
        owner = ownerAddress;  
        MRC = _MRC;
        BUSD = _BUSD;
    }
    
     
	function BuyToken(uint256 tokenQty) public payable 
	{
        require((tokenQty*1e18)>=MINIMUM_BUY,"Invalid minimum quatity");
        require((tokenQty*1e18)<=MAXIMUM_BUY,"Invalid maximum quatity");
        uint256 Token_amt=tokenQty*token_price;
        require(BUSD.balanceOf(msg.sender)>=Token_amt);
        require(MRC.balanceOf(address(this))>=(tokenQty*1e18),"Balance is Low");
        BUSD.transferFrom(msg.sender ,owner, Token_amt);
        MRC.transfer(msg.sender ,tokenQty*1e18);
        emit TokenBuy(msg.sender,tokenQty);	
			
	 }
      function Buy_setting(uint min_buy, uint max_buy) public payable
        {
           require(msg.sender==owner,"Only Owner");
              MINIMUM_BUY = min_buy ;
              MAXIMUM_BUY = max_buy;
	
        }

         function Price_setting(uint256 token_rate) public payable
        {
           require(msg.sender==owner,"Only Owner");
            token_price=token_rate;
			
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
        _TOKEN.transfer(owner,(QtyAmt));
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