/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: XenDAOfinal.sol

//SPDX-License-Identifier: NONE
pragma solidity ^0.8.10;



interface IXEN {
    function claimRank(uint256 term) external;
    function claimMintReward() external;
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function userMints(address) external view returns (address, uint256, uint256, uint256, uint256, uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract XENDAO is ERC20("XEN DAO", "XD"), ReentrancyGuard {
	struct UserInfo {
        uint256 amount;         // tokens burned from user
        uint256 rewardDebt;     // Reward debt
    }
	
    uint256 public constant INITIALARTIFICIALBURN = 10000; //for first deposit
	address public immutable XEN = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;
    uint256 public immutable MAXFEE; 
	
	address public immutable implementation;

	mapping (address => UserInfo) public userInfo;
	
	uint256 public accEthPerShare;
	uint256 public latestBalance; //latest Fee balance
	
	// can transfer minting right to new contracts(in case there is optimization of the minting process)
	// rug-pull proof (5-day delay)
	address public canMint;
    address public registerMinter; // for time lock
    uint256 public daysDelay = 3; // 3 day time lock (can be extended)
    uint256 public timeWithDelay; //  "time lock"
    bool public canAssignNewMinter = true; // can be renounced
	
    //initial rewards
	uint256 public reward = 1e24; //1 million xenDao per mint 
	uint256 public rewardWbonus = 125 * 1e22; // +25% bonus if referred
	uint256 public refbonus = 250 * 1e21; // 250K tokens referral bonus
	uint256 public sendReward = 750 * 1e21; //750K reward
	uint256 public sendRewardBonus = 850 * 1e21; //850K reward
	uint256 public sendRewardRef = 200 * 1e21; //200K reward
	
    uint256 public fee;
	uint256 public claimAgainFee; 
    uint256 public sendFee;

	uint256 public lastRewardUpdate;
	uint256 public dayCount = 1;

	uint256 public totalBurned = 10000; //amount staked
	
	uint256 public alreadyMinted = 0;
	address public noExpectationAddress = 0xf16d68c08a05Cd824FC026FeC1191A3ee261c70A;
	
    mapping(address => uint256 []) public userQuantities;
	
	constructor(uint256 _fee, uint256 _maxFee, address _implementation) {
		lastRewardUpdate = block.timestamp + 13 * 24 * 3600; //steady for first 14 days
        fee = _fee;
        claimAgainFee = _fee;
        sendFee = _fee;
        MAXFEE = _maxFee;
		implementation = _implementation;
	}

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function createContract (bytes memory data, uint256 quantity, bytes calldata _salt) external payable {
		require(msg.value == fee*quantity, "ETH sent is incorrect");
		address _clone;
        bytes32 salt;
        for(uint i=0; i<quantity; i++) {
            salt = keccak256(abi.encodePacked(_salt,i,msg.sender));
			_clone = cloneDeterministic(implementation, salt);
			Implementation(_clone).a(data);
        }
        userQuantities[msg.sender].push(quantity);
		_mint(msg.sender, quantity * reward);
    }
	
    function createContractRef (bytes memory data, uint256 quantity, bytes calldata _salt, address referral) external payable {
        require(msg.value == fee*quantity, "ETH sent is incorrect");
		address _clone;
        bytes32 salt;
        for(uint i=0; i<quantity; i++) {
            salt = keccak256(abi.encodePacked(_salt,i,msg.sender));
            _clone = cloneDeterministic(implementation, salt);
			Implementation(_clone).a(data);
        }
        userQuantities[msg.sender].push(quantity);
		_mint(msg.sender, quantity * rewardWbonus);
		if(referral != msg.sender) { _mint(referral, quantity * refbonus); }
    }
	
	function stake(uint256 _amount) external nonReentrant {
		uint256 _tokenChange = address(this).balance - latestBalance;
		accEthPerShare = accEthPerShare + _tokenChange * 1e12 / totalBurned;
		
		_burn(msg.sender, _amount);
		totalBurned+= _amount;
		
		if(userInfo[msg.sender].amount == 0) { //no previous balance
			userInfo[msg.sender].amount = _amount;
            userInfo[msg.sender].rewardDebt = userInfo[msg.sender].amount * accEthPerShare / 1e12; 
		} else {
			uint256 _pending = userInfo[msg.sender].amount * accEthPerShare / 1e12 - userInfo[msg.sender].rewardDebt;
			userInfo[msg.sender].amount+= _amount;
            userInfo[msg.sender].rewardDebt = userInfo[msg.sender].amount * accEthPerShare / 1e12 - _pending; 
		}
		latestBalance = address(this).balance;
	}

	function harvest() public nonReentrant {
		uint256 _tokenChange = address(this).balance - latestBalance;
		accEthPerShare = accEthPerShare + _tokenChange * 1e12 / totalBurned;
		uint256 _pending = userInfo[msg.sender].amount * accEthPerShare / 1e12 - userInfo[msg.sender].rewardDebt;
		
		userInfo[msg.sender].rewardDebt = userInfo[msg.sender].amount * accEthPerShare / 1e12; // reset 
		payable(msg.sender).transfer(_pending);
		latestBalance = address(this).balance;
	}
	
	function withdraw() external nonReentrant {
		uint256 _tokenChange = address(this).balance - latestBalance;
		accEthPerShare = accEthPerShare + _tokenChange * 1e12 / totalBurned;
		
		uint256 _pending = userInfo[msg.sender].amount * accEthPerShare / 1e12 - userInfo[msg.sender].rewardDebt;
		
		uint256 _tokensStaked = userInfo[msg.sender].amount;
		
		userInfo[msg.sender].amount = 0;
		userInfo[msg.sender].rewardDebt = 0;
		
		payable(msg.sender).transfer(_pending);
		latestBalance = address(this).balance;
		
		_mint(msg.sender, _tokensStaked);
		totalBurned-= _tokensStaked;
	}

    // if better-optimized contract is launched, minting privileges can be transferred
    function mint(address _to, uint256 _amount) external {
        require(msg.sender == canMint);
        _mint(_to, _amount);
    }
	
	function aMassSend(address[] calldata _address, uint256 _amount) external payable nonReentrant {
		uint256 _quantity = _address.length;
        require(msg.value == _quantity * sendFee + _quantity * _amount, "fee insufficient!");
		
		for(uint i=0; i < _quantity; i++) {
            payable(_address[i]).transfer(_amount);
        }
	
		_mint(msg.sender, _quantity * sendReward);
	}

    function vmassSendRef(address[] calldata _address, uint256 _amount, address _referral) external payable nonReentrant {
		uint256 _quantity = _address.length;
        require(msg.value == _quantity * sendFee + _quantity * _amount, "total send + fee insufficient!");
        require(msg.sender != _referral, "not allowed");
		
		for(uint i=0; i < _quantity; i++) {
            payable(_address[i]).transfer(_amount);
        }
        
		_mint(msg.sender, _quantity * sendRewardBonus);
        _mint(_referral, _quantity * sendRewardRef);
	}
	
    // used for minting & claiming again
    function multiCall(address[] calldata _contracts, bytes memory data) external {
        for(uint256 i=0; i < _contracts.length; i++) {
            Implementation(_contracts[i]).a(data);
        }
    }

    function claimAgainWithFee(address[] calldata _contracts, address _referral, bytes memory data) external payable {
        uint256 _quantity = _contracts.length;
        uint256 _tAmount = claimAgainFee * _quantity;
        require(msg.value == _tAmount, "ETH sent is incorrect");

        for(uint256 i=0; i < _contracts.length; i++) {
            Implementation(_contracts[i]).a(data);
        }
        
        if(_referral != msg.sender) {
            _mint(msg.sender, _quantity * sendRewardBonus);
            _mint(_referral, _quantity * sendRewardRef);
        } else {
            _mint(msg.sender, _quantity * sendReward);
        }
    }

    //returns earnings, amount staked and total Staked
	function userStakeEarnings(address _user) external view returns (uint256, uint256, uint256) {
		uint256 _tokenChange = address(this).balance - latestBalance;
		uint256 _tempAccEthPerShare = accEthPerShare + _tokenChange * 1e12 / totalBurned;
		
		uint256 _pending = userInfo[_user].amount * _tempAccEthPerShare / 1e12 - userInfo[_user].rewardDebt;
		
		return (_pending, userInfo[_user].amount, totalBurned);
	}
	
    function userMints(address _user) external view returns(uint256) {
        return userQuantities[_user].length; 
    }

    function contractAddress(bytes calldata _salt, uint256 _mintNr, address _user) public view returns (address) {
        return predictDeterministicAddress(implementation, keccak256(abi.encodePacked(_salt,_mintNr,_user)), address(this));
    }

    function contractAddressWithHash(bytes32 _salt) public view returns (address) {
        return predictDeterministicAddress(implementation, _salt, address(this));
    }
	
    function multiData(address _user, uint256 _id, address _contractAddress) external view returns (uint256, uint256) {
        return (userQuantities[_user][_id], getMaturationDate(_contractAddress));
    }

    function getMaturationDate(address _contract) public view returns (uint256) {
        (, , uint256 maturation, , , ) = IXEN(XEN).userMints(_contract);
        return maturation;
    }

    function getClaimCallData(uint256 term) external pure returns (bytes memory) {
        return abi.encodeWithSignature("claimRank(uint256)", term);
    }

     function getMintCallData() external pure returns (bytes memory) {
        return abi.encodeWithSignature("mint()");
    }
	
	function getTransferCallData(address _to, uint256 _amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", _to, _amount);
    }

    function transferAllCallData(address _contract, address _to) external view returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", _to, IXEN(XEN).balanceOf(_contract));
    }

    function getSalt(bytes calldata _salt, uint256 _mintNr, address _user) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_salt,_mintNr,_user));
    }
	
	function totalSupply() public view virtual override returns (uint256) {
        return super.totalSupply() + totalBurned - INITIALARTIFICIALBURN;
    }

    function getBatchAddresses(bytes32[] calldata _salt, uint256 _claimId, address _user) external view returns (address[] memory) {
        uint256 _batchLength = userQuantities[_user][_claimId];
        address[] memory _addresses;
        for(uint i=0; i<_batchLength; i++) {
            _addresses[i] = predictDeterministicAddress(implementation, _salt[i], address(this));     
        }
        return _addresses;
    }
	
	// inflationary only for the first 3-4 months
	function decreaseRewards() external {
		require(block.timestamp - lastRewardUpdate > 86400, "Decrease not yet eligible. Must wait 1 day between calls");
		reward = reward * (100 - dayCount) / 100;
		rewardWbonus = rewardWbonus * (100 - dayCount) / 100;
		refbonus = refbonus * (100 - dayCount) / 100;

        sendReward = sendReward * (100 - dayCount) / 100;
		sendRewardBonus = sendRewardBonus * (100 - dayCount) / 100;
		sendRewardRef = sendRewardRef * (100 - dayCount) / 100;
		
		dayCount++;
	}
	
	function stopInflation() external {
		require(block.timestamp > 1673740800, "Must wait until 15th Jan 2023");
		reward = 0;
		rewardWbonus = 0;
		refbonus = 0;

        sendReward = 0;
        sendRewardBonus = 0;
        sendRewardRef = 0;
	}
	
	function mintNoExpectation() external nonReentrant {
        require(msg.sender == noExpectationAddress, "not allowed");
		uint256 _totalAllowed = totalSupply() / 10;
		uint256 _toMint = _totalAllowed - alreadyMinted;
		alreadyMinted+= _toMint;
		_mint(noExpectationAddress, _toMint);
	}

    function setFee(uint256 _newFee, uint256 _againFee, uint256 _sendFee) external {
        require(_newFee <= MAXFEE && _againFee <= MAXFEE && _sendFee <= MAXFEE, "over limit");
        require(msg.sender == noExpectationAddress);
        fee = _newFee;
        claimAgainFee = _againFee;
        sendFee = _sendFee; 
    }
	
	//set mint reward for mass send
	function setSendingReward(uint256 _new) external {
		require(msg.sender == noExpectationAddress);
		require(_new <= reward, "can't be bigger than reward");
		sendReward = _new;
		sendRewardBonus = _new * 125 / 100;
		sendRewardRef = _new * 25 / 100;
	}
	
	function wchangeAddress(address _noExpect) external {
		require(msg.sender == noExpectationAddress);
		noExpectationAddress = _noExpect;
	}
	
    function wdaysDelay(uint256 _newDelay) external {
		require(msg.sender == noExpectationAddress);
        require(_newDelay > daysDelay, "can only increase");
		daysDelay = _newDelay;
	}

   function wassignNewMinter(address _new) external {
        require(canAssignNewMinter, "renounced");
        require(msg.sender == noExpectationAddress);
        registerMinter = _new;
        timeWithDelay = block.timestamp + daysDelay * 24 * 3600;
    }

    function wfinalizeMinterAfterDelay() external {
        require(canAssignNewMinter);
        require(registerMinter != address(0));
        require(block.timestamp > timeWithDelay);
        canMint = registerMinter;
    }

    function wrenounceNewMinters() external {
        require(msg.sender == noExpectationAddress, "not allowed");
        canAssignNewMinter = false;
    }
	
    //source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/Clones.sol
    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */

    function cloneDeterministic(address _implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, _implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, _implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address _implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), _implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }
}

contract Implementation {
    address private o;
    uint256 private u;

    function a(bytes memory data) external {
        if(u > 0) { 
            require(tx.origin == o);
        } else {
            o = tx.origin;
            u = 1;
        }
        assembly {
            let succeeded := call(
                gas(),
                0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e,
                0,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
        }
    }
}