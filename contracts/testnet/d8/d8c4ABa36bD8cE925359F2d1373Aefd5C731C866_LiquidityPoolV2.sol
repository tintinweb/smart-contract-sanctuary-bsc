/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// File: contracts/ERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.14;

interface ERC20 {
  function totalSupply() external returns (uint256);

  function balanceOf(address tokenOwner) external returns (uint256 balance);

  function allowance(address tokenOwner, address spender)
    external
    returns (uint256 remaining);

  function transfer(address to, uint256 tokens) external returns (bool success);

  function approve(address spender, uint256 tokens)
    external
    returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 tokens
  ) external returns (bool success);

  event Transfer(address indexed from, address indexed to, uint256 tokens);
  event Approval(
    address indexed tokenOwner,
    address indexed spender,
    uint256 tokens
  );
}

// File: contracts/Owner.sol


pragma solidity >=0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {
  address private owner;

  // event for EVM logging
  event OwnerSet(address indexed oldOwner, address indexed newOwner);

  // modifier to check if caller is owner
  modifier isOwner() {
    // If the first argument of 'require' evaluates to 'false', execution terminates and all
    // changes to the state and to Ether balances are reverted.
    // This used to consume all gas in old EVM versions, but not anymore.
    // It is often a good idea to use 'require' to check if functions are called correctly.
    // As a second argument, you can also provide an explanation about what went wrong.
    require(msg.sender == owner, "Caller is not owner");
    _;
  }

  /**
   * @dev Set contract deployer as owner
   */
  constructor() {
    owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    emit OwnerSet(address(0), owner);
  }

  /**
   * @dev Change owner
   * @param newOwner address of new owner
   */
  function changeOwner(address newOwner) public isOwner {
    emit OwnerSet(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Return owner address
   * @return address of owner
   */
  function getOwner() external view returns (address) {
    return owner;
  }
}

// File: contracts/LiquidityPoolV2.sol


pragma solidity >=0.8.14;


contract LiquidityPoolV2 is Owner {
  address public vndt = 0x82dFB30EB546d988D94c511Ae99b0F31AE9aDa3A;
  address public usdt = 0xFbc9a41E904fe5509f66DAF2A71d1Ae4A229d19A;
  uint256 public vndtRate = 24000;
  uint256 public usdtRate = 1;

  function swapTokens(
    address _fromToken,
    uint256 _fromAmount,
    address _toToken
  ) external {
    uint256 toAmount;
    if (_fromToken == vndt && _toToken == usdt) {
      toAmount = (_fromAmount / vndtRate) * usdtRate;
      ERC20(vndt).transferFrom(msg.sender, address(this), _fromAmount);
      ERC20(usdt).transfer(msg.sender, toAmount);
    } else if (_fromToken == usdt && _toToken == vndt) {
      toAmount = (_fromAmount / usdtRate) * vndtRate;
      ERC20(usdt).transferFrom(msg.sender, address(this), _fromAmount);
      ERC20(vndt).transfer(msg.sender, toAmount);
    } else {
      revert("Invalid swap");
    }
  }

  function depositVndt(uint256 _amount) external isOwner {
    ERC20(vndt).transferFrom(msg.sender, address(this), _amount);
  }

  function depositUsdt(uint256 _amount) external isOwner {
    ERC20(usdt).transferFrom(msg.sender, address(this), _amount);
  }

  function withdrawVndt(uint256 _amount) external isOwner {
    ERC20(vndt).transfer(msg.sender, _amount);
  }

  function withdrawUsdt(uint256 _amount) external isOwner {
    ERC20(usdt).transfer(msg.sender, _amount);
  }
}