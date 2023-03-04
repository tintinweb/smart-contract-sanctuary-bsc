/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

/*
███████  ██████   ██████  ███████     ████████  ██████  ██   ██ ███████ ███    ██ 
   ███  ██    ██ ██    ██    ███         ██    ██    ██ ██  ██  ██      ████   ██ 
  ███   ██    ██ ██    ██   ███          ██    ██    ██ █████   █████   ██ ██  ██ 
 ███    ██    ██ ██    ██  ███           ██    ██    ██ ██  ██  ██      ██  ██ ██ 
███████  ██████   ██████  ███████        ██     ██████  ██   ██ ███████ ██   ████ 
                                                                                                                                                             
WebSite: https://zooz.finance
GitHub: https://github.com/coalichain/ZOOZToken
*/

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

/**
 * @dev PinkAntiBot Interface
 */
interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

/**
 * @dev ZOOZ Token 
 */
contract ZOOZToken is Ownable, IERC20 {
	IPinkAntiBot public pinkAntiBot;
	bool public antiBotEnabled = false;
		
	mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => Holder) internal balances;

	mapping (address => bool) internal pairs;
    mapping (address => mapping (address => bool)) internal botAddresses;
    mapping (address => mapping (address => bool)) internal blockedAddresses;
	
	string public constant NAME = 'ZOOZ Token';
    string public constant SYMBOL = 'ZOOZ';
    uint8 public constant DECIMALS = 9;
	uint256 public constant TOTALSUPPLY = 770 * 10**6 * 10**9;

	address public rewardsAddress = address(0);	
	address public managerAddress = address(0);	
	
	address public governance1Address = address(0);	
	address public governance2Address = address(0);	
	address public governance3Address = address(0);	
	
	event RewardAddressChanged(
        address rewardsAddress
    );	
	
	event ManagerAddressChanged(
        address managerAddress
    );
	
	event GovernanceAddressChanged(
        address governance,
		uint number
    );
	
	event PairAddressAdded(
        address pairAddress
    );
	
	event PairAddressRemoved(
        address pairAddress
    );
	
	event BotAddressAdded(
        address botAddress
	);	
	
	event BotAddressRemoved(
        address botAddress
    );
	
	event AddressBlocked(
        address blockedAddress
    );
	
	event AddressUnblocked(
        address unblockedAddress
    );

	modifier onlyManager() {
        require(managerAddress == _msgSender() || owner() == _msgSender(), "ZOOZ: caller is not allowed");
        _;
    }
	
	modifier onlyGovernance() {
        require(governance1Address == _msgSender() 
				|| governance2Address == _msgSender() 
				|| governance3Address == _msgSender() 
				|| owner() == _msgSender(), "ZOOZ: caller is not allowed");
        _;
    }
	
	struct Holder {
        uint256 token;  
		uint timestamp;
    }
	
	struct HolderView {
		address addr;
        uint256 token;  
		uint timestamp;
    }

	constructor(bool activePinkAntiBot) {
		if(activePinkAntiBot) {
			pinkAntiBot = IPinkAntiBot(0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5);
			pinkAntiBot.setTokenOwner(_msgSender());
		}

		balances[_msgSender()].token = TOTALSUPPLY;
		balances[_msgSender()].timestamp = block.timestamp;
		
		emit Transfer(address(0), _msgSender(), TOTALSUPPLY);
	}
		 
	function totalSupply() public pure override returns (uint256)  {
		return TOTALSUPPLY;
    }
	
	function balanceOf(address account) public view override returns (uint256)  {
		return balances[account].token;
    }
	
	function timestampOf(address account) public view returns (uint256)  {
		return balances[account].timestamp;
    }
	
	function balancesOf(address[] memory accounts) public view returns (HolderView[] memory)  {
		HolderView[] memory tmp = new HolderView[](accounts.length);

        for (uint i = 0; i < accounts.length; i++) {
            tmp[i].token = balances[accounts[i]].token;
            tmp[i].timestamp = balances[accounts[i]].timestamp;
            tmp[i].addr = accounts[i];
        }

        return tmp;
    }
	
	function transfer(address recipient, uint256 amount) public override returns (bool) {
		 _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()] - amount);
        return true;
    }
	
	function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
	function _transfer(address sender, address recipient, uint256 amount) private {
        require(!_isBlockedAddress(sender) && !_isBlockedAddress(recipient), "This address is blocked, contact the governance team");
		
		if (antiBotEnabled)
			pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
		
		bool shouldBeExcludedFromFees = _isItBotAddress(sender) || _isItBotAddress(recipient);
		
		if(!shouldBeExcludedFromFees && pairs[recipient]) {
			uint fees = _getFees(balances[sender].timestamp);
			
			uint256 rewardAmount = amount * fees / 100;
			amount = amount - rewardAmount;

			_stdTransfer(sender, rewardsAddress, rewardAmount);
		}
		
		_holdDateHook(sender, recipient);
		_stdTransfer(sender, recipient, amount);
	}

	/**
	* @dev determine if addr is blocked or not
	*/
	function _isBlockedAddress(address addr) internal view returns(bool) {
		return blockedAddresses[addr][governance1Address] 
				&& blockedAddresses[addr][governance2Address] 
				&& blockedAddresses[addr][governance3Address];
	}

	/**
	* @dev determine if addr is a bot or not
	*/
	function _isItBotAddress(address addr) internal view returns(bool) {
		return botAddresses[addr][governance1Address] 
				&& botAddresses[addr][governance2Address] 
				&& botAddresses[addr][governance3Address];
	}
	 
	/**
     * @dev get fees depending on the hold time
     */
	function _getFees(uint timestamp) internal view returns(uint256) {
		if(timestamp == 0 || timestamp >= block.timestamp) 
			return 14;

		uint diff = block.timestamp - timestamp;

		// 1 Week
		if(diff <= 5 minutes) 
			return 14;

		// 1 Month
		if(diff <= 10 minutes) 
			return 10;		

		// 3 Months
		if(diff <= 15 minutes) 
			return 5;

		// 6 Months
		if(diff <= 20 minutes) 
			return 2;

		// > 6 Months
		return 0; 
	}	

	/**
     * @dev change sender and recipiend timestamp wallet date 
     */
	function _holdDateHook(address sender, address recipient) internal {
		if(balances[recipient].timestamp == 0)
			balances[recipient].timestamp = block.timestamp;
			
		balances[sender].timestamp = block.timestamp;
    }
	
	/**
     * @dev standard erc20 transfer 
     */
	function _stdTransfer(address sender, address recipient, uint256 amount) private {
		if(amount == 0)
			return;
		
		balances[sender].token = balances[sender].token - amount;
		balances[recipient].token = balances[recipient].token + amount;
		
		emit Transfer(sender, recipient, amount);
	}
	
	/**
     * @dev change manager address
     */
	function setManagerAddress(address newAddress) public onlyManager()  {
		require(newAddress != address(0), "Manager Address can't be the zero address");

		managerAddress = newAddress;
		
		emit ManagerAddressChanged(managerAddress);
    }	
	
	/**
     * @dev change rewards address
     */
	function setRewardsTeamAddress(address newAddress) public onlyManager()  {
		require(newAddress != address(0), "Rewards Address can't be the zero address");

		rewardsAddress = newAddress;
		
		emit RewardAddressChanged(rewardsAddress);
    }
	
	/**
     * @dev block or unblock an holder
     */
	function setBlockedAddress(address holderAddress, bool blocked) public onlyGovernance()  {
		require(holderAddress != address(0), "HolderAddress can't be the zero address");
			
        blockedAddresses[holderAddress][_msgSender()] = blocked;
		 		
		if(blocked) {
			emit AddressBlocked(holderAddress);
			return;
		}
		
		emit AddressUnblocked(holderAddress);
    }	
	
	/**
     * @dev add or remove bot 
     */
	function setBotAddress(address botAddress, bool isbot) public onlyGovernance()  {
		require(botAddress != address(0), "BotAddress can't be the zero address");
		
		botAddresses[botAddress][_msgSender()] = isbot;

		if(isbot) {
			emit BotAddressAdded(botAddress);
			return;
		}
		
		emit BotAddressRemoved(botAddress);
    }	
	
	/**
     * @dev add or remove pair address 
     */
	function setPair(address pairAddress, bool isPair) public onlyManager()  {
        require(pairAddress != address(0), "PairAddress can't be the zero address");

        pairs[pairAddress] = isPair;
		
		if(isPair) {
			emit PairAddressAdded(pairAddress);
			return;
		}
		
		emit PairAddressRemoved(pairAddress);
    }	
	
	/**
     * @dev enabled or disabled pinksale antibot system
     */
	function setEnableAntiBot(bool enable) external onlyManager() {
		antiBotEnabled = enable;
	}
	
	/**
     * @dev add or remove gouvernance
     */
	function setGovernance(address governanceAddress, uint number) public onlyOwner()  {
		require(governanceAddress != address(0), "GovernanceAddress can't be the zero address");
		require(number >= 1 && number <= 3, "Number must be 1, 2 or 3");
		
		if(number == 1) 
			governance1Address = governanceAddress;
		if(number == 2) 
			governance2Address = governanceAddress;
		if(number == 3) 
			governance3Address = governanceAddress;
		
		emit GovernanceAddressChanged(governanceAddress, number);
    }	
}