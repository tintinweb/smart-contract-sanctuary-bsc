// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.7.5;

import "./libraries/SafeMath.sol";
import "./libraries/SafeERC20.sol";

import "./interfaces/IERC20.sol";
import "./interfaces/IsFIDL.sol";

import "./interfaces/IgFIDL.sol";

import "./interfaces/IStaking.sol";

// import "./types/OlympusAccessControlled.sol";

interface IDistributor {
  function distribute() external returns (bool);
}

contract TrapezaStaking_V2 {
  /* ========== DEPENDENCIES ========== */

  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using SafeERC20 for IsFIDL;
  using SafeERC20 for IgFIDL;
  using SafeERC20 for IStaking;

  /* ========== EVENTS ========== */

  event DistributorSet(address distributor);
  event WarmupSet(uint256 warmup);

  /* ========== DATA STRUCTURES ========== */

  struct Epoch {
    uint256 length; // in seconds
    uint256 number; // since inception
    uint256 end; // timestamp
    uint256 distribute; // amount
  }

  struct Claim {
    uint256 deposit; // if forfeiting
    uint256 gons; // staked balance
    uint256 expiry; // end of warmup period
    bool lock; // prevents malicious delays for claim
  }

  /* ========== STATE VARIABLES ========== */

  IERC20 public immutable FIDL;
  IsFIDL public immutable sFIDL;
  IgFIDL public immutable gFIDL;

  address public oldStaking;

  Epoch public epoch;

  IDistributor public distributor;

  mapping(address => Claim) public warmupInfo;
  uint256 public warmupPeriod;
  uint256 private gonsInWarmup;

  /* ========== CONSTRUCTOR ========== */

  constructor(
    address _FIDL,
    address _sFIDL,
    address _gFIDL,
    address _oldStaking,
    uint256 _oldEpochNumber,
    uint256 _initEpochTimestamp
  ) {
    require(_FIDL != address(0), "Zero address: FIDL");
    FIDL = IERC20(_FIDL);

    require(_sFIDL != address(0), "Zero address: sFIDL");
    sFIDL = IsFIDL(_sFIDL);

    require(_gFIDL != address(0), "Zero address: gFIDL");
    gFIDL = IgFIDL(_gFIDL);

    require(_oldStaking != address(0), "Zero address: old staking");
    oldStaking = _oldStaking;

    epoch = Epoch({
      // length: 28800, // 8 hours timestamp
      length: 1800, // 8 hours timestamp
      number: _oldEpochNumber,
      end: _initEpochTimestamp,
      distribute: 0
    });
  }

  /* ========== MUTATIVE FUNCTIONS ========== */

  /**
   * @notice stake FIDL to enter warmup
   * @param _to address
   * @param _amount uint
   * @param _claim bool
   * @return uint
   */
  function stake(
    address _to,
    uint256 _amount,
    bool _claim
  ) external returns (uint256) {
    rebase();

    FIDL.safeTransferFrom(msg.sender, address(this), _amount);

    if (_claim && warmupPeriod == 0) {
      return _send(_to, _amount);
    } else {
      Claim memory info = warmupInfo[_to];

      if (!info.lock) {
        require(_to == msg.sender, "External deposits for account are locked");
      }

      warmupInfo[_to] = Claim({
        deposit: info.deposit.add(_amount),
        gons: info.gons.add(sFIDL.gonsForBalance(_amount)),
        expiry: epoch.number.add(warmupPeriod),
        lock: info.lock
      });

      gonsInWarmup = gonsInWarmup.add(sFIDL.gonsForBalance(_amount));

      return _amount;
    }
  }

  /**
   * @notice retrieve stake from warmup
   * @param _to address
   * @return uint
   */
  function claim(address _to) public returns (uint256) {
    Claim memory info = warmupInfo[_to];

    if (!info.lock) {
      require(_to == msg.sender, "External claims for account are locked");
    }

    if (epoch.number >= info.expiry && info.expiry != 0) {
      delete warmupInfo[_to];

      gonsInWarmup = gonsInWarmup.sub(info.gons);

      return _send(_to, sFIDL.balanceForGons(info.gons));
    }
    return 0;
  }

  /**
   * @notice forfeit stake and retrieve FIDL
   * @return uint
   */
  function forfeit() external returns (uint256) {
    Claim memory info = warmupInfo[msg.sender];
    delete warmupInfo[msg.sender];

    gonsInWarmup = gonsInWarmup.sub(info.gons);

    FIDL.safeTransfer(msg.sender, info.deposit);

    return info.deposit;
  }

  /**
   * @notice prevent new deposits or claims from ext. address (protection from malicious activity)
   */
  function toggleLock() external {
    warmupInfo[msg.sender].lock = !warmupInfo[msg.sender].lock;
  }

  /**
   * @notice redeem sFIDL for FIDLs
   * @param _to address
   * @param _amount uint
   * @param _rebasing bool
   * @return amount_ uint256
   */
  function unstake(
    address _to,
    uint256 _amount,
    bool _rebasing
  ) external returns (uint256 amount_) {
    if (_rebasing) {
      rebase();
    }

    gFIDL.burn(msg.sender, _amount); // amount was given in gFIDL terms
    amount_ = gFIDL.balanceFrom(_amount);

    require(
      amount_ <= FIDL.balanceOf(address(this)),
      "Insufficient FIDL balance in contract"
    );

    FIDL.safeTransfer(_to, amount_);
  }

  /**
   * @notice trigger rebase if epoch over
   */
  function rebase() public {
    if (epoch.end <= block.timestamp) {
      sFIDL.rebase(epoch.distribute, epoch.number);

      epoch.end = epoch.end.add(epoch.length);
      epoch.number++;

      if (address(distributor) != address(0)) {
        distributor.distribute();
      }

      uint256 balance = FIDL.balanceOf(address(this)).add(
        FIDL.balanceOf(oldStaking)
      );
      uint256 staked = sFIDL.circulatingSupply();

      if (balance <= staked) {
        epoch.distribute = 0;
      } else {
        epoch.distribute = balance.sub(staked);
      }
    }
  }

  /* ========== INTERNAL FUNCTIONS ========== */

  /**
   * @notice send staker their amount as sFIDL or gFIDL
   * @param _to address
   * @param _amount uint256
   */
  function _send(address _to, uint256 _amount) internal returns (uint256) {
    gFIDL.mint(_to, gFIDL.balanceTo(_amount)); // send as gFIDL (convert units from FIDL)
    return gFIDL.balanceTo(_amount);
  }

  /* ========== VIEW FUNCTIONS ========== */

  /**
   * @notice returns the sFIDL index, which tracks rebase growth
   * @return uint256
   */
  function index() public view returns (uint256) {
    return sFIDL.index();
  }

  /**
   * @notice total supply in warmup
   * @return uint256
   */
  function supplyInWarmup() public view returns (uint256) {
    return sFIDL.balanceForGons(gonsInWarmup);
  }

  /**
   * @notice seconds until the next epoch begins
   * @return uint256
   */
  function secondsToNextEpoch() external view returns (uint256) {
    return epoch.end.sub(block.timestamp);
  }

  /* ========== MANAGERIAL FUNCTIONS ========== */

  /**
   * @notice sets the contract address for LP staking
   * @param _distributor address
   */
  function setDistributor(address _distributor) external {
    distributor = IDistributor(_distributor);
    emit DistributorSet(_distributor);
  }

  /**
   * @notice set warmup period for new stakers
   * @param _warmupPeriod uint
   */
  function setWarmupLength(uint256 _warmupPeriod) external {
    warmupPeriod = _warmupPeriod;
    emit WarmupSet(_warmupPeriod);
  }
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