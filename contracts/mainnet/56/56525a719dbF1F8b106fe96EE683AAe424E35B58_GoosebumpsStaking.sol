// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../interfaces/IERC20.sol";
import "../utils/Ownable.sol";
import "../utils/Pausable.sol";

contract GoosebumpsStaking is Ownable, Pausable {
    struct StakerInfo {
        uint256 amount;
        uint256 startBlock;
        uint256 stakeRewards;
    }

    // Staker Info
    mapping(address => StakerInfo) public staker;

    uint256 public rewardPerBlockTokenN;
    uint256 public rewardPerBlockTokenD; // Must be greater than zero

    IERC20 public stakeToken;
    IERC20 public rewardsToken;

    address public TREASURY;
    address public REWARD_WALLET;

    event LogStake(address indexed from, uint256 amount);
    event LogUnstake(
        address indexed from,
        uint256 amount,
        uint256 amountRewards
    );
    event LogRewardsWithdrawal(address indexed to, uint256 amount);
    event LogSetTreasury(address indexed newTreasury);
    event LogSetRewardWallet(address indexed newRewardWallet);
    event LogSetRewardsToken(address indexed rewardsToken);
    event LogSetStakeToken(address indexed stakeToken);
    event LogSetRewardPerBlockToken(uint256 rewardPerBlockTokenN, uint256 rewardPerBlockTokenD);

    constructor(
        IERC20 _stakeToken,
        IERC20 _rewardsToken,
        address _treasury,
        address _rewardWallet,
        uint256 _rewardPerBlockTokenN,
        uint256 _rewardPerBlockTokenD
    ) {
        require(
            address(_stakeToken) != address(0) && 
            address(_rewardsToken) != address(0) && 
            _treasury != address(0) && 
            _rewardWallet != address(0), 
            "ZERO_ADDRESS"
        );
        require(_rewardPerBlockTokenD != 0, "ZERO_VALUE");
        stakeToken = _stakeToken;
        rewardsToken = _rewardsToken;
        TREASURY = _treasury;
        REWARD_WALLET = _rewardWallet;
        rewardPerBlockTokenN = _rewardPerBlockTokenN;
        rewardPerBlockTokenD = _rewardPerBlockTokenD;
    }

    function stake(uint256 _amount) external whenNotPaused {
        require(_amount > 0, "Staking amount must be greater than zero");

        require(
            stakeToken.balanceOf(msg.sender) >= _amount,
            "Insufficient stakeToken balance"
        );

        if (staker[msg.sender].amount > 0) {
            staker[msg.sender].stakeRewards = getTotalRewards(msg.sender);
        }

        require(
            stakeToken.transferFrom(msg.sender, TREASURY, _amount),
            "TransferFrom fail"
        );

        staker[msg.sender].amount += _amount;
        staker[msg.sender].startBlock = block.number;
        emit LogStake(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external whenNotPaused {
        require(_amount > 0, "Unstaking amount must be greater than zero");
        require(staker[msg.sender].amount >= _amount, "Insufficient unstake");

        uint256 amountWithdraw = _withdrawRewards();
        staker[msg.sender].amount -= _amount;
        staker[msg.sender].startBlock = block.number;
        staker[msg.sender].stakeRewards = 0;

        require(
            stakeToken.transferFrom(TREASURY, msg.sender, _amount),
            "TransferFrom fail"
        );

        emit LogUnstake(msg.sender, _amount, amountWithdraw);
    }

    function _withdrawRewards() internal returns (uint256) {
        uint256 amountWithdraw = getTotalRewards(msg.sender);
        if (amountWithdraw > 0) {
            require(
                rewardsToken.transferFrom(
                    REWARD_WALLET,
                    msg.sender,
                    amountWithdraw
                ),
                "TransferFrom fail"
            );
        }
        return amountWithdraw;
    }

    function withdrawRewards() external whenNotPaused {
        uint256 amountWithdraw = _withdrawRewards();
        require(amountWithdraw > 0, "Insufficient rewards balance");
        staker[msg.sender].startBlock = block.number;
        staker[msg.sender].stakeRewards = 0;

        emit LogRewardsWithdrawal(msg.sender, amountWithdraw);
    }

    function getTotalRewards(address _staker) public view returns (uint256) {
        uint256 newRewards = ((block.number - staker[_staker].startBlock) *
            staker[_staker].amount *
            rewardPerBlockTokenN) / rewardPerBlockTokenD;
        return newRewards + staker[_staker].stakeRewards;
    }

    function setTreasury(address _treasury) external onlyMultiSig {
        require(address(0) != _treasury, "ZERO_ADDRESS");
        require(TREASURY != _treasury, "SAME_ADDRESS");
        TREASURY = _treasury;
        emit LogSetTreasury(TREASURY);
    }

    function setRewardWallet(address _rewardWallet) external onlyMultiSig {
        require(address(0) != _rewardWallet, "ZERO_ADDRESS");
        require(REWARD_WALLET != _rewardWallet, "SAME_ADDRESS");
        REWARD_WALLET = _rewardWallet;
        emit LogSetRewardWallet(REWARD_WALLET);
    }

    function setRewardPerBlockToken(uint256 _rewardPerBlockTokenN, uint256 _rewardPerBlockTokenD) external onlyMultiSig {
        require(_rewardPerBlockTokenD != 0, "ZERO_VALUE");
        require(!(rewardPerBlockTokenN == _rewardPerBlockTokenN && rewardPerBlockTokenD == _rewardPerBlockTokenD), "SAME_VALUE");
        rewardPerBlockTokenN = _rewardPerBlockTokenN;
        rewardPerBlockTokenD = _rewardPerBlockTokenD;

        emit LogSetRewardPerBlockToken(rewardPerBlockTokenN, rewardPerBlockTokenD);
    }

    function setStakeToken(address _stakeToken) external onlyMultiSig {
        require(_stakeToken != address(0), "ZERO_ADDRESS");
        require(_stakeToken != address(stakeToken), "SAME_ADDRESS");
        stakeToken = IERC20(_stakeToken);

        emit LogSetStakeToken(_stakeToken);
    }

    function setRewardsToken(address _rewardsToken) external onlyMultiSig {
        require(_rewardsToken != address(0), "ZERO_ADDRESS");
        require(_rewardsToken != address(rewardsToken), "SAME_ADDRESS");
        rewardsToken = IERC20(_rewardsToken);
        
        emit LogSetRewardsToken(_rewardsToken);
    }

    function setPause() external onlyMultiSig {
        _pause();
    }

    function setUnpause() external onlyMultiSig {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.7;

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.7;

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
 * `onlyMultiSig`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    /**
     * @dev Must be Multi-Signature Wallet.
     */
    address private _multiSigOwner;

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
    modifier onlyMultiSig() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _multiSigOwner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyMultiSig` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyMultiSig {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyMultiSig {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _multiSigOwner;
        _multiSigOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity 0.8.7;

import "./Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.7;

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
}