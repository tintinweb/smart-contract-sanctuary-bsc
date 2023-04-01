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

// File: contracts/LiquidityPoolV3.sol


pragma solidity >=0.8.14;


contract LiquidityPoolV3 is Owner {
  uint128 public usdtRate = 1;
  uint128 public vndtRate = 24000;
  address public vndt = 0x82dFB30EB546d988D94c511Ae99b0F31AE9aDa3A;
  address public usdt = 0xFbc9a41E904fe5509f66DAF2A71d1Ae4A229d19A;

  address[] public senders;
  mapping(address => mapping(address => int256)) public balance;

  struct State {
    address[] tokens;
    bytes[] payloads;
  }

  function swap(address fromToken, uint128 fromAmount)
    public
    returns (uint128 value)
  {
    uint128 toAmount;

    if (fromToken == vndt) {
      toAmount = (fromAmount / vndtRate) * usdtRate;
      ERC20(vndt).transferFrom(msg.sender, address(this), uint256(fromAmount));
      ERC20(usdt).transfer(msg.sender, uint256(toAmount));
    } else if (fromToken == usdt) {
      toAmount = (fromAmount / usdtRate) * vndtRate;
      ERC20(usdt).transferFrom(msg.sender, address(this), uint256(fromAmount));
      ERC20(vndt).transfer(msg.sender, uint256(toAmount));
    } else {
      revert("Invalid swap");
    }

    return toAmount;
  }

  function gaslessSwap(address fromToken, uint128 fromAmount) public {
    uint128 toAmount = swap(fromToken, fromAmount);
    updateBalance(fromToken, fromAmount, toAmount);
    senders.push(msg.sender);
  }

  function computeState() public isOwner returns (State memory value) {
    address[] memory tokens = new address[](senders.length * 2);
    bytes[] memory payloads = new bytes[](senders.length * 2);

    for (uint128 i = 0; i < senders.length; i++) {
      address sender = senders[i];
      tokens[2 * i] = usdt;
      payloads[2 * i] = resolveBalance(usdt, sender);
    }

    for (uint128 i = 0; i < senders.length; i++) {
      address sender = senders[i];
      tokens[2 * i + 1] = vndt;
      payloads[2 * i + 1] = resolveBalance(vndt, sender);
    }

    resolveSenders();

    return State(tokens, payloads);
  }

  function commit(address[] memory tokens, bytes[] memory payloads)
    public
    isOwner
  {
    for (uint128 i = 0; i < tokens.length; i++) {
      address token = tokens[i];
      bytes memory payload = payloads[i];
      (bool success, ) = token.call(payload);
      require(success);
    }
  }

  function resolveBalance(address token, address sender)
    internal
    returns (bytes memory payload)
  {
    uint256 amount = uint256(balance[token][sender]);

    if (amount > 0) {
      return
        abi.encodeWithSignature(
          "transferFrom(address,address,uint256)",
          sender,
          address(this),
          uint256(amount)
        );
    } else if (amount < 0) {
      return
        abi.encodeWithSignature(
          "transfer(address,uint256)",
          sender,
          uint256(amount)
        );
    }

    delete balance[vndt][sender];
  }

  function resolveSenders() internal {
    senders = new address[](0);
  }

  function updateBalance(
    address fromToken,
    uint128 fromAmount,
    uint128 toAmount
  ) internal {
    if (fromToken == vndt) {
      balance[vndt][msg.sender] += toSigned256(fromAmount);
      balance[usdt][msg.sender] -= toSigned256(toAmount);
    } else {
      balance[usdt][msg.sender] += toSigned256(fromAmount);
      balance[vndt][msg.sender] -= toSigned256(toAmount);
    }
  }

  function deposit(address token, uint128 amount) public isOwner {
    ERC20(token).transferFrom(msg.sender, address(this), amount);
  }

  function withdraw(address token, uint128 amount) public isOwner {
    ERC20(token).transfer(msg.sender, amount);
  }

  function toSigned256(uint128 amount) internal pure returns (int256 value) {
    return int256(uint256(amount));
  }
}