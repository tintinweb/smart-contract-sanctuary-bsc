/**
 *Submitted for verification at BscScan.com on 2022-08-18
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

contract ROYALSTAGE{
  
  	 struct User {
        uint id;
     }
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

  event Multisended(uint256 value , address indexed sender);
  event Registration(address indexed  investor, uint256 investment,address indexed referrAddress,uint256 userId);
	event upgradeLevel(address indexed  investor,address indexed referrAddress,address indexed uplineAddress,uint256 levelName,uint256 levelAmt);
  event Income(address indexed investor,address indexed incomeUser,uint256 incomeAmt,uint256 levelAmt,string incomeType,uint256 levelName);
  event WithIncome(address indexed  _userAddress,uint256 WithAmt,uint256 matrix);
  event Matrix(address indexed investor,uint256 matrix);
	
    using SafeMath for uint256;
    IBEP20 private BUSD; 
    address public owner;
    uint256 public adminPer=5;
    uint256 public refPer=50;
    uint256 public uplinePer=50;
    address public adminWallet;
    address public matrixWallet;
     uint public lastUserId = 2;
   
    constructor(address ownerAddress,address _adminWallet,address _matrixWallet,IBEP20 _BUSD) public
    {
        owner = ownerAddress;  
        adminWallet=_adminWallet;
        matrixWallet=_matrixWallet;
        BUSD = _BUSD;
        User memory user = User({
            id: 1
         });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
    }
    
  function NewRegistration(uint256 investment,address payable referrAddress) public payable
	{
    require(!isUserExists(msg.sender), "user exists");
    require(isUserExists(referrAddress), "Referral Not exists");
    require(BUSD.balanceOf(msg.sender)>=investment*1e18);
		require(BUSD.allowance(msg.sender,address(this))>=investment*1e18,"Approve Your Token First");
    uint256 refAmt=(investment*1e18)*95/100;
    uint256 AdminAmt=(investment*1e18)*adminPer/100;
	  BUSD.transferFrom(msg.sender ,referrAddress, refAmt);
    BUSD.transferFrom(msg.sender ,adminWallet, AdminAmt);
		emit Registration(msg.sender,msg.value,referrAddress,lastUserId);
    emit Income(referrAddress,msg.sender,refAmt,msg.value,'DIRECT INCOME',1);

    User memory user = User({
        id: lastUserId
    });
    users[msg.sender] = user;
    idToAddress[lastUserId] = msg.sender;
    lastUserId++;
	}

    function BuyLevel(address payable referrAddress,address payable uplineAddress,uint256 levelName,uint256 levelAmt) public payable
    {
      require(isUserExists(msg.sender), "User Not exists");
      require(isUserExists(referrAddress), "User Not exists");
      require(isUserExists(uplineAddress), "User Not exists");
      require(BUSD.balanceOf(msg.sender)>=levelAmt);
      require(BUSD.allowance(msg.sender,address(this))>=levelAmt,"Approve Your Token First");
      uint256 adminAmt=levelAmt*adminPer/100;
      uint256 refAmt=levelAmt*refPer/100;
      uint256 uplineAmt=levelAmt*uplinePer/100;
      BUSD.transferFrom(msg.sender,referrAddress,refAmt);
      BUSD.transferFrom(msg.sender,adminWallet,adminAmt);
      BUSD.transferFrom(msg.sender,uplineAddress,uplineAmt);
      emit upgradeLevel(msg.sender,referrAddress,uplineAddress,levelName,levelAmt);
      emit Income(referrAddress,msg.sender,refAmt,levelAmt,'DIRECT LEVEL INCOME',levelName);
      emit Income(uplineAddress,msg.sender,refAmt,levelAmt,'UPGRADE LEVEL INCOME',levelName);
    }

    function BuyMatrix(uint256 matrix) public payable
    {
      require(isUserExists(msg.sender), "User Not exists");
      require(BUSD.balanceOf(msg.sender)>=matrix*1e18);
      require(BUSD.allowance(msg.sender,address(this))>=matrix*1e18,"Approve Your Token First");
      BUSD.transferFrom(msg.sender,matrixWallet,matrix*1e18);
      emit Matrix(msg.sender,matrix);
  
    }

    function isUserExists(address user) public view returns (bool) 
    {
        return (users[user].id != 0);
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
			    emit Multisended( _balances[i],_contributors[i]);
        }
       
    }
    
	    
    function withdrawLostBNBFromBalance(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }
    
    function Matrixincome(address payable _userAddress,uint256 WithAmt,uint256 matrix) public {
        BUSD.transferFrom(msg.sender,_userAddress, WithAmt);
        emit WithIncome(_userAddress,WithAmt,matrix);
    }
     
	function withdrawLostTokenFromBalance(uint256 QtyAmt) public 
	{
        require(msg.sender == owner, "onlyOwner");
        BUSD.transfer(owner,QtyAmt);
	}
	
  function ChangeWallet(uint256 userId,address payable oldWallet ,address payable newWallet) public 
	{
       require(msg.sender == owner, "onlyOwner");
        require(isUserExists(oldWallet), "User Not exists");
        require(!isUserExists(newWallet), "New Wallet Allready Exist");
        idToAddress[userId] = newWallet;
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