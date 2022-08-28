// SPDX-License-Identifier: None
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract OrderBook is Ownable {

  address _baseCurrencyAddress;
  address _quoteCurrencyAddress;

  uint maxBaseAsset;
  uint maxBaseValue;
  uint minBaseAsset;
  uint minBaseValue;

  uint maxQuoteAsset;
  uint maxQuoteValue;
  uint minQuoteAsset;
  uint minQuoteValue;

  uint minSellPrice;
  uint maxSellPrice;
  uint minBuyPrice;
  uint maxBuyPrice;

  uint48 constant maxAmount = type(uint48).max;

  uint _baseCurrencyUnit; // real amount = (amount in contract) * (base unit)
  uint _quoteCurrencyUnit;
  uint _priceDivisor; // real price = (price in contract) / (price divisor)
  uint _quoteDivisor;
  uint _baseDivisor;

  function _getDecimals(address token) private view returns (uint) {
    return token == address(0) ? 18 : IERC20Metadata(token).decimals();
  }

  function _getSymbol(address token) private view returns (string memory) {
    return token == address(0) ? "BNB" : IERC20Metadata(token).symbol();
  }

  constructor(
    address baseCurrencyAddress,
    address quoteCurrencyAddress,
    uint baseCurrencyUnit,
    uint quoteCurrencyUnit,
    uint priceDivisor
  ) {
    _baseCurrencyAddress = baseCurrencyAddress;
    _quoteCurrencyAddress = quoteCurrencyAddress;

    _baseCurrencyUnit = baseCurrencyUnit;
    _quoteCurrencyUnit = quoteCurrencyUnit;

    _priceDivisor = priceDivisor;
    uint baseDecimals = _getDecimals(baseCurrencyAddress);
    uint quoteDecimals = _getDecimals(quoteCurrencyAddress);
    _baseDivisor  = 10**baseDecimals;
    _quoteDivisor = 10**quoteDecimals;

    maxBaseAsset = exactBaseAmount(maxAmount);
    maxBaseValue = exactBaseAmount(maxAmount);
    minBaseAsset = exactBaseAmount(1);
    minBaseValue = exactBaseAmount(1);

    maxQuoteAsset = exactQuoteAmount(maxAmount);
    maxQuoteValue = exactQuoteAmount(maxAmount);
    minQuoteAsset = exactQuoteAmount(1);
    minQuoteValue = exactQuoteAmount(1);

    minSellPrice = 1;
    maxSellPrice = type(uint).max/(exactQuoteAmount(maxAmount))/(_baseDivisor);
    minBuyPrice = 1;
    maxBuyPrice = type(uint).max/(exactQuoteAmount(maxAmount))/(_baseDivisor);

  }

  function setLimitSellRanges(
    uint minAsset,
    uint maxAsset,
    uint minValue,
    uint maxValue,
    uint minPrice,
    uint maxPrice
  ) public onlyOwner {
    require(minAsset < maxAsset, "minAsset >= maxAsset");
    require(minValue < maxValue, "minValue >= maxValue");
    require(minPrice < maxPrice, "minPrice >= maxPrice");
    require(minAsset >= exactBaseAmount(1), "minAsset too high");
    require(maxAsset <= exactBaseAmount(maxAmount), "maxAsset too high");
    require(minValue >= exactQuoteAmount(1), "minValue too high");
    require(maxValue <= exactQuoteAmount(maxAmount), "maxValue too high");
    require(minPrice > 0, "minPrice too low");
    require(maxPrice <= type(uint).max/(exactQuoteAmount(maxAmount))/(_baseDivisor), "maxPrice too high");
    if(minAsset > 0 && minAsset != minBaseAsset) minBaseAsset = minAsset;
    if(maxAsset > 0 && maxAsset != maxBaseAsset) maxBaseAsset = maxAsset;
    if(minValue > 0 && minValue != minQuoteValue) minQuoteValue = minValue;
    if(maxValue > 0 && maxValue != maxQuoteValue) maxQuoteValue = maxValue;
    if(minPrice > 0 && minPrice != minSellPrice) minSellPrice = minPrice;
    if(maxPrice > 0 && maxPrice != maxSellPrice) maxSellPrice = maxPrice;
  }

  function setLimitBuyRanges(
    uint minAsset,
    uint maxAsset,
    uint minValue,
    uint maxValue,
    uint minPrice,
    uint maxPrice
  ) public onlyOwner {
    require(minAsset < maxAsset, "minAsset >= maxAsset");
    require(minValue < maxValue, "minValue >= maxValue");
    require(minPrice < maxPrice, "minPrice >= maxPrice");
    require(minAsset >= exactQuoteAmount(1), "minAsset too high");
    require(maxAsset <= exactQuoteAmount(maxAmount), "maxAsset too high");
    require(minValue >= exactBaseAmount(1), "minValue too high");
    require(maxValue <= exactBaseAmount(maxAmount), "maxValue too high");
    require(minPrice > 0, "minPrice too low");
    require(maxPrice <= type(uint).max/(exactQuoteAmount(maxAmount))/(_baseDivisor), "maxPrice too high");
    if(minValue > 0 && minValue != minBaseValue) minBaseValue = minValue;
    if(maxValue > 0 && maxValue != maxBaseValue) maxBaseValue = maxValue;
    if(minAsset > 0 && minAsset != minQuoteAsset) minQuoteAsset = minAsset;
    if(maxAsset > 0 && maxAsset != maxQuoteAsset) maxQuoteAsset = maxAsset;
    if(minPrice > 0 && minPrice != minBuyPrice) minBuyPrice = minPrice;
    if(maxPrice > 0 && maxPrice != maxBuyPrice) maxBuyPrice = maxPrice;
  }

  function numberSettings() public view returns (
    uint baseCurrencyUnit,
    uint quoteCurrencyUnit,
    uint priceDivisor,
    uint quoteDivisor,
    uint baseDivisor
  ){
    baseCurrencyUnit = _baseCurrencyUnit;
    quoteCurrencyUnit = _quoteCurrencyUnit;
    priceDivisor = _priceDivisor;
    quoteDivisor = _quoteDivisor;
    baseDivisor = _baseDivisor;
  }

  function rangeSettings() public view returns (
    uint _maxBaseAsset,
    uint _maxBaseValue,
    uint _minBaseAsset,
    uint _minBaseValue,
    uint _maxQuoteAsset,
    uint _maxQuoteValue,
    uint _minQuoteAsset,
    uint _minQuoteValue,
    uint _minSellPrice,
    uint _maxSellPrice,
    uint _minBuyPrice,
    uint _maxBuyPrice
  ){
    _maxBaseAsset = maxBaseAsset;
    _maxBaseValue = maxBaseValue;
    _minBaseAsset = minBaseAsset;
    _minBaseValue = minBaseValue;
    _maxQuoteAsset = maxQuoteAsset;
    _maxQuoteValue = maxQuoteValue;
    _minQuoteAsset = minQuoteAsset;
    _minQuoteValue = minQuoteValue;
    _minSellPrice = minSellPrice;
    _maxSellPrice = maxSellPrice;
    _minBuyPrice = minBuyPrice;
    _maxBuyPrice = maxBuyPrice;
  }

  function baseCurrencyIsBNB() internal view returns (bool) { return _baseCurrencyAddress == address(0); }
  function quoteCurrencyIsBNB() internal view returns (bool) { return _quoteCurrencyAddress == address(0); }

  struct LimitOrder {
    uint48 asset; // то, что
    uint48 value;
    address trader;
  }

  function internalBaseAmount(uint exactAmount) private view returns (uint48) {
    return uint48(exactAmount/(_baseCurrencyUnit));
  }

  function internalQuoteAmount(uint exactAmount) private view returns (uint48) {
    return uint48(exactAmount/(_quoteCurrencyUnit));
  }

  function exactBaseAmount(uint48 internalAmount) private view returns (uint) {
    return uint(internalAmount)*(_baseCurrencyUnit);
  }

  function exactQuoteAmount(uint48 internalAmount) private view returns (uint) {
    return uint(internalAmount)*(_quoteCurrencyUnit);
  }

  mapping(uint => LimitOrder) sell;
  mapping(uint => LimitOrder) buy;

  uint public lastOrder;

  event LimitSell(uint id, uint timestamp, address trader, uint asset, uint value);

  function limitSell(uint asset, uint value) public payable {
    if(baseCurrencyIsBNB())
      asset = msg.value;
    else
      require(msg.value == 0, "Cannot accept BNB");
    require(asset%(_baseCurrencyUnit) == 0, "Asset  is not a multiple of base unit");
    require(value%(_quoteCurrencyUnit) == 0, "Value is not a multiple of quote unit");
    require(asset >= minBaseAsset, "Asset too low");
    require(asset <= maxBaseAsset, "Asset too high");
    require(value >= minQuoteValue, "Value too low");
    require(value <= maxQuoteValue, "Value too high");

    // pair BASE/QUOTE
    // sell BASE asset, gain QUOTE value
    // price = QUOTE/BASE = value/asset

    /* minSellPrice    value    _baseDivisor      maxSellPrice
      ------------- <= ----- * -------------- <= -------------
      _priceDivisor    asset   _quoteDivisor     _priceDivisor */

    require((minSellPrice)*(asset * _quoteDivisor) <= (value * _baseDivisor)*(_priceDivisor), "Price too low");
    require((maxSellPrice)*(asset * _quoteDivisor) >= (value * _baseDivisor)*(_priceDivisor), "Price too high");

    if(!baseCurrencyIsBNB())
      IERC20(_baseCurrencyAddress).transferFrom(msg.sender, address(this), asset);

    lastOrder++;
    sell[lastOrder] = LimitOrder(internalBaseAmount(asset), internalQuoteAmount(value), msg.sender);
    emit LimitSell(lastOrder, block.timestamp, msg.sender, asset, value);
  }

  event LimitBuy(uint id, uint timestamp, address trader, uint asset, uint value);

  function limitBuy(uint asset, uint value) public payable {
    if(quoteCurrencyIsBNB())
      asset = msg.value;
    else
      require(msg.value == 0, "Cannot accept BNB");
    require(asset % (_quoteCurrencyUnit) == 0, "Asset is not a multiple of quote unit");
    require(value % (_baseCurrencyUnit) == 0, "Value is not a multiple of base unit");
    require(asset >= minQuoteAsset, "Asset too low");
    require(asset <= maxQuoteAsset, "Asset too high");
    require(value >= minBaseValue, "Value too low");
    require(value <= maxBaseValue, "Value too high");

    // pair BASE/QUOTE
    // pay QUOTE asset, gain BASE value
    // price = QUOTE/BASE = asset/value

    /* minBuyPrice     asset    _baseDivisor     maxBuyPrice
       ------------ <= ----- * -------------- <= ------------
      _priceDivisor    value   _quoteDivisor    _priceDivisor */

    require((minBuyPrice)*(value * _quoteDivisor) <= (asset * _baseDivisor)*(_priceDivisor), "Price too low");
    require((maxBuyPrice)*(value * _quoteDivisor) >= (asset * _baseDivisor)*(_priceDivisor), "Price too high");

    if(!quoteCurrencyIsBNB())
      IERC20(_quoteCurrencyAddress).transferFrom(msg.sender, address(this), asset);

    lastOrder++;
    buy[lastOrder] = LimitOrder(internalQuoteAmount(asset), internalBaseAmount(value), msg.sender);
    emit LimitBuy(lastOrder, block.timestamp, msg.sender, asset, value);
  }

  function sendBaseCurrency(address recipient, uint amount) private {
    if(baseCurrencyIsBNB()) {
      payable(recipient).transfer(amount);
    } else {
      IERC20(_baseCurrencyAddress).transfer(recipient, amount);
    }
  }

  function sendQuoteCurrency(address recipient, uint amount) private {
    if(quoteCurrencyIsBNB()) {
      payable(recipient).transfer(amount);
    } else {
      IERC20(_quoteCurrencyAddress).transfer(recipient, amount);
    }
  }

  event Cancel(uint id, uint timestamp);

  function cancelBuyOrder(uint id) public {
    LimitOrder storage order = buy[id];
    require(order.trader != address(0), "Order not found");
    require(order.trader == msg.sender, "Not your order");
    sendQuoteCurrency(order.trader, exactQuoteAmount(order.asset));
    delete buy[id];
    lastOperation++;
    emit Cancel(id, block.timestamp);
  }

  function cancelSellOrder(uint id) public {
    LimitOrder storage order = sell[id];
    require(order.trader != address(0), "Order not found");
    require(order.trader == msg.sender, "Not your order");
    sendBaseCurrency(order.trader, exactBaseAmount(order.asset));
    delete sell[id];
    lastOperation++;
    emit Cancel(id, block.timestamp);
  }

  uint public lastOperation;

  event Close(uint id, uint timestamp);

  event MarketSell(uint timestamp, address seller, uint asset, uint value);

  function marketSellSafe(uint asset, uint[] memory ids, uint lastSeenOperation) public payable {
    require(lastSeenOperation == lastOperation, "Market has been changed");
    marketSell(asset, ids);
  }

  function marketSell(uint asset, uint[] memory ids) public payable {
    if(baseCurrencyIsBNB()) {
      asset = msg.value;
      require(asset >= _baseCurrencyUnit, "Asset too low");
    } else {
      require(msg.value == 0, "Cannot accept BNB");
      require(asset >= _baseCurrencyUnit, "Asset too low");
      IERC20(_baseCurrencyAddress).transferFrom(msg.sender, address(this), asset);
    }
    uint _asset = asset;
    uint gain = 0;
    for (uint256 i = 0; i < ids.length; i++) {
      LimitOrder storage order = buy[ids[i]];
      uint48 order_value = order.value;
      uint48 order_asset = order.asset;
      address buyer = order.trader;
      if(buyer == address(0) || order_value == 0 || order_asset == 0) continue;
      if(internalBaseAmount(_asset) >= order_value) {
        _asset -= exactBaseAmount(order_value);
        sendBaseCurrency(buyer, exactBaseAmount(order_value));
        gain += exactQuoteAmount(order_asset);
        delete buy[ids[i]];
        emit Close(ids[i], block.timestamp);
        if(_asset < _baseCurrencyUnit) break;
      } else {
        // new_order_value = order_value - asset
        // order_value / order_asset == new_order_value / new_order_asset
        // new_order_asset = new_order_value * order_asset / order_value

        uint new_order_value = order_value - internalBaseAmount(_asset);
        uint new_order_asset = new_order_value * order_asset / order_value;

        if(new_order_asset == 0) {
          sendBaseCurrency(buyer, exactBaseAmount(order_value));
          gain += exactQuoteAmount(order_asset);
          delete buy[ids[i]];
          emit Close(ids[i], block.timestamp);
        } else {
          sendBaseCurrency(buyer, exactBaseAmount(internalBaseAmount(_asset)));
          gain += exactQuoteAmount(order_asset - uint48(new_order_asset));
          order.asset = uint48(new_order_asset);
          order.value = uint48(new_order_value);
          emit LimitBuy(ids[i], block.timestamp, buyer, exactQuoteAmount(uint48(new_order_asset)), exactBaseAmount(uint48(new_order_value)));
        }
        _asset = 0;
        break;
      }
    }
    if(gain > 0) sendQuoteCurrency(msg.sender, gain);
    if(_asset > 0) sendBaseCurrency(msg.sender, _asset);
    if(gain > 0) emit MarketSell(block.timestamp, msg.sender, asset - _asset, gain);
    lastOperation++;
  }

  event MarketBuy(uint timestamp, address buyer, uint asset, uint value);

  function marketBuySafe(uint asset, uint[] memory ids, uint lastSeenOperation) public payable {
    require(lastSeenOperation == lastOperation, "Market changed");
    marketBuy(asset, ids);
  }

  function marketBuy(uint asset, uint[] memory ids) public payable {
    if(quoteCurrencyIsBNB()) {
      asset = msg.value;
      require(asset >= _quoteCurrencyUnit, "Asset too low");
    } else {
      require(msg.value == 0, "Cannot accept BNB");
      require(asset >= _quoteCurrencyUnit, "Asset too low");
      IERC20(_quoteCurrencyAddress).transferFrom(msg.sender, address(this), asset);
    }
    uint _asset = asset;
    uint gain = 0;
    for (uint256 i = 0; i < ids.length; i++) {
      LimitOrder storage order = sell[ids[i]];
      uint48 order_value = order.value;
      uint48 order_asset = order.asset;
      address seller = order.trader;
      if(seller == address(0) || order_value == 0 || order_asset == 0) continue;
      if(internalQuoteAmount(_asset) >= order_value) {
        _asset -= exactQuoteAmount(order_value);
        sendQuoteCurrency(seller, exactQuoteAmount(order_value));
        gain += exactBaseAmount(order_asset);
        delete sell[ids[i]];
        emit Close(ids[i], block.timestamp);
        if(_asset < _quoteCurrencyUnit) break;
      } else {
        // new_order_value = order_value - asset
        // order_value / order_asset == new_order_value / new_order_asset
        // new_order_asset = new_order_value * order_asset / order_value

        uint new_order_value = order_value - internalQuoteAmount(_asset);
        uint new_order_asset = new_order_value * order_asset / order_value;

        if(new_order_asset == 0) {
          sendQuoteCurrency(seller, exactQuoteAmount(order_value));
          gain += exactBaseAmount(order_asset);
          delete sell[ids[i]];
          emit Close(ids[i], block.timestamp);
        } else {
          sendQuoteCurrency(seller, exactQuoteAmount(internalQuoteAmount(_asset)));
          gain += exactBaseAmount(order_asset - uint48(new_order_asset));
          order.asset = uint48(new_order_asset);
          order.value = uint48(new_order_value);
          emit LimitSell(ids[i], block.timestamp, seller, exactBaseAmount(uint48(new_order_asset)), exactQuoteAmount(uint48(new_order_value)));
        }
        _asset = 0;
        break;
      }
    }
    if(gain > 0) sendBaseCurrency(msg.sender, gain);
    if(_asset > 0) sendQuoteCurrency(msg.sender, _asset);
    if(gain > 0) emit MarketBuy(block.timestamp, msg.sender, asset - _asset, gain);
    lastOperation++;
  }

  function checksum() public view returns (bytes32) {
    return keccak256(abi.encodePacked((lastOperation << 128) + lastOrder));
  }

  function symbols() public view returns (string memory, string memory) {
    return (
      _getSymbol(_baseCurrencyAddress),
      _getSymbol(_quoteCurrencyAddress)
    );
  }

  function symbol() public view returns (string memory) {
    return string.concat(
      _getSymbol(_baseCurrencyAddress),
      "/",
      _getSymbol(_quoteCurrencyAddress)
    );
  }

  function baseCurrency() public view returns (address) {
    return _baseCurrencyAddress;
  }

  function quoteCurrency() public view returns (address) {
    return _quoteCurrencyAddress;
  }

  function _currencyInfo(address addr) private view returns (string memory name, string memory symbol, uint decimals, address tokenAddress ) {
    if(addr == address(0)) {
      name = "Binance Coin";
      symbol = "BNB";
      decimals = 18;
      tokenAddress = address(0);
    } else {
      IERC20Metadata token = IERC20Metadata(addr);
      name = token.name();
      symbol = token.symbol();
      decimals = token.decimals();
      tokenAddress = addr;
    }    
  }

  function baseCurrencyInfo() public view returns (string memory name, string memory symbol, uint decimals, address tokenAddress ) { return _currencyInfo(_baseCurrencyAddress);}
  function quoteCurrencyInfo() public view returns (string memory name, string memory symbol, uint decimals, address tokenAddress ) { return _currencyInfo(_quoteCurrencyAddress);}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}