//SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./interfaces/ERC20Interface.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/PriceOracle.sol";
import "./interfaces/AggregatorV3Interface.sol";
import "./MultiSigOwner.sol";

contract OkseCardPriceOracle is PriceOracle, MultiSigOwner {
    using SafeMath for uint256;

    mapping(address => uint256) prices;
    event PricePosted(
        address asset,
        uint256 previousPriceMantissa,
        uint256 requestedPriceMantissa,
        uint256 newPriceMantissa
    );

    mapping(address => address) priceFeeds;
    event PriceFeedChanged(
        address asset,
        address previousPriceFeed,
        address newPriceFeed
    );

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        //////bsc///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if (chainId == 56) {
            priceFeeds[
                0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
            ] = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; // BNB/USD
            priceFeeds[
                0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d
            ] = 0x51597f405303C4377E36123cBc172b13269EA163; // USDC/USD
            priceFeeds[
                0x55d398326f99059fF775485246999027B3197955
            ] = 0xB97Ad0E74fa7d920791E90258A6E2085088b4320; // USDT/USD
            priceFeeds[
                0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
            ] = 0xcBb98864Ef56E9042e7d2efef76141f15731B82f; // BUSD/USD
            priceFeeds[
                0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c
            ] = 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf; // WBTC/USD
            priceFeeds[
                0x2170Ed0880ac9A755fd29B2688956BD959F933F8
            ] = 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e; // ETH/USD
        }
        //// matic //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if (chainId == 137) {
            priceFeeds[
                0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270
            ] = 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0; // MATIC/USD
            priceFeeds[
                0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174
            ] = 0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7; // USDC/USD
            priceFeeds[
                0xc2132D05D31c914a87C6611C10748AEb04B58e8F
            ] = 0x0A6513e40db6EB1b165753AD52E80663aeA50545; // USDT/USD
            priceFeeds[
                0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6
            ] = 0xDE31F8bFBD8c84b5360CFACCa3539B938dd78ae6; // WBTC/USD
            priceFeeds[
                0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619
            ] = 0xF9680D99D6C9589e2a93a78A04A279e509205945; // ETH/USD
            priceFeeds[
                0x0b3F868E0BE5597D5DB7fEB59E1CADBb0fdDa50a
            ] = 0x49B0c695039243BBfEb8EcD054EB70061fd54aa0; // SUSHI/USD
            priceFeeds[
                0xa3Fa99A148fA48D14Ed51d610c367C61876997F1
            ] = 0xd8d483d813547CfB624b8Dc33a00F2fcbCd2D428; // MIMATIC/USD
        }
        //// fantom //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if (chainId == 250) {
            priceFeeds[
                0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83
            ] = 0xf4766552D15AE4d256Ad41B6cf2933482B0680dc; // FTM/USD
            priceFeeds[
                0x04068DA6C83AFCFA0e13ba15A6696662335D5B75
            ] = 0x2553f4eeb82d5A26427b8d1106C51499CBa5D99c; // USDC/USD
            priceFeeds[
                0x049d68029688eAbF473097a2fC38ef61633A3C7A
            ] = 0xF64b636c5dFe1d3555A847341cDC449f612307d0; // fUSDT/USD
            priceFeeds[
                0x321162Cd933E2Be498Cd2267a90534A804051b11
            ] = 0x8e94C22142F4A64b99022ccDd994f4e9EC86E4B4; // WBTC/USD
            priceFeeds[
                0x74b23882a30290451A17c44f4F05243b6b58C76d
            ] = 0x11DdD3d147E5b83D01cee7070027092397d63658; // WETH/USD
            priceFeeds[
                0xae75A438b2E0cB8Bb01Ec1E1e376De11D44477CC
            ] = 0xCcc059a1a17577676c8673952Dc02070D29e5a66; // SUSHI/USD
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }

    //return usd price of asset , decimal is 8
    function getUnderlyingPrice(address market)
        public
        view
        override
        returns (uint256)
    {
        uint80 roundID;
        int256 price;
        uint256 startedAt;
        uint256 timeStamp;
        uint80 answeredInRound;

        uint256 resultPrice;

        if (prices[market] != 0) {
            resultPrice = prices[market];
        } else {
            if (priceFeeds[market] != address(0)) {
                (
                    roundID,
                    price,
                    startedAt,
                    timeStamp,
                    answeredInRound
                ) = AggregatorV3Interface(priceFeeds[market]).latestRoundData();
            } else {
                price = 0;
            }
            resultPrice = uint256(price);
        }
        uint256 defaultDecimal = 18;
        ERC20Interface token = ERC20Interface(market);
        uint256 tokenDecimal = uint256(token.decimals());
        if (defaultDecimal == tokenDecimal) {
            return resultPrice;
        } else if (defaultDecimal > tokenDecimal) {
            return resultPrice.mul(10**(defaultDecimal.sub(tokenDecimal)));
        } else {
            return resultPrice.div(10**(tokenDecimal.sub(defaultDecimal)));
        }
    }

    function assetPrices(address asset) external view returns (uint256) {
        return prices[asset];
    }

    function setDirectPrice(bytes calldata signData, bytes calldata keys)
        external
        validSignOfOwner(signData, keys, "setDirectPrice")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (address asset, uint256 price) = abi.decode(params, (address, uint256));
        setDirectPriceInternal(asset, price);
    }

    function setBatchDirectPrice(bytes calldata signData, bytes calldata keys)
        external
        validSignOfOwner(signData, keys, "setBatchDirectPrice")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (address[] memory _assets, uint256[] memory _prices) = abi.decode(
            params,
            (address[], uint256[])
        );
        require(_assets.length == _prices.length, "le");
        for (uint256 i = 0; i < _assets.length; i++) {
            setDirectPriceInternal(_assets[i], _prices[i]);
        }
    }

    function setDirectPriceInternal(address asset, uint256 price) internal {
        emit PricePosted(asset, prices[asset], price, price);
        prices[asset] = price;
    }

    function setPriceFeed(bytes calldata signData, bytes calldata keys)
        external
        validSignOfOwner(signData, keys, "setPriceFeed")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        (address asset, address priceFeed) = abi.decode(
            params,
            (address, address)
        );
        emit PriceFeedChanged(asset, priceFeeds[asset], priceFeed);
        priceFeeds[asset] = priceFeed;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

