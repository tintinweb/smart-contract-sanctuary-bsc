pragma solidity 0.6.12;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

interface IDione is IERC20Upgradeable {
    function decimals() external returns (uint256);
}

contract DStaking is Initializable, ContextUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IDione;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 penaltyDebt;
        uint256 rewardClaimable;
        uint256 penaltyClaimable;
        uint256 stakingTimestamp;
        uint256 reimbursementAmount;
    }

    struct Statistics {
        uint256 totalStakers;
        uint256 totalDeposit;
        uint256 totalReimbursement;
    }

    struct PenaltyTiers {
        uint256 validUntil;
        uint256 percent;
    }

    uint256 constant public REWARD_PERIOD = 2 * 604800; // Bi-Weekly

    uint256 private accPenalty;
    uint256 private accReward;

    uint256 public accPenaltyPerShare;
    uint256 public accRewardPerShare;

    uint256 public stakingEndTime;
    uint256 public stakingStartTime;

    uint256 public lastPenaltyTime;
    uint256 public lastRewardTime;

    uint256 public PRECISION_FACTOR;

    uint256 public rewardPerWeek;
    uint256 public reimbursementFee;

    address public burnAddress;
    address public marketAddress;
    IDione public dione;

    bool public isStarted;
    bool public isFinished;
    bool public isWithdrawable;

    mapping(address => UserInfo) public userInfo;

    address[] private stakers;
    Statistics public statistics;
    PenaltyTiers[] public penaltyTiers;
    PenaltyTiers public outOfTiersPenalty;

    modifier isStaking() {
        require(isStarted, "DioneStaking: NOT_STARTED");
        require(!isFinished, "DioneStaking: STAKING_FINISHED");
        _;
    }

    event Init();
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EarlyWithdraw(address indexed user, uint256 amount);

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event NewRewardPerWeek(uint256 rewardPerWeek);
    event PenaltyTierAdded(uint256 validUntil, uint256 percent);
    event PenaltyTaken(address indexed user, uint256 amount);
    event UpdateWithdrawStatus(bool withdrawable);
    event UpdateFinishStatus(bool finished);
    event UpdateBurnAccount(address indexed oldAdmin, address indexed newAdmin);

    function initialize(
        IDione _dione,
        uint256 _reimbursementFee,
        address _burnAddress,
        address _marketAddress
    ) public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __DioneStaking_init_unchained(_dione, _reimbursementFee, _burnAddress, _marketAddress);
    }

    function __DioneStaking_init_unchained(
        IDione _dione,
        uint256 _reimbursementFee,
        address _burnAddress,
        address _marketAddress
    ) internal initializer {
        require(_dione.totalSupply() >= 0);

        dione = _dione;
        reimbursementFee = _reimbursementFee;
        burnAddress = _burnAddress;
        marketAddress = _marketAddress;

        isStarted = false;
        isFinished = false;
        isWithdrawable = false;

        PRECISION_FACTOR = uint256(10**(uint256(30).sub(_dione.decimals())));
    }

    function updateOutOfTiersPenalty(uint256 _validUntil, uint256 _percent) external onlyOwner {
        outOfTiersPenalty.validUntil = _validUntil;
        outOfTiersPenalty.percent = _percent;
    }

    function addPenaltyTier(uint256 _validUntil, uint256 _percent) external onlyOwner {
        _addPenaltyTier(_validUntil, _percent);
    }

    function _addPenaltyTier(uint256 _validUntil, uint256 _percent) internal {
        penaltyTiers.push(PenaltyTiers(_validUntil, _percent));

        emit PenaltyTierAdded(_validUntil, _percent);
    }

    function getPenaltyAmount(address _user) external view returns (uint256) {
        if(isWithdrawable) return 0;

        return _calculatePenalty(_user);
    }

    function _calculatePenalty(address _user) internal view returns (uint256) {
        uint256 penaltyPercent = _getPenaltyTier(userInfo[_user].stakingTimestamp);
        return penaltyPercent.mul(userInfo[_user].amount).div(10**4);
    }

    function _getPenaltyTier(uint256 _timestamp) internal view returns (uint256) {
        uint256 penaltyPercent;
        for(uint256 i = 0; i < penaltyTiers.length; i++) {
            if(penaltyTiers[i].validUntil + _timestamp <= now) {
                penaltyPercent = penaltyTiers[i].percent;
                break;
            }
        }

        if(penaltyPercent == 0) {
            return outOfTiersPenalty.percent;
        }
        return penaltyPercent;
    }

    function init(uint256 _rewardPerWeek) external onlyOwner {
        require(!isStarted, "DioneStaking: ALREADY_STARTED");
        require(!isFinished, "DioneStaking: ALREADY_FINISHED");
        require(!isWithdrawable, "DioneStaking: WITHDRAWAL_STAGE");

        isStarted = true;
        rewardPerWeek = _rewardPerWeek;
        stakingStartTime = block.timestamp;
        lastRewardTime = stakingStartTime;
        lastPenaltyTime = stakingStartTime;
        emit Init();
    }


    function updateFinishedStatus(bool _status) external onlyOwner {
        require(isStarted, "DioneStaking: NOT_STARTED");
        require(!isWithdrawable, "DioneStaking: WITHDRAWAL_STAGE");
        stakingEndTime = block.timestamp;
        isFinished = _status;

        emit UpdateFinishStatus(_status);
    }

    function updateWithdrawStatus(bool _status) external onlyOwner {
        require(isFinished, "DioneStaking: NOT_FINISHED");
        isWithdrawable = _status;

        emit UpdateWithdrawStatus(_status);
    }

    function deposit(uint256 _amount) external isStaking nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        _updatePool();

        if (user.amount > 0) {
            uint256 pendingPenalty = user.amount.mul(accPenaltyPerShare).div(PRECISION_FACTOR).sub(user.penaltyDebt);
            if (pendingPenalty > 0) {
                user.penaltyClaimable = pendingPenalty;
            }

            uint256 pendingReward = user.amount.mul(accRewardPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
            if (pendingReward > 0) {
                user.rewardClaimable = pendingReward;
            }
        } else {
            user.stakingTimestamp = block.timestamp;
            statistics.totalStakers++;
            stakers.push(msg.sender);
        }

        if (_amount > 0) {
            uint256 allowance = dione.allowance(msg.sender, address(this));
            require(allowance >= _amount, "DioneStaking: INSUFFICIENT_ALLOWANCE");

            uint256 before = dione.balanceOf(address(this));
            dione.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 _tAmount = dione.balanceOf(address(this)).sub(before);
            uint256 _reimbursementAmount = _amount.mul(reimbursementFee).div(10**4);

            user.amount = user.amount.add(_tAmount);
            user.reimbursementAmount = user.reimbursementAmount.add(_reimbursementAmount);

            statistics.totalDeposit = statistics.totalDeposit.add(_tAmount);
            statistics.totalReimbursement = statistics.totalReimbursement.add(_reimbursementAmount);
        }

        user.rewardDebt = user.amount.mul(accRewardPerShare).div(PRECISION_FACTOR);
        user.penaltyDebt = user.amount.mul(accPenaltyPerShare).div(PRECISION_FACTOR);

        emit Deposit(msg.sender, _amount);
    }

    function withdraw() external nonReentrant {
        require(isStarted, "DioneStaking: NOT_STARTED");
        uint256 stakedAmount = userInfo[msg.sender].amount;

        require(stakedAmount > 0, "DioneStaking: INSUFFICIENT_BALANCE");
        _updatePool();

        if(!isWithdrawable) {
            _earlyWithdraw(msg.sender);
        } else {
            _withdraw(msg.sender);
        }
    }

    function massWithdraw() external onlyOwner {
        require(isWithdrawable, "DioneStaking: NOT_WITHDRAWAL");
        for(uint256 i = 0; i < stakers.length; i++) {
            uint256 amount = userInfo[stakers[i]].amount;
            if(amount > 0) {
                _withdraw(stakers[i]);
            }
        }
    }

    function _earlyWithdraw(address _user) internal {
        UserInfo storage user = userInfo[_user];

        uint256 pendingPenalty = user.amount.mul(accPenaltyPerShare).div(PRECISION_FACTOR).sub(user.penaltyDebt).add(user.penaltyClaimable);
        uint256 pendingReward = user.amount.mul(accRewardPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt).add(user.rewardClaimable);

        uint256 _penalty = _calculatePenalty(_user);
        uint256 _amount = user.amount.sub(_penalty);
        _initializeUser(_user, true);
        dione.safeTransfer(_user, _amount);

        _addPenalty(_user, pendingPenalty, _penalty, pendingReward);

        emit EarlyWithdraw(_user, _amount);
    }

    function _withdraw(address _user) internal {
        UserInfo storage user = userInfo[_user];

        uint256 pendingPenalty = user.amount.mul(accPenaltyPerShare).div(PRECISION_FACTOR).sub(user.penaltyDebt).add(user.penaltyClaimable);
        uint256 pendingReward = user.amount.mul(accRewardPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt).add(user.rewardClaimable);

        uint256 _amount = user.amount.add(user.reimbursementAmount).add(pendingPenalty).add(pendingReward);
        _initializeUser(_user, false);
        dione.safeTransfer(burnAddress, _amount);

        emit Withdraw(_user, _amount);
    }

    function _initializeUser(address _user, bool _early) internal {
        UserInfo storage user = userInfo[_user];

        if(_early) {
            statistics.totalReimbursement = statistics.totalReimbursement.sub(user.reimbursementAmount);
            statistics.totalDeposit = statistics.totalDeposit.sub(user.amount);
            statistics.totalStakers = statistics.totalReimbursement.sub(1);
        }

        user.amount = 0;
        user.rewardClaimable = 0;
        user.rewardDebt = 0;
        user.penaltyClaimable = 0;
        user.penaltyDebt = 0;
        user.reimbursementAmount = 0;
        user.stakingTimestamp = 0;
    }

    function _addPenalty(address user, uint256 pendingPenalty, uint256 penalty, uint256 pendingReward) internal {
        accPenalty = accPenalty.add(penalty).add(pendingPenalty);
        accReward = accReward.add(pendingReward);

        emit PenaltyTaken(user, penalty);
    }

    function pendingReward(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        uint256 totalStaked = statistics.totalDeposit;
        if (block.timestamp > lastRewardTime && totalStaked != 0) {
            uint256 multiplier = _getMultiplier(lastRewardTime, block.timestamp);
            uint256 rewardAmount = multiplier.mul(rewardPerWeek).add(accReward);
            uint256 adjustedTokenPerShare = accRewardPerShare.add(
                rewardAmount.mul(PRECISION_FACTOR).div(totalStaked)
            );
            return user.amount.mul(adjustedTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt).add(user.rewardClaimable);
        } else {
            return user.amount.mul(accRewardPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt).add(user.rewardClaimable);
        }
    }

    function _updatePool() internal {
        if (block.timestamp <= lastPenaltyTime && block.timestamp <= lastRewardTime) {
            return;
        }

        uint256 totalStaked = statistics.totalDeposit;
        if (totalStaked == 0) {
            lastPenaltyTime = block.timestamp;
            lastRewardTime = block.timestamp;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardTime, block.timestamp);
        uint256 rewardAmount = multiplier.mul(rewardPerWeek).add(accReward);
        accReward = 0;
        accRewardPerShare = accRewardPerShare.add(rewardAmount.mul(PRECISION_FACTOR).div(totalStaked));

        accPenaltyPerShare = accPenaltyPerShare.add(accPenalty.mul(PRECISION_FACTOR).div(totalStaked));
        accPenalty = 0;

        lastPenaltyTime = block.timestamp;
        lastRewardTime = block.timestamp;
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(dione), "DioneStaking: NOT_ALLOWED_DIONE");

        IERC20Upgradeable(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    function updateBurnAddress(address _burn) external onlyOwner {
        require(_burn != address(0), "DioneStaking: INVALID_ADDRESS");
        require(_burn != burnAddress, "DioneStaking: OLD_ADDRESS");
        address _oldAddress = burnAddress;
        burnAddress = _burn;
        emit UpdateBurnAccount(_oldAddress, _burn);
    }

    function updateRewardPerWeek(uint256 _rewardPerWeek) external onlyOwner {
        require(!isStarted, "DioneStaking: ALREADY_STARTED");

        rewardPerWeek = _rewardPerWeek;
        emit NewRewardPerWeek(_rewardPerWeek);
    }

    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if(!isStarted) return 0;

        if (!isFinished) {
            if(_from <= stakingStartTime) {
                return _to.sub(stakingStartTime).div(REWARD_PERIOD);
            } else {
                return _to.sub(_from).div(REWARD_PERIOD);
            }
        } else if (_from >= stakingEndTime) {
            return 0;
        } else {
            return stakingEndTime.sub(_from).div(REWARD_PERIOD);
        }
    }

    // Add NFTs to this application
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}