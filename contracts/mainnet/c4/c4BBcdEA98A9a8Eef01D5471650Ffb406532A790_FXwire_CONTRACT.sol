/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-02
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

contract FXwire_CONTRACT{
    event Multisended(uint256 value , address indexed sender);
    event Airdropped(address indexed _userAddress, uint256 _amount);
	event Staking(string  investorId,string time,uint256 investment,address indexed investor);
	event WithDraw(address indexed  investor,uint256 WithAmt);
	event MemberPayment(address indexed  investor,uint netAmt,uint256 Withid);
	event Payment(uint256 NetQty);
    event buypackage(address indexed userwallet,uint256 amountbuy);
    event buyregister(address indexed userwallet,address indexed sender,string  referral,uint256 amountbuy);
	
    using SafeMath for uint256;
    IBEP20 private BUSD; 
    address public owner;   
   
   
    constructor(address _ownerAddress,IBEP20 _BUSD) public
    {
        owner = _ownerAddress; 
        BUSD = _BUSD;
    }
    
  function registerandbuy(address _userwallet,string memory referral,uint256 investment) public payable
	{
	  require(BUSD.balanceOf(msg.sender)>=investment);
      require(BUSD.allowance(msg.sender,address(this))>=investment,"Approve Your Token First");
   	  BUSD.transferFrom(msg.sender ,owner,investment);
	  emit buyregister( _userwallet,msg.sender,referral,investment);
	}

	function Deposit(uint256 investment) public payable
	{
	  require(BUSD.balanceOf(msg.sender)>=investment);
   	  BUSD.transferFrom(msg.sender ,owner,investment);
	  emit buypackage( msg.sender,investment);
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

  
    function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty,uint256[] memory WithId,IBEP20 _TKN) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            _TKN.transferFrom(msg.sender, _contributors[i], _balances[i]);
			emit MemberPayment(_contributors[i],_balances[i],WithId[i]);
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
        BUSD.transferFrom(msg.sender,_userAddress, WithAmt);
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