/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: MIT
/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-28
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

contract Global_NFT_Contract{
  event Multisended(uint256 value , address indexed sender);
  event Airdropped(address indexed _userAddress, uint256 _amount);
	event Staking(string  investorId,string time,uint256 investment,address indexed investor);
	event WithDraw(address indexed  investor,uint256 WithAmt);
	event MemberPayment(address indexed  investor,uint netAmt,uint256 Withid);
	event Payment(uint256 NetQty);
  event buypackage(address indexed userwallet,uint256 amountbuy);
  event buyregister(address indexed userwallet,address indexed sender,uint256 amountbuy);
	
    using SafeMath for uint256;
    IBEP20 private BUSD; 
    address public owner;
    address public fee_Wallet;
    mapping(address => Referal_levels) public refer_info;
    mapping(address => User) public user_info;
   
   
      struct User {
          bool referred;
          address referred_by;
      }

      struct Referal_levels {
          uint256 level_1;
          uint256 level_2;
          uint256 level_3;
          uint256 level_4;
          uint256 level_5;
      }

   
    constructor(address ownerAddress, IBEP20 _BUSD, address _fee_Wallet) public   {
        owner = ownerAddress; 
        BUSD = _BUSD;
        fee_Wallet = _fee_Wallet;
    }
    
  function registerandbuy(address _userwallet,uint256 investment,address _refferal) public payable
	{
	   require(BUSD.balanceOf(msg.sender)>=investment);
     require(BUSD.allowance(msg.sender,address(this))>=investment,"Approve Your Token First");
   	 BUSD.transferFrom(msg.sender ,address(this),investment);
     send_refferal_income(_refferal);
		 emit buyregister( _userwallet,msg.sender,investment);
	}

	function Deposit(uint256 investment) public payable
	{
	  require(BUSD.balanceOf(msg.sender)>=investment*1e18);
   	BUSD.transferFrom(msg.sender ,address(this),investment*1e18);
		emit buypackage( msg.sender,investment);
	}


  function send_refferal_income(address ref_add) public {
      
        require(user_info[msg.sender].referred == false, " Already referred ");
        require(ref_add != msg.sender, " You cannot refer yourself ");

        user_info[msg.sender].referred_by = ref_add;
        user_info[msg.sender].referred = true;

        address level1 = user_info[msg.sender].referred_by;
        address level2 = user_info[level1].referred_by;
        address level3 = user_info[level2].referred_by;
        address level4 = user_info[level3].referred_by;
        address level5 = user_info[level4].referred_by;   
       
        if ((level1 != msg.sender) && (level1 != address(0))) {
            refer_info[level1].level_1 += 1;          
	          BUSD.transfer(level1, 22.5 * 1e18);       
        }
        if ((level2 != msg.sender) && (level2 != address(0))) {
            refer_info[level2].level_2 += 1;
	          BUSD.transfer(level2, 10.25 * 1e18);                 
        }
        if ((level3 != msg.sender) && (level3 != address(0))) {
            refer_info[level3].level_3 += 1;           
	          BUSD.transfer(level3, 5 * 1e18);                                    
        }
        if ((level4 != msg.sender) && (level4 != address(0))) {
            refer_info[level4].level_4 += 1;          
	          BUSD.transfer(level4, 4.75 * 1e18);  
        }
        if((level5 != msg.sender) && (level5 != address(0))){
           refer_info[level5].level_5 += 1;         
	         BUSD.transfer(level5, 4.75 * 1e18);                 
        } 

        BUSD.transfer(fee_Wallet, 2.75 * 1e18);
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