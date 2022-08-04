// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "Ownable.sol";
import "IERC20.sol";
import "ReentrancyGuard.sol";

import "IPresaleContract.sol";

contract PresaleContractLock is Ownable, ReentrancyGuard, IPresaleContract {
    /* ========== STATE VARIABLES ========== */
    mapping(string => IERC20) private supportedTokenContracts;
    mapping(uint256 => string) private supportedTokenNames;
    mapping(uint256 => address) private supportedTokenAddresses;
    mapping(address => uint256[]) private lockedBalances;
    mapping(address => uint256[]) private unlockedBalances;

    uint256[] private tokenReleaseRounds;
    uint256 private timestampStart = 0;
    uint256 private decimals = 18;

    uint256 private totalSupportedTokens;
    uint256 private talSupply;
    uint256 private totalLockedTokens;
    uint256 private oneMonth = 10;

    IERC20 private talContract;

    /* ========== CONSTRUCTOR ========== */
    constructor(address _talAddress, uint256[] memory _tokenReleaseRounds) {
        totalSupportedTokens = 0;
        talContract = IERC20(_talAddress);
        tokenReleaseRounds = _tokenReleaseRounds; // Previous time must lower than next time
    }

    /* ========== VIEWS ========== */
    function getRounds() external view returns (uint256[] memory) {
        return tokenReleaseRounds;
    }

    function totalTALSupply() external view returns (uint256) {
        return talSupply;
    }

    function allSupportedTokenInfo()
        external
        view
        returns (SupportedTokenInfo[] memory)
    {
        SupportedTokenInfo[] memory tokenInfo = new SupportedTokenInfo[](
            totalSupportedTokens
        );

        for (uint256 i = 0; i < totalSupportedTokens; i++) {
            tokenInfo[i].name = supportedTokenNames[i];
            tokenInfo[i].contractAddress = supportedTokenAddresses[i];
        }

        return tokenInfo;
    }

    function getTotalLockedTokens() external view returns (uint256) {
        return totalLockedTokens;
    }

    function getLockedTokensAccount(address _account)
        external
        view
        returns (uint256[] memory)
    {
        return lockedBalances[_account];
    }

    function getUnlockedTokensAccount(address _account)
        external
        view
        returns (uint256[] memory)
    {
        return unlockedBalances[_account];
    }

    function getCurrentLockedRound() external view returns (uint256) {
        uint256 totalRounds = tokenReleaseRounds.length;
        uint256 currentRound = 1;

        for (uint256 i = totalRounds; i > 0; i--) {
            uint256 roundTimestamp = timestampStart + tokenReleaseRounds[i - 1];
            if (roundTimestamp >= block.timestamp) {
                currentRound = i;
            } else if (i == 1) {
                currentRound = totalRounds;
            }
        }

        return currentRound;
    }

    function getCurrentLockedMonths(uint256 round)
        external
        view
        returns (uint256)
    {
        uint256 currentRound = this.getCurrentLockedRound();

        require(round <= currentRound, "This round has not activated yet");

        uint256 currentReleaseMonths = (block.timestamp - timestampStart) /
            oneMonth;

        uint256 maxMonths = tokenReleaseRounds[round - 1] / oneMonth;
        if (currentReleaseMonths > maxMonths) return maxMonths;

        if (currentReleaseMonths * oneMonth > tokenReleaseRounds[round - 1])
            return currentReleaseMonths;

        if (round - 1 > 0) {
            currentReleaseMonths =
                (block.timestamp -
                    timestampStart -
                    tokenReleaseRounds[round - 2]) /
                oneMonth;
        }

        return currentReleaseMonths;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function buyTALTokenByBNB(uint256 _amountTAL, uint256 round)
        external
        payable
        nonReentrant
        isStarted
    {
        require(_amountTAL > 0, "Amount TAL must be more than 0");
        require(msg.value > 0, "Invalid buyer supply");

        talSupply = talSupply - _amountTAL;

        payable(owner()).transfer(msg.value);

        bool isLocked = true;

        if (
            tokenReleaseRounds[tokenReleaseRounds.length - 1] +
                timestampStart <=
            block.timestamp
        ) {
            talContract.transfer(msg.sender, _amountTAL);
            isLocked = false;
        } else {
            increaseLockedBalance(msg.sender, round - 1, _amountTAL);
            totalLockedTokens += _amountTAL;
        }

        emit BuyTALTokenByBNB(msg.sender, _amountTAL, msg.value, isLocked);
    }

    function increaseLockedBalance(
        address _account,
        uint256 position,
        uint256 _amount
    ) private {
        if (
            lockedBalances[_account].length > 0 &&
            lockedBalances[_account].length - 1 >= position
        ) lockedBalances[_account][position] += _amount;
        else lockedBalances[_account].push(_amount);
    }

    function increaseUnlockedBalance(
        address _account,
        uint256 position,
        uint256 _amount
    ) private {
        if (
            unlockedBalances[_account].length > 0 &&
            unlockedBalances[_account].length - 1 >= position
        ) unlockedBalances[_account][position] += _amount;
        else unlockedBalances[_account].push(_amount);
    }

    function buyTALTokenBySupportedToken(
        uint256 _amountTAL,
        uint256 _amountSupportedToken,
        string memory _supportedTokenName,
        uint256 round
    ) external nonReentrant isStarted {
        require(_amountTAL > 0, "Amount TAL must be more than 0");
        require(
            _amountSupportedToken > 0,
            "Amount supported token must be more than 0"
        );

        checkIsTokenSupported(_supportedTokenName);

        IERC20 supportedTokenContract = supportedTokenContracts[
            _supportedTokenName
        ];

        talSupply = talSupply - _amountTAL;

        supportedTokenContract.transferFrom(
            msg.sender,
            owner(),
            _amountSupportedToken
        );

        bool isLocked = true;

        if (
            tokenReleaseRounds[tokenReleaseRounds.length - 1] > block.timestamp
        ) {
            talContract.transfer(msg.sender, _amountTAL);
            isLocked = false;
        } else {
            increaseLockedBalance(msg.sender, round - 1, _amountTAL);
            totalLockedTokens += _amountTAL;
        }

        emit BuyTALTokenBySupportedToken(
            msg.sender,
            _amountTAL,
            _amountSupportedToken,
            isLocked
        );
    }

    function buyTALTokenByCash(uint256 _amountTAL, uint256 round)
        external
        nonReentrant
        isStarted
    {
        require(_amountTAL > 0, "Amount TAL must be more than 0");

        talSupply = talSupply - _amountTAL;

        bool isLocked = true;

        if (
            tokenReleaseRounds[tokenReleaseRounds.length - 1] > block.timestamp
        ) {
            talContract.transfer(msg.sender, _amountTAL);
            isLocked = false;
        } else {
            increaseLockedBalance(msg.sender, round - 1, _amountTAL);
            totalLockedTokens += _amountTAL;
        }

        emit BuyTALTokenByCash(msg.sender, _amountTAL, isLocked);
    }

    function withdrawUnlockedTokens(uint256 round)
        external
        nonReentrant
        isStarted
    {
        uint256 currentRound = this.getCurrentLockedRound();

        require(round <= currentRound, "This round has not activated yet");
        require(totalLockedTokens > 0, "Not enough tokens in contract");
        require(
            lockedBalances[msg.sender][round - 1] > 0,
            "All locked tokens were released in this round"
        );

        uint256 _amountTAL = lockedBalances[msg.sender][round - 1];

        uint256 maxMonths = tokenReleaseRounds[round - 1] / oneMonth;
        uint256 currentReleaseMonths = this.getCurrentLockedMonths(round);

        if (round == currentRound && currentReleaseMonths < maxMonths) {
            uint256 totalRoundTokens = lockedBalances[msg.sender][round - 1];
            if (unlockedBalances[msg.sender].length >= round) {
                totalRoundTokens += unlockedBalances[msg.sender][round - 1];
            }

            uint256 eachReleasedTokens = (totalRoundTokens * oneMonth) /
                tokenReleaseRounds[round - 1];

            uint256 releasedMonths = 0;
            if (unlockedBalances[msg.sender].length >= round) {
                releasedMonths =
                    unlockedBalances[msg.sender][round - 1] /
                    eachReleasedTokens;
            }

            require(
                currentReleaseMonths - 1 > 0,
                "No released tokens now in this month"
            );

            require(
                currentReleaseMonths - releasedMonths >= 1,
                "No released tokens now in this month"
            );

            _amountTAL =
                eachReleasedTokens *
                (currentReleaseMonths - releasedMonths - 1);
        }

        totalLockedTokens = totalLockedTokens - _amountTAL;
        lockedBalances[msg.sender][round - 1] =
            lockedBalances[msg.sender][round - 1] -
            _amountTAL;

        increaseUnlockedBalance(msg.sender, round - 1, _amountTAL);

        talContract.transfer(msg.sender, _amountTAL);

        emit GetUnlockedTokens(msg.sender, _amountTAL);
    }

    /* ========== OWNER FUNCTIONS ========== */
    function start() external onlyOwner {
        timestampStart = block.timestamp;

        emit Start();
    }

    function addSupportedToken(string memory _tokenName, address _tokenAddress)
        external
        onlyOwner
    {
        supportedTokenContracts[_tokenName] = IERC20(_tokenAddress);
        supportedTokenNames[totalSupportedTokens] = _tokenName;
        supportedTokenAddresses[totalSupportedTokens] = _tokenAddress;
        totalSupportedTokens = totalSupportedTokens + 1;

        emit AddSupportedToken(_tokenName, _tokenAddress);
    }

    function removeSupportedToken(string memory _tokenName) external onlyOwner {
        uint256 tokenNameIndex = checkIsTokenSupported(_tokenName);

        delete supportedTokenNames[tokenNameIndex];
        delete supportedTokenAddresses[tokenNameIndex];
        delete supportedTokenContracts[_tokenName];

        emit RemoveSupportedToken(_tokenName);
    }

    function fundContractBalance(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Invalid fund");

        talSupply = talSupply + _amount;
        talContract.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawTALToken(address receiver) external onlyOwner {
        require(talSupply > 0, "TAL supply is 0");

        uint256 currentSupply = talSupply;
        talSupply = 0;

        talContract.transfer(receiver, currentSupply);
    }

    /* ========== UTIL FUNCTIONS ========== */
    function checkIsTokenSupported(string memory _supportedTokenName)
        internal
        returns (uint256)
    {
        bool isTokenSupported = false;
        uint256 tokenNameIndex = 0;

        for (uint256 i = 0; i < totalSupportedTokens; i++) {
            bytes32 str1Hash = keccak256(abi.encode(supportedTokenNames[i]));
            bytes32 str2Hash = keccak256(abi.encode(_supportedTokenName));

            if (str1Hash == str2Hash) {
                isTokenSupported = true;
                tokenNameIndex = i;
                break;
            }
        }

        require(isTokenSupported, "The supported token is not supported");

        return tokenNameIndex;
    }

    /* ========== MODIFIERS ========== */
    modifier isStarted() {
        require(timestampStart > 0, "The round has not started yet");

        _;
    }

    /* ========== EVENTS ========== */
    event BuyTALTokenByBNB(
        address indexed buyer,
        uint256 talAmount,
        uint256 bnbAmount,
        bool isLocked
    );
    event BuyTALTokenBySupportedToken(
        address indexed buyer,
        uint256 talAmount,
        uint256 supportedTokenAmount,
        bool isLocked
    );
    event BuyTALTokenByCash(
        address indexed buyer,
        uint256 talAmount,
        bool isLocked
    );

    event Start();
    event AddSupportedToken(string tokenName, address tokenAddress);
    event RemoveSupportedToken(string tokenName);
    event GetUnlockedTokens(address indexed receiver, uint256 talAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
pragma solidity ^0.8.4;

interface IPresaleContract {
    /* ========== STRUCT ========== */
    struct SupportedTokenInfo {
        string name;
        address contractAddress;
    }

    /* ========== VIEWS ========== */
    function totalTALSupply() external view returns (uint256);

    function allSupportedTokenInfo()
        external
        view
        returns (SupportedTokenInfo[] memory);

    /* ========== MUTATIVE FUNCTIONS ========== */
    function buyTALTokenByBNB(uint256 _amount, uint256 round) external payable;

    function buyTALTokenBySupportedToken(
        uint256 _amountTAL,
        uint256 _amountSupportedToken,
        string memory _supportedTokenName,
        uint256 round
    ) external;

    function buyTALTokenByCash(uint256 _amountTAL, uint256 round) external;

     function withdrawUnlockedTokens(uint256 round) external;

    /* ========== OWNER FUNCTIONS ========== */
    function addSupportedToken(string memory _tokenName, address _tokenAddress)
        external;

    function fundContractBalance(uint256 _amount) external;

    function withdrawTALToken(address receiver) external;
}