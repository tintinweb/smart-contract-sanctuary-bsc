// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Escrow{

    enum STATE { AWAITING_DELIVERY, AWAITING_FUND_RELEASE, COMPLETE }
    struct ProductItem
    {
        string chatRoomNumber;
        string productName;
        string productLink;
        address payable buyer;
        address payable seller;
        uint256 price;
        STATE currentState;
        uint256 createTime;
        uint256 deliverTime;
        bool fundsWithdrawn;
        bool appeal;
    }

    struct ServiceItem
    {
        string chatRoomNumber;
        string serviceName;
        string serviceLink;
        address payable buyer;
        address payable seller;
        uint256 price;
        STATE currentState;
        uint256 createTime;
        uint256 duration;
        uint256 deliverTime;
        bool fundsWithdrawn;
        bool appeal;
    }

    struct CryptoItem
    {
        address payable buyer;
        address payable seller;
        address currency;
        uint8 decimals;
        uint256 amount;
        uint256 price;
        uint256 createTime;
        bool completed;
    }

    address public owner;
    address public priceFeedAddress;
    AggregatorV3Interface internal priceFeed;

    mapping(address => bool) public managers;
    mapping(address => bool) public bannedAddresses;

    mapping(uint256 => ProductItem) public productTrades;
    mapping(uint256 => ServiceItem) public serviceTrades;
    mapping(uint256 => CryptoItem) public cryptoTrades;

    uint256 public currentProductTradeId;
    uint256 public currentServiceTradeId;
    uint256 public currentCryptoTradeId;

    uint256 public totalTax = 5; // $5
    uint256 public constant LOCK_TIME = 300; // 5 min
    address payable public teamWallet1 = payable(0x4b4a0CBB2A7c971D51Ae7dE040a7a290498Df74E);
    address payable public teamWallet2 = payable(0xCb10616fDfd7a5f3e3e144Aad8e7D7821DFAb6A2);
    address payable public teamWallet3 = payable(0x936A0cA35971Fe8A48000829f952e41293ea0DC8);
    address payable public teamWallet4 = payable(0x595F21963feDbc4f5BA4A11b76359dEe916040c0);
    address payable public teamWallet5 = payable(0xd136EB70B571cEf8Db36FAd5be07cB4F76905B64);
    address payable public teamWallet6 = payable(0xd136EB70B571cEf8Db36FAd5be07cB4F76905B64);

    event NewTradeCreated(uint256 tradeId, uint256 category);
    event ProductDelivered(uint256 tradeId, string productLink, uint256 category);
    event FundReleased(uint256 tradeId, uint256 category);
    event AppealRequested(uint256 tradeId, uint256 category);
    event AppealResolved(uint256 tradeId, bool buyerWin, uint256 category);
    event CryptoSold(uint256 cryptoTradeId);
    event AdminsUpdated(address adminAddress, bool deleted);

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    modifier onlyManager {
      require(msg.sender == owner || managers[msg.sender]);
      _;
   }

    constructor ()
    {
        // BNB mainnet: 0x45f86CA2A8BC9EBD757225B19a1A0D7051bE46Db
        // BNB testnet: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        priceFeedAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        owner = msg.sender;
    }

    function setTax(uint256 _totalTax) external onlyOwner {
        totalTax = _totalTax;
    }

    function getLatestPrice() public view returns (uint256) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function addManagers(address manager) external onlyOwner {
        managers[manager] = true;
        emit AdminsUpdated(manager, false);
    }

    function removeManagers(address manager) external onlyOwner {
        managers[manager] = false;
        emit AdminsUpdated(manager, true);
    }

    function manageBannedAddress(address illegalAddress, bool isAdd) external onlyOwner {
        if (isAdd)
            bannedAddresses[illegalAddress] = true;
        else
            bannedAddresses[illegalAddress] = false;
    }

    /** 
     * @dev We always start a new trade from this function which will be called by Buyer
     * @param _duration - in days - must be converted into seconds
     */
    function createNewTrade (string memory _chatRoomNumber, string memory _productName, uint256 _price, address _seller, uint256 _duration, uint256 category) external payable {
        require(msg.value >= _price, "Not enough deposit");
        require(category == 0 || category == 1, "invalid category value");
        require(!bannedAddresses[msg.sender] && !bannedAddresses[_seller], "Banned address");

        if (category == 0) {
            ProductItem memory product;
            product.chatRoomNumber = _chatRoomNumber;
            product.productName = _productName;
            product.price = _price;
            product.buyer = payable(msg.sender);
            product.seller = payable(_seller);
            product.createTime = block.timestamp;
            product.currentState = STATE.AWAITING_DELIVERY;

            currentProductTradeId ++;
            productTrades[currentProductTradeId] = product;

            emit NewTradeCreated(currentProductTradeId, category);
        } else {
            ServiceItem memory service;
            service.chatRoomNumber = _chatRoomNumber;
            service.serviceName = _productName;
            service.price = _price;
            service.buyer = payable(msg.sender);
            service.seller = payable(_seller);
            service.createTime = block.timestamp;
            service.duration = _duration * 24 * 60 * 60;
            service.currentState = STATE.AWAITING_DELIVERY;

            currentServiceTradeId ++;
            serviceTrades[currentServiceTradeId] = service;

            emit NewTradeCreated(currentServiceTradeId, category);
        }        
    }

    /** 
     * @dev As soon as a new trade is created by Buyer, the seller should deliver the product
     */
    function deliverProduct(uint256 tradeId, string memory _productLink, uint256 category) external {
        require(category == 0 || category == 1, "invalid category value");
        
        if (category == 0) {
            ProductItem storage product = productTrades[tradeId];
            require(product.seller == msg.sender, "You are not the seller of this trade");
            require(product.currentState == STATE.AWAITING_DELIVERY, "Invalid state");
            
            product.productLink = _productLink;
            product.currentState = STATE.AWAITING_FUND_RELEASE;
            product.deliverTime = block.timestamp;
        } else {
            ServiceItem storage service = serviceTrades[tradeId];
            require(service.seller == msg.sender, "You are not the seller of this trade");
            require(service.currentState == STATE.AWAITING_DELIVERY, "Invalid state");
            require(service.createTime + service.duration >= block.timestamp, "Deadline expired");
            
            service.serviceLink = _productLink;
            service.currentState = STATE.AWAITING_FUND_RELEASE;
            service.deliverTime = block.timestamp;
        }
        emit ProductDelivered(tradeId, _productLink, category);
    }

    /** 
     * @dev The buyer finally check the product and release the fund
     */
    function releaseFunds(uint256 tradeId, uint256 category) external {
        require(category == 0 || category == 1, "invalid category value");
        if (category == 0) {
            ProductItem storage product = productTrades[tradeId];
            require(product.buyer == msg.sender, "You are not the buyer of this trade");
            require(product.currentState == STATE.AWAITING_FUND_RELEASE, "Invalid state");

            uint256 payAmount = payTax(product.price, true);
            (product.seller).transfer(payAmount);

            product.currentState = STATE.COMPLETE;
            product.fundsWithdrawn = true;
        } else {
            ServiceItem storage service = serviceTrades[tradeId];
            require(service.buyer == msg.sender, "You are not the buyer of this trade");
            require(service.currentState == STATE.AWAITING_FUND_RELEASE, "Invalid state");

            uint256 payAmount = payTax(service.price, true);
            (service.seller).transfer(payAmount);

            service.currentState = STATE.COMPLETE;
            service.fundsWithdrawn = true;
        }

        emit FundReleased(tradeId, category);
    }

    function payTax(uint256 price, bool success) internal returns(uint256 payAmount) {
        uint256 currentPrice = getLatestPrice();

        (teamWallet1).transfer(currentPrice * totalTax * 125 / 1000); // 12.5%
        (teamWallet2).transfer(currentPrice * totalTax * 125 / 1000); // 12.5%
        (teamWallet3).transfer(currentPrice * totalTax * 125 / 1000); // 12.5%
        (teamWallet4).transfer(currentPrice * totalTax * 20 / 100);   // 20%
        (teamWallet5).transfer(currentPrice * totalTax * 375 / 1000); // 37.5%
        (teamWallet6).transfer(currentPrice * totalTax * 5 / 100);    // 5%

        uint256 tax7;
        if (success)
            tax7 = price / 100;
        else
            tax7 = price / 200;
        payAmount = price - currentPrice * totalTax - tax7;
    }

    /** 
     * @dev The buyer review the link and decide to appeal
     */
    function appeal(uint256 tradeId, uint256 category) external {
        require(category == 0 || category == 1, "invalid category value");
        if (category == 0) {
            ProductItem storage product = productTrades[tradeId];
            require(product.buyer == msg.sender, "You are not the buyer of this trade");
            require(product.currentState == STATE.AWAITING_FUND_RELEASE, "Invalid state");

            product.appeal = true;
        } else {
            ServiceItem storage service = serviceTrades[tradeId];
            require(service.buyer == msg.sender, "You are not the buyer of this trade");
            require(service.currentState == STATE.AWAITING_FUND_RELEASE, "Invalid state");

            service.appeal = true;
        }
        
        emit AppealRequested(tradeId, category);
    }

    /** 
     * @dev The buyer appealed and the admin review it
     * @param tradeId Id of the trade in which the buyer and seller agreed for the trade
     * @param buyerWin denotes whether buyer won: true for the buyer and false for the seller
     * @param category denotes 0: product, 1: service
     */
    function resolveAppeal(uint256 tradeId, bool buyerWin, uint256 category) external onlyManager {
        require(category == 0 || category == 1, "invalid category value");
        
        if (category == 0) {
            ProductItem storage product = productTrades[tradeId];
            require(product.appeal, "This trade is not set appeal");
            require(product.currentState == STATE.AWAITING_FUND_RELEASE, "Invalid state");
            
            // implement tax policy
            uint256 payAmount = payTax(product.price, false);
            if (buyerWin)
                (product.buyer).transfer(payAmount);
            else
                (product.seller).transfer(payAmount);

            product.currentState = STATE.COMPLETE;
            product.appeal = false;
        }
        else {
            ServiceItem storage service = serviceTrades[tradeId];
            require(service.appeal, "This trade is not set appeal");
            require(service.currentState == STATE.AWAITING_FUND_RELEASE, "Invalid state");

            // implement tax policy
            uint256 payAmount = payTax(service.price, false);
            if (buyerWin)
                (service.buyer).transfer(payAmount);
            else
                (service.seller).transfer(payAmount);

            service.currentState = STATE.COMPLETE;
            service.appeal = false;
        }
        emit AppealResolved(tradeId, buyerWin, category);
    }

    /** 
     * @dev The seller tries to withdraw funds
     * @param tradeId Id of the trade in which the buyer and seller agreed for the trade
     */
    function getFundsBack(uint256 tradeId) external {
        ServiceItem storage service = serviceTrades[tradeId];
        require(service.createTime + service.duration < block.timestamp, "You should wait until the deadline is met");
        require(service.buyer == msg.sender, "You are not the buyer of this trade");
        require(!service.fundsWithdrawn, "Funds already withdrawn");
        require(service.currentState == STATE.AWAITING_DELIVERY, "Invalid state");
        
        uint256 payAmount = payTax(service.price, false);
        (service.buyer).transfer(payAmount);

        service.fundsWithdrawn = true;
        service.currentState = STATE.COMPLETE;

        emit FundReleased(tradeId, 1);
    }

    /** 
     * @dev The seller tries to withdraw funds
     * @param tradeId Id of the trade in which the buyer and seller agreed for the trade
     */
    function withdrawFunds(uint256 tradeId, uint256 category) external {
        require(category == 0 || category == 1, "invalid category value");
        
        if (category == 0) {
            ProductItem storage product = productTrades[tradeId];
            require(!product.appeal, "This trade is set appeal");
            require(product.seller == msg.sender, "You are not the seller of this trade");
            require(product.currentState == STATE.AWAITING_FUND_RELEASE, "Invalid state");
            require(!product.fundsWithdrawn, "Funds already withdrawn");
            require(block.timestamp - product.deliverTime >= LOCK_TIME, "Lock time is not passed yet");

            (product.seller).transfer(product.price);

            product.fundsWithdrawn = true;
            product.currentState = STATE.COMPLETE;
        } else {
            ServiceItem storage service = serviceTrades[tradeId];
            require(!service.appeal, "This trade is set appeal");
            require(service.seller == msg.sender, "You are not the seller of this trade");
            require(service.currentState == STATE.AWAITING_FUND_RELEASE, "Invalid state");
            require(!service.fundsWithdrawn, "Funds already withdrawn");
            require(block.timestamp - service.deliverTime >= LOCK_TIME, "Lock time is not passed yet");

            (service.seller).transfer(service.price);

            service.fundsWithdrawn = true;
            service.currentState = STATE.COMPLETE;
        }
        

        emit FundReleased(tradeId, category);
    }

    /** 
     * @dev We always start a new crypto trade from this function which will be called by seller
     * @param _currencyAddress crypto currency address
     * @param _amount amount of crypto currency
     * @param _price price of crypto currency in BNB
     */
    function createNewCryptoTrade (address _currencyAddress, uint256 _amount, uint256 _price) external {
        require(!bannedAddresses[msg.sender], "Banned address");

        IERC20Metadata token = IERC20Metadata(_currencyAddress);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), _amount);

        CryptoItem memory cryptoProduct;
        cryptoProduct.seller = payable(msg.sender);
        cryptoProduct.currency = _currencyAddress;
        cryptoProduct.amount = _amount;
        cryptoProduct.price = _price;
        cryptoProduct.createTime = block.timestamp;
        cryptoProduct.decimals = token.decimals();

        currentCryptoTradeId ++;
        cryptoTrades[currentCryptoTradeId] = cryptoProduct;
    }

    /** 
     * @dev Seller already sets the crypto item, now it's time to buy this crypto
     * @param cryptoTradeId crypto trade id
     */
    function buyCrypto (uint256 cryptoTradeId) external payable{
        CryptoItem storage cryptoProduct = cryptoTrades[cryptoTradeId];
        require(msg.value >= cryptoProduct.price, "Not enough paid");
        require(!cryptoProduct.completed, "Already completed");

        // tax policy
        (cryptoProduct.seller).transfer(cryptoProduct.price);

        IERC20Metadata token = IERC20Metadata(cryptoProduct.currency);
        token.transfer(msg.sender, cryptoProduct.amount);

        cryptoProduct.buyer = payable(msg.sender);
        cryptoProduct.completed = true;

        emit CryptoSold(cryptoTradeId);
    }
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