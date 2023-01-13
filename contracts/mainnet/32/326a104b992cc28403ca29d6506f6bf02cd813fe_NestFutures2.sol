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


// File contracts/interfaces/INestFuturesWithPrice.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Defines methods for Futures
interface INestFuturesWithPrice {
    
    struct FutureView {
        uint index;
        address tokenAddress;
        uint lever;
        bool orientation;
        
        uint balance;
        // Base price
        uint basePrice;
        // Base block
        uint baseBlock;
    }

    /// @dev New future event
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @param index Index of the future
    event New(
        address tokenAddress, 
        uint lever,
        bool orientation,
        uint index
    );

    /// @dev Buy future event
    /// @param index Index of future
    /// @param nestAmount Amount of paid NEST
    /// @param owner The owner of future
    event Buy(
        uint index,
        uint nestAmount,
        address owner
    );

    /// @dev Sell future event
    /// @param index Index of future
    /// @param amount Amount to sell
    /// @param owner The owner of future
    /// @param value Amount of NEST obtained
    event Sell(
        uint index,
        uint amount,
        address owner,
        uint value
    );

    /// @dev Settle future event
    /// @param index Index of future
    /// @param addr Target address
    /// @param sender Address of settler
    /// @param reward Liquidation reward
    event Settle(
        uint index,
        address addr,
        address sender,
        uint reward
    );

    /// @dev List prices
    /// @param pairIndex index of token in channel 0 on NEST Oracle
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return priceArray List of prices, i * 3 + 0 means period, i * 3 + 1 means height, i * 3 + 2 means price
    function listPrice(
        uint pairIndex,
        uint offset, 
        uint count, 
        uint order
    ) external view returns (uint[] memory priceArray);

    /// @dev Returns the current value of target address in the specified future
    /// @param index Index of future
    /// @param oraclePrice Current price from oracle, usd based, 18 decimals
    /// @param addr Target address
    function balanceOf(uint index, uint oraclePrice, address addr) external view returns (uint);

    /// @dev Find the futures of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return futureArray Matched futures
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (FutureView[] memory futureArray);

    /// @dev List futures
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return futureArray List of futures
    function list(uint offset, uint count, uint order) external view returns (FutureView[] memory futureArray);

    // /// @dev Create future
    // /// @param tokenAddress Target token address, 0 means eth
    // /// @param levers Levers of future
    // /// @param orientation true: call, false: put
    // function create(address tokenAddress, uint[] calldata levers, bool orientation) external;

    /// @dev Obtain the number of futures that have been created
    /// @return Number of futures created
    function getFutureCount() external view returns (uint);

    /// @dev Get information of future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @return Information of future
    function getFutureInfo(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) external view returns (FutureView memory);

    /// @dev Buy future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @param nestAmount Amount of paid NEST
    function buy(
        address tokenAddress,
        uint lever,
        bool orientation,
        uint nestAmount
    ) external payable;

    /// @dev Buy future direct
    /// @param index Index of future
    /// @param nestAmount Amount of paid NEST
    function buyDirect(uint index, uint nestAmount) external payable;

    /// @dev Sell future
    /// @param index Index of future
    /// @param amount Amount to sell
    function sell(uint index, uint amount) external payable;

