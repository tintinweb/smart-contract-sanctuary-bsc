/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-27
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

contract METAZEN_SWAP{
  
     using SafeMath for uint256;
    IERC20 private MTZ; 
    IERC20 private BUSD;
    address payable public owner;
    uint public token_price = 100*1e18;    //0.5 Paisa
    uint public  MINIMUM_BUY = 1*1e18 ;
     uint public  MAXIMUM_BUY = 10*1e18 ;
	   uint public  MINIMUM_SALE = 1*1e18 ;
     uint public  MAXIMUM_SALE = 10*1e18 ;
	 uint public sale_status = 0;
   
    constructor(address payable ownerAddress,IERC20 _MTZ,IERC20 _BUSD) public
    {
        owner = ownerAddress;  
        MTZ = _MTZ;
        BUSD=_BUSD;
    }
    
    function BuyToken(uint256 tokenQty) public payable
	{
		require(tokenQty>=MINIMUM_BUY,"Invalid minimum quatity");
		require(tokenQty<=MAXIMUM_BUY,"Invalid maximum quatity");
        require(MTZ.balanceOf(address(this))>=tokenQty,"Low Token Balance In Contract");
        uint256 BUSD_amt=(tokenQty*token_price)/1e18;   
        require(BUSD_amt>0,"Invalid buy amount");
        require(BUSD.balanceOf(msg.sender)>=BUSD_amt,"Low BUSD Balance In Wallet");
		BUSD.transferFrom(msg.sender,address(this), BUSD_amt);
		MTZ.transfer(msg.sender , tokenQty);
 
	}
    
	function sellToken(uint256 tokenQty) public payable 
	{
			require(sale_status>=1,"Sale Not Allow");
	        require(tokenQty>=MINIMUM_SALE,"Invalid minimum quatity");
	        require(tokenQty<=MAXIMUM_SALE,"Invalid maximum quatity");
	     	require(MTZ.balanceOf(msg.sender)>=tokenQty,"Low Token Balance");
			uint BUSD_amt=(tokenQty*token_price)/1e18;   
            require(BUSD.balanceOf(address(this))>=BUSD_amt,"Low BUSD Balance In Contract");
			MTZ.transferFrom(msg.sender ,address(this), tokenQty);
			BUSD.transfer(msg.sender ,BUSD_amt);
			
			
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
        owner.transfer(WithAmt*1e18);
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