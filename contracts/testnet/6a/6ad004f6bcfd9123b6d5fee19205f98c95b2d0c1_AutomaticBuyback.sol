// SPDX-License-Identifier: MIT

// TESTNET VERSION

pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./IPancakeSwap.sol";
import "./IAutomaticBuyback.sol";

contract AutomaticBuyback is IAutomaticBuyback {
    using SafeMath for uint256;

    address private _token;                     // Caller Smart Contract
    bool private initialized;

    IBEP20 private cumulatedToken;              // Cumulated token (stablecoin BUSD)
    IBEP20 private buybackToken;                // The token to buyback using all the cumulatedToken balance
    uint256 private buybackPeriod;              // Buyback period in days. CAN ONLY BE 30 days, 60 days or 90 days
    uint256 private buybackPeriodNew;           // Used to update the buyback period
    uint256 private buyback_timestamp;          // The next buyback timestamp
    uint256 private totalBuyedBackAlltime;      // Total bought back alltime
    IPancakeRouter02 private pancakeRouter;     // The DEX router

    uint256 private constant TIME_UNIT = 1 minutes;
    uint256 private constant INSTANT_UPDATE_FORBIDDEN_TH = 7 * TIME_UNIT;          // Days before the buyback
    uint256 private constant CUMULATED_TOKEN_CHANGE_PERIOD_TH = 5 * TIME_UNIT;     // Days after the buyback

    modifier onlyToken() {
        require(msg.sender == _token, "Unauthorized"); _;
    }

    constructor () {}

    function initialize(address _pancakeRouterAddress, address _cumulatedTokenAddress, address _buybackTokenAddress) external override {
        require(!initialized, "AutomaticBuyback: already initialized!");
        initialized = true;
        _token = msg.sender;
        cumulatedToken = IBEP20(_cumulatedTokenAddress);
        buybackToken = IBEP20(_buybackTokenAddress);
        pancakeRouter = IPancakeRouter02(_pancakeRouterAddress);
        _changeBuybackPeriod(30);   // Set default period of 30 min
        emit Initialized(_token, address(cumulatedToken), address(buybackToken), address(pancakeRouter));
    }

    // Trigger to call at every transaction. If the buyback timestamp is reached the buyback will be executed, returning true
    // Otherwise nothing will be executed, returning false
    function trigger() external override onlyToken returns (bool buyback_executed) {
        if (block.timestamp >= buyback_timestamp) {
            // Execute the buyback
            _buybackAll();
            // Set next buyback
            if (buybackPeriodNew != buybackPeriod) {
                buybackPeriod = buybackPeriodNew;
            }
            buyback_timestamp = buyback_timestamp + buybackPeriod * TIME_UNIT;
            emit NewBuybackTimestampSet(buybackPeriod, buyback_timestamp);
            buyback_executed = true;
        } else {
            buyback_executed = false;
        }
    }

    // External function to change the buyback period between 30, 60 or 90 minutes
    function changeBuybackPeriod(uint256 newPeriod) external override onlyToken {
        require(newPeriod != buybackPeriod, "AutomaticBuyback: the newPeriod must be different from the current period");
        require(newPeriod == 30 || newPeriod == 60 || newPeriod == 90, "AutomaticBuyback: the period must be 30, 60 or 90 (minutes)");
        _changeBuybackPeriod(newPeriod);
    }

    // Change the buyback period. It will be done immediately only if the new period is greater than the old period and the change
    // is done at least 7 minutes before the current buyback timestamp. Otherwise the change is done after the buyback
    function _changeBuybackPeriod(uint256 newPeriod) internal {
        if (buyback_timestamp == 0) {
            buyback_timestamp = block.timestamp + newPeriod * TIME_UNIT;
            emit ChangedBuybackPeriod(buybackPeriod, newPeriod, true);
            buybackPeriod = newPeriod;
            buybackPeriodNew = newPeriod;
            emit NewBuybackTimestampSet(buybackPeriod, buyback_timestamp);
            return;
        }
        if (newPeriod > buybackPeriod) {
            if (block.timestamp < buyback_timestamp - INSTANT_UPDATE_FORBIDDEN_TH) {
                // If before 7 minutes (INSTANT_UPDATE_FORBIDDEN_TH) from the buyback time, we can shift it, otherwise it will be changed after the buyback
                buyback_timestamp = (buyback_timestamp - buybackPeriod * TIME_UNIT) + newPeriod * TIME_UNIT;
                emit ChangedBuybackPeriod(buybackPeriod, newPeriod, true);
                buybackPeriod = newPeriod;
                buybackPeriodNew = newPeriod;
                emit NewBuybackTimestampSet(buybackPeriod, buyback_timestamp);
            } else {
                buybackPeriodNew = newPeriod;
                emit ChangedBuybackPeriod(buybackPeriod, newPeriod, false);
            }
        } else {
            // Set to update after the next buyback
            buybackPeriodNew = newPeriod;
            emit ChangedBuybackPeriod(buybackPeriod, newPeriod, false);
        }
    }


    // Buy the buybackToken using all the cumulated cumulatedToken in the contract
    // The buybackToken will be sent to the AutomatedBuyback contract (this) and can be burnt from the caller token
    // using the internal _burn() function or kept locked forever inside the AutomatedBuyback contract
    function _buybackAll() internal {
        uint256 tokenAmount = cumulatedToken.balanceOf(address(this));
        uint256 previousBuybackBalance = buybackToken.balanceOf(address(this));
        if (tokenAmount > 0) {
            address[] memory path = new address[](3);
            path[0] = address(cumulatedToken);
            path[1] = pancakeRouter.WETH();
            path[2] = address(buybackToken);
            cumulatedToken.approve(address(pancakeRouter), tokenAmount);
            // make the swap
            pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
        uint256 currentBuybackBalance = buybackToken.balanceOf(address(this));
        totalBuyedBackAlltime = totalBuyedBackAlltime.add(currentBuybackBalance).sub(previousBuybackBalance);
        emit BuybackExecuted(tokenAmount, currentBuybackBalance.sub(previousBuybackBalance), currentBuybackBalance, totalBuyedBackAlltime);
    }


    // Update the router address 
    function updateRouterAddress(address newAddress) external override onlyToken {
        emit UpdatePancakeRouter(newAddress, address(pancakeRouter));
        pancakeRouter = IPancakeRouter02(newAddress);
    }


    // Change the cumulated token used for the automatic buyback. It must be called just before changing the cumulatedToken in the caller
    // After changing the token, the AutomaticBuyback contract is expecting to cumulate and use the new token
    function changeCumulatedToken(address newCumulatedTokenAddress) external override onlyToken {
        require(newCumulatedTokenAddress != address(buybackToken), "AutomaticBuyback: cumulatedToken cannot be buybackToken");
        // Only possible within the first 5 minutes (CUMULATED_TOKEN_CHANGE_PERIOD_TH) from the last buyback event
        require(block.timestamp <= (buyback_timestamp - buybackPeriod * TIME_UNIT) + CUMULATED_TOKEN_CHANGE_PERIOD_TH, "AutomaticBuyback: cannot change the cumulatedToken used NOW");
        emit ChangedAutomaticBuybackCumulatedToken(address(cumulatedToken), newCumulatedTokenAddress);
        // Do a forced internal buyback, without changing the next timestamp
        _buybackAll();
        // Now the cumulatedToken balance is zero, we can switch to the new cumulatedToken
        cumulatedToken = IBEP20(newCumulatedTokenAddress);
    }

    // Return the current status of the AutomaticBuyback and the countdown to the next automatic buyback event
    function getAutomaticBuybackStatus() public view override returns (
            address automatic_buyback_contract_address,
            uint256 next_buyback_timestamp,
            uint256 next_buyback_countdown,
            uint256 current_buyback_period,
            uint256 new_buyback_period,
            address current_cumulated_token,
            uint256 current_cumulated_balance,
            uint256 current_buyback_token_balance,
            uint256 total_buyed_back ) {
        automatic_buyback_contract_address = address(this);
        next_buyback_timestamp = buyback_timestamp;
        next_buyback_countdown = block.timestamp < buyback_timestamp ? buyback_timestamp - block.timestamp : 0;
        current_buyback_period = buybackPeriod;
        new_buyback_period = buybackPeriodNew;
        current_cumulated_token = address(cumulatedToken);
        current_cumulated_balance = cumulatedToken.balanceOf(address(this));
        current_buyback_token_balance = buybackToken.balanceOf(address(this));
        total_buyed_back = totalBuyedBackAlltime;
    }

}