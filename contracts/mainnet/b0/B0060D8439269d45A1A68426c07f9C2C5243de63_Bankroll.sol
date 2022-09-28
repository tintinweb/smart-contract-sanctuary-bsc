// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BankrollShare is IERC20, Ownable {
	using SafeERC20 for IERC20;

	string public symbol = "";
	string public name = "";
	IERC20 public immutable token;
	uint8 public immutable decimals;
	uint256 public override totalSupply;
	uint256 private constant LOCK_TIME = 24 hours;

	struct UserBalances {
		uint256 balance;
		uint256 lockedUntil;
	}

	event WithdrawUnderlying(address indexed recipient, uint256 amount);
	/// @notice owner > balance mapping.
	mapping(address => UserBalances) public users;
	/// @notice owner > spender > allowance mapping.
	mapping(address => mapping(address => uint256)) public override allowance;

	constructor(
		address token_,
		string memory name_,
		string memory symbol_
	) public {
		token = IERC20(token_);
		name = name_;
		symbol = symbol_;
		decimals = IERC20Metadata(token_).decimals();
	}

	/* onlyOwner which is always the Bankroll Contract */
	function withdrawUnderlying(address recipient, uint256 amount)
		external
		onlyOwner
	{
		token.safeTransfer(recipient, amount);

		emit WithdrawUnderlying(recipient,amount);
	}


	function balanceOf(address user)
		external
		view
		override
		returns (uint256 balance)
	{
		return users[user].balance;
	}

	function lockedUntil(address user) external view returns (uint256 timestamp) {
		UserBalances memory fromUser = users[user];
		return fromUser.lockedUntil;
	}

	function _transfer(
		address from,
		address to,
		uint256 shares
	) internal {
		require(to != address(0), "To Zero address");
		require(from != address(0), "From Zero address");

		UserBalances memory fromUser = users[from];
		require(block.timestamp >= fromUser.lockedUntil, "Locked");

		if (shares != 0) {
			require(fromUser.balance >= shares, "Low balance");
			if (from != to) {
				UserBalances memory toUser = users[to];
				users[from].balance = fromUser.balance - shares;
				users[to].balance = toUser.balance + shares;
			}
		}
		emit Transfer(from, to, shares);
	}

	function _useAllowance(address from, uint256 shares) internal {
		if (_msgSender() == from) {
			return;
		}
		uint256 spenderAllowance = allowance[from][_msgSender()];
		// If allowance is infinite, don't decrease it to save on gas (breaks with EIP-20).
		if (spenderAllowance != type(uint256).max) {
			require(spenderAllowance >= shares, "Low allowance");
			allowance[from][_msgSender()] = spenderAllowance - shares; // Underflow is checked
		}

		
		emit Approval(_msgSender(), from, spenderAllowance - shares);
	}

	/// @notice Transfers `shares` tokens from `msg.sender` to `to`.
	/// @param to The address to move the tokens.
	/// @param shares of the tokens to move.
	/// @return (bool) Returns True if succeeded.
	function transfer(address to, uint256 shares)
		external
		override
		returns (bool)
	{
		_transfer(_msgSender(), to, shares);
		return true;
	}

	/// @notice Transfers `shares` tokens from `from` to `to`. Caller needs approval for `from`.
	/// @param from Address to draw tokens from.
	/// @param to The address to move the tokens.
	/// @param shares The token shares to move.
	/// @return (bool) Returns True if succeeded.
	function transferFrom(
		address from,
		address to,
		uint256 shares
	) external override returns (bool) {
		_useAllowance(from, shares);
		_transfer(from, to, shares);
		return true;
	}

	/// @notice Approves `amount` from sender to be spend by `spender`.
	/// @param spender Address of the party that can draw from msg.sender's account.
	/// @param amount The maximum collective amount that `spender` can draw.
	/// @return (bool) Returns True if approved.
	function approve(address spender, uint256 amount)
		external
		override
		returns (bool)
	{
		allowance[_msgSender()][spender] = amount;
		emit Approval(_msgSender(), spender, amount);
		return true;
	}

	function mint(address recipient, uint256 amount) external onlyOwner {
		require(recipient != address(0), "Zero address");
		UserBalances memory user = users[recipient];

		user.balance += amount;
		user.lockedUntil = (block.timestamp + LOCK_TIME);
		users[recipient] = user;
		totalSupply += amount;

		emit Transfer(address(0), recipient, amount);
	}

	function _burn(address from, uint256 amount) internal {
		require(from != address(0), "Zero address");
		UserBalances memory user = users[from];
		require(block.timestamp >= user.lockedUntil, "Locked");

		users[from].balance = user.balance - amount;
		totalSupply -= amount;

		emit Transfer(from, address(0), amount);
	}

	function burnFrom(address from, uint256 amount) external {
		_useAllowance(from, amount);
		_burn(from, amount);
	}
}

