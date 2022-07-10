// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IGoldRushGame.sol";

contract GoldRushPool is Context, Ownable {

    IGoldRushGame public goldRushGame;
    IERC20 public goldRushToken;
    uint256 public totalClaimedInBNB;
    uint256 public totalClaimedInToken;
    mapping(address => uint256) private _claimedInBNB;
    mapping(address => uint256) private _claimedInToken;
    event Claimed(address indexed player, uint256 amountInBNB, uint256 bnbNoTax, uint256 amount);

    constructor () {
    }

    function claimBNBOfAccount(address account) external view returns(uint256) {
        return _claimedInBNB[account];
    }
    function claimTokenOfAccount(address account) external view returns(uint256) {
        return _claimedInToken[account];
    }
    
    // owner will renounce ownership once set game and token contract.
    function setContracts(IGoldRushGame _goldRushGame, IERC20 _goldRushToken) external onlyOwner {
        goldRushGame = _goldRushGame;
        goldRushToken = _goldRushToken;
    }

    receive() external payable {}
    function claim(uint256 percent) external {        
        require (percent <= 100);
        uint256 amount = goldRushGame.balanceToClaim(msg.sender) * percent / 100;        
        uint256 tokenAmount = goldRushGame.getTokenPrice() * amount / 10 ** 18;
        require (tokenAmount > 0 && goldRushToken.balanceOf(address(this)) >= tokenAmount, "Pool is not enough");
        uint256 balance = goldRushGame.balanceOf(msg.sender) * percent / 100;
        totalClaimedInBNB += amount;
        _claimedInBNB[msg.sender] += amount;
        totalClaimedInToken += tokenAmount;        
        _claimedInToken[msg.sender] += tokenAmount;
        goldRushGame.claimedRewards(msg.sender, balance);        
        goldRushToken.transfer(msg.sender, tokenAmount);       
        emit Claimed(msg.sender, balance, amount, tokenAmount);
    }
}

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;
import "./GoldRushNFTLibrary.sol";
interface IGoldRushGame {
    function balanceOf(address account) external view returns(uint256);
    function getTokenPrice() external view returns(uint256);
    function balanceToClaim(address account) external view returns (uint256);
    function claimedRewards(address account, uint256 amount) external;
    function unlockTime(address account) external view returns (uint256);
    function foods(address account) external view returns(uint256);
    function getcvXps(address account) external view returns (uint256[3] memory);
    function lockTime(address account) external view returns (uint256);
    function getcvLvls(address account) external view returns(uint8[3] memory);
    function getTeam(address account, uint8 cvIndex) external view returns (GoldRushNFTLibrary.GoldRushNFT[] memory);
    function getMission(address account, uint8 cvIndex) external view returns (uint256, uint256, uint256, uint256);
    function getNumersOfAccount(address account) external view returns(uint256, uint256);
    function getNumersOfTeam(address account, uint8 cvIndex) external view returns(uint256, uint256);
    function getPowerOfTeam(address account, uint8 cvIndex) external view returns (uint256, uint256);
    function buyFood(uint256 packIndex, bool useReward) external;
    function createNFT(uint8 _nftType, uint8 cntOfNft) external payable;
    function assignTeam(uint256 nftId, uint8 cvIndex) external;
    function takeOutFromTeam(uint256 nftId, uint8 cvIndex) external;
    function upgradeCaravan(uint8 cvIndex, bool useReward) external;
    function newMission(uint8 mtNum, uint8 cvIndex, bool useTMap) external;
    function completeMission(uint8 cvIndex) external;
    event CreatedNewMiner(address indexed player, uint256 _nftId);
    event CreatedNewGunman(address indexed player, uint256 _nftId);
    event CreatedNewFarmer(address indexed player, uint256 _nftId);
    event CompletedMission(address indexed player, uint256 indexed missionId, uint8 cvIndex, uint8 x2Rewards, uint8 survival, uint256 rewards, bool treasureChest, uint256 tMapPrice);
    event NftDied(address indexed player, uint256 missionId, uint8 cvIndex, uint256 nftId);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library GoldRushNFTLibrary{
    struct GoldRushNFT {        
        uint256 nftId;
        uint name;
        uint8 stars;       
        uint256 strength;
        uint8 nftType;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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