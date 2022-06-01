/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/Trade.sol


pragma solidity ^0.8.7;

library SafeMath {
  
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

  
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

   
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

   
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

   
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}


contract BusdRocket  is Ownable{
    using SafeMath for uint256;
	IERC20 public token; // BUSD

	
	uint256 private EGGS_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day
	uint256 private PSN = 10000;
	uint256 private PSNH = 5000;
	uint256 private devFeeVal = 3;
	uint private withdrawnFee = 3;
	bool private initialized = false;
	address payable public devAddress;
	address payable public marketingAddress;
	address payable public marketingAddressTwo;
	address payable public marketingAddressThree;
	
	uint256 public marketEggs;

	struct User{
		uint256 invest;
		uint256 withdraw;
		uint256 hatcheryMiners;
		uint256 claimedEggs;
		uint256 lastHatch;
		uint checkpoint;
		address referrals;
	}

	mapping (address => User) public users;


	uint public totalInvested;
	uint256 constant internal TIME_STEP = 1 days;

	constructor(address _dev, address _mark, address _markTwo, address _markThree, address _token) payable { 
		devAddress = payable(_dev);
		marketingAddress = payable(_mark);
		marketingAddressTwo = payable(_markTwo);
		marketingAddressThree = payable(_markThree);
		token = IERC20(_token);
	}

	 modifier initializer() {
		require(initialized, "initialized is false");
		_;
	 }

	modifier checkUser_() {
		require(checkUser(), "try again later");
		_;
	}

	function checkUser() public view returns (bool){
		uint256 check = block.timestamp.sub(users[msg.sender].checkpoint);
		if(check > TIME_STEP) {
			return true;
		}
		return false;
	}


	function hatchEggs(address ref) public initializer {		
		
		if(ref == msg.sender) {
			ref = address(0);
		}
		
		User storage user = users[msg.sender];
		if(user.referrals == address(0) && user.referrals != msg.sender) {
			user.referrals = ref;
		}
		
		uint256 eggsUsed = getMyEggs(msg.sender);
		uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
		user.hatcheryMiners = SafeMath.add(user.hatcheryMiners,newMiners);
		user.claimedEggs = 0;
		user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		
		//send referral eggs
		User storage referrals_ =users[user.referrals];
		referrals_.claimedEggs = SafeMath.add(referrals_.claimedEggs,SafeMath.div(eggsUsed,10));
		
		//boost market to nerf miners hoarding
		marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
	}
	
	function sellEggs() external initializer checkUser_ {
		User storage user =users[msg.sender];
		uint256 hasEggs = getMyEggs(msg.sender);
		uint256 eggValue = calculateEggSell(hasEggs);

		uint256 fee;

		user.claimedEggs = 0;
		user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		marketEggs = SafeMath.add(marketEggs,hasEggs);

		if(msg.sender != devAddress && msg.sender != marketingAddress){
			fee = withdrawFee(eggValue);
			payFees(2, fee);
		}
		
		user.withdraw += eggValue;
		//payable (msg.sender).transfer(SafeMath.sub(eggValue,fee));
		token.transfer(msg.sender, SafeMath.sub(eggValue,fee));
	}

	function beanRewards(address adr) public view returns(uint256) {
		uint256 hasEggs = getMyEggs(adr);
		uint256 eggValue = calculateEggSell(hasEggs);
		return eggValue;
	}
	
	function buyEggs(address ref, uint amount) external initializer {		
		User storage user =users[msg.sender];

		token.transferFrom(msg.sender, address(this), amount);
		//uint256 eggsBought = calculateEggBuy(amount,SafeMath.sub(address(this).balance,amount));
		uint256 eggsBought = calculateEggBuy(amount,SafeMath.sub(getBalance(),amount));

		if(msg.sender != devAddress && msg.sender != marketingAddress){
			eggsBought = SafeMath.sub(eggsBought,devFee(eggsBought));
			uint256 fee = devFee(amount);
			payFees(1, fee);
		}
		
		if(user.invest == 0) {
			user.checkpoint = block.timestamp;
		}
		user.invest += amount;
		user.claimedEggs = SafeMath.add(user.claimedEggs,eggsBought);
		hatchEggs(ref);
		totalInvested += amount;
	}
	
	function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
		uint a =PSN.mul(bs);
		uint b =PSNH;

		uint c =PSN.mul(rs);
		uint d =PSNH.mul(rt);

		uint h =c.add(d).div(rt);
		
		return a.div(b.add(h));
	}
	
	function calculateEggSell(uint256 eggs) public view returns(uint256) {
		//uint _cal = calculateTrade(eggs,marketEggs,address(this).balance);
		uint _cal = calculateTrade(eggs,marketEggs,getBalance());
		_cal += _cal.mul(5).div(100);
		return _cal;
	}
	
	function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
		return calculateTrade(eth,contractBalance,marketEggs);
	}
	
	function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
		//return calculateEggBuy(eth,address(this).balance);
		return calculateEggBuy(eth,getBalance());
	}
	
	function devFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,devFeeVal),100);
	}

	function withdrawFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,withdrawnFee),100);
	}
	
	function seedMarket() public payable onlyOwner {
		require(marketEggs == 0);
		initialized = true;
		marketEggs = 108000000000;
	}
	
	function getBalance() public view returns(uint256) {
		//return address(this).balance;
		return token.balanceOf(address(this));
	}
	
	function getMyMiners(address adr) public view returns(uint256) {
		User memory user =users[adr];
		return user.hatcheryMiners;
	}
	
	function getMyEggs(address adr) public view returns(uint256) {
		User memory user =users[adr];
		return SafeMath.add(user.claimedEggs,getEggsSinceLastHatch(adr));
	}
	
	function getEggsSinceLastHatch(address adr) public view returns(uint256) {
		User memory user =users[adr];
		uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,user.lastHatch));
		return SafeMath.mul(secondsPassed,user.hatcheryMiners);
	}
	
	function min(uint256 a, uint256 b) private pure returns (uint256) {
		return a < b ? a : b;
	}

	function getSellEggs(address user_) public view returns(uint eggValue){
		uint256 hasEggs = getMyEggs(user_);
		eggValue = calculateEggSell(hasEggs);
		
	}

	function getPublicData() external view returns(uint _totalInvest, uint _balance) {
		_totalInvest = totalInvested;
		//_balance = address(this).balance;
		_balance = token.balanceOf(address(this));
	}


	function userData(address user_) external view returns (
	uint256 hatcheryMiners_,
	uint256 claimedEggs_,
	uint256 lastHatch_,
	uint256 sellEggs_,
	uint256 eggsMiners_,
	address referrals_,
	uint256 checkpoint
	) { 	
	User memory user =users[user_];
	hatcheryMiners_=getMyMiners(user_);
	claimedEggs_=getMyEggs(user_);
	lastHatch_=user.lastHatch;
	referrals_=user.referrals;
	sellEggs_=getSellEggs(user_);
	eggsMiners_=getEggsSinceLastHatch(user_);
	checkpoint=user.checkpoint;
	}

	function payFees(uint8 flag, uint _amount) internal {
		uint toOwners = _amount.div(3);
		token.transfer(devAddress, toOwners);
		token.transfer(marketingAddress, toOwners);

		if(flag == 1){
			token.transfer(marketingAddressTwo, toOwners);
		}
		if(flag == 2){
			token.transfer(marketingAddressThree, toOwners);
		}
		//devAddress.transfer(toOwners);
		//marketingAddress.transfer(toOwners);
	}

	function getDAte() public view returns(uint256) {
		return block.timestamp;
	}

}