    /// @dev Settle future
    /// @param index Index of future
    /// @param addresses Target addresses
    function settle(uint index, address[] calldata addresses) external payable;
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


// File contracts/NestFuturesWithPrice.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Futures
contract NestFuturesWithPrice is NestFrequentlyUsed, INestFuturesWithPrice {

    /// @dev Future information
    struct FutureInfo {
        // Target token address
        address tokenAddress; 
        // Lever of future
        uint32 lever;
        // true: call, false: put
        bool orientation;

        // Token index in _tokenConfigs
        uint16 tokenIndex;
        
        // Account mapping
        mapping(address=>Account) accounts;
    }

    /// @dev Account information
    struct Account {
        // Amount of margin
        uint128 balance;
        // Base price
        uint64 basePrice;
        // Base block
        uint32 baseBlock;
    }

    // Token configuration
    struct TokenConfig {
        // The channelId for call nest price
        uint16 channelId;
        // The pairIndex for call nest price
        uint16 pairIndex;

        // SigmaSQ for token
        uint64 sigmaSQ;
        // MIU_LONG for token
        uint64 miuLong;
        // MIU_SHORT for token
        uint64 miuShort;
    }

    // Mapping from composite key to future index
    mapping(uint=>uint) _futureMapping;

    // Future array, element of 0 is place holder
    FutureInfo[] _futures;

    // token to index mapping, address=>tokenConfigIndex + 1
    mapping(address=>uint) _tokenMapping;

    // Token configs
    TokenConfig[] _tokenConfigs;

    // price array, period(16)|height(48)|price3(64)|price2(64)|price1(64)
    uint[] _prices;

    constructor() {
    }

    // /// @dev To support open-zeppelin/upgrades
    // /// @param governance INestGovernance implementation contract address
    // function initialize(address governance) public override {
    //     super.initialize(governance);
    //     _futures.push();
    // }

    /// @dev Direct post price
    /// @param period Term of validity
    // @param equivalents Price array, one to one with pairs
    function directPost(uint period, uint[3] calldata /*equivalents*/) external {
        require(msg.sender == DIRECT_POSTER, "NFWP:not directPoster");

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
        _prices.push(period);
    }

    /// @dev List prices
    /// @param pairIndex index of token in channel 0 on NEST Oracle
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return priceArray List of prices, i * 3 + 0 means period, i * 3 + 1 means height, i * 3 + 2 means price
    function listPrice(
        uint pairIndex,
        uint offset, 
        uint count, 
        uint order
    ) external view override returns (uint[] memory priceArray) {
        // Load prices
        uint[] storage prices = _prices;
        // Create result array
        priceArray = new uint[](count * 3);
        uint length = prices.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                (priceArray[i], priceArray[i + 1], priceArray[i + 2]) = _decodePrice(prices[--index], pairIndex);
                i += 3;
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
                (priceArray[i], priceArray[i + 1], priceArray[i + 2]) = _decodePrice(prices[index++], pairIndex);
                i += 3;
            }
        }
    }

    // /// @dev Find the price at block number
    // /// @param pairIndex index of token in channel 0 on NEST Oracle
    // /// @param height Destination block number
    // /// @return blockNumber The block number of price
    // /// @return price The token price. (1eth equivalent to (price) token)
    // function findPrice(
    //     uint pairIndex,
    //     uint height
    // ) external view returns (uint blockNumber, uint price) {

    //     uint length = _prices.length;
    //     uint index = 0;
    //     uint sheetHeight;
    //     {
    //         // If there is no sheet in this channel, length is 0, length - 1 will overflow,
    //         uint right = length - 1;
    //         uint left = 0;
    //         // Find the index use Binary Search
    //         while (left < right) {

    //             index = (left + right) >> 1;
    //             sheetHeight = (_prices[index] >> 192) & 0xFFFFFFFFFFFF;
    //             if (height > sheetHeight) {
    //                 left = ++index;
    //             } else if (height < sheetHeight) {
    //                 // When index = 0, this statement will have an underflow exception, which usually 
    //                 // indicates that the effective block height passed during the call is lower than 
    //                 // the block height of the first quotation
    //                 right = --index;
    //             } else {
    //                 break;
    //             }
    //         }
    //     }

    //     while (((_prices[index] >> 192) & 0xFFFFFFFFFFFF) > height) {
    //         --index;
    //     }

    //     (,blockNumber, price) = _decodePrice(_prices[index], pairIndex);
    // }

    /// @dev Register token configuration
    /// @param tokenAddress Target token address, 0 means eth
    /// @param tokenConfig token configuration
    function register(address tokenAddress, TokenConfig calldata tokenConfig) external onlyGovernance {
        // Get registered tokenIndex by tokenAddress
        uint index = _tokenMapping[tokenAddress];
        
        // index == 0 means token not registered, add
        if (index == 0) {
            // Add tokenConfig to array
            _tokenConfigs.push(tokenConfig);
            // Record index + 1
            index = _tokenConfigs.length;
            require(index < 0x10000, "NF:too much tokenConfigs");
            _tokenMapping[tokenAddress] = index;
        } else {
            // Update tokenConfig
            _tokenConfigs[index - 1] = tokenConfig;
        }
    }

    /// @dev Returns the current value of target address in the specified future
    /// @param index Index of future
    /// @param oraclePrice Current price from oracle, usd based, 18 decimals
    /// @param addr Target address
    function balanceOf(uint index, uint oraclePrice, address addr) external view override returns (uint) {
        FutureInfo storage fi = _futures[index];
        Account memory account = fi.accounts[addr];
        return _balanceOf(
            _tokenConfigs[fi.tokenIndex],
            uint(account.balance), 
            CommonLib.decodeFloat(account.basePrice), 
            uint(account.baseBlock),
            oraclePrice, 
            fi.orientation, 
            uint(fi.lever)
        );
    }

    /// @dev Find the futures of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return futureArray Matched futures
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view override returns (FutureView[] memory futureArray) {
        futureArray = new FutureView[](count);
        // Calculate search region
        FutureInfo[] storage futures = _futures;

        // Loop from start to end
        uint end = 0;
        // start is 0 means Loop from the last item
        if (start == 0) {
            start = futures.length;
        }
        // start > maxFindCount, so end is not 0
        if (start > maxFindCount) {
            end = start - maxFindCount;
        }
        
        // Loop lookup to write qualified records to the buffer
        for (uint index = 0; index < count && start > end;) {
            FutureInfo storage fi = futures[--start];
            if (uint(fi.accounts[owner].balance) > 0) {
                futureArray[index++] = _toFutureView(fi, start, owner);
            }
        }
    }

    /// @dev List futures
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return futureArray List of futures
    function list(
        uint offset, 
        uint count, 
        uint order
    ) external view override returns (FutureView[] memory futureArray) {
        // Load futures
        FutureInfo[] storage futures = _futures;
        // Create result array
        futureArray = new FutureView[](count);
        uint length = futures.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                FutureInfo storage fi = futures[--index];
                futureArray[i++] = _toFutureView(fi, index, msg.sender);
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
                futureArray[i++] = _toFutureView(futures[index], index, msg.sender);
                ++index;
            }
        }
    }

    /// @dev Obtain the number of futures that have been created
    /// @return Number of futures created
    function getFutureCount() external view override returns (uint) {
        return _futures.length;
    }

    /// @dev Get information of future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @return Information of future
    function getFutureInfo(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) external view override returns (FutureView memory) {
        uint index = _futureMapping[_getKey(tokenAddress, lever, orientation)];
        return _toFutureView(_futures[index], index, msg.sender);
    }

    // @dev Buy future
    // @param tokenAddress Target token address, 0 means eth
    // @param lever Lever of future
    // @param orientation true: call, false: put
    // @param nestAmount Amount of paid NEST
    function buy(
        address,// tokenAddress,
        uint,// lever,
        bool,// orientation,
        uint// nestAmount
    ) external payable override {
        revert("NF:please use buy2");
        // return buyDirect(_futureMapping[_getKey(tokenAddress, lever, orientation)], nestAmount);
    }

    // @dev Buy future direct
    // @param index Index of future
    // @param nestAmount Amount of paid NEST
    function buyDirect(uint /*index*/, uint /*nestAmount*/) public payable override {
        revert("NF:please use buy2");
        // require(index != 0, "NF:not exist");
        // require(nestAmount >= 50 ether, "NF:at least 50 NEST");

        // // 1. Transfer NEST from user
        // TransferHelper.safeTransferFrom(
        //     NEST_TOKEN_ADDRESS, 
        //     msg.sender, 
        //     NEST_VAULT_ADDRESS, 
        //     nestAmount * (1 ether + CommonLib.FEE_RATE) / 1 ether
        // );

        // FutureInfo storage fi = _futures[index];
        // bool orientation = fi.orientation;
        
        // // 2. Query oracle price
        // TokenConfig memory tokenConfig = _tokenConfigs[uint(fi.tokenIndex)];
        // uint oraclePrice = _queryPrice(tokenConfig);

        // // 3. Merger price
        // Account memory account = fi.accounts[msg.sender];
        // uint basePrice = CommonLib.decodeFloat(account.basePrice);
        // uint balance = uint(account.balance);
        // uint newPrice = oraclePrice;
        // if (uint(account.baseBlock) > 0) {
        //     newPrice = (balance + nestAmount) * oraclePrice * basePrice / (
        //         basePrice * nestAmount + (balance << 64) * oraclePrice / _expMiuT(
        //             uint(orientation ? tokenConfig.miuLong : tokenConfig.miuShort), 
        //             uint(account.baseBlock)
        //         )
        //     );
        // }
        
        // // 4. Update account
        // account.balance = _toUInt128(balance + nestAmount);
        // account.basePrice = CommonLib.encodeFloat64(newPrice);
        // account.baseBlock = uint32(block.number);
        // fi.accounts[msg.sender] = account;

        // // emit Buy event
        // emit Buy(index, nestAmount, msg.sender);
    }

    /// @dev Sell future
    /// @param index Index of future
    /// @param amount Amount to sell
    function sell(uint index, uint amount) external payable override {
        require(index != 0, "NF:not exist");
        
        // 1. Load the future
        FutureInfo storage fi = _futures[index];
        uint lever = uint(fi.lever);

        // 2. Query oracle price
        TokenConfig memory tokenConfig = _tokenConfigs[uint(fi.tokenIndex)];
        uint oraclePrice = _queryPrice(tokenConfig);

        // 3. Update account
        Account memory account = fi.accounts[msg.sender];
        uint basePrice = CommonLib.decodeFloat(uint(account.basePrice));
        account.balance -= _toUInt128(amount);
        fi.accounts[msg.sender] = account;

        // 4. Transfer NEST to user
        uint value = _balanceOf(
            tokenConfig,
            amount, 
            basePrice, 
            uint(account.baseBlock),
            oraclePrice, 
            fi.orientation, 
            lever
        );

        uint fee = amount * lever * oraclePrice / basePrice * CommonLib.FEE_RATE / 1 ether;
        // If value grater than fee, deduct and transfer NEST to owner
        if (value > fee) {
            INestVault(NEST_VAULT_ADDRESS).transferTo(msg.sender, value - fee);
        } 

        // emit Sell event
        emit Sell(index, amount, msg.sender, value);
    }

    /// @dev Settle future
    /// @param index Index of future
    /// @param addresses Target addresses
    function settle(uint index, address[] calldata addresses) external payable override {

        require(index != 0, "NF:not exist");

        // 1. Load the future
        FutureInfo storage fi = _futures[index];
        uint lever = uint(fi.lever);
        require(lever > 1, "NF:lever must greater than 1");

        bool orientation = fi.orientation;
            
        // 2. Query oracle price
        TokenConfig memory tokenConfig = _tokenConfigs[uint(fi.tokenIndex)];
        uint oraclePrice = _queryPrice(tokenConfig);

        // 3. Loop and settle
        uint reward = 0;
        for (uint i = addresses.length; i > 0;) {
            address acc = addresses[--i];

            // 4. Update account
            Account memory account = fi.accounts[acc];
            if (uint(account.balance) > 0) {
                uint balance = _balanceOf(
                    tokenConfig,
                    uint(account.balance), 
                    CommonLib.decodeFloat(account.basePrice), 
                    uint(account.baseBlock),
                    oraclePrice, 
                    orientation, 
                    lever
                );

                // 5. Settle logic
                // lever is great than 1, and balance less than a regular value, can be liquidated
                // the regular value is: Max(balance * lever * 2%, MIN_VALUE)
                if (balance < CommonLib.MIN_FUTURE_VALUE || balance < uint(account.balance) * lever / 50) {
                    fi.accounts[acc] = Account(uint128(0), uint64(0), uint32(0));
                    reward += balance;
                    emit Settle(index, acc, msg.sender, balance);
                }
            }
        }

        // 6. Transfer NEST to user
        if (reward > 0) {
            INestVault(NEST_VAULT_ADDRESS).transferTo(msg.sender, reward);
        }
    }

    // Compose key by tokenAddress, lever and orientation
    function _getKey(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) private pure returns (uint) {
        //return keccak256(abi.encodePacked(tokenAddress, lever, orientation));
        require(lever < 0x100000000, "NF:lever too large");
        return (uint(uint160(tokenAddress)) << 96) | (lever << 8) | (orientation ? 1 : 0);
    }
    
    // Query price
    function _queryPrice(TokenConfig memory tokenConfig) internal view returns (uint oraclePrice) {
        // Query price from oracle
        (uint period, uint height, uint price) = _decodePrice(_prices[_prices.length - 1], uint(tokenConfig.pairIndex));
        require(block.number < height + period, "NFWP:price expired");
        oraclePrice = CommonLib.toUSDTPrice(price);
    }

    // Convert uint to uint128
    function _toUInt128(uint value) private pure returns (uint128) {
        require(value < 0x100000000000000000000000000000000, "NF:can't convert to uint128");
        return uint128(value);
    }

    // Convert uint to int128
    function _toInt128(uint v) private pure returns (int128) {
        require(v < 0x80000000000000000000000000000000, "NF:can't convert to int128");
        return int128(int(v));
    }

    // Convert int128 to uint
    function _toUInt(int128 v) private pure returns (uint) {
        require(v >= 0, "NF:can't convert to uint");
        return uint(int(v));
    }
    
    // Calculate net worth
    function _balanceOf(
        TokenConfig memory tokenConfig,
        uint balance,
        uint basePrice,
        uint baseBlock,
        uint oraclePrice, 
        bool ORIENTATION, 
        uint LEVER
    ) internal view returns (uint) {

        if (balance > 0) {
            uint left;
            uint right;
            // Call
            if (ORIENTATION) {
                left = balance + (LEVER << 64) * balance * oraclePrice / basePrice
                        / _expMiuT(uint(tokenConfig.miuLong), baseBlock);
                right = balance * LEVER;
            } 
            // Put
            else {
                left = balance * (1 + LEVER);
                right = (LEVER << 64) * balance * oraclePrice / basePrice 
                        / _expMiuT(uint(tokenConfig.miuShort), baseBlock);
            }

            if (left > right) {
                balance = left - right;
            } else {
                balance = 0;
            }
        }

        return balance;
    }

    // Calculate e^μT
    function _expMiuT(uint miu, uint baseBlock) internal view returns (uint) {
        // return _toUInt(ABDKMath64x64.exp(
        //     _toInt128((orientation ? MIU_LONG : MIU_SHORT) * (block.number - baseBlock) * BLOCK_TIME)
        // ));

        // Using approximate algorithm: x*(1+rt)
        return miu * (block.number - baseBlock) * CommonLib.BLOCK_TIME / 1000 + 0x10000000000000000;
    }

    // Convert FutureInfo to FutureView
    function _toFutureView(FutureInfo storage fi, uint index, address owner) private view returns (FutureView memory) {
        Account memory account = fi.accounts[owner];
        return FutureView(
            index,
            fi.tokenAddress,
            uint(fi.lever),
            fi.orientation,
            uint(account.balance),
            CommonLib.decodeFloat(account.basePrice),
            uint(account.baseBlock)
        );
    }

    // Decode composed price
    function _decodePrice(uint rawPrice, uint pairIndex) private pure returns (uint period, uint height, uint price) {
        return (
            rawPrice >> 240,
            (rawPrice >> 192) & 0xFFFFFFFFFFFF,
            CommonLib.decodeFloat(uint64(rawPrice >> (pairIndex << 6)))
        );
    }
}


