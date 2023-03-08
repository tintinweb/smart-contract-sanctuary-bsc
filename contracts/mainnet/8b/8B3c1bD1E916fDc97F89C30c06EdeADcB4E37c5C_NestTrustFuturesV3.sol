/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File contracts/libs/TransferHelper.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value,gas:5000}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/libs/CommonLib.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Common library
library CommonLib {
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // // ETH:
    // // Block average time in milliseconds. ethereum 12.09 seconds, BSC 3 seconds, polygon 2.2 seconds, KCC 3 seconds
    // uint constant BLOCK_TIME = 12090;
    // // Minimal exercise block period. 200000
    // uint constant MIN_PERIOD = 200000;
    // // Minimal exercise block period for NestLPGuarantee. 200000
    // uint constant MIN_EXERCISE_BLOCK = 200000;

    // BSC:
    // Block average time in milliseconds. ethereum 14 seconds, BSC 3 seconds, polygon 2.2 seconds, KCC 3 seconds
    uint constant BLOCK_TIME = 3000;
    // Minimal exercise block period. 840000
    uint constant MIN_PERIOD = 840000;
    // Minimal exercise block period for NestLPGuarantee. 840000
    uint constant MIN_EXERCISE_BLOCK = 840000;

    // // Polygon:
    // // Block average time in milliseconds. ethereum 14 seconds, BSC 3 seconds, polygon 2.2 seconds, KCC 3 seconds
    // uint constant BLOCK_TIME = 2200;
    // // Minimal exercise block period. 1200000
    // uint constant MIN_PERIOD = 1200000;
    // // Minimal exercise block period for NestLPGuarantee. 1200000
    // uint constant MIN_EXERCISE_BLOCK = 1200000;

    // // KCC:
    // // Block average time in milliseconds. ethereum 14 seconds, BSC 3 seconds, polygon 2.2 seconds, KCC 3 seconds
    // uint constant BLOCK_TIME = 3000;
    // // Minimal exercise block period. 840000
    // uint constant MIN_PERIOD = 840000;
    // // Minimal exercise block period for NestLPGuarantee. 840000
    // uint constant MIN_EXERCISE_BLOCK = 840000;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // USDT base
    uint constant USDT_BASE = 1 ether;

    // Post unit: 2000usd
    uint constant POST_UNIT = 2000 * USDT_BASE;

    // Minimum value quantity. If the balance is less than this value, it will be liquidated
    uint constant MIN_FUTURE_VALUE = 15 ether;

    // Unit of nest, 4 decimals
    uint constant NEST_UNIT = 0.0001 ether;

    // Min amount of buy futures, amount >= 50 nest
    uint constant FUTURES_NEST_LB = 499999;

    // // Service fee for buy, sell, add and liquidate
    // uint constant FEE_RATE = 0.001 ether;
    
    // Fee for execute limit order or stop order, 15 nest
    uint constant EXECUTE_FEE = 150000;

    // Fee for execute limit order or stop order in nest values, 18 decimals
    uint constant EXECUTE_FEE_NEST = EXECUTE_FEE * NEST_UNIT;

    // Range of lever, (LEVER_LB, LEVER_RB)
    uint constant LEVER_LB = 0;

    // Range of lever, (LEVER_LB, LEVER_RB)
    uint constant LEVER_RB = 51;

    /// @dev Encode the uint value as a floating-point representation in the form of fraction * 16 ^ exponent
    /// @param value Destination uint value
    /// @return v float format
    function encodeFloat56(uint value) internal pure returns (uint56 v) {
        assembly {
            for { v := 0 } gt(value, 0x3FFFFFFFFFFFF) { v := add(v, 1) } {
                value := shr(4, value)
            }
            v := or(v, shl(6, value))
        }
    }

    /// @dev Decode the floating-point representation of fraction * 16 ^ exponent to uint
    /// @param floatValue fraction value
    /// @return decode format
    function decodeFloat(uint floatValue) internal pure returns (uint) {
        return (floatValue >> 6) << ((floatValue & 0x3F) << 2);
    }

    /// @dev Convert to usdt based price
    /// @param rawPrice The price that equivalent to 2000usd 
    function toUSDTPrice(uint rawPrice) internal pure returns (uint) {
        return CommonLib.POST_UNIT * 1 ether / rawPrice;
    }    
}


// File contracts/interfaces/INestTrustFutures.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Futures proxy
interface INestTrustFutures {

    /// @dev TrustOrder information for view methods
    struct TrustOrderView {
        // Index of this TrustOrder
        uint32 index;
        // Owner of this order
        address owner;
        // Index of target Order
        uint32 orderIndex;
        // Index of target channel, support eth(0), btc(1) and bnb(2)
        uint16 channelIndex;
        // Leverage of this order
        uint8 lever;
        // Orientation of this order, long or short
        bool orientation;

        // Limit price for trigger buy
        uint limitPrice;
        // Stop price for trigger sell
        uint stopProfitPrice;
        uint stopLossPrice;

        // Balance of nest, 4 decimals
        uint40 balance;
        // Service fee, 4 decimals
        uint40 fee;
        // Status of order, 0: executed, 1: normal, 2: canceled
        uint8 status;
    }
    
