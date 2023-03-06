/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

pragma solidity 0.5.4;
contract Initializable {

  bool private initialized;
  bool private initializing;

  modifier initializer() 
  {
	  require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");
	  bool wasInitializing = initializing;
	  initializing = true;
	  initialized = true;
		_;
	  initializing = wasInitializing;
  }
  function isConstructor() private view returns (bool) 
  {
  uint256 cs;
  assembly { cs := extcodesize(address) }
  return cs == 0;
  }
  uint256[50] private __gap;

}

contract Ownable is Initializable {
  address public _owner;
  uint256 private _ownershipLocked;
  event OwnershipLocked(address lockedOwner);
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
  address indexed previousOwner,
  address indexed newOwner
	);
  function initialize(address sender) internal initializer {
   _owner = sender;
   _ownershipLocked = 0;

  }
  function ownerr() public view returns(address) {
   return _owner;

  }

  modifier onlyOwner() {
    require(isOwner());
    _;

  }

  function isOwner() public view returns(bool) {
  return msg.sender == _owner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
   _transferOwnership(newOwner);

  }
  function _transferOwnership(address newOwner) internal {
    require(_ownershipLocked == 0);
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;

  }

  // Set _ownershipLocked flag to lock contract owner forever

  function lockOwnership() public onlyOwner {
    require(_ownershipLocked == 0);
    emit OwnershipLocked(_owner);
    _ownershipLocked = 1;
  }

  uint256[50] private __gap;

}

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
   
contract DEX_SWAP is Ownable {
  using SafeMath for uint256;
    address public owner;
    event buyToken(string userAddress, string member_user_id, uint256 total_token,string tr_type);
 
   IBEP20 private BUSD; 
   IBEP20 private USD; 
   event onBuy(address buyer , uint256 amount);

    constructor(address ownerAddress,IBEP20 _BUSD,IBEP20 _USD) public 
    {
                 
        owner = ownerAddress;
        BUSD = _BUSD;
        USD=_USD;
        Ownable.initialize(msg.sender);
    }
 
    function withdrawLostBNBFromBalance() public 
    {
        require(msg.sender == owner, "onlyOwner");
        msg.sender.transfer(address(this).balance);
    }
    
	 function SwapWithBNB(string memory userAddress,string memory member_user_id,uint256 totalAmt,string memory swaptype) public payable {
		
		require(msg.value>=totalAmt,"Invalid buy amount");
    address(uint160(owner)).transfer(msg.value);
		emit buyToken(userAddress,member_user_id, msg.value,swaptype);	
	
	}
	 
	 function SwapWithBUSD(string memory userAddress,string memory member_user_id,uint256 busd_amt,string memory swaptype) public payable {
  	
		BUSD.transferFrom(msg.sender,owner,busd_amt);
		emit buyToken(userAddress,member_user_id, busd_amt,swaptype);	
	
	}

  function SwapWithUSD(string memory userAddress,string memory member_user_id,uint256 busd_amt,string memory swaptype) public payable {
  	
		USD.transferFrom(msg.sender,owner,busd_amt);
		emit buyToken(userAddress,member_user_id, busd_amt,swaptype);	
	
	}
	 
   
       
		function withdrawLostTokenFromBalance(uint256 tokenQty) public payable
		{
        require(msg.sender == owner, "onlyOwner");
        BUSD.transfer(owner,tokenQty);
    	}
   
    }