// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC20.sol";
import "./interfaces/InewsFIDL.sol";
import "./interfaces/IsFIDL.sol";
import "./interfaces/IgFIDL.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IStakingV1.sol";

import "./libraries/SafeMath.sol";
import "./libraries/SafeERC20.sol";

contract TrapezaTokenMigrator is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using SafeERC20 for IgFIDL;
  using SafeERC20 for IsFIDL;

  /* ========== STATE VARIABLES ========== */

  IERC20 public FIDL;
  IgFIDL public gFIDL;

  InewsFIDL public immutable newsFIDL;
  IsFIDL public immutable oldsFIDL;

  IStakingV1 public immutable oldStaking;

  IStaking public newStaking;

  bool public shutdown;

  /* ========== EVENTS ========== */

  event Migrated(uint256 sFIDL, uint256 gFIDL);
  event Toggled(bool shutdown);

  /* ========== CONSTRUCTOR ========== */
  constructor(
    address _FIDL,
    address _gFIDL,
    address _oldsFIDL,
    address _newsFIDL,
    address _oldStaking,
    address _newStaking
  ) {
    require(_FIDL != address(0), "Zero address: FIDL");
    FIDL = IgFIDL(_FIDL);

    require(_gFIDL != address(0), "Zero address: gFIDL");
    gFIDL = IgFIDL(_gFIDL);

    require(_oldsFIDL != address(0), "Zero address: sFIDL");
    oldsFIDL = IsFIDL(_oldsFIDL);

    require(_newsFIDL != address(0), "Zero address: new sFIDL");
    newsFIDL = InewsFIDL(_newsFIDL);

    require(_oldStaking != address(0), "Zero address: Staking");
    oldStaking = IStakingV1(_oldStaking);

    require(_newStaking != address(0), "Zero address: new staking");
    newStaking = IStaking(_newStaking);

    approveForMigrator(_oldsFIDL, _oldStaking);
    approveForMigrator(_FIDL, _newStaking);
  }

  /* ========== OWNABLE ========== */

  /**
   * @notice approve max amount for migrator, only owner available
   * @param _token Token address
   * @param _spender The address to approve
   */
  function approveForMigrator(address _token, address _spender)
    public
    onlyOwner
  {
    IERC20(_token).approve(_spender, uint256(-1));
  }

  /**
   * @notice toggle shutdown
   */
  function halt() external onlyOwner {
    shutdown = !shutdown;

    emit Toggled(shutdown);
  }

  /* ========== MIGRATION ========== */

  /**
   * @notice migrate sFIDL to gFIDL, tranfer FIDL from oldStaking to newStaking
   * @param _amount sFIDL amount
   */
  function migrate(uint256 _amount) external {
    require(!shutdown, "Shut down");

    uint256 oldsFIDLCirculatingSupply = newsFIDL.oldsFIDLCirculatingSupply();
    require(oldsFIDLCirculatingSupply >= _amount, "Exceed migrate amount");

    oldsFIDL.safeTransferFrom(msg.sender, address(this), _amount);
    oldStaking.unstake(_amount, false);

    FIDL.safeTransfer(address(newStaking), _amount);

    newsFIDL.decreaseOldsFIDLCirculatingSupply(_amount);

    uint256 gAmount = expect(_amount);

    gFIDL.mint(msg.sender, gAmount); // mint gFIDL to sender;

    emit Migrated(_amount, gAmount);
  }

  /* ========== VIEW FUNCTIONS ========== */

  /**
   * @notice expectation current gFIDL amount from sFIDL
   * @param _amount sFIDL amount
   * @return uint256 gFIDL amount
   */
  function expect(uint256 _amount) public view returns (uint256) {
    return gFIDL.balanceTo(_amount.mul(gFIDL.index()).div(oldsFIDL.index()));
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

import "./IERC20.sol";

interface InewsFIDL is IERC20 {
  function oldsFIDLCirculatingSupply() external view returns (uint256);

  function decreaseOldsFIDLCirculatingSupply(uint256 _migrateValue) external;
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

import "./IERC20.sol";

interface IsFIDL is IERC20 {
  function rebase(uint256 profit_, uint256 epoch_) external returns (uint256);

  function circulatingSupply() external view returns (uint256);

  function gonsForBalance(uint256 amount) external view returns (uint256);

  function balanceForGons(uint256 gons) external view returns (uint256);

  function index() external view returns (uint256);

  function toG(uint256 amount) external view returns (uint256);

  function fromG(uint256 amount) external view returns (uint256);

  function changeDebt(
    uint256 amount,
    address debtor,
    bool add
  ) external;

  function debtBalances(address _address) external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

import "./IERC20.sol";

interface IgFIDL is IERC20 {
  function mint(address _to, uint256 _amount) external;

  function burn(address _from, uint256 _amount) external;

  function index() external view returns (uint256);

  function balanceFrom(uint256 _amount) external view returns (uint256);

  function balanceTo(uint256 _amount) external view returns (uint256);

  function initialize(address _staking, address _migrator) external;
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

interface IStaking {
  function stake(
    address _to,
    uint256 _amount,
    bool _rebasing,
    bool _claim
  ) external returns (uint256);

  function claim(address _recipient, bool _rebasing) external returns (uint256);

  function forfeit() external returns (uint256);

  function toggleLock() external;

  function unstake(
    address _to,
    uint256 _amount,
    bool _trigger,
    bool _rebasing
  ) external returns (uint256);

  function wrap(address _to, uint256 _amount)
    external
    returns (uint256 gBalance_);

  function unwrap(address _to, uint256 _amount)
    external
    returns (uint256 sBalance_);

  function rebase() external;

  function index() external view returns (uint256);

  function contractBalance() external view returns (uint256);

  function totalStaked() external view returns (uint256);

  function supplyInWarmup() external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

interface IStakingV1 {
  function unstake(uint256 _amount, bool _trigger) external;

  function index() external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.7.5;

// TODO(zx): Replace all instances of SafeMath with OZ implementation
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    assert(a == b * c + (a % b)); // There is no case in which this doesn't hold

    return c;
  }

  // Only used in the  BondingCalculator.sol
  function sqrrt(uint256 a) internal pure returns (uint256 c) {
    if (a > 3) {
      c = a;
      uint256 b = add(div(a, 2), 1);
      while (b < c) {
        c = b;
        b = div(add(div(a, b), b), 2);
      }
    } else if (a != 0) {
      c = 1;
    }
  }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.5;

import {IERC20} from "../interfaces/IERC20.sol";

/// @notice Safe IERC20 and ETH transfer library that safely handles missing return values.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/libraries/TransferHelper.sol)
/// Taken from Solmate
library SafeERC20 {
  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 amount
  ) internal {
    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
    );

    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TRANSFER_FROM_FAILED"
    );
  }

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
    );

    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TRANSFER_FAILED"
    );
  }

  function safeApprove(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(IERC20.approve.selector, to, amount)
    );

    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "APPROVE_FAILED"
    );
  }

  function safeTransferETH(address to, uint256 amount) internal {
    (bool success, ) = to.call{value: amount}(new bytes(0));

    require(success, "ETH_TRANSFER_FAILED");
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}