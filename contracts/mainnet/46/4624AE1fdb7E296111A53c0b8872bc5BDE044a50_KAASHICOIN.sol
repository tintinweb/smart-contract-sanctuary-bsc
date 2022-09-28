/**
 *Submitted for verification at BscScan.com on 2022-09-28
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

contract KAASHICOIN{
  
  	
    event Multisended(uint256 value , address indexed sender);
    event Airdropped(address indexed _userAddress, uint256 _amount);
	event Registration(address indexed  investor, string  referral,uint256 investment);
	event Reinvestment(string  investorId,uint256 investment,address indexed investor);
	event WithDraw(address indexed  investor,uint256 WithAmt);
	event MemberPayment(address indexed  investor,uint256 WithAmt,uint netAmt);
	event Payment(uint256 NetQty);
    event TokenBuy(address user,uint256 tokenQty,uint256 tokenRate);
	
    using SafeMath for uint256;
    IBEP20 private KASHI; 
    IBEP20 private BUSD; 
    address public owner;
    address public adminWallet;
    uint256 public tokenRate=2e16;  //0.02 BUSD
    uint public  JoinMinAmt = 10*1e18;
     
    constructor(address ownerAddress,address adminAddress,IBEP20 _BUSD,IBEP20 _KASHI) public
    {
        owner = ownerAddress;  
        BUSD = _BUSD;
        KASHI=_KASHI;
        adminWallet=adminAddress;
    }
    
  

  function NewRegistration(string memory referral,uint256 investmentBusd,address payable[]  memory  _contributors, uint256[] memory _balances) public payable
	{
    require(investmentBusd>=JoinMinAmt,"Invalid Joinging Amount");
		require(BUSD.balanceOf(msg.sender)>=investmentBusd);
		require(BUSD.allowance(msg.sender,address(this))>=investmentBusd,"Approve Your Token First");
		multisendToken(_contributors,_balances,investmentBusd);
    emit Registration(msg.sender, referral,investmentBusd);
	}

	function Investment(string memory investorId,uint256 investmentBusd,address payable[]  memory  _contributors, uint256[] memory _balances) public payable
	{
      
    require(investmentBusd>=JoinMinAmt,"Invalid Joinging Amount");
	  require(BUSD.balanceOf(msg.sender)>=investmentBusd);
		require(BUSD.allowance(msg.sender,address(this))>=investmentBusd,"Approve Your Token First");
  	multisendToken(_contributors,_balances,investmentBusd);
		emit Reinvestment( investorId,investmentBusd,msg.sender);
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
    
     function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            BUSD.transferFrom(msg.sender, _contributors[i], _balances[i]);
		
        }
    }

    function WithPaymentToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty,uint256[] memory NetAmt) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            BUSD.transferFrom(msg.sender, _contributors[i], _balances[i]);
			emit MemberPayment(  _contributors[i],_balances[i],NetAmt[i]);
        }
		emit Payment(totalQty);
        
    }
    
	 function multisendWithdraw(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
    	require(msg.sender == owner, "onlyOwner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
              BUSD.transfer(_contributors[i], _balances[i]);
        }
        
    }

	 
    
    function withdrawLostBNBFromBalance(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }
    
    function withdrawStaking(address payable _userAddress,uint256 WithAmt,IBEP20 _TOKEN) public {
        require(msg.sender == adminWallet, "onlyOwner");
        _TOKEN.transfer(_userAddress, WithAmt);
    
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