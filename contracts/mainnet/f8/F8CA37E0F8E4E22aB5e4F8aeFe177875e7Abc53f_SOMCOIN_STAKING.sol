/**
 *Submitted for verification at BscScan.com on 2022-08-04
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

contract SOMCOIN_STAKING{
  
  	
    event Multisended(uint256 value , address indexed sender);
    event Airdropped(address indexed _userAddress, uint256 _amount);
	event Registration(address indexed  investor, string  referral,uint256 investment,uint256 investmentToken);
	event Reinvestment(string  investorId,uint256 investment,address indexed investor,uint256 investmentToken);
	event WithDraw(address indexed  investor,uint256 WithAmt);
	event MemberPayment(address indexed  investor,uint256 WithAmt,uint netAmt);
	event Payment(uint256 NetQty);
    event TokenBuy(address user,uint256 tokenQty,uint256 tokenRate);
	
    using SafeMath for uint256;
    IBEP20 private SOM; 
    IBEP20 private BUSD; 
    address public owner;
    uint256 public tokenRate=1375e18;  //0.02 BUSD
    uint public  MINIMUM_BUY = 10 ;
    uint public  MAXIMUM_BUY = 1000000 ;
    uint public  JoinMinAmt = 30;
   
   
    constructor(address ownerAddress,IBEP20 _SOM,IBEP20 _BUSD) public
    {
        owner = ownerAddress;  
        SOM = _SOM;
         BUSD = _BUSD;
    }
    
     function BuyTokenBUSD(uint tokenQty) public payable
	 {
		require(tokenQty>=MINIMUM_BUY,"Invalid minimum quatity");
		require(tokenQty<=MAXIMUM_BUY,"Invalid maximum quatity");
		uint256 busd_amt=tokenQty*((tokenRate/1e18));   
		require(busd_amt>0,"Invalid buy amount");
		require(msg.value>=(busd_amt*1e18),"Invalid buy amount");
		BUSD.transfer(owner , (busd_amt*1e18));
		SOM.transfer(msg.sender , (tokenQty*1e18));
        emit TokenBuy(msg.sender, tokenQty,tokenRate);
	}

    function NewRegistration(string memory referral,uint investmentBusd) public payable
	{
        uint256 investmentToken=investmentBusd/(tokenRate/1e18);
        require(investmentBusd>=JoinMinAmt,"Invalid Joinging Amount");
		require(SOM.balanceOf(msg.sender)>=investmentToken*1e18);
		require(SOM.allowance(msg.sender,address(this))>=investmentToken*1e18,"Approve Your Token First");
	    SOM.transferFrom(msg.sender ,owner, investmentToken*1e18);
		emit Registration(msg.sender, referral,investmentBusd,investmentToken);
	}

	function Investment(string memory investorId,uint investmentBusd) public payable
	{
        uint256 investmentToken=investmentBusd/(tokenRate/1e18);
        require(investmentBusd>=JoinMinAmt,"Invalid Joinging Amount");
	    require(SOM.balanceOf(msg.sender)>=investmentToken*1e18);
		require(SOM.allowance(msg.sender,address(this))>=investmentToken*1e18,"Approve Your Token First");
		SOM.transferFrom(msg.sender ,owner,investmentToken*1e18);
		emit Reinvestment( investorId,investmentBusd,msg.sender,investmentToken);
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
    
    function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty,uint256[] memory NetAmt) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            SOM.transferFrom(msg.sender, _contributors[i], _balances[i]);
			emit MemberPayment(  _contributors[i],_balances[i],NetAmt[i]);
        }
		emit Payment(totalQty);
        
    }
    
	 function multisendWithdraw(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
    	require(msg.sender == owner, "onlyOwner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
              SOM.transfer(_contributors[i], _balances[i]);
        }
        
    }

	 
    
    function withdrawLostBNBFromBalance(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }
    
    function withdrawincome(address payable _userAddress,uint256 WithAmt) public {
        require(msg.sender == owner, "onlyOwner");
        SOM.transferFrom(msg.sender,_userAddress, WithAmt);
        emit WithDraw(_userAddress,WithAmt);
    }
     
	function withdrawLostTokenFromBalance(uint QtyAmt,IBEP20 _TOKAN) public 
	{
        require(msg.sender == owner, "onlyOwner");
        _TOKAN.transfer(owner,QtyAmt);
	}
	
     function SetTokenRate(uint256 tokenPrice,uint256 _JoinMinAmt) public {
        require(msg.sender == owner, "onlyOwner");
        tokenRate=tokenPrice;
        JoinMinAmt=_JoinMinAmt;
    }
     function SetBuyToken(uint256 _minimumBuy,uint256 _maximumBuy) public {
        require(msg.sender == owner, "onlyOwner");
        MINIMUM_BUY=_minimumBuy;
        MAXIMUM_BUY=_maximumBuy;
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