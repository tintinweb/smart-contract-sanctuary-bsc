/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity = 0.8.16;

import "../AppStorage.sol";
import "../../libraries/LibCheck.sol";
import "../../libraries/LibInternal.sol";
import "../../libraries/LibMarket.sol";
import "../../libraries/LibClaim.sol";
import "../ReentrancyGuard.sol";

/**
 * @author Publius
 * @title Claim handles claiming TopCorn and LP withdrawals, harvesting plots and claiming BNB.
 **/
contract ClaimFacet is ReentrancyGuard {
    event TopcornClaim(address indexed account, uint32[] withdrawals, uint256 topcorns);
    event LPClaim(address indexed account, uint32[] withdrawals, uint256 lp);
    event BnbClaim(address indexed account, uint256 bnb);
    event Harvest(address indexed account, uint256[] plots, uint256 topcorns);
    event TopcornAllocation(address indexed account, uint256 topcorns);

    function claim(LibClaim.Claim calldata c) external payable nonReentrant returns (uint256 topcornsClaimed) {
        topcornsClaimed = LibClaim.claim(c);
        LibMarket.claimRefund(c);
        LibCheck.balanceCheck();
    }

    function claimAndUnwrapTopcorns(LibClaim.Claim calldata c, uint256 amount) external payable nonReentrant returns (uint256 topcornsClaimed) {
        topcornsClaimed = LibClaim.claim(c);
        topcornsClaimed = topcornsClaimed + (_unwrapTopcorns(amount));
        LibMarket.claimRefund(c);
        LibCheck.balanceCheck();
    }

    function claimTopcorns(uint32[] calldata withdrawals) external {
        uint256 topcornsClaimed = LibClaim.claimTopcorns(withdrawals);
        ITopcorn(s.c.topcorn).transfer(msg.sender, topcornsClaimed);
        LibCheck.topcornBalanceCheck();
    }

    function claimLP(uint32[] calldata withdrawals) external {
        LibClaim.claimLP(withdrawals);
        LibCheck.lpBalanceCheck();
    }

    function removeAndClaimLP(
        uint32[] calldata withdrawals,
        uint256 minTopcornAmount,
        uint256 minBNBAmount
    ) external nonReentrant {
        LibClaim.removeAndClaimLP(withdrawals, minTopcornAmount, minBNBAmount);
        LibCheck.balanceCheck();
    }

    function harvest(uint256[] calldata plots) external {
        uint256 topcornsHarvested = LibClaim.harvest(plots);
        ITopcorn(s.c.topcorn).transfer(msg.sender, topcornsHarvested);
        LibCheck.topcornBalanceCheck();
    }

    function claimBnb() external {
        LibClaim.claimBnb();
    }

    function unwrapTopcorns(uint256 amount) external returns (uint256 topcornsToWallet) {
        return _unwrapTopcorns(amount);
    }

    function _unwrapTopcorns(uint256 amount) private returns (uint256 topcornsToWallet) {
        if (amount == 0) return topcornsToWallet;
        uint256 wTopcorns = s.a[msg.sender].wrappedTopcorns;

        if (amount > wTopcorns) {
            ITopcorn(s.c.topcorn).transfer(msg.sender, wTopcorns);
            topcornsToWallet = s.a[msg.sender].wrappedTopcorns;
            s.a[msg.sender].wrappedTopcorns = 0;
        } else {
            ITopcorn(s.c.topcorn).transfer(msg.sender, amount);
            s.a[msg.sender].wrappedTopcorns = wTopcorns - (amount);
            topcornsToWallet = amount;
        }
    }

    function wrapTopcorns(uint256 amount) external {
        ITopcorn(s.c.topcorn).transferFrom(msg.sender, address(this), amount);
        s.a[msg.sender].wrappedTopcorns = s.a[msg.sender].wrappedTopcorns + (amount);
    }

    function wrappedTopcorns(address user) external view returns (uint256) {
        return s.a[user].wrappedTopcorns;
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.16;

import "../interfaces/IDiamondCut.sol";

/**
 * @author Publius
 * @title App Storage defines the state object for Farmer.
 **/
contract Account {
    // Field stores a Farmer's Plots and Pod allowances.
    struct Field {
        mapping(uint256 => uint256) plots; // A Farmer's Plots. Maps from Plot index to Pod amount.
        mapping(address => uint256) podAllowances; // An allowance mapping for Pods similar to that of the ERC-20 standard. Maps from spender address to allowance amount.
    }

    // Asset Silo is a struct that stores Deposits and Seeds per Deposit, and stored Withdrawals.
    struct AssetSilo {
        mapping(uint32 => uint256) withdrawals;
        mapping(uint32 => uint256) deposits;
        mapping(uint32 => uint256) depositSeeds;
    }

    // Deposit represents a Deposit in the Silo of a given Token at a given Season.
    // Stored as two uint128 state variables to save gas.
    struct Deposit {
        uint128 amount;
        uint128 tdv;
    }

    // Silo stores Silo-related balances
    struct Silo {
        uint256 stalk; // Balance of the Farmer's normal Stalk.
        uint256 seeds; // Balance of the Farmer's normal Seeds.
    }

    // Season Of Plenty stores Season of Plenty (SOP) related balances
    struct SeasonOfPlenty {
        uint256 base;
        uint256 roots; // The number of Roots a Farmer had when it started Raining.
        uint256 basePerRoot;
    }

    // The Account level State stores all of the Farmer's balances in the contract.
    struct State {
        Field field; // A Farmer's Field storage.
        AssetSilo topcorn;
        AssetSilo lp;
        Silo s; // A Farmer's Silo storage. 
        uint32 lastUpdate; // The Season in which the Farmer last updated their Silo.
        uint32 lastSop; // The last Season that a SOP occured at the time the Farmer last updated their Silo.
        uint32 lastRain; // The last Season that it started Raining at the time the Farmer last updated their Silo.
        SeasonOfPlenty sop; // A Farmer's Season Of Plenty storage.
        uint256 roots; // A Farmer's Root balance.
        uint256 wrappedTopcorns;
        mapping(address => mapping(uint32 => Deposit)) deposits;  // A Farmer's Silo Deposits stored as a map from Token address to Season of Deposit to Deposit.
        mapping(address => mapping(uint32 => uint256)) withdrawals;  // A Farmer's Withdrawals from the Silo stored as a map from Token address to Season the Withdrawal becomes Claimable to Withdrawn amount of Tokens.
    }
}

contract Storage {
    // Contracts stored the contract addresses of various important contracts to Farm.
    struct Contracts {
        address topcorn;
        address pair;
        address pegPair;
        address wbnb;
    }

    // Field stores global Field balances.
    struct Field {
        uint256 soil; // The number of Soil currently available.
        uint256 pods; // The pod index; the total number of Pods ever minted.
        uint256 harvested; // The harvested index; the total number of Pods that have ever been Harvested.
        uint256 harvestable; // The harvestable index; the total number of Pods that have ever been Harvestable. Included previously Harvested Topcorns.
    }

    // Silo
    struct AssetSilo {
        uint256 deposited; // The total number of a given Token currently Deposited in the Silo.
        uint256 withdrawn; // The total number of a given Token currently Withdrawn From the Silo but not Claimed.
    }

    struct SeasonOfPlenty {
        uint256 wbnb;
        uint256 base;
        uint32 last;
    }

    struct Silo {
        uint256 stalk;
        uint256 seeds;
        uint256 roots;
        uint256 topcorns;
    }

    // Oracle stores global level Oracle balances.
    // Currently the oracle refers to the time weighted average price calculated from the Topcorn:BNB - usd:BNB.
    struct Oracle {
        bool initialized;  // True if the Oracle has been initialzed. It needs to be initialized on Deployment and re-initialized each Unpause.
        uint256 cumulative;
        uint256 pegCumulative;
        uint32 timestamp;  // The timestamp of the start of the current Season.
        uint32 pegTimestamp;
    }

    // Rain stores global level Rain balances. (Rain is when P > 1, Pod rate Excessively Low).
    struct Rain {
        uint32 start;
        bool raining;
        uint256 pods; // The number of Pods when it last started Raining.
        uint256 roots; // The number of Roots when it last started Raining.
    }

    // Sesaon stores global level Season balances.
    struct Season {
        // The first storage slot in Season is filled with a variety of somewhat unrelated storage variables.
        // Given that they are all smaller numbers, they are stored together for gas efficient read/write operations. 
        // Apologies if this makes it confusing :(
        uint32 current; // The current Season in Farm.
        uint8 withdrawSeasons; // The number of seasons required to Withdraw a Deposit.
        uint256 start; // The timestamp of the Farm deployment rounded down to the nearest hour.
        uint256 period; // The length of each season in Farm.
        uint256 timestamp; // The timestamp of the start of the current Season.
        uint256 rewardMultiplier; // Multiplier for incentivize 
        uint256 maxTimeMultiplier; // Multiplier for incentivize 
        uint256 costSunrice; // For Incentivize, gas limit per function call sunrise()
    }

    // Weather stores global level Weather balances.
    struct Weather {
        uint256 startSoil; // The number of Soil at the start of the current Season.
        uint256 lastDSoil; // Delta Soil; the number of Soil purchased last Season.
        uint32 lastSowTime; // The number of seconds it took for all but at most 1 Soil to sell out last Season.
        uint32 nextSowTime; // The number of seconds it took for all but at most 1 Soil to sell out this Season
        uint32 yield; // Weather; the interest rate for sowing Topcorns in Soil.
    }

    // SiloSettings stores the settings for each Token that has been Whitelisted into the Silo.
    // A Token is considered whitelisted in the Silo if there exists a non-zero SiloSettings selector.
    struct SiloSettings {
        bytes4 selector; // The encoded TDV function selector for the Token.
        uint32 seeds; // The Seeds Per TDV that the Silo mints in exchange for Depositing this Token.
        uint32 stalk; // The Stalk Per TDV that the Silo mints in exchange for Depositing this Token.
    }
}

struct AppStorage {
    uint8 index; // The index of the Topcorn token in the Topcorn:BNB Pancakeswap v2 pool
    int8[32] cases; // The 24 Weather cases (array has 32 items, but caseId = 3 (mod 4) are not cases).
    bool paused; // True if Farm is Paused.
    uint128 pausedAt; // The timestamp at which Farm was last paused. 
    Storage.Season season; // The Season storage struct found above.
    Storage.Contracts c;
    Storage.Field f; // The Field storage struct found above.
    Storage.Oracle o; // The Oracle storage struct found above.
    Storage.Rain r; // The Rain storage struct found above.
    Storage.Silo s; // The Silo storage struct found above.
    uint256 reentrantStatus; // An intra-transaction state variable to protect against reentrance
    Storage.Weather w; // The Weather storage struct found above.
    Storage.AssetSilo topcorn;
    Storage.AssetSilo lp;
    Storage.SeasonOfPlenty sop;
    mapping(uint32 => uint256) sops; // A mapping from Season to Plenty Per Root (PPR) in that Season. Plenty Per Root is 0 if a Season of Plenty did not occur.
    mapping(address => Account.State) a; // A mapping from Farmer address to Account state.
    mapping(uint256 => bytes32) podListings; // A mapping from Plot Index to the hash of the Pod Listing.
    mapping(bytes32 => uint256) podOrders; // A mapping from the hash of a Pod Order to the amount of Pods that the Pod Order is still willing to buy.
    mapping(address => Storage.AssetSilo) siloBalances; // A mapping from Token address to Silo Balance storage (amount deposited and withdrawn).
    mapping(address => Storage.SiloSettings) ss;  // A mapping from Token address to Silo Settings for each Whitelisted Token. If a non-zero storage exists, a Token is whitelisted.
    // These refund variables are intra-transaction state varables use to store refund amounts
    uint256 refundStatus;
    uint256 topcornRefundAmount;
    uint256 bnbRefundAmount;
    uint8 pegIndex; // The index of the BUSD token in the BUSD:BNB PancakeSwap v2 pool
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.16;

import "../interfaces/pancake/IPancakePair.sol";
import "./LibAppStorage.sol";
import "../interfaces/ITopcorn.sol";

/**
 * @author Publius
 * @title Check Library verifies Farmer's balances are correct.
 **/
library LibCheck {
    function topcornBalanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(ITopcorn(s.c.topcorn).balanceOf(address(this)) >= s.f.harvestable - s.f.harvested + s.topcorn.deposited + s.topcorn.withdrawn, "Check: TopCorn balance fail.");
    }

    function lpBalanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(IPancakePair(s.c.pair).balanceOf(address(this)) >= s.lp.deposited + s.lp.withdrawn, "Check: LP balance fail.");
    }

    function balanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(ITopcorn(s.c.topcorn).balanceOf(address(this)) >= s.f.harvestable - s.f.harvested + s.topcorn.deposited + s.topcorn.withdrawn, "Check: TopCorn balance fail.");
        require(IPancakePair(s.c.pair).balanceOf(address(this)) >= s.lp.deposited + s.lp.withdrawn, "Check: LP balance fail.");
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.16;

/**
 * @author Publius
 * @title Internal Library handles gas efficient function calls between facets.
 **/

interface ISiloUpdate {
    function updateSilo(address account) external payable;
}

library LibInternal {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function updateSilo(address account) internal {
        DiamondStorage storage ds = diamondStorage();
        address facet = ds.selectorToFacetAndPosition[ISiloUpdate.updateSilo.selector].facetAddress;
        bytes memory myFunctionCall = abi.encodeWithSelector(ISiloUpdate.updateSilo.selector, account);
        (bool success, ) = address(facet).delegatecall(myFunctionCall);
        require(success, "Silo: updateSilo failed.");
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.16;

import "../interfaces/pancake/IPancakeRouter02.sol";
import "../interfaces/ITopcorn.sol";
import "../interfaces/IWBNB.sol";
import "./LibAppStorage.sol";
import "./LibClaim.sol";

/**
 * @author Publius
 * @title Market Library handles swapping, addinga and removing LP on Pancake for Farmer.
 **/
library LibMarket {
    event TopcornAllocation(address indexed account, uint256 topcorns);

    struct DiamondStorage {
        address topcorn;
        address wbnb;
        address router;
    }

    struct AddLiquidity {
        uint256 topcornAmount;
        uint256 minTopcornAmount;
        uint256 minBNBAmount;
    }

    bytes32 private constant MARKET_STORAGE_POSITION = keccak256("diamond.standard.market.storage");

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = MARKET_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function initMarket(
        address topcorn,
        address wbnb,
        address router
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.topcorn = topcorn;
        ds.wbnb = wbnb;
        ds.router = router;
    }

    /**
     * Swap
     **/

    function buy(uint256 buyTopcornAmount) internal returns (uint256 amount) {
        (, amount) = _buy(buyTopcornAmount, msg.value, msg.sender);
    }

    function buyAndDeposit(uint256 buyTopcornAmount) internal returns (uint256 amount) {
        (, amount) = _buy(buyTopcornAmount, msg.value, address(this));
    }

    function buyExactTokensToWallet(
        uint256 buyTopcornAmount,
        address to,
        bool toWallet
    ) internal returns (uint256 amount) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (toWallet) amount = buyExactTokens(buyTopcornAmount, to);
        else {
            amount = buyExactTokens(buyTopcornAmount, address(this));
            s.a[to].wrappedTopcorns = s.a[to].wrappedTopcorns + amount;
        }
    }

    function buyExactTokens(uint256 buyTopcornAmount, address to) internal returns (uint256 amount) {
        (uint256 BNBAmount, uint256 topcornAmount) = _buyExactTokens(buyTopcornAmount, msg.value, to);
        allocateBNBRefund(msg.value, BNBAmount, false);
        return topcornAmount;
    }

    function buyAndSow(uint256 buyTopcornAmount, uint256 buyBNBAmount) internal returns (uint256 amount) {
        if (buyTopcornAmount == 0) {
            allocateBNBRefund(msg.value, 0, false);
            return 0;
        }
        (uint256 bnbAmount, uint256 topcornAmount) = _buyExactTokensWBNB(buyTopcornAmount, buyBNBAmount, address(this));
        allocateBNBRefund(msg.value, bnbAmount, false);
        amount = topcornAmount;
    }

    function sellToWBNB(uint256 sellTopcornAmount, uint256 minBuyBNBAmount) internal returns (uint256 amount) {
        (, uint256 outAmount) = _sell(sellTopcornAmount, minBuyBNBAmount, address(this));
        return outAmount;
    }

    /**
     *  Liquidity
     **/

    function removeLiquidity(
        uint256 liqudity,
        uint256 minTopcornAmount,
        uint256 minBNBAmount
    ) internal returns (uint256 topcornAmount, uint256 bnbAmount) {
        DiamondStorage storage ds = diamondStorage();
        return IPancakeRouter02(ds.router).removeLiquidityETH(ds.topcorn, liqudity, minTopcornAmount, minBNBAmount, msg.sender, block.timestamp);
    }

    function removeLiquidityWithTopcornAllocation(
        uint256 liqudity,
        uint256 minTopcornAmount,
        uint256 minBNBAmount
    ) internal returns (uint256 topcornAmount, uint256 bnbAmount) {
        DiamondStorage storage ds = diamondStorage();
        (topcornAmount, bnbAmount) = IPancakeRouter02(ds.router).removeLiquidity(ds.topcorn, ds.wbnb, liqudity, minTopcornAmount, minBNBAmount, address(this), block.timestamp);
        allocateBNBRefund(bnbAmount, 0, true);
    }

    function addAndDepositLiquidity(AddLiquidity calldata al) internal returns (uint256) {
        allocateTopcorns(al.topcornAmount);
        (, uint256 liquidity) = addLiquidity(al);
        return liquidity;
    }

    function addLiquidity(AddLiquidity calldata al) internal returns (uint256, uint256) {
        (uint256 topcornsDeposited, uint256 bnbDeposited, uint256 liquidity) = _addLiquidity(msg.value, al.topcornAmount, al.minBNBAmount, al.minTopcornAmount);
        allocateBNBRefund(msg.value, bnbDeposited, false);
        allocateTopcornRefund(al.topcornAmount, topcornsDeposited);
        return (topcornsDeposited, liquidity);
    }

    function swapAndAddLiquidity(
        uint256 buyTopcornAmount,
        uint256 buyBNBAmount,
        LibMarket.AddLiquidity calldata al
    ) internal returns (uint256) {
        uint256 boughtLP;
        if (buyTopcornAmount > 0) boughtLP = LibMarket.buyTopcornsAndAddLiquidity(buyTopcornAmount, al);
        else if (buyBNBAmount > 0) boughtLP = LibMarket.buyBNBAndAddLiquidity(buyBNBAmount, al);
        else boughtLP = LibMarket.addAndDepositLiquidity(al);
        return boughtLP;
    }

    // al.buyTopcornAmount is the amount of topcorns the user wants to add to LP
    // buyTopcornAmount is the amount of topcorns the person bought to contribute to LP. Note that
    // buyTopcorn amount will AT BEST be equal to al.buyTopcornAmount because of slippage.
    // Otherwise, it will almost always be less than al.buyTopcorn amount
    function buyTopcornsAndAddLiquidity(uint256 buyTopcornAmount, AddLiquidity calldata al) internal returns (uint256 liquidity) {
        DiamondStorage storage ds = diamondStorage();
        IWBNB(ds.wbnb).deposit{value: msg.value}();

        address[] memory path = new address[](2);
        path[0] = ds.wbnb;
        path[1] = ds.topcorn;
        uint256[] memory amounts = IPancakeRouter02(ds.router).getAmountsIn(buyTopcornAmount, path);
        (uint256 bnbSold, uint256 topcorns) = _buyWithWBNB(buyTopcornAmount, amounts[0], address(this));

        // If topcorns bought does not cover the amount of money to move to LP
        if (al.topcornAmount > buyTopcornAmount) {
            uint256 newTopcornAmount = al.topcornAmount - buyTopcornAmount;
            allocateTopcorns(newTopcornAmount);
            topcorns = topcorns + newTopcornAmount;
        }
        uint256 bnbAdded;
        (topcorns, bnbAdded, liquidity) = _addLiquidityWBNB(msg.value - bnbSold, topcorns, al.minBNBAmount, al.minTopcornAmount);

        allocateTopcornRefund(al.topcornAmount, topcorns);
        allocateBNBRefund(msg.value, bnbAdded + bnbSold, true);
        return liquidity;
    }

    // This function is called when user sends more value of TopCorn than BNB to LP.
    // Value of TopCorn is converted to equivalent value of BNB.
    function buyBNBAndAddLiquidity(uint256 buyWbnbAmount, AddLiquidity calldata al) internal returns (uint256) {
        DiamondStorage storage ds = diamondStorage();
        uint256 sellTopcorns = _amountIn(buyWbnbAmount);
        allocateTopcorns(al.topcornAmount + sellTopcorns);
        (uint256 topcornsSold, uint256 wbnbBought) = _sell(sellTopcorns, buyWbnbAmount, address(this));
        if (msg.value > 0) IWBNB(ds.wbnb).deposit{value: msg.value}();
        (uint256 topcorns, uint256 bnbAdded, uint256 liquidity) = _addLiquidityWBNB(msg.value + wbnbBought, al.topcornAmount, al.minBNBAmount, al.minTopcornAmount);

        allocateTopcornRefund(al.topcornAmount + sellTopcorns, topcorns + topcornsSold);
        allocateBNBRefund(msg.value + wbnbBought, bnbAdded, true);
        return liquidity;
    }

    /**
     *  Shed
     **/

    function _sell(
        uint256 sellTopcornAmount,
        uint256 minBuyBNBAmount,
        address to
    ) internal returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.topcorn;
        path[1] = ds.wbnb;
        uint256[] memory amounts = IPancakeRouter02(ds.router).swapExactTokensForTokens(sellTopcornAmount, minBuyBNBAmount, path, to, block.timestamp);
        return (amounts[0], amounts[1]);
    }

    function _buy(
        uint256 topcornAmount,
        uint256 bnbAmount,
        address to
    ) private returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.wbnb;
        path[1] = ds.topcorn;

        uint256[] memory amounts = IPancakeRouter02(ds.router).swapExactETHForTokens{value: bnbAmount}(topcornAmount, path, to, block.timestamp);
        return (amounts[0], amounts[1]);
    }

    function _buyExactTokens(
        uint256 topcornAmount,
        uint256 bnbAmount,
        address to
    ) private returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.wbnb;
        path[1] = ds.topcorn;

        uint256[] memory amounts = IPancakeRouter02(ds.router).swapETHForExactTokens{value: bnbAmount}(topcornAmount, path, to, block.timestamp);
        return (amounts[0], amounts[1]);
    }

    function _buyExactTokensWBNB(
        uint256 topcornAmount,
        uint256 bnbAmount,
        address to
    ) private returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.wbnb;
        path[1] = ds.topcorn;
        IWBNB(ds.wbnb).deposit{value: bnbAmount}();
        uint256[] memory amounts = IPancakeRouter02(ds.router).swapTokensForExactTokens(topcornAmount, bnbAmount, path, to, block.timestamp);
        IWBNB(ds.wbnb).withdraw(bnbAmount - amounts[0]);
        return (amounts[0], amounts[1]);
    }

    function _buyWithWBNB(
        uint256 topcornAmount,
        uint256 bnbAmount,
        address to
    ) internal returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.wbnb;
        path[1] = ds.topcorn;

        uint256[] memory amounts = IPancakeRouter02(ds.router).swapExactTokensForTokens(bnbAmount, topcornAmount, path, to, block.timestamp);
        return (amounts[0], amounts[1]);
    }

    function _addLiquidity(
        uint256 bnbAmount,
        uint256 topcornAmount,
        uint256 minBNBAmount,
        uint256 minTopcornAmount
    )
        private
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        DiamondStorage storage ds = diamondStorage();
        return IPancakeRouter02(ds.router).addLiquidityETH{value: bnbAmount}(ds.topcorn, topcornAmount, minTopcornAmount, minBNBAmount, address(this), block.timestamp);
    }

    function _addLiquidityWBNB(
        uint256 wbnbAmount,
        uint256 topcornAmount,
        uint256 minWBNBAmount,
        uint256 minTopcornAmount
    )
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        DiamondStorage storage ds = diamondStorage();
        return IPancakeRouter02(ds.router).addLiquidity(ds.topcorn, ds.wbnb, topcornAmount, wbnbAmount, minTopcornAmount, minWBNBAmount, address(this), block.timestamp);
    }

    function _amountIn(uint256 buyWBNBAmount) internal view returns (uint256) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.topcorn;
        path[1] = ds.wbnb;
        uint256[] memory amounts = IPancakeRouter02(ds.router).getAmountsIn(buyWBNBAmount, path);
        return amounts[0];
    }

    function allocateTopcornsToWallet(
        uint256 amount,
        address to,
        bool toWallet
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (toWallet) LibMarket.allocateTopcornsTo(amount, to);
        else {
            LibMarket.allocateTopcornsTo(amount, address(this));
            s.a[to].wrappedTopcorns = s.a[to].wrappedTopcorns + amount;
        }
    }

    function transferTopcorns(
        address to,
        uint256 amount,
        bool toWallet
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (toWallet) ITopcorn(s.c.topcorn).transferFrom(msg.sender, to, amount);
        else {
            ITopcorn(s.c.topcorn).transferFrom(msg.sender, address(this), amount);
            s.a[to].wrappedTopcorns = s.a[to].wrappedTopcorns + amount;
        }
    }

    function allocateTopcorns(uint256 amount) internal {
        allocateTopcornsTo(amount, address(this));
    }

    function allocateTopcornsTo(uint256 amount, address to) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        uint256 wrappedTopcorns = s.a[msg.sender].wrappedTopcorns;
        uint256 remainingTopcorns = amount;
        if (wrappedTopcorns > 0) {
            if (remainingTopcorns > wrappedTopcorns) {
                s.a[msg.sender].wrappedTopcorns = 0;
                remainingTopcorns = remainingTopcorns - wrappedTopcorns;
            } else {
                s.a[msg.sender].wrappedTopcorns = wrappedTopcorns - remainingTopcorns;
                remainingTopcorns = 0;
            }
            uint256 fromWrappedTopcorns = amount - remainingTopcorns;
            emit TopcornAllocation(msg.sender, fromWrappedTopcorns);
            if (to != address(this)) ITopcorn(s.c.topcorn).transfer(to, fromWrappedTopcorns);
        }
        if (remainingTopcorns > 0) ITopcorn(s.c.topcorn).transferFrom(msg.sender, to, remainingTopcorns);
    }

    // Allocate TopCorn Refund stores the TopCorn refund amount in the state to be refunded at the end of the transaction.
    function allocateTopcornRefund(uint256 inputAmount, uint256 amount) internal {
        if (inputAmount > amount) {
            AppStorage storage s = LibAppStorage.diamondStorage();
            if (s.refundStatus % 2 == 1) {
                s.refundStatus += 1;
                s.topcornRefundAmount = inputAmount - amount;
            } else s.topcornRefundAmount = s.topcornRefundAmount + (inputAmount - amount);
        }
    }

    // Allocate BNB Refund stores the BNB refund amount in the state to be refunded at the end of the transaction.
    function allocateBNBRefund(
        uint256 inputAmount,
        uint256 amount,
        bool wbnb
    ) internal {
        if (inputAmount > amount) {
            AppStorage storage s = LibAppStorage.diamondStorage();
            if (wbnb) IWBNB(s.c.wbnb).withdraw(inputAmount - amount);
            if (s.refundStatus < 3) {
                s.refundStatus += 2;
                s.bnbRefundAmount = inputAmount - amount;
            } else s.bnbRefundAmount = s.bnbRefundAmount + (inputAmount - amount);
        }
    }

    function claimRefund(LibClaim.Claim calldata c) internal {
        // The only case that a Claim triggers an BNB refund is
        // if the farmer claims LP, removes the LP and wraps the underlying Topcorns
        if (c.convertLP && !c.toWallet && c.lpWithdrawals.length > 0) refund();
    }

    function refund() internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // If Refund state = 1 -> No refund
        // If Refund state is even -> Refund Topcorns
        // if Refund state > 2 -> Refund BNB

        uint256 rs = s.refundStatus;
        if (rs > 1) {
            if (rs > 2) {
                (bool success, ) = msg.sender.call{value: s.bnbRefundAmount}("");
                require(success, "Market: Refund failed.");
                rs -= 2;
                s.bnbRefundAmount = 1;
            }
            if (rs == 2) {
                ITopcorn(s.c.topcorn).transfer(msg.sender, s.topcornRefundAmount);
                s.topcornRefundAmount = 1;
            }
            s.refundStatus = 1;
        }
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity = 0.8.16;

