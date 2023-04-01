/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

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
  uint128 public usdtRate = 1;
  uint128 public vndtRate = 24000;
  address public vndt = 0x82dFB30EB546d988D94c511Ae99b0F31AE9aDa3A;
  address public usdt = 0xFbc9a41E904fe5509f66DAF2A71d1Ae4A229d19A;

  address[] public senders;
  mapping(address => mapping(address => int256)) public balance;

  function swapToken(
    address fromToken,
    uint128 fromAmount,
    address toToken
  ) public returns (uint128 value) {
    uint128 toAmount;

    if (fromToken == vndt && toToken == usdt) {
      toAmount = (fromAmount / vndtRate) * usdtRate;
      ERC20(vndt).transferFrom(msg.sender, address(this), fromAmount);
      ERC20(usdt).transfer(msg.sender, toAmount);
    } else if (fromToken == usdt && toToken == vndt) {
      toAmount = (fromAmount / usdtRate) * vndtRate;
      ERC20(usdt).transferFrom(msg.sender, address(this), fromAmount);
      ERC20(vndt).transfer(msg.sender, toAmount);
    } else {
      revert("Invalid swap");
    }

    return toAmount;
  }

  function gaslessSwap(
    address fromToken,
    uint128 fromAmount,
    address toToken
  ) external {
    uint128 toAmount = swapToken(fromToken, fromAmount, toToken);
    updateBalance(fromToken, fromAmount, toToken, toAmount);
    senders.push(msg.sender);
  }

  function commit() external isOwner {
    for (uint128 i = 0; i < senders.length; i++) {
      address sender = senders[i];
      resolveBalance(vndt, sender);
      resolveBalance(usdt, sender);
    }

    resolveSenders();
  }

  function resolveBalance(address token, address sender) internal {
    uint256 amount = uint256(balance[vndt][sender]);

    if (amount > 0) {
      ERC20(token).transferFrom(sender, address(this), uint256(amount));
    } else if (amount < 0) {
      ERC20(token).transfer(sender, uint256(amount));
    }

    delete balance[vndt][sender];
  }

  function resolveSenders() internal {
    senders = new address[](0);
  }

  function updateBalance(
    address fromToken,
    uint128 fromAmount,
    address toToken,
    uint128 toAmount
  ) internal {
    if (fromToken == vndt) {
      balance[msg.sender][vndt] += toSigned256(fromAmount);
    } else {
      balance[msg.sender][usdt] += toSigned256(fromAmount);
    }

    if (toToken == vndt) {
      balance[msg.sender][vndt] -= toSigned256(toAmount);
    } else {
      balance[msg.sender][usdt] -= toSigned256(toAmount);
    }
  }

  function deposit(address token, uint128 amount) public isOwner {
    ERC20(token).transferFrom(msg.sender, address(this), amount);
  }

  function withdraw(address token, uint128 amount) external {
    ERC20(token).transfer(msg.sender, amount);
  }

  function toSigned256(uint128 amount) internal pure returns (int256 value) {
    return int256(uint256(amount));
  }
}