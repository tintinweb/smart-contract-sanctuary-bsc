/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// File: contracts/interfaces/IBotPrevention.sol



pragma solidity ^0.8.0;

interface IBotPrevention {
    function protect(
        address sender,
        address receiver,
        uint256 amount
    ) external;
}
// File: contracts/BotPrevention.sol



pragma solidity ^0.8.0;





contract BotPrevention is IBotPrevention, Ownable {

    struct Configuration {
        bool gasLimitEnabled;
        bool whitelistEnabled;
        bool limitSellEnabled;
        uint256 duration;
        uint256 lockDuration;
        uint256 maxBuyTokenPerTx;
        uint256 releasePercent;
        uint256 cooldownDuration;
        uint256 gasPriceLimit;
        address tokenAddress;
        address pairAddress;
    }

    // Token Address
    address public tokenAddress = 0xC008debBB1f33d9453FFd2104fEB1fe7E9663524;
    
    address public pairAddress;

    // Flag BP
    bool public gasLimitEnabled = true;
    bool public whitelistEnabled = true;
    bool public limitSellEnabled = true;

    uint256 public listingBlock;
    uint256 public startTime;

    uint256 public duration = 180 seconds;
    uint256 public maxBuyTokenPerTx = 25000000000000000000000 wei;

    uint256 public lockDuration = 86400 seconds;
    uint256 public releasePercent = 20;
    uint256 public cooldownDuration = 30 seconds;

    uint256 public gasPriceLimit = 11000000000 wei;

    mapping(address => AddressReputation) public addressReputationMap;

    event AddWhiteListEvent(
        address[] _whitelistAddress
    );

    event RemoveWhitelistEvent(
        address[] _whitelistAddress
    );

    event AddBlackListEvent(
        address[] _blacklistAddress
    );

    event RemoveBlacklistEvent(
        address[] _blacklistAddress
    );

    event LockPurchaseEvent(address buyer, uint256 amount);

    struct AddressReputation {
        uint256 lockAmount;
        bool isWhitelist;
        bool isBlacklist;
        uint256 lastBuyTime;
        uint256 lastSellTime;
    }

    constructor() {}

    function getConfiguration() external view returns (Configuration memory) {
        Configuration memory conf = Configuration({
            gasLimitEnabled: gasLimitEnabled,
            whitelistEnabled: whitelistEnabled,
            limitSellEnabled: limitSellEnabled,
            duration: duration,
            lockDuration: lockDuration,
            maxBuyTokenPerTx: maxBuyTokenPerTx,
            releasePercent: releasePercent,
            cooldownDuration: cooldownDuration,
            gasPriceLimit: gasPriceLimit,
            tokenAddress: tokenAddress,
            pairAddress: pairAddress
        });
        return conf;
    }

    function addWhitelist(address[] calldata _whitelistAddress) external onlyOwner {
        require(_whitelistAddress.length > 0, '_whitelistAddress must have length > 0');

        for (uint256 i = 0; i < _whitelistAddress.length; i++) {
            address targetAddress = _whitelistAddress[i];
            AddressReputation storage addressReputation = addressReputationMap[targetAddress];

            addressReputation.isWhitelist = true;
        }

        emit AddWhiteListEvent(_whitelistAddress);
    }

    function removeWhitelist(address[] calldata _whitelistAddress) external onlyOwner {
        require(_whitelistAddress.length > 0, '_whitelistAddress must have length > 0');

        for (uint256 i = 0; i < _whitelistAddress.length; i++) {
            address targetAddress = _whitelistAddress[i];

            AddressReputation storage addressReputation = addressReputationMap[targetAddress];

            addressReputation.isWhitelist = false;
        }

        emit RemoveWhitelistEvent(_whitelistAddress);
    }

    function addBlacklist(address[] calldata _blacklistAddress) external onlyOwner {
        require(_blacklistAddress.length > 0, '_blacklistAddress must have length > 0');

        for (uint256 i = 0; i < _blacklistAddress.length; i++) {
            address targetAddress = _blacklistAddress[i];
            AddressReputation storage addressReputation = addressReputationMap[targetAddress];

            addressReputation.isBlacklist = true;
        }

        emit AddBlackListEvent(_blacklistAddress);
    }

    function removeBlacklist(address[] calldata _blacklistAddress) external onlyOwner {
        require(_blacklistAddress.length > 0, '_blacklistAddress must have length > 0');

        for (uint256 i = 0; i < _blacklistAddress.length; i++) {
            address targetAddress = _blacklistAddress[i];

            AddressReputation storage addressReputation = addressReputationMap[targetAddress];

            addressReputation.isBlacklist = false;
        }

        emit RemoveBlacklistEvent(_blacklistAddress);
    }

    function updateBPFlags(bool _gasLimitEnabled, bool _whitelistEnabled, bool _limitSellEnabled) external onlyOwner {
        gasLimitEnabled = _gasLimitEnabled;
        whitelistEnabled = _whitelistEnabled;
        limitSellEnabled = _limitSellEnabled;
    }

    function updateConfiguration(
        uint256 _duration,
        uint256 _lockDuration,
        uint256 _maxBuyTokenPerTx,
        uint256 _releasePercent,
        uint256 _cooldownDuration,
        uint256 _gasPriceLimit
    ) external onlyOwner {
        require(_duration > 0, "Duration must be > 0");
        require(_maxBuyTokenPerTx > 0, "maxBuyTokenPerTx should be > 0");
        require(_releasePercent <= 100, "releasePercent should be <= 100");

        duration = _duration;
        lockDuration = _lockDuration;
        maxBuyTokenPerTx = _maxBuyTokenPerTx;
        releasePercent = _releasePercent;
        cooldownDuration = _cooldownDuration;
        gasPriceLimit = _gasPriceLimit;
    }

    function updateFlagsAndConfiguration(
        uint256 _duration,
        uint256 _lockDuration,
        uint256 _maxBuyTokenPerTx,
        uint256 _releasePercent,
        uint256 _cooldownDuration,
        uint256 _gasPriceLimit,
        bool _gasLimitEnabled, 
        bool _whitelistEnabled, 
        bool _limitSellEnabled
    ) external onlyOwner {
        require(_duration > 0, "Duration must be > 0");
        require(_maxBuyTokenPerTx > 0, "maxBuyTokenPerTx should be > 0");
        require(_releasePercent <= 100, "releasePercent should be <= 100");

        duration = _duration;
        lockDuration = _lockDuration;
        maxBuyTokenPerTx = _maxBuyTokenPerTx;
        releasePercent = _releasePercent;
        cooldownDuration = _cooldownDuration;
        gasPriceLimit = _gasPriceLimit;
        gasLimitEnabled = _gasLimitEnabled;
        whitelistEnabled = _whitelistEnabled;
        limitSellEnabled = _limitSellEnabled;
    }

    function updateTokenAddress(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0x0), "Cannot be 0x0");
        tokenAddress = _tokenAddress;
    }

    function updatePairAddress(address _pairAddress) external onlyOwner {
        require(_pairAddress != address(0x0), "Cannot be 0x0");
        pairAddress = _pairAddress;
    }

    function protect(
        address sender,
        address receiver,
        uint256 amount
    ) external override onlyToken {
        AddressReputation storage senderReputation = addressReputationMap[sender];
        AddressReputation storage receiverReputation = addressReputationMap[receiver];
        AddressReputation storage originReputation = addressReputationMap[tx.origin];

        if (listingBlock == 0) {
            if (receiver == pairAddress && pairAddress != address(0x0) && amount > 0) {
                listingBlock = block.number;
                startTime = block.timestamp;
            }
            
            return;
        }

        bool isInLockTime = block.timestamp < (startTime + lockDuration);

        if (!isInLockTime) {
            return;
        }

        bool isInProtectTime = block.timestamp < (startTime + duration);
        bool isBuyTx = sender == pairAddress && pairAddress != address(0x0);

        if (isBuyTx && isInProtectTime) {
            require(amount <= maxBuyTokenPerTx, "Whale alert");
            require(block.number - listingBlock > 3, "Don't cheat us");
            require(!receiverReputation.isBlacklist, "BL");

            if (whitelistEnabled) {
                require(receiverReputation.isWhitelist, "Only whitelist canBuy");
            }

            if (gasLimitEnabled) {
                require(tx.gasprice <= gasPriceLimit, "Don't cheat");
            }

            bool isInCooldownTime = block.timestamp < (receiverReputation.lastBuyTime + cooldownDuration);
            bool isInOriginCooldownTime = block.timestamp < (originReputation.lastBuyTime + cooldownDuration);
            require(!isInCooldownTime && !isInOriginCooldownTime, "Buy too fast");

            if (limitSellEnabled) {
                receiverReputation.lockAmount += amount * (100 - releasePercent) / 100;
            }

            receiverReputation.lastBuyTime = block.timestamp;
            originReputation.lastBuyTime = block.timestamp;

            emit LockPurchaseEvent(receiver, amount);

            return;
        }

        if (!limitSellEnabled) {
            return;
        }

        uint256 currentBalanceOfUser = IERC20(tokenAddress).balanceOf(sender);

        require(senderReputation.lockAmount <= (currentBalanceOfUser - amount), "Exceed sell or transfer for locked token amount");
    }

    modifier onlyToken() {
        require(_msgSender() == tokenAddress, "TokenAddress only");
        _;
    }
}