import "./LibCheck.sol";
import "./LibInternal.sol";
import "./LibMarket.sol";
import "./LibAppStorage.sol";
import "../interfaces/IWBNB.sol";

/**
 * @author Publius
 * @title Claim Library handles claiming TopCorn and LP withdrawals, harvesting plots and claiming BNB.
 **/
library LibClaim {
    event TopcornClaim(address indexed account, uint32[] withdrawals, uint256 topcorns);
    event LPClaim(address indexed account, uint32[] withdrawals, uint256 lp);
    event BnbClaim(address indexed account, uint256 bnb);
    event FullHarvest(address indexed account, uint256[] plots, uint256 topcorns);
    event PodListingCancelled(address indexed account, uint256 indexed index);

    struct Claim {
        uint32[] topcornWithdrawals;
        uint32[] lpWithdrawals;
        uint256[] plots;
        bool claimBnb;
        bool convertLP;
        uint256 minTopcornAmount;
        uint256 minBNBAmount;
        bool toWallet;
    }

    function claim(Claim calldata c) public returns (uint256 topcornsClaimed) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (c.topcornWithdrawals.length > 0) topcornsClaimed = topcornsClaimed + claimTopcorns(c.topcornWithdrawals);
        if (c.plots.length > 0) topcornsClaimed = topcornsClaimed + harvest(c.plots);
        if (c.lpWithdrawals.length > 0) {
            if (c.convertLP) {
                if (!c.toWallet) topcornsClaimed = topcornsClaimed + removeClaimLPAndWrapTopcorns(c.lpWithdrawals, c.minTopcornAmount, c.minBNBAmount);
                else removeAndClaimLP(c.lpWithdrawals, c.minTopcornAmount, c.minBNBAmount);
            } else claimLP(c.lpWithdrawals);
        }
        if (c.claimBnb) claimBnb();

        if (topcornsClaimed > 0) {
            if (c.toWallet) ITopcorn(s.c.topcorn).transfer(msg.sender, topcornsClaimed);
            else s.a[msg.sender].wrappedTopcorns = s.a[msg.sender].wrappedTopcorns + topcornsClaimed;
        }
    }

    // Claim Topcorns

    function claimTopcorns(uint32[] calldata withdrawals) public returns (uint256 topcornsClaimed) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint256 i; i < withdrawals.length; i++) {
            require(withdrawals[i] <= s.season.current, "Claim: Withdrawal not recievable.");
            topcornsClaimed = topcornsClaimed + claimTopcornWithdrawal(msg.sender, withdrawals[i]);
        }
        emit TopcornClaim(msg.sender, withdrawals, topcornsClaimed);
    }

    function claimTopcornWithdrawal(address account, uint32 _s) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 amount = s.a[account].topcorn.withdrawals[_s];
        require(amount > 0, "Claim: TopCorn withdrawal is empty.");
        delete s.a[account].topcorn.withdrawals[_s];
        s.topcorn.withdrawn = s.topcorn.withdrawn - amount;
        return amount;
    }

    // Claim LP

    function claimLP(uint32[] calldata withdrawals) public {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 lpClaimed = _claimLP(withdrawals);
        IPancakePair(s.c.pair).transfer(msg.sender, lpClaimed);
    }

    function removeAndClaimLP(
        uint32[] calldata withdrawals,
        uint256 minTopcornAmount,
        uint256 minBNBAmount
    ) public returns (uint256 topcorns) {
        uint256 lpClaimd = _claimLP(withdrawals);
        (topcorns, ) = LibMarket.removeLiquidity(lpClaimd, minTopcornAmount, minBNBAmount);
    }

    function removeClaimLPAndWrapTopcorns(
        uint32[] calldata withdrawals,
        uint256 minTopcornAmount,
        uint256 minBNBAmount
    ) private returns (uint256 topcorns) {
        uint256 lpClaimd = _claimLP(withdrawals);
        (topcorns, ) = LibMarket.removeLiquidityWithTopcornAllocation(lpClaimd, minTopcornAmount, minBNBAmount);
    }

    function _claimLP(uint32[] calldata withdrawals) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 lpClaimd = 0;
        for (uint256 i; i < withdrawals.length; i++) {
            require(withdrawals[i] <= s.season.current, "Claim: Withdrawal not recievable.");
            lpClaimd = lpClaimd + claimLPWithdrawal(msg.sender, withdrawals[i]);
        }
        emit LPClaim(msg.sender, withdrawals, lpClaimd);
        return lpClaimd;
    }

    function claimLPWithdrawal(address account, uint32 _s) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 amount = s.a[account].lp.withdrawals[_s];
        require(amount > 0, "Claim: LP withdrawal is empty.");
        delete s.a[account].lp.withdrawals[_s];
        s.lp.withdrawn = s.lp.withdrawn - amount;
        return amount;
    }

    // Season of Plenty

    function claimBnb() public {
        LibInternal.updateSilo(msg.sender);
        uint256 bnb = claimPlenty(msg.sender);
        emit BnbClaim(msg.sender, bnb);
    }

    function claimPlenty(address account) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.sop.base == 0) return 0;
        uint256 bnb = (s.a[account].sop.base * s.sop.wbnb) / s.sop.base;
        s.sop.wbnb = s.sop.wbnb - bnb;
        s.sop.base = s.sop.base - s.a[account].sop.base;
        s.a[account].sop.base = 0;
        IWBNB(s.c.wbnb).withdraw(bnb);
        (bool success, ) = account.call{value: bnb}("");
        require(success, "WBNB: bnb transfer failed");
        return bnb;
    }

    // Harvest

    function harvest(uint256[] calldata plots) public returns (uint256 topcornsHarvested) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint256 i; i < plots.length; i++) {
            require(plots[i] < s.f.harvestable, "Claim: Plot not harvestable.");
            require(s.a[msg.sender].field.plots[plots[i]] > 0, "Claim: Plot not harvestable.");
            uint256 harvested = harvestPlot(msg.sender, plots[i]);
            topcornsHarvested = topcornsHarvested + harvested;
        }
        require(s.f.harvestable - s.f.harvested >= topcornsHarvested, "Claim: Not enough Harvestable.");
        s.f.harvested = s.f.harvested + topcornsHarvested;
        emit FullHarvest(msg.sender, plots, topcornsHarvested);
    }

    function harvestPlot(address account, uint256 plotId) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 pods = s.a[account].field.plots[plotId];
        require(pods > 0, "Claim: Plot is empty.");
        uint256 harvestablePods = s.f.harvestable - plotId;
        delete s.a[account].field.plots[plotId];
        if (s.podListings[plotId] > 0) {
            cancelPodListing(plotId);
        }
        if (harvestablePods >= pods) return pods;
        s.a[account].field.plots[plotId + harvestablePods] = pods - harvestablePods;
        return harvestablePods;
    }

    function cancelPodListing(uint256 index) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        delete s.podListings[index];
        emit PodListingCancelled(msg.sender, index);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity = 0.8.16;