    /// @dev Find the orders of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return orderArray Matched orders
    function findTrustOrder(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (TrustOrderView[] memory orderArray);

    /// @dev List TrustOrder
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return orderArray List of orders
    function listTrustOrder(
        uint offset, 
        uint count, 
        uint order
    ) external view returns (TrustOrderView[] memory orderArray);

    /// @dev Create TrustOrder, for everyone
    /// @param channelIndex Index of target trade channel, support eth, btc and bnb
    /// @param lever Leverage of this order
    /// @param orientation Orientation of this order, long or short
    /// @param amount Amount of buy order
    /// @param limitPrice Limit price for trigger buy
    /// @param stopProfitPrice If not 0, will open a stop order
    /// @param stopLossPrice If not 0, will open a stop order
    function newTrustOrder(
        uint16 channelIndex, 
        uint8 lever, 
        bool orientation, 
        uint amount, 
        uint limitPrice,
        uint stopProfitPrice,
        uint stopLossPrice
    ) external;

    /// @dev Update limitPrice for TrustOrder
    /// @param trustOrderIndex Index of TrustOrder
    /// @param limitPrice Limit price for trigger buy
    function updateLimitPrice(uint trustOrderIndex, uint limitPrice) external;

    /// @dev Update stopPrice for TrustOrder
    /// @param trustOrderIndex Index of target TrustOrder
    /// @param stopProfitPrice If not 0, will open a stop order
    /// @param stopLossPrice If not 0, will open a stop order
    function updateStopPrice(uint trustOrderIndex, uint stopProfitPrice, uint stopLossPrice) external;

    /// @dev Create a new stop order for Order
    /// @param orderIndex Index of target Order
    /// @param stopProfitPrice If not 0, will open a stop order
    /// @param stopLossPrice If not 0, will open a stop order
    function newStopOrder(uint orderIndex, uint stopProfitPrice, uint stopLossPrice) external;

    /// @dev Buy futures with StopOrder
    /// @param channelIndex Index of target channel
    /// @param lever Lever of order
    /// @param orientation true: long, false: short
    /// @param amount Amount of paid NEST, 4 decimals
    /// @param stopProfitPrice If not 0, will open a stop order
    /// @param stopLossPrice If not 0, will open a stop order
    function buyWithStopOrder(
        uint channelIndex, 
        uint lever, 
        bool orientation, 
        uint amount,
        uint stopProfitPrice, 
        uint stopLossPrice
    ) external payable;
    
    /// @dev Cancel TrustOrder, for everyone
    /// @param trustOrderIndex Index of TrustOrder
    function cancelLimitOrder(uint trustOrderIndex) external;

    /// @dev Execute limit order, only maintains account
    /// @param trustOrderIndices Array of TrustOrder index
    function executeLimitOrder(uint[] calldata trustOrderIndices) external;

    /// @dev Execute stop order, only maintains account
    /// @param trustOrderIndices Array of TrustOrder index
    function executeStopOrder(uint[] calldata trustOrderIndices) external;
}


// File contracts/interfaces/INestVault.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Defines methods for Nest Vault
interface INestVault {

    /// @dev Approve allowance amount to target contract address
    /// @dev target Target contract address
    /// @dev limit Amount limit can transferred once
    event Approved(address target, uint limit);

    /// @dev Approve allowance amount to target contract address
    /// @dev target Target contract address
    /// @dev limit Amount limit can transferred once
    function approve(address target, uint limit) external;

    /// @dev Transfer to by allowance
    /// @param to Target receive address
    /// @param amount Transfer amount
    function transferTo(address to, uint amount) external;
}


// File contracts/interfaces/INestFutures3.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Nest futures without merger
interface INestFutures3 {
    
    /// @dev Order structure
    struct Order {
        // Address index of owner
        uint32 owner;
        // Base price of this order, encoded with encodeFloat56()
        uint56 basePrice;
        // Balance of this order, 4 decimals
        uint40 balance;
        // Append amount of this order
        uint40 appends;
        // Index of target channel, support eth, btc and bnb
        uint16 channelIndex;
        // Leverage of this order
        uint8 lever;
        // Orientation of this order, long or short
        bool orientation;
        // Pt, use this to calculate miuT
        int56 Pt;
    }

    /// @dev Order for view methods
    struct OrderView {
        // Index of this order
        uint32 index;
        // Owner of this order
        address owner;
        // Balance of this order, 4 decimals
        uint40 balance;
        // Index of target channel, support eth, btc and bnb
        uint16 channelIndex;
        // Leverage of this order
        uint8 lever;
        // Append amount of this order
        uint40 appends;
        // Orientation of this order, long or short
        bool orientation;
        // Base price of this order
        uint basePrice;
        // Pt, use this to calculate miuT
        int Pt;
    }

    /// @dev Buy order event
    /// @param index Index of order
    /// @param nestAmount Amount of paid NEST, 4 decimals
    /// @param owner The owner of order
    event Buy(
        uint index,
        uint nestAmount,
        address owner
    );

    /// @dev Add order event
    /// @param index Index of order
    /// @param amount Amount to sell, 4 decimals
    /// @param owner The owner of order
    event Add(
        uint index,
        uint amount,
        address owner
    );

    /// @dev Sell order event
    /// @param index Index of order
    /// @param amount Amount to sell, 4 decimals
    /// @param owner The owner of order
    /// @param value Amount of NEST obtained
    event Sell(
        uint index,
        uint amount,
        address owner,
        uint value
    );

    /// @dev Liquidate order event
    /// @param index Index of order
    /// @param sender Address of sender
    /// @param reward Liquidation reward
    event Liquidate(
        uint index,
        address sender,
        uint reward
    );

    /// @dev Returns the current value of target order
    /// @param orderIndex Index of order
    /// @param oraclePrice Current price from oracle, usd based, 18 decimals
    function balanceOf(uint orderIndex, uint oraclePrice) external view returns (uint value);
    
    /// @dev Buy futures
    /// @param channelIndex Index of target channel
    /// @param lever Lever of order
    /// @param orientation true: long, false: short
    /// @param amount Amount of paid NEST, 4 decimals
    function buy(
        uint channelIndex, 
        uint lever, 
        bool orientation, 
        uint amount
    ) external payable;

    /// @dev Append buy
    /// @param orderIndex Index of target order
    /// @param amount Amount of paid NEST
    function add(uint orderIndex, uint amount) external payable;

    /// @dev Sell order
    /// @param orderIndex Index of order
    function sell(uint orderIndex) external payable;

    /// @dev Liquidate order
    /// @param indices Target order indices
    function liquidate(uint[] calldata indices) external payable;

    /// @dev Find the orders of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return orderArray Matched orders
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (OrderView[] memory orderArray);

    /// @dev List orders
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return orderArray List of orders
    function list(uint offset, uint count, uint order) external view returns (OrderView[] memory orderArray);

    /// @dev List prices
    /// @param channelIndex index of target channel
    function lastPrice(uint channelIndex) external view returns (uint period, uint height, uint price);
}


// File contracts/interfaces/INestMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev The interface defines methods for nest builtin contract address mapping
interface INestMapping {

    /// @dev Set the built-in contract address of the system
    /// @param nestTokenAddress Address of nest token contract
    /// @param nestNodeAddress Address of nest node contract
    /// @param nestLedgerAddress INestLedger implementation contract address
    /// @param nestMiningAddress INestMining implementation contract address for nest
    /// @param ntokenMiningAddress INestMining implementation contract address for ntoken
    /// @param nestPriceFacadeAddress INestPriceFacade implementation contract address
    /// @param nestVoteAddress INestVote implementation contract address
    /// @param nestQueryAddress INestQuery implementation contract address
    /// @param nnIncomeAddress NNIncome contract address
    /// @param nTokenControllerAddress INTokenController implementation contract address
    function setBuiltinAddress(
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    ) external;