interface ERC20Interface {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return add(a, b, "SafeMath: addition overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, errorMessage);

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

abstract contract PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    bool public constant isPriceOracle = true;

    /**
      * @notice Get the underlying price of a cToken asset
      * @param market The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address market) external virtual view returns (uint);

}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// SPDX-License-Identifier: LICENSED
pragma solidity ^0.7.0;
pragma abicoder v2;

// 2/3 Multi Sig Owner
contract MultiSigOwner {
    address[] public owners;
    mapping(uint256 => bool) public signatureId;
    bool private initialized;
    // events
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SignValidTimeChanged(uint256 newValue);
    modifier validSignOfOwner(
        bytes calldata signData,
        bytes calldata keys,
        string memory functionName
    ) {
        require(isOwner(msg.sender), "on");
        address signer = getSigner(signData, keys);
        require(
            signer != msg.sender && isOwner(signer) && signer != address(0),
            "is"
        );
        (bytes4 method, uint256 id, uint256 validTime, ) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        require(
            signatureId[id] == false &&
                method == bytes4(keccak256(bytes(functionName))),
            "sru"
        );
        require(validTime > block.timestamp, "ep");
        signatureId[id] = true;
        _;
    }

    function isOwner(address addr) public view returns (bool) {
        bool _isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == addr) {
                _isOwner = true;
            }
        }
        return _isOwner;
    }

    constructor() {}

    function initializeOwners(address[3] memory _owners) public {
        require(
            !initialized &&
                _owners[0] != address(0) &&
                _owners[1] != address(0) &&
                _owners[2] != address(0),
            "ai"
        );
        owners = [_owners[0], _owners[1], _owners[2]];
        initialized = true;
    }

    function getSigner(bytes calldata _data, bytes calldata keys)
        public
        view
        returns (address)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(
            keys,
            (uint8, bytes32, bytes32)
        );
        return
            ecrecover(
                toEthSignedMessageHash(
                    keccak256(abi.encodePacked(this, chainId, _data))
                ),
                v,
                r,
                s
            );
    }

    function encodePackedData(bytes calldata _data)
        public
        view
        returns (bytes32)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return keccak256(abi.encodePacked(this, chainId, _data));
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    // Set functions
    // verified
    function transferOwnership(bytes calldata signData, bytes calldata keys)
        public
        validSignOfOwner(signData, keys, "transferOwnership")
    {
        (, , , bytes memory params) = abi.decode(
            signData,
            (bytes4, uint256, uint256, bytes)
        );
        address newOwner = abi.decode(params, (address));
        uint256 index;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                index = i;
            }
        }
        address oldOwner = owners[index];
        owners[index] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}