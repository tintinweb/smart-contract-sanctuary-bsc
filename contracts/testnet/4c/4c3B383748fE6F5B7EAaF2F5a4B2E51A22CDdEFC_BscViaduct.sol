// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

interface IAddressesProvider {
  /***************************************************** */
  /*********************GETTERS************************* */
  /***************************************************** */
  function getAddress(bytes32 id) external view returns (address);

  function getACLManager() external view returns (address);

  function getSpent() external view returns (address);

  function getEusd() external view returns (address);

  function getACLAdmin() external view returns (address);

  function getZapContract() external view returns (address);

  function getBscViaDuctContract() external returns (address);

  function getBarterRouter() external view returns (address);

  function getBarterFactory() external view returns (address);

  function getUpRightContract() external view returns (address);

  function getCropYardContract() external view returns (address);

  function getPrimeContract() external view returns (address);

  function getFiskContract() external view returns (address);

  function getWhitelistContract() external view returns (address);

  function getUprightStableContract() external view returns (address);

  function getUprightLpContract() external view returns (address);

  function getUprightSwapTokenContract() external view returns (address);

  function getUprightBstContract() external view returns (address);

  function getBorrowLendContract() external view returns (address);

  /***************************************************** */
  /*********************SETTERS************************* */
  /***************************************************** */

  function setAddress(bytes32 id, address newAddress) external;

  function setACLManager(address newAclManager) external;

  function setACLAdmin(address newAclAdmin) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

// FIXME: seggregate errors
library Errors {
  /*********************************************************** */
  /****************************RBAC*************************** */
  /*********************************************************** */
  string public constant CALLER_NOT_ADMIN = "CALLER_NOT_ADMIN"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_OWNER = "CALLER_NOT_OWNER"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_MODERATOR = "CALLER_NOT_MODERATOR"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_SWAP = "CALLER_NOT_SWAP"; // 'The caller of the function is not a pool admin'
  string public constant ACL_ADMIN_CANNOT_BE_ZERO = "ACL_ADMIN_CANNOT_BE_ZERO";

  /*********************************************************** */
  /*************************WHITELISTING********************** */
  /*********************************************************** */
  string public constant ALREADY_WHITELISTED = "ALREADY_WHITELISTED";
  string public constant CALLER_OR_POOL_NOT_WHITELISTED = "CALLER_OR_POOL_NOT_WHITELISTED";
  string public constant REF_NOT_WHITELISTED = "REF_NOT_WHITELISTED";
  string public constant CANNOT_BE_CALLED_BY_MEMBER = "CANNOT_BE_CALLED_BY_MEMBER";
  /*********************************************************** */
  /****************************ERC20************************** */
  /*********************************************************** */
  string public constant AMOUNT_ZERO = "AMOUNT_ZERO";
  string public constant LOW_ALLOWANCE = "LOW_ALLOWANCE";
  string public constant INSUFFICIENT_AMOUNT = "INSUFFICIENT_AMOUNT";
  string public constant LOW_BALANCE = "LOW_BALANCE";
  /*********************************************************** */
  /*************************ZERO_ERROR************************ */
  /*********************************************************** */
  string public constant LP_AMOUNT_INVALID = "LP_AMOUNT_INVALID";
  string public constant AMOUNT_INVALID = "AMOUNT_INVALID";
  string public constant NO_TOKEN_IN_CONTRACT = "NO_TOKEN_IN_CONTRACT";
  /*********************************************************** */
  /**************************LOCKED*************************** */
  /*********************************************************** */
  string public constant LP_NOT_UNLOCABLE_YET = "LP_NOT_UNLOCABLE_YET";
  /*********************************************************** */
  /**************************STAKE*************************** */
  /*********************************************************** */
  string public constant WRONG_LP = "WRONG_LP";
  string public constant NOT_CLIAMABLE_YET = "NOT_CLIAMABLE_YET";
  string public constant NOT_UNSTAKABLE_YET = "NOT_UNSTAKABLE_YET";
  string public constant LOW_LOCK_DURATION = "LOW_LOCK_DURATION";
  /*********************************************************** */
  /**************************TRANSACTION************************ */
  /************************************************************ */
  string public constant TRANSACTION_FAILED = "TRANSACTION_FAILED";
  /*********************************************************** */
  /**************************VIA-DUCT************************* */
  /*********************************************************** */
  string public constant ZERO_AFTER_DEDUCTIONS = "ZERO_AFTER_DEDUCTIONS";
  string public constant ZERO_AFTER_VALUATIONS = "ZERO_AFTER_VALUATIONS";
  string public constant LOW_EUSD_BALANCE_IN_CONTRACT = "LOW_EUSD_BALANCE_IN_CONTRACT";
}

// contracts/DaddyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IMERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);

