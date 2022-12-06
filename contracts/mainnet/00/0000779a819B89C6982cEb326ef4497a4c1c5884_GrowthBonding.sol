// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
Bonding Deposit Contract xGRO

30/60/90 Day option (pays out in xGRO and xPERPs)
(Mild, Wild, Full throttle)

30 day - 6% deposit fee 6% withdrawal fee of deposited token
1% Mgmt
1% Boosted Stakers
4% Pool
Pool pays out proportionally to stakers at the end of the bond, 30 days in this case.. (if someone withdraws early, they get charged the fee and get nothing at the end of the Bonding period..)

60 day - 16% deposit fee 16% withdrawal fee of deposited token
1.5% Mgmt
1.5% Boosted Stakers
13% Pool
Pool pays out proportionally to stakers at the end of the bond, 60 days in this case.. (if someone withdraws early, they get charged the fee and get nothing at the end of the Bonding period..)

90 day - 33% Deposit fee 33% withdrawal fee of deposited token
3% Mgmt
3% Boosted Stakers
27% Pool
Pool pays out proportionally to stakers at the end of the bond, 90 days in this case.. (if someone withdraws early, they get charged the fee and get nothing at the end of the Bonding period..)

*From the 20% claim tax on xGRO single stake farm: 
*15% of xPERPs goes to 30 day pool
*30% of xPERPs goes to 60 day pool
*55%, of xPERPs goes to 90 day pool

xPERPs Boosted position and sidepot

Deposit xPERPs to gain a boosted position in either the 30,60, or 90 day Bonds. 60% of the deposited xPERPs is burnt, 40% goes to a sidepot, from which positions 1,2, and 3 will split up the Pot at the end of the Bond..

