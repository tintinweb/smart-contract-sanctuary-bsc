/**
 *Submitted for verification at BscScan.com on 2023-01-13
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
    uint constant MIN_FUTURE_VALUE = 10 ether;

    // Unit of nest, 4 decimals
    uint constant NEST_UNIT = 0.0001 ether;

    // Min amount of buy futures, amount >= 50 nest
    uint constant FUTURES_NEST_LB = 499999;

    // Service fee for buy, sell, add and liquidate
    uint constant FEE_RATE = 0.002 ether;
    
    // Fee for execute limit order or stop order, 15 nest
    uint constant EXECUTE_FEE = 150000;

    // Fee for execute limit order or stop order in nest values, 18 decimals
    uint constant EXECUTE_FEE_NEST = EXECUTE_FEE * NEST_UNIT;

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


// File contracts/interfaces/INestFutures2.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Defines methods for Futures
interface INestFutures2 {

    /// @dev Order for view methods
    struct OrderView {
        // Index of this order
        uint32 index;
        // Owner of this order
        address owner;
        // Balance of this order, 4 decimals
        uint48 balance;
        // Index of target token, support eth and btc
        uint16 tokenIndex;
        // Open block of this order
        uint32 baseBlock;
        // Leverage of this order
        uint8 lever;
        // Orientation of this order, long or short
        bool orientation;
        // Base price of this order
        uint basePrice;
        // Stop price, for stop order
        uint stopPrice;
    }
    
    /// @dev Buy order event
    /// @param index Index of order
    /// @param nestAmount Amount of paid NEST, 4 decimals
    /// @param owner The owner of order
    event Buy2(
        uint index,
        uint nestAmount,
        address owner
    );

    /// @dev Sell order event
    /// @param index Index of order
    /// @param amount Amount to sell, 4 decimals
    /// @param owner The owner of order
    /// @param value Amount of NEST obtained
    event Sell2(
        uint index,
        uint amount,
        address owner,
        uint value
    );

    /// @dev Liquidate order event
    /// @param index Index of order
    /// @param sender Address of sender
    /// @param reward Liquidation reward
    event Liquidate2(
        uint index,
        address sender,
        uint reward
    );

    /// @dev Returns the current value of target order
    /// @param index Index of order
    /// @param oraclePrice Current price from oracle, usd based, 18 decimals
    function valueOf2(uint index, uint oraclePrice) external view returns (uint);

    /// @dev Find the orders of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return orderArray Matched orders
    function find2(
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
    function list2(uint offset, uint count, uint order) external view returns (OrderView[] memory orderArray);

    /// @dev Buy futures
    /// @param tokenIndex Index of token
    /// @param lever Lever of order
    /// @param orientation true: long, false: short
    /// @param amount Amount of paid NEST, 4 decimals
    /// @param stopPrice Stop price for trigger sell, 0 means not stop order
    function buy2(uint16 tokenIndex, uint8 lever, bool orientation, uint amount, uint stopPrice) external payable;

    /// @dev Set stop price for stop order
    /// @param index Index of order
    /// @param stopPrice Stop price for trigger sell
    function setStopPrice(uint index, uint stopPrice) external;

    /// @dev Append buy
    /// @param index Index of future
    /// @param amount Amount of paid NEST
    function add2(uint index, uint amount) external payable;

    /// @dev Sell order
    /// @param index Index of order
    function sell2(uint index) external payable;

    /// @dev Liquidate order
    /// @param indices Target order indices
    function liquidate2(uint[] calldata indices) external payable;
    
    /// @dev Buy from NestFuturesPRoxy
    /// @param tokenIndex Index of token
    /// @param lever Lever of order
    /// @param orientation true: call, false: put
    /// @param amount Amount of paid NEST, 4 decimals
    /// @param stopPrice Stop price for stop order
    function proxyBuy2(
        address owner, 
        uint16 tokenIndex, 
        uint8 lever, 
        bool orientation, 
        uint48 amount,
        uint56 stopPrice
    ) external payable;

    /// @dev Execute stop order, only for maintains account
    /// @param indices Array of futures order index
    function executeStopOrder(uint[] calldata indices) external payable;
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
//     address CYBER_INK_ADDRESS;
//     // Address of direct poster
//     address DIRECT_POSTER;  // 0x06Ca5C8eFf273009C94D963e0AB8A8B9b09082eF;

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
//         DIRECT_POSTER = INestGovernance(newGovernance).checkAddress("nest.app.directPoster");
//         CYBER_INK_ADDRESS = INestGovernance(newGovernance).checkAddress("nest.app.cyberink");
//     }
// }


// File contracts/NestFuturesProxy.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Futures proxy
contract NestFuturesProxy is NestFrequentlyUsed {
    
    // Status of limit order: executed
    uint constant S_EXECUTED = 0;
    // Status of limit order: normal
    uint constant S_NORMAL = 1;
    // Status of limit order: canceled
    uint constant S_CANCELED = 2;

    // Limit order
    struct LimitOrder {
        // Owner of this order
        address owner;
        // Limit price for trigger buy, encode by encodeFloat56()
        uint56 limitPrice;
        // Index of target token, support eth and btc
        uint16 tokenIndex;
        // Leverage of this order
        uint8 lever;
        // Orientation of this order, long or short
        bool orientation;

        // Balance of nest, 4 decimals
        uint48 balance;
        // Service fee, 4 decimals
        uint48 fee;
        // Limit order fee, 4 decimals
        uint48 limitFee;
        // Stop price for trigger sell, encode by encodeFloat56()
        uint56 stopPrice;

        // 0: executed, 1: normal, 2: canceled
        uint8 status;
    }

    /// @dev Limit order information for view methods
    struct LimitOrderView {
        // Index of this order
        uint32 index;
        // Owner of this order
        address owner;
        // Index of target token, support eth and btc
        uint16 tokenIndex;
        // Leverage of this order
        uint8 lever;
        // Orientation of this order, long or short
        bool orientation;

        // Limit price for trigger buy
        uint limitPrice;
        // Stop price for trigger sell
        uint stopPrice;

        // Balance of nest, 4 decimals
        uint48 balance;
        // Service fee, 4 decimals
        uint48 fee;
        // Limit order fee, 4 decimals
        uint48 limitFee;
        // Status of order, 0: executed, 1: normal, 2: canceled
        uint8 status;
    }

    // Array of limit orders
    LimitOrder[] _limitOrders;

    address constant NEST_FUTURES_ADDRESS = 0x8e32C33814271bD64D5138bE9d47Cd55025074CD;
    address constant MAINTAINS_ADDRESS = 0x029972C516c4F248c5B066DA07DbAC955bbb5E7F;

    modifier onlyMaintains {
        require(msg.sender == MAINTAINS_ADDRESS, "NFP:not maintains");
        _;
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
    ) external view returns (LimitOrderView[] memory orderArray) {
        orderArray = new LimitOrderView[](count);
        // Calculate search region
        LimitOrder[] storage orders = _limitOrders;

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
        for (uint index = 0; index < count && start > end;) {
            LimitOrder memory order = orders[--start];
            if (order.owner == owner) {
                orderArray[index++] = _toOrderView(order, start);
            }
        }
    }

    /// @dev List orders
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return orderArray List of orders
    function list(
        uint offset, 
        uint count, 
        uint order
    ) external view returns (LimitOrderView[] memory orderArray) {
        // Load orders
        LimitOrder[] storage orders = _limitOrders;
        // Create result array
        orderArray = new LimitOrderView[](count);
        uint length = orders.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                LimitOrder memory o = orders[--index];
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

    /// @dev Create limit order, for everyone
    /// @param tokenIndex Index of target token, support eth and btc
    /// @param lever Leverage of this order
    /// @param orientation Orientation of this order, long or short
    /// @param amount Amount of buy order
    /// @param limitPrice Limit price for trigger buy
    /// @param stopPrice If not 0, will open a stop order
    function newLimitOrder(
        uint16 tokenIndex, 
        uint8 lever, 
        bool orientation, 
        uint amount, 
        uint limitPrice,
        uint stopPrice
    ) external {
        // 1. Check arguments
        require(amount > CommonLib.FUTURES_NEST_LB && amount < 0x1000000000000, "NF:amount invalid");
        require(lever > 0 && lever < 21, "NF:lever not allowed");
        
        // 2. Service fee, 4 decimals
        uint fee = amount * CommonLib.FEE_RATE * uint(lever) / 1 ether;

        // 3. Create limit order
        _limitOrders.push(LimitOrder(
            // owner
            msg.sender,
            // limitPrice
            CommonLib.encodeFloat56(limitPrice),
            // tokenIndex
            tokenIndex,
            // lever
            lever,
            // orientation
            orientation,

            // balance
            uint48(amount),
            // fee
            uint48(fee),
            // limitFee
            uint48(CommonLib.EXECUTE_FEE),
            // stopPrice
            stopPrice > 0 ? CommonLib.encodeFloat56(stopPrice) : uint56(0),

            // status
            uint8(S_NORMAL)
        ));

        // 4. Transfer nest from user to this contract
        TransferHelper.safeTransferFrom(
            NEST_TOKEN_ADDRESS, 
            msg.sender, 
            address(this), 
            (amount + fee + CommonLib.EXECUTE_FEE) * CommonLib.NEST_UNIT
        );
    }

    /// @dev Update limitPrice for limit order
    /// @param index Index of limit order
    /// @param limitPrice Limit price for trigger buy
    function updateLimitOrder(uint index, uint limitPrice) external {
        require(msg.sender == _limitOrders[index].owner, "NFP:not owner");
        _limitOrders[index].limitPrice = CommonLib.encodeFloat56(limitPrice);
    }

    /// @dev Cancel limit order, for everyone
    /// @param index Index of limit order
    function cancelLimitOrder(uint index) external {
        LimitOrder memory order = _limitOrders[index];
        require(msg.sender == order.owner, "NFP:not owner");
        require(uint(order.status) == S_NORMAL, "NFP:order status error");

        order.status = uint8(S_CANCELED);
        _limitOrders[index] = order;

        TransferHelper.safeTransfer(
            NEST_TOKEN_ADDRESS, 
            msg.sender, 
            (uint(order.balance) + uint(order.fee) + uint(order.limitFee)) * CommonLib.NEST_UNIT
        );
    }

    /// @dev Execute limit order, only maintains account
    /// @param indices Array of limit order index
    function executeLimitOrder(uint[] calldata indices) external onlyMaintains {
        uint totalNest = 0;
        // Loop and execute limit orders
        for (uint i = indices.length; i > 0;) {
            // Get order index
            uint index = indices[--i];
            // Load limit order
            LimitOrder memory order = _limitOrders[index];
            // Status of limit order must be S_NORMAL
            if (uint(order.status) == S_NORMAL) {
                // Create futures order by proxy
                INestFutures2(NEST_FUTURES_ADDRESS).proxyBuy2(
                    // owner
                    order.owner, 
                    // tokenIndex
                    order.tokenIndex, 
                    // lever
                    order.lever, 
                    // orientation
                    order.orientation, 
                    // amount
                    order.balance,
                    // stopPrice
                    order.stopPrice
                );

                // Add nest to totalNest
                totalNest += uint(order.balance) + uint(order.fee);
                order.status = uint8(S_EXECUTED);
                _limitOrders[index] = order;
            }
        }

        TransferHelper.safeTransfer(NEST_TOKEN_ADDRESS, NEST_VAULT_ADDRESS, totalNest * CommonLib.NEST_UNIT);
    }

    /// @dev Settle execute fee to MAINTAINS_ADDRESS
    /// @param value Value of total execute fee
    function settleExecuteFee(uint value) external onlyGovernance {
        TransferHelper.safeTransfer(NEST_TOKEN_ADDRESS, MAINTAINS_ADDRESS, value);
    }

    // Convert LimitOrder to LimitOrderView
    function _toOrderView(LimitOrder memory order, uint index) internal pure returns (LimitOrderView memory v) {
        v = LimitOrderView(
            // index
            uint32(index),
            // owner
            order.owner,
            // tokenIndex
            order.tokenIndex,
            // lever
            order.lever,
            // orientation
            order.orientation,
            
            // limitPrice
            CommonLib.decodeFloat(uint(order.limitPrice)),
            // stopPrice
            CommonLib.decodeFloat(uint(order.stopPrice)),

            // balance
            order.balance,
            // fee
            order.fee,
            // limitFee
            order.limitFee,
            // status
            order.status
        );
    }
}