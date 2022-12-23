// SPDX-License-Identifier: GPL-3.0
/**
 * Copyright 2017-2021, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.8.15;

import "../../externalContract/openzeppelin/non-upgradeable/IERC20Metadata.sol";
import "../../externalContract/modify/non-upgradeable/AggregatorV2V3Interface.sol";
import "../../externalContract/modify/non-upgradeable/ManagerTimelock.sol";

contract PriceFeeds_BSC is ManagerTimelock {
    event GlobalPricingPaused(address indexed sender, bool isPaused);
    event SetPriceFeed(address indexed sender, address[] tokens, address[] feeds);
    event SetDecimals(address indexed sender, address[] tokens);
    event SetStalePeriod(address indexed sender, uint256 oldValue, uint256 newValue);

    mapping(address => address) public pricesFeeds; // token => pricefeed
    mapping(address => uint256) public decimals; // decimals of supported tokens

    bool public globalPricingPaused = false;

    uint256 WEI_PRECISION = 10**18;
    uint256 stalePeriod;
    address wethTokenAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //mainnet

    constructor() {
        noTimelockManager = msg.sender;
        configTimelockManager = msg.sender;
        decimals[wethTokenAddress] = 18;
        stalePeriod = 2 hours;

        emit TransferNoTimelockManager(address(0), noTimelockManager);
        emit TransferConfigTimelockManager(address(0), configTimelockManager);
        emit SetStalePeriod(msg.sender, 0, stalePeriod);
    }

    function queryRate(address sourceToken, address destToken)
        public
        view
        returns (uint256 rate, uint256 precision)
    {
        require(!globalPricingPaused, "PriceFeed/pricing-is-paused");
        return _queryRate(sourceToken, destToken);
    }

    function queryPrecision(address sourceToken, address destToken) public view returns (uint256) {
        return
            sourceToken != destToken ? _getDecimalPrecision(sourceToken, destToken) : WEI_PRECISION;
    }

    //// NOTE: This function returns 0 during a pause, rather than a revert. Ensure calling contracts handle correctly. ///
    function queryReturn(
        address sourceToken,
        address destToken,
        uint256 sourceAmount
    ) public view returns (uint256 destAmount) {
        require(!globalPricingPaused, "PriceFeed/pricing-is-paused");

        (uint256 rate, uint256 precision) = _queryRate(sourceToken, destToken);

        destAmount = (sourceAmount * rate) / precision;
    }

    function amountInEth(address tokenAddress, uint256 amount)
        public
        view
        returns (uint256 ethAmount)
    {
        if (tokenAddress == wethTokenAddress) {
            ethAmount = amount;
        } else {
            (uint256 toEthRate, uint256 toEthPrecision) = queryRate(tokenAddress, wethTokenAddress);
            ethAmount = (amount * toEthRate) / toEthPrecision;
        }
    }

    /*
     * Owner functions
     */

    function setPriceFeed(address[] calldata tokens, address[] calldata feeds)
        external
        onlyConfigTimelockManager
    {
        require(tokens.length == feeds.length, "PriceFeed/count-mismatch");
        for (uint256 i = 0; i < tokens.length; i++) {
            pricesFeeds[tokens[i]] = feeds[i];
        }

        emit SetPriceFeed(msg.sender, tokens, feeds);
    }

    function setStalePeriod(uint256 newValue) external onlyConfigTimelockManager {
        uint256 oldValue = stalePeriod;
        stalePeriod = newValue;

        emit SetStalePeriod(msg.sender, oldValue, stalePeriod);
    }

    function setDecimals(IERC20Metadata[] calldata tokens) external onlyConfigTimelockManager {
        address[] memory tokenAddresses = new address[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            decimals[address(tokens[i])] = tokens[i].decimals();
            tokenAddresses[i] = address(tokens[i]);
        }

        emit SetDecimals(msg.sender, tokenAddresses);
    }

    function setGlobalPricingPaused(bool isPaused) external onlyNoTimelockManager {
        globalPricingPaused = isPaused;

        emit GlobalPricingPaused(msg.sender, isPaused);
    }

    /*
     * Internal functions
     */

    function _queryRate(address sourceToken, address destToken)
        internal
        view
        returns (uint256 rate, uint256 precision)
    {
        if (sourceToken != destToken) {
            uint256 sourceRate = _queryRateUSD(sourceToken);
            uint256 destRate = _queryRateUSD(destToken);

            rate = (sourceRate * WEI_PRECISION) / destRate;

            precision = _getDecimalPrecision(sourceToken, destToken);
        } else {
            rate = WEI_PRECISION;
            precision = WEI_PRECISION;
        }
    }

    function _queryRateUSD(address token) internal view returns (uint256 rate) {
        require(pricesFeeds[token] != address(0), "PriceFeed/unsupported-address");
        AggregatorV2V3Interface _Feed = AggregatorV2V3Interface(pricesFeeds[token]);
        (, int256 answer, , uint256 updatedAt, ) = _Feed.latestRoundData();
        rate = uint256(answer);
        require(block.timestamp - updatedAt < stalePeriod, "PriceFeed/price-is-stale");
    }

    function queryRateUSD(address token) external view returns (uint256 rate) {
        require(!globalPricingPaused, "PriceFeed/pricing-is-paused");
        rate = _queryRateUSD(token);
    }

    function _getDecimalPrecision(address sourceToken, address destToken)
        internal
        view
        returns (uint256)
    {
        if (sourceToken == destToken) {
            return WEI_PRECISION;
        } else {
            uint256 sourceTokenDecimals = decimals[sourceToken];
            if (sourceTokenDecimals == 0)
                sourceTokenDecimals = IERC20Metadata(sourceToken).decimals();

            uint256 destTokenDecimals = decimals[destToken];
            if (destTokenDecimals == 0) destTokenDecimals = IERC20Metadata(destToken).decimals();

            if (destTokenDecimals >= sourceTokenDecimals) {
                return 10**(18 - (destTokenDecimals - sourceTokenDecimals));
            } else {
                return 10**(18 + (sourceTokenDecimals - destTokenDecimals));
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

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

/**
 * @title The V2 & V3 Aggregator Interface
 * @notice Solidity V0.5 does not allow interfaces to inherit from other
 * interfaces so this contract is a combination of v0.5 AggregatorInterface.sol
 * and v0.5 AggregatorV3Interface.sol.
 */
interface AggregatorV2V3Interface {
    //
    // V2 Interface:
    //
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

    function latestRound() external view returns (uint256);

    function getAnswer(uint256 roundId) external view returns (int256);

    function getTimestamp(uint256 roundId) external view returns (uint256);

    event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
    event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);

    //
    // V3 Interface:
    //
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract ManagerTimelock {
    address internal noTimelockManager;
    address internal configTimelockManager;
    address internal addressTimelockManager;

    event TransferNoTimelockManager(address, address);
    event TransferConfigTimelockManager(address, address);
    event TransferAddressTimelockManager(address, address);

    constructor() {}

    modifier onlyNoTimelockManager() {
        _onlyNoTimelockManager();
        _;
    }
    modifier onlyConfigTimelockManager() {
        _onlyConfigTimelockManager();
        _;
    }
    modifier onlyAddressTimelockManager() {
        _onlyAddressTimelockManager();
        _;
    }

    function getNoTimelockManager() external view returns (address) {
        return noTimelockManager;
    }

    function getConfigTimelockManager() external view returns (address) {
        return configTimelockManager;
    }

    function getAddressTimelockManager() external view returns (address) {
        return addressTimelockManager;
    }

    function _onlyNoTimelockManager() internal view {
        require(noTimelockManager == msg.sender, "Manager/caller-is-not-the-manager");
    }

    function _onlyConfigTimelockManager() internal view {
        require(configTimelockManager == msg.sender, "Manager/caller-is-not-the-manager");
    }

    function _onlyAddressTimelockManager() internal view {
        require(addressTimelockManager == msg.sender, "Manager/caller-is-not-the-manager");
    }

    function transferNoTimelockManager(address _address) public virtual onlyNoTimelockManager {
        require(_address != address(0), "Manager/new-manager-is-the-zero-address");
        _transferNoTimelockManager(_address);
    }

    function transferConfigTimelockManager(address _address)
        public
        virtual
        onlyConfigTimelockManager
    {
        require(_address != address(0), "Manager/new-manager-is-the-zero-address");
        _transferConfigTimelockManager(_address);
    }

    function transferAddressTimelockManager(address _address)
        public
        virtual
        onlyAddressTimelockManager
    {
        require(_address != address(0), "Manager/new-manager-is-the-zero-address");
        _transferAddressTimelockManager(_address);
    }

    function _transferNoTimelockManager(address _address) internal virtual {
        address oldManager = noTimelockManager;
        noTimelockManager = _address;
        emit TransferNoTimelockManager(oldManager, _address);
    }

    function _transferConfigTimelockManager(address _address) internal virtual {
        address oldManager = configTimelockManager;
        configTimelockManager = _address;
        emit TransferConfigTimelockManager(oldManager, _address);
    }

    function _transferAddressTimelockManager(address _address) internal virtual {
        address oldManager = addressTimelockManager;
        addressTimelockManager = _address;
        emit TransferAddressTimelockManager(oldManager, _address);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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