// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;


import "Ownable.sol";
import "IERC20.sol";
import "Pausable.sol";




contract BurnPage is Pausable, Ownable {
  struct Campaign {
    uint256 startAt;
    uint256 endAt;
    mapping(address => uint256) voteCount;
  }

struct ProjectVotes{
address projectAddress;
uint256 voteCount;
uint256 chainId;
}

  struct Project {
    address addr;
    uint chainId;
    bool isKnown;
  }

mapping(address => bool) isProjectKnown;
mapping(address => uint) projectsIndex;
  Campaign public currentCampaign;
  Campaign[] public campaigns;
  Project[] public projects;
  address constant public DEAD = address(0x000000000000000000000000000000000000dEaD);

  IERC20 public _oburn; 

  constructor(address oburnAddr) {
    require(oburnAddr != address(0x0), "Zero address detected");
    _oburn = IERC20(oburnAddr);
//    _oburn.approve(initRouterAddress, type(uint256).max);
  }

  function vote(uint256 amount, uint chainId, address addr) public {
    require(addr != address(0x0), "Zero address detected");
    require(currentCampaign.endAt >= block.timestamp, "Campaign ended");

    if(!isProjectKnown[addr]) {
      
      projects.push (Project({
        addr: addr,
        chainId: chainId,
        isKnown: true
      }));
      isProjectKnown[addr] = true;
      projectsIndex[addr] = projects.length-1;
    }

   _oburn.transferFrom(msg.sender, DEAD, amount);
    
    currentCampaign.voteCount[addr] += amount;
    emit LogVote(amount, chainId, addr);
  }

  function createNewCampaign(uint256 _startAt, uint256 _endAt) public onlyOwner {
    require(_endAt > _startAt, "Invalid end at");
    require(_endAt > block.timestamp, "End at can not be in past");

Campaign storage c = campaigns.push();
c.endAt = _endAt;
c.startAt= _startAt;

    if(c.startAt <= block.timestamp) {

      currentCampaign.endAt = _endAt;
      currentCampaign.startAt= _startAt;
      wipeCampaign();

    }
    emit LogNewCampaign(_startAt,_endAt);
  }

  function setCurrentCampaign(uint id) public onlyOwner {
    require(id < campaigns.length, "invalid campaign");
    currentCampaign.endAt =campaigns[id].endAt;
    currentCampaign.startAt= campaigns[id].startAt;
    wipeCampaign();
    emit LogsetcurrentCampaign(id);
  }



function getPastCampaign(uint id) public view returns(uint startAt,uint endAt, ProjectVotes[] memory) {
ProjectVotes[] memory projectVotes = new ProjectVotes[](projects.length);
uint256 campaignStartAt = campaigns[id].startAt;
uint256 campaignEndAt = campaigns[id].endAt;
for (uint i = 0; i < projects.length; i++) {
  projectVotes[i]= ProjectVotes({
    projectAddress: projects[i].addr,
    voteCount: campaigns[id].voteCount[projects[i].addr],
    chainId: projects[i].chainId
  });
}
return (campaignStartAt, campaignEndAt, projectVotes);
}


function getCurrentCampaign() public view returns(ProjectVotes[] memory) {
ProjectVotes[] memory projectVotes = new ProjectVotes[](projects.length);
for (uint i = 0; i < projects.length; i++) {
  projectVotes[i]= ProjectVotes({
    projectAddress: projects[i].addr,
    voteCount: currentCampaign.voteCount[projects[i].addr],
    chainId: projects[i].chainId
  });
}
return projectVotes;
}

function wipeCampaign() private {
  for (uint i = 0; i < projects.length; i++) {
  currentCampaign.voteCount[projects[i].addr] = 0;
}
}

event LogVote( uint256 amount, uint chainId, address projectAddress);
event LogNewCampaign( uint256 startAt, uint endAt);
event LogsetcurrentCampaign(uint id);
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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