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

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

interface IAddressesProvider {
  /***************************************************** */
  /*********************GETTERS************************* */
  /***************************************************** */
  function getAddress(bytes32 id) external view returns (address);

  function getSpent() external view returns (address);

  function getSpentLP() external view returns (address);

  function getEusd() external view returns (address);

  function getZapContract() external view returns (address);

  function getBscViaDuctContract() external returns (address);

  function getBarterRouter() external view returns (address);

  function getBarterFactory() external view returns (address);

  function getUpRightContract() external view returns (address);

  function getCropYardContract() external view returns (address);

  function getPrimeContract() external view returns (address);

  function getFiskContract() external view returns (address);

  function getWhitelistContract() external view returns (address);

  function getUprightStableContract() external view returns (address);

  function getUprightLpContract() external view returns (address);

  function getUprightSwapTokenContract() external view returns (address);

  function getUprightBstContract() external view returns (address);

  function getBorrowLendContract() external view returns (address);

  function getTokenomicsContract() external view returns (address);

  function getManagerContract() external view returns (address);

  function getManager() external view returns (address);

  /***************************************************** */
  /*********************SETTERS************************* */
  /***************************************************** */

  function setAddress(bytes32 id, address newAddress) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IAddressesProvider } from "../AddressProvider/IAddressesProvider.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IFisk } from "../../../protocol/Fisk/interface/IFisk.sol";
import { IBarterERC20 } from "../../../protocol/Barter/interface/IBarterERC20.sol";
import { Errors } from "../../libraries/helpers/Errors.sol";

