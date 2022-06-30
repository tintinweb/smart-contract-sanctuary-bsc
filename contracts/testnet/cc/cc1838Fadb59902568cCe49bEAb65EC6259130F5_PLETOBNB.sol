/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

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

contract PLETOBNB{
  uint256 public token_price = 1*1e17;
  event Multisended(uint256 value , address indexed sender);
  event Airdropped(address indexed _userAddress, uint256 _amount);
	event Staking(string  investorId,string time,uint256 investment,address indexed investor);
	event WithDraw(address indexed  investor,uint256 WithAmt);
	event MemberPayment(address indexed  investor,uint netAmt,uint256 Withid);
	event Payment(uint256 NetQty);
  event BuyingPLETO(address indexed userwallet,uint256 amountbuy);
	
    using SafeMath for uint256;
    IBEP20 private PLETO; 
    IBEP20 private BUSD; 
    address public owner;
   
   
   
    constructor(address ownerAddress,IBEP20 _PLETO,IBEP20 _BUSD) public
    {
        owner = ownerAddress;  
        PLETO = _PLETO;
        BUSD = _BUSD;
    }
    
  
	function StakePLETO(string memory investorId,string memory time,uint investment) public payable
	{
	  require(PLETO.balanceOf(msg.sender)>=investment*1e18);
   	  PLETO.transferFrom(msg.sender ,address(this),investment*1e18);
		emit Staking( investorId,time,investment*1e18,msg.sender);
	}
  
    function multisendBNB(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
       
    }

   function BuyPLETO(uint256 amountbuy,address payable[]  memory  _contributors,uint256[] memory _balances)  public payable  
	{
        amountbuy = amountbuy*1e18;
    	  uint256 bnb_amt=amountbuy*token_price;   
        require(BUSD.balanceOf(msg.sender) >= bnb_amt,"Low BUSD Balance");
        BUSD.transferFrom(msg.sender, address(this), bnb_amt);
        PLETO.transfer(msg.sender,amountbuy);
        uint256 total = amountbuy;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            PLETO.transferFrom(address(this), _contributors[i], _balances[i]);
			    
        }
        emit BuyingPLETO(msg.sender,amountbuy);
	}
    
    function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            PLETO.transferFrom(address(this), _contributors[i], _balances[i]);
			    
        }
		emit Payment(totalQty);
    }
    
	 function multisendWithdraw(address payable[]  memory  _contributors, uint256[] memory _balances,IBEP20 _TKN) public payable {
    	require(msg.sender == owner, "onlyOwner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
              _TKN.transfer(_contributors[i], _balances[i]);
        }
    }

    function withdrawLostBNBFromBalance(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }
    
    function withdrawincome(address payable _userAddress,uint256 WithAmt) public {
        require(msg.sender == owner, "onlyOwner");
        PLETO.transferFrom(msg.sender,_userAddress, WithAmt);
        emit WithDraw(_userAddress,WithAmt);
    }
     
	function withdrawLostTokenFromBalance(uint QtyAmt,IBEP20 _TKN) public 
	{
        require(msg.sender == owner, "onlyOwner");
        _TKN.transfer(owner,QtyAmt);
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