// File contracts/NestFutures2.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Nest futures without merger
contract NestFutures2 is NestFuturesWithPrice, INestFutures2 {

    /// @dev Order structure
    struct Order {
        // Address index of owner
        uint32 owner;
        // Base price of this order, encoded with encodeFloat56()
        uint56 basePrice;
        // Balance of this order, 4 decimals
        uint48 balance;
        // Open block of this order
        uint32 baseBlock;
        // Index of target token, support eth and btc
        uint16 tokenIndex;
        // Leverage of this order
        uint8 lever;
        // Orientation of this order, long or short
        bool orientation;
        // Stop price, for stop order, encoded with encodeFloat56()
        uint56 stopPrice;
    }

    // Array of orders
    Order[] _orders;

    // Registered account address mapping
    mapping(address=>uint) _accountMapping;

    // Registered accounts
    address[] _accounts;

	address constant FUTURES_PROXY_ADDRESS = 0x8b2A11F6C5cEbB00793dCE502a9B08741eDBcb96;
    address constant MAINTAINS_ADDRESS = 0x029972C516c4F248c5B066DA07DbAC955bbb5E7F;

    constructor() {
    }

    modifier onlyProxy {
        require(msg.sender == FUTURES_PROXY_ADDRESS, "NF:not futures proxy");
        _;
    }

    // TODO: Don't forget init after upgrade
    // Initialize account array, execute once
    function init() external {
        require(_accounts.length == 0, "NF:initialized");
        _accounts.push();
    }

    /// @dev Returns the current value of target order
    /// @param index Index of order
    /// @param oraclePrice Current price from oracle, usd based, 18 decimals
    function valueOf2(uint index, uint oraclePrice) external view override returns (uint) {
        // Load order
        Order memory order = _orders[index];

        // Newest value of order, no service charge deducted
        return _balanceOf(
            // tokenConfig
            _tokenConfigs[uint(order.tokenIndex)],
            // balance
            uint(order.balance) * CommonLib.NEST_UNIT, 
            // basePrice
            CommonLib.decodeFloat(uint(order.basePrice)), 
            // baseBlock
            uint(order.baseBlock),
            // oraclePrice
            oraclePrice, 
            // ORIENTATION
            order.orientation, 
            // LEVER
            uint(order.lever)
        );
    }

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
    ) external view override returns (OrderView[] memory orderArray) {
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

    /// @dev List orders
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return orderArray List of orders
    function list2(uint offset, uint count, uint order) external view override returns (OrderView[] memory orderArray) {
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

    /// @dev Buy futures
    /// @param tokenIndex Index of token
    /// @param lever Lever of order
    /// @param orientation true: long, false: short
    /// @param amount Amount of paid NEST, 4 decimals
    /// @param stopPrice Stop price for trigger sell, 0 means not stop order
    function buy2(
        uint16 tokenIndex, 
        uint8 lever, 
        bool orientation, 
        uint amount, 
        uint stopPrice
    ) external payable override {
        require(amount > CommonLib.FUTURES_NEST_LB && amount < 0x1000000000000, "NF:amount invalid");
        require(lever > 0 && lever < 21, "NF:lever not allowed");

        // 1. Emit event
        emit Buy2(_orders.length, amount, msg.sender);

        // 2. Create order
        _orders.push(Order(
            // owner
            uint32(_addressIndex(msg.sender)),
            // basePrice
            // Query oraclePrice
            CommonLib.encodeFloat56(_queryPrice(_tokenConfigs[tokenIndex])),
            // balance
            uint48(amount),
            // baseBlock
            uint32(block.number),
            // tokenIndex
            tokenIndex,
            // lever
            lever,
            // orientation
            orientation,
            // stopPrice
            stopPrice > 0 ? CommonLib.encodeFloat56(stopPrice) : uint56(0)
        ));

        // 4. Transfer NEST from user
        TransferHelper.safeTransferFrom(
            NEST_TOKEN_ADDRESS, 
            msg.sender, 
            NEST_VAULT_ADDRESS, 
            amount * CommonLib.NEST_UNIT * (1 ether + CommonLib.FEE_RATE * uint(lever)) / 1 ether
        );
    }

    /// @dev Set stop price for stop order
    /// @param index Index of order
    /// @param stopPrice Stop price for trigger sell
    function setStopPrice(uint index, uint stopPrice) external {
        require(msg.sender == _accounts[_orders[index].owner], "NF:not owner");
        _orders[index].stopPrice = CommonLib.encodeFloat56(stopPrice);
    }

    /// @dev Append buy
    /// @param index Index of future
    /// @param amount Amount of paid NEST
    function add2(uint index, uint amount) external payable override {
        require(amount > CommonLib.FUTURES_NEST_LB, "NF:amount invalid");

        // 1. Load the order
        Order memory order = _orders[index];

        uint basePrice = CommonLib.decodeFloat(order.basePrice);
        uint balance = uint(order.balance);
        uint newBalance = balance + amount;

        require(balance > 0, "NF:order cleared");
        require(newBalance < 0x1000000000000, "NF:balance too big");
        require(msg.sender == _accounts[uint(order.owner)], "NF:not owner");

        // 2. Query oracle price
        TokenConfig memory tokenConfig = _tokenConfigs[uint(order.tokenIndex)];
        uint oraclePrice = _queryPrice(tokenConfig);

        // 3. Update order
        // Merger price
        order.basePrice = CommonLib.encodeFloat56(newBalance * oraclePrice * basePrice / (
            basePrice * amount + (balance << 64) * oraclePrice / _expMiuT(
                uint(order.orientation ? tokenConfig.miuLong : tokenConfig.miuShort), 
                uint(order.baseBlock)
            )
        ));
        order.balance = uint48(newBalance);
        order.baseBlock = uint32(block.number);
        _orders[index] = order;

        // 4. Transfer NEST from user
        TransferHelper.safeTransferFrom(
            NEST_TOKEN_ADDRESS, 
            msg.sender, 
            NEST_VAULT_ADDRESS, 
            amount * CommonLib.NEST_UNIT * (1 ether + CommonLib.FEE_RATE * uint(order.lever)) / 1 ether
        );

        // 5. Emit event
        emit Buy2(index, amount, msg.sender);
    }

    /// @dev Sell order
    /// @param index Index of order
    function sell2(uint index) external payable override {
        // 1. Load the order
        Order memory order = _orders[index];
        
        require(msg.sender == _accounts[uint(order.owner)], "NF:not owner");

        uint basePrice = CommonLib.decodeFloat(uint(order.basePrice));
        uint balance = uint(order.balance);
        uint lever = uint(order.lever);

        // 2. Query oracle price
        TokenConfig memory tokenConfig = _tokenConfigs[uint(order.tokenIndex)];
        uint oraclePrice = _queryPrice(tokenConfig);

        // 3. Update order
        order.balance = uint48(0);
        _orders[index] = order;

        // 4. Transfer NEST to user
        uint value = _balanceOf(
            // tokenConfig
            tokenConfig,
            // balance
            balance * CommonLib.NEST_UNIT, 
            // basePrice
            basePrice, 
            // baseBlock
            uint(order.baseBlock),
            // oraclePrice
            oraclePrice, 
            // ORIENTATION
            order.orientation, 
            // LEVER
            lever
        );
        
        uint fee = balance * CommonLib.NEST_UNIT * lever * oraclePrice / basePrice * CommonLib.FEE_RATE / 1 ether;
        // If value grater than fee, deduct and transfer NEST to owner
        if (value > fee) {
            INestVault(NEST_VAULT_ADDRESS).transferTo(msg.sender, value - fee);
        }

        // 5. Emit event
        emit Sell2(index, balance, msg.sender, value);
    }

    /// @dev Liquidate order
    /// @param indices Target order indices
    function liquidate2(uint[] calldata indices) external payable override {
        uint reward = 0;
        uint oraclePrice = 0;
        uint tokenIndex = 0x10000;
        TokenConfig memory tokenConfig;
        
        // 1. Loop and liquidate
        for (uint i = indices.length; i > 0;) {
            uint index = indices[--i];
            Order memory order = _orders[index];

            uint lever = uint(order.lever);
            uint balance = uint(order.balance) * CommonLib.NEST_UNIT;
            if (lever > 1 && balance > 0) {
                // If tokenIndex is not same with previous, need load new tokenConfig and query oracle
                // At first, tokenIndex is 0x10000, this is impossible the same with current tokenIndex
                if (tokenIndex != uint(order.tokenIndex)) {
                    tokenIndex = uint(order.tokenIndex);
                    tokenConfig = _tokenConfigs[tokenIndex];
                    oraclePrice = _queryPrice(tokenConfig);
                    //require(oraclePrice > 0, "NF:price error");
                }

                // 3. Calculate order value
                uint basePrice = CommonLib.decodeFloat(order.basePrice);
                uint value = _balanceOf(
                    // tokenConfig
                    tokenConfig,
                    // balance
                    balance, 
                    // basePrice
                    basePrice, 
                    // baseBlock
                    uint(order.baseBlock),
                    // oraclePrice
                    oraclePrice, 
                    // ORIENTATION
                    order.orientation, 
                    // LEVER
                    lever
                );

                // 4. Liquidate logic
                // lever is great than 1, and balance less than a regular value, can be liquidated
                // the regular value is: Max(M0 * L * St / S0 * c, a)
                if (value < CommonLib.MIN_FUTURE_VALUE || 
                    value < balance * lever * oraclePrice / basePrice * CommonLib.FEE_RATE / 1 ether) {

                    // Clear all data of order, use this code next time
                    // assembly {
                    //     mstore(0, _orders.slot)
                    //     sstore(add(keccak256(0, 0x20), index), 0)
                    // }
                    
                    // Clear balance
                    order.balance = uint48(0);
                    // Clear baseBlock
                    order.baseBlock = uint32(0);
                    // Update order
                    _orders[index] = order;

                    // Add reward
                    reward += value;

                    // Emit liquidate event
                    emit Liquidate2(index, msg.sender, value);
                }
            }
        }

        // 6. Transfer NEST to user
        if (reward > 0) {
            INestVault(NEST_VAULT_ADDRESS).transferTo(msg.sender, reward);
        }
    }

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
    ) external payable onlyProxy {
        // 1. Emit event
        emit Buy2(_orders.length, uint(amount), owner);

        // 2. Create order
        _orders.push(Order(
            // owner
            uint32(_addressIndex(owner)),
            // basePrice
            // Query oraclePrice
            CommonLib.encodeFloat56(_queryPrice(_tokenConfigs[tokenIndex])),
            // balance
            amount,
            // baseBlock
            uint32(block.number),
            // tokenIndex
            tokenIndex,
            // lever
            lever,
            // orientation
            orientation,
            // stopPrice
            stopPrice
        ));
    }

    /// @dev Execute stop order, only for maintains account
    /// @param indices Array of futures order index
    function executeStopOrder(uint[] calldata indices) external payable override {
        // Only for maintains address
        require(msg.sender == MAINTAINS_ADDRESS, "NFP:not maintains");

        uint executeFee = 0;
        uint oraclePrice = 0;
        uint tokenIndex = 0x10000;
        TokenConfig memory tokenConfig;

        for (uint i = indices.length; i > 0;) {
            uint index = indices[--i];
            // 1. Load the order
            Order memory order = _orders[index];
            require(order.stopPrice > 0, "NF:not stop order");

            uint balance = uint(order.balance);
            if (balance > 0) {
                // 2. Query oraclePrice
                // If tokenIndex is not same with previous, need load new tokenConfig and query oracle
                // At first, tokenIndex is 0x10000, this is impossible the same with current tokenIndex
                if (tokenIndex != uint(order.tokenIndex)) {
                    tokenIndex = uint(order.tokenIndex);
                    tokenConfig = _tokenConfigs[tokenIndex];
                    oraclePrice = _queryPrice(tokenConfig);
                    //require(oraclePrice > 0, "NF:price error");
                }

                uint lever = uint(order.lever);
                uint basePrice = CommonLib.decodeFloat(uint(order.basePrice));
                address owner = _accounts[uint(order.owner)];

                // 3. Update account
                order.balance = uint48(0);
                _orders[index] = order;

                // 4. Transfer NEST to user
                uint value = _balanceOf(
                    // tokenConfig
                    tokenConfig,
                    // balance
                    balance * CommonLib.NEST_UNIT, 
                    // basePrice
                    basePrice, 
                    // baseBlock
                    uint(order.baseBlock),
                    // oraclePrice
                    oraclePrice, 
                    // ORIENTATION
                    order.orientation, 
                    // LEVER
                    uint(order.lever)
                );

                uint fee = balance 
                         * CommonLib.NEST_UNIT 
                         * lever 
                         * oraclePrice 
                         / basePrice 
                         * CommonLib.FEE_RATE 
                         / 1 ether;

                // 5. Transfer NEST to owner
                // Newest value of order is greater than fee + EXECUTE_FEE, deduct and transfer NEST to owner
                if (value > fee + CommonLib.EXECUTE_FEE_NEST) {
                    INestVault(NEST_VAULT_ADDRESS).transferTo(owner, value - fee - CommonLib.EXECUTE_FEE_NEST);
                }
                executeFee += CommonLib.EXECUTE_FEE_NEST;

                // 6. Emit event
                emit Sell2(index, balance, owner, value);
            }
        }

        // Transfer EXECUTE_FEE to proxy address
        INestVault(NEST_VAULT_ADDRESS).transferTo(FUTURES_PROXY_ADDRESS, executeFee);
    }

    /// @dev Gets the index number of the specified address. If it does not exist, register
    /// @param addr Destination address
    /// @return The index number of the specified address
    function _addressIndex(address addr) private returns (uint) {
        uint index = _accountMapping[addr];
        if (index == 0) {
            // If it exceeds the maximum number that 32 bits can store, you can't continue to register a new account.
            // If you need to support a new account, you need to update the contract
            require((_accountMapping[addr] = index = _accounts.length) < 0x100000000, "NO:!accounts");
            _accounts.push(addr);
        }

        return index;
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
            // tokenIndex
            order.tokenIndex,
            // baseBlock
            order.baseBlock,
            // lever
            order.lever,
            // orientation
            order.orientation,
            // basePrice
            CommonLib.decodeFloat(order.basePrice),
            // stopPrice
            CommonLib.decodeFloat(order.stopPrice)
        );
    }
}