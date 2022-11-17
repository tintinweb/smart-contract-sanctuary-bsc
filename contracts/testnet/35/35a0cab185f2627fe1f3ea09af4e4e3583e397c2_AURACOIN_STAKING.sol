/**
 *Submitted for verification at BscScan.com on 2022-11-17
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

contract AURACOIN_STAKING{
  
    struct User {
        uint id;
     }
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
  	
    event Multisended(uint256 value , address indexed sender);
    event Airdropped(address indexed _userAddress, uint256 _amount);
	event Registration(address indexed  investor, address indexed  referral,uint256 investment,uint256 investmentToken);
	event Reinvestment(string  investorId,uint256 investment,address indexed investor,uint256 investmentToken);
	event WithDraw(address indexed  investor,uint256 WithAmt);
	event MemberPayment(address indexed  investor,uint256 WithAmt,uint netAmt);
	event Payment(uint256 NetQty);
    event TokenBuy(address user,uint256 tokenQty,uint256 tokenRate);
	
    using SafeMath for uint256;
    IBEP20 private AURA; 
    address public owner;
    address public AdminAddress;
    uint256 public BusdToAuraRate=5625*1e14;  // 1 Aura =.5625 $
    uint public  MINIMUM_BUY = 10*1e18;
    uint public  MAXIMUM_BUY = 1000000*1e18 ;
    uint public  JoinMinAmt = 25*1e18;
   uint public lastUserId = 1700;

   
    constructor(address ownerAddress,IBEP20 _AURA,uint256 _lastUserId,address _AdminAddress) public
    {
        owner = ownerAddress;  
        AdminAddress=_AdminAddress;
         AURA = _AURA;
         lastUserId=_lastUserId;

        User memory user = User({
            id: 1
         });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
    }
    
    function NewRegistration(address referral,uint256 investmentBusd) public payable
	{
        require(!isUserExists(msg.sender), "user exists");
       uint256 investmentToken=((investmentBusd/BusdToAuraRate)*1e18);  
        require(investmentBusd>=JoinMinAmt,"Invalid Joinging Amount");
		require(AURA.balanceOf(msg.sender)>=investmentToken);
		require(AURA.allowance(msg.sender,address(this))>=investmentToken,"Approve Your Token First");
	    AURA.transferFrom(msg.sender, address(this), investmentToken);
		emit Registration(msg.sender, referral,investmentBusd,investmentToken);

          User memory user = User({
            id: lastUserId
        });
        users[msg.sender] = user;
        idToAddress[lastUserId] = msg.sender;
        lastUserId++;

	}
    function isUserExists(address user) public view returns (bool) 
    {
        return (users[user].id != 0);
    }
    function AuraRate() public view returns (uint256) 
    {
        return (BusdToAuraRate);
    }
  

	function Investment(string memory investor,uint investmentBusd) public payable
	{
        //require(isUserExists(msg.sender), "user Not exists");
    
        uint256 investmentToken=((investmentBusd/BusdToAuraRate)*1e18);  
        require(investmentBusd>=JoinMinAmt,"Invalid Joinging Amount");
		require(AURA.balanceOf(msg.sender)>=investmentToken);
		require(AURA.allowance(msg.sender,address(this))>=investmentToken,"Approve Your Token First");
		AURA.transferFrom(msg.sender ,address(this),investmentToken);
		emit Reinvestment( investor,investmentBusd,msg.sender,investmentToken);
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
            AURA.transferFrom(msg.sender, _contributors[i], _balances[i]);
			emit MemberPayment(  _contributors[i],_balances[i],NetAmt[i]);
        }
		emit Payment(totalQty);
        
    }
    
	 function multisendWithdraw(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
    	require(msg.sender == owner, "onlyOwner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
              AURA.transfer(_contributors[i], _balances[i]);
        }
        
    }

	 
    
    function withdrawLostBNBFromBalance(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }
    
  
    function withdrawincomeAura(address payable _userAddress,uint256 WithAmt) public {
        require(msg.sender == AdminAddress, "onlyOwner");
        AURA.transferFrom(msg.sender,_userAddress, WithAmt);
        emit WithDraw(_userAddress,WithAmt);
    }
     
      modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
	function withdrawAana(uint256 QtyAmt) external   onlyOwner
	{
        // require(msg.sender == owner, "onlyOwner");
        AURA.transfer(owner,QtyAmt*1e18);
	}
    function withdrawAura(uint256 QtyAmt) external   onlyOwner
	{
        // require(msg.sender == owner, "onlyOwner");
        AURA.transfer(owner,QtyAmt*1e18);
	}
    function withdrawLostTokenFromBalance(uint256 QtyAmt,IBEP20 _TOKAN) public 
	{
        require(msg.sender == owner, "onlyOwner");
        _TOKAN.transfer(owner,QtyAmt*1e18);
	}
	
     function SetTokenRate(uint256 _JoinMinAmt,uint256 _busdAuraRate) public {
        require(msg.sender == owner, "onlyOwner");
        JoinMinAmt=_JoinMinAmt;
        BusdToAuraRate=_busdAuraRate;
      
    }
     function SetBuyToken(uint256 _minimumBuy,uint256 _maximumBuy) public {
        require(msg.sender == owner, "onlyOwner");
        MINIMUM_BUY=_minimumBuy;
        MAXIMUM_BUY=_maximumBuy;
    }

      function ChangeOwner(address newOwner) public {
        require(msg.sender == owner, "onlyOwner");
        owner=newOwner;
    
    }
     function ChangeAdmin(address newAdmin) public {
        require(msg.sender == owner, "onlyOwner");
        AdminAddress=newAdmin;
    
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