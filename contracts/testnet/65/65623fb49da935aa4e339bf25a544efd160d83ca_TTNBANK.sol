/**
 *Submitted for verification at BscScan.com on 2022-10-15
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

// File: contracts/interfaces/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity 0.8.4;


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
}

// File: contracts/TTNBANK.sol



pragma solidity 0.8.4;





contract TTNBANK is Ownable, Pausable, ReentrancyGuard {
    uint256 public constant MIN_DEPOSIT_AMOUNT = 20; // Note: 20 * 10**decimals
    uint256 public constant MAX_DEPOSIT_AMOUNT = 25000; // Note: 25000 * 10**decimals

    uint256 public constant MIN_APY = 1; // for only test
    uint256 public constant MAX_APY = 1000000; // for only test

    uint256 public constant REFERRAL_PERCENT = 1000;
    uint256 public constant DEPOSIT_FEE = 100;
    uint256 public constant WITHDRAW_FEE = 50;
    uint256 public constant DEV_FEE = 1000;

    uint256 public constant DENOMINATOR = 10000; // 1: 0.01%(0.0001), 100: 1%(0.01), 10000: 100%(1)

    address public treasury;
    address public devWallet;

    uint256 public immutable startTime;
    uint256 public immutable epochLength;

    IERC20Metadata public token;

    uint256 public epochNumber; // increase one by one per epoch

    mapping(uint256 => uint256) public apy; // epochNumber => apy, apyValue = (apy / DENOMINATOR * 100) %

    mapping(address => mapping(uint256 => uint256)) public amount; // staker => (epochNumber => stakedAmount)
    mapping(address => uint256) public lastClaimEpochNumber; // staker => lastClaimEpochNumber
    mapping(address => uint256) public lastActionEpochNumber; // staker => lastActionEpochNumber
    mapping(address => uint256) public lastRewards; // staker => lastReward
    mapping(address => uint256) public totalRewards; // staker => totalReward
    mapping(address => address) public referrals; // staker => referral

    mapping(address => uint256) public referralRewards; // referral => referralReward
    mapping(address => uint256) public referralTotalRewards; // referral => referral => referralReward

    event LogSetDevWallet(address indexed devWallet);
    event LogSetTreasury(address indexed treasury);
    event LogSetToken(address indexed token);
    event LogSetAPY(uint256 indexed apy);
    event LogDeposit(
        address indexed staker,
        uint256 indexed epochNumber,
        uint256 indexed stakedAmount
    );
    event LogSetReferral(address indexed user, address indexed referral);
    event LogWithdraw(
        address indexed staker,
        uint256 epochNumber,
        uint256 indexed stakedAmount
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

    constructor(
        IERC20Metadata _token,
        uint256 _epochLength,
        uint256 _apy,
        address _treasury,
        address _devWallet
    ) {
        setToken(_token);
        epochLength = _epochLength;
        apy[0] = _apy;
        _setAPY(_apy);
        setTreasury(_treasury);
        setDevWallet(_devWallet);
        startTime = block.timestamp;
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

    function setToken(IERC20Metadata _token) public onlyOwner {
        require(address(_token) != address(0), "setToken: ZERO_ADDRESS");
        require(address(_token) != address(token), "setToken: SAME_ADDRESS");

        token = _token;
        emit LogSetToken(address(token));
    }

    function _setAPY(uint256 _apy) internal {
        apy[epochNumber + 1] = _apy;
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
        require(
            MIN_DEPOSIT_AMOUNT * 10**token.decimals() <= _amount &&
                _amount <= MAX_DEPOSIT_AMOUNT * 10**token.decimals(),
            "deposit: OUT_BOUNDARY"
        );

        _setNewEpoch();

        uint256 depositFee = (_amount * DEPOSIT_FEE) / DENOMINATOR;

        require(
            token.transferFrom(msg.sender, address(this), _amount - depositFee),
            "deposit: TRANSFERFROM_FAIL"
        );

        require(
            token.transferFrom(
                msg.sender,
                treasury,
                (depositFee * (DENOMINATOR - DEV_FEE)) / DENOMINATOR
            ),
            "deposit: TRANSFERFROM_TO_TREASURY_FAIL"
        );

        require(
            token.transferFrom(
                msg.sender,
                devWallet,
                (depositFee * DEV_FEE) / DENOMINATOR
            ),
            "deposit: TRANSFERFROM_TO_DEV_FAIL"
        );

        for (
            uint256 index = epochNumber;
            index > lastActionEpochNumber[msg.sender] + 1;
            index--
        ) {
            amount[msg.sender][index] = amount[msg.sender][
                lastActionEpochNumber[msg.sender] + 1
            ];
        }

        if (epochNumber == lastActionEpochNumber[msg.sender]) {
            amount[msg.sender][epochNumber + 1] += _amount;
        } else {
            amount[msg.sender][epochNumber + 1] =
                amount[msg.sender][epochNumber] +
                _amount;
        }

        if (
            referrals[msg.sender] == address(0) &&
            _referral != msg.sender &&
            _referral != address(0)
        ) {
            referrals[msg.sender] = _referral;
            emit LogSetReferral(msg.sender, _referral);
        }

        lastActionEpochNumber[msg.sender] = epochNumber;

        emit LogDeposit(
            msg.sender,
            epochNumber + 1,
            amount[msg.sender][epochNumber + 1]
        );
    }

    function withdraw(uint256 _amount) external whenNotPaused nonReentrant {
        require(_amount > 0, "withdraw: ZERO_WITHDRAW_AMOUNT");

        _withdrawReward();

        uint256 withdrawFee = (_amount * WITHDRAW_FEE) / DENOMINATOR;

        require(
            token.transfer(msg.sender, _amount - withdrawFee),
            "withdraw: TRANSFER_FAIL"
        );

        require(
            token.transfer(
                treasury,
                (withdrawFee * (DENOMINATOR - DEV_FEE)) / DENOMINATOR
            ),
            "withdraw: TRANSFER_TO_TREASURY_FAIL"
        );

        require(
            token.transfer(devWallet, (withdrawFee * DEV_FEE) / DENOMINATOR),
            "withdraw: TRANSFER_TO_DEV_FAIL"
        );

        if (epochNumber == lastActionEpochNumber[msg.sender]) {
            require(
                amount[msg.sender][epochNumber + 1] >= _amount,
                "withdraw: INSUFFICIENT_STAKED_NEXT_BALANCE"
            );

            amount[msg.sender][epochNumber + 1] -= _amount;
        } else {
            require(
                amount[msg.sender][epochNumber] >= _amount,
                "withdraw: INSUFFICIENT_STAKED_BALANCE"
            );

            amount[msg.sender][epochNumber + 1] =
                amount[msg.sender][epochNumber] -
                _amount;
        }

        lastActionEpochNumber[msg.sender] = epochNumber;

        emit LogWithdraw(
            msg.sender,
            epochNumber + 1,
            amount[msg.sender][epochNumber + 1]
        );
    }

    function _withdrawReward() internal returns (bool hasReward) {
        _setNewEpoch();
        for (
            uint256 index = epochNumber;
            index > lastActionEpochNumber[msg.sender] + 1;
            index--
        ) {
            amount[msg.sender][index] = amount[msg.sender][
                lastActionEpochNumber[msg.sender] + 1
            ];
        }

        uint256 pendingReward;
        for (
            uint256 index = lastClaimEpochNumber[msg.sender];
            index < epochNumber;
            index++
        ) {
            pendingReward += amount[msg.sender][index] * apy[index];
        }

        if (pendingReward > 0) {
            hasReward = true;
            uint256 withdrawRewardFee = (pendingReward * WITHDRAW_FEE) /
                DENOMINATOR;

            uint256 userReward = pendingReward - withdrawRewardFee;
            uint256 referralReward = (userReward * REFERRAL_PERCENT) /
                DENOMINATOR;

            require(
                token.transfer(msg.sender, userReward - referralReward),
                "_withdrawReward: TRANSFER_FAIL"
            );

            referralRewards[referrals[msg.sender]] += referralReward;

            require(
                token.transfer(
                    treasury,
                    (withdrawRewardFee * (DENOMINATOR - DEV_FEE)) / DENOMINATOR
                ),
                "_withdrawReward: TRANSFER_TO_TREASURY_FAIL"
            );

            require(
                token.transfer(
                    devWallet,
                    (withdrawRewardFee * DEV_FEE) / DENOMINATOR
                ),
                "_withdrawReward: TRANSFER_TO_DEV_FAIL"
            );

            lastClaimEpochNumber[msg.sender] = epochNumber;
            lastRewards[msg.sender] = pendingReward;
            totalRewards[msg.sender] += pendingReward;

            emit LogWithdrawReward(msg.sender, epochNumber, pendingReward);
        } else {
            hasReward = false;
        }
    }

    function withdrawReward() external whenNotPaused nonReentrant {
        require(_withdrawReward(), "withdrawReward: NO_REWARD");
        lastActionEpochNumber[msg.sender] = epochNumber;
    }

    function getPendingReward(address user)
        external
        view
        returns (uint256 pendingReward)
    {
        for (
            uint256 index = lastClaimEpochNumber[user];
            index < lastActionEpochNumber[user];
            index++
        ) {
            pendingReward += amount[user][index] * apy[index];
        }

        uint256 newEpochNumber = epochLength +
            (block.timestamp - startTime - epochLength * epochNumber) /
            epochLength;
        for (
            uint256 index = lastActionEpochNumber[user];
            index < newEpochNumber;
            index++
        ) {
            uint256 amountValue = (index == lastActionEpochNumber[user])
                ? amount[user][index]
                : amount[user][lastActionEpochNumber[user] + 1];
            uint256 apyValue = (
                apy[index] > 0 ? apy[index] : (apy[epochNumber + 1] > 0)
                    ? apy[epochNumber + 1]
                    : apy[epochNumber]
            );
            pendingReward += amountValue * apyValue;
        }
    }

    function _setNewEpoch() internal {
        uint256 delta = block.timestamp - startTime;
        if (delta >= epochLength * (epochNumber + 1)) {
            uint256 increaseValue = (delta - epochLength * epochNumber) /
                epochLength;

            uint256 apyValue = apy[epochNumber];

            for (
                uint256 index = epochNumber + 1;
                index <= epochNumber + increaseValue + 1;
                index++
            ) {
                apy[index] = apy[index] > 0 ? apy[index] : apyValue;
            }

            epochNumber += increaseValue;

            emit LogSetNewEpoch(epochNumber);
        }
    }

    function withdrawReferral() external whenNotPaused nonReentrant {
        require(
            referralRewards[msg.sender] > 0,
            "withdrawReferral: ZERO_AMOUNT"
        );
        require(
            token.transfer(msg.sender, referralRewards[msg.sender]),
            "withdrawReferral: TRANSFER_FAIL"
        );
        referralTotalRewards[msg.sender] += referralRewards[msg.sender];
        referralRewards[msg.sender] = 0;

        emit LogWithdrawReferral(msg.sender, referralRewards[msg.sender]);
    }
}