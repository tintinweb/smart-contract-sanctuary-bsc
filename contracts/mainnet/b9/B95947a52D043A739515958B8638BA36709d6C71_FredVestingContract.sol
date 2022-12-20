// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FredVestingContract is Ownable, ReentrancyGuard {
    IERC20 public BUSD;
    IERC20 public FRED;
    bool public presaleActive;
    address[] public marketingWallets;
    address public teamWallet;
    uint256 public whiteListStartTime;
    uint256 public publicStartTime = whiteListStartTime + 1 hours;
    uint256 public launchTime = 1671822000; // 23rd of December @ 19 hours UTC
    uint256 public vestingEndDate = launchTime + 45 days;
    uint256 public presaleSpots = 150;
    uint256 public whitelListSpots = 50;
    uint256 public teamTokenLockTime;
    uint256 public lastMarketingClaim;
    TeamVest public teamVest;

    struct Vest {
        address _benificiary;
        uint256 _total;
        uint256 _amount;
        uint256 _claimed;
    }

    struct TeamVest {
        uint256 _amount;
        uint256 _lastClaimDate;
        uint256 _remaining;
        uint256 _vestingStartDate;
        uint256 _vestingEndDate;
        uint256 _claimed;
    }

    mapping(address => Vest) public vestingRegistry;
    mapping(address => bool) public hasPurchased;
    mapping(address => bool) public whiteListed;

    event PresaleStarted();
    event SpotBought(address _address);

    constructor(address _fred) {
        FRED = IERC20(_fred);
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    function buyPresaleSlot() external {
        require(presaleActive, "Presale is not active yet");
        require(!hasPurchased[msg.sender], "This wallet already has purchased");

        if (block.timestamp < publicStartTime) {
            require(whiteListed[msg.sender], "You are not whitelisted");
            require(whitelListSpots > 0);
        } else {
            require(presaleSpots + whitelListSpots > 0);
        }

        require(
            FRED.balanceOf(address(this)) >= 4000000 ether,
            "No more presale tokens availalbe"
        );

        require(
            BUSD.transferFrom(msg.sender, address(this), 60 ether), // $60 BUSD
            "Payment Failed"
        );

        createVest(msg.sender, 4000000 * 10 ** 18, false);
    }

    function createVest(
        address _benificiary,
        uint256 _amount,
        bool _marketing
    ) internal {
        Vest storage vest = vestingRegistry[_benificiary];

        uint256 available = (_amount * 40) / 100;
        require(
            FRED.transfer(_benificiary, available),
            "Token transfer failed"
        );

        vest._benificiary = _benificiary;
        vest._amount = _amount - available;
        vest._total = _amount - available;

        hasPurchased[_benificiary] = true;

        if (!_marketing) {
            if (block.timestamp < publicStartTime) {
                whitelListSpots -= 1;
            } else {
                if (whitelListSpots == 0) {
                    presaleSpots -= 1;
                } else {
                    whitelListSpots -= 1;
                }
            }
        }

        emit SpotBought(_benificiary);
    }

    function checkAvailableTokens(
        address _address
    ) public view returns (uint256) {
        require(
            hasPurchased[_address],
            "You have not purchased any tokens yet.."
        );
        uint256 timeElapsed;
        uint256 amountToClaim;
        if (block.timestamp < launchTime) {
            timeElapsed = 0;
        } else {
            Vest storage vest = vestingRegistry[_address];
            block.timestamp > vestingEndDate
                ? timeElapsed = vestingEndDate - launchTime
                : timeElapsed = block.timestamp - launchTime;
            uint256 releasedPerSecond = vest._total /
                (vestingEndDate - launchTime);
            amountToClaim = ((timeElapsed * releasedPerSecond) - vest._claimed);
        }

        return amountToClaim;
    }

    function claimTokens() external nonReentrant {
        require(hasPurchased[msg.sender], "You dont have any vest");
        Vest storage vest = vestingRegistry[msg.sender];
        require(
            block.timestamp > launchTime + 1 days,
            "Your tokens will start releasing after 24hrs post launch"
        );

        uint256 available = checkAvailableTokens(msg.sender);
        if (vest._amount > 0) {
            vest._amount -= available;
            vest._claimed += available;
            FRED.transfer(msg.sender, available);
        }
    }

    // Marketing

    function createMarketingVest(
        address _address,
        uint256 _amount
    ) external onlyOwner {
        FRED.transferFrom(msg.sender, address(this), _amount);
        createVest(_address, _amount, true);
        marketingWallets.push(_address);
    }

    function claimMarketingTokens() external nonReentrant {
        require(
            block.timestamp > launchTime + 1 days,
            "Your tokens will start releasing after 24hrs"
        );
        require(
            block.timestamp >= lastMarketingClaim + 1 days,
            "Marketers can only claim once a day"
        );
        address[] memory wallets = marketingWallets;
        lastMarketingClaim = block.timestamp;
        for (uint256 i; i < wallets.length; i++) {
            uint256 available = checkAvailableTokens(wallets[i]);
            FRED.transfer(wallets[i], available);
        }
    }

    // Vest Team Tokens 100 weeks

    function vestTeamTokens(uint256 _amount) external onlyOwner {
        require(
            FRED.transferFrom(msg.sender, address(this), _amount),
            "Token transfer Failed"
        );
        TeamVest storage vest = teamVest;
        vest._amount = _amount;
        vest._lastClaimDate = block.timestamp;
        vest._remaining = _amount;
        vest._vestingStartDate = block.timestamp;
        vest._vestingEndDate = block.timestamp + 100 weeks;
    }

    function checkTeamTokensAvailable() public view returns (uint256) {
        uint256 timePast;
        uint256 unlockedPerSecond = teamVest._amount / 100 weeks;
        block.timestamp > teamVest._vestingEndDate
            ? timePast = teamVest._vestingEndDate - teamVest._vestingStartDate
            : timePast = block.timestamp - teamVest._vestingStartDate;

        return (timePast * unlockedPerSecond) - teamVest._claimed;
    }

    function withdrawTeamTokens() external {
        require(msg.sender == teamWallet, "Caller is not the team wallet");
        require(
            block.timestamp > teamVest._lastClaimDate + 1 weeks,
            "Can only claim once a week"
        );
        require(teamVest._remaining > 0, "Nothing left to claim");
        uint256 toClaim = checkTeamTokensAvailable();
        teamVest._claimed += toClaim;
        teamVest._lastClaimDate = block.timestamp;

        FRED.transfer(teamWallet, toClaim);
    }

    // SETTERS AND GETTERS

    function withdrawBUSD() external onlyOwner {
        require(BUSD.balanceOf(address(this)) > 0, "Nothing to withdraw");
        require(
            BUSD.transfer(owner(), BUSD.balanceOf(address(this))),
            "Withdraw Failed"
        );
    }

    function addWhiteListed(address _address) external onlyOwner {
        whiteListed[_address] = true;
    }

    function setStartTime(uint256 _newLaunchTime) external onlyOwner {
        require(
            _newLaunchTime < launchTime,
            "Cannot extend time, only shorten it"
        );
        launchTime = _newLaunchTime;
    }

    function startPresale() external onlyOwner {
        require(!presaleActive, "Presale is already active");
        presaleActive = true;
        whiteListStartTime = block.timestamp;
        emit PresaleStarted();
    }

    function getUnusedTokens() external onlyOwner {
        require(
            block.timestamp > launchTime + 100 days,
            "Cannot remove unused tokens until after 100 days"
        );
        uint256 amount = (whitelListSpots + presaleSpots) * 4000000 ether;
        require(FRED.balanceOf(address(this)) >= amount);
        FRED.transfer(owner(), amount);
    }

    function updateWhiteListSpots(uint256 _amt) external onlyOwner {
        whitelListSpots = _amt;
    }

    function updatePresaleSpots(uint256 _amt) external onlyOwner {
        presaleSpots = _amt;
    }

    function replaceMarketingWallet(address _address) external onlyOwner {
        address[] storage wallets = marketingWallets;
        for (uint256 i; i < wallets.length; i++) {
            if (wallets[i] == _address) {
                wallets[i] = owner();
            }
        }
    }

    function setTeamWallet(address _newTeamWallet) external onlyOwner {
        teamWallet = _newTeamWallet;
    }

    function getMarketingWallets() public view returns (address[] memory) {
        return marketingWallets;
    }

    function updateBUSD(address _newAddress) external onlyOwner {
        BUSD = IERC20(_newAddress);
    }
}