import "../libraries/LibInternal.sol";
import "./AppStorage.sol";

/**
 * @author Farmer Farms
 * @title Variation of Oepn Zeppelins reentrant guard to include Silo Update
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts%2Fsecurity%2FReentrancyGuard.sol
 **/
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    AppStorage internal s;

    modifier updateSilo() {
        LibInternal.updateSilo(msg.sender);
        _;
    }
    
    modifier updateSiloNonReentrant() {
        require(s.reentrantStatus != _ENTERED, "ReentrancyGuard: reentrant call");
        s.reentrantStatus = _ENTERED;
        LibInternal.updateSilo(msg.sender);
        _;
        s.reentrantStatus = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(s.reentrantStatus != _ENTERED, "ReentrancyGuard: reentrant call");
        s.reentrantStatus = _ENTERED;
        _;
        s.reentrantStatus = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.16;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

/**
 * @author Stanislav
 * @title Pancake Pair Interface
 **/
interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.16;

import "../farm/AppStorage.sol";

/**
 * @author Publius
 * @title App Storage Library allows libaries to access Farmer's state.
 **/
library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity = 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Publius
 * @title TopCorn Interface
 **/
abstract contract ITopcorn is IERC20 {
    function burn(uint256 amount) public virtual;

    function burnFrom(address account, uint256 amount) public virtual;

    function mint(address account, uint256 amount) public virtual returns (bool);
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
pragma solidity >=0.6.2;

import { IPancakeRouter01 } from "./IPancakeRouter01.sol";

/**
 * @author Stanislav
 * @title Pancake Router02 Interface
 **/
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity = 0.8.16;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Publius
 * @title WBNB Interface
 **/
interface IWBNB is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

/**
 * @author Stanislav
 * @title Pancake Router01 Interface
 **/
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}