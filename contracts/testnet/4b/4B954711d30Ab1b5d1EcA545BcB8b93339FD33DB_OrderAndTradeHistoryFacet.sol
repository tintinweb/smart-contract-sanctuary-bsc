// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IOrderAndTradeHistory.sol";

contract OrderAndTradeHistoryFacet is IOrderAndTradeHistory {

    function getOrderAndTradeHistory(
        address user, uint start, uint8 length
    ) external view override returns (OrderAndTradeHistory[] memory datas) {
        datas = new OrderAndTradeHistory[](1);
        // todo: 待完成
        datas[0] = OrderAndTradeHistory(
            keccak256(abi.encode(user, start, length)), uint40(block.timestamp), "BTC/USD", ActionType.LIMIT,
            0xB9EF9C975EBB606498d14B105a1619E89255c972, true, uint96(20 * 1e18),
            uint80(3 * 1e10), uint64(20000 * 1e8), uint96(3 * 1e18), uint96(5 * 1e17),
            uint64(21400 * 1e8), int96(- 5 * 1e18), uint96(3 * 1e18), uint96(3 * 1e17)
        );
        return datas;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IOrderAndTradeHistory {

    enum ActionType {LIMIT, CANCEL_LIMIT, SYSTEM_CANCEL, OPEN, CLOSE, TP, SL, LIQUIDATED}

//    struct History {
//
//    }

    struct OrderAndTradeHistory {
        bytes32 hash;
        uint40 timestamp;
        string pair;
        ActionType actionType;
        address tokenIn;
        bool isLong;
        uint96 margin;             // tokenIn decimals
        uint80 qty;                // 1e10
        uint64 entryPrice;         // 1e8
        uint96 openFee;            // tokenIn decimals
        uint96 openExecutionFee;   // tokenIn decimals

        uint64 closePrice;         // 1e8
        int96 fundingFee;         // tokenIn decimals
        uint96 closeFee;           // tokenIn decimals
        uint96 closeExecutionFee;  // tokenIn decimals
    }

    function getOrderAndTradeHistory(
        address user, uint start, uint8 length
    ) external view returns (OrderAndTradeHistory[] memory);

}