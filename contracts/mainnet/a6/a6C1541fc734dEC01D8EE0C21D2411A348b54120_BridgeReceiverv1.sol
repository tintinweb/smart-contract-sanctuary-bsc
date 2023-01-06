/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _transferOwnership(_msgSender());
  }

  modifier onlyOwner() {
    _checkOwner();
    _;
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  function _checkOwner() internal view virtual {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
      address from,
      address to,
      uint256 amount
  ) external returns (bool);
}

interface IERC20Permit {
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
  function nonces(address owner) external view returns (uint256);
  function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library Address {
  function isContract(address account) internal view returns (bool) {
    return account.code.length > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");

    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");

    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");

    (bool success, bytes memory returndata) = target.delegatecall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) internal pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}

library SafeERC20 {
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
  }

  function safePermit(
    IERC20Permit token,
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal {
    uint256 nonceBefore = token.nonces(owner);
    token.permit(owner, spender, value, deadline, v, r, s);
    uint256 nonceAfter = token.nonces(owner);
    require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}

interface IUniswapRouterETH {
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
  
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IWETH is IERC20 {
  function deposit() external payable;
  function withdraw(uint256 wad) external;
}

contract BridgeReceiverv1 is Ownable {
  using SafeERC20 for IERC20;
  
  mapping (address => bool) public managers;

  constructor() {
    managers[msg.sender] = true;
    managers[0x5e1f49A1349dd35FACA241eB192c6c2EDF47EF46] = true;
  }

  modifier onlyManager() {
    require(managers[msg.sender], "!manager");
    _;
  }

  receive() external payable {
  }

  function redeem(address account, address token, uint256 amount, uint256 fee, address unirouter, address[] memory path) public onlyManager {
    require(IERC20(token).balanceOf(address(this)) >= amount, "BridgeReceiverv1: redeem not completed");
    if (fee > 0) {
      uint256[] memory reqamounts = IUniswapRouterETH(unirouter).getAmountsIn(fee, path);
      uint256 reqAmount = reqamounts[0];
      if (amount > reqAmount) {
        amount -= reqAmount;
      }
      else {
        reqAmount = amount;
        amount = 0;
      }
      _approveTokenIfNeeded(token, unirouter);
      uint256[] memory amounts = IUniswapRouterETH(unirouter).swapExactTokensForTokens(reqAmount, 0, path, address(this), block.timestamp);
      _removeAllowances(token, unirouter);
      uint256 nativeBalance = amounts[amounts.length - 1];
      IWETH(path[path.length-1]).withdraw(nativeBalance);

      (bool success, ) = msg.sender.call{value: nativeBalance}("");
      require(success, "BridgeReceiverv1: send fee");
    }

    if (amount > 0) {
      IERC20(token).safeTransfer(account, amount);
    }
  }

  function redeemAndSwap(address account, address token, uint256 amount, uint256 fee, address unirouter, address[] memory path) public onlyManager {
    require(IERC20(token).balanceOf(address(this)) >= amount, "BridgeReceiverv1: redeem not completed");
    _approveTokenIfNeeded(token, unirouter);
    uint256[] memory amounts = IUniswapRouterETH(unirouter).swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);
    _removeAllowances(token, unirouter);
    uint256 nativeBalance = amounts[amounts.length - 1];
    IWETH(path[path.length-1]).withdraw(nativeBalance);

    if (nativeBalance > fee) {
      (bool success, ) = payable(account).call{value: nativeBalance - fee}("");
      require(success, "BridgeReceiverv1: redeem");
    }

    if (fee > 0) {
      if (nativeBalance > fee) {
        (bool success, ) = msg.sender.call{value: fee}("");
        require(success, "BridgeReceiverv1: send fee");
      }
      else {
        (bool success, ) = msg.sender.call{value: nativeBalance}("");
        require(success, "BridgeReceiverv1: send fee");
      }
    }
  }

  function redeemAndSwapFromCoin(address account, uint256 amount, uint256 fee, address unirouter, address[] memory path) public onlyManager {
    require(address(this).balance >= amount, "BridgeReceiverv1: lc redeem not completed");

    if (fee > 0) {
      if (amount > fee) {
        (bool success, ) = msg.sender.call{value: fee}("");
        require(success, "BridgeReceiverv1: send fee");
        amount -= fee;
      }
      else {
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "BridgeReceiverv1: send fee");
        amount = 0;
      }
    }

    if (amount > 0) {
      IWETH(path[0]).deposit{value: amount}();
      _approveTokenIfNeeded(path[0], unirouter);
      uint256[] memory amounts = IUniswapRouterETH(unirouter).swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);
      _removeAllowances(path[0], unirouter);

      IERC20(path[path.length-1]).safeTransfer(account, amounts[amounts.length-1]);
    }
  }

  function setManager(address account, bool access) public onlyOwner {
    managers[account] = access;
  }

  function _approveTokenIfNeeded(address token, address spender) private {
    if (IERC20(token).allowance(address(this), spender) == 0) {
      IERC20(token).approve(spender, type(uint256).max);
    }
  }

  function _removeAllowances(address token, address spender) private {
    if (IERC20(token).allowance(address(this), spender) > 0) {
      IERC20(token).approve(spender, 0);
    }
  }
}