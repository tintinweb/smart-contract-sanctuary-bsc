// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.9;

import "./lib/SafeBEP20.sol";
import "./lib/Ownable.sol";
import "./lib/Address.sol";
import "./IBEP20.sol";

/**
 * @author JumpTask (https://www.jumptask.io)
 * @title A fluid staking contract for JumpToken.
 *
 * @dev This contract is used in order to provide fluid staking functionality for JumpToken users.
 * While staking, the needed amount of token should be approved for this contract beforehand.
 */
contract FluidStaking is Ownable {
    using SafeBEP20 for IBEP20;
    using Address for address;

    /**
     * @dev BEP20 basic token contract being held
     */
    IBEP20 public immutable _token;

    /**
     * @dev The campaign identifier being sent with each Stake event
     */
    string public _campaignId;

    /**
     * @dev A map holding staked balances for participating wallets
     */
    mapping(address => uint256) public _stakedBalances;

    /**
     * @dev Total staked balance from all the wallets
     */
    uint256 public _totalStaked;

    /**
     * @dev Minimum amount accepted for each stake
     */
    uint256 public _minStake = 1;

    /**
     * @dev Maximum amount accepted for each stake
     */
    uint256 public _maxStake = 0;

    /**
     * @dev Maximum amount that can be staked in this contract in total
     */
    uint256 public _stakeLimit = 0;

    /**
     * @dev A map of wallets that are blacklisted.
     */
    mapping(address => bool) public _blacklistWallets;

    /**
     * @dev Unix timestamp when the staking campaign becomes active. It won't
     * accept any stakes before this timestamp.
     */
    uint256 public _startAt;

    /**
     * @dev Unix timestamp when the staking campaign becomes expired (inactive).
     * It won't accept any new stakes after this timestamp.
     */
    uint256 public _expireAt;

    /**
     * @dev How many tokens should be distributed for the stakers each minute.
     */
    uint256 public _mBudgetTokens;

    /**
     * @dev Minimum MPR that can be calculated.
     */
    uint256 public _minMpr;

    /**
     * @dev Maximum MPR that can be calculated
     */
    uint256 public _maxMpr;

    /**
     * @dev Minutely percentage rate decimals count. It is used instead of float
     * variables while calculating MPR.
     */
    uint256 public _mprDecimals = 18;

    /**
     * @dev Event index which is incremented by 1 for each successful stake and withdrawal.
     * It is sent together with each event in case consumer needs to verify the consistency
     * of events sequence.
     */
    uint256 public _eventIndex = 1;

    /**
     * @dev Allows to temporary hold staking activity.
     */
    bool public _hold = false;

    /**
     * @dev Event which is emitted during each successful stake and withdrawal.
     */
    event Stake(
        string campaignId, // campaign identifier being sent with each event
        address indexed staker, // transaction sender (staker wallet)
        int256 amount, // amount of stake (can be negative for withdrawals)
        uint256 stakedBalance, // balance of staker after performed action
        uint256 totalStaked, // total campaign staked amount
        uint256 mpr, // calculated MPR after performed action
        uint256 mprDecimals, // MPR decimals count
        uint256 txIndex, // incremental index of the transaction (increases after each event)
        uint256 timestamp // block timestamp of the action
    );

    /**
     * @dev Validates integrity of the contract balance and total staked amount.
     */
    modifier validIntegrity {
        _;
        require(_token.balanceOf(address(this)) >= _totalStaked, "FluidStaking: contract balance is incorrect compared to total staked amount");
    }

    modifier checkHold {
        require(!_hold, "FluidStaking: staking activity is temporary on hold");
        _;
    }

    modifier checkBlacklist {
        require(!isBlacklisted(_msgSender()), "FluidStaking: address is blacklisted");
        _;
    }

    /**
     * @dev Token address (immutable), campaign id and initial budget tokens should
     * be provided for contract initialization.
     */
    constructor(address tokenAddress_, string memory campaignId_, uint256 budgetTokens_) {
        _token = IBEP20(tokenAddress_);
        _campaignId = campaignId_;
        _mBudgetTokens = budgetTokens_;
    }

    /**
     * @dev Set new campaign id.
     */
    function setCampaignId(string memory campaignId_) public onlyOwner {
        _campaignId = campaignId_;
    }

    /**
     * @dev Sets minimal amount of token for a single stake.
     */
    function setMinStake(uint256 min_) public onlyOwner {
        require(min_ > 0, "FluidStaking: minimal stake should be positive number");
        _minStake = min_;
    }

    /**
     * @dev Sets maximum amount of token for a single stake.
     */
    function setMaxStake(uint256 max_) public onlyOwner {
        require(max_ == 0 || max_ >= _minStake, "FluidStaking: max stake should be either 0 or higher than minimum stake");
        _maxStake = max_;
    }

    /**
     * @dev Sets maximum amount of token that can be staked in this contract. After
     * this limit is hit, no new stakes are accepted.
     * 0 - for infinite.
     */
    function setStakeLimit(uint256 stakeLimit_) public onlyOwner {
        _stakeLimit = stakeLimit_;
    }

    /**
     * @dev Sets start timestamp. No stakes will be accepted before this timestamp.
     * 0 - for infinite.
     */
    function setStartAt(uint256 ts_) public onlyOwner {
        require(ts_ >= 0, "FluidStaking: start at should be positive unix timestamp number or 0");
        _startAt = ts_;
    }

    /**
     * @dev Sets expire timestamp. No stakes will be accepted after this timestamp.
     * 0 - for infinite.
     */
    function setExpireAt(uint256 expireAt_) public onlyOwner {
        require(expireAt_ >= 0 && expireAt_ >= _startAt, "FluidStaking: end at should be 0 or positive unix timestamp number and be greater than start at timestamp");
        _expireAt = expireAt_;
    }

    /**
     * @dev Sets minutely budget token, which is used for calculating MPR.
     */
    function setMBudgetTokens(uint256 mBudgetTokens_) public onlyOwner {
        _mBudgetTokens = mBudgetTokens_;
    }

    /**
     * @dev Sets maximum MPR for campaign.
     */
    function setMaxMpr(uint256 maxMpr_) public onlyOwner {
        _maxMpr = maxMpr_;
    }

    /**
     * @dev Sets maximum MPR for campaign.
     */
    function setMinMpr(uint256 minMpr_) public onlyOwner {
        _minMpr = minMpr_;
    }

    /**
     * @dev Sets current eventIndex for further events.
     */
    function setEventIndex(uint256 eventIndex_) public onlyOwner {
        _eventIndex = eventIndex_;
    }

    /**
     * @dev Set total staked amount to exact amount.
     */
    function setTotalStaked(uint256 totalStaked_) public onlyOwner {
        _totalStaked = totalStaked_;
    }

    /**
     * @dev Set hold value in order to temporary hold staking activity (e.g.
     * in case of maintenance or migrations).
     */
    function setHold(bool hold_) public onlyOwner {
        _hold = hold_;
    }

    /**
     * @dev Set staked balance.
     */
    function setStakedBalance(address address_, uint256 amount_) public onlyOwner {
        _stakedBalances[address_] = amount_;
    }

    /**
     * @dev Set staked balances in bulk.
     */
    function setStakedBalances(address[] calldata addresses_, uint256[] calldata amounts_, bool syncTotalStaked_) external onlyOwner {
        uint256 length = addresses_.length;
        require(length == amounts_.length, 'FluidStaking: arrays length should be identical for setting staked balances in bulk.');

        for (uint256 i = 0; i < length; i++) {
            if (syncTotalStaked_)
                _totalStaked -= _stakedBalances[addresses_[i]];

            _stakedBalances[addresses_[i]] = amounts_[i];

            if (syncTotalStaked_)
                _totalStaked += amounts_[i];
        }
    }

    /**
     * @dev Add wallet to blacklist.
     */
    function addToBlacklist(address address_) public onlyOwner {
        _blacklistWallets[address_] = true;
    }

    /**
     * @dev Remove wallet from blacklist.
     */
    function removeFromBlacklist(address address_) public onlyOwner {
        delete _blacklistWallets[address_];
    }

    /**
     * @dev Check if wallet is currently blacklisted.
     */
    function isBlacklisted(address address_) public view returns (bool) {
        return _blacklistWallets[address_];
    }

    /**
     * @dev Returns total amount of all the staked tokens.
     */
    function totalStaked() public view returns (uint256) {
        return _totalStaked;
    }

    /**
     * @dev Performs the stake operation and transfers sender's tokens to
     * the contract address.
     */
    function stake(uint256 amount_) public validIntegrity checkHold checkBlacklist {
        address sender = _msgSender();

        uint256 stakedBalance = _stakedBalances[sender] + amount_;

        require(block.timestamp >= _startAt, "FluidStaking: campaign is not started yet");
        require(_expireAt == 0 || block.timestamp < _expireAt, "FluidStaking: campaign is already expired");
        require(stakedBalance >= _minStake, "FluidStaking: stake amount is too small");
        require(_maxStake == 0 || stakedBalance <= _maxStake, "FluidStaking: stake amount is too big");
        require(_stakeLimit == 0 || _stakeLimit >= _totalStaked + amount_, "FluidStaking: stake limit is reached for this campaign");
        require(_token.allowance(sender, address(this)) >= amount_, "FluidStaking: not enough allowance of token");
        require(_token.transferFrom(sender, address(this), amount_), "FluidStaking: could not transfer tokens from sender to staking contract");

        _stakedBalances[sender] += amount_;
        _totalStaked += amount_;

        emitStakeEvent(sender, int256(amount_));
    }

    /**
     * @dev A helper method for emitting Stake event.
     */
    function emitStakeEvent(address sender, int256 amount_) internal {
        emit Stake(
            _campaignId,
            sender,
            amount_,
            getStaked(sender),
            totalStaked(),
            mpr(),
            mprDecimals(),
            _eventIndex++,
            block.timestamp
        );
    }

    /**
     * @dev Calculates MPR for currently staked token amount.
     * Note that result is multiplied by _mprDecimals in order not to lose precision.
     */
    function mpr() public view returns (uint256) {
        if (totalStaked() < 1) {
            return 0;
        }

        uint256 mpr_ = _mBudgetTokens * 10 ** _mprDecimals / totalStaked();

        if (_maxMpr > 0 && mpr_ > _maxMpr) {
            mpr_ = _maxMpr;
        }

        if (_minMpr > 0 && mpr_ < _minMpr) {
            mpr_ = _minMpr;
        }

        return mpr_;
    }

    /**
     * @dev Returns amount of decimals for MPR.
     */
    function mprDecimals() public view returns(uint256) {
        return _mprDecimals;
    }

    /**
     * @dev Triggers withdrawal process. It withdraws all the
     * staked amount for sender.
     */
    function withdraw() public {
        withdrawAmount(_stakedBalances[_msgSender()]);
    }

    /**
     * @dev Withdraws particular amount of token for sender.
     */
    function withdrawAmount(uint256 amount_) public validIntegrity checkHold checkBlacklist {
        address sender = _msgSender();
        uint256 staked = getStaked(sender);

        require(amount_ > 0, "FluidStaking: withdraw amount should be positive number");
        require(amount_ <= staked, "FluidStaking: withdraw amount is higher than staked amount");

        uint256 leftOver = staked - amount_;
        require(leftOver >= 0, "FluidStaking: stake amount should be positive");
        require(leftOver == 0 || leftOver >= _minStake, "FluidStaking: left-over amount is less than minimal stake after withdraw");

        _stakedBalances[sender] -= amount_;
        _totalStaked -= amount_;

        _token.transfer(sender, amount_);

        emitStakeEvent(sender, -1 * int256(amount_));
    }

    function reimburse(address to_, uint256 amount_) public onlyOwner {
        _token.transfer(to_, amount_);
    }

    /**
     * @dev Returns a staked balance for address.
     */
    function getStaked(address addr_) public view returns (uint256) {
        return _stakedBalances[addr_];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../IBEP20.sol';
import './Address.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
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
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./Context.sol";

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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.9;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
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

pragma solidity 0.8.9;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.9;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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