    /// @dev Get the built-in contract address of the system
    /// @return nestTokenAddress Address of nest token contract
    /// @return nestNodeAddress Address of nest node contract
    /// @return nestLedgerAddress INestLedger implementation contract address
    /// @return nestMiningAddress INestMining implementation contract address for nest
    /// @return ntokenMiningAddress INestMining implementation contract address for ntoken
    /// @return nestPriceFacadeAddress INestPriceFacade implementation contract address
    /// @return nestVoteAddress INestVote implementation contract address
    /// @return nestQueryAddress INestQuery implementation contract address
    /// @return nnIncomeAddress NNIncome contract address
    /// @return nTokenControllerAddress INTokenController implementation contract address
    function getBuiltinAddress() external view returns (
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    );

    /// @dev Get address of nest token contract
    /// @return Address of nest token contract
    function getNestTokenAddress() external view returns (address);

    /// @dev Get address of nest node contract
    /// @return Address of nest node contract
    function getNestNodeAddress() external view returns (address);

    /// @dev Get INestLedger implementation contract address
    /// @return INestLedger implementation contract address
    function getNestLedgerAddress() external view returns (address);

    /// @dev Get INestMining implementation contract address for nest
    /// @return INestMining implementation contract address for nest
    function getNestMiningAddress() external view returns (address);

    /// @dev Get INestMining implementation contract address for ntoken
    /// @return INestMining implementation contract address for ntoken
    function getNTokenMiningAddress() external view returns (address);

    /// @dev Get INestPriceFacade implementation contract address
    /// @return INestPriceFacade implementation contract address
    function getNestPriceFacadeAddress() external view returns (address);

    /// @dev Get INestVote implementation contract address
    /// @return INestVote implementation contract address
    function getNestVoteAddress() external view returns (address);

    /// @dev Get INestQuery implementation contract address
    /// @return INestQuery implementation contract address
    function getNestQueryAddress() external view returns (address);

    /// @dev Get NNIncome contract address
    /// @return NNIncome contract address
    function getNnIncomeAddress() external view returns (address);

    /// @dev Get INTokenController implementation contract address
    /// @return INTokenController implementation contract address
    function getNTokenControllerAddress() external view returns (address);

    /// @dev Registered address. The address registered here is the address accepted by nest system
    /// @param key The key
    /// @param addr Destination address. 0 means to delete the registration information
    function registerAddress(string memory key, address addr) external;