/*
	Bankroll has pools for each whitelisted token (whitelisted managed by owner,later timelock from multisig)
	Each pool emits tokens on deposit, which represent the share of the underlying asset (ETH pool emits brETH)
	Pool gets filled/empties based on game performance;
*/
contract Bankroll is Ownable, ReentrancyGuard {
	using SafeERC20 for IERC20;

	event Withdraw(
		address indexed user,
		address token,
		uint256 shares,
		uint256 receivedUnderlying
	);

	event Deposit(
		address indexed user,
		address token,
		uint256 amount,
		uint256 receivedShares
	);

	event ReserveDebt(address indexed game, address token, uint256 amount);

	event ClearDebt(address indexed game, address token, uint256 amount);

	event PayDebt(
		address indexed game,
		address indexed recipient,
		address token,
		uint256 amount
	);
	event MaxWinChanged(uint256 oldMax,uint256 newMax);
	event UpdateGameLimit(address indexed gameAddress,uint256 limit);
	event UpdateWhitelist(address indexed contractAddress, bool state);

	event AddPool(address indexed asset, address indexed poolToken);
	event RemovePool(address indexed asset, address indexed poolToken);


	event UpdateGuardian(address indexed guardianAddress, bool state);
	event EmergencyHaltGame(address indexed gameAddress);

	/* Tokens whitelisted */
	mapping(address => bool) public whitelistedTokens;

	/* Asset -> Share Pool */
	mapping(address => BankrollShare) public pools;
	/* Asset -> Debt Amount */
	mapping(address => uint256) public debtPools;

	uint256 public maxWin = 2500; // 25%;

	/* Guardian Roles */
	mapping(address => bool) public whitelistGuardians;

	/* Whitelisted contracts to request debt (games) */
	mapping(address => bool) public whitelistContracts;

	/* Keep track of the balance's the games withdraw */
	uint256 private immutable creationDate;
	
	/* game -> limit */
	mapping(address => uint256) public dailyGameLimits;
	/* game -> token -> day -> used amount */
	mapping(address => mapping(address => mapping(uint256 => uint256))) public dailyGameStats;

	constructor() {
		creationDate = block.timestamp;
	}
	
	/// @notice returns day index since contract deployment
	function getDay() public view returns (uint256) {
		if (block.timestamp < creationDate) return 0;
		uint256 delta = block.timestamp - creationDate;
		uint256 day = delta / 1 days;
		return day;
	}

	/// @notice check if a contract is whitelisted
	/// @param game game address
	/// @param token token address
	/// @param amount amount amount to withdraw
	/// @return bool true/false if is within limit
	function isWithinLimit(address game,address token,uint256 amount) private view returns (bool) {
		uint256 limit = dailyGameLimits[game];
		if (limit == 0) return true; /* In case of disabled limit */
		uint256 needed = dailyGameStats[game][token][getDay()] + amount;
		uint256 reserve_limit = reserves(token) * limit / 10000;
		if (needed <= reserve_limit) {
			return true;
		}
		return false;
	}


	/// @notice sets the newLimit percentage in bps. 10000 = 100%, 0 = disabled
	/// @param a game address
	/// @param newLimit new value to set it to
	function setDailyGameLimit(address a, uint256 newLimit) external onlyOwner {
		require(newLimit >= 0, "BR:invalid new limit, below 0");
		require(newLimit <= 10000, "BR:invalid new limit, exceeds 10000");

		dailyGameLimits[a] = newLimit;
		emit UpdateGameLimit(a,newLimit);
	}

	/* only guardians */
	modifier onlyGuardian() {
		require(
			whitelistGuardians[_msgSender()],
			"BR:Only Guardian Addresses can call this"
		);
		_;
	}

	/// @notice instantly disables a game
	/// @param game game to disable
	function emergencyHaltGame(address game) external onlyGuardian {
		require(game != address(0), "BR:emergencyHaltGame game address is 0");

		whitelistContracts[game] = false;
		emit EmergencyHaltGame(game);
	}

	/// @notice change guardian state for address
	/// @param user address to change
	/// @param to value to set
	function setGuardian(address user, bool to) external onlyOwner {
		whitelistGuardians[user] = to;
		emit UpdateGuardian(user, to);
	}


	/// @notice check if a contract is whitelisted
	/// @param check contract to check
	/// @return bool true/false if whitelisted
	function isWhitelisted(address check) public view returns (bool) {
		return whitelistContracts[check];
	}

	/* only games/trusted contracts */
	modifier onlyGames() {
		require(
			isWhitelisted(_msgSender()),
			"BR:Only Whitelisted Games can call this"
		);
		_;
	}

	/// @notice set contract whitelist state
	/// @param a contract to update
	/// @param to value to set
	function setWhitelist(address a, bool to) external onlyOwner {
		whitelistContracts[a] = to;

		/* Set default limit for new games */
		dailyGameLimits[a] = 1500; // 15%

		emit UpdateWhitelist(a, to);
	}


	/// @notice sets the maxWin percentage in bps. 10000 = 100%
	/// @param newMax new value to set it to
	function setMaxWin(uint256 newMax) external onlyOwner {
		require(newMax > 0, "BR:invalid new max win");
		require(newMax <= 10000, "BR:invalid new max win, exceeds 10000");


		emit MaxWinChanged(maxWin, newMax);
		maxWin = newMax;
	}

	/* only if there is a pool for the asset */
	modifier hasBankrollPool(address token) {
		require(hasPool(token), "BR:No Pool for Token");
		_;
	}

	/// @notice hasPool
	/// @param token token to check if there is a pool for
	/// @return bool true/false if there is a pool
	function hasPool(address token) public view returns (bool) {
		return whitelistedTokens[token];
	}

	/// @notice remove a bankroll pool, doesnt destroy the contract so emergencyWithdraw is still possible.
	/// @param token `token` pool to remove
	function removePool(address token) external onlyOwner {
		require(hasPool(token), "BR:pool does not exists");
		whitelistedTokens[token] = false;

		emit RemovePool(token, address(pools[token]));
	}

	/// @notice add a bankroll pool & whitelist it
	/// @param token creates a bankroll pool for `token`
	function addPool(address token) external onlyOwner {
		require(hasPool(token) == false, "BR:pool already exists");
		whitelistedTokens[token] = true;
		if (address(pools[token]) == address(0x0)) {
			pools[token] = new BankrollShare(
				token,
				string(abi.encodePacked("br", IERC20Metadata(token).symbol())),
				string(abi.encodePacked("br", IERC20Metadata(token).symbol()))
			);
		}

		emit AddPool(token, address(pools[token]));
	}

	/// @notice returns reserves of `token` in the bankroll pool
	/// @param token the non wrapped token
	/// @return reserves token balance of the contract
	function reserves(address token) public view returns (uint256) {
		//return IERC20(token).balanceOf(address(this));
		return IERC20(token).balanceOf(address(pools[token]));
	}

	/* Returns the users balance of a brToken (i.e a fetch with USDC token returns the brUSDC balance of user) */
	/// @notice get balance of the br`token` for `user`
	/// @param token the non wrapped token
	/// @param user user to check
	/// @return balance amount of brToken the user has
	function balanceOf(address token, address user)
		external
		view
		returns (uint256)
	{
		BankrollShare shareToken = pools[token];
		return shareToken.balanceOf(user);
	}


	/// @notice withdraw `token` and `shares` from a bankroll pool
	/// @param token the target token
	/// @param shares brShares to withdraw
	function _withdraw(IERC20 token, uint256 shares)
		private
	{
		BankrollShare shareToken = pools[address(token)];
		require(shares > 0, "BR:shares == 0");

		require(
			shareToken.balanceOf(_msgSender()) >= shares,
			"BR:insufficent balance"
		);

		uint256 amount = (shares * reserves(address(token))) /
			shareToken.totalSupply();

		if (amount >= reserves(address(token))) {
			amount = reserves(address(token));
		}

		require(
			(reserves(address(token)) - amount) >= debtPools[address(token)],
			"BR: remaining reserves less than debt"
		);

		shareToken.burnFrom(_msgSender(), shares);
		shareToken.withdrawUnderlying(_msgSender(), amount);

		emit Withdraw(_msgSender(), address(token), shares, amount);
	}


	/// @notice emergency withdraw whole br`token` balance from a bankroll pool
	/// @param token the target token
	function emergencyWithdraw(IERC20 token) external nonReentrant {
		BankrollShare shareToken = pools[address(token)];
		uint256 poolBalance = shareToken.balanceOf(_msgSender());
		require(poolBalance > 0, "BR:invalid amount");

		_withdraw(token, poolBalance);
	}

	/// @notice withdraw
	/// @param token the target token
	/// @param shares amount of shares to withdraw
	function withdraw(IERC20 token,uint256 shares) external hasBankrollPool(address(token)) nonReentrant {
		_withdraw(token, shares);
	}

	/// @notice deposit `token` and `amount` into a bankroll pool
	/// @param token the target token
	/// @param amount amount to deposit
	function deposit(IERC20 token, uint256 amount)
		external
		hasBankrollPool(address(token))
		nonReentrant
	{
		BankrollShare shareToken = pools[address(token)];

		require(amount > 0, "BR:amount == 0");
		require(token.balanceOf(_msgSender()) >= amount, "insufficient balance");

		/* Calculate ratio to mint brTokens in */
		uint256 totalSupply = shareToken.totalSupply();
		uint256 shares = totalSupply == 0
			? amount
			: (amount * totalSupply) / reserves(address(token));


		/* Send to Pool Contract */
		token.safeTransferFrom(_msgSender(), address(shareToken), amount);
		/* Mint brToken */
		shareToken.mint(_msgSender(), shares);

		emit Deposit(_msgSender(), address(token), amount, shares);
	}

	/// @notice get the max amount of a pool that can be won.
	/// @param token the target token
	/// @return maxWin maximum winnable
	function getMaxWin(address token) public view returns (uint256) {
		return (reserves(token) * maxWin) / 10000;
	}

	/// @notice clear `token` `amount` debt
	/// @param token the target token
	/// @param amount amount to remove from the debtPool
	function clearDebt(address token, uint256 amount)
		external
		hasBankrollPool(token)
		onlyGames
	{
		require(debtPools[token] >= amount, "BR:debt is smaller then amount");

		debtPools[token] -= amount;

		emit ClearDebt(_msgSender(), token, amount);
	}

	/// @notice pays reserved `token` `amount` to `recipient`.
	/// @param recipient recipient
	/// @param token the target token
	/// @param amount amount that needs to be sent
	function payDebt(
		address recipient,
		address token,
		uint256 amount
	) external 
		onlyGames 
		hasBankrollPool(token) 
	{
		require(debtPools[token] >= amount, "BR:debt pool lt amount");
		require(reserves(token) >= amount, "BR:reserve lt amount");

		/* Check if the amount is within the game's limit */
		require(isWithinLimit(_msgSender(),token,amount), "BR:amount outside of daily limit");
		dailyGameStats[_msgSender()][token][getDay()] += amount;

		debtPools[token] -= amount;
		pools[token].withdrawUnderlying(recipient, amount);

		emit PayDebt(_msgSender(), recipient, token, amount);
	}

	/// @notice Reserves `token` `amount` for a game.
	/// @param token the target token
	/// @param amount Amount the bankroll needs to reserve in case of a win for the user
	function reserveDebt(
		address token, 
		uint256 amount
	) external
		onlyGames
		hasBankrollPool(token)
	{
		require(getMaxWin(token) >= amount, "BR:amount exceeds maxWin");

		require(
			reserves(token) >= debtPools[token] + amount,
			"BR:reserve lt debt + amount"
		);

		debtPools[token] += amount;
		emit ReserveDebt(_msgSender(), token, amount);
	}
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
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