contract Manager is Ownable, ReentrancyGuard {
  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  event AirDropAdded(address account, uint256 amount);

  constructor(IAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
  }

  modifier onlyManager() {
    _onlyManager();
    _;
  }

  function _onlyManager() internal view virtual {
    require(ADDRESSES_PROVIDER.getManager() == msg.sender, Errors.CALLER_NOT_MANAGER);
  }

  function increaseAllowanceFisk(address account, uint256 amount, address token) public nonReentrant onlyManager returns (bool) {
    return IFisk(ADDRESSES_PROVIDER.getFiskContract()).approve(account, amount, token);
  }

  function restAllowanceFisk(address account, address token) public nonReentrant onlyManager returns (bool) {
    return IFisk(ADDRESSES_PROVIDER.getFiskContract()).approvalRest(account, token);
  }

  function subFiskGameAmount(address account, uint256 amount) public nonReentrant onlyManager returns (bool) {
    return IFisk(ADDRESSES_PROVIDER.getFiskContract()).subGameAmount(account, amount);
  }

  function addAirDropToMember(address account, uint256 amount) public nonReentrant onlyManager returns (bool) {
    require(IBarterERC20(ADDRESSES_PROVIDER.getSpentLP()).balanceOf(address(this)) > amount, Errors.LOW_BALANCE);
    IBarterERC20(ADDRESSES_PROVIDER.getSpentLP()).addAirDrop(account, amount);
    emit AirDropAdded(account, amount);
    IBarterERC20(ADDRESSES_PROVIDER.getSpentLP()).transfer(address(0), amount);
    return true;
  }

  function subAirDropFromMember(address account, uint256 amount) public nonReentrant onlyManager returns (bool) {
    IBarterERC20(ADDRESSES_PROVIDER.getSpentLP()).subAirDrop(account, amount);
    return true;
  }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

// FIXME: seggregate errors
library Errors {
  /*********************************************************** */
  /****************************RBAC*************************** */
  /*********************************************************** */
  string public constant CALLER_NOT_ADMIN = "CALLER_NOT_ADMIN"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_OWNER = "CALLER_NOT_OWNER"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_MODERATOR = "CALLER_NOT_MODERATOR"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_SWAP = "CALLER_NOT_SWAP"; // 'The caller of the function is not a pool admin'
  string public constant ACL_ADMIN_CANNOT_BE_ZERO = "ACL_ADMIN_CANNOT_BE_ZERO";

  /*********************************************************** */
  /*************************WHITELISTING********************** */
  /*********************************************************** */
  string public constant ALREADY_WHITELISTED = "ALREADY_WHITELISTED";
  string public constant CALLER_OR_POOL_NOT_WHITELISTED = "CALLER_OR_POOL_NOT_WHITELISTED";
  string public constant REF_NOT_WHITELISTED = "REF_NOT_WHITELISTED";
  string public constant CANNOT_BE_CALLED_BY_MEMBER = "CANNOT_BE_CALLED_BY_MEMBER";
  string public constant WRONG_LOACTION = "WRONG_LOACTION";
  /*********************************************************** */
  /****************************ERC20************************** */
  /*********************************************************** */
  string public constant AMOUNT_ZERO = "AMOUNT_ZERO";
  string public constant LOW_ALLOWANCE = "LOW_ALLOWANCE";
  string public constant INSUFFICIENT_AMOUNT = "INSUFFICIENT_AMOUNT";
  string public constant LOW_BALANCE = "LOW_BALANCE";
  /*********************************************************** */
  /*************************ZERO_ERROR************************ */
  /*********************************************************** */
  string public constant LP_AMOUNT_INVALID = "LP_AMOUNT_INVALID";
  string public constant AMOUNT_INVALID = "AMOUNT_INVALID";
  string public constant NO_TOKEN_IN_CONTRACT = "NO_TOKEN_IN_CONTRACT";
  /*********************************************************** */
  /**************************LOCKED*************************** */
  /*********************************************************** */
  string public constant LP_NOT_UNLOCABLE_YET = "LP_NOT_UNLOCABLE_YET";
  /*********************************************************** */
  /**************************STAKE*************************** */
  /*********************************************************** */
  string public constant WRONG_LP = "WRONG_LP";
  string public constant NOT_CLAIMABLE_YET = "NOT_CLAIMABLE_YET";
  string public constant NOT_UNSTAKABLE_YET = "NOT_UNSTAKABLE_YET";
  string public constant LOW_LOCK_DURATION = "LOW_LOCK_DURATION";
  /*********************************************************** */
  /**************************TRANSACTION************************ */
  /************************************************************ */
  string public constant TRANSACTION_FAILED = "TRANSACTION_FAILED";
  /*********************************************************** */
  /**************************VIA-DUCT************************* */
  /*********************************************************** */
  string public constant ZERO_AFTER_DEDUCTIONS = "ZERO_AFTER_DEDUCTIONS";
  string public constant ZERO_AFTER_VALUATIONS = "ZERO_AFTER_VALUATIONS";
  string public constant LOW_eUSD_BALANCE_IN_CONTRACT = "LOW_eUSD_BALANCE_IN_CONTRACT";
  /*********************************************************** */
  /**************************ACL****************************** */
  /*********************************************************** */
  string public constant CALLER_NOT_PRIME_CONTRACT = "CALLER_NOT_PRIME_CONTRACT";
  string public constant CALLER_NOT_WHITELIST_CONTRACT = "CALLER_NOT_WHITELIST_CONTRACT";
  string public constant CALLER_NOT_CROP_YARD_CONTRACT = "CALLER_NOT_CROP_YARD_CONTRACT";
  string public constant CALLER_NOT_BORROW_LEND_CONTRACT = "CALLER_NOT_BORROW_LEND_CONTRACT";

  string public constant CALLER_NOT_UPRIGHT_STABLE_CONTRACT = "CALLER_NOT_UPRIGHT_STABLE_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_LP_CONTRACT = "CALLER_NOT_UPRIGHT_LP_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_SWAP_TOKEN_CONTRACT = "CALLER_NOT_UPRIGHT_SWAP_TOKEN_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_BST_CONTRACT = "CALLER_NOT_UPRIGHT_BST_CONTRACT";

  string public constant CALLER_NOT_MANAGER_CONTRACT = "CALLER_NOT_MANAGER_CONTRACT";
  string public constant CALLER_NOT_MANAGER = "CALLER_NOT_MANAGER";

  string public constant CALLER_NOT_CROP_YARD_OR_UPRIGHT_CONTRACT = "CALLER_NOT_CROP_YARD_OR_UPRIGHT_CONTRACT";

  string public constant CALLER_NOT_BSC_VIADUCT_CONTRACT = "CALLER_NOT_BSC_VIADUCT_CONTRACT";
  string public constant CALLER_NOT_ROUTER_CONTRACT = "CALLER_NOT_ROUTER_CONTRACT";
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IBarterERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event AirdropAdded(address indexed account, uint256 amount);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

  function addAirDrop(address account, uint256 amount) external returns (bool);

  function subAirDrop(address account, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IFisk {
  event claimedFisk(uint256 amount, address account);
  event claimedV2Fisk(uint256 amount, address account);
  event GameAmountAdded(address account, uint256 amount);
  event GameAmountSub(address account, uint256 amount);

  /********************************************************** */

  function addCropYardFees(uint256 amount) external returns (bool);

  function addWhitelistFees(uint256 amount) external returns (bool);

  function addCropYardPerformanceFees(uint256 amount) external returns (bool);

  /***********************STAKE*********************** */
  function addBorrowStakeTokenFees(uint256 amount) external returns (bool);

  function addStableTokensFees(uint256 amount) external returns (bool);

  function addSwapLpTokensFees(uint256 amount) external returns (bool);

  function addSwapTokensFees(uint256 amount) external returns (bool);

  function addBorrowLendFees(uint256 amount) external returns (bool);

  /*************************************************** */

  function claim(address account, address token) external returns (bool);

  function claimV2(address to, address token, uint256 amount) external returns (bool);

  function allowance(address account, address token) external returns (uint256);

  function approve(address account, uint256 amount, address token) external returns (bool);

  function approvalRest(address account, address token) external returns (bool);

  /****************************************************** */

  function addGameAmount(address account, uint256 amount) external returns (bool);

  function subGameAmount(address account, uint256 amount) external returns (bool);

  function getGameAmount(address account) external returns (uint256);
}