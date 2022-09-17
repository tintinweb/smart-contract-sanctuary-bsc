/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-29
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

contract American_Bull_SWAP{
  
     using SafeMath for uint256;

    struct User
    {
        uint256 id;
        address referreral;
        uint256 totalBuy;
        uint256 totalIncome;
    }

    IERC20 private ABT; 
    IERC20 private BUSD;
    address payable public owner;
    uint public token_price = 1*1e16;    //0.01
    uint public  MINIMUM_BUY = 100*1e18 ;
     uint public  MAXIMUM_BUY = 10000*1e18 ;
	   uint public  MINIMUM_SALE = 100*1e18 ;
     uint public  MAXIMUM_SALE = 10000*1e18 ;
     uint256 public  totalSale=0;
	   uint public sale_status = 0;
     uint refPer=10;

    mapping(address => address[]) public referrals;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    uint public lastUserId = 2;

    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
    event tokenBuy(address indexed user,address indexed referrer,uint256 token_price,uint256 tokenQty,uint256 busdAmt);
    event UserIncome(address indexed user,address indexed incomeFrom,uint256 incomeAmt);
   
    constructor(address payable ownerAddress,IERC20 _ABT,IERC20 _BUSD) public
    {
        owner = ownerAddress;  
        ABT = _ABT;
        BUSD=_BUSD;

           User memory user = User({
            id: 1,
            referreral: address(0),
            totalBuy:uint(0),
            totalIncome:uint256(0)
           });

        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
    }
    
    function BuyToken(uint256 tokenQty,address referrer) public payable
	{
        if(!isUserExists(msg.sender))
	    {
	        registration(msg.sender, referrer);   
	    }
        require(isUserExists(referrer),"Referral Not Exist");
		require(tokenQty>=MINIMUM_BUY,"Invalid minimum quatity");
		require(tokenQty<=MAXIMUM_BUY,"Invalid maximum quatity");
        require(ABT.balanceOf(address(this))>=tokenQty,"Low Token Balance In Contract");
        uint256 BUSD_amt=(tokenQty*token_price)/1e18;   
        uint256 refAmt=BUSD_amt*refPer/100;
        uint256 ownerAmt=BUSD_amt-refAmt;
        require(BUSD_amt>0,"Invalid buy amount");
        require(BUSD.balanceOf(msg.sender)>=BUSD_amt,"Low BUSD Balance In Wallet");
		BUSD.transferFrom(msg.sender,owner, ownerAmt);
		ABT.transfer(msg.sender , tokenQty);
        emit tokenBuy(msg.sender, referrer,token_price,tokenQty,BUSD_amt);
        users[address(uint(msg.value))].totalBuy+=tokenQty;
        totalSale+=tokenQty;
        if(refAmt>0)
        {
            BUSD.transferFrom(msg.sender,referrer , refAmt);
            emit UserIncome(referrer,msg.sender,refAmt);
            users[referrer].totalIncome+=refAmt;
        }

	}
    
 function registration(address userAddress, address referrerAddress) private 
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referreral: referrerAddress,
            totalBuy: uint(0),
            totalIncome:uint(0)
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referreral = referrerAddress;
        referrals[referrerAddress].push(userAddress);
        lastUserId++;
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
	
	
         
    function isUserExists(address user) public view returns (bool) 
    {
        return (users[user].id != 0);
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
          function refPEr_setting(uint256 _refPer) public payable
        {
           require(msg.sender==owner,"Only Owner");
            refPer=_refPer;
			
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