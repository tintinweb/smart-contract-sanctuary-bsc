/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../intf/IDealer.sol";
import "../intf/IPerpetual.sol";
import "../utils/SignedDecimalMath.sol";

contract Perpetual is Ownable, IPerpetual {
    using SignedDecimalMath for int256;

    // ========== storage ==========

    /*
        We use int128 to store paper and reduced credit, 
        so that we could store balance in a single slot.
        This can help us save gas.

        int128 can support size of 1.7E38, which is enough 
        for most transactions. But other than storing paper 
        and reduced credit values, we use int256 to achieve 
        higher accuracy of calculation.
        
        Please keep in mind that even int256 is allowed in 
        some places, you should not pass in a value exceed 
        int128 when storing paper and reduced credit values.
    */
    struct balance {
        int128 paper;
        int128 reducedCredit;
    }
    mapping(address => balance) public balanceMap;
    int256 fundingRate;

    // ========== events ==========

    event BalanceChange(
        address indexed trader,
        int256 paperChange,
        int256 creditChange
    );

    event UpdateFundingRate(int256 oldFundingRate, int256 newFundingRate);

    // ========== constructor ==========

    constructor(address _owner) Ownable() {
        transferOwnership(_owner);
    }

    // ========== balance related ==========

    /*
        We store "reducedCredit" instead of credit itself.
        So that after funding rate is updated, the credit values will be
        updated without any extra storage write.
        
        credit = (paper * fundingRate) + reducedCredit

        FundingRate here is a little different from what it means at CEX.
        FundingRate is a cumulative value. Its absolute value doesn't mean 
        anything and only the changes (due to funding updates) matter.

        e.g. If the fundingRate increases by 5 at a certain update, 
        then you will receive 5 credit for every paper you long.
        Conversely, you will be charged 5 credit for every paper you short.
    */

    /// @inheritdoc IPerpetual
    function balanceOf(address trader)
        external
        view
        returns (int256 paper, int256 credit)
    {
        paper = int256(balanceMap[trader].paper);
        credit =
            paper.decimalMul(IDealer(owner()).getFundingRate(address(this))) +
            int256(balanceMap[trader].reducedCredit);
    }

    function updateFundingRate(int256 newFundingRate) external onlyOwner {
        int256 oldFundingRate = fundingRate;
        fundingRate = newFundingRate;
        emit UpdateFundingRate(oldFundingRate, newFundingRate);
    }

    function getFundingRate() external view returns (int256) {
        return fundingRate;
    }

    // ========== trade ==========

    /// @inheritdoc IPerpetual
    function trade(bytes calldata tradeData) external {
        (
            address[] memory traderList,
            int256[] memory paperChangeList,
            int256[] memory creditChangeList
        ) = IDealer(owner()).approveTrade(msg.sender, tradeData);

        for (uint256 i = 0; i < traderList.length; ) {
            address trader = traderList[i];
            _settle(trader, paperChangeList[i], creditChangeList[i]);
            unchecked {
                ++i;
            }
        }

        require(IDealer(owner()).isAllSafe(traderList), "TRADER_NOT_SAFE");
    }

    // ========== liquidation ==========

    /// @inheritdoc IPerpetual
    function liquidate(
        address liquidatedTrader,
        int256 requestPaper,
        int256 expectCredit
    ) external returns (int256 liqtorPaperChange, int256 liqtorCreditChange) {
        // liqed => liquidated trader, who faces the risk of liquidation.
        // liqtor => liquidator, who takes over the trader's position.
        int256 liqedPaperChange;
        int256 liqedCreditChange;
        (
            liqtorPaperChange,
            liqtorCreditChange,
            liqedPaperChange,
            liqedCreditChange
        ) = IDealer(owner()).requestLiquidation(
            msg.sender,
            liquidatedTrader,
            requestPaper
        );

        // expected price = expectCredit/requestPaper * -1
        // execute price = liqtorCreditChange/liqtorPaperChange * -1
        if (liqtorPaperChange < 0) {
            // open short, execute price >= expected price
            // liqtorCreditChange/liqtorPaperChange * -1 >= expectCredit/requestPaper * -1
            // liqtorCreditChange/liqtorPaperChange <= expectCredit/requestPaper
            require(
                liqtorCreditChange * requestPaper <=
                    expectCredit * liqtorPaperChange,
                "LIQUIDATION_PRICE_PROTECTION"
            );
        } else {
            // open long, execute price <= expected price
            // liqtorCreditChange/liqtorPaperChange * -1 <= expectCredit/requestPaper * -1
            // liqtorCreditChange/liqtorPaperChange >= expectCredit/requestPaper
            require(
                liqtorCreditChange * requestPaper >=
                    expectCredit * liqtorPaperChange,
                "LIQUIDATION_PRICE_PROTECTION"
            );
        }

        _settle(liquidatedTrader, liqedPaperChange, liqedCreditChange);
        _settle(msg.sender, liqtorPaperChange, liqtorCreditChange);
        require(IDealer(owner()).isSafe(msg.sender), "LIQUIDATOR_NOT_SAFE");
        if (balanceMap[liquidatedTrader].paper == 0) {
            IDealer(owner()).handleBadDebt(liquidatedTrader);
        }
    }

    // ========== settlement ==========

    /*
        Remember the fomula?
        credit = (paper * fundingRate) + reducedCredit

        So we have...
        reducedCredit = credit - (paper * fundingRate)

        When you update the balance, you need to first calculate the credit, 
        and then calculate and store the reducedCredit.
    */

    function _settle(
        address trader,
        int256 paperChange,
        int256 creditChange
    ) internal {
        if (balanceMap[trader].paper == 0) {
            IDealer(owner()).openPosition(trader);
        }
        int256 rate = fundingRate; // gas saving
        int256 credit = int256(balanceMap[trader].paper).decimalMul(
            rate
        ) +
            int256(balanceMap[trader].reducedCredit) +
            creditChange;
        int128 newPaper = balanceMap[trader].paper + int128(paperChange);
        int128 newReducedCredkt = int128(
            credit - int256(newPaper).decimalMul(rate)
        );
        balanceMap[trader].paper = newPaper;
        balanceMap[trader].reducedCredit = newReducedCredkt;
        emit BalanceChange(trader, paperChange, creditChange);
        if (balanceMap[trader].paper == 0) {
            // realize PNL
            IDealer(owner()).realizePnl(
                trader,
                balanceMap[trader].reducedCredit
            );
            balanceMap[trader].reducedCredit = 0;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

interface IDealer {
    /// @notice Deposit fund to get credit for trading
    /// @param primaryAmount is the amount of primary asset you want to withdraw.
    /// @param secondaryAmount is the amount of secondary asset you want to withdraw.
    /// @param to Please be careful. If you pass in others' addresses,
    /// the credit will be added to that address directly.
    function deposit(
        uint256 primaryAmount,
        uint256 secondaryAmount,
        address to
    ) external;

    /// @notice Submit withdrawal request, which can be executed after
    /// the timelock. The main purpose of this function is to avoid the
    /// failure of counterparty caused by withdrawal.
    /// @param primaryAmount is the amount of primary asset you want to withdraw.
    /// @param secondaryAmount is the amount of secondary asset you want to withdraw.
    function requestWithdraw(uint256 primaryAmount, uint256 secondaryAmount)
        external;

    /// @notice execute the withdrawal request.
    /// @param to Be careful if you pass in others' addresses,
    /// because the fund will be transferred to this address directly.
    /// @param isInternal Only credit transfers will be made,
    /// and ERC20 transfers will not happen.
    function executeWithdraw(address to, bool isInternal) external;

    /// @notice help perpetual contract parse tradeData and return
    /// the balance changes should be made to each trader.
    /// @dev only perpetual contract can call this function
    /// @param orderSender is the one who submit tradeData.
    /// @param tradeData data contain orders, signatures and match info.
    function approveTrade(address orderSender, bytes calldata tradeData)
        external
        returns (
            address[] memory traderList,
            int256[] memory paperChangeList,
            int256[] memory creditChangeList
        );

    /// @notice check if the trader's account is safe. The trader's positions
    /// under all markets will be liquidated if the return value is true
    function isSafe(address trader) external view returns (bool);

    /// @notice check if a list of traders are safe.
    function isAllSafe(address[] memory traderList) external view returns (bool);

    /// @notice get funding rate of a perpetual market.
    /// Funding rate is a 1e18 based decimal.
    function getFundingRate(address perp) external view returns (int256);

    /// @notice when someone calls liquidate function at perpetual.sol, it
    /// will call this function to know how to change balances.
    /// @dev only perpetual contract can call this function.
    /// liqtor is short for liquidator, liqed is short for liquidated trader.
    /// @param liquidator is the one who will take over positions.
    /// @param liquidatedTrader is the one who is being liquidated.
    /// @param requestPaperAmount is the size that the liquidator wants to take.
    function requestLiquidation(
        address liquidator,
        address liquidatedTrader,
        int256 requestPaperAmount
    )
        external
        returns (
            int256 liqtorPaperChange,
            int256 liqtorCreditChange,
            int256 liqedPaperChange,
            int256 liqedCreditChange
        );

    /// @notice Transfer all bad debt to insurance account,
    /// including primary and secondary balance.
    function handleBadDebt(address liquidatedTrader) external;

    /// @notice Register position into dealer for trader
    /// @dev only perpetual contract can call this function when
    /// someone's position is opened.
    function openPosition(address trader) external;

    /// @notice Accrual realized pnl
    /// @dev only perpetual contract can call this function when
    /// someone's position is closed.
    function realizePnl(address trader, int256 pnl) external;

    /// @notice Registry operator
    /// The operator can sign order on your behalf.
    function setOperator(address operator, bool isValid) external;
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

interface IPerpetual {
    /// @notice This is the paper amount and credit amount of a certain trader
    /// @return paper value is positive when the trader holds a long position and
    /// negative when the trader holds a short position.
    /// @return credit not related to position direction or entry price,
    /// only used to calculate risk ratio and net value.
    function balanceOf(address trader)
        external
        view
        returns (int256 paper, int256 credit);

    /// @notice tradeData will be transfered to the Dealer contract
    /// and the Perpetual contract will directly execute and update the balance.
    function trade(bytes calldata tradeData) external;

    /// @notice Submit the paper amount you want to liquidate.
    /// Because the liquidation is public, there is no guarantee that your request
    /// will be executed. It will not be executed or partially executed if:
    /// 1) someone else submitted a liquidation request before you, or
    /// 2) the trader deposited enough margin in time, or
    /// 3) the mark price moved.
    /// This function will help you liquidate up to the position size.
    /// @param  liquidatedTrader is the trader you want to liquidate.
    /// @param  requestPaper is the size of position you want to take .
    /// requestPaper is positive when you want to liquidate a long position, negative when short.
    /// @param expectCredit is the amount of credit you want to pay (when liquidating a short position)
    /// or receive (when liquidating a long position)
    /// @return liqtorPaperChange is the final executed change of liquidator's paper amount
    /// @return liqtorCreditChange is the final executed change of liquidator's credit amount
    function liquidate(
        address liquidatedTrader,
        int256 requestPaper,
        int256 expectCredit
    ) external returns (int256 liqtorPaperChange, int256 liqtorCreditChange);

    /// @notice Get funding rate of this perpetual market. 
    /// Funding rate is a 1e18 based decimal.
    function getFundingRate() external view returns (int256);

    /// @notice Update funding rate, only owner can call.
    function updateFundingRate(int256 newFundingRate) external;
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

/// @notice Decimal math for int256. Round down.
library SignedDecimalMath {
    int256 constant ONE = 10**18;

    function decimalMul(int256 a, int256 b) internal pure returns (int256) {
        return (a * b) / ONE;
    }

    function decimalDiv(int256 a, int256 b) internal pure returns (int256) {
        return (a * ONE) / b;
    }

    function abs(int256 a) internal pure returns (uint256) {
        return a < 0 ? uint256(a * -1) : uint256(a);
    }
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