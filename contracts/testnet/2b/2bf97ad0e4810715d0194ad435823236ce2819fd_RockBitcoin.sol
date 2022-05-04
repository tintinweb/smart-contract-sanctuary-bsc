/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

// SPDX-License-Identifier: None
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: RockBitcoin.sol


pragma solidity ^0.8.7;




contract RockBitcoin is Ownable {
    // Contract handles
    IERC20 constant public BEDROCK = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);
    IERC20 constant public WBTC = IERC20(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);

    // Stake parameters
    address[] public stakerWallets;
    mapping(address => uint256) stakerWalletIndices;
    mapping(address => uint256) public rockStakes;
    mapping(address => uint256) public lastClaim;
    mapping(address => uint256) public unclaimedRock;

    // Fee mechanics
    uint8 depositFeePercent = 10;
    uint8 withdrawalFeePercent = 10;
    uint8 burnCutPercent = 50;
    uint8 paybackPercent = 25;
    uint8 treasuryPercent = 25;

    // External wallets
    address public burnWallet;
    address public treasuryWallet;
    address public moderatorWallet;

    // Modifiers
    modifier onlyModerator {
        require(_msgSender() == moderatorWallet, "Access forbidden!");
        _;
    }

    // Events
    event RockStaked(address wallet, uint256 amountDeposited, uint256 effectiveRockStaked);
    event RockUnstaked(address wallet, uint256 amountUnstaked, uint256 effectiveRockUnstaked);
    event BitcoinClaimed(address wallet, uint256 poolSharePercent, uint256 poolBtcBefore, uint256 btcReceived);

    constructor() {
        stakerWallets.push(burnWallet);
        burnWallet = 0x000000000000000000000000000000000000dEaD;
        treasuryWallet = _msgSender();
        moderatorWallet = _msgSender();
    }

    // Moderation functions
    function setFeeMechanics(uint8 _depositFeePercent, uint8 _withdrawalFeePercent, uint8 _burnCutPercent, uint8 _paybackPercent, uint8 _treasuryPercent) external onlyOwner {
        depositFeePercent = _depositFeePercent;
        withdrawalFeePercent = _withdrawalFeePercent;
        burnCutPercent = _burnCutPercent;
        paybackPercent = _paybackPercent;
        treasuryPercent = _treasuryPercent;
    }

    function setExternalWallets(address _burnWallet, address _treasuryWallet, address _moderatorWallet) external onlyOwner {
        burnWallet = _burnWallet;
        treasuryWallet = _treasuryWallet;
        moderatorWallet = _moderatorWallet;
    }

    // Staking functions
    function stakeRock(uint256 amount) external {
        BEDROCK.transferFrom(_msgSender(), address(this), amount);

        if (stakerWalletIndices[_msgSender()] == 0) {
            stakerWalletIndices[_msgSender()] = stakerWallets.length;
            stakerWallets.push(_msgSender());
        }

        uint256 remainingAmount = _deductFee(amount, true);
        rockStakes[_msgSender()] += remainingAmount;

        emit RockStaked(_msgSender(), amount, remainingAmount);
    }

    function claimBitcoin(address recipient, uint256 amount) external onlyModerator {
        WBTC.transfer(recipient, amount);
        lastClaim[recipient] = block.timestamp;
    }

    function claimRock() external {
        uint256 unclaimedAmount = unclaimedRock[_msgSender()];
        require(unclaimedAmount > 0, "You do not have any unclaimed rock left.");
        unclaimedRock[_msgSender()] = 0;
        BEDROCK.transfer(_msgSender(), unclaimedAmount);
    }

    function withdrawRock(uint256 amount) external {
        require(amount <= rockStakes[_msgSender()], "You don't have enough staked");

        if (amount == rockStakes[_msgSender()]) {
            stakerWallets[stakerWalletIndices[_msgSender()]] = stakerWallets[stakerWallets.length - 1];
            stakerWalletIndices[stakerWallets[stakerWallets.length - 1]] = stakerWalletIndices[_msgSender()];
            delete stakerWallets[stakerWallets.length - 1];
            stakerWalletIndices[_msgSender()] = 0;
        }

        uint256 remainingAmount = _deductFee(amount, false);
        rockStakes[_msgSender()] -= amount;
        BEDROCK.transfer(_msgSender(), remainingAmount);

        emit RockUnstaked(_msgSender(), amount, remainingAmount);
    }

    // Utility functions
    function calculateFee(uint256 amount, bool isDeposit) public view returns(uint256 baseFeeAmount, uint256 burnAmount, uint256 paybackAmount, uint256 treasuryAmount) {
        uint8 baseFeePercent = depositFeePercent;
        if (!isDeposit) {
            baseFeePercent = withdrawalFeePercent;
        }

        baseFeeAmount = (amount * baseFeePercent) / 100;
        burnAmount = (baseFeeAmount * burnCutPercent) / 100;
        paybackAmount = (baseFeeAmount * paybackPercent) / 100;
        treasuryAmount = (baseFeeAmount * treasuryPercent) / 100;
    }
    
    function _deductFee(uint256 amount, bool isDeposit) internal returns(uint256 remainingAmount) {
        (, uint256 burnAmount, uint256 paybackAmount, uint256 treasuryAmount) = calculateFee(amount, isDeposit);

        BEDROCK.transfer(burnWallet, burnAmount);
        BEDROCK.transfer(treasuryWallet, treasuryAmount);

        uint256 slack = _distributeRock(paybackAmount);

        remainingAmount = amount - burnAmount - paybackAmount - treasuryAmount + slack;
    }

    function _distributeRock(uint256 amount) internal returns(uint256 slack) {
        slack = amount;
        for (uint256 i = 0; i < stakerWallets.length; i++) {
            address wallet = stakerWallets[i];
            if (rockStakes[wallet] == 0 || wallet == burnWallet || wallet == address(0) || wallet == _msgSender()) {
                continue;
            }

            uint256 contractRockBalance = BEDROCK.balanceOf(address(this));
            uint256 percentageShare = (100 * rockStakes[wallet]) / contractRockBalance;
            uint256 amountToReward = (amount * percentageShare) / 100;
            unclaimedRock[wallet] += amountToReward;
            slack -= amountToReward;
        }
    }
}