1st Place will receive 55% of the sidepot
2nd Place will receive 30% 
3rd Place will recieve 15%
*/
contract GrowthBonding is Initializable, Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct RoundInfo {
		uint256 startTime;
		uint256 endTime;
		uint256 amount; // total xGRO staked balance
		uint256 boost; // total xGRO accumulated for the extra payout for burners
		uint256 payout; // total xGRO accumulated for the payout
		uint256 reward; // total xPERPS reward balance
		uint256 burned; // total xPERPS burned balance
		uint256 prize; // XPERPS accumulated as prize for top burners
		address[3] top3; // top 3 xPERPS burners
		uint256 weight; // total time-weighted xGRO balance

		uint256 reserved0; // unused
		uint256 reserved1; // unused
		uint256 reserved2; // unused
	}

	struct AccountInfo {
		bool exists; // flag to index account
		uint256 round; // account round
		uint256 amount; // xGRO deposited
		uint256 burned; // xPERPS burned
		uint256 weight; // time-weighted xGRO balance

		uint256 reserved0; // unused
		uint256 reserved1; // unused
		uint256 reserved2; // unused
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_BANKROLL = 0x392681Eaf8AD9BC65e74BE37Afe7503D92802b7d; // multisig

	address public reserveToken; // xGRO
	address public rewardToken; // xPERPS
	address public burnToken; // xPERPS

	uint256 public bankrollFee; // percentage of deposits/withdrawals towards the bankroll
	uint256 public boostFee; // percentage of deposits/withdrawals towards the boost pool
	uint256 public payoutFee; // percentage of deposits/withdrawals towards the payout pool

	uint256 public roundLength; // 30 days
	uint256 public roundInterval; // 7 days

	address public bankroll = DEFAULT_BANKROLL;

	uint256 public totalReserve = 0; // total xGRO balance
	uint256 public totalReward = 0; // total xPERPS balance

	RoundInfo[] public roundInfo;

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function roundInfoLength() external view returns (uint256 _roundInfoLength)
	{
		return roundInfo.length;
	}

	function roundInfoTop3(uint256 _index) external view returns (address[3] memory _top3)
	{
		return roundInfo[_index].top3;
	}

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	constructor(address _reserveToken, address _rewardToken, uint256 _bankrollFee, uint256 _boostFee, uint256 _payoutFee, uint256 _launchTime, uint256 _roundLength, uint256 _roundInterval)
	{
		initialize(msg.sender, _reserveToken, _rewardToken, _bankrollFee, _boostFee, _payoutFee, _launchTime, _roundLength, _roundInterval);
	}

	function initialize(address _owner, address _reserveToken, address _rewardToken, uint256 _bankrollFee, uint256 _boostFee, uint256 _payoutFee, uint256 _launchTime, uint256 _roundLength, uint256 _roundInterval) public initializer
	{
		_transferOwnership(_owner);

		bankroll = DEFAULT_BANKROLL;

		totalReserve = 0; // total xGRO balance
		totalReward = 0; // total xPERPS balance

		require(_launchTime >= block.timestamp, "invalid time");
		uint256 _startTime = _launchTime;
		uint256 _endTime = _startTime + _roundLength;
		roundInfo.push(RoundInfo({
			startTime: _startTime,
			endTime: _endTime,
			amount: 0,
			boost: 0,
			payout: 0,
			reward: 0,
			burned: 0,
			prize: 0,
			top3: [address(0), address(0), address(0)],
			weight: 0,

			reserved0: 0,
			reserved1: 0,
			reserved2: 0
		}));

		require(_rewardToken != _reserveToken, "invalid token");
		reserveToken = _reserveToken;
		rewardToken = _rewardToken;
		burnToken = _rewardToken;

		require(_bankrollFee + _boostFee + _payoutFee <= 100e16, "invalid rate");
		bankrollFee = _bankrollFee;
		boostFee = _boostFee;
		payoutFee = _payoutFee;

		require(_roundLength > 0, "invalid length");
		roundLength = _roundLength;
		roundInterval = _roundInterval;
	}

	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == reserveToken) _amount -= totalReserve;
		else
		if (_token == rewardToken) _amount -= totalReward;
		require(_amount > 0, "no balance");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}

	function burn(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		if (!_accountInfo.exists) {
			_accountInfo.exists = true;
			accountIndex.push(msg.sender);
		}
		if (_accountInfo.amount == 0 && _accountInfo.burned == 0) {
			_accountInfo.round = _currentRound;
		}
		require(_accountInfo.round == _currentRound, "pending redemption");

		RoundInfo storage _roundInfo = roundInfo[_accountInfo.round];
		require(block.timestamp >= _roundInfo.startTime, "not available");

		uint256 _prizeAmount = _amount * 40e16 / 100e16; // 40%
		uint256 _burnAmount = _amount - _prizeAmount;

		_accountInfo.burned += _amount;

		_roundInfo.burned += _amount;
		_roundInfo.prize += _prizeAmount;

		// updates ranking
		if (msg.sender != _roundInfo.top3[0] && msg.sender != _roundInfo.top3[1] && _accountInfo.burned > accountInfo[_roundInfo.top3[2]].burned) {
			_roundInfo.top3[2] = msg.sender;
		}
		if (accountInfo[_roundInfo.top3[2]].burned > accountInfo[_roundInfo.top3[1]].burned) {
			(_roundInfo.top3[1], _roundInfo.top3[2]) = (_roundInfo.top3[2], _roundInfo.top3[1]);
		}
		if (accountInfo[_roundInfo.top3[1]].burned > accountInfo[_roundInfo.top3[0]].burned) {
			(_roundInfo.top3[0], _roundInfo.top3[1]) = (_roundInfo.top3[1], _roundInfo.top3[0]);
		}

		totalReward += _prizeAmount;

		IERC20(burnToken).safeTransferFrom(msg.sender, FURNACE, _burnAmount);
		IERC20(burnToken).safeTransferFrom(msg.sender, address(this), _prizeAmount);

		emit Burn(msg.sender, burnToken, _amount, _currentRound);
	}

	function deposit(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		if (!_accountInfo.exists) {
			_accountInfo.exists = true;
			accountIndex.push(msg.sender);
		}
		if (_accountInfo.amount == 0 && _accountInfo.burned == 0) {
			_accountInfo.round = _currentRound;
		}
		require(_accountInfo.round == _currentRound, "pending redemption");

		RoundInfo storage _roundInfo = roundInfo[_accountInfo.round];
		require(block.timestamp >= _roundInfo.startTime, "not available");
		uint256 _timeLeft = _roundInfo.endTime - block.timestamp;

		uint256 _feeAmount = _amount * bankrollFee / 100e16;
		uint256 _boostedAmount = _amount * boostFee / 100e16;
		uint256 _payoutAmount = _amount * payoutFee / 100e16;
		uint256 _netAmount = _amount - (_feeAmount + _boostedAmount + _payoutAmount);
		uint256 _transferAmount = _netAmount + _payoutAmount + _boostedAmount;

		uint256 _weight = _netAmount * _timeLeft;

		_accountInfo.amount += _netAmount;
		_accountInfo.weight += _weight;

		_roundInfo.amount += _netAmount;
		_roundInfo.boost += _boostedAmount;
		_roundInfo.payout += _payoutAmount;
		_roundInfo.weight += _weight;

		totalReserve += _transferAmount;

		IERC20(reserveToken).safeTransferFrom(msg.sender, bankroll, _feeAmount);
		IERC20(reserveToken).safeTransferFrom(msg.sender, address(this), _transferAmount);

		emit Deposit(msg.sender, reserveToken, _amount, _currentRound);
	}

	function withdraw(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_accountInfo.round == _currentRound, "not available");
		require(_amount <= _accountInfo.amount, "insufficient balance");

		RoundInfo storage _roundInfo = roundInfo[_accountInfo.round];

		uint256 _feeAmount = _amount * bankrollFee / 100e16;
		uint256 _boostedAmount = _amount * boostFee / 100e16;
		uint256 _payoutAmount = _amount * payoutFee / 100e16;
		uint256 _netAmount = _amount - (_feeAmount + _boostedAmount + _payoutAmount);
		uint256 _transferAmount = _feeAmount + _netAmount;

		uint256 _weight = _amount * _accountInfo.weight / _accountInfo.amount;

		_accountInfo.amount -= _amount;
		_accountInfo.weight -= _weight;

		_roundInfo.amount -= _amount;
		_roundInfo.boost += _boostedAmount;
		_roundInfo.payout += _payoutAmount;
		_roundInfo.weight -= _weight;

		totalReserve -= _transferAmount;

		IERC20(reserveToken).safeTransfer(bankroll, _feeAmount);
		IERC20(reserveToken).safeTransfer(msg.sender, _netAmount);

		emit Withdraw(msg.sender, reserveToken, _amount, _currentRound);
	}

	function estimateRedemption(address _account) public view returns (uint256 _amount, uint256 _boostAmount, uint256 _payoutAmount, uint256 _weightedPayoutAmount, uint256 _divsAmount, uint256 _weightedDivsAmount, uint256 _prizeAmount, bool _available)
	{
		AccountInfo storage _accountInfo = accountInfo[_account];

		RoundInfo storage _roundInfo = roundInfo[_accountInfo.round];

		uint256 _halfPayout = _roundInfo.payout / 2;
		uint256 _halfReward = _roundInfo.reward / 2;

		_amount = _accountInfo.amount;
		_boostAmount = _accountInfo.burned == 0 ? 0 : _accountInfo.burned * _roundInfo.boost / _roundInfo.burned;
		_payoutAmount = _accountInfo.amount == 0 ? 0 : _accountInfo.amount * _halfPayout / _roundInfo.amount;
		_weightedPayoutAmount = _accountInfo.weight == 0 ? 0 : _accountInfo.weight * _halfPayout / _roundInfo.weight;

		_divsAmount = _accountInfo.amount == 0 ? 0 : _accountInfo.amount * _halfReward / _roundInfo.amount;
		_weightedDivsAmount = _accountInfo.weight == 0 ? 0 : _accountInfo.weight * _halfReward / _roundInfo.weight;
		_prizeAmount = 0;
		if (msg.sender == _roundInfo.top3[0]) {
			_prizeAmount = _roundInfo.prize * 55e16 / 100e16; // 55% 1st place
		}
		else
		if (msg.sender == _roundInfo.top3[1]) {
			_prizeAmount = _roundInfo.prize * 30e16 / 100e16; // 30% 2nd place
		}
		else
		if (msg.sender == _roundInfo.top3[2]) {
			_prizeAmount = _roundInfo.prize * 15e16 / 100e16; // 15% 3rd place
		}
		_available = block.timestamp >= _roundInfo.endTime;

		return (_amount, _boostAmount, _payoutAmount, _weightedPayoutAmount, _divsAmount, _weightedDivsAmount, _prizeAmount, _available);
	}

	function redeem() external nonReentrant
	{
		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_accountInfo.amount > 0 || _accountInfo.burned > 0, "no balance");
		uint256 _accountRound = _accountInfo.round;
		require(_accountRound < _currentRound, "open round");

		(uint256 _amount, uint256 _boostAmount, uint256 _payoutAmount, uint256 _weightedPayoutAmount, uint256 _divsAmount, uint256 _weightedDivsAmount, uint256 _prizeAmount, bool _available) = estimateRedemption(msg.sender);
		require(_available, "not available"); // should never happen

		emit AccountUponRedemption(msg.sender, _accountInfo.round, _accountInfo.amount, _accountInfo.burned, _accountInfo.weight);

		uint256 _reserveAmount = _amount + _boostAmount + _payoutAmount + _weightedPayoutAmount;
		uint256 _rewardAmount = _divsAmount + _weightedDivsAmount + _prizeAmount;

		_accountInfo.round = _currentRound;
		_accountInfo.amount = 0;
		_accountInfo.burned = 0;
		_accountInfo.weight = 0;

		totalReserve -= _reserveAmount;
		totalReward -= _rewardAmount;

		IERC20(reserveToken).safeTransfer(msg.sender, _reserveAmount);
		IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);

		emit Redeem(msg.sender, reserveToken, _reserveAmount, rewardToken, _rewardAmount, _accountRound);
	}

	function reward(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateRound();

		uint256 _currentRound = roundInfo.length - 1;

		RoundInfo storage _roundInfo = roundInfo[_currentRound];

		_roundInfo.reward += _amount;

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit Reward(msg.sender, rewardToken, _amount, _currentRound);
	}

	function updateRound() external
	{
		_updateRound();
	}

	function _updateRound() internal
	{
		RoundInfo storage _roundInfo = roundInfo[roundInfo.length - 1];
		if (block.timestamp < _roundInfo.endTime) return;
		uint256 _roundIntervalPlusLength = roundInterval + roundLength;
		uint256 _skippedRounds = (block.timestamp - _roundInfo.endTime) / _roundIntervalPlusLength;
		uint256 _startTime = _roundInfo.endTime + _skippedRounds * _roundIntervalPlusLength + roundInterval;
		uint256 _endTime = _startTime + roundLength;
		roundInfo.push(RoundInfo({
			startTime: _startTime,
			endTime: _endTime,
			amount: 0,
			boost: 0,
			payout: 0,
			reward: 0,
			burned: 0,
			prize: 0,
			top3: [address(0), address(0), address(0)],
			weight: 0,

			reserved0: 0,
			reserved1: 0,
			reserved2: 0
		}));
	}

	event Burn(address indexed _account, address _burnToken, uint256 _amount, uint256 indexed _round);
	event Deposit(address indexed _account, address _reserveToken, uint256 _amount, uint256 indexed _round);
	event Withdraw(address indexed _account, address _reserveToken, uint256 _amount, uint256 indexed _round);
	event AccountUponRedemption(address indexed _account, uint256 indexed _round, uint256 _amount, uint256 _burned, uint256 _weight);
	event Redeem(address indexed _account, address _reserveToken, uint256 _reserveAmount, address _rewardToken, uint256 _rewardAmount, uint256 indexed _round);
	event Reward(address indexed _account, address _rewardToken, uint256 _amount, uint256 indexed _round);
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