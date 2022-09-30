// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { OneVolatile } from "./OneVolatile.sol";

/*
 Compound VDC fees are 11% in and 11% out, they are distributed in the following way:
 7% to drip pool
 1% Instant dividends to stakers
 1% xONE-S to xPERPS stakers
 1% Payout
 1% Volatile VDC
 Receives incentives daily from xONE-S staking
 */
contract OneCompound is Initializable, Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		uint256 amount; // xONE-S staked
		uint256 burned; // xPERPS burned
		uint256 reward; // xONE-S reward accumulated but not claimed
		uint256 drip; // xONE-S from drip pool accumulated but not claimed
		uint256 boost; // xONE-S from boost accumulated but not claimed
		uint256 accRewardDebt; // xONE-S reward debt from PCS distribution algorithm
		uint256 accDripDebt; // xONE-S reward debt from PCS distribution algorithm
		uint256 accBoostDebt; // xONE-S reward debt from PCS distribution algorithm
		bool whitelisted; // flag indicating whether or not account pays withdraw penalties
		bool exists; // flag to index account
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_PAYOUT = 0x5c327D395D0617f5b6ad6E8Da5dCBb35A6Be5b11; // ghost

	uint256 constant DEFAULT_LAUNCH_TIME = 1664906400; // 2022-10-04 6PM UTC
	uint256 constant DEFAULT_DRIP_RATE_PER_DAY = 1e16; // 1% per day
	uint256 constant DEFAULT_DRIP_BOOST_RATE_PER_DAY = 0.5e16; // 0.5% per day

	uint256 constant DAY = 1 days;
	uint256 constant TZ_OFFSET = 22 hours + 30 minutes; // UTC-1.30

	address public reserveToken; // xONE-S
	address public rewardToken; // xONE-S
	address public boostToken; // xPERPS

	address public oneVolatile;

	address public payout = DEFAULT_PAYOUT;

	uint256 public launchTime = DEFAULT_LAUNCH_TIME;

	uint256 public dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;
	uint256 public dripBoostRatePerDay = DEFAULT_DRIP_BOOST_RATE_PER_DAY;

	bool public whitelistAll = false;

	uint256 public totalStaked = 0; // total staked balance
	uint256 public totalBurned = 0; // total burned balance

	uint256 public totalDrip = 0; // total drip pool balance
	uint256 public allocDrip = 0; // total drip pool balance allocated

	uint256 public totalReward = 0; // total reward balance

	uint256 public totalBoost = 0; // total boost balance

	uint256 public accRewardPerShare = 0; // cumulative reward xONE-S per xONE-S staked from PCS distribution algorithm
	uint256 public accDripPerShare = 0; // cumulative drip pool xONE-S per xONE-S staked from PCS distribution algorithm
	uint256 public accBoostPerShare = 0; // cumulative boost xONE-S per xPERPS burned from PCS distribution algorithm

	uint64 public day = today();

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function today() public view returns (uint64 _today)
	{
		return uint64((block.timestamp + TZ_OFFSET) / DAY);
	}

	modifier hasLaunched()
	{
		require(block.timestamp >= launchTime, "unavailable");
		_;
	}

	constructor(address _reserveToken, address _boostToken, address _oneVolatile)
	{
		initialize(msg.sender, _reserveToken, _boostToken, _oneVolatile);
	}

	function initialize(address _owner, address _reserveToken, address _boostToken, address _oneVolatile) public initializer
	{
		_transferOwnership(_owner);

		payout = DEFAULT_PAYOUT;

		launchTime = DEFAULT_LAUNCH_TIME;

		dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;
		dripBoostRatePerDay = DEFAULT_DRIP_BOOST_RATE_PER_DAY;

		whitelistAll = false;

		totalStaked = 0; // total staked balance
		totalBurned = 0; // total burned balance

		totalDrip = 0; // total drip pool balance
		allocDrip = 0; // total drip pool balance allocated

		totalReward = 0; // total reward balance

		totalBoost = 0; // total boost balance

		accRewardPerShare = 0; // cumulative reward xONE-S per xONE-S staked from PCS distribution algorithm
		accDripPerShare = 0; // cumulative drip pool xONE-S per xONE-S staked from PCS distribution algorithm
		accBoostPerShare = 0; // cumulative boost xONE-S per xPERPS burned from PCS distribution algorithm

		day = today();

		require(_boostToken != _reserveToken, "invalid token");
		reserveToken = _reserveToken;
		rewardToken = _reserveToken;
		boostToken = _boostToken;
		oneVolatile = _oneVolatile;
	}

	// updates the volatile vdc address
	function setOneVolatile(address _oneVolatile) external onlyOwner
	{
		require(_oneVolatile != address(0), "invalid address");
		oneVolatile = _oneVolatile;
	}

	// updates the payout address
	function setPayout(address _payout) external onlyOwner
	{
		require(_payout != address(0), "invalid address");
		payout = _payout;
	}

	// updates the launch time
	function setLaunchTime(uint256 _launchTime) external onlyOwner
	{
		require(block.timestamp < launchTime, "unavailable");
		require(_launchTime >= block.timestamp, "invalid time");
		launchTime = _launchTime;
	}

	// updates the percentual rate of distribution from the drip pool
	function setDripRatePerDay(uint256 _dripRatePerDay) external onlyOwner
	{
		require(_dripRatePerDay + dripBoostRatePerDay <= 100e16, "invalid rate");
		dripRatePerDay = _dripRatePerDay;
	}

	// updates the percentual rate of distribution from the drip pool
	function setDripBoostRatePerDay(uint256 _dripBoostRatePerDay) external onlyOwner
	{
		require(dripRatePerDay + _dripBoostRatePerDay <= 100e16, "invalid rate");
		dripBoostRatePerDay = _dripBoostRatePerDay;
	}

	// flags all accounts for withdrawing without penalty (useful for migration)
	function updateWhitelistAll(bool _whitelistAll) external onlyOwner
	{
		whitelistAll = _whitelistAll;
	}

	// flags multiple accounts for withdrawing without penalty
	function updateWhitelist(address[] calldata _accounts, bool _whitelisted) external onlyOwner
	{
		for (uint256 _i; _i < _accounts.length; _i++) {
			accountInfo[_accounts[_i]].whitelisted = _whitelisted;
		}
	}

	// this is a safety net method for recovering funds that are not being used
	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == reserveToken) _amount -= totalStaked + totalDrip + totalReward + totalBoost;
		require(_amount > 0, "no balance");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}

	// burns xPERPS
	function burn(uint256 _amount) external
	{
		burnOnBehalfOf(_amount, msg.sender);
	}

	// burns xPERPS on behalf of another account
	function burnOnBehalfOf(uint256 _amount, address _account) public hasLaunched nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateAccount(_account, 0, _amount);

		totalBurned += _amount;

		IERC20(boostToken).safeTransferFrom(msg.sender, FURNACE, _amount);

		emit Burn(_account, boostToken, _amount);
	}

	// stakes xONE-S
	function deposit(uint256 _amount) external hasLaunched nonReentrant
	{
		_deposit(msg.sender, _amount, msg.sender);

		emit Deposit(msg.sender, reserveToken, _amount);
	}

	// stakes xONE-S on behalf of another account
	function depositOnBehalfOf(uint256 _amount, address _account) external hasLaunched nonReentrant
	{
		_deposit(msg.sender, _amount, _account);

		emit Deposit(_account, reserveToken, _amount);
	}

	function _deposit(address _sender, uint256 _amount, address _account) internal
	{
		require(_amount > 0, "invalid amount");

		_updateDay();

		uint256 _1percent = _amount * 1e16 / 100e16;
		uint256 _dripAmount = 8 * _1percent;
		uint256 _netAmount = _amount - (11 * _1percent);

		// 8% accounted for the drip pool
		totalDrip += _dripAmount;

		// 1% instant rewards (only 7% actually go to the drip pool)
		if (totalStaked > 0) {
			accDripPerShare += _1percent * 1e18 / totalStaked;
			allocDrip += _1percent;
		}

		// rewards users for PERPS burned
		if (totalBurned > 0) {
			accBoostPerShare += _1percent * 1e18 / totalBurned;
			totalBoost += _1percent;
		}

		_updateAccount(_account, int256(_netAmount), 0);

		totalStaked += _netAmount;

		if (_sender == address(this)) {
			IERC20(reserveToken).safeTransfer(payout, _1percent);
		} else {
			IERC20(reserveToken).safeTransferFrom(_sender, address(this), _netAmount + _dripAmount + _1percent + _1percent);
			IERC20(reserveToken).safeTransferFrom(_sender, payout, _1percent);
		}

		// rewards Volatile VDC users
		IERC20(reserveToken).safeApprove(oneVolatile, _1percent);
		OneVolatile(oneVolatile).rewardAll(_1percent);
	}

	// unstakes xONE-S
	function withdraw(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "insufficient balance");

		_updateDay();

		_updateAccount(msg.sender, -int256(_amount), 0);

		totalStaked -= _amount;

		if (_accountInfo.whitelisted || whitelistAll) {
			IERC20(reserveToken).safeTransfer(msg.sender, _amount);
		} else {
			uint256 _1percent = _amount * 1e16 / 100e16;
			uint256 _dripAmount = 8 * _1percent;
			uint256 _netAmount = _amount - (11 * _1percent);

			// 8% accounted for the drip pool
			totalDrip += _dripAmount;

			// 1% instant rewards (only 7% actually go to the drip pool)
			if (totalStaked > 0) {
				accDripPerShare += _1percent * 1e18 / totalStaked;
				allocDrip += _1percent;
			}

			// rewards users for xPERPS burned
			if (totalBurned > 0) {
				accBoostPerShare += _1percent * 1e18 / totalBurned;
				totalBoost += _1percent;
			}

			IERC20(reserveToken).safeTransfer(payout, _1percent);

			// rewards Volatile VDC users
			IERC20(reserveToken).safeApprove(oneVolatile, _1percent);
			OneVolatile(oneVolatile).rewardAll(_1percent);

			IERC20(reserveToken).safeTransfer(msg.sender, _netAmount);
		}

		emit Withdraw(msg.sender, reserveToken, _amount);
	}

	// claims rewards only (xONE-S)
	function claimReward() external nonReentrant returns (uint256 _rewardAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;

			IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);
		}

		emit Claim(msg.sender, rewardToken, _rewardAmount);

		return _rewardAmount;
	}

	// claims drip only (xONE-S)
	function claimDrip() external nonReentrant returns (uint256 _dripAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_dripAmount = _accountInfo.drip;

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			IERC20(reserveToken).safeTransfer(msg.sender, _dripAmount);
		}

		emit Claim(msg.sender, reserveToken, _dripAmount);

		return _dripAmount;
	}

	// claims boost only (xONE-S)
	function claimBoost() external nonReentrant returns (uint256 _boostAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_boostAmount = _accountInfo.boost;

		if (_boostAmount > 0) {
			_accountInfo.boost = 0;

			totalBoost -= _boostAmount;

			IERC20(reserveToken).safeTransfer(msg.sender, _boostAmount);
		}

		emit Claim(msg.sender, reserveToken, _boostAmount);

		return _boostAmount;
	}

	// claims all (xONE-S)
	function claimAll() external nonReentrant returns (uint256 _rewardAmount, uint256 _dripAmount, uint256 _boostAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;
		_dripAmount = _accountInfo.drip;
		_boostAmount = _accountInfo.boost;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;
		}

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;
		}

		if (_boostAmount > 0) {
			_accountInfo.boost = 0;

			totalBoost -= _boostAmount;
		}

		uint256 _rewardPlusDripPlusBoostAmount = _rewardAmount + _dripAmount + _boostAmount;
		if (_rewardPlusDripPlusBoostAmount > 0) {
			IERC20(reserveToken).safeTransfer(msg.sender, _rewardPlusDripPlusBoostAmount);
		}

		emit Claim(msg.sender, rewardToken, _rewardAmount);
		emit Claim(msg.sender, reserveToken, _dripAmount);
		emit Claim(msg.sender, reserveToken, _boostAmount);

		return (_rewardAmount, _dripAmount, _boostAmount);
	}

	// compounds rewards only (xONE-S)
	function compoundReward() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;

			_deposit(address(this), _rewardAmount, msg.sender);
		}

		emit Compound(msg.sender, rewardToken, _rewardAmount);
	}

	// compounds drip only (xONE-S)
	function compoundDrip() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _dripAmount = _accountInfo.drip;

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			_deposit(address(this), _dripAmount, msg.sender);
		}

		emit Compound(msg.sender, reserveToken, _dripAmount);
	}

	// compounds boost only (xONE-S)
	function compoundBoost() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _boostAmount = _accountInfo.boost;

		if (_boostAmount > 0) {
			_accountInfo.boost = 0;

			totalBoost -= _boostAmount;

			_deposit(address(this), _boostAmount, msg.sender);
		}

		emit Compound(msg.sender, reserveToken, _boostAmount);
	}

	// compounds all (xONE-S)
	function compoundAll() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;
		uint256 _dripAmount = _accountInfo.drip;
		uint256 _boostAmount = _accountInfo.boost;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;
		}

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;
		}

		if (_boostAmount > 0) {
			_accountInfo.boost = 0;

			totalBoost -= _boostAmount;
		}

		uint256 _rewardPlusDripPlusBoostAmount = _rewardAmount + _dripAmount + _boostAmount;
		if (_rewardPlusDripPlusBoostAmount > 0) {
			_deposit(address(this), _rewardPlusDripPlusBoostAmount, msg.sender);
		}

		emit Compound(msg.sender, rewardToken, _rewardAmount);
		emit Compound(msg.sender, reserveToken, _dripAmount);
		emit Compound(msg.sender, reserveToken, _boostAmount);
	}

	// sends xONE-S to a set of accounts
	function reward(address[] calldata _accounts, uint256[] calldata _amounts) external nonReentrant
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _amounts[_i];

			emit Reward(_account, rewardToken, _amounts[_i]);

			_amount += _amounts[_i];
		}

		if (_amount > 0) {
			totalReward += _amount;

			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	// sends xONE-S to all stakers
	function rewardAll(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		if (totalStaked == 0) {
			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
			return;
		}

		_updateDay();

		accRewardPerShare += _amount * 1e18 / totalStaked;

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit RewardAll(msg.sender, rewardToken, _amount);
	}

	// performs the daily distribution from the drip pool (xONE-S)
	function updateDay() external nonReentrant
	{
		_updateDay();
	}

	function _updateDay() internal
	{
		uint64 _today = today();

		if (day == _today) return;

		uint256 _ratePerDay = dripRatePerDay + dripBoostRatePerDay;
		if (_ratePerDay > 0) {
			// calculates the percentage of the drip pool and distributes
			{
				// formula: drip_reward = drip_pool_balance * (1 - (1 - drip_rate_per_day) ^ days_ellapsed)
				uint64 _days = _today - day;
				uint256 _rate = 100e16 - _exp(100e16 - _ratePerDay, _days);
				uint256 _amount = (totalDrip - allocDrip) * _rate / 100e16;

				uint256 _amountDrip = _amount * dripRatePerDay / _ratePerDay;
				if (totalStaked > 0) {
					accDripPerShare += _amountDrip * 1e18 / totalStaked;
					allocDrip += _amountDrip;
				}

				uint256 _amountBoost = _amount - _amountDrip;
				if (totalBurned > 0) {
					accBoostPerShare += _amountBoost * 1e18 / totalBurned;
					totalDrip -= _amountBoost;
					totalBoost += _amountBoost;
				}
			}
		}

		day = _today;
	}

	// updates the account balances while accumulating reward/drip/boost using PCS distribution algorithm
	function _updateAccount(address _account, int256 _amount, uint256 _burned) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			// adds account to index
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}

		_accountInfo.reward += _accountInfo.amount * accRewardPerShare / 1e18 - _accountInfo.accRewardDebt;
		_accountInfo.drip += _accountInfo.amount * accDripPerShare / 1e18 - _accountInfo.accDripDebt;
		_accountInfo.boost += _accountInfo.burned * accBoostPerShare / 1e18 - _accountInfo.accBoostDebt;
		if (_amount > 0) {
			_accountInfo.amount += uint256(_amount);
		}
		else
		if (_amount < 0) {
			_accountInfo.amount -= uint256(-_amount);
		}
		_accountInfo.burned += _burned;
		_accountInfo.accRewardDebt = _accountInfo.amount * accRewardPerShare / 1e18;
		_accountInfo.accDripDebt = _accountInfo.amount * accDripPerShare / 1e18;
		_accountInfo.accBoostDebt = _accountInfo.burned * accBoostPerShare / 1e18;
	}

	// exponentiation with integer exponent
	function _exp(uint256 _x, uint256 _n) internal pure returns (uint256 _y)
	{
		_y = 1e18;
		while (_n > 0) {
			if (_n & 1 != 0) _y = _y * _x / 1e18;
			_n >>= 1;
			_x = _x * _x / 1e18;
		}
		return _y;
	}

	event Burn(address indexed _account, address indexed _boostToken, uint256 _amount);
	event Deposit(address indexed _account, address indexed _reserveToken, uint256 _amount);
	event Withdraw(address indexed _account, address indexed _reserveToken, uint256 _amount);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Compound(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Reward(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event RewardAll(address indexed _account, address indexed _rewardToken, uint256 _amount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { OneCompound } from "./OneCompound.sol";

/*
 Volatile VDC fees are 33% in and 33% out, they are distributed in the following way:
 30% to drip pool
 1% Instant dividends to stakers
 1% xONE to xPERPS stakers
 1% Payout
 Does not receive incentives daily but does receive 1% of all xONE-S deposited into Compound VDC
 */
contract OneVolatile is Initializable, Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		uint256 amount; // xONE staked
		uint256 burned; // xPERPS burned
		uint256 reward; // xONE-S reward from Compound VDC accumulated but not claimed
		uint256 drip; // xONE from drip pool accumulated but not claimed
		uint256 boost; // xONE from boost accumulated but not claimed
		uint256 accRewardDebt; // xONE-S reward debt from PCS distribution algorithm
		uint256 accDripDebt; // xONE reward debt from PCS distribution algorithm
		uint256 accBoostDebt; // xONE reward debt from PCS distribution algorithm
		bool whitelisted; // flag indicating whether or not account pays withdraw penalties
		bool exists; // flag to index account
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_PAYOUT = 0x5c327D395D0617f5b6ad6E8Da5dCBb35A6Be5b11; // ghost

	uint256 constant DEFAULT_LAUNCH_TIME = 1664906400; // 2022-10-04 6PM UTC
	uint256 constant DEFAULT_DRIP_RATE_PER_DAY = 1e16; // 1% per day
	uint256 constant DEFAULT_DRIP_BOOST_RATE_PER_DAY = 0.5e16; // 0.5% per day

	uint256 constant DAY = 1 days;
	uint256 constant TZ_OFFSET = 22 hours + 30 minutes; // UTC-1.30

	address public reserveToken; // xONE
	address public rewardToken; // xONE-S
	address public boostToken; // xPERPS

	address public oneCompound;

	address public payout = DEFAULT_PAYOUT;

	uint256 public launchTime = DEFAULT_LAUNCH_TIME;

	uint256 public dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;
	uint256 public dripBoostRatePerDay = DEFAULT_DRIP_BOOST_RATE_PER_DAY;

	bool public whitelistAll = false;

	uint256 public totalStaked = 0; // total staked balance
	uint256 public totalBurned = 0; // total burned balance

	uint256 public totalDrip = 0; // total drip pool balance
	uint256 public allocDrip = 0; // total drip pool balance allocated

	uint256 public totalReward = 0; // total reward balance

	uint256 public totalBoost = 0; // total boost balance

	uint256 public accRewardPerShare = 0; // cumulative reward xONE-S per xONE staked from PCS distribution algorithm
	uint256 public accDripPerShare = 0; // cumulative drip pool xONE per xONE staked from PCS distribution algorithm
	uint256 public accBoostPerShare = 0; // cumulative boost xONE per xPERPS burned from PCS distribution algorithm

	uint64 public day = today();

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function today() public view returns (uint64 _today)
	{
		return uint64((block.timestamp + TZ_OFFSET) / DAY);
	}

	modifier hasLaunched()
	{
		require(block.timestamp >= launchTime, "unavailable");
		_;
	}

	constructor(address _reserveToken, address _rewardToken, address _boostToken, address _oneCompound)
	{
		initialize(msg.sender, _reserveToken, _rewardToken, _boostToken, _oneCompound);
	}

	function initialize(address _owner, address _reserveToken, address _rewardToken, address _boostToken, address _oneCompound) public initializer
	{
		_transferOwnership(_owner);

		payout = DEFAULT_PAYOUT;

		launchTime = DEFAULT_LAUNCH_TIME;

		dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;
		dripBoostRatePerDay = DEFAULT_DRIP_BOOST_RATE_PER_DAY;

		whitelistAll = false;

		totalStaked = 0; // total staked balance
		totalBurned = 0; // total burned balance

		totalDrip = 0; // total drip pool balance
		allocDrip = 0; // total drip pool balance allocated

		totalReward = 0; // total reward balance

		totalBoost = 0; // total boost balance

		accRewardPerShare = 0; // cumulative reward xONE-S per xONE staked from PCS distribution algorithm
		accDripPerShare = 0; // cumulative drip pool xONE per xONE staked from PCS distribution algorithm
		accBoostPerShare = 0; // cumulative boost xONE per xPERPS burned from PCS distribution algorithm

		day = today();

		require(_rewardToken != _reserveToken && _boostToken != _reserveToken && _boostToken != _rewardToken, "invalid token");
		reserveToken = _reserveToken;
		rewardToken = _rewardToken;
		boostToken = _boostToken;
		oneCompound = _oneCompound;
	}

	// updates the compound vdc address
	function setOneCompound(address _oneCompound) external onlyOwner
	{
		require(_oneCompound != address(0), "invalid address");
		oneCompound = _oneCompound;
	}

	// updates the payout address
	function setPayout(address _payout) external onlyOwner
	{
		require(_payout != address(0), "invalid address");
		payout = _payout;
	}

	// updates the launch time
	function setLaunchTime(uint256 _launchTime) external onlyOwner
	{
		require(block.timestamp < launchTime, "unavailable");
		require(_launchTime >= block.timestamp, "invalid time");
		launchTime = _launchTime;
	}

	// updates the percentual rate of distribution from the drip pool
	function setDripRatePerDay(uint256 _dripRatePerDay) external onlyOwner
	{
		require(_dripRatePerDay + dripBoostRatePerDay <= 100e16, "invalid rate");
		dripRatePerDay = _dripRatePerDay;
	}

	// updates the percentual rate of distribution from the drip pool
	function setDripBoostRatePerDay(uint256 _dripBoostRatePerDay) external onlyOwner
	{
		require(dripRatePerDay + _dripBoostRatePerDay <= 100e16, "invalid rate");
		dripBoostRatePerDay = _dripBoostRatePerDay;
	}

	// flags all accounts for withdrawing without penalty (useful for migration)
	function updateWhitelistAll(bool _whitelistAll) external onlyOwner
	{
		whitelistAll = _whitelistAll;
	}

	// flags multiple accounts for withdrawing without penalty
	function updateWhitelist(address[] calldata _accounts, bool _whitelisted) external onlyOwner
	{
		for (uint256 _i; _i < _accounts.length; _i++) {
			accountInfo[_accounts[_i]].whitelisted = _whitelisted;
		}
	}

	// this is a safety net method for recovering funds that are not being used
	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == rewardToken) _amount -= totalReward;
		if (_token == reserveToken) _amount -= totalStaked + totalDrip + totalBoost;
		require(_amount > 0, "no balance");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}

	// burns xPERPS
	function burn(uint256 _amount) external
	{
		burnOnBehalfOf(_amount, msg.sender);
	}

	// burns xPERPS on behalf of another account
	function burnOnBehalfOf(uint256 _amount, address _account) public hasLaunched nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateAccount(_account, 0, _amount);

		totalBurned += _amount;

		IERC20(boostToken).safeTransferFrom(msg.sender, FURNACE, _amount);

		emit Burn(_account, boostToken, _amount);
	}

	// stakes xONE
	function deposit(uint256 _amount) external hasLaunched nonReentrant
	{
		_deposit(msg.sender, _amount, msg.sender);

		emit Deposit(msg.sender, reserveToken, _amount);
	}

	// stakes xONE on behalf of another account
	function depositOnBehalfOf(uint256 _amount, address _account) external hasLaunched nonReentrant
	{
		_deposit(msg.sender, _amount, _account);

		emit Deposit(_account, reserveToken, _amount);
	}

	function _deposit(address _sender, uint256 _amount, address _account) internal
	{
		require(_amount > 0, "invalid amount");

		_updateDay();

		uint256 _1percent = _amount * 1e16 / 100e16;
		uint256 _dripAmount = 31 * _1percent;
		uint256 _netAmount = _amount - (33 * _1percent);

		// 31% accounted for the drip pool
		totalDrip += _dripAmount;

		// 1% instant rewards (only 30% actually go to the drip pool)
		if (totalStaked > 0) {
			accDripPerShare += _1percent * 1e18 / totalStaked;
			allocDrip += _1percent;
		}

		// rewards users for xPERPS burned
		if (totalBurned > 0) {
			accBoostPerShare += _1percent * 1e18 / totalBurned;
			totalBoost += _1percent;
		}

		_updateAccount(_account, int256(_netAmount), 0);

		totalStaked += _netAmount;

		if (_sender == address(this)) {
			IERC20(reserveToken).safeTransfer(payout, _1percent);
		} else {
			IERC20(reserveToken).safeTransferFrom(_sender, address(this), _netAmount + _dripAmount + _1percent);
			IERC20(reserveToken).safeTransferFrom(_sender, payout, _1percent);
		}
	}

	// unstakes xONE
	function withdraw(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "insufficient balance");

		_updateDay();

		_updateAccount(msg.sender, -int256(_amount), 0);

		totalStaked -= _amount;

		if (_accountInfo.whitelisted || whitelistAll) {
			IERC20(reserveToken).safeTransfer(msg.sender, _amount);
		} else {
			uint256 _1percent = _amount * 1e16 / 100e16;
			uint256 _dripAmount = 31 * _1percent;
			uint256 _netAmount = _amount - (33 * _1percent);

			// 31% accounted for the drip pool
			totalDrip += _dripAmount;

			// 1% instant rewards (only 30% actually go to the drip pool)
			if (totalStaked > 0) {
				accDripPerShare += _1percent * 1e18 / totalStaked;
				allocDrip += _1percent;
			}

			// rewards users for xPERPS burned
			if (totalBurned > 0) {
				accBoostPerShare += _1percent * 1e18 / totalBurned;
				totalBoost += _1percent;
			}

			IERC20(reserveToken).safeTransfer(payout, _1percent);

			IERC20(reserveToken).safeTransfer(msg.sender, _netAmount);
		}

		emit Withdraw(msg.sender, reserveToken, _amount);
	}

	// claims rewards only (xONE-S)
	function claimReward() external nonReentrant returns (uint256 _rewardAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;

			IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);
		}

		emit Claim(msg.sender, rewardToken, _rewardAmount);

		return _rewardAmount;
	}

	// claims drip only (xONE)
	function claimDrip() external nonReentrant returns (uint256 _dripAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_dripAmount = _accountInfo.drip;

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			IERC20(reserveToken).safeTransfer(msg.sender, _dripAmount);
		}

		emit Claim(msg.sender, reserveToken, _dripAmount);

		return _dripAmount;
	}

	// claims boost only (xONE)
	function claimBoost() external nonReentrant returns (uint256 _boostAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_boostAmount = _accountInfo.boost;

		if (_boostAmount > 0) {
			_accountInfo.boost = 0;

			totalBoost -= _boostAmount;

			IERC20(reserveToken).safeTransfer(msg.sender, _boostAmount);
		}

		emit Claim(msg.sender, reserveToken, _boostAmount);

		return _boostAmount;
	}

	// claims all (xONE and xONE-S)
	function claimAll() external nonReentrant returns (uint256 _rewardAmount, uint256 _dripAmount, uint256 _boostAmount)
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;
		_dripAmount = _accountInfo.drip;
		_boostAmount = _accountInfo.boost;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;
		}

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;
		}

		if (_boostAmount > 0) {
			_accountInfo.boost = 0;

			totalBoost -= _boostAmount;
		}

		if (_rewardAmount > 0) {
			IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);
		}

		uint256 _dripPlusBoostAmount = _dripAmount + _boostAmount;
		if (_dripPlusBoostAmount > 0) {
			IERC20(reserveToken).safeTransfer(msg.sender, _dripPlusBoostAmount);
		}

		emit Claim(msg.sender, rewardToken, _rewardAmount);
		emit Claim(msg.sender, reserveToken, _dripAmount);
		emit Claim(msg.sender, reserveToken, _boostAmount);

		return (_rewardAmount, _dripAmount, _boostAmount);
	}

	// compounds rewards only (xONE-S)
	function compoundReward() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;

			IERC20(rewardToken).safeApprove(oneCompound, _rewardAmount);
			OneCompound(oneCompound).depositOnBehalfOf(_rewardAmount, msg.sender);
		}

		emit Compound(msg.sender, rewardToken, _rewardAmount);
	}

	// compounds drip only (xONE)
	function compoundDrip() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _dripAmount = _accountInfo.drip;

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			_deposit(address(this), _dripAmount, msg.sender);
		}

		emit Compound(msg.sender, reserveToken, _dripAmount);
	}

	// compounds boost only (xONE)
	function compoundBoost() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _boostAmount = _accountInfo.boost;

		if (_boostAmount > 0) {
			_accountInfo.boost = 0;

			totalBoost -= _boostAmount;

			_deposit(address(this), _boostAmount, msg.sender);
		}

		emit Compound(msg.sender, reserveToken, _boostAmount);
	}

	// compounds all (xONE and xONE-S)
	function compoundAll() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;
		uint256 _dripAmount = _accountInfo.drip;
		uint256 _boostAmount = _accountInfo.boost;

		if (_rewardAmount > 0) {
			_accountInfo.reward = 0;

			totalReward -= _rewardAmount;
		}

		if (_dripAmount > 0) {
			_accountInfo.drip = 0;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;
		}

		if (_boostAmount > 0) {
			_accountInfo.boost = 0;

			totalBoost -= _boostAmount;
		}

		if (_rewardAmount > 0) {
			IERC20(rewardToken).safeApprove(oneCompound, _rewardAmount);
			OneCompound(oneCompound).depositOnBehalfOf(_rewardAmount, msg.sender);
		}

		uint256 _dripPlusBoostAmount = _dripAmount + _boostAmount;
		if (_dripPlusBoostAmount > 0) {
			_deposit(address(this), _dripPlusBoostAmount, msg.sender);
		}

		emit Compound(msg.sender, rewardToken, _rewardAmount);
		emit Compound(msg.sender, reserveToken, _dripAmount);
		emit Compound(msg.sender, reserveToken, _boostAmount);
	}

	// sends xONE-S to a set of accounts
	function reward(address[] calldata _accounts, uint256[] calldata _amounts) external nonReentrant
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _amounts[_i];

			emit Reward(_account, rewardToken, _amounts[_i]);

			_amount += _amounts[_i];
		}

		if (_amount > 0) {
			totalReward += _amount;

			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	// sends xONE-S to all stakers
	function rewardAll(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		if (totalStaked == 0) {
			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
			return;
		}

		_updateDay();

		accRewardPerShare += _amount * 1e18 / totalStaked;

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit RewardAll(msg.sender, rewardToken, _amount);
	}

	// performs the daily distribution from the drip pool (xONE)
	function updateDay() external nonReentrant
	{
		_updateDay();
	}

	function _updateDay() internal
	{
		uint64 _today = today();

		if (day == _today) return;

		uint256 _ratePerDay = dripRatePerDay + dripBoostRatePerDay;
		if (_ratePerDay > 0) {
			// calculates the percentage of the drip pool and distributes
			{
				// formula: drip_reward = drip_pool_balance * (1 - (1 - drip_rate_per_day) ^ days_ellapsed)
				uint64 _days = _today - day;
				uint256 _rate = 100e16 - _exp(100e16 - _ratePerDay, _days);
				uint256 _amount = (totalDrip - allocDrip) * _rate / 100e16;

				uint256 _amountDrip = _amount * dripRatePerDay / _ratePerDay;
				if (totalStaked > 0) {
					accDripPerShare += _amountDrip * 1e18 / totalStaked;
					allocDrip += _amountDrip;
				}

				uint256 _amountBoost = _amount - _amountDrip;
				if (totalBurned > 0) {
					accBoostPerShare += _amountBoost * 1e18 / totalBurned;
					totalDrip -= _amountBoost;
					totalBoost += _amountBoost;
				}
			}
		}

		day = _today;
	}

	// updates the account balances while accumulating reward/drip/boost using PCS distribution algorithm
	function _updateAccount(address _account, int256 _amount, uint256 _burned) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			// adds account to index
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}

		_accountInfo.reward += _accountInfo.amount * accRewardPerShare / 1e18 - _accountInfo.accRewardDebt;
		_accountInfo.drip += _accountInfo.amount * accDripPerShare / 1e18 - _accountInfo.accDripDebt;
		_accountInfo.boost += _accountInfo.burned * accBoostPerShare / 1e18 - _accountInfo.accBoostDebt;
		if (_amount > 0) {
			_accountInfo.amount += uint256(_amount);
		}
		else
		if (_amount < 0) {
			_accountInfo.amount -= uint256(-_amount);
		}
		_accountInfo.burned += _burned;
		_accountInfo.accRewardDebt = _accountInfo.amount * accRewardPerShare / 1e18;
		_accountInfo.accDripDebt = _accountInfo.amount * accDripPerShare / 1e18;
		_accountInfo.accBoostDebt = _accountInfo.burned * accBoostPerShare / 1e18;
	}

	// exponentiation with integer exponent
	function _exp(uint256 _x, uint256 _n) internal pure returns (uint256 _y)
	{
		_y = 1e18;
		while (_n > 0) {
			if (_n & 1 != 0) _y = _y * _x / 1e18;
			_n >>= 1;
			_x = _x * _x / 1e18;
		}
		return _y;
	}

	event Burn(address indexed _account, address indexed _boostToken, uint256 _amount);
	event Deposit(address indexed _account, address indexed _reserveToken, uint256 _amount);
	event Withdraw(address indexed _account, address indexed _reserveToken, uint256 _amount);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Compound(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Reward(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event RewardAll(address indexed _account, address indexed _rewardToken, uint256 _amount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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