    /// @dev Get registered address
    /// @param key The key
    /// @return Destination address. 0 means empty
    function checkAddress(string memory key) external view returns (address);
}


// File contracts/interfaces/INestGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This interface defines the governance methods
interface INestGovernance is INestMapping {

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight 
    /// to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File contracts/NestBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of nest
contract NestBase {

    /// @dev INestGovernance implementation contract address
    address public _governance;

    /// @dev To support open-zeppelin/upgrades
    /// @param governance INestGovernance implementation contract address
    function initialize(address governance) public virtual {
        require(_governance == address(0), "NEST:!initialize");
        _governance = governance;
    }

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    /// @param newGovernance INestGovernance implementation contract address
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = newGovernance;
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(INestGovernance(_governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _;
    }

    modifier noContract() {
        require(msg.sender == tx.origin, "NEST:!contract");
        _;
    }
}


// File contracts/custom/NestFrequentlyUsed.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This contract include frequently used data
contract NestFrequentlyUsed is NestBase {

    // // ETH:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0xE544cF993C7d477C7ef8E91D28aCA250D135aa03;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS;

    // BSC:
    // Address of nest token
    address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // Address of NestOpenPrice contract
    address constant NEST_OPEN_PRICE = 0x09CE0e021195BA2c1CDE62A8B187abf810951540;
    // Address of nest vault
    address constant NEST_VAULT_ADDRESS = 0x65e7506244CDdeFc56cD43dC711470F8B0C43beE;
    // Address of direct poster
    address constant DIRECT_POSTER = 0x06Ca5C8eFf273009C94D963e0AB8A8B9b09082eF;
    // Address of CyberInk
    address constant CYBER_INK_ADDRESS = 0xCBB79049675F06AFF618CFEB74c2B0Bf411E064a;

    // // Polygon:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0x09CE0e021195BA2c1CDE62A8B187abf810951540;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS;

    // // KCC:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0x7DBe94A4D6530F411A1E7337c7eb84185c4396e6;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS;

    // USDT base
    uint constant USDT_BASE = 1 ether;
}

// import "../interfaces/INestGovernance.sol";

// /// @dev This contract include frequently used data
// contract NestFrequentlyUsed is NestBase {

//     // Address of nest token
//     address NEST_TOKEN_ADDRESS;
//     // Address of NestOpenPrice contract
//     address NEST_OPEN_PRICE;
//     // Address of nest vault
//     address NEST_VAULT_ADDRESS;
//     // Address of CyberInk
//     address constant CYBER_INK_ADDRESS = address(0);
//     // Address of direct poster
//     //address DIRECT_POSTER;  // 0x06Ca5C8eFf273009C94D963e0AB8A8B9b09082eF;

//     // USDT base
//     uint constant USDT_BASE = 1 ether;

//     /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
//     ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
//     /// @param newGovernance INestGovernance implementation contract address
//     function update(address newGovernance) public virtual override {
//         super.update(newGovernance);
//         NEST_TOKEN_ADDRESS = INestGovernance(newGovernance).getNestTokenAddress();
//         NEST_OPEN_PRICE = INestGovernance(newGovernance).checkAddress("nest.v4.openPrice");
//         NEST_VAULT_ADDRESS = INestGovernance(newGovernance).checkAddress("nest.app.vault");
//         //DIRECT_POSTER = INestGovernance(newGovernance).checkAddress("nest.app.directPoster");
//         //CYBER_INK_ADDRESS = INestGovernance(newGovernance).checkAddress("nest.app.cyberink");
//     }
// }


// File contracts/NestFutures3V3.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Nest futures with dynamic miu
contract NestFutures3V3 is NestFrequentlyUsed, INestFutures3 {

    // Service fee for buy, sell, add and liquidate
    uint constant FEE_RATE = 0.001 ether;

    // Global parameter for trade channel
    struct TradeChannel {
        // Last price of this channel, encoded with encodeFloat56()
        uint56 lastPrice;
        int56  miu;
        int56  PtL;
        int56  PtS;
        uint32 bn;
    }

    // Registered account address mapping
    mapping(address=>uint) _accountMapping;

    // Registered accounts
    address[] _accounts;

    // Array of orders
    Order[] _orders;

    // The prices of (eth, btc and bnb) posted by directPost() method is stored in this field
    // Bits explain: period(16)|height(48)|price3(64)|price2(64)|price1(64)
    uint _lastPrices;
    
    // Global parameters for trade channel
    TradeChannel[3] _channels;

    // Address of direct poster
    //address constant DIRECT_POSTER = 0x06Ca5C8eFf273009C94D963e0AB8A8B9b09082eF;
    //address constant DIRECT_POSTER = 0xd9f3aA57576a6da995fb4B7e7272b4F16f04e681;

    constructor() {
    }
    
    /// @dev To support open-zeppelin/upgrades
    /// @param governance INestGovernance implementation contract address
    function initialize(address governance) public override {
        super.initialize(governance);
        _accounts.push();
    }

    /// @dev Direct post price
    /// @param period Term of validity
    // @param prices Price array, direct price, eth&btc&bnb, eg: 1700e18, 25000e18, 300e18
    // Please note that the price is no longer relative to 2000 USD
    function post(uint period, uint[3] calldata /*prices*/) external {
        require(msg.sender == DIRECT_POSTER, "NF:not directPoster");
        assembly {
            // Encode value at position indicated by value to float
            function encode(value) -> v {
                v := 0
                // Load value from calldata
                // Encode logic
                for { value := calldataload(value) } gt(value, 0x3FFFFFFFFFFFFFF) { value := shr(4, value) } {
                    v := add(v, 1)
                }
                v := or(v, shl(6, value))
            }

            period := 
            or(
                or(
                    or(
                        or(
                            // period
                            shl(240, period), 
                            // block.number
                            shl(192, number())
                        ), 
                        // equivalents[2]
                        shl(128, encode(0x64))
                    ), 
                    // equivalents[1]
                    shl(64, encode(0x44))
                ), 
                // equivalents[0]
                encode(0x24)
            )
        }
        _lastPrices = period;
    }

    /// @dev List prices
    /// @param channelIndex index of target channel
    function lastPrice(uint channelIndex) public view override returns (uint period, uint height, uint price) {
        // Bits explain: period(16)|height(48)|price3(64)|price2(64)|price1(64)
        uint rawPrice =_lastPrices;
        return (
            rawPrice >> 240,
            (rawPrice >> 192) & 0xFFFFFFFFFFFF,
            CommonLib.decodeFloat((rawPrice >> (channelIndex << 6)) & 0xFFFFFFFFFFFFFFFF)
        );
    }

    /// @dev Get channel information
    /// @param channelIndex Index of target channel
    function getChannel(uint channelIndex) external view returns (TradeChannel memory channel) {
        channel = _channels[channelIndex];
    }

    /// @dev Returns the current value of target order
    /// @param orderIndex Index of order
    /// @param oraclePrice Current price from oracle, usd based, 18 decimals
    function balanceOf(uint orderIndex, uint oraclePrice) external view override returns (uint value) {
        Order memory order = _orders[orderIndex];
        (value,) = _valueOf(_updateChannel(uint(order.channelIndex), oraclePrice), order, oraclePrice);
    }

    /// @dev Find the orders of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return orderArray Matched orders
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view override returns (OrderView[] memory orderArray) {
        unchecked {
            orderArray = new OrderView[](count);
            // Calculate search region
            Order[] storage orders = _orders;

            // Loop from start to end
            uint end = 0;
            // start is 0 means Loop from the last item
            if (start == 0) {
                start = orders.length;
            }
            // start > maxFindCount, so end is not 0
            if (start > maxFindCount) {
                end = start - maxFindCount;
            }
            
            // Loop lookup to write qualified records to the buffer
            uint ownerIndex = _accountMapping[owner];
            for (uint index = 0; index < count && start > end;) {
                Order memory order = orders[--start];
                if (uint(order.owner) == ownerIndex) {
                    orderArray[index++] = _toOrderView(order, start);
                }
            }
        }
    }

    /// @dev List orders
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return orderArray List of orders
    function list(uint offset, uint count, uint order) external view override returns (OrderView[] memory orderArray) {
        unchecked {
            // Load orders
            Order[] storage orders = _orders;
            // Create result array
            orderArray = new OrderView[](count);
            uint length = orders.length;
            uint i = 0;

            // Reverse order
            if (order == 0) {
                uint index = length - offset;
                uint end = index > count ? index - count : 0;
                while (index > end) {
                    Order memory o = orders[--index];
                    orderArray[i++] = _toOrderView(o, index);
                }
            } 
            // Positive order
            else {
                uint index = offset;
                uint end = index + count;
                if (end > length) {
                    end = length;
                }
                while (index < end) {
                    orderArray[i++] = _toOrderView(orders[index], index);
                    ++index;
                }
            }
        }
    }

    /// @dev Buy futures
    /// @param channelIndex Index of target channel
    /// @param lever Lever of order
    /// @param orientation true: long, false: short
    /// @param amount Amount of paid NEST, 4 decimals
    function buy(
        uint channelIndex, 
        uint lever, 
        bool orientation, 
        uint amount
    ) public payable override {
        // 1. Check arguments
        require(amount > CommonLib.FUTURES_NEST_LB && amount < 0x10000000000, "NF:amount invalid");
        require(lever > CommonLib.LEVER_LB && lever < CommonLib.LEVER_RB, "NF:lever not allowed");

        // 2. Load target channel
        // channelIndex is increase from 0, if channelIndex out of range, means target channel not exist
        uint oraclePrice = _lastPrice(channelIndex);
        TradeChannel memory channel = _updateChannel(channelIndex, oraclePrice);

        // 3. Update parameter for channel
        _channels[channelIndex] = channel;

        // 4. Emit event
        emit Buy(_orders.length, amount, msg.sender);

        // 5. Create order
        _orders.push(Order(
            // owner
            uint32(_addressIndex(msg.sender)),
            // basePrice
            // Query oraclePrice
            CommonLib.encodeFloat56(oraclePrice),
            // balance
            uint40(amount),
            // append
            uint40(0),
            // channelIndex
            uint16(channelIndex),
            // lever
            uint8(lever),
            // orientation
            orientation,
            // Pt
            orientation ? channel.PtL : channel.PtS
        ));

        // 6. Transfer NEST from user
        TransferHelper.safeTransferFrom(
            NEST_TOKEN_ADDRESS, 
            msg.sender, 
            NEST_VAULT_ADDRESS, 
            amount * CommonLib.NEST_UNIT * (1 ether + FEE_RATE * lever) / 1 ether
        );
    }

    /// @dev Append buy
    /// @param orderIndex Index of target order
    /// @param amount Amount of paid NEST
    function add(uint orderIndex, uint amount) external payable override {
        // 1. Check arguments
        require(amount < 0x10000000000, "NF:amount invalid");
        _orders[orderIndex].appends += uint40(amount);

        // 2. Emit event
        emit Add(orderIndex, amount, msg.sender);

        // 3. Transfer NEST from user
        TransferHelper.safeTransferFrom(
            NEST_TOKEN_ADDRESS, 
            msg.sender, 
            NEST_VAULT_ADDRESS, 
            amount * CommonLib.NEST_UNIT
        );
    }

    /// @dev Sell order
    /// @param orderIndex Index of order
    function sell(uint orderIndex) external payable override {
        // 1. Load the order
        Order memory order = _orders[orderIndex];
        require(msg.sender == _accounts[uint(order.owner)], "NF:not owner");

        // 2. Query price
        uint channelIndex = uint(order.channelIndex);
        uint oraclePrice = _lastPrice(channelIndex);

        // 3. Update channel
        TradeChannel memory channel = _updateChannel(channelIndex, oraclePrice);
        _channels[channelIndex] = channel;

        // 4. Calculate value and update Order
        (uint value, uint fee) = _valueOf(channel, order, oraclePrice);
        emit Sell(orderIndex, uint(order.balance), msg.sender, value);
        order.balance = uint40(0);
        order.appends = uint40(0);
        _orders[orderIndex] = order;

        // 5. Transfer NEST to user
        // If value grater than fee, deduct and transfer NEST to owner
        if (value > fee) {
            INestVault(NEST_VAULT_ADDRESS).transferTo(msg.sender, value - fee);
        }
    }

    /// @dev Liquidate order
    /// @param indices Target order indices
    function liquidate(uint[] calldata indices) external payable override {
        // 0. Global variables
        // Total reward of this transaction
        uint reward = 0;
        // Last price of current channel
        uint oraclePrice = 0;
        // Index of current channel
        uint channelIndex = 0x10000;
        // Current channel
        TradeChannel memory channel;
        
        // 1. Loop and liquidate
        // Index of Order
        uint index = 0;
        uint i = indices.length << 5;
        while (i > 0) {
            // 2. Load Order
            // uint index = indices[--i];
            assembly {
                i := sub(i, 0x20)
                index := calldataload(add(indices.offset, i))
            }

            Order memory order = _orders[index];
            uint lever = uint(order.lever);
            uint balance = uint(order.balance) * CommonLib.NEST_UNIT * lever;
            if (lever > 1 && balance > 0) {
                // 3. Load and update channel
                // If channelIndex is not same with previous, need load new channel and query oracle
                // At first, channelIndex is 0x10000, this is impossible the same with current channelIndex
                if (channelIndex != uint(order.channelIndex)) {
                    // Update previous channel
                    if (channelIndex < 0x10000) {
                        _channels[channelIndex] = channel;
                    }
                    // Load current channel
                    channelIndex = uint(order.channelIndex);
                    oraclePrice = _lastPrice(channelIndex);
                    channel = _updateChannel(channelIndex, oraclePrice);
                }

                // 4. Calculate order value
                (uint value, uint fee) = _valueOf(channel, order, oraclePrice);

                // 5. Liquidate logic
                // lever is great than 1, and balance less than a regular value, can be liquidated
                // the regular value is: Max(M0 * L * St / S0 * c, a) | expired
                // the regular value is: Max(M0 * L * St / S0 * c + a, M0 * L * 0.5%)
                unchecked {
                    if (value < balance / 200 || value < fee + CommonLib.MIN_FUTURE_VALUE) {
                        // Clear all data of order, use this code next time
                        assembly {
                            mstore(0, _orders.slot)
                            sstore(add(keccak256(0, 0x20), index), 0)
                        }
                        
                        // Add reward
                        reward += value;

                        // Emit liquidate event
                        emit Liquidate(index, msg.sender, value);
                    }
                }
            }
        }

        // Update last channel
        if (channelIndex < 0x10000) {
            _channels[channelIndex] = channel;
        }

        // 6. Transfer NEST to user
        if (reward > 0) {
            INestVault(NEST_VAULT_ADDRESS).transferTo(msg.sender, reward);
        }
    }

    // Calculate e^μT
    function _expMiuT(int miuT) internal pure returns (uint) {
        // return _toUInt(ABDKMath64x64.exp(
        //     _toInt128((orientation ? MIU_LONG : MIU_SHORT) * (block.number - baseBlock) * BLOCK_TIME)
        // ));

        // Using approximate algorithm: x*(1+rt)
        // This may be 0, or negative!
        int v = (miuT * 0x10000000000000000) / 1e12 + 0x10000000000000000;
        if (v < 1) return 1;
        return uint(v);
    }

    // Calculate net worth
    function _valueOf(
        TradeChannel memory channel,
        Order memory order, 
        uint oraclePrice
    ) internal pure returns (uint value, uint fee) {
        value = uint(order.balance) * CommonLib.NEST_UNIT;
        uint lever = uint(order.lever);
        uint base = value * lever * oraclePrice / CommonLib.decodeFloat(uint(order.basePrice));
        uint negative;

        // Long
        if (order.orientation) {
            negative = value * lever;
            value = value + (
                channel.PtL > order.Pt 
                ? base * 0x10000000000000000 / _expMiuT(int(channel.PtL) - int(order.Pt)) 
                : base
            ) + uint(order.appends) * CommonLib.NEST_UNIT;
        } 
        // Short
        else {
            negative = channel.PtS < order.Pt 
                     ? base * 0x10000000000000000 / _expMiuT(int(channel.PtS) - int(order.Pt)) 
                     : base;
            value = value * (1 + lever) + uint(order.appends) * CommonLib.NEST_UNIT;
        }

        assembly {
            switch gt(value, negative) 
            case true { value := sub(value, negative) }
            case false { value := 0 }

            fee := div(mul(base, FEE_RATE), 1000000000000000000)
        }
    }

    // Query price
    function _lastPrice(uint channelIndex) internal view returns (uint oraclePrice) {
        // Query price from oracle
        (uint period, uint height, uint price) = lastPrice(channelIndex);
        unchecked { require(block.number < height + period, "NF:price expired"); }
        oraclePrice = price;
    }

    /// @dev Gets the index number of the specified address. If it does not exist, register
    /// @param addr Destination address
    /// @return The index number of the specified address
    function _addressIndex(address addr) internal returns (uint) {
        uint index = _accountMapping[addr];
        if (index == 0) {
            // If it exceeds the maximum number that 32 bits can store, you can't continue to register a new account.
            // If you need to support a new account, you need to update the contract
            require((_accountMapping[addr] = index = _accounts.length) < 0x100000000, "NO:!accounts");
            _accounts.push(addr);
        }

        return index;
    }
    
    // Update parameters to channel and load
    function _updateChannel(uint channelIndex, uint S1) internal view returns (TradeChannel memory channel) {
        channel = _channels[channelIndex];
        uint bn = uint(channel.bn);
        if (block.number > bn && bn > 0) 
        {
            // Pt is expressed as 56-bits integer, which 12 decimals, representable range is
            // [-36028.797018963968, 36028.797018963967], assume the earn rate is 0.9% per day,
            // and it continues 100 years, Pt may reach to 328.725, this is far less than 
            // 36028.797018963967, so Pt is impossible out of [-36028.797018963968, 36028.797018963967].
            // And even so, Pt is truncated, the consequences are not serious, so we don't check truncation
            unchecked {
                int S0 = int(CommonLib.decodeFloat(channel.lastPrice));
                int dt = int(block.number - bn) * 3;
                int miu = int(channel.miu);
                channel.PtL = int56(int(channel.PtL) + (miu + 0.00000001027e12) * dt);
                channel.PtS = int56(int(channel.PtS) + miu * dt);
                channel.miu =int56(0.0895e12 * (int(S1) - S0) / S0 / dt);
            }
        }

        channel.lastPrice = CommonLib.encodeFloat56(S1);
        channel.bn = uint32(block.number);
    }

    // Convert Order to OrderView
    function _toOrderView(Order memory order, uint index) internal view returns (OrderView memory v) {
        v = OrderView(
            // index
            uint32(index),
            // owner
            _accounts[uint(order.owner)],
            // balance
            order.balance,
            // channelIndex
            order.channelIndex,
            // lever
            order.lever,
            // appends
            order.appends,
            // orientation
            order.orientation,
            // basePrice
            CommonLib.decodeFloat(order.basePrice),
            // Pt
            order.Pt
        );
    }
}


// File contracts/NestTrustFuturesV3.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Futures proxy
contract NestTrustFuturesV3 is NestFutures3V3, INestTrustFutures {

    // Status of limit order: executed
    uint constant S_EXECUTED = 0;

    // Status of limit order: normal
    uint constant S_NORMAL = 1;
    
    // Status of limit order: canceled
    uint constant S_CANCELED = 2;

    // TrustOrder, include limit order and stop order
    struct TrustOrder {
        // Index of target Order
        uint32 orderIndex;              // 32
        // Balance of nest, 4 decimals
        uint40 balance;                 // 48
        // Service fee, 4 decimals
        uint40 fee;                     // 48
        // Stop price for trigger sell, encoded by encodeFloat56()
        uint56 stopProfitPrice;         // 56
        // Stop price for trigger sell, encoded by encodeFloat56()
        uint56 stopLossPrice;           // 56
        // Status of order, 0: executed, 1: normal, 2: canceled
        uint8 status;                   // 8
    }

    // Array of TrustOrders
    TrustOrder[] _trustOrders;

    address constant MAINTAINS_ADDRESS = 0x029972C516c4F248c5B066DA07DbAC955bbb5E7F;

    modifier onlyMaintains {
        require(msg.sender == MAINTAINS_ADDRESS, "NFP:not maintains");
        _;
    }

    constructor() {
    }
    
    /// @dev Find the orders of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return orderArray Matched orders
    function findTrustOrder(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view override returns (TrustOrderView[] memory orderArray) {
        unchecked {
            orderArray = new TrustOrderView[](count);
            // Calculate search region
            TrustOrder[] storage orders = _trustOrders;

            // Loop from start to end
            uint end = 0;
            // start is 0 means Loop from the last item
            if (start == 0) {
                start = orders.length;
            }
            // start > maxFindCount, so end is not 0
            if (start > maxFindCount) {
                end = start - maxFindCount;
            }
            
            // Loop lookup to write qualified records to the buffer
            uint ownerIndex = _accountMapping[owner];
            for (uint index = 0; index < count && start > end;) {
                TrustOrder memory order = orders[--start];
                if (_orders[uint(order.orderIndex)].owner == ownerIndex) {
                    orderArray[index++] = _toTrustOrderView(order, start);
                }
            }
        }
    }

    /// @dev List TrustOrder
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return orderArray List of orders
    function listTrustOrder(
        uint offset, 
        uint count, 
        uint order
    ) external view override returns (TrustOrderView[] memory orderArray) {
        unchecked {
            // Load orders
            TrustOrder[] storage orders = _trustOrders;
            // Create result array
            orderArray = new TrustOrderView[](count);
            uint length = orders.length;
            uint i = 0;

            // Reverse order
            if (order == 0) {
                uint index = length - offset;
                uint end = index > count ? index - count : 0;
                while (index > end) {
                    TrustOrder memory o = orders[--index];
                    orderArray[i++] = _toTrustOrderView(o, index);
                }
            } 
            // Positive order
            else {
                uint index = offset;
                uint end = index + count;
                if (end > length) {
                    end = length;
                }
                while (index < end) {
                    orderArray[i++] = _toTrustOrderView(orders[index], index);
                    ++index;
                }
            }
        }
    }

    /// @dev Create TrustOrder, for everyone
    /// @param channelIndex Index of target trade channel, support eth, btc and bnb
    /// @param lever Leverage of this order
    /// @param orientation Orientation of this order, long or short
    /// @param amount Amount of buy order
    /// @param limitPrice Limit price for trigger buy
    /// @param stopProfitPrice If not 0, will open a stop order
    /// @param stopLossPrice If not 0, will open a stop order
    function newTrustOrder(
        uint16 channelIndex, 
        uint8 lever, 
        bool orientation, 
        uint amount, 
        uint limitPrice,
        uint stopProfitPrice,
        uint stopLossPrice
    ) external override {
        // 1. Check arguments
        require(amount > CommonLib.FUTURES_NEST_LB && amount < 0x10000000000, "NF:amount invalid");
        require(lever > CommonLib.LEVER_LB && lever < CommonLib.LEVER_RB, "NF:lever not allowed");
        
        // 2. Service fee, 4 decimals
        uint fee = amount * FEE_RATE * uint(lever) / 1 ether;

        // 3. Create TrustOrder
        _trustOrders.push(TrustOrder(
            // orderIndex
            uint32(_orders.length),
            // balance
            uint40(amount),
            // fee
            uint40(fee),
            // stopProfitPrice
            stopProfitPrice > 0 ? CommonLib.encodeFloat56(stopProfitPrice) : uint56(0),
            // stopLossPrice
            stopLossPrice   > 0 ? CommonLib.encodeFloat56(stopLossPrice  ) : uint56(0),
            // status
            uint8(S_NORMAL)
        ));

        // 4. Create Order
        _orders.push(Order(
            // owner
            uint32(_addressIndex(msg.sender)),
            // basePrice
            // Query oraclePrice
            CommonLib.encodeFloat56(limitPrice),
            // balance
            uint40(0),
            // appends
            uint40(0),
            // channelIndex
            channelIndex,
            // lever
            lever,
            // orientation
            orientation,
            // Pt
            int56(0)
        ));

        // 5. Transfer NEST
        TransferHelper.safeTransferFrom(
            NEST_TOKEN_ADDRESS,
            msg.sender, 
            address(this), 
            (amount + fee + CommonLib.EXECUTE_FEE) * CommonLib.NEST_UNIT
        );
    }

    /// @dev Update limitPrice for TrustOrder
    /// @param trustOrderIndex Index of TrustOrder
    /// @param limitPrice Limit price for trigger buy
    function updateLimitPrice(uint trustOrderIndex, uint limitPrice) external override {
        // Load TrustOrder
        TrustOrder memory trustOrder = _trustOrders[trustOrderIndex];

        // Check status
        require(uint(trustOrder.status) == S_NORMAL, "NF:status error");
        
        // Load Order
        uint orderIndex = uint(trustOrder.orderIndex);
        Order memory order = _orders[orderIndex];
        
        // Check owner
        require(msg.sender == _accounts[uint(order.owner)], "NF:not owner");
        
        // Update limitPrice
        _orders[orderIndex].basePrice = CommonLib.encodeFloat56(limitPrice);
    }

    /// @dev Update stopPrice for TrustOrder
    /// @param trustOrderIndex Index of target TrustOrder
    /// @param stopProfitPrice If not 0, will open a stop order
    /// @param stopLossPrice If not 0, will open a stop order
    function updateStopPrice(uint trustOrderIndex, uint stopProfitPrice, uint stopLossPrice) external override {
        // Load TrustOrder
        TrustOrder memory trustOrder = _trustOrders[trustOrderIndex];

        // Check owner
        require(msg.sender == _accounts[_orders[uint(trustOrder.orderIndex)].owner], "NF:not owner");

        // Update stopPrice
        // When user updateStopPrice, stopProfitPrice and stopLossPrice are not 0 general, so we don't consider 0
        trustOrder.stopProfitPrice = CommonLib.encodeFloat56(stopProfitPrice);
        trustOrder.stopLossPrice   = CommonLib.encodeFloat56(stopLossPrice  );

        _trustOrders[trustOrderIndex] = trustOrder;
    }

    /// @dev Create a new stop order for Order
    /// @param orderIndex Index of target Order
    /// @param stopProfitPrice If not 0, will open a stop order
    /// @param stopLossPrice If not 0, will open a stop order
    function newStopOrder(uint orderIndex, uint stopProfitPrice, uint stopLossPrice) public override {
        Order memory order = _orders[orderIndex];

        // The balance of the order is 0, means order cleared, or a LimitOrder haven't executed
        require(uint(order.balance) > 0, "NF:order cleared");
        require(msg.sender == _accounts[uint(order.owner)], "NF:not owner");

        _trustOrders.push(TrustOrder(
            uint32(orderIndex),
            uint40(0),
            uint40(0),
            // When user newStopOrder, stopProfitPrice and stopLossPrice are not 0 general, so we don't consider 0
            CommonLib.encodeFloat56(stopProfitPrice),
            CommonLib.encodeFloat56(stopLossPrice),
            uint8(S_EXECUTED)
        ));
    }

    /// @dev Buy futures with StopOrder
    /// @param channelIndex Index of target channel
    /// @param lever Lever of order
    /// @param orientation true: long, false: short
    /// @param amount Amount of paid NEST, 4 decimals
    /// @param stopProfitPrice If not 0, will open a stop order
    /// @param stopLossPrice If not 0, will open a stop order
    function buyWithStopOrder(
        uint channelIndex, 
        uint lever, 
        bool orientation, 
        uint amount,
        uint stopProfitPrice, 
        uint stopLossPrice
    ) external payable override {
        buy(channelIndex, lever, orientation, amount);
        newStopOrder(_orders.length - 1, stopProfitPrice, stopLossPrice);
    }

    /// @dev Cancel TrustOrder, for everyone
    /// @param trustOrderIndex Index of TrustOrder
    function cancelLimitOrder(uint trustOrderIndex) external override {
        // Load TrustOrder
        TrustOrder memory trustOrder = _trustOrders[trustOrderIndex];
        // Check status
        require((trustOrder.status) == S_NORMAL, "NF:status error");
        // Check owner
        require(msg.sender == _accounts[uint(_orders[uint(trustOrder.orderIndex)].owner)], "NF:not owner");

        TransferHelper.safeTransfer(
            NEST_TOKEN_ADDRESS,
            msg.sender,
            (uint(trustOrder.balance) + uint(trustOrder.fee) + CommonLib.EXECUTE_FEE) * CommonLib.NEST_UNIT
        );

        trustOrder.balance = uint40(0);
        trustOrder.fee = uint40(0);
        trustOrder.status = uint8(S_CANCELED);
        _trustOrders[trustOrderIndex] = trustOrder;
    }

    /// @dev Execute limit order, only maintains account
    /// @param trustOrderIndices Array of TrustOrder index
    function executeLimitOrder(uint[] calldata trustOrderIndices) external override onlyMaintains {
        uint totalNest = 0;
        uint oraclePrice = 0;
        uint channelIndex = 0x10000;
        TradeChannel memory channel;

        // 1. Loop and execute
        uint index = 0;
        uint i = trustOrderIndices.length << 5;
        while (i > 0) { 
            // Load TrustOrder and Order
            // uint index = trustOrderIndices[--i];
            assembly {
                i := sub(i, 0x20)
                index := calldataload(add(trustOrderIndices.offset, i))
            }

            TrustOrder memory trustOrder = _trustOrders[index];
            // Check status
            require(trustOrder.status == uint8(S_NORMAL), "NF:status error");
            uint orderIndex = uint(trustOrder.orderIndex);
            Order memory order = _orders[orderIndex];

            if (channelIndex != uint(order.channelIndex)) {
                // If channelIndex is not same with previous, need load new channel and query oracle
                // At first, channelIndex is 0x10000, this is impossible the same with current channelIndex
                if (channelIndex < 0x10000) {
                    _channels[channelIndex] = channel;
                }
                // Load current channel
                channelIndex = uint(order.channelIndex);
                oraclePrice = _lastPrice(channelIndex);
                channel = _updateChannel(channelIndex, oraclePrice);
            }

            uint balance = uint(trustOrder.balance);
            totalNest += (balance + uint(trustOrder.fee));

            // Update Order: basePrice, baseBlock, balance, Pt
            order.basePrice = CommonLib.encodeFloat56(oraclePrice);
            order.balance = uint40(balance);
            order.Pt = order.orientation ? channel.PtL : channel.PtS;

            // Update TrustOrder: balance, status
            trustOrder.balance = uint40(0);
            trustOrder.fee = uint40(0);
            trustOrder.status = uint8(S_EXECUTED);

            // Update TrustOrder and Order
            _trustOrders[index] = trustOrder;
            _orders[orderIndex] = order;
        }

        // Update last channel
        if (channelIndex < 0x10000) {
            _channels[channelIndex] = channel;
        }

        // Transfer NEST to NestVault
        TransferHelper.safeTransfer(NEST_TOKEN_ADDRESS, NEST_VAULT_ADDRESS, totalNest * CommonLib.NEST_UNIT);
    }

    /// @dev Execute stop order, only maintains account
    /// @param trustOrderIndices Array of TrustOrder index
    function executeStopOrder(uint[] calldata trustOrderIndices) external override onlyMaintains {
        uint executeFee = 0;
        uint oraclePrice = 0;
        uint channelIndex = 0x10000;
        TradeChannel memory channel;

        // 1. Loop and execute
        for (uint i = trustOrderIndices.length; i > 0;) {
            TrustOrder memory trustOrder = _trustOrders[trustOrderIndices[--i]];
            require(uint(trustOrder.status) == S_EXECUTED, "NF:status error");
            Order memory order = _orders[uint(trustOrder.orderIndex)];
            uint balance = uint(order.balance);

            if (balance > 0) {
                address owner = _accounts[uint(order.owner)];

                if (channelIndex != uint(order.channelIndex)) {
                    // If channelIndex is not same with previous, need load new channel and query oracle
                    // At first, channelIndex is 0x10000, this is impossible the same with current channelIndex
                    if (channelIndex < 0x10000) {
                        _channels[channelIndex] = channel;
                    }
                    // Load current channel
                    channelIndex = uint(order.channelIndex);
                    oraclePrice = _lastPrice(channelIndex);
                    channel = _updateChannel(channelIndex, oraclePrice);
                }

                (uint value, uint fee) = _valueOf(channel, order, oraclePrice);

                order.balance = uint40(0);
                order.appends = uint40(0);
                _orders[uint(trustOrder.orderIndex)] = order;

                // Newest value of order is greater than fee + EXECUTE_FEE, deduct and transfer NEST to owner
                if (value > fee + CommonLib.EXECUTE_FEE_NEST) {
                    INestVault(NEST_VAULT_ADDRESS).transferTo(owner, value - fee - CommonLib.EXECUTE_FEE_NEST);
                }
                executeFee += CommonLib.EXECUTE_FEE_NEST;

                emit Sell(uint(trustOrder.orderIndex), balance, owner, value);
            }
        }
        
        // Update last channel
        if (channelIndex < 0x10000) {
            _channels[channelIndex] = channel;
        }

        // Transfer EXECUTE_FEE to proxy address
        INestVault(NEST_VAULT_ADDRESS).transferTo(address(this), executeFee);
    }

    /// @dev Settle execute fee to MAINTAINS_ADDRESS
    /// @param value Value of total execute fee
    function settleExecuteFee(uint value) external onlyGovernance {
        TransferHelper.safeTransfer(NEST_TOKEN_ADDRESS, MAINTAINS_ADDRESS, value);
    }

    // Convert TrustOrder to TrustOrderView
    function _toTrustOrderView(
        TrustOrder memory trustOrder, 
        uint index
    ) internal view returns (TrustOrderView memory v) {
        Order memory order = _orders[uint(trustOrder.orderIndex)];
        v = TrustOrderView(
            // Index of this TrustOrder
            uint32(index),
            // Owner of this order
            _accounts[order.owner],
            // Index of target Order
            trustOrder.orderIndex,
            // Index of target channel, support eth(0), btc(1) and bnb(2)
            order.channelIndex,
            // Leverage of this order
            order.lever,
            // Orientation of this order, long or short
            order.orientation,

            // Limit price for trigger buy
            CommonLib.decodeFloat(order.basePrice),
            // Stop price for trigger sell
            CommonLib.decodeFloat(trustOrder.stopProfitPrice),
            CommonLib.decodeFloat(trustOrder.stopLossPrice),

            // Balance of nest, 4 decimals
            trustOrder.balance,
            // Service fee, 4 decimals
            trustOrder.fee,
            // Status of order, 0: executed, 1: normal, 2: canceled
            trustOrder.status
        );
    }
}