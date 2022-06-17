/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


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

// File: prefinal rob/MANAGER.sol

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;



interface NFT {
  function totalSupply() external view returns (uint256);
  function mint(address to, string memory nodeName, uint256 value) external;
  function ownerOf(uint256 tokenId) external view returns (address);
  function updateValue(uint256 id, uint256 rewards) external;
  function balanceOf(address owner) external view returns (uint256);
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
  function updateClaimTimestamp(uint256 id) external;
  function _nodes(uint256 id) external view returns (uint256, string memory, uint8, uint256, uint256, uint256);
}

contract Manager is Ownable {
  NFT public NFT_CONTRACT;
  IERC20 public TOKEN_CONTRACT;
  address public POOL;

  uint256 public startingPrice = 10e18;

  uint16[] public tiers = [100, 150, 200];

  mapping(address => bool) public isBlacklisted;

  struct Fees {
      uint8 create;
      uint8 compound;
      uint8 claim;
  }

  Fees public fees = Fees({
    create: 10, 
    compound: 5, 
    claim: 10
  });

  struct FeesDistribution {
    uint8 directUpline;
    uint8 uplines;
    uint8 rewards;
  }

  FeesDistribution public createFeesDistribution = FeesDistribution({
    directUpline: 50,
    uplines: 20,
    rewards: 30
  });

  constructor(address TOKEN_CONTRACT_, address POOL_) {
    TOKEN_CONTRACT = IERC20(TOKEN_CONTRACT_);
    POOL = POOL_;
  }

  function updateTokenContract(address value) public onlyOwner {
    TOKEN_CONTRACT = IERC20(value);
  }

  function updateNftContract(address value) public onlyOwner {
    NFT_CONTRACT = NFT(value);
  }

  function updatePool(address value) public onlyOwner {
    POOL = value;
  }

  function currentPrice() public view returns (uint256) {
    return startingPrice + 1 * NFT_CONTRACT.totalSupply() / 1000 * 1e18;
  }

  function mintNode(string memory nodeName, uint256 amount) public {
    require(amount >= currentPrice(), "MINT: Amount too low");
    TOKEN_CONTRACT.transferFrom(_msgSender(), POOL, amount);
    NFT_CONTRACT.mint(_msgSender(), nodeName, amount);
  }

  function depositMore(uint256 id, uint256 amount) public {
    require(NFT_CONTRACT.ownerOf(id) == _msgSender(), "CLAIMALL: Not your NFT");
    TOKEN_CONTRACT.transferFrom(_msgSender(), POOL, amount);
    compound(id);
    NFT_CONTRACT.updateValue(id, amount);
  }

  function availableRewards(uint256 id) public view returns (uint256) {
    (, , uint8 tier, uint256 value, , uint256 claimTimestamp) = NFT_CONTRACT._nodes(id);
    return value * (block.timestamp - claimTimestamp) * tiers[tier] / 86400 / 10000;
  }

  function availableRewardsOfUser(address user) public view returns (uint256) {
    uint256 balance = NFT_CONTRACT.balanceOf(user);
    if (balance == 0) return 0;
    uint256 sum = 0;
    for (uint256 i = 0; i < balance; i++) {
      uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(user, i);
      sum += availableRewards(id);
    }
    return sum;
  }

  function _claimRewards(uint256 id) private {
    require(NFT_CONTRACT.ownerOf(id) == _msgSender(), "CLAIMALL: Not your NFT");
    uint256 rewards_ = availableRewards(id);
    require(rewards_ > 0, "CLAIM: No rewards available yet");
    NFT_CONTRACT.updateClaimTimestamp(id);
    uint256 fees_ = rewards_ * fees.claim / 100;
    TOKEN_CONTRACT.transferFrom(POOL, _msgSender(), rewards_ - fees_);
  }

  function claimRewards(uint256 id) public {
    require(NFT_CONTRACT.balanceOf(_msgSender()) > 0, "CLAIMALL: You don't own a NFT");
    _claimRewards(id);
  }

  function claimRewards() public {
    uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
    require(balance > 0, "CLAIMALL: You don't own a NFT");
    for (uint256 i = 0; i < balance; i++) {
      uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
      _claimRewards(id);
    }
  }

  function _compound(uint256 id, uint256 rewards_) internal {
    require(NFT_CONTRACT.ownerOf(id) == _msgSender(), "CLAIMALL: Not your NFT");
    NFT_CONTRACT.updateClaimTimestamp(id);
    uint256 fees_ = rewards_ * fees.compound / 100;
    NFT_CONTRACT.updateValue(id, rewards_ - fees_);
  }

  function compound(uint256 id) public {
    require(NFT_CONTRACT.balanceOf(_msgSender()) > 0, "CLAIMALL: You don't own a NFT");
    uint256 rewards_ = availableRewards(id);
    require(rewards_ > 0, "CLAIM: No rewards available yet");
    _compound(id, rewards_);
  }

  function compoundAll() public {
    uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
    require(balance > 0, "CLAIMALL: You don't own a NFT");
    for (uint256 i = 0; i < balance; i++) {
      uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
      uint256 rewards_ = availableRewards(id);
      if (rewards_ > 0) {
        _compound(id, rewards_);
      }
    }
  }

  function compoundAllToSpecific(uint256 toId) public {
    uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
    require(balance > 0, "CLAIMALL: You don't own a NFT");
    uint256 sum = 0;
    for (uint256 i = 0; i < balance; i++) {
      uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
      uint256 rewards_ = availableRewards(id);
      if (rewards_ > 0) {
        NFT_CONTRACT.updateClaimTimestamp(id);
      }
    }
    uint256 fees_ = sum * fees.compound / 100;
    NFT_CONTRACT.updateValue(toId, sum - fees_);
  }

  /***********************************|
  |         Owner Functions           |
  |__________________________________*/

  function setStartingPrice(uint256 value) public onlyOwner {
    startingPrice = value;
  }

  function setTiers(uint8[] memory tiers_) public onlyOwner {
    tiers = tiers_;
  }

  function setIsBlacklisted(address user, bool value) public onlyOwner {
    isBlacklisted[user] = value;
  }

  function setFees(uint8 create_, uint8 compound_, uint8 claim_) public onlyOwner {
    fees = Fees({
      create: create_, 
      compound: compound_, 
      claim: claim_
    });
  }

  function setCreateFeesDistribution(uint8 directUpline_, uint8 uplines_, uint8 rewards_) public onlyOwner {
    createFeesDistribution = FeesDistribution({
      directUpline: directUpline_,
      uplines: uplines_,
      rewards: rewards_
    });
  }
}