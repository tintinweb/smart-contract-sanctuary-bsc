/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT

// File: contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity 0.8.4;

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

// File: contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.4;

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

// File: contracts/utils/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity 0.8.4;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts/utils/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.4;


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

// File: contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.4;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: contracts/TTNBANK.sol



pragma solidity 0.8.4;





contract TTNBANK is Ownable, Pausable, ReentrancyGuard {
    struct UserInfo {
        uint256 requestAmount; // staker => requestAmount
        uint256 requestEpochNumber; // staker => requestEpochNumber
        uint256 pendingClaimEpochNumber; // staker => pendingClaimEpochNumber
        uint256 lastActionEpochNumber; // staker => lastActionEpochNumber
        uint256 lastRewards; // staker => lastReward
        uint256 totalRewards; // staker => totalReward
        address referrals; // staker => referral
    }

    uint256 public constant MIN_APY = 1; // for only test
    uint256 public constant MAX_APY = 10**6; // for only test

    uint256 public constant REFERRAL_PERCENT = 1000; // 10%
    uint256 public constant WITHDRAW_FEE = 100; // 1%
    uint256 public constant DEV_FEE = 1000; // 10%

    uint256 public constant DENOMINATOR = 10000; // 1: 0.01%(0.0001), 100: 1%(0.01), 10000: 100%(1)

    uint256 public immutable START_TIME;
    uint256 public immutable EPOCH_LENGTH;
    uint256 public immutable WITHDRAW_TIME;

    address public treasury;
    address public devWallet;

    IERC20 public stakedToken;

    uint256 public epochNumber; // increase one by one per epoch
    uint256 public totalAmount; // total staked amount

    mapping(uint256 => uint256) public apy; // epochNumber => apy, apyValue = (apy / DENOMINATOR * 100) %

    mapping(address => mapping(uint256 => uint256)) public amount; // staker => (epochNumber => stakedAmount)
    mapping(address => UserInfo) public userInfo; // staker => userInfo

    mapping(address => uint256) public referralRewards; // referral => referralReward
    mapping(address => uint256) public referralTotalRewards; // referral => referral => referralReward

    event LogSetDevWallet(address indexed devWallet);
    event LogSetTreasury(address indexed treasury);
    event LogSetStakedToken(address indexed stakedToken);
    event LogSetAPY(uint256 indexed apy);
    event LogDeposit(
        address indexed staker,
        uint256 indexed epochNumber,
        uint256 indexed depositAmount
    );
    event LogSetReferral(address indexed user, address indexed referral);
    event LogWithdraw(
        address indexed staker,
        uint256 epochNumber,
        uint256 indexed withdrawAmount
    );
    event LogWithdrawReward(
        address indexed user,
        uint256 indexed epochNumber,
        uint256 indexed reward
    );
    event LogSetNewEpoch(uint256 indexed epochNumber);
    event LogWithdrawReferral(
        address indexed referral,
        uint256 indexed referralReward
    );
    event LogInjectFunds(uint256 indexed injectAmount);
    event LogEjectFunds(uint256 indexed ejectAmount);

    constructor(
        IERC20 _stakedToken,
        uint256 _apy,
        address _treasury,
        address _devWallet,
        uint256 _startTime,
        uint256 _epochLength,
        uint256 _withdrawTime
    ) {
        setStakedToken(_stakedToken);
        _setAPY(_apy);
        setTreasury(_treasury);
        setDevWallet(_devWallet);
        START_TIME = _startTime;
        EPOCH_LENGTH = _epochLength;
        WITHDRAW_TIME = _withdrawTime;
    }

    function setDevWallet(address _devWallet) public onlyOwner {
        require(_devWallet != address(0), "setDevWallet: ZERO_ADDRESS");
        require(_devWallet != devWallet, "setDevWallet: SAME_ADDRESS");

        devWallet = _devWallet;

        emit LogSetDevWallet(devWallet);
    }

    function setTreasury(address _treasury) public onlyOwner {
        require(_treasury != address(0), "setTreasury: ZERO_ADDRESS");
        require(_treasury != treasury, "setTreasury: ZERO_ADDRESS");

        treasury = _treasury;
        emit LogSetTreasury(treasury);
    }

    function setPause() external onlyOwner {
        _pause();
    }

    function setUnpause() external onlyOwner {
        _unpause();
    }

    function setStakedToken(IERC20 _stakedToken) public onlyOwner {
        stakedToken = _stakedToken;
        emit LogSetStakedToken(address(stakedToken));
    }

    function _setAPY(uint256 _apy) internal {
        apy[epochNumber] = _apy;
        emit LogSetAPY(_apy);
    }

    function setAPY(uint256 _apy) external onlyOwner {
        _setNewEpoch();
        _setAPY(_apy);
    }

    function deposit(uint256 _amount, address _referral)
        external
        whenNotPaused
        nonReentrant
    {
        _setNewEpoch();

        require(
            stakedToken.transferFrom(msg.sender, address(this), _amount),
            "deposit: TRANSFERFROM_FAIL"
        );

        totalAmount += _amount;

        if (epochNumber < 1) {
            amount[msg.sender][0] += _amount;
        } else {
            for (
                uint256 index = epochNumber - 1;
                index > userInfo[msg.sender].lastActionEpochNumber;
                index--
            ) {
                amount[msg.sender][index] = amount[msg.sender][
                    userInfo[msg.sender].lastActionEpochNumber
                ];
            }

            if (epochNumber == userInfo[msg.sender].lastActionEpochNumber) {
                amount[msg.sender][epochNumber] += _amount;
            } else {
                amount[msg.sender][epochNumber] =
                    amount[msg.sender][epochNumber - 1] +
                    _amount;
            }
        }

        if (
            userInfo[msg.sender].referrals == address(0) &&
            _referral != msg.sender &&
            _referral != address(0)
        ) {
            userInfo[msg.sender].referrals = _referral;
            emit LogSetReferral(msg.sender, _referral);
        }

        userInfo[msg.sender].lastActionEpochNumber = epochNumber;

        emit LogDeposit(msg.sender, epochNumber, _amount);
    }

    function withdraw(uint256 _amount) external whenNotPaused nonReentrant {
        bool hasReward = _withdrawReward();
        require(
            hasReward || _amount > 0,
            "withdraw: NO_REWARD_OR_ZERO_WITHDRAW"
        );

        userInfo[msg.sender].lastActionEpochNumber = epochNumber;

        if (_amount > 0) {
            uint256 withdrawStart = START_TIME +
                userInfo[msg.sender].requestEpochNumber *
                EPOCH_LENGTH;
            require(
                withdrawStart <= block.timestamp &&
                    block.timestamp < withdrawStart + WITHDRAW_TIME,
                "withdraw: TIME_OVER"
            );

            uint256 requestAmount = userInfo[msg.sender].requestAmount;
            uint256 enableAmount = amount[msg.sender][
                userInfo[msg.sender].requestEpochNumber - 1
            ];

            require(
                _amount <= enableAmount && _amount <= requestAmount,
                "withdraw: INSUFFICIENT_REQUEST_OR_ENABLE_AMOUNT"
            );

            userInfo[msg.sender].requestAmount -= _amount;

            uint256 withdrawFee = (_amount * WITHDRAW_FEE) / DENOMINATOR;

            require(
                stakedToken.transfer(msg.sender, _amount - withdrawFee),
                "withdraw: TRANSFER_FAIL"
            );

            require(
                stakedToken.transfer(
                    treasury,
                    (withdrawFee * (DENOMINATOR - DEV_FEE)) / DENOMINATOR
                ),
                "withdraw: TRANSFERFROM_TO_TREASURY_FAIL"
            );

            require(
                stakedToken.transfer(
                    devWallet,
                    (withdrawFee * DEV_FEE) / DENOMINATOR
                ),
                "withdraw: TRANSFERFROM_TO_DEV_FAIL"
            );

            totalAmount -= _amount;

            amount[msg.sender][epochNumber] -= _amount;

            emit LogWithdraw(msg.sender, epochNumber, _amount);
        }
    }

    function _withdrawReward() internal returns (bool hasReward) {
        _setNewEpoch();
        for (
            uint256 index = epochNumber;
            index > userInfo[msg.sender].lastActionEpochNumber;
            index--
        ) {
            amount[msg.sender][index] = amount[msg.sender][
                userInfo[msg.sender].lastActionEpochNumber
            ];
        }

        uint256 pendingReward;
        if (epochNumber > 1) {
            for (
                uint256 index = userInfo[msg.sender].pendingClaimEpochNumber;
                index < epochNumber - 1;
                index++
            ) {
                pendingReward +=
                    (amount[msg.sender][index] * apy[index]) /
                    DENOMINATOR;
            }
            userInfo[msg.sender].pendingClaimEpochNumber = epochNumber - 1;
        }

        if (pendingReward > 0) {
            hasReward = true;

            uint256 referralReward = (pendingReward * REFERRAL_PERCENT) /
                DENOMINATOR;

            pendingReward -= referralReward;
            uint256 withdrawFee = (pendingReward * WITHDRAW_FEE) / DENOMINATOR;

            require(
                stakedToken.transferFrom(
                    treasury,
                    msg.sender,
                    pendingReward - withdrawFee
                ),
                "_withdrawReward: TRANSFERFROM_FAIL"
            );

            require(
                stakedToken.transferFrom(
                    treasury,
                    devWallet,
                    (withdrawFee * DEV_FEE) / DENOMINATOR
                ),
                "_withdrawReward: TRANSFERFROM_TO_DEV_FAIL"
            );

            referralRewards[userInfo[msg.sender].referrals] += referralReward;

            userInfo[msg.sender].lastRewards = pendingReward;
            userInfo[msg.sender].totalRewards += pendingReward;

            emit LogWithdrawReward(msg.sender, epochNumber, pendingReward);
        } else {
            hasReward = false;
        }
    }

    function getPendingReward(address user)
        external
        view
        returns (uint256 pendingReward)
    {
        if (block.timestamp >= START_TIME + EPOCH_LENGTH) {
            uint256 newEpochNumber = (block.timestamp - START_TIME) /
                EPOCH_LENGTH;
            for (
                uint256 index = userInfo[user].pendingClaimEpochNumber;
                index < newEpochNumber;
                index++
            ) {
                uint256 amountValue = amount[user][index] > 0
                    ? amount[user][index]
                    : amount[user][userInfo[user].lastActionEpochNumber];
                uint256 apyValue = (
                    apy[index] > 0 ? apy[index] : apy[epochNumber]
                );
                pendingReward += (amountValue * apyValue) / DENOMINATOR;
            }

            pendingReward -= (pendingReward * REFERRAL_PERCENT) / DENOMINATOR;
        }
    }

    function _setNewEpoch() internal {
        if (block.timestamp < START_TIME) return;
        uint256 newEpochNumber = (block.timestamp - START_TIME) /
            EPOCH_LENGTH +
            1;
        if (newEpochNumber > epochNumber) {
            uint256 apyValue = apy[epochNumber];

            for (
                uint256 index = epochNumber + 1;
                index <= newEpochNumber;
                index++
            ) {
                apy[index] = apyValue;
            }

            epochNumber = newEpochNumber;

            emit LogSetNewEpoch(epochNumber);
        }
    }

    function withdrawReferral() external whenNotPaused nonReentrant {
        require(
            referralRewards[msg.sender] > 0,
            "withdrawReferral: ZERO_AMOUNT"
        );
        require(
            stakedToken.transferFrom(
                treasury,
                msg.sender,
                referralRewards[msg.sender]
            ),
            "withdrawReferral: TRANSFER_FAIL"
        );
        referralTotalRewards[msg.sender] += referralRewards[msg.sender];

        emit LogWithdrawReferral(msg.sender, referralRewards[msg.sender]);

        referralRewards[msg.sender] = 0;
    }

    function withdrawRequest(uint256 _amount)
        external
        whenNotPaused
        nonReentrant
    {
        _setNewEpoch();
        userInfo[msg.sender].requestEpochNumber = epochNumber > 0
            ? epochNumber
            : 1;
        userInfo[msg.sender].requestAmount = _amount;
    }

    /**
     * @notice Inject funds to distribute to stakers.
     */
    function injectFunds(uint256 _injectAmount) external onlyOwner {
        require(
            stakedToken.transferFrom(treasury, address(this), _injectAmount),
            "injectFunds: TRANSFERFROM_INJECT_FAIL"
        );

        emit LogInjectFunds(_injectAmount);
    }

    /**
     * @notice Eject funds to make profit for stakers.
     */
    function ejectFunds(uint256 _amount) external onlyOwner {
        uint256 ejectEnabledAmount = stakedToken.balanceOf(address(this));

        require(
            _amount <= ejectEnabledAmount,
            "ejectFunds: OVERFLOW_EJECT_ENABLED_AMOUNT"
        );

        require(
            stakedToken.transfer(treasury, _amount),
            "ejectFunds: TRANSFER_FAIL"
        );

        emit LogEjectFunds(_amount);
    }
}