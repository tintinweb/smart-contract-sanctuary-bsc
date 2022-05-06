// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBombHero {
    function lock(uint256 tokenId) external;
    function unlock(uint256 tokenId) external;
    function isLocked(uint tokenId) external view returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract HeroStake is Pausable, ReentrancyGuard, Ownable {

  enum Rarity {
    Common,
    Rare,
    SuperRare,
    Epic,
    Legendary,
    SuperLegendary
  }

  struct StakeInfo {
      bool staked;
      uint256 time;
      address owner;
  }


  IERC20 public bombHeroCoin;
  IBombHero public bombHero;
  address[] public stakers;

  uint public constant FACTOR = 3_161_823;
  uint public constant fee = 80 * 10**12 wei;
  uint public taxingTime = 2_592_000; //30 days

  mapping(address => mapping(Rarity => uint)) private _userRaritiesStaked;
  mapping(address => bool) private _userAlreadyStaked;
  mapping(uint256 => Rarity) private _tokenRarity;
  mapping(Rarity => uint256) public rarityBooster;
  mapping(uint256 => StakeInfo) public stakedTokens;
  mapping(address => uint256[]) private _userTokensStaked;

  error requesterMustOwnTheToken();
  error tokenIsAlreadyStaked(uint256 token);
  error tokenIsNotStaked(uint256 token);
  error maxLimitOfTokensStaked();
  error feeSmallerThanEnough();

  event HeroesStaked(uint256[] tokenIds);
  event HeroesUnstaked(uint256[] tokenId);
  event RaritySet(uint256 tokenId, Rarity rarity);

  constructor(address _bombHeroCoin, address _bombHero) {
    bombHeroCoin = IERC20(_bombHeroCoin);
    bombHero = IBombHero(_bombHero);
    rarityBooster[Rarity.Common] = 1;
    rarityBooster[Rarity.Rare] = 10;
    rarityBooster[Rarity.SuperRare] = 30;
    rarityBooster[Rarity.Epic] = 50;
    rarityBooster[Rarity.Legendary] = 80;
    rarityBooster[Rarity.SuperLegendary] = 120;
  }

  function setTaxingTime(uint unixTime) external onlyOwner {
      taxingTime = unixTime;
  }

  /**
   * @dev claim rewards without unstaking heroes
   */
  function claimRewards(uint256[] calldata tokenIds) public nonReentrant whenNotPaused {
    uint withdrawlBalance = 0;
    for (uint i = 0;i < tokenIds.length; i++ ) {
        if (stakedTokens[tokenIds[i]].owner !=  msg.sender) revert requesterMustOwnTheToken();
        if (!stakedTokens[tokenIds[i]].staked) revert tokenIsNotStaked(tokenIds[i]);  
        withdrawlBalance += checkTokenRewards(tokenIds[i]);
        stakedTokens[tokenIds[i]].time = block.timestamp;
    }    
    bombHeroCoin.transfer(msg.sender, withdrawlBalance);
  }

  /**
   * @dev Set rarities
   */
  function setRarities(uint256[] calldata _tokenIds, Rarity[] memory _rarity) external onlyOwner {
    for (uint i = 0; i < _tokenIds.length; i++) {
      _tokenRarity[_tokenIds[i]] = _rarity[i];
      emit RaritySet(_tokenIds[i], _rarity[i]);
    }
  }

  /**
   * @dev Stake multiple tokens.
   */
  function stakeTokens(uint256[] calldata tokenIds) public payable nonReentrant whenNotPaused {
    if (msg.value < tokenIds.length * fee) revert feeSmallerThanEnough();
    if (!_userAlreadyStaked[msg.sender] && tokenIds.length > 0) stakers.push(msg.sender);
    _userAlreadyStaked[msg.sender] = true;
    for (uint i = 0;i < tokenIds.length; i++) {
        Rarity tokenRarity = _tokenRarity[tokenIds[i]];
        if ((tokenRarity == Rarity.Common && _userRaritiesStaked[msg.sender][Rarity.Common] > 6) ||
            (tokenRarity == Rarity.Rare && _userRaritiesStaked[msg.sender][Rarity.Rare] > 6) ||
            (tokenRarity == Rarity.SuperRare && _userRaritiesStaked[msg.sender][Rarity.SuperRare] > 6) ) revert maxLimitOfTokensStaked();
        if (bombHero.ownerOf(tokenIds[i]) !=  msg.sender) revert requesterMustOwnTheToken();
        if (stakedTokens[tokenIds[i]].staked) revert tokenIsAlreadyStaked(tokenIds[i]);
        bombHero.lock(tokenIds[i]);
        ++_userRaritiesStaked[msg.sender][tokenRarity];
        _userTokensStaked[msg.sender].push(tokenIds[i]);        
        stakedTokens[tokenIds[i]].staked = true;
        stakedTokens[tokenIds[i]].owner = msg.sender;
        stakedTokens[tokenIds[i]].time = block.timestamp;
    }
  }

  /**
   * @dev Unstake multiple tokens.
   */
  function unstakeTokens(uint256[] calldata tokenIds) public nonReentrant whenNotPaused {    
    uint withdrawlBalance = 0;
    uint[] memory raritiesAmount = new uint[](6);
    for (uint128 i = 0; i < tokenIds.length; i++ ) {
        if (stakedTokens[tokenIds[i]].owner !=  msg.sender) revert requesterMustOwnTheToken();
        if (!stakedTokens[tokenIds[i]].staked) revert tokenIsNotStaked(tokenIds[i]);
        stakedTokens[tokenIds[i]].staked = false;      
        ++raritiesAmount[uint(_tokenRarity[tokenIds[i]])];
        bombHero.unlock(tokenIds[i]);
        withdrawlBalance += checkTokenRewards(tokenIds[i]);
        stakedTokens[tokenIds[i]].time = block.timestamp;
    }
    for (uint128 i = 0; i < 6; i++) {
        _userRaritiesStaked[msg.sender][Rarity(i)] -= raritiesAmount[i]; 
    }   
    bombHeroCoin.transfer(msg.sender, withdrawlBalance);
  }
  
  /**
   * @notice Check token rarity
   */
  function getRarity(uint256 tokenId) public view returns (Rarity) {
    return _tokenRarity[tokenId];
  }

  /**
   * @notice Returns reward for specific tokenId
   * @dev Used for calculations on claiming rewards
   */
  function checkTokenRewards(uint256 tokenId) public view returns(uint256) {
    uint256 stakeDuration = block.timestamp - stakedTokens[tokenId].time;
    uint bonusFromHeroesAmount = getBonusFromNumberOfHeroes(_tokenRarity[tokenId], _userRaritiesStaked[stakedTokens[tokenId].owner][_tokenRarity[tokenId]]);
    if (stakeDuration > taxingTime) {
        return stakeDuration*rarityBooster[_tokenRarity[tokenId]]*(bonusFromHeroesAmount + 100)/100 > FACTOR 
            ? stakeDuration*rarityBooster[_tokenRarity[tokenId]]*(bonusFromHeroesAmount + 100)/(FACTOR*100)
            : 0;
    } else {
        return stakeDuration*rarityBooster[_tokenRarity[tokenId]]*(bonusFromHeroesAmount + 100)*2/1000 > FACTOR 
            ? stakeDuration*rarityBooster[_tokenRarity[tokenId]]*(bonusFromHeroesAmount + 100)*2/(FACTOR*1000) 
            : 0;
    }
  } 

  /**
   * @dev Get array of rewards corresponding to getUserStakedTokens array
   */
  function getUserRewards(address user) external view returns (uint256[] memory) {
    uint256[] memory tokenIds = getUserStakedTokens(user);
    uint256[] memory rewards = new uint256[](tokenIds.length);
    for(uint256 i = 0; i < tokenIds.length; i++) {
        rewards[i] = checkTokenRewards(tokenIds[i]);
    }
    return rewards;
  }

  function getUserRaritiesStaked(address user) external view returns (uint256[] memory) {
      uint[] memory result = new uint[](6);
      for(uint i = 0; i < 6; i++) {
          result[i] = _userRaritiesStaked[user][Rarity(i)];
      }
      return result;
  }

  /**
   * @dev Get array of token ids currently staked by the user
   */
  function getUserStakedTokens(address user) public view returns (uint256[] memory) {
    uint256[] memory fullStakedTokensArray = new uint256[](_userTokensStaked[user].length);
    uint128 amountOfTokens;
    for(uint128 i = 0; i < _userTokensStaked[user].length; i++) {
        if (stakedTokens[_userTokensStaked[user][i]].staked) {
            fullStakedTokensArray[i] = _userTokensStaked[user][i];
            ++amountOfTokens;
        }
    }
    uint256[] memory userTokensCurrentlyStaked = new uint256[](amountOfTokens);
    uint128 j = 0;
    for(uint128 i = 0; i < _userTokensStaked[user].length; i++) {        
        if (stakedTokens[_userTokensStaked[user][i]].staked) {
            userTokensCurrentlyStaked[j] = _userTokensStaked[user][i];
            ++j;
        }
    }
    quickSort(userTokensCurrentlyStaked);
    userTokensCurrentlyStaked =  removeDuplicates(userTokensCurrentlyStaked, amountOfTokens);
    return userTokensCurrentlyStaked;
  }

  /**
   * @dev gets the bonus multiplyer for amount of rare heroes staked
   */
  function getBonusFromNumberOfHeroes(Rarity rarity, uint256 amount) internal pure returns(uint256) {
      if (rarity == Rarity.Epic && amount >= 10) {
          return (amount/5)+1;
      } else
      if (rarity == Rarity.Legendary && amount >= 5) {
          return (amount/5)*2+1;
      } else
      if (rarity == Rarity.SuperLegendary && amount >= 2) {
          return amount+2;
      } else
      return 0;
  }

  /**
   * @dev Helper function for getUserStaked Tokens
   */
  function quickSort(uint[] memory arr) internal pure {
    if (arr.length > 1) {
        quick(arr, 0, arr.length - 1);
    }
  }
  
  /**
   * @dev Helper function for getUserStaked Tokens
   */
  function quick(uint[] memory arr, uint low, uint high) internal pure {
    if (low < high) {
        uint pivotVal = arr[(low + high) / 2];

        uint low1 = low;
        uint high1 = high;
        for (;;) {
            while (arr[low1] < pivotVal) low1++;
            while (arr[high1] > pivotVal) high1--;
            if (low1 >= high1) break;
            (arr[low1], arr[high1]) = (arr[high1], arr[low1]);
            low1++;
            high1--;
        }
        if (low < high1) quick(arr, low, high1);
        high1++;
        if (high1 < high) quick(arr, high1, high);
    }
  }

  /**
   * @dev Helper function for getUserStaked Tokens
   */
  function removeDuplicates(uint256[] memory arr, uint arrSize) internal pure returns(uint256[] memory) {
    if (arrSize <= 1) return arr;
    uint j = 0; 
    for (uint i = 0; i < arrSize - 1 ; i++) {
        if (arr[i] != arr[i + 1]) arr[j++] = arr[i];
    }
    arr[j++] = arr[arrSize - 1];

    uint[] memory replaceArr = new uint[](j);
    for (uint i = 0; i < j; i++) {
        replaceArr[i] = arr[i];
    }
    return replaceArr;
  }

  /** 
   * @dev Get all users that staked tokens.
   */
  function getStakers() public view returns (address[] memory) {
      return stakers;
  }

  /**
  *@dev pauses the contract
  */
  function pause() public onlyOwner {
        _pause();
  }

  /**
  *@dev unpauses the contract
  */
  function unpause() public onlyOwner {
      _unpause();
  }

  function withdrawlBNB() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  function withdrawlBEP20(address _tokenContract) external onlyOwner {
    require(_tokenContract != address(0), "Invalid address");
    IERC20 token = IERC20(_tokenContract);
    uint256 balance = token.balanceOf(address(this));
    token.transfer(payable(owner()), balance);
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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