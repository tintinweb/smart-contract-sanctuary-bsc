// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "./interfaces/IERC20Metadata.sol";

import "./libraries/SafeMath.sol";
import "./libraries/SafeERC20.sol";

import "./types/Ownable.sol";

contract TrapezaCloser is Ownable {
  using SafeMath for uint256;
  using SafeMath for uint8;
  using SafeERC20 for IERC20Metadata;

  /* ========== STATE VARIABLES ========== */

  address public FIDL;
  address public principle;

  bool public shutdown = true;

  uint256 public exchangeRate; // 100 equals 1$

  /* ========== EVENTS ========== */

  event Toggled(bool shutdown);
  event Destroyed(address indexed owner);
  event UpdateExchangeRate(uint256 preExchangeRate, uint256 curExchangeRate);
  event Exchanged(
    address indexed sender,
    address indexed receipient,
    uint256 exchangeRate,
    uint256 fidlAmount,
    uint256 principleAmount
  );

  /* ========== CONSTRUCTOR ========== */
  constructor(
    address _FIDL,
    address _principle,
    uint256 _exchangeRate
  ) {
    require(_FIDL != address(0), "Zero address: _FIDL");
    FIDL = _FIDL;

    require(_principle != address(0), "Zero address: _principle");
    principle = _principle;

    require(_exchangeRate >= 100, "_exchangeRate too small, 100 means 1$");
    require(_exchangeRate <= 10000, "_exchangeRate too large, 10000 means 100$");
    exchangeRate = _exchangeRate;
  }

  /* ========== OWNABLE ========== */

  /**
   * @notice update exchange rate, only owner available
   * @param _exchangeRate Token address
   */
  function updateExchangeRate(uint256 _exchangeRate) external onlyOwner {
    require(_exchangeRate >= 100, "_exchangeRate too small, 100 means 1$");
    require(_exchangeRate <= 10000, "_exchangeRate too large, 10000 means 100$");

    emit UpdateExchangeRate(exchangeRate, _exchangeRate);

    exchangeRate = _exchangeRate;
  }

  /**
   * @notice withdraw, only owner available
   * @param _token Token address
   * @param _amount withdraw amount
   * @param _recipient The address to receive
   */
  function withdraw(
    address _token,
    uint256 _amount,
    address _recipient
  ) external onlyOwner {
    require(_token != address(0), "Zero address: _token");
    require(_token != FIDL, "FIDL can not withdraw");
    require(_amount > 0, "Zero amount");

    if (_recipient == address(0)) {
      _recipient = msg.sender;
    }

    IERC20Metadata(_token).approve(_recipient, _amount);
    IERC20Metadata(_token).safeTransferFrom(address(this), _recipient, _amount);
  }

  /**
   * @notice toggle shutdown
   */
  function halt() external onlyOwner {
    shutdown = !shutdown;

    emit Toggled(shutdown);
  }

  /**
   * @notice destroy migrator
   */
  function destroy() external onlyOwner {
    shutdown = true;

    FIDL = address(0);
    principle = address(0);

    exchangeRate = 0;

    emit Destroyed(msg.sender);
  }

  /* ========== MUTATION ========== */
  /**
   * @notice deposit token to this contract (approve first)
   * @param _token Token address to deposit
   * @param _amount Token amount
   */
  function deposit(address _token, uint256 _amount) external {
    require(_amount > 0, "Zero amount");

    IERC20Metadata(_token).safeTransferFrom(msg.sender, address(this), _amount);
  }

  /**
   * @notice exchange FIDL to principle
   * @param _amount FIDL amount
   * @param _recipient The address to receive
   */
  function exchange(uint256 _amount, address _recipient) external {
    require(!shutdown, "shutdown");
    require(_amount > 0, "Zero amount");
    require(_recipient != address(0), "Zero address: _recipient");

    IERC20Metadata(FIDL).safeTransferFrom(msg.sender, address(this), _amount);

    uint256 exchangedCurrency = expect(_amount);

    IERC20Metadata(principle).approve(_recipient, exchangedCurrency);
    IERC20Metadata(principle).safeTransferFrom(address(this), _recipient, exchangedCurrency);

    emit Exchanged(msg.sender, _recipient, exchangeRate, _amount, exchangedCurrency);
  }

  /* ========== VIEW FUNCTIONS ========== */

  /**
   * @notice expect currency from FIDL to principle (control point is 100)
   * @param _amount FIDL amount
   */
  function expect(uint256 _amount) public view returns (uint256) {
    return
      _amount
        .mul(exchangeRate)
        .mul(10**IERC20Metadata(principle).decimals())
        .div(10**IERC20Metadata(FIDL).decimals())
        .div(100);
  }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
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

import { IERC20 } from "../interfaces/IERC20.sol";

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

    require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
  }

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
  }

  function safeApprove(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    (bool success, bytes memory data) = address(token).call(
      abi.encodeWithSelector(IERC20.approve.selector, to, amount)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
  }

  function safeTransferETH(address to, uint256 amount) internal {
    (bool success, ) = to.call{ value: amount }(new bytes(0));

    require(success, "ETH_TRANSFER_FAILED");
  }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.7.5;

import "../interfaces/IOwnable.sol";

abstract contract Ownable is IOwnable {
  address internal _owner;
  address internal _newOwner;

  event OwnershipPushed(
    address indexed previousOwner,
    address indexed newOwner
  );
  event OwnershipPulled(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    _owner = msg.sender;
    emit OwnershipPushed(address(0), _owner);
  }

  function owner() public view override returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function renounceManagement() public virtual override onlyOwner {
    emit OwnershipPulled(_owner, address(0));
    _owner = address(0);
    _newOwner = address(0);
  }

  function pushManagement(address newOwner_) public virtual override onlyOwner {
    emit OwnershipPushed(_owner, newOwner_);
    _newOwner = newOwner_;
  }

  function pullManagement() public virtual override {
    require(msg.sender == _newOwner, "Ownable: must be new owner to pull");
    emit OwnershipPulled(_owner, _newOwner);
    _owner = _newOwner;
    _newOwner = address(0);
  }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

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

interface IOwnable {
  function owner() external view returns (address);

  function renounceManagement() external;

  function pushManagement(address newOwner_) external;

  function pullManagement() external;
}