  function mint(uint256 amount, address account) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { IAddressesProvider } from "../../common/configuration/AddressProvider/IAddressesProvider.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IBscViaDuct } from "./interface/IBscViaDuct.sol";
import { IMERC20 } from "../tokenization/interface/IMERC20.sol";
import { Errors } from "../../common/libraries/helpers/Errors.sol";

// this is for BUSD and bnb
contract BscViaduct is IBscViaDuct, ReentrancyGuard {
  IAddressesProvider public immutable ADDRESSES_PROVIDER;
  AggregatorV3Interface public BNB_PRICE_FEED;
  AggregatorV3Interface public BUSD_PRICE_FEED;

  address public _eBusd;
  address public _BUSD;
  address public _eBNB;

  uint256 public _fee;

  constructor(address _bnbPriceFeed, address _busdPriceFeed, address _ebusd, address _ebnb, IAddressesProvider provider, address _busd, uint256 fee) {
    BNB_PRICE_FEED = AggregatorV3Interface(_bnbPriceFeed);
    BUSD_PRICE_FEED = AggregatorV3Interface(_busdPriceFeed);
    ADDRESSES_PROVIDER = provider;
    _eBNB = _ebnb;
    _eBusd = _ebusd;
    _BUSD = _busd;
    _fee = fee;
  }

  function bridgeBnb(address account) public payable override returns (bool) {
    require(msg.value > 0, Errors.AMOUNT_ZERO);

    (uint afterDeduction, ) = deductFees(msg.value);

    require(afterDeduction > 0, Errors.ZERO_AFTER_DEDUCTIONS);

    (uint256 usdValue, uint256 price) = valueOfBnb(afterDeduction);

    require(afterDeduction > 0, Errors.ZERO_AFTER_VALUATIONS);

    require(IMERC20(ADDRESSES_PROVIDER.getEusd()).balanceOf(address(this)) > usdValue, Errors.LOW_EUSD_BALANCE_IN_CONTRACT);

    IMERC20(ADDRESSES_PROVIDER.getEusd()).transfer(account, usdValue);
    IMERC20(_eBNB).mint(msg.value, address(this));

    emit bridgeBNB(account, msg.value, usdValue, price, afterDeduction);

    return true;
  }

  function bridgeBusd(uint256 amount, address account) public override returns (bool) {
    require(amount > 0, Errors.AMOUNT_ZERO);
    require(IMERC20(_BUSD).allowance(account, address(this)) > amount, Errors.LOW_ALLOWANCE);

    IMERC20(_BUSD).transferFrom(account, address(this), amount);

    (uint afterDeduction, ) = deductFees(amount);
    require(afterDeduction > 0, Errors.ZERO_AFTER_DEDUCTIONS);

    (uint256 usdValue, uint256 price) = valueOfBusd(afterDeduction);

    require(usdValue > 0, Errors.ZERO_AFTER_VALUATIONS);

    require(IMERC20(ADDRESSES_PROVIDER.getEusd()).balanceOf(address(this)) > usdValue, Errors.LOW_EUSD_BALANCE_IN_CONTRACT);

    IMERC20(ADDRESSES_PROVIDER.getEusd()).transfer(account, usdValue);

    IMERC20(_eBusd).mint(usdValue, address(this));

    emit bridgeBUSD(account, amount, usdValue, price, afterDeduction);

    return true;
  }

  function deductFees(uint256 amount) private view returns (uint256, uint256) {
    uint256 deductable = (amount * _fee) / 10000;
    uint256 rem = amount - deductable;
    return (rem, deductable);
  }

  function getLatestBnbPrice() public view override returns (uint256) {
    (, int256 price, , , ) = BNB_PRICE_FEED.latestRoundData();
    require(price > 0, "UNABLE_TO_RETRIEVE_BNB_PRICE");
    return uint256(price); // data is in 8 decimals
  }

  function getLatestBusdPrice() public view override returns (uint256) {
    (, int256 price, , , ) = BUSD_PRICE_FEED.latestRoundData();
    require(price > 0, "UNABLE_TO_RETRIEVE_BUSD_PRICE");
    return uint256(price); // data is in 8 decimals
  }

  function valueOfBnb(uint256 _bnbAmount) public view override returns (uint256, uint256) {
    uint256 price = getLatestBnbPrice(); // Price of 1 BNB
    uint256 value = _bnbAmount * price; // Price of given BNB    (18 decimals)
    return ((value / 10 ** 8), price); // Returning in consistence to 18 decimals
  }

  function valueOfBusd(uint256 _busdAmount) public view override returns (uint256, uint256) {
    uint256 price = getLatestBusdPrice(); // Price of 1 BUSD
    uint256 value = _busdAmount * price; // Price of given BUSD    (18 decimals)
    return ((value / 10 ** 8), price); // Returning in consistence to 18 decimals
  }

  // RBCA here
  function setBnbPriceFeed(address _bnbPriceFeed) public override returns (bool) {
    BNB_PRICE_FEED = AggregatorV3Interface(_bnbPriceFeed);
    return true;
  }

  // RBCA here
  function setBusdPriceFeed(address _busdPriceFeed) public override returns (bool) {
    BUSD_PRICE_FEED = AggregatorV3Interface(_busdPriceFeed);
    return true;
  }

  // RBCA here
  function syncBNB(uint256 amount, address payable to) public override returns (bool) {
    require(amount > 0, Errors.AMOUNT_ZERO);
    require(address(this).balance >= amount, Errors.LOW_BALANCE);

    to.transfer(amount);

    return true;
  }

  // RBCA here
  function syncBUSD(uint256 amount, address to) public override returns (bool) {
    require(amount > 0, Errors.AMOUNT_ZERO);
    require(IMERC20(_BUSD).balanceOf(address(this)) >= amount, Errors.LOW_BALANCE);

    IMERC20(_BUSD).transfer(to, amount);

    return true;
  }

  // RBCA
  function setFees(uint256 fee) public override returns (bool) {
    _fee = fee;
    return true;
  }

  // recivalble , fees , price of bnb ,, value of that
  function quoteBNB(uint256 amount) public view override returns (uint256, uint256, uint256, uint256) {
    (uint256 value, uint256 price) = valueOfBnb(amount);

    (uint afterDeduction, uint256 fee) = deductFees(amount);

    return (afterDeduction, fee, price, value);
  }

  // recivalble , fees , price of bnb , value of that
  function quoteBUSD(uint256 amount) public view override returns (uint256, uint256, uint256, uint256) {
    (uint256 value, uint256 price) = valueOfBusd(amount);

    (uint afterDeduction, uint256 fee) = deductFees(amount);

    return (afterDeduction, fee, price, value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IBscViaDuct {
  /********************************************************* */
  /***********************EVENTS**************************** */
  /********************************************************* */

  event bridgeBNB(address from, uint256 bnbAmount, uint256 usdAmount, uint256 price, uint256 eusdMintAmount);
  event bridgeBUSD(address from, uint256 busdAmount, uint256 usdAmount, uint256 price, uint256 eusdMintAmount);

  /********************************************************* */
  /***********************FUNCTIONS************************ */
  /********************************************************* */

  function getLatestBnbPrice() external returns (uint256);

  function getLatestBusdPrice() external returns (uint256);

  function valueOfBnb(uint256 _bnbAmount) external returns (uint256, uint256);

  function valueOfBusd(uint256 _busdAmount) external returns (uint256, uint256);

  function setBnbPriceFeed(address _bnbPriceFeed) external returns (bool);

  function setBusdPriceFeed(address _busdPriceFeed) external returns (bool);

  function bridgeBnb(address account) external payable returns (bool);

  function bridgeBusd(uint256 amount, address account) external returns (bool);

  function syncBNB(uint256 amount, address payable to) external returns (bool);

  function syncBUSD(uint256 amount, address to) external returns (bool);

  function setFees(uint256 fee) external returns (bool);

  function quoteBNB(uint256 amount) external returns (uint256, uint256, uint256, uint256);

  function quoteBUSD(uint256 amount) external returns (uint256, uint256, uint256, uint256);
}