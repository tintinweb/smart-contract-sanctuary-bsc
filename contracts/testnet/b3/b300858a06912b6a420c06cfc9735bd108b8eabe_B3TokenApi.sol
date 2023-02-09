// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {Owned} from "lib/solmate/src/auth/Owned.sol";
import {SafeToken} from "./libraries/SafeToken.sol";
import {IB3TokenApi} from "./interfaces/IB3TokenApi.sol";

contract B3TokenApi is IB3TokenApi, Owned {
  using SafeToken for address;

  mapping(address => address) public tokens;
  address[] public tokenList;

  constructor(address owner_) Owned(owner_) {}

  // View functions ----------------------------------------
  function getTokenDetails(
    address token
  ) external view override returns (uint256 price, uint256 decimals) {
    if (!isTokenAvailable(token)) revert UnavailableToken(token);

    decimals = token.decimals();
    price = token.priceOf(tokens[token]);
  }

  function userTokenBalance(
    address user,
    address token
  ) public view override returns (uint256) {
    return token.balanceOf(user);
  }

  function userTokenAllowance(
    address user,
    address token,
    address spender
  ) public view override returns (uint256) {
    return token.allowance(user, spender);
  }

  function userTokenInformation(
    address user,
    address spender
  )
    external
    view
    override
    returns (
      string[] memory symbols,
      uint256[] memory balances,
      uint256[] memory allowances
    )
  {
    symbols = new string[](tokenList.length);
    balances = new uint256[](tokenList.length);
    allowances = new uint256[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      address token = tokenList[i];
      symbols[i] = token.symbol();
      balances[i] = userTokenBalance(user, token);
      allowances[i] = userTokenAllowance(user, token, spender);
    }
  }

  function isTokenAvailable(address token) public view override returns (bool) {
    return tokens[token] != address(0);
  }

  function allTokens() external view override returns (address[] memory) {
    return tokenList;
  }

  function allPriceFeeds() external view override returns (address[] memory feedArray) {
    uint256 length = tokenList.length;
    feedArray = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      address token = tokenList[i];
      if (isTokenAvailable(token)) feedArray[i] = tokens[token];
    }
  }

  function allTokensInformation()
    external
    view
    override
    returns (
      address[] memory addresses,
      string[] memory symbols,
      uint256[] memory decimals,
      uint256[] memory prices
    )
  {
    uint256 length = tokenList.length;

    prices = new uint256[](length);
    symbols = new string[](length);
    decimals = new uint256[](length);
    addresses = new address[](length);

    for (uint256 i = 0; i < length; i++) {
      address token = tokenList[i];
      prices[i] = token.priceOf(tokens[token]);
      symbols[i] = token.symbol();
      decimals[i] = token.decimals();
      addresses[i] = token;
    }
  }

  // Modify functions ---------------------------------------
  function addToken(address token, address feed) public onlyOwner {
    if (!isTokenAvailable(token)) {
      tokenList.push(token);
      emit NewToken(token, feed);
    }

    tokens[token] = feed;
  }

  function removeToken(address token) external onlyOwner {
    delete tokens[token];
    cleanTokenList();
  }

  function batchAddToken(
    address[] memory tokenArray,
    address[] memory feedArray
  ) external onlyOwner {
    if (tokenArray.length != feedArray.length) revert("BadLength");
    for (uint256 i = 0; i < tokenArray.length; i++) {
      addToken(tokenArray[i], feedArray[i]);
    }
  }

  function batchRemoveToken(address[] memory tokenArray) external onlyOwner {
    for (uint256 i = 0; i < tokenArray.length; i++) {
      delete tokens[tokenArray[i]];
    }
    cleanTokenList();
  }

  function cleanTokenList() public onlyOwner {
    for (uint256 i = 0; i < tokenList.length; i++) {
      if (!isTokenAvailable(tokenList[i])) {
        tokenList[i] = tokenList[tokenList.length - 1];
        tokenList.pop();
        emit RemoveToken(tokenList[i]);
      }
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAggregator {
  function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

interface IB3TokenApi {
  error UnavailableToken(address token);

  event NewToken(address token, address feed);
  event RemoveToken(address token);

  function getTokenDetails(
    address token
  ) external view returns (uint256 price, uint256 decimals);

  function userTokenBalance(address user, address token) external view returns (uint256);

  function userTokenAllowance(
    address user,
    address token,
    address spender
  ) external view returns (uint256);

  function userTokenInformation(
    address user,
    address spender
  )
    external
    view
    returns (
      string[] memory symbols,
      uint256[] memory balances,
      uint256[] memory allowances
    );

  function isTokenAvailable(address token) external view returns (bool);

  function allTokens() external view returns (address[] memory);

  function allPriceFeeds() external view returns (address[] memory);

  function allTokensInformation()
    external
    view
    returns (
      address[] memory addresses,
      string[] memory symbols,
      uint256[] memory decimals,
      uint256[] memory prices
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "lib/solmate/src/tokens/ERC20.sol";
import "../interfaces/IAggregator.sol";

interface IUniswapV3Pool {
  function slot0()
    external
    view
    returns (
      uint160 sqrtPriceX96,
      int24 tick,
      uint16 observationIndex,
      uint16 observationCardinality,
      uint16 observationCardinalityNext,
      uint8 feeProtocol,
      bool unlocked
    );

  function token0() external view returns (address);
}

// make a library for addresses that can use for permit2
library SafeToken {
  error InvalidToken(address token);

  function symbol(address token) internal view returns (string memory) {
    if (token == address(0)) return "ETH";

    return ERC20(token).symbol();
  }

  function decimals(address token) internal view returns (uint256) {
    if (token == address(0)) return 18;

    return ERC20(token).decimals();
  }

  function balanceOf(address token, address user) internal view returns (uint256) {
    if (token == address(0)) return user.balance;

    return ERC20(token).balanceOf(user);
  }

  function allowance(
    address token,
    address user,
    address spender
  ) internal view returns (uint256) {
    if (token == address(0)) return type(uint256).max;

    return ERC20(token).allowance(user, spender);
  }

  function priceOf(address token, address feed) internal view returns (uint256 price) {
    // if the chainlink price feed available get it if not fallback to the Uniswap price
    int256 aggregatorPrice = IAggregator(feed).latestAnswer();

    if (aggregatorPrice <= 0) {
      // fallback to the Uniswap price
      bool zeroForOne = IUniswapV3Pool(token).token0() == token;

      (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(token).slot0();

      uint256 priceX96 = zeroForOne
        ? uint256(sqrtPriceX96) * uint256(sqrtPriceX96)
        : type(uint256).max / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96));

      price = priceX96 >> 96;
    } else {
      price = uint256(aggregatorPrice);
    }

    if (price <= 0) revert InvalidToken(token);
  }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}