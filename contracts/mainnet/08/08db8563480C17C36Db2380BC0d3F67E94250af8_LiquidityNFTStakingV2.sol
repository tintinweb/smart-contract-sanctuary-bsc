// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../spot-exchange/libraries/liquidity/PoolLiquidity.sol";
import "../spot-exchange/libraries/liquidity/LiquidityInfo.sol";

interface ILiquidityPool {
    event LiquidityAdded(
        bytes32 indexed poolKey,
        address indexed user,
        uint128 baseAmount,
        uint128 quoteAmount,
        uint128 totalQValue
    );

    event LiquidityRemoved(
        bytes32 indexed poolKey,
        address indexed user,
        uint256 tokenId,
        uint128 baseAmount,
        uint128 quoteAmount,
        uint128 totalQValue,
        int128 pnl
    );

    event PoolAdded(bytes32 indexed poolKey, address executer);

    event SpotFactoryAdded(address oldFactory, address newFactory);

    struct AddLiquidityParams {
        bytes32 poolId;
        // gridType see {Grid.GridType}
        //        uint8 gridType;
        // pip lower limit
        //        uint80 lowerLimit;
        // pip upper limit
        //        uint80 upperLimit;
        // grid count
        //        uint16 gridCount;
        uint128 baseAmount;
        uint128 quoteAmount;
    }

    struct ReBalanceState {
        int128 soRemovablePosBuy;
        int128 soRemovablePosSell;
        uint256 claimableQuote;
        uint256 claimableBase;
        uint256 feeQuoteAmount;
        uint256 feeBaseAmount;
        IPairManager pairManager;
        bytes32 poolId;
    }

    /// @notice Add liquidity to the pool
    /// @dev Add token0, token1 to the pool and return an ERC721 token representing the liquidity
    function addLiquidity(AddLiquidityParams calldata params) external;

    /// @notice Remove liquidity from the pool
    /// @dev Explain to a developer any extra details
    function removeLiquidity(uint256 tokenId) external;

    /// @notice Resupply the pool based on pool strategy
    /// @dev Claim the unclaim amounts then re-supply the liquidity following the pool strategy
    /// caller receives a reward by calling this method
    function rebalance(bytes32 poolId) external;

    /// @notice Propose to change the rebalance strategy
    /// Note: to change rebalance strategy require votes from lp supplier
    function changeRebalanceStrategy() external;

    // @dev get the current PnL of a pool
    // @return Current profit and losses of the pool
    function getPoolPnL(bytes32 poolKey) external view returns (int128);

    // get pendingReward of an NFT
    // @param tokenId the nft token id
    // @return the total reward of the NFT in quote currency
    function pendingReward(uint256 tokenId)
        external
        view
        returns (uint256 rewardInQuote);

    //    function getPoolClaimable(
    //        bytes32 poolKey,
    //        PoolLiquidity.PoolLiquidityInfo memory data
    //    )
    //        external
    //        view
    //        returns (
    //            uint256 quote,
    //            uint256 base,
    //            uint256 feeQuoteAmount,
    //            uint256 feeBaseAmount
    //        );

    // @dev get the current pool liquidity
    // @param poolKey pool hash of the pool
    // @return quote amount,  base amount
    function getPoolLiquidity(bytes32 poolKey)
        external
        view
        returns (uint128 quote, uint128 base);

    // @dev get liquidity info of an NFT
    // get the total deposited of an NFT
    // @return PoolLiquidity.PoolLiquidityInfo
    //    function liquidityInfo(uint256 tokenId) external view returns (LiquidityInfo.Data memory);

    // @dev get the current poolInfo
    // @return PoolLiquidity.PoolLiquidityInfo
    //    function poolInfo(bytes32 poolKey) external view returns (PoolLiquidity.PoolLiquidityInfo memory);

    // @dev get data of nft
    function getDataNonfungibleToken(uint256 tokenId)
        external
        view
        returns (LiquidityInfo.Data memory);

    // @dev get all data of nft
    function getAllDataTokens(uint256[] memory tokens)
        external
        view
        returns (LiquidityInfo.Data[] memory);

    function receiveQuoteAndBase(
        bytes32 poolId,
        uint128 base,
        uint128 quote
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../helper/PackedOrderId.sol";
import "../../../interfaces/ILiquidityPool.sol";
import "../../../interfaces/IPairManager.sol";
import "./LiquidityMath.sol";
import "./../helper/BitMathLiquidity.sol";

import "hardhat/console.sol";
import "../helper/Convert.sol";
import "../exchange/BitMath.sol";
import "../../../interfaces/IRebalanceStrategy.sol";

library PoolLiquidity {
    using U128Math for uint128;
    using Convert for int128;
    using Convert for int256;
    int256 public constant PNL_DENOMINATOR = 10**18;
    using PackedOrderId for bytes32;
    using PoolLiquidity for PoolLiquidityInfo;
    struct PoolLiquidityInfo {
        address pairManager;
        address strategy;
        // the last updated liquidity in quote
        //        uint128 lastUpdatePip;
        //        uint128 lastUpdateBaseLiquidity;
        // total pool liquidity converted to quote
        // each deposit must update
        // totalQuoteDeposited += base2quote(baseAmount, price) + quoteAmount
        // each remove must update
        // totalQuoteDeposited -= base2quote(baseAmount, price) + quoteAmount
        uint128 totalQuoteDeposited;
        // all-time profit & loss per share
        // this value can negative
        uint128 totalFundingCertificates;
        uint128 baseLiquidity;
        uint128 quoteLiquidity;
        // each pool only hold up to 256 limit orders
        // because of the gas limit
        // we don't need to hold more than 256 orders
        // each array push, remove costs ~20k gas
        // so we just need to replace new order to the filled orders
        bytes32[256] supplyOrders;
        // to identify the filled orders, we use the following variables
        // a bit set, marks that the limit order at that bit position is filled
        // each bit position represents the `supplyOrders` index
        // 1 means filled
        // 0 means not
        // eg:
        // bit pos: 1 2 3 4 5 6 7 8 9 10
        //          0 0 0 1 0 0 0 1 0 0
        // means supplyOrders[4] and supplyOrders[8] has been filled
        // other orders have not been filled
        // In an other word:
        // 1 means replaceable
        // 0 means there's a pending order at supplyOrders[bitPos]
        // full name: Supply order removable bit positions
        // NOTE: initialize should set this var to type(int256).max
        int128 soRemovablePosBuy;
        int128 soRemovablePosSell;
    }

    function pushSupply(
        bytes32[256] storage supplyOrders,
        ILiquidityPool.ReBalanceState memory state,
        bytes32 value
    ) internal {
        if (value.isBuy()) {
            // side is buy
            require(state.soRemovablePosBuy != 0, "No slot to push");
            uint256 pos = rightMostSetBitPos(state.soRemovablePosBuy);
            supplyOrders[pos] = value;
            state.soRemovablePosBuy = setPosToZero(
                state.soRemovablePosBuy,
                pos
            );
        } else {
            // side sell
            require(state.soRemovablePosSell != 0, "No slot to push");
            uint256 pos = rightMostSetBitPos(state.soRemovablePosSell);
            supplyOrders[BitMathLiquidity.getPosOfSell(uint128(pos))] = value;
            state.soRemovablePosSell = setPosToZero(
                state.soRemovablePosSell,
                pos
            );
        }
    }

    /// @dev unset bit with given position in a int128 bitmask
    /// Example: given mask = 0x1111...1111, position = 2, return 0x1111...1011
    function clearBitPositionInt128(int128 mask, uint8 position)
        internal
        pure
        returns (int128)
    {
        return mask & (~(int128(1) << position));
    }

    // @dev set bit at `bitPos` to 1
    // Example: given oldSo 000...000, bitPos = 2, return 000...010
    function markSoRemovablePos(int128 oldSo, uint8 bitPos)
        internal
        view
        returns (int128 newSo)
    {
        return oldSo | int128(uint128(1 << bitPos));
    }

    // @dev set bit at `bitPos` to 1 with Int256
    // Example: given oldSo 000...000, bitPos = 2, return 000...010
    function markSoRemovablePosInt256(int256 oldSo, uint128 bitPos)
        internal
        view
        returns (int256 newSo)
    {
        return oldSo | int256(uint256(1 << bitPos));
    }

    // @dev find the right most set bit position
    // Example: given n = 18 (010010), return 2
    // given n = 19 (010011), return 1
    /*
    Algorithm: (Example 12(1100))
    Let I/P be 12 (1100)
    1. Take two’s complement of the given no as all bits are reverted
    except the first ‘1’ from right to left (0100)
    2  Do a bit-wise & with original no, this will return no with the
    required one only (0100)
    3  Take the log2 of the no, you will get (position – 1) (2)
    4  Add 1 (3)

    Explanation –

    (n&~(n-1)) always return the binary number containing the rightmost set bit as 1.
    if N = 12 (1100) then it will return 4 (100)
    Here log2 will return you, the number of times we can express that number in a power of two.
    For all binary numbers containing only the rightmost set bit as 1 like 2, 4, 8, 16, 32….
    We will find that position of rightmost set bit is always equal to log2(Number)+1

    Ref: https://www.geeksforgeeks.org/position-of-rightmost-set-bit/
    */
    function rightMostSetBitPos(int128 n) internal pure returns (uint128) {
        return uint128(log2(uint256(int256((n & -n)))));
    }

    // manually tested on Remix
    function rightMostSetBitPosUint256(int256 n)
        internal
        pure
        returns (uint256)
    {
        return log2(uint256(n & -n));
    }

    function rightMostUnSetBitPosInt256(int256 n)
        internal
        pure
        returns (uint256)
    {
        n = ~n;
        return log2(uint256(n & -n));
    }

    function leftMostUnsetBitPos(int128 n) internal view returns (uint8) {
        n = n ^ type(int128).max;
        return uint8(BitMath.mostSignificantBit(uint256(uint128(n))));
    }

    // Simple Method Loop through all bits in an integer, check if a bit is set and if it is, then increment the set bit count.
    // TODO Need to find a save gas solution
    // currently spent approx. 20k gas to count 100 bits
    // ref: https://www.geeksforgeeks.org/count-set-bits-in-an-integer/?ref=lbp
    function countBitSet(int128 n) internal pure returns (uint8 count) {
        while (n != 0) {
            count += uint8(uint128(n & 1));
            n >>= 1;
        }
    }

    function countBitSet(uint256 n) internal pure returns (uint8 count) {
        while (n != 0) {
            count += uint8(n & 1);
            n >>= 1;
        }
    }

    // @dev just rename the function to avoid confusion
    // Because `so` mark `0` as pending orders
    // so we just need to count the unset bit in the given `so`
    function countPendingSoOrder(int128 so)
        internal
        pure
        returns (uint8 count)
    {
        return countUnsetBit(so);
    }

    // @dev count unset bit in given int128 n
    // Example: given 17 (10001), return 3
    // The idea is to toggle bits in O(1) time. Then apply any of the methods discussed in count set bits article.
    // In GCC, we can directly count set bits using __builtin_popcount(). First toggle the bits and then apply above function __builtin_popcount().
    // Ref: https://www.geeksforgeeks.org/count-unset-bits-number/
    // unit test available in test/unit/TestPoolLiquidityLibrary.test.ts #L211 -> L227
    function countUnsetBit(int128 n) internal pure returns (uint8 count) {
        int128 x = n;

        // Make all bits set MSB
        // (including MSB)

        // This makes sure two bits
        // (From MSB and including MSB)
        // are set
        n |= n >> 1;

        // This makes sure 4 bits
        // (From MSB and including MSB)
        // are set
        n |= n >> 2;

        n |= n >> 4;
        n |= n >> 8;
        n |= n >> 16;
        n |= n >> 32;
        n |= n >> 64;
        n |= n >> 128;
        return _countBit128(x ^ n);
    }

    function _countBit128(int128 x) private pure returns (uint8) {
        // To store the count
        // of set bits
        uint8 setBits = 0;
        while (x != 0) {
            x = x & (x - 1);
            setBits++;
        }

        return setBits;
    }

    //copy form https://ethereum.stackexchange.com/questions/8086/logarithm-math-operation-in-solidity
    function log2(uint256 x) internal pure returns (uint256 y) {
        assembly {
            let arg := x
            x := sub(x, 1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(
                m,
                0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd
            )
            mstore(
                add(m, 0x20),
                0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe
            )
            mstore(
                add(m, 0x40),
                0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616
            )
            mstore(
                add(m, 0x60),
                0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff
            )
            mstore(
                add(m, 0x80),
                0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e
            )
            mstore(
                add(m, 0xa0),
                0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707
            )
            mstore(
                add(m, 0xc0),
                0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606
            )
            mstore(
                add(m, 0xe0),
                0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100
            )
            mstore(0x40, add(m, 0x100))
            let
                magic
            := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let
                shift
            := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m, sub(255, a))), shift)
            y := add(
                y,
                mul(
                    256,
                    gt(
                        arg,
                        0x8000000000000000000000000000000000000000000000000000000000000000
                    )
                )
            )
        }
    }

    // function to calculate the return amounts of base and quote
    function calculateReturnAmounts(
        uint128 quoteDeposited,
        uint128 totalQuoteDeposited,
        uint128 poolBaseLiquidity,
        uint128 poolQuoteLiquidity
    ) internal pure returns (uint128 baseAmount, uint128 quoteAmount) {
        baseAmount = (quoteDeposited * poolBaseLiquidity) / totalQuoteDeposited;
        quoteAmount =
            (quoteDeposited * poolQuoteLiquidity) /
            totalQuoteDeposited;
    }

    /// @notice canculate the pool pnl
    /// poolPnl = deltaPip / _basisPoint * _baseLiquidity
    function calculatePoolPnl(
        int128 _deltaPip,
        uint256 _basisPoint,
        uint128 _baseLiquidity
    ) internal pure returns (int128) {
        return
            (_deltaPip * int128(_baseLiquidity)) / int128(uint128(_basisPoint));
    }

    function getCurrentPipAndBasisPoint(PoolLiquidityInfo memory _pool)
        internal
        view
        returns (uint128 pip, uint128 _basisPoint)
    {
        return IPairManager(_pool.pairManager).getCurrentPipAndBasisPoint();
    }

    function updateLiquidity(
        PoolLiquidityInfo storage pool,
        uint128 baseAmount,
        uint128 quoteAmount,
        uint128 totalQuoteDeposited,
        uint128 addedFundCertificates
    ) internal {
        unchecked {
            pool.baseLiquidity += baseAmount;
            pool.quoteLiquidity += quoteAmount;
            pool.totalQuoteDeposited += totalQuoteDeposited;
            pool.totalFundingCertificates += addedFundCertificates;
        }
    }

    function removeLiquidity(
        PoolLiquidityInfo storage pool,
        uint128 newBaseAmount,
        uint128 newQuoteAmount,
        uint128 totalQuoteDeposited,
        uint128 removedFundCertificates
    ) internal {
        unchecked {
            // should never overflow
            pool.baseLiquidity = newBaseAmount;
            pool.quoteLiquidity = newQuoteAmount;
            pool.totalQuoteDeposited -= totalQuoteDeposited;
            pool.totalFundingCertificates -= removedFundCertificates;
        }
    }

    // @dev get user's Pnl
    // divided by the PNL_DENOMINATOR
    function getUserPnl(PoolLiquidityInfo memory _pool, int256 userDepositQ)
        internal
        view
        returns (int128)
    {
        return 0;
    }

    function getUserBaseQuoteOut(
        PoolLiquidityInfo memory _pool,
        uint128 quoteLiquidity,
        uint128 baseLiquidity,
        uint128 totalPoolLiquidityQ,
        uint128 userClaimableQ
    ) internal view returns (uint128 base, uint128 quote) {
        base = uint128(
            LiquidityMath.baseOut(
                baseLiquidity,
                userClaimableQ,
                totalPoolLiquidityQ
            )
        );
        quote = uint128(
            LiquidityMath.quoteOut(
                quoteLiquidity,
                userClaimableQ,
                totalPoolLiquidityQ
            )
        );
    }

    function setPosToZero(int128 soRemovablePos, uint256 pos)
        private
        view
        returns (int128)
    {
        return soRemovablePos & ~int128(uint128((1 << pos)));
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library LiquidityInfo {
    struct Data {
        bytes32 poolId;
        //        uint80 lowerLimit;
        //        uint80 upperLimit;
        //        // gridData contains gridType and gridCount packed in a 16 bit slot
        //        // because solidity only store minimum 8 bit, so we need to pack and unpack manually
        //        // gridType is the fist bit 0 or 1 (0 for arithmetic, 1 for geometric) - if add anyother type
        //        // will need refactor the pack and unpack Grid Data
        //        // gridCount can store up to 15 bits with the maximum 32767
        //        uint16 gridData;
        uint128 baseAmount;
        uint128 quoteAmount;
        // consider packed or remove?
        uint128 priceOfFundingCertificate; // Reward debt. See explanation below.
        uint128 amountOfFC;
        uint128 quoteDeposited;
    }

    // manually tested on Remix
    function packGridData(uint8 gridType, uint16 gridCount)
        internal
        pure
        returns (uint16 gridData)
    {
        require(gridCount <= 32767, "gridCount must <= 32767");
        // WARNING: if you want to change gridType > 1, you need to re-write the packing slot below
        // becuase 1 bit can only store 0 or 1
        require(gridType <= 1, "gridType must <= 1");
        gridData = (gridType << 15) | gridCount;
    }

    function unpackGridData(uint16 gridData)
        internal
        pure
        returns (uint8 gridType, uint16 gridCount)
    {
        gridType = uint8(gridData >> 15);
        gridCount = gridData & 0x7FFF; // gridData & 32767
        /*
        EG:
        let gridType = 1, gridCount = 1123 => gridData = 33891
        0x463	    1000010001100011	33891
        &	0x7fff	0111111111111111	32767
        =	0x463	0000010001100011	1123

        let gridType = 1, gridCount = 1123 => gridData = 1123
        0x463	    0000010001100011	1123
        &	0x7fff	0111111111111111	32767
        =	0x463	0000010001100011	1123
        */
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "hardhat/console.sol";

/// @dev Helper library for packing and unpacking Pair limit order IDs.
library PackedOrderId {
    /// @dev Packs a pair limit order ID.
    function pack(
        uint128 _pip,
        uint64 _orderIdx,
        bool _isBuy
    ) internal pure returns (bytes32) {
        return bytes32(_pack64And128AndBool(_pip, _orderIdx, _isBuy));
    }

    /// @dev Unpacks a pair limit order ID.
    function unpack(bytes32 _packed)
        internal
        pure
        returns (
            uint128 _pip,
            uint64 _orderIdx,
            bool isBuy
        )
    {
        return _unpack192(uint256(_packed));
    }

    function isBuy(bytes32 _packed) internal view returns (bool isBuy) {
        return _unpackSide(uint256(_packed));
    }

    function _pack64And128(uint128 a, uint64 b) private pure returns (uint192) {
        // convert to uint192, then shift b (uint64) 128 bits to the left,
        // leave 128 bits in the right and then add a (uint128)
        return (uint192(b) << 128) | uint192(a);
    }

    function _pack64And128AndBool(
        uint128 a,
        uint64 b,
        bool isBuy
    ) private pure returns (uint256) {
        // convert to int256, then shift b (uint64) 128 bits to the left,
        // leave 128 bits in the right and then add a (uint128)
        return (((uint256(b) << 128) | uint256(a)) << 1) | (isBuy ? 1 : 0);
    }

    function _unpack192(uint256 packedN)
        private
        pure
        returns (
            uint128 a,
            uint64 b,
            bool isBuy
        )
    {
        a = uint128(packedN >> 1);
        b = uint64(packedN >> 129);

        if (packedN & 1 == 1) {
            isBuy = true;
        }
    }

    function _unpackSide(uint256 _packed) private view returns (bool) {
        return _packed & 1 == 1 ? true : false;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../spot-exchange/libraries/types/PairManagerStorage.sol";
import "../spot-exchange/libraries/liquidity/Grid.sol";
import "../spot-exchange/libraries/liquidity/PoolLiquidity.sol";

interface IPairManager {
    event MarketFilled(
        bool isBuy,
        uint256 indexed amount,
        uint128 toPip,
        uint256 startPip,
        uint128 remainingLiquidity,
        uint64 filledIndex
    );
    event LimitOrderCreated(
        uint64 orderId,
        uint128 pip,
        uint128 size,
        bool isBuy
    );

    event PairManagerInitialized(

        address quoteAsset,
        address baseAsset,
        address counterParty,
        uint256 basisPoint,
        uint256 BASE_BASIC_POINT,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        uint64 expireTime,
        address owner
    );
    event LimitOrderCancelled(
        bool isBuy,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    event UpdateMaxFindingWordsIndex(
        address spotManager,
        uint128 newMaxFindingWordsIndex
    );

    event MaxWordRangeForLimitOrderUpdated(
        uint128 newMaxWordRangeForLimitOrder
    );
    event MaxWordRangeForMarketOrderUpdated(
        uint128 newMaxWordRangeForMarketOrder
    );
    event UpdateBasisPoint(address spotManager, uint256 newBasicPoint);
    event UpdateBaseBasicPoint(address spotManager, uint256 newBaseBasisPoint);
    event ReserveSnapshotted(uint128 pip, uint256 timestamp);
    event LimitOrderUpdated(
        address spotManager,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );
    event UpdateExpireTime(address spotManager, uint64 newExpireTime);
    event UpdateCounterParty(address spotManager, address newCounterParty);
    event LiquidityPoolAllowanceUpdate(address liquidityPool, bool value);
    //    event Swap(
    //        address account,
    //        uint256 indexed amountIn,
    //        uint256 indexed amountOut
    //    );

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    struct ExchangedData {
        uint256 baseAmount;
        uint256 quoteAmount;
        uint256 feeQuoteAmount;
        uint256 feeBaseAmount;
    }

    struct AccPoolExchangedDataParams {
        bytes32 orderId;
        int128 baseAdjust;
        int128 quoteAdjust;
        //        int128 baseFilledCurrentPip;
        uint128 currentPip;
        uint256 basisPoint;
        //        // cumulative price*quantity buy orders
        //        uint128 cumPQ;
        //        // cumulative quantity
        //        uint128 cumQ;
    }

    function initializeFactory(
        address _quoteAsset,
        address _baseAsset,
        address _counterParty,
        uint256 _basisPoint,
        uint256 _BASE_BASIC_POINT,
        uint128 _maxFindingWordsIndex,
        uint128 _initialPip,
        uint64 _expireTime,
        address _owner,
        address _liquidityPool
    ) external;

    /// @notice Supply Grid order to the pair
    /// @dev drop order that equals the currentPip
    /// @param orders the grid orders
    /// returns baseAmountUsed, quoteAmountUsed, the amount base,quote actually used
    /// due to the skip order, partially amount may not use
    // currently no fee required for supply grid
    function supplyGridOrder(
        Grid.GridOrderData[] memory orders,
        address user,
        bytes memory data,
        bytes32 poolId
    )
        external
        returns (
            uint256 baseAmountUsed,
            uint256 quoteAmountUsed,
            bytes32[] memory orderIds
        );

    /// @notice Cancel Grid order
    /// @param _orderIds the order ids to cancel
    /// return the total amount cancelled in quote and base
    /// and transfer back the liquidity the amount
    function cancelGridOrders(bytes32[] memory _orderIds)
        external
        returns (uint256 base, uint256 quote);

    //    function removeGridOrder()
    //        external
    //        returns (uint256 baseOut, uint256 quoteOut);

    function openLimit(
        uint128 pip,
        uint128 size,
        bool isBuy,
        address trader,
        uint256 quoteDeposited
    )
        external
        returns (
            uint64 orderId,
            uint256 sizeOut,
            uint256 openNotional
        );

    function calculatingQuoteAmount(uint256 quantity, uint128 pip)
        external
        view
        returns (uint256);

    function cancelLimitOrder(uint128 pip, uint64 orderId)
        external
        returns (uint256 size, uint256 partialFilled);

    function updatePartialFilledOrder(uint128 pip, uint64 orderId) external;

    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        external
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        );

    function getBasisPoint() external view returns (uint256);

    //    function isExpired() external returns (bool);

    function getBaseBasisPoint() external returns (uint256);

    function getCurrentPipAndBasisPoint()
        external
        view
        returns (uint128 currentPip, uint128 basisPoint);

    function getCurrentPip() external view returns (uint128);

    function getCurrentSingleSlot() external view returns (uint128, uint8);

    function getPrice() external view returns (uint256);

    function getQuoteAsset() external view returns (IERC20);

    function getBaseAsset() external view returns (IERC20);

    function pipToPrice(uint128 pip) external view returns (uint256);

    function getLiquidityInCurrentPip() external view returns (uint128);

    function hasLiquidity(uint128 pip) external view returns (bool);

    function getLiquidityInPipRange(
        uint128 fromPip,
        uint256 dataLength,
        bool toHigher
    )
        external
        view
        returns (PairManagerStorage.LiquidityOfEachPip[] memory, uint128);

    //    function pause() external;
    //
    //    function unpause() external;

    function updateMaxFindingWordsIndex(uint128 _newMaxFindingWordsIndex)
        external;

    //    function updateBasisPoint(uint256 _newBasisPoint) external;
    //
    //    function updateBaseBasicPoint(uint256 _newBaseBasisPoint) external;

    //    function updateExpireTime(uint64 _expireTime) external;

    function openMarket(
        uint256 size,
        bool isBuy,
        address _trader
    ) external returns (uint256 sizeOut, uint256 quoteAmount);

    function openMarketWithQuoteAsset(
        uint256 quoteAmount,
        bool isBuy,
        address trader
    ) external returns (uint256 sizeOutQuote, uint256 baseAmount);

    function getFee()
        external
        view
        returns (uint256 baseFeeFunding, uint256 quoteFeeFunding);

    function resetFee(uint256 baseFee, uint256 quoteFee) external;

    function increaseBaseFeeFunding(uint256 baseFee) external;

    function increaseQuoteFeeFunding(uint256 quoteFee) external;

    function decreaseBaseFeeFunding(uint256 baseFee) external;

    function decreaseQuoteFeeFunding(uint256 quoteFee) external;

    function quoteToBase(uint256 quoteAmount, uint128 pip)
        external
        view
        returns (uint256);

    function accumulatePoolExchangedData(
        bytes32[256] memory _orderIds,
        uint16 feeShareRatio,
        uint128 feeBase,
        int128 soRemovablePosBuy,
        int128 soRemovablePosSell
    ) external view returns (int128 quoteAdjust, int128 baseAdjust);

    function accumulateClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        IPairManager.ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view returns (IPairManager.ExchangedData memory);

    function accumulatePoolLiquidityClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        IPairManager.ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external returns (IPairManager.ExchangedData memory, bool isFilled);

    //    function claimAmountFromLiquidityPool(
    //        uint256 quoteAmount,
    //        uint256 baseAmount,
    //        address user
    //    ) external;

    function collectFund(
        IERC20 token,
        address to,
        uint256 amount
    ) external;

    function updateSpotHouse(address _newSpotHouse) external;

    function getAmountEstimate(
        uint256 size,
        bool isBuy,
        bool isBase
    ) external view returns (uint256 sizeOut, uint256 openOtherSide);
//
//    function receiveBNB() external payable ;
//    function withdrawBNB(address recipient, uint256 amount) external payable;


}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../helper/U128Math.sol";

library LiquidityMath {
    using U128Math for uint128;

    // get the pool quote ratio
    // used to calculate the base amount transfer to user
    // from the totalUserLiquidityInQuote
    function quoteOut(
        uint128 quoteLiquidity,
        uint128 totalQuoteDeposited,
        uint128 totalPoolLiquidityQ
    ) internal pure returns (uint256) {
        // quoteOut = totalQuoteDeposited * quoteRatio
        // quoteRatio = quoteLiquidity / poolLiquidityInQuote
        // or quoteRatio = quoteLiquidity / (baseLiquidity * currentPrice + quoteLiquidity)
        // convert to 256 bits, avoid overflow
        return
            (quoteLiquidity.toU256() * totalQuoteDeposited.toU256()) /
            totalPoolLiquidityQ.toU256();
    }

    // get the pool base ratio
    // used to calculate the base amount transfer to user
    // from the totalUserLiquidityInQuote
    function baseOut(
        uint128 baseLiquidity,
        uint128 totalQuoteDeposited,
        uint128 totalPoolLiquidityQ
    ) internal pure returns (uint256) {
        //  baseOut = totalQuoteDeposited * baseRatio
        // while baseRatio = baseLiquidity / poolLiquidityInQuote
        // convert to 256 bits, avoid overflow
        return
            (baseLiquidity.toU256() * totalQuoteDeposited.toU256()) /
            totalPoolLiquidityQ.toU256();
    }

    // in case of the rounding issues, if liquidity < removeAmount returns 0
    function safeSubLiquidity(uint128 liquidity, uint128 removeAmount)
        internal
        pure
        returns (uint128)
    {
        if (liquidity >= removeAmount) {
            return liquidity - removeAmount;
        }
        return 0;
    }

    function absIn128(int128 n) internal pure returns (uint128) {
        return uint128(n > 0 ? n : -n);
    }

    function safeAdjustLiquidity(uint128 liquidity, int128 adjustAmount)
        internal
        pure
        returns (uint128)
    {
        int128 c = int128(liquidity) + adjustAmount;
        if (c > 0) {
            return uint128(c);
        }
        return 0;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "hardhat/console.sol";

library BitMathLiquidity {
    function isSoRemoveable(int128 soRemoveable, uint256 index)
        internal
        view
        returns (bool hasNotSupply)
    {
        if (index == 127 || index == 255) return hasNotSupply = true;

        if (index < 127) {
            return
                hasNotSupply =
                    uint256(int256(soRemoveable)) &
                        (1 << uint256(int256(index))) !=
                    0;
        }

        if (index > 127) {
            return
                hasNotSupply =
                    uint256(int256(soRemoveable)) &
                        (1 << ((getIndexOrderOfSell(index)))) !=
                    0;
        }
    }

    // manually tested on Remix
    function packInt128AndIn128(
        int128 soRemovablePosBuy,
        int128 soRemovablePosSell
    ) internal pure returns (int256) {
        return
            ((int256(soRemovablePosSell)) << 128) | (int256(soRemovablePosBuy));
    }

    function getPosOfSell(uint128 pos) internal pure returns (uint8) {
        return uint8(pos + 128);
    }

    function getIndexOrderOfSell(uint256 index) internal pure returns (uint8) {
        return uint8(index - 128);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Convert {
    function Uint256ToUint128(uint256 x) internal pure returns (uint128) {
        return uint128(x);
    }

    function Uint256ToUint64(uint256 x) internal pure returns (uint64) {
        return uint64(x);
    }

    function Uint256ToUint32(uint256 x) internal pure returns (uint32) {
        return uint32(x);
    }

    function toI256(uint256 x) internal pure returns (int256) {
        return int256(x);
    }

    function toI128(uint256 x) internal pure returns (int128) {
        return int128(int256(x));
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }

    function abs256(int128 x) internal pure returns (uint256) {
        return uint256(uint128(x >= 0 ? x : -x));
    }

    function toU128(uint256 x) internal pure returns (uint128) {
        return uint128(x);
    }

    function Uint256ToUint40(uint256 x) internal returns (uint40) {
        return uint40(x);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title BitMath
/// @dev This libraries provides functionality for computing bit properties of an unsigned integer
library BitMath {
    /// @notice Returns the index of the most significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    /// @param x the value for which to compute the most significant bit, must be greater than 0
    /// @return r the index of the most significant bit
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }

    /// @notice Returns the index of the least significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    /// @param x the value for which to compute the least significant bit, must be greater than 0
    /// @return r the index of the least significant bit
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        r = 255;
        if (x & type(uint128).max > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & type(uint64).max > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & type(uint32).max > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & type(uint16).max > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & type(uint8).max > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../spot-exchange/libraries/liquidity/Grid.sol";

interface IRebalanceStrategy {
    function getSupplyPrices(
        uint128 currentPip,
        uint128 quote,
        uint128 base
    ) external view returns (Grid.GridOrderData[] memory);

    function getNumberOfSupplyOrdersEachSide() external view returns (uint16);
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../exchange/TickPosition.sol";
import "../exchange/LiquidityBitmap.sol";
import "../helper/Timers.sol";
import "../../../interfaces/IPairManager.sol";

contract PairManagerStorage {
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);

    // quote asset token address
    IERC20 internal quoteAsset;

    // base asset token address
    IERC20 internal baseAsset;

    // base fee for base asset
    uint256 internal baseFeeFunding;

    // base fee for quote asset
    uint256 internal quoteFeeFunding;

    address public owner;

    bool internal _isInitialized;

    // the smallest number of the price. Eg. 100 for 0.01
    uint256 internal basisPoint;

    // demoninator of the basis point. Eg. 10000 for 0.01
    uint256 public BASE_BASIC_POINT;

    // Max finding word can be 3500
    uint128 public maxFindingWordsIndex;

    // Counter party address
    address public counterParty;

    // Liquidaity pool
    address public liquidityPool;

    uint64 public expireTime;

    // The unit of measurement to express the change in value between two currencies
    struct SingleSlot {
        uint128 pip;
        //0: not set
        //1: buy
        //2: sell
        uint8 isFullBuy;
    }

    enum CurrentLiquiditySide {
        NotSet,
        Buy,
        Sell
    }

    struct LiquidityOfEachPip {
        uint128 pip;
        uint256 liquidity;
    }

    struct StepComputations {
        uint128 pipNext;
    }

    struct ReserveSnapshot {
        uint128 pip;
        uint64 timestamp;
        uint64 blockNumber;
    }

    ReserveSnapshot[] public reserveSnapshots;

    SingleSlot public singleSlot;
    mapping(uint128 => TickPosition.Data) public tickPosition;
    mapping(uint128 => uint256) public tickStore;
    // a packed array of bit, where liquidity is filled or not
    mapping(uint128 => uint256) public liquidityBitmap;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;

    ///////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// EXTEND VIEWER ///////////////////////////////////

    function balanceBase() public view returns (uint256) {
        return baseAsset.balanceOf(address(this));
    }

    function balanceQuote() public view returns (uint256) {
        return quoteAsset.balanceOf(address(this));
    }

    struct DebtPool {
        uint128 debtQuote;
        uint128 debtBase;
    }

    // @deprecated just hold to upgradeable
    mapping(bytes32 => DebtPool) debtPool;

    uint128 public maxWordRangeForLimitOrder;
    uint128 public maxWordRangeForMarketOrder;

    mapping(address => bool) public liquidityPoolAllowed;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Grid {
    enum GridType {
        Artithmetic,
        Geometric
    }

    struct GridOrderData {
        uint128 pip;
        // negative is sell
        // positive is buy
        int256 amount;
    }

    // @dev generate grid base on the GridType
    function generateGrid(
        uint256 currentPip,
        uint80 lowerLimit,
        uint80 upperLimit,
        uint16 gridCount,
        uint128 baseAmount,
        uint128 quoteAmount
    ) internal pure returns (GridOrderData[] memory out) {
        (
            uint256[] memory priceGrids,
            uint256 bidCount,
            uint256 askCount
        ) = generateGridArithmeticPrice(
                currentPip,
                lowerLimit,
                upperLimit,
                gridCount
            );
        out = new GridOrderData[](priceGrids.length);
        int256 gridBidQty;
        int256 gridAskQty;
        // bidCount must > 0
        if (bidCount > 0) {
            gridBidQty = -int256(uint256(quoteAmount / uint128(bidCount)));
        }
        if (askCount > 0) {
            gridAskQty = int256(uint256(baseAmount / uint128(askCount)));
        }
        for (uint256 i = 0; i < priceGrids.length; i++) {
            out[i] = GridOrderData({
                pip: uint128(priceGrids[i]),
                amount: priceGrids[i] <= currentPip ? gridBidQty : gridAskQty
            });
        }
    }

    //Arithmetic: Each grid has an equal price difference.
    //The arithmetic grid divides the price range from grid_lower_limit to grid_upper_limit into grid_count by equal price difference.
    function generateGridArithmeticPrice(
        uint256 currentPip,
        uint80 lowerLimit,
        uint80 upperLimit,
        uint16 gridCount
    )
        internal
        pure
        returns (
            uint256[] memory result,
            uint256 bidCount,
            uint256 askCount
        )
    {
        result = new uint256[](gridCount);
        uint80 step = (upperLimit - lowerLimit) / uint80(gridCount);
        for (uint80 i = 0; i < uint80(gridCount); i++) {
            uint256 _p = uint256(lowerLimit + i * step);
            if (_p <= currentPip) {
                bidCount++;
            } else {
                askCount++;
            }
            result[i] = _p;
        }
    }

    // Geometric: Each grid has an equal price difference ratio.
    // The geometric grid divides the price range from grid_lower_limit to grid_upper_limit by into grid_count by equal price ratio.
    // Example: Geometric grid price_diff_percentage = 10%: 1000, 1100, 1210, 1331, 1464.1,... (the next price is 10% higher than the previous one)
    function generateGridGeometricPrice(
        uint256 currentPip,
        uint256 lowerLimit,
        uint256 upperLimit,
        uint256 gridCount
    )
        internal
        pure
        returns (
            uint256[] memory result,
            uint256 bidCount,
            uint256 askCount
        )
    {
        uint256 price_ratio = (upperLimit / lowerLimit)**(1 / gridCount); // TODO resolve 1/gridCount
        /**
        Geometric: Each grid has an equal price difference ratio.
        The geometric grid divides the price range from grid_lower_limit to grid_upper_limit by into grid_count by equal price ratio.
        The price ratio of each grid is:
        price_ratio = (grid_upper_limit / grid_lower_limit)^(1/grid_count)
        The price difference of each grid is:
        price_diff_percentage = ( (grid_upper_limit / grid_lower_limit) ^ (1/grid_count) - 1)*100%
        Then it constructed a series of price intervals:
        price_1 = grid_lower_limit
        price_2 = grid_lower_limit* price_ratio
        price_3 = grid_lower_limit * price_ratio ^ 2
        ...
        price_n = grid_lower_limit* price_ratio ^ (n-1)
        At grid_upper_limit，n = grid_count
        Example: Geometric grid price_diff_percentage = 10%: 1000, 1100, 1210, 1331, 1464.1,... (the next price is 10% higher than the previous one)

        Reference: https://www.binance.com/en/support/faq/f4c453bab89648beb722aa26634120c3
         */
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./LimitOrder.sol";

import "hardhat/console.sol";

/*
 * A library storing data and logic at a pip
 */

library TickPosition {
    using SafeMath for uint128;
    using SafeMath for uint64;
    using LimitOrder for LimitOrder.Data;
    struct Data {
        uint128 liquidity;
        uint64 filledIndex;
        uint64 currentIndex;
        // position at a certain tick
        // index => order data
        mapping(uint64 => LimitOrder.Data) orderQueue;
    }

    function insertLimitOrder(
        TickPosition.Data storage self,
        uint128 size,
        bool hasLiquidity,
        bool isBuy
    ) internal returns (uint64) {
        self.currentIndex++;
        if (
            !hasLiquidity &&
            self.filledIndex != self.currentIndex &&
            self.liquidity != 0
        ) {
            // means it has liquidity but is not set currentIndex yet
            // reset the filledIndex to fill all
            self.filledIndex = self.currentIndex;
            self.liquidity = size;
        } else {
            self.liquidity = self.liquidity + size;
        }
        self.orderQueue[self.currentIndex].update(isBuy, size);
        return self.currentIndex;
    }

    function updateOrderWhenClose(
        TickPosition.Data storage self,
        uint64 orderId
    ) internal returns (uint256) {
        return self.orderQueue[orderId].updateWhenClose();
    }

    function getQueueOrder(TickPosition.Data storage self, uint64 orderId)
        internal
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        (isBuy, size, partialFilled) = self.orderQueue[orderId].getData();
        if (self.filledIndex > orderId && size != 0) {
            isFilled = true;
        } else if (self.filledIndex < orderId) {
            isFilled = false;
        } else {
            isFilled = partialFilled >= size && size != 0 ? true : false;
        }
    }

    function partiallyFill(TickPosition.Data storage _self, uint128 _amount)
        internal
    {
        _self.liquidity -= _amount;
        unchecked {
            uint64 index = _self.filledIndex;
            uint128 totalSize = 0;
            if (
                _self.orderQueue[index].size ==
                _self.orderQueue[index].partialFilled
            ) {
                index++;
            }
            if (_self.orderQueue[index].partialFilled != 0) {
                totalSize += (_self.orderQueue[index].size -
                    _self.orderQueue[index].partialFilled);
                index++;
            }
            while (totalSize < _amount) {
                totalSize += _self.orderQueue[index].size;
                index++;
            }
            index--;
            _self.filledIndex = index;
            _self.orderQueue[index].updatePartialFill(
                uint120(totalSize - _amount)
            );
        }
    }

    function calculatingFilledIndex(TickPosition.Data storage self)
        internal
        view
        returns (uint64)
    {
        if (self.filledIndex == self.currentIndex && self.currentIndex > 0) {
            return self.filledIndex - 1;
        }

        return self.filledIndex;
    }

    function cancelLimitOrder(TickPosition.Data storage self, uint64 orderId)
        internal
        returns (
            uint256,
            uint256,
            bool
        )
    {
        (bool isBuy, uint256 size, uint256 partialFilled) = self
            .orderQueue[orderId]
            .getData();
        if (self.liquidity >= uint128(size - partialFilled)) {
            self.liquidity = self.liquidity - uint128(size - partialFilled);
        }
        self.orderQueue[orderId].update(isBuy, partialFilled);

        return (size - partialFilled, partialFilled, isBuy);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./BitMath.sol";

library LiquidityBitmap {
    uint256 public constant MAX_UINT256 =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    /// @notice Get the position in the mapping
    /// @param pip The bip index for computing the position
    /// @return mapIndex the index in the map
    /// @return bitPos the position in the bitmap
    function position(uint128 pip)
        private
        pure
        returns (uint128 mapIndex, uint8 bitPos)
    {
        mapIndex = pip >> 8;
        bitPos = uint8((pip) & 0xff);
        // % 256
    }

    /// @notice find the next pip has liquidity
    /// @param pip The current pip index
    /// @param lte  Whether to search for the next initialized tick to the left (less than or equal to the starting tick)
    /// @return next The next bit position has liquidity, 0 means no liquidity found
    function findHasLiquidityInOneWords(
        mapping(uint128 => uint256) storage self,
        uint128 pip,
        bool lte
    ) internal view returns (uint128 next) {
        if (lte) {
            // main is find the next pip has liquidity
            (uint128 wordPos, uint8 bitPos) = position(pip);
            // all the 1s at or to the right of the current bitPos
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = self[wordPos] & mask;
            //            bool hasLiquidity = (self[wordPos] & 1 << bitPos) != 0;

            // if there are no initialized ticks to the right of or at the current tick, return rightmost in the word
            bool initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (pip - (bitPos - BitMath.mostSignificantBit(masked)))
                : 0;
        } else {
            // start from the word of the next tick, since the current tick state doesn't matter
            (uint128 wordPos, uint8 bitPos) = position(pip);
            // all the 1s at or to the left of the bitPos
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked = self[wordPos] & mask;
            // if there are no initialized ticks to the left of the current tick, return leftmost in the word
            bool initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (pip + (BitMath.leastSignificantBit(masked) - bitPos)) // +1
                : 0;
        }
    }

    // find nearest pip has liquidity in multiple word
    function findHasLiquidityInMultipleWords(
        mapping(uint128 => uint256) storage self,
        uint128 pip,
        uint128 maxWords,
        bool lte
    ) internal view returns (uint128 next) {
        uint128 startWord = pip >> 8;
        if (lte) {
            if (startWord != 0) {
                uint128 i = startWord;
                for (
                    i;
                    i > (startWord < maxWords ? 0 : startWord - maxWords);
                    i--
                ) {
                    if (self[i] != 0) {
                        next = findHasLiquidityInOneWords(
                            self,
                            i < startWord ? 256 * i + 255 : pip,
                            true
                        );
                        if (next != 0) {
                            return next;
                        }
                    }
                }
                if (i == 0 && self[0] != 0) {
                    next = findHasLiquidityInOneWords(self, 255, true);
                    if (next != 0) {
                        return next;
                    }
                }
            } else {
                if (self[startWord] != 0) {
                    next = findHasLiquidityInOneWords(self, pip, true);
                    if (next != 0) {
                        return next;
                    }
                }
            }
        } else {
            for (uint128 i = startWord; i < startWord + maxWords; i++) {
                if (self[i] != 0) {
                    next = findHasLiquidityInOneWords(
                        self,
                        i > startWord ? 256 * i : pip,
                        false
                    );
                    if (next != 0) {
                        return next;
                    }
                }
            }
        }
    }

    // find all pip has liquidity in multiple word
    function findAllLiquidityInMultipleWords(
        mapping(uint128 => uint256) storage self,
        uint128 startPip,
        uint256 dataLength,
        bool toHigher
    ) internal view returns (uint128[] memory) {
        uint128 startWord = startPip >> 8;
        uint128 index = 0;
        uint128[] memory allPip = new uint128[](uint128(dataLength));
        if (!toHigher) {
            for (
                uint128 i = startWord;
                i >= (startWord == 0 ? 0 : startWord - 100);
                i--
            ) {
                if (self[i] != 0) {
                    uint128 next;
                    next = findHasLiquidityInOneWords(
                        self,
                        i < startWord ? 256 * i + 255 : startPip,
                        true
                    );
                    if (next != 0) {
                        allPip[index] = next;
                        index++;
                        while (true) {
                            next = findHasLiquidityInOneWords(
                                self,
                                next - 1,
                                true
                            );
                            if (next != 0 && index <= dataLength) {
                                allPip[index] = next;
                                index++;
                            } else {
                                break;
                            }
                        }
                    }
                }
                if (index == dataLength) return allPip;
                if (i == 0) break;
            }
        } else {
            for (uint128 i = startWord; i <= startWord + 100; i++) {
                if (self[i] != 0) {
                    uint128 next;
                    next = findHasLiquidityInOneWords(
                        self,
                        i > startWord ? 256 * i : startPip,
                        false
                    );
                    if (next != 0) {
                        allPip[index] = next;
                        index++;
                    }
                    while (true) {
                        next = findHasLiquidityInOneWords(
                            self,
                            next + 1,
                            false
                        );
                        if (next != 0 && index <= dataLength) {
                            allPip[index] = next;
                            index++;
                        } else {
                            break;
                        }
                    }
                }
            }
            if (index == dataLength) return allPip;
        }

        return allPip;
    }

    function hasLiquidity(mapping(uint128 => uint256) storage self, uint128 pip)
        internal
        view
        returns (bool)
    {
        (uint128 mapIndex, uint8 bitPos) = position(pip);
        return (self[mapIndex] & (1 << bitPos)) != 0;
    }

    /// @notice Set all bits in a given range
    /// @dev WARNING THIS FUNCTION IS NOT READY FOR PRODUCTION
    /// only use for generating test data purpose
    /// @param fromPip the pip to set from
    /// @param toPip the pip to set to
    function setBitsInRange(
        mapping(uint128 => uint256) storage self,
        uint128 fromPip,
        uint128 toPip
    ) internal {
        (uint128 fromMapIndex, uint8 fromBitPos) = position(fromPip);
        (uint128 toMapIndex, uint8 toBitPos) = position(toPip);
        if (toMapIndex == fromMapIndex) {
            // in the same storage
            // Set all the bits in given range of a number
            self[toMapIndex] |= (((1 << (fromBitPos - 1)) - 1) ^
                ((1 << toBitPos) - 1));
        } else {
            // need to shift the map index
            // TODO fromMapIndex needs set separately
            self[fromMapIndex] |= (((1 << (fromBitPos - 1)) - 1) ^
                ((1 << 255) - 1));
            for (uint128 i = fromMapIndex + 1; i < toMapIndex; i++) {
                // pass uint256.MAX to avoid gas for computing
                self[i] = MAX_UINT256;
            }
            // set bits for the last index
            self[toMapIndex] = MAX_UINT256 >> (256 - toBitPos);
        }
    }

    function unsetBitsRange(
        mapping(uint128 => uint256) storage self,
        uint128 fromPip,
        uint128 toPip
    ) internal {
        if (fromPip == toPip) return toggleSingleBit(self, fromPip, false);
        fromPip++;
        toPip++;
        if (toPip < fromPip) {
            uint128 n = fromPip;
            fromPip = toPip;
            toPip = n;
        }
        (uint128 fromMapIndex, uint8 fromBitPos) = position(fromPip);
        (uint128 toMapIndex, uint8 toBitPos) = position(toPip);
        if (toMapIndex == fromMapIndex) {
            //            if(fromBitPos > toBitPos){
            //                uint8 n = fromBitPos;
            //                fromBitPos = toBitPos;
            //                toBitPos = n;
            //            }
            self[toMapIndex] &= unsetBitsFromLToR(
                MAX_UINT256,
                fromBitPos,
                toBitPos
            );
        } else {
            //TODO check overflow here
            fromBitPos--;
            self[fromMapIndex] &= ~toggleLastMBits(MAX_UINT256, fromBitPos);
            for (uint128 i = fromMapIndex + 1; i < toMapIndex; i++) {
                self[i] = 0;
            }
            self[toMapIndex] &= toggleLastMBits(MAX_UINT256, toBitPos);
        }
    }

    function toggleSingleBit(
        mapping(uint128 => uint256) storage self,
        uint128 pip,
        bool isSet
    ) internal {
        (uint128 mapIndex, uint8 bitPos) = position(pip);
        if (isSet) {
            self[mapIndex] |= 1 << bitPos;
        } else {
            self[mapIndex] &= ~(1 << bitPos);
        }
    }

    function unsetBitsFromLToR(
        uint256 _n,
        uint8 _l,
        uint8 _r
    ) private returns (uint256) {
        if (_l == 0) {
            // NOTE this code support unset at index 0 only
            // avoid overflow in the next line (_l - 1)
            _n |= 1;
            _l++;
        }
        // calculating a number 'num'
        // having 'r' number of bits
        // and bits in the range l
        // to r are the only set bits
        // Important NOTE this code could toggle 0 -> 1
        uint256 num = ((1 << _r) - 1) ^ ((1 << (_l - 1)) - 1);

        // toggle the bits in the
        // range l to r in 'n'
        // and return the number
        return (_n ^ num);
    }

    // Function to toggle the last m bits
    function toggleLastMBits(uint256 n, uint8 m) private returns (uint256) {
        // Calculating a number 'num' having
        // 'm' bits and all are set
        uint256 num = (1 << m) - 1;

        // Toggle the last m bits and
        // return the number
        return (n ^ num);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Timers {
    function passed(uint64 timer, uint256 _now) internal pure returns (bool) {
        return _now > timer;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "hardhat/console.sol";

library LimitOrder {
    struct Data {
        // Type order LONG or SHORT
        uint8 isBuy;
        uint120 size;
        // NOTICE need to add leverage
        uint120 partialFilled;
    }

    function getData(LimitOrder.Data storage self)
        internal
        view
        returns (
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        isBuy = self.isBuy == 1;
        size = uint256(self.size);
        partialFilled = uint256(self.partialFilled);
    }

    function update(
        LimitOrder.Data storage self,
        bool isBuy,
        uint256 size
    ) internal {
        self.isBuy = isBuy ? 1 : 2;
        self.size = uint120(size);
    }

    function updatePartialFill(
        LimitOrder.Data storage _self,
        uint120 _remainSize
    ) internal {
        // remainingSize should be negative
        _self.partialFilled += (_self.size - _self.partialFilled - _remainSize);
    }

    function updateWhenClose(LimitOrder.Data storage self)
        internal
        returns (uint256)
    {
        self.size -= self.partialFilled;
        self.partialFilled = 0;
        return (uint256(self.size));
    }

    function getPartialFilled(LimitOrder.Data storage self)
        internal
        view
        returns (bool isPartial, uint256 remainingSize)
    {
        remainingSize = self.size - self.partialFilled;
        isPartial = remainingSize > 0;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library U128Math {
    function add(uint128 a, uint128 b) internal pure returns (uint128) {
        return a + b;
    }

    function baseToQuote(
        uint128 quantity,
        uint128 pip,
        uint128 basisPoint
    ) internal pure returns (uint128) {
        return
            uint128((uint256(quantity) * uint256(pip)) / uint256(basisPoint));
    }

    function quoteToBase(
        uint128 quantity,
        uint128 pip,
        uint128 basisPoint
    ) internal pure returns (uint128) {
        return
            uint128((uint256(quantity) * uint256(basisPoint)) / uint256(pip));
    }

    function toU256(uint128 a) internal pure returns (uint256) {
        return uint256(a);
    }

    function toInt128(uint128 a) internal pure returns (int128) {
        return int128(a);
    }

    function toInt256(uint128 a) internal pure returns (int256) {
        return int256(int128(a));
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {
        return a - b;
    }

    function mul(uint128 a, uint256 b) internal pure returns (uint256) {
        return uint256(a) * b;
    }
}

pragma solidity ^0.8.0;

import "../spot-exchange/libraries/liquidity/PoolLiquidity.sol";
import "../spot-exchange/libraries/helper/BitMathLiquidity.sol";
import "../interfaces/ILiquidityPool.sol";

contract TestPoolLiquidityLibrary {
    PoolLiquidity.PoolLiquidityInfo public data;
    using PoolLiquidity for PoolLiquidity.PoolLiquidityInfo;
    using PoolLiquidity for bytes32[256];
    using PoolLiquidity for int256;
    using PoolLiquidity for int128;
    using PackedOrderId for uint128;

    uint128 public mockPrice;
    uint128 public constant PRICE_DENOMINATOR = 10**4;
    bytes32 hashID =
        0x0000000000000000000000000000000000000000000000000000000000000000;

    constructor() {
        data.soRemovablePosBuy = type(int128).max;
        data.soRemovablePosSell = type(int128).max;
    }

    function pushSupplyBuy(bytes32 value) public {
        ILiquidityPool.ReBalanceState memory reBalanceState = ILiquidityPool
            .ReBalanceState({
                soRemovablePosBuy: data.soRemovablePosBuy,
                soRemovablePosSell: data.soRemovablePosSell,
                claimableQuote: 0,
                claimableBase: 0,
                feeQuoteAmount: 0,
                feeBaseAmount: 0,
                pairManager: IPairManager(data.pairManager),
                poolId: hashID
            });
        data.supplyOrders.pushSupply(reBalanceState, value);
        data.soRemovablePosBuy = reBalanceState.soRemovablePosBuy;
    }

    function pushSupplySell(bytes32 value) public {
        ILiquidityPool.ReBalanceState memory reBalanceState = ILiquidityPool
            .ReBalanceState({
                soRemovablePosBuy: data.soRemovablePosBuy,
                soRemovablePosSell: data.soRemovablePosSell,
                claimableQuote: 0,
                claimableBase: 0,
                feeQuoteAmount: 0,
                feeBaseAmount: 0,
                pairManager: IPairManager(data.pairManager),
                poolId: hashID
            });
        data.supplyOrders.pushSupply(reBalanceState, value);
        data.soRemovablePosSell = reBalanceState.soRemovablePosSell;
    }

    function isNext(uint256 index) public view returns (bool isNext) {}

    function markSoRemovablePosBuy(uint8 n) public {
        data.soRemovablePosBuy = data.soRemovablePosBuy.markSoRemovablePos(n);
    }

    function markSoRemovablePosSell(uint8 n) public {
        data.soRemovablePosSell = data.soRemovablePosSell.markSoRemovablePos(n);
    }

    function getRightMostSoSell() public view returns (uint128) {
        return data.soRemovablePosSell.rightMostSetBitPos();
    }

    function getRightMostSoBuy() public view returns (uint128) {
        return data.soRemovablePosBuy.rightMostSetBitPos();
    }

    function getSupplyOrderAtIndex(uint8 index) public view returns (uint256) {
        return uint256(data.supplyOrders[index]);
    }

    function pack(
        uint128 pip,
        uint64 orderIdx,
        bool isBuy
    ) public view returns (bytes32) {
        return pip.pack(orderIdx, isBuy);
    }

    function calculateReturnAmounts(
        uint128 quoteDeposited,
        uint128 totalQuoteDeposited,
        uint128 poolBaseLiquidity,
        uint128 poolQuoteLiquidity
    ) public pure returns (uint128 baseAmount, uint128 quoteAmount) {
        return
            PoolLiquidity.calculateReturnAmounts(
                quoteDeposited,
                totalQuoteDeposited,
                poolBaseLiquidity,
                poolQuoteLiquidity
            );
    }

    // totalPoolLiquidityQ is the mock variable
    // the total pool liquidity in quote the pool is debt
    function mockDeposit(uint128 base, uint128 quote) public {
        //        data.updateAccPerShare(0);
        data.totalQuoteDeposited +=
            quote +
            (base * mockPrice) /
            PRICE_DENOMINATOR;
        data.quoteLiquidity += quote;
        data.baseLiquidity += base;
    }

    function mockRebalance(
        uint128 lastPoolLiquidityQ,
        uint128 LB,
        uint128 LQ
    ) public {
        // data.lastPoolLiquidityQ = lastPoolLiquidityQ;
        data.quoteLiquidity = LQ;
        data.baseLiquidity = LB;
    }

    function mockWithdraw(int128 userDepositQ, int128 debtAccPerShare) public {
        uint128 base;
        uint128 quote;
        //        (uint128 base, uint128 quote) = getUserBaseQuote(
        //            userDepositQ,
        //            debtAccPerShare
        //        );
        // withdraw need substruct the base and quote liquidity
        data.baseLiquidity -= base;
        data.quoteLiquidity -= quote;
        data.totalQuoteDeposited -= uint128(userDepositQ);
    }

    function mockUpdateAccPerShare() public {
        //        data.updateAccPerShare(0);
    }

    function setMockPrice(uint128 price) public {
        mockPrice = price;
    }

    function getUserPnl() public view returns (int256) {}

    function getUserBaseQuote(int128 userDepositQ, int128 debtAccPerShare)
        public
        view
        returns (uint128 base, uint128 quote)
    {
        return
            data.getUserBaseQuoteOut(
                // For test only, quote, base liquidity won't get from the poolData
                data.quoteLiquidity,
                data.baseLiquidity,
                getTotalPoolLiquidityQ(),
                uint128(
                    userDepositQ
                    //                    userDepositQ +
                    //                        data.getUserPnl(userDepositQ, debtAccPerShare)
                )
            );
    }

    function getTotalPoolLiquidityQ() public view returns (uint128) {
        return
            (data.baseLiquidity * mockPrice) /
            PRICE_DENOMINATOR +
            data.quoteLiquidity;
    }

    function getPoolPnl() public view returns (int128) {
        return 0;
        // return int128(getTotalPoolLiquidityQ() - data.lastPoolLiquidityQ);
    }

    function leftMostUnsetBitPos(int128 n) public view returns (uint8 count) {
        uint256 gasBefore = gasleft();
        count = PoolLiquidity.leftMostUnsetBitPos(n);
        console.log("gas used", gasBefore - gasleft());
    }

    function toggleToTestLeftMostUnset(uint16[] memory toggleList)
        public
        view
        returns (int128)
    {
        int128 MAX_UINT128 = type(int128).max;
        for (uint16 i = 0; i < toggleList.length; i++) {
            MAX_UINT128 &= ~int128(int256(1 << toggleList[i]));
        }
        return MAX_UINT128;
    }

    function countBitSet(int128 n) public pure returns (uint8 count) {
        return PoolLiquidity.countBitSet(n);
    }

    // @dev supports writing unit test for method clearBitPositionInt128
    function clearBitPositionInt128(int128 mask, uint8 position)
        public
        pure
        returns (int128)
    {
        return PoolLiquidity.clearBitPositionInt128(mask, position);
    }

    function countUnsetBit(int128 n) public view returns (uint8 count) {
        uint256 gasBefore = gasleft();
        count = PoolLiquidity.countUnsetBit(n);
        console.log("gas used", gasBefore - gasleft());
    }
}

/**
 * @author Musket
 */
pragma solidity ^0.8.0;
import "../spot-exchange/libraries/helper/BitMathLiquidity.sol";

contract TestBitMathLiquidity {
    function isNext(
        uint256 index,
        int128 soRemovablePosBuy,
        int128 soRemovablePosSell
    ) public view returns (bool isNext) {}
}

/**
 * @author Musket
 */
pragma solidity ^0.8.0;

import "../spot-exchange/PairManager.sol";

import "hardhat/console.sol";

import "../spot-exchange/libraries/helper/Convert.sol";
import "../spot-exchange/libraries/helper/TradeConvert.sol";
import "../spot-exchange/libraries/helper/BitMathLiquidity.sol";

contract MockPairManager02 is PairManager {
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);
    using Timers for uint64;
    using Convert for uint256;
    using Convert for int256;
    using TradeConvert for uint256;

    function takeOrder(
        uint128 pip,
        bool isBuy,
        IERC20 quoteAsset,
        IERC20 baseAsset,
        uint256 amount,
        uint64 orderId
    ) public {
        uint256 _liquidity;

        if (!isBuy) {
            _liquidity = quoteToBase(amount, pip);
        } else {
            _liquidity = amount;
        }
        uint128 liquidity = tickPosition[pip].liquidity;

        console.log("[SM] takeOrder liquidity: ", liquidity);
        console.log("[SM] takeOrder _liquidity: ", _liquidity);

        singleSlot.pip = pip;

        if (_liquidity == liquidity) {
            singleSlot.isFullBuy = 0;
            liquidityBitmap.toggleSingleBit(pip, false);

            if (isBuy) {
                uint256 quote = (_liquidity * pip) / basisPoint;
                quoteAsset.transferFrom(msg.sender, address(this), _liquidity);
            } else {
                baseAsset.transferFrom(msg.sender, address(this), _liquidity);
            }
        } else if (_liquidity < liquidity) {
            if (orderId != 0) {
                (
                    bool isFilled,
                    ,
                    uint256 baseSize,
                    uint256 partialFilled
                ) = getPendingOrderDetail(pip, orderId);

                console.log(
                    "[SM] takeOrder baseSize, _liquidity, pip: ",
                    baseSize,
                    _liquidity,
                    pip
                );
                _liquidity = baseSize - partialFilled;
            }
            if (isBuy) {
                singleSlot.isFullBuy = 2;
                uint256 quote = (_liquidity * pip) / basisPoint;
                console.log("[SM] takeOrder quote,", quote);
                quoteAsset.transferFrom(msg.sender, address(this), quote);
                tickPosition[pip].partiallyFill(_liquidity.Uint256ToUint128());
            } else {
                singleSlot.isFullBuy = 1;
                console.log("[SM] takeOrder _liquidity,", _liquidity);

                baseAsset.transferFrom(msg.sender, address(this), _liquidity);
                tickPosition[pip].partiallyFill(_liquidity.Uint256ToUint128());
            }

            //            if (liquidity - _liquidity <= 2) {
            //                singleSlot.isFullBuy = 0;
            //                liquidityBitmap.toggleSingleBit(pip, false);
            //
            //                if(isBuy) {
            //                    uint256 quote = (_liquidity * pip) / basisPoint;
            //                    quoteAsset.transferFrom(msg.sender, address(this),_liquidity);
            //                }else {
            //                    baseAsset.transferFrom(msg.sender, address(this), _liquidity);
            //                }
            //            }else {
            //                if(isBuy) {
            //                    singleSlot.isFullBuy = 2;
            //                    uint256 quote = (_liquidity * pip) / basisPoint;
            //                    console.log("[SM] takeOrder quote," ,quote);
            //                    quoteAsset.transferFrom(msg.sender, address(this), quote);
            //                    tickPosition[pip].partiallyFill(
            //                        _liquidity.Uint256ToUint128()
            //                    );
            //                }else {
            //                    singleSlot.isFullBuy = 1;
            //                    console.log("[SM] takeOrder _liquidity," ,_liquidity);
            //
            //                    baseAsset.transferFrom(msg.sender, address(this), _liquidity);
            //                    tickPosition[pip].partiallyFill(
            //                        _liquidity.Uint256ToUint128()
            //                    );
            //                }
            //
            //            }
        }

        console.log("takeOrder singleSlot.pip: ", singleSlot.pip);
    }

    function openLimitMock(
        uint128 pip,
        uint128 size,
        bool isBuy,
        address trader,
        IERC20 quoteAsset,
        IERC20 baseAsset
    ) public {
        _internalOpenLimit(
            ParamsInternalOpenLimit({
                pip: pip,
                size: size,
                isBuy: isBuy,
                trader: trader,
                quoteDeposited: 0
            })
        );

        if (isBuy) {
            quoteAsset.transfer(address(this), (size * pip) / basisPoint);
        } else {
            baseAsset.transfer(address(this), size);
        }
    }

    function openMarketMock(
        uint256 size,
        bool isBuy,
        address trader,
        IERC20 quoteAsset,
        IERC20 baseAsset
    ) external returns (uint256 sizeOut, uint256 quoteAmount) {
        console.log(
            "[SM] openMarketMock getLiquidityInCurrentPip1: ",
            getLiquidityInCurrentPip()
        );
        console.log(
            "[SM] openMarketMock singleSlot :",
            singleSlot.pip,
            singleSlot.isFullBuy
        );

        console.log(
            "SM tickPosition[101000].liquidity",
            tickPosition[101000].liquidity
        );
        (sizeOut, quoteAmount) = _internalOpenMarketOrder(
            size,
            isBuy,
            0,
            trader,
            true
        );
        console.log(
            "[SM] openMarketMock sizeOut, quoteAmount: ",
            sizeOut,
            quoteAmount
        );
        console.log(
            "[SM] openMarketMock getLiquidityInCurrentPip2: ",
            getLiquidityInCurrentPip()
        );

        if (isBuy) {
            quoteAsset.transfer(address(this), quoteAmount);
        } else {
            baseAsset.transfer(address(this), sizeOut);
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./libraries/exchange/TickPosition.sol";
import "./libraries/exchange/LimitOrder.sol";
import "./libraries/exchange/LiquidityBitmap.sol";
import "./libraries/types/PairManagerStorage.sol";
import "./libraries/helper/Timers.sol";
import "../interfaces/IPairManager.sol";
import "../interfaces/IPosiCallback.sol";
import "../interfaces/ILiquidityPool.sol";
import {Errors} from "./libraries/helper/Errors.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";
import "./implement/Block.sol";
import "./libraries/helper/Convert.sol";
import "./libraries/helper/PackedOrderId.sol";
import "./libraries/helper/TradeConvert.sol";
import "./libraries/helper/BitMathLiquidity.sol";

/// @title A PairManager stores all the information about the pairs and the liquidity
/// @author Position Exchange Team
/// @notice
/// @dev
contract PairManager is Initializable, IPairManager, Block, PairManagerStorage {
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);
    using Timers for uint64;
    using Convert for uint256;
    using Convert for int256;
    using PackedOrderId for uint128;
    using PackedOrderId for bytes32;
    using TradeConvert for uint256;

    modifier onlyCounterParty() {
        require(
            counterParty == _msgSender() || liquidityPoolAllowed[_msgSender()],
            Errors.VL_ONLY_COUNTERPARTY
        );
        _;
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), Errors.VL_ONLY_OWNER);
        _;
    }

    modifier onlyLiquidityPool() {
        require(liquidityPoolAllowed[_msgSender()], Errors.VL_ONLY_LIQUIDITY_POOL);
        _;
    }

    function initialize(
        address _quoteAsset,
        address _baseAsset,
        address _counterParty,
        uint256 _basisPoint,
        uint256 _BASE_BASIC_POINT,
        uint128 _maxFindingWordsIndex,
        uint128 _initialPip,
        uint64 _expireTime,
        address _liquidityPool
    ) public initializer {
        initializeFactory(
            _quoteAsset,
            _baseAsset,
            _counterParty,
            _basisPoint,
            _BASE_BASIC_POINT,
            _maxFindingWordsIndex,
            _initialPip,
            _expireTime,
            msg.sender,
            _liquidityPool
        );
    }

    function initializeFactory(
        address _quoteAsset,
        address _baseAsset,
        address _counterParty,
        uint256 _basisPoint,
        uint256 _BASE_BASIC_POINT,
        uint128 _maxFindingWordsIndex,
        uint128 _initialPip,
        uint64 _expireTime,
        address _owner,
        address _liquidityPool
    ) public override {
        require(_isInitialized == false, Errors.VL_MUST_NOT_INITIALIZABLE);

        reserveSnapshots.push(
            ReserveSnapshot(_initialPip, _blockTimestamp(), _blockNumber())
        );

        counterParty = _counterParty;
        quoteAsset = IERC20(_quoteAsset);
        baseAsset = IERC20(_baseAsset);
        singleSlot.pip = _initialPip;
        basisPoint = _basisPoint;
        BASE_BASIC_POINT = _BASE_BASIC_POINT;
        maxFindingWordsIndex = _maxFindingWordsIndex;
        maxWordRangeForLimitOrder = _maxFindingWordsIndex;
        maxWordRangeForMarketOrder = _maxFindingWordsIndex;
        expireTime = _expireTime;

        owner = _owner;
        liquidityPool = _liquidityPool;

        _isInitialized = true;

        _approve();
        emit PairManagerInitialized(
            _quoteAsset,
            _baseAsset,
            _counterParty,
            _basisPoint,
            _BASE_BASIC_POINT,
            _maxFindingWordsIndex,
            _initialPip,
            _expireTime,
            _owner
        );
    }

    //------------------------------------------------------------------------------------------------------------------
    // FUNCTIONS CALLED FROM LIQUIDITY POOL
    //------------------------------------------------------------------------------------------------------------------

    function collectFund(
        IERC20 token,
        address to,
        uint256 amount
    ) external override onlyLiquidityPool {
        _transfer(token, to, amount);
    }

    function cancelGridOrders(bytes32[] memory _orderIds)
        public
        override
        onlyLiquidityPool
        returns (uint256 base, uint256 quote)
    {
        uint256 _basisPoint = basisPoint;
        uint256 filledSize;

        for (uint256 i = 0; i < _orderIds.length; i++) {
            (uint128 _pip, uint64 _orderId, bool _isBuy) = _orderIds[i]
                .unpack();
            (bool isFilled, , uint256 baseSize, ) = getPendingOrderDetail(
                _pip,
                _orderId
            );
            if (isFilled) {
                // collect
                filledSize = baseSize;
                if (_isBuy) {
                    // buy -> claim base
                    base += filledSize;
                } else {
                    // sell -> claim quote
                    quote += filledSize.baseToQuote(_pip, _basisPoint);
                }
                delete tickPosition[_pip].orderQueue[_orderId];
            } else {
                // cancelget
                (
                    uint256 sizeLeft,
                    uint256 partialFilled
                ) = _internalCancelLimitOrder(_pip, _orderId);
                if (_isBuy) {
                    quote += sizeLeft.baseToQuote(_pip, _basisPoint);
                    base += partialFilled;
                } else {
                    base += sizeLeft;
                    quote += partialFilled.baseToQuote(_pip, _basisPoint);
                }
            }
        }

        // transfer fund to liquidityPool
        //        if(base > 0) { _transfer(baseAsset, liquidityPool, base);}
        //        if(quote > 0){ _transfer(quoteAsset, liquidityPool, quote);}
    }

    function accumulatePoolLiquidityClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        IPairManager.ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    )
        external
        virtual
        override
        onlyLiquidityPool
        returns (IPairManager.ExchangedData memory, bool isFilled)
    {
        (
            bool isFilled,
            bool isBuy,
            uint256 baseSize,
            uint256 partialFilled
        ) = getPendingOrderDetail(_pip, _orderId);

        if (isFilled) {
            if (isBuy) {
                //BUY => can claim base asset
                exData.baseAmount += baseSize;
                exData.feeQuoteAmount += _feeRefundCalculator(
                    baseSize.baseToQuote(_pip, basisPoint),
                    fee,
                    feeBasis
                );
            } else {
                // SELL => can claim quote asset
                exData.quoteAmount += baseSize.baseToQuote(_pip, basisPoint);
                exData.feeBaseAmount += _feeRefundCalculator(
                    baseSize,
                    fee,
                    feeBasis
                );
            }
        } else if (partialFilled > 0) {
            if (isBuy) {
                exData.baseAmount += partialFilled;
            } else {
                exData.quoteAmount += partialFilled.baseToQuote(
                    _pip,
                    basisPoint
                );
            }
            tickPosition[_pip].updateOrderWhenClose(_orderId);
        }
        return (exData, isFilled);
    }

    function supplyGridOrder(
        Grid.GridOrderData[] memory orders,
        address user,
        bytes memory data,
        bytes32 poolId
    )
        external
        override
        onlyLiquidityPool
        returns (
            uint256 baseAmountUsed,
            uint256 quoteAmountUsed,
            bytes32[] memory orderIds
        )
    {
        (baseAmountUsed, quoteAmountUsed, orderIds) = _supplyGridOrder(orders);

        // if user is the liquidityPool
        // only transfer in the liquidityPool's balance
        // don't need to transfer the whole amount used

        if (liquidityPoolAllowed[user]) {
            (uint128 claimableQuote, uint128 claimableBase) = abi.decode(
                data,
                (uint128, uint128)
            );

            uint256 baseClaimed;
            uint256 quoteClaimed;

            // claimable amount already in the PairManager
            if (baseAmountUsed > uint256(claimableBase)) {
                baseAmountUsed = baseAmountUsed - uint256(claimableBase);
            } else {
                baseClaimed = uint256(claimableBase) - baseAmountUsed;
                baseAmountUsed = 0;

                if (baseClaimed > 0) {
                    _transfer(baseAsset, user, baseClaimed);
                }
            }

            if (quoteAmountUsed > uint256(claimableQuote)) {
                quoteAmountUsed = quoteAmountUsed - uint256(claimableQuote);
            } else {
                quoteClaimed = uint256(claimableQuote) - quoteAmountUsed;
                quoteAmountUsed = 0;

                if (quoteClaimed > 0) {
                    _transfer(quoteAsset, user, quoteClaimed);
                }
            }

            ILiquidityPool(user).receiveQuoteAndBase(
                poolId,
                uint128(baseClaimed),
                uint128(quoteClaimed)
            );
        }

        uint256 baseAmountBefore;
        uint256 quoteAmountBefore;
        if (baseAmountUsed > 0) baseAmountBefore = balanceBase();
        if (quoteAmountUsed > 0) quoteAmountBefore = balanceQuote();
        // callback to deposit funds
        IPosiCallback(msg.sender).posiAddLiquidityCallback(
            baseAsset,
            quoteAsset,
            baseAmountUsed,
            quoteAmountUsed,
            user
        );
        // ensure the balance is correct
        // currently doesn't support reflaction tokens
        if (baseAmountUsed > 0)
            require(balanceBase() >= baseAmountBefore + baseAmountUsed, "!BB");
        if (quoteAmountUsed > 0)
            require(
                balanceQuote() >= quoteAmountBefore + quoteAmountUsed,
                "!BQ"
            );
    }

    //------------------------------------------------------------------------------------------------------------------
    // FUNCTIONS CALLED FROM SPOT HOUSE
    //------------------------------------------------------------------------------------------------------------------

    function updatePartialFilledOrder(uint128 pip, uint64 orderId)
        external
        override
        onlyCounterParty
    {
        uint256 newSize = tickPosition[pip].updateOrderWhenClose(orderId);
        emit LimitOrderUpdated(address(this), orderId, pip, newSize);
    }

    function cancelLimitOrder(uint128 pip, uint64 orderId)
        external
        override
        onlyCounterParty
        returns (uint256 remainingSize, uint256 partialFilled)
    {
        return _internalCancelLimitOrder(pip, orderId);
    }

    function openLimit(
        uint128 pip,
        uint128 size,
        bool isBuy,
        address trader,
        uint256 quoteDeposited
    )
        external
        override
        onlyCounterParty
        returns (
            uint64 orderId,
            uint256 sizeOut,
            uint256 quoteAmount
        )
    {
        (orderId, sizeOut, quoteAmount) = _internalOpenLimit(
            ParamsInternalOpenLimit({
                pip: pip,
                size: size,
                isBuy: isBuy,
                trader: trader,
                quoteDeposited: quoteDeposited
            })
        );
    }

    function openMarket(
        uint256 size,
        bool isBuy,
        address trader
    )
        external
        override
        onlyCounterParty
        returns (uint256 sizeOut, uint256 quoteAmount)
    {
        return _internalOpenMarketOrder(size, isBuy, 0, trader, true);
    }

    function openMarketWithQuoteAsset(
        uint256 quoteAmount,
        bool _isBuy,
        address _trader
    )
        external
        override
        onlyCounterParty
        returns (uint256 sizeOutQuote, uint256 baseAmount)
    {
        (sizeOutQuote, baseAmount) = _internalOpenMarketOrder(
            quoteAmount,
            _isBuy,
            0,
            _trader,
            false
        );
    }

    function decreaseBaseFeeFunding(uint256 baseFee)
        external
        override
        onlyCounterParty
    {
        if (baseFee > 0) {
            baseFeeFunding -= baseFee;
        }
    }

    function decreaseQuoteFeeFunding(uint256 quoteFee)
        external
        override
        onlyCounterParty
    {
        if (quoteFee > 0) {
            quoteFeeFunding -= quoteFee;
        }
    }

    function increaseBaseFeeFunding(uint256 baseFee)
        external
        override
        onlyCounterParty
    {
        if (baseFee > 0) {
            baseFeeFunding += baseFee;
        }
    }

    function increaseQuoteFeeFunding(uint256 quoteFee)
        external
        override
        onlyCounterParty
    {
        if (quoteFee > 0) {
            quoteFeeFunding += quoteFee;
        }
    }

    function resetFee(uint256 baseFee, uint256 quoteFee)
        external
        override
        onlyCounterParty
    {
        baseFeeFunding -= baseFee;
        quoteFeeFunding -= quoteFee;
    }

    //------------------------------------------------------------------------------------------------------------------
    // VIEW FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function getAmountEstimate(
        uint256 size,
        bool isBuy,
        bool isBase
    ) external view override returns (uint256 sizeOut, uint256 openOtherSide) {
        //save gas
        SwapState memory state = SwapState({
            remainingSize: size,
            pip: singleSlot.pip,
            basisPoint: basisPoint.Uint256ToUint32(),
            baseBasisPoint: BASE_BASIC_POINT.Uint256ToUint32(),
            startPip: 0,
            remainingLiquidity: 0,
            isFullBuy: 0,
            isSkipFirstPip: false,
            lastMatchedPip: singleSlot.pip
        });
        {
            CurrentLiquiditySide currentLiquiditySide = CurrentLiquiditySide(
                singleSlot.isFullBuy
            );
            if (currentLiquiditySide != CurrentLiquiditySide.NotSet) {
                if (isBuy)
                    // if buy and latest liquidity is buy. skip current pip
                    state.isSkipFirstPip =
                        currentLiquiditySide == CurrentLiquiditySide.Buy;
                    // if sell and latest liquidity is sell. skip current pip
                else
                    state.isSkipFirstPip =
                        currentLiquiditySide == CurrentLiquiditySide.Sell;
            }
        }
        while (state.remainingSize != 0) {
            StepComputations memory step;
            (step.pipNext) = liquidityBitmap.findHasLiquidityInMultipleWords(
                state.pip,
                maxFindingWordsIndex,
                !isBuy
            );
            // updated findHasLiquidityInMultipleWords, save more gas
            //            if (maxPip != 0) {
            //                // if order is buy and step.pipNext (pip has liquidity) > maxPip then break cause this is limited to maxPip and vice versa
            //                if (
            //                    (isBuy && step.pipNext > maxPip) ||
            //                    (!isBuy && step.pipNext < maxPip)
            //                ) {
            //                    break;
            //                }
            //            }
            if (step.pipNext == 0) {
                // no more next pip
                // state pip back 1 pip
                if (isBuy) {
                    state.pip--;
                } else {
                    state.pip++;
                }
                break;
            } else {
                if (!state.isSkipFirstPip) {
                    if (state.startPip == 0) state.startPip = step.pipNext;

                    // get liquidity at a tick index
                    uint128 liquidity = tickPosition[step.pipNext].liquidity;
                    //                    if (maxPip != 0) {
                    //                        state.lastMatchedPip = step.pipNext;
                    //                    }
                    uint256 baseAmount = isBase
                        ? state.remainingSize
                        : quoteToBase(state.remainingSize, step.pipNext);
                    if (liquidity > baseAmount) {
                        if (isBase)
                            openOtherSide += calculatingQuoteAmountV2(
                                state.remainingSize,
                                step.pipNext,
                                state.baseBasisPoint,
                                state.basisPoint
                            );
                        else openOtherSide += baseAmount;

                        state.remainingSize = 0;
                        state.pip = step.pipNext;
                    } else if (baseAmount > liquidity) {
                        // order in that pip will be fulfilled
                        if (isBase) {
                            state.remainingSize -= liquidity;
                            openOtherSide += calculatingQuoteAmountV2(
                                liquidity,
                                step.pipNext,
                                state.baseBasisPoint,
                                state.basisPoint
                            );
                        } else {
                            state.remainingSize -= calculatingQuoteAmountV2(
                                liquidity,
                                step.pipNext,
                                state.baseBasisPoint,
                                state.basisPoint
                            );
                            openOtherSide += liquidity;
                        }
                        state.pip = isBuy ? step.pipNext + 1 : step.pipNext - 1;
                    } else {
                        if (isBase) {
                            openOtherSide += calculatingQuoteAmountV2(
                                state.remainingSize,
                                step.pipNext,
                                state.baseBasisPoint,
                                state.basisPoint
                            );
                        } else {
                            openOtherSide += liquidity;
                        }
                        state.remainingSize = 0;
                    }
                } else {
                    state.isSkipFirstPip = false;
                    state.pip = isBuy ? step.pipNext + 1 : step.pipNext - 1;
                }
            }
        }

        sizeOut = size - state.remainingSize;
    }

    function accumulateClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        IPairManager.ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view override returns (IPairManager.ExchangedData memory) {
        (
            bool isFilled,
            bool isBuy,
            uint256 baseSize,
            uint256 partialFilled
        ) = getPendingOrderDetail(_pip, _orderId);
        uint256 filledSize = isFilled ? baseSize : partialFilled;
        {
            if (isBuy) {
                //BUY => can claim base asset
                exData.baseAmount += filledSize;
                //                exData.feeQuoteAmount += _feeRefundCalculator(
                //                    filledSize.baseToQuote(_pip, basisPoint),
                //                    fee,
                //                    feeBasis
                //                );
            } else {
                // SELL => can claim quote asset
                exData.quoteAmount += filledSize.baseToQuote(_pip, basisPoint);
                //                exData.feeBaseAmount += _feeRefundCalculator(
                //                    filledSize,
                //                    fee,
                //                    feeBasis
                //                );
            }
        }
        return exData;
    }

    function accumulatePoolExchangedData(
        bytes32[256] memory _orderIds,
        uint16 _feeShareRatio,
        uint128 _feeBasis,
        int128 soRemovablePosBuy,
        int128 soRemovablePosSell
    ) external view override returns (int128 quoteAdjust, int128 baseAdjust) {
        IPairManager.AccPoolExchangedDataParams memory _d;
        _d.basisPoint = basisPoint;
        _d.currentPip = singleSlot.pip;

        int256 packSo = BitMathLiquidity.packInt128AndIn128(
            soRemovablePosBuy,
            soRemovablePosSell
        );

        uint8 countBitHasSupply = uint8(
            255 - PoolLiquidity.countBitSet(uint256(packSo))
        );
        uint128 posTemp;

        while (countBitHasSupply != 0) {
            posTemp = PoolLiquidity
                .rightMostUnSetBitPosInt256(packSo)
                .Uint256ToUint128();
            packSo = PoolLiquidity.markSoRemovablePosInt256(packSo, posTemp);
            countBitHasSupply--;
            if (posTemp == 127 || posTemp == 255) {
                continue;
            }
            _d.orderId = _orderIds[posTemp];

            _accumulatePoolExchangedData(_d, _feeShareRatio, _feeBasis);
        }

        return (_d.quoteAdjust, _d.baseAdjust);
    }

    function getFee() external view override returns (uint256, uint256) {
        return (baseFeeFunding, quoteFeeFunding);
    }

    //    function isExpired() external view override returns (bool) {
    //        // If not set expireTime for this pair
    //        // expireTime is 0 and unlimited time to expire
    //        if (expireTime == 0) {
    //            return false;
    //        }
    //        return expireTime.passed(_blockTimestamp());
    //    }

    function getBaseBasisPoint() public view override returns (uint256) {
        return BASE_BASIC_POINT;
    }

    function getBasisPoint() public view override returns (uint256) {
        return basisPoint;
    }

    function getCurrentPipAndBasisPoint()
        public
        view
        override
        returns (uint128, uint128)
    {
        return (singleSlot.pip, uint128(basisPoint));
    }

    function getCurrentPip() public view override returns (uint128) {
        return singleSlot.pip;
    }

    function getCurrentSingleSlot()
        public
        view
        override
        returns (uint128, uint8)
    {
        return (singleSlot.pip, singleSlot.isFullBuy);
    }

    function getPrice() public view override returns (uint256) {
        return (uint256(singleSlot.pip) * BASE_BASIC_POINT) / basisPoint;
    }

    function getQuoteAsset() public view override returns (IERC20) {
        return quoteAsset;
    }

    function getBaseAsset() public view override returns (IERC20) {
        return baseAsset;
    }

    function pipToPrice(uint128 pip) public view override returns (uint256) {
        return (uint256(pip) * BASE_BASIC_POINT) / basisPoint;
    }

    function pipToPriceV2(
        uint128 pip,
        uint256 baseBasisPoint,
        uint256 basisPoint
    ) public view returns (uint256) {
        return (uint256(pip) * baseBasisPoint) / basisPoint;
    }

    function calculatingQuoteAmount(uint256 quantity, uint128 pip)
        public
        view
        override
        returns (uint256)
    {
        return TradeConvert.baseToQuote(quantity, pip, basisPoint);
    }

    function calculatingQuoteAmountV2(
        uint256 quantity,
        uint128 pip,
        uint256 baseBasisPoint,
        uint256 basisPoint
    ) public view returns (uint256) {
        return
            (quantity * pipToPriceV2(pip, baseBasisPoint, basisPoint)) /
            baseBasisPoint;
    }

    function getLiquidityInCurrentPip() public view override returns (uint128) {
        return
            liquidityBitmap.hasLiquidity(singleSlot.pip)
                ? tickPosition[singleSlot.pip].liquidity
                : 0;
    }

    function hasLiquidity(uint128 pip) public view override returns (bool) {
        return liquidityBitmap.hasLiquidity(pip);
    }

    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        public
        view
        virtual
        override
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        (isFilled, isBuy, size, partialFilled) = tickPosition[pip]
            .getQueueOrder(orderId);

        if (!liquidityBitmap.hasLiquidity(pip)) {
            isFilled = true;
        }
        if (size != 0 && size == partialFilled) {
            isFilled = true;
        }
    }

    function getLiquidityInPipRange(
        uint128 fromPip,
        uint256 dataLength,
        bool toHigher
    ) external view override returns (LiquidityOfEachPip[] memory, uint128) {
        uint128[] memory allInitializedPip = new uint128[](uint128(dataLength));
        allInitializedPip = liquidityBitmap.findAllLiquidityInMultipleWords(
            fromPip,
            dataLength,
            toHigher
        );
        LiquidityOfEachPip[] memory allLiquidity = new LiquidityOfEachPip[](
            dataLength
        );

        for (uint256 i = 0; i < dataLength; i++) {
            allLiquidity[i] = LiquidityOfEachPip({
                pip: allInitializedPip[i],
                liquidity: tickPosition[allInitializedPip[i]].liquidity
            });
        }
        return (allLiquidity, allInitializedPip[dataLength - 1]);
    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function updateSpotHouse(address _newSpotHouse)
        external
        override
        onlyOwner
    {
        counterParty = _newSpotHouse;
        _approve();
    }

    function updateMaxWordRangeForLimitOrder(
        uint128 _newMaxWordRangeForLimitOrder
    ) external onlyOwner {
        maxWordRangeForLimitOrder = _newMaxWordRangeForLimitOrder;
    }

    function updateMaxWordRangeForMarketOrder(
        uint128 _newMaxWordRangeForMarketOrder
    ) external onlyOwner {
        maxWordRangeForMarketOrder = _newMaxWordRangeForMarketOrder;
    }

    function updateMaxFindingWordsIndex(uint128 _newMaxFindingWordsIndex)
        external
        override
        onlyOwner
    {
        maxFindingWordsIndex = _newMaxFindingWordsIndex;
        emit UpdateMaxFindingWordsIndex(
            address(this),
            _newMaxFindingWordsIndex
        );
    }

    //    function updateExpireTime(uint64 _expireTime) external override onlyOwner {
    //        expireTime = _expireTime;
    //        emit UpdateExpireTime(address(this), _expireTime);
    //    }

    // function updateLiquidityPool(address newLiquidityPool) external onlyOwner {
    //     liquidityPool = newLiquidityPool;
    // }

    function updateLiquidityPoolAllowance(address liquidityPool, bool isAllow) external onlyOwner {
        emit LiquidityPoolAllowanceUpdate(liquidityPool, isAllow);
        liquidityPoolAllowed[liquidityPool] = isAllow;
    }

    //------------------------------------------------------------------------------------------------------------------
    // INTERNAL FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function _transfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        if (amount > 0) token.transfer(to, amount);
    }

    function _internalCancelLimitOrder(uint128 pip, uint64 orderId)
        internal
        returns (uint256 remainingSize, uint256 partialFilled)
    {
        bool isBuy;
        (remainingSize, partialFilled, isBuy) = tickPosition[pip]
            .cancelLimitOrder(orderId);
        if (tickPosition[pip].liquidity == 0) {
            liquidityBitmap.toggleSingleBit(pip, false);

            if (pip == getCurrentPip()) {
                singleSlot.isFullBuy = 0;
            }
        }
        emit LimitOrderCancelled(isBuy, orderId, pip, remainingSize);
    }

    function _accumulatePoolExchangedData(
        AccPoolExchangedDataParams memory params,
        uint16 _feeShareRatio,
        uint128 _feeBasis
    ) internal view {
        (uint128 _pip, uint64 _orderId, bool isBuy) = params.orderId.unpack();
        (
            bool isFilled,
            ,
            uint256 baseSize,
            uint256 partialFilled
        ) = getPendingOrderDetail(_pip, _orderId);
        uint256 filledSize = isFilled ? baseSize : partialFilled;
        if (isBuy) {
            //BUY => can claim base asset
            params.baseAdjust += filledSize.toI128();
            // sub quote and plus quote fee
            params.quoteAdjust -= (filledSize
                .baseToQuote(_pip, params.basisPoint)
                .toI128() -
                _feeRefundCalculator(
                    filledSize.baseToQuote(_pip, params.basisPoint),
                    _feeShareRatio,
                    _feeBasis
                ).toI128());
        } else {
            // SELL => can claim quote asset
            params.quoteAdjust += filledSize
                .baseToQuote(_pip, params.basisPoint)
                .toI128();
            //            if(_pip == params.currentPip){
            //                params.baseFilledCurrentPip -= filledSize.toI128();
            //            }

            params.baseAdjust -= (filledSize.toI128() -
                _feeRefundCalculator(baseSize, _feeShareRatio, _feeBasis)
                    .toI128());
        }
    }

    function _feeRefundCalculator(
        uint256 _amount,
        uint16 _fee,
        uint128 _feeBasis
    ) internal view returns (uint256 feeRefund) {
        if (_amount == 0 || _feeBasis == 0) return 0;
        feeRefund = (_amount * _fee) / (_feeBasis - _fee);
    }

    function _supplyGridOrder(Grid.GridOrderData[] memory orders)
        internal
        returns (
            uint256 baseAmountUsed,
            uint256 quoteAmountUsed,
            bytes32[] memory orderIds
        )
    {
        SingleSlot memory _singleSlot = singleSlot;
        uint256 _basisPoint = basisPoint;
        uint128 size;
        orderIds = new bytes32[](orders.length);
        for (uint256 i = 0; i < orders.length; i++) {
            Grid.GridOrderData memory _order = orders[i];
            bool isBuy = _order.amount < 0;
            bool hasLiquidity = liquidityBitmap.hasLiquidity(_order.pip);
            // skip
            // if orderPip == currentPip && hasLiquidityCurrentPip && !side
            // if isBuy but orderPip > currentPip
            // if isSell but orderPip < currentPip
            // if amount  == 0
            // if pip == 0
            if (
                (_order.pip == _singleSlot.pip &&
                    hasLiquidity &&
                    _singleSlot.isFullBuy != (isBuy ? 1 : 2)) ||
                (isBuy && _order.pip > _singleSlot.pip) ||
                (!isBuy && _order.pip < _singleSlot.pip) ||
                _order.amount == 0 ||
                _order.pip == 0
            ) {
                continue;
            }
            if (isBuy) {
                size = quoteToBaseV2(
                    uint256(-_order.amount),
                    _order.pip,
                    _basisPoint
                ).Uint256ToUint128();
                quoteAmountUsed += uint256(-_order.amount);
            } else {
                size = uint256(_order.amount).Uint256ToUint128();

                baseAmountUsed += size;
            }

            uint64 orderId = tickPosition[_order.pip].insertLimitOrder(
                size,
                hasLiquidity,
                isBuy
            );
            orderIds[i] = _order.pip.pack(orderId, isBuy);
            if (!hasLiquidity) {
                //set the bit to mark it has liquidity
                liquidityBitmap.toggleSingleBit(_order.pip, true);
            }
            emit LimitOrderCreated(orderId, _order.pip, size, isBuy);
        }
    }

    function emitEventSwap(
        bool isBuy,
        uint256 _baseAmount,
        uint256 _quoteAmount,
        address _trader
    ) internal {
        uint256 amount0In;
        uint256 amount1In;
        uint256 amount0Out;
        uint256 amount1Out;

        if (isBuy) {
            amount1In = _quoteAmount;
            amount0Out = _baseAmount;
        } else {
            amount0In = _baseAmount;
            amount1Out = _quoteAmount;
        }
        emit Swap(
            msg.sender,
            amount0In,
            amount1In,
            amount0Out,
            amount1Out,
            _trader
        );
    }

    function quoteToBase(uint256 quoteAmount, uint128 pip)
        public
        view
        override
        returns (uint256)
    {
        return (quoteAmount * basisPoint) / pip;
    }

    function quoteToBaseV2(
        uint256 quoteAmount,
        uint128 pip,
        uint256 basisPoint
    ) public view returns (uint256) {
        return (quoteAmount * basisPoint) / pip;
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _approve() internal {
        quoteAsset.approve(counterParty, type(uint256).max);
        baseAsset.approve(counterParty, type(uint256).max);
    }

    struct SwapState {
        uint256 remainingSize;
        // the tick associated with the current price
        uint128 pip;
        uint32 basisPoint;
        uint32 baseBasisPoint;
        uint128 startPip;
        uint128 remainingLiquidity;
        uint8 isFullBuy;
        bool isSkipFirstPip;
        uint128 lastMatchedPip;
    }

    function _openMarketWithMaxPip(
        uint256 size,
        bool isBuy,
        uint128 maxPip,
        address _trader
    ) internal returns (uint256 sizeOut, uint256 quoteAmount) {
        // plus 1 avoid  (singleSlot.pip - maxPip)/250 = 0
        uint128 _maxFindingWordsIndex = ((
            isBuy ? maxPip - singleSlot.pip : singleSlot.pip - maxPip
        ) / 250) + 1;
        return
            _internalOpenMarketOrderWithMaxFindingWord(
                size,
                isBuy,
                maxPip,
                address(0),
                true,
                _maxFindingWordsIndex
            );
    }

    function _internalOpenMarketOrder(
        uint256 _size,
        bool _isBuy,
        uint128 _maxPip,
        address _trader,
        bool _isBase
    ) internal returns (uint256 sizeOut, uint256 openOtherSide) {
        return
            _internalOpenMarketOrderWithMaxFindingWord(
                _size,
                _isBuy,
                _maxPip,
                _trader,
                _isBase,
                maxFindingWordsIndex
            );
    }

    function _internalOpenMarketOrderWithMaxFindingWord(
        uint256 _size,
        bool _isBuy,
        uint128 _maxPip,
        address _trader,
        bool _isBase,
        uint128 _maxFindingWordsIndex
    ) internal returns (uint256 sizeOut, uint256 openOtherSide) {
        // get current tick liquidity
        SingleSlot memory _initialSingleSlot = singleSlot;
        //save gas
        SwapState memory state = SwapState({
            remainingSize: _size,
            pip: _initialSingleSlot.pip,
            basisPoint: basisPoint.Uint256ToUint32(),
            baseBasisPoint: BASE_BASIC_POINT.Uint256ToUint32(),
            startPip: 0,
            remainingLiquidity: 0,
            isFullBuy: 0,
            isSkipFirstPip: false,
            lastMatchedPip: _initialSingleSlot.pip
        });
        {
            CurrentLiquiditySide currentLiquiditySide = CurrentLiquiditySide(
                _initialSingleSlot.isFullBuy
            );
            if (currentLiquiditySide != CurrentLiquiditySide.NotSet) {
                if (_isBuy)
                    // if buy and latest liquidity is buy. skip current pip
                    state.isSkipFirstPip =
                        currentLiquiditySide == CurrentLiquiditySide.Buy;
                    // if sell and latest liquidity is sell. skip current pip
                else
                    state.isSkipFirstPip =
                        currentLiquiditySide == CurrentLiquiditySide.Sell;
            }
        }
        while (state.remainingSize != 0) {
            StepComputations memory step;
            (step.pipNext) = liquidityBitmap.findHasLiquidityInMultipleWords(
                state.pip,
                _maxFindingWordsIndex,
                !_isBuy
            );
            // updated findHasLiquidityInMultipleWords, save more gas
            if (_maxPip != 0) {
                // if order is buy and step.pipNext (pip has liquidity) > maxPip then break cause this is limited to maxPip and vice versa
                if (
                    (_isBuy && step.pipNext > _maxPip) ||
                    (!_isBuy && step.pipNext < _maxPip)
                ) {
                    break;
                }
            }
            if (step.pipNext == 0) {
                // no more next pip
                // state pip back 1 pip
                if (_isBuy) {
                    state.pip--;
                } else {
                    state.pip++;
                }
                break;
            } else {
                if (!state.isSkipFirstPip) {
                    if (state.startPip == 0) state.startPip = step.pipNext;

                    // get liquidity at a tick index
                    uint128 liquidity = tickPosition[step.pipNext].liquidity;
                    if (_maxPip != 0) {
                        state.lastMatchedPip = step.pipNext;
                    }
                    uint256 baseAmount = _isBase
                        ? state.remainingSize
                        : quoteToBase(state.remainingSize, step.pipNext);
                    if (liquidity > baseAmount) {
                        // pip position will partially filled and stop here
                        tickPosition[step.pipNext].partiallyFill(
                            baseAmount.Uint256ToUint128()
                        );
                        if (_isBase)
                            openOtherSide += calculatingQuoteAmountV2(
                                state.remainingSize,
                                step.pipNext,
                                state.baseBasisPoint,
                                state.basisPoint
                            );
                        else openOtherSide += baseAmount;

                        // remaining liquidity at current pip
                        state.remainingLiquidity =
                            liquidity -
                            baseAmount.Uint256ToUint128();
                        state.remainingSize = 0;
                        state.pip = step.pipNext;
                        state.isFullBuy = uint8(
                            !_isBuy
                                ? CurrentLiquiditySide.Buy
                                : CurrentLiquiditySide.Sell
                        );
                    } else if (baseAmount > liquidity) {
                        // order in that pip will be fulfilled
                        if (_isBase) {
                            state.remainingSize -= liquidity;
                            openOtherSide += calculatingQuoteAmountV2(
                                liquidity,
                                step.pipNext,
                                state.baseBasisPoint,
                                state.basisPoint
                            );
                        } else {
                            state.remainingSize -= calculatingQuoteAmountV2(
                                liquidity,
                                step.pipNext,
                                state.baseBasisPoint,
                                state.basisPoint
                            );
                            openOtherSide += liquidity;
                        }
                        state.pip = _isBuy
                            ? step.pipNext + 1
                            : step.pipNext - 1;
                    } else {
                        // remaining size = liquidity
                        // only 1 pip should be toggled, so we call it directly here
                        liquidityBitmap.toggleSingleBit(step.pipNext, false);
                        if (_isBase) {
                            openOtherSide += calculatingQuoteAmountV2(
                                state.remainingSize,
                                step.pipNext,
                                state.baseBasisPoint,
                                state.basisPoint
                            );
                        } else {
                            openOtherSide += liquidity;
                        }
                        state.remainingSize = 0;
                        state.pip = step.pipNext;
                        state.isFullBuy = 0;
                    }
                } else {
                    state.isSkipFirstPip = false;
                    state.pip = _isBuy ? step.pipNext + 1 : step.pipNext - 1;
                }
            }
        }
        {
            if (
                _initialSingleSlot.pip != state.pip &&
                state.remainingSize != _size
            ) {
                // all ticks in shifted range must be marked as filled
                if (
                    !(state.remainingLiquidity > 0 &&
                        state.startPip == state.pip)
                ) {
                    if (_maxPip != 0) {
                        state.pip = state.lastMatchedPip;
                    }
                    liquidityBitmap.unsetBitsRange(
                        state.startPip,
                        state.remainingLiquidity > 0
                            ? (_isBuy ? state.pip - 1 : state.pip + 1)
                            : state.pip
                    );
                }
                // TODO write a checkpoint that we shift a range of ticks
            } else if (
                _maxPip != 0 &&
                _initialSingleSlot.pip == state.pip &&
                state.remainingSize < _size &&
                state.remainingSize != 0
            ) {
                // if limit order with max pip filled current pip, toggle current pip to initialized
                // after that when create new limit order will initialize pip again in `OpenLimitPosition`
                liquidityBitmap.toggleSingleBit(state.pip, false);
            }

            if (state.remainingSize != _size) {
                // if limit order with max pip filled other order, update isFullBuy
                singleSlot.isFullBuy = state.isFullBuy;
            }
            if (_maxPip != 0) {
                // if limit order still have remainingSize, change current price to limit price
                // else change current price to last matched pip
                singleSlot.pip = state.remainingSize != 0
                    ? _maxPip
                    : state.lastMatchedPip;
            } else {
                singleSlot.pip = state.pip;
            }
        }

        sizeOut = _size - state.remainingSize;
        //        _addReserveSnapshot();

        if (sizeOut != 0) {
            emit MarketFilled(
                _isBuy,
                _isBase ? sizeOut : openOtherSide,
                singleSlot.pip,
                state.startPip,
                state.remainingLiquidity,
                tickPosition[singleSlot.pip].calculatingFilledIndex()
            );
            emitEventSwap(_isBuy, sizeOut, openOtherSide, _trader);
        }
    }

    struct ParamsInternalOpenLimit {
        uint128 pip;
        uint128 size;
        bool isBuy;
        address trader;
        uint256 quoteDeposited;
    }

    function _internalOpenLimit(ParamsInternalOpenLimit memory _params)
        internal
        returns (
            uint64 orderId,
            uint256 sizeOut,
            uint256 quoteAmount
        )
    {
        require(_params.size != 0, Errors.VL_INVALID_SIZE);
        SingleSlot memory _singleSlot = singleSlot;

        {
            if (_params.isBuy) {
                int128 maxPip = int128(_singleSlot.pip) -
                    int128(maxWordRangeForLimitOrder * 250);
                if (maxPip > 0) {
                    require(
                        int128(_params.pip) >= maxPip,
                        Errors.VL_MUST_CLOSE_TO_INDEX_PRICE_LONG
                    );
                } else {
                    require(
                        _params.pip >= 1,
                        Errors.VL_MUST_CLOSE_TO_INDEX_PRICE_LONG
                    );
                }
            } else {
                require(
                    _params.pip >= 1,
                    Errors.VL_MUST_CLOSE_TO_INDEX_PRICE_LONG
                );
                require(
                    _params.pip <=
                        (_singleSlot.pip + maxWordRangeForLimitOrder * 250),
                    Errors.VL_MUST_CLOSE_TO_INDEX_PRICE_SHORT
                );
            }
            bool hasLiquidity = liquidityBitmap.hasLiquidity(_params.pip);
            //save gas
            {
                bool canOpenMarketWithMaxPip = (_params.isBuy &&
                    _params.pip >= _singleSlot.pip) ||
                    (!_params.isBuy && _params.pip <= _singleSlot.pip);
                if (canOpenMarketWithMaxPip) {
                    // TODO use the following code to calculate slippage
                    //                if(isBuy){
                    //                    // higher pip when long must lower than max word range for market order short
                    //                    require(_pip <= _singleSlot.pip + maxWordRangeForMarketOrder * 250, Errors.VL_MARKET_ORDER_MUST_CLOSE_TO_INDEX_PRICE);
                    //                }else{
                    //                    // lower pip when short must higher than max word range for market order long
                    //                    require(int128(_pip) >= (int256(_singleSlot.pip) - int128(maxWordRangeForMarketOrder * 250)), Errors.VL_MARKET_ORDER_MUST_CLOSE_TO_INDEX_PRICE);
                    //                }
                    // open market
                    (sizeOut, quoteAmount) = _openMarketWithMaxPip(
                        _params.size,
                        _params.isBuy,
                        _params.pip,
                        _params.trader
                    );
                    hasLiquidity = liquidityBitmap.hasLiquidity(_params.pip);
                    _singleSlot = singleSlot;
                }
            }

            {
                if (
                    (_params.size > sizeOut) ||
                    (_params.size == sizeOut &&
                        _params.quoteDeposited > quoteAmount &&
                    _params.quoteDeposited > 0)
                ) {
                    uint128 remainingSize;

                    if (_params.quoteDeposited > 0 && _params.isBuy
                        && _params.quoteDeposited > quoteAmount) {
                        remainingSize = uint128(
                            quoteToBase(
                                _params.quoteDeposited - quoteAmount,
                                _params.pip
                            )
                        );
                    } else {
                        remainingSize = _params.size - uint128(sizeOut);
                    }

                    if (
                        _params.pip == _singleSlot.pip &&
                        _singleSlot.isFullBuy != (_params.isBuy ? 1 : 2)
                    ) {
                        singleSlot.isFullBuy = _params.isBuy ? 1 : 2;
                    }

                    orderId = tickPosition[_params.pip].insertLimitOrder(
                        remainingSize,
                        hasLiquidity,
                        _params.isBuy
                    );
                    if (!hasLiquidity) {
                        //set the bit to mark it has liquidity
                        liquidityBitmap.toggleSingleBit(_params.pip, true);
                    }
                    emit LimitOrderCreated(
                        orderId,
                        _params.pip,
                        remainingSize,
                        _params.isBuy
                    );
                }
            }
        }
    }

    // TODO for test only needs remove on production
    // BECARE FULL DEPLOY MEEEEEE
    ///////////////////////////////////////////
    // should move me to a mock contract for test only
    //    function clearCurrentPip() external onlyOwner {
    //        liquidityBitmap.toggleSingleBit(singleSlot.pip, false);
    //        singleSlot.isFullBuy = 0;
    //        tickPosition[singleSlot.pip].liquidity = 0;
    //    }

    //    function _addReserveSnapshot() internal {
    //        uint64 currentBlock = _blockNumber();
    //        ReserveSnapshot memory latestSnapshot = reserveSnapshots[
    //            reserveSnapshots.length - 1
    //        ];
    //        if (currentBlock == latestSnapshot.blockNumber) {
    //            reserveSnapshots[reserveSnapshots.length - 1].pip = singleSlot.pip;
    //        } else {
    //            reserveSnapshots.push(
    //                ReserveSnapshot(singleSlot.pip, _blockTimestamp(), currentBlock)
    //            );
    //        }
    //        emit ReserveSnapshotted(singleSlot.pip, _blockTimestamp());
    //    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library TradeConvert {
    // convert from base amount to quote amount by pip
    function baseToQuote(
        uint256 quantity,
        uint128 pip,
        uint256 basisPoint
    ) internal view returns (uint256) {
        // quantity * pip / baseBasisPoint / basisPoint / baseBasisPoint;
        // shorten => quantity * pip / basisPoint ;
        return (quantity * pip) / basisPoint;
    }

    function quoteToBase(
        uint256 quoteAmount,
        uint128 pip,
        uint256 basisPoint
    ) public view returns (uint256) {
        return (quoteAmount * basisPoint) / pip;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPosiCallback {
    function posiAddLiquidityCallback(
        IERC20 baseToken,
        IERC20 quoteToken,
        uint256 baseAmountUsed,
        uint256 quoteAmountUsed,
        address user
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 *  - VL = ValidationLogic
 *  - MATH = Math libraries

 */
library Errors {
    //common errors
    string public constant VL_EMPTY_ADDRESS = "1";
    string public constant VL_ONLY_COUNTERPARTY = "2";
    string public constant VL_LONG_PRICE_THAN_CURRENT_PRICE = "3";
    string public constant VL_SHORT_PRICE_LESS_CURRENT_PRICE = "4";
    string public constant VL_INVALID_SIZE = "6";
    string public constant VL_INVALID_ORDER_ID = "7";
    string public constant VL_EXPIRED = "8";
    string public constant VL_NOT_ENOUGH_LIQUIDITY = "9";
    string public constant VL_NOT_ENOUGH_QUOTE_FUNDING = "10";
    string public constant VL_NOT_ENOUGH_BASE_FUNDING = "11";
    string public constant VL_MUST_NOT_FILLED = "12";
    string public constant VL_SPOT_MANGER_NOT_EXITS = "13";
    string public constant VL_SPOT_MANGER_EXITS = "14";
    string public constant VL_NO_AMOUNT_TO_CLAIM = "15";
    string public constant VL_NO_LIMIT_TO_CANCEL = "16";
    string public constant VL_ONLY_OWNER = "17";
    string public constant VL_MUST_IDENTICAL_ADDRESSES = "18";
    string public constant VL_MUST_NOT_INITIALIZABLE = "19";
    string public constant VL_MUST_NOT_TOKEN_USE_RFI = "20";
    string public constant VL_ONLY_LIQUIDITY_POOL = "!LP";
    string public constant VL_NEED_MORE_BNB = "21";
    string public constant VL_MUST_CLOSE_TO_INDEX_PRICE_SHORT = "24.1";
    string public constant VL_MUST_CLOSE_TO_INDEX_PRICE_LONG = "24.2";

    // Liquidity Errors
    string public constant LQ_NO_LIQUIDITY_BASE = "30";
    string public constant LQ_NO_LIQUIDITY_QUOTE = "31";
    string public constant LQ_NO_LIQUIDITY = "32";
    string public constant LQ_POOL_EXIST = "33";
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

abstract contract Block {
    function _blockTimestamp() internal view virtual returns (uint64) {
        return uint64(block.timestamp);
    }

    function _blockNumber() internal view virtual returns (uint64) {
        return uint64(block.number);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

/**
 * @author Musket
 */
pragma solidity ^0.8.0;

import "../spot-exchange/PairManager.sol";

import "hardhat/console.sol";

import "../spot-exchange/libraries/helper/Convert.sol";
import "../spot-exchange/libraries/helper/TradeConvert.sol";
import "../spot-exchange/libraries/helper/BitMathLiquidity.sol";

contract MockPairManager is PairManager {
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);
    using Timers for uint64;
    using Convert for uint256;
    using Convert for int256;
    using TradeConvert for uint256;

    IPairManager.ExchangedData public exData;
    bool isFilled;

    function Mock(IPairManager.ExchangedData memory _exData, bool _isFilled)
        public
    {
        exData = _exData;
        isFilled = _isFilled;
    }

    function abc(
        IPairManager _pairManager,
        uint256 amount,
        uint256 pip
    ) public view returns (uint256) {
        uint256 a = ((amount * 100) / pip);
        uint256 _fee = (a * 10) / (10000 - 10);
        return a + _fee;
    }

    function accumulatePoolLiquidityClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        IPairManager.ExchangedData memory _exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view override returns (IPairManager.ExchangedData memory, bool) {
        return (exData, isFilled);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "../interfaces/ISpotHouse.sol";
import "../interfaces/IWBNB.sol";
import "./libraries/types/SpotHouseStorage.sol";
import {Errors} from "./libraries/helper/Errors.sol";
import {TransferHelper} from "./libraries/helper/TransferHelper.sol";

import "hardhat/console.sol";
import "./libraries/helper/Convert.sol";
import "./libraries/helper/SpotHouseHelper.sol";
import "./implement/Block.sol";

contract SpotHouse is
    Block,
    ISpotHouse,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    SpotHouseStorage
{
    using Convert for uint256;

    modifier onlyRouter() {
        require(_msgSender() == positionRouter, "!OR");
        _;
    }


    function initialize() public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();

        feeBasis = 10000;
        fee = 20;
        WBNB = address(0);
    }

    /**
     * @dev see {ISpotHouse-openLimitOrder}
     */
    function openLimitOrder(
        IPairManager pairManager,
        Side side,
        uint256 quantity,
        uint128 pip
    ) external payable override whenNotPaused nonReentrant {
        //        require(!_pairManager.isExpired(), Errors.VL_EXPIRED);
        address trader = _msgSender();

        _openLimitOrder(pairManager, quantity, pip, trader, side);
    }

    function openBuyLimitOrderExactInput(
        IPairManager pairManager,
        Side side,
        uint256 quantity,
        uint128 pip
    ) external payable override whenNotPaused nonReentrant {
        require(side == Side.BUY, "!B");
        address trader = _msgSender();
        _openBuyLimitOrderExactInput(pairManager, quantity, pip, trader);
    }

    function openLimitOrderWithQuote(
        IPairManager _pairManager,
        Side _side,
        uint256 _quoteAmount,
        uint128 _pip
    ) external payable whenNotPaused nonReentrant {
        revert("not supported");
        //        address _trader = _msgSender();
        //
        //        _openLimitOrder(
        //            _pairManager,
        //            (_quoteAmount * _pairManager.getBasisPoint()) / _pip,
        //            _pip,
        //            _trader,
        //            _side
        //        );
    }

    function openMarketOrder(
        IPairManager _pairManager,
        Side _side,
        uint256 _quantity
    ) external payable override whenNotPaused nonReentrant {
        address _trader = _msgSender();
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            _pairManager
        );

        _openMarketOrder(_pairManager, _side, _quantity, _trader, _trader);
    }

    function openMarketOrder(
        IPairManager _pairManager,
        Side _side,
        uint256 _quantity,
        address _payer,
        address _recipient
    )
        external
        payable
        override
        whenNotPaused
        nonReentrant
        onlyRouter
        returns (uint256[] memory)
    {
        return
            _openMarketOrder(
                _pairManager,
                _side,
                _quantity,
                _payer,
                _recipient
            );
    }

    function openMarketOrderWithQuote(
        IPairManager _pairManager,
        Side _side,
        uint256 _quoteAmount
    ) external payable override whenNotPaused nonReentrant {
        address _trader = _msgSender();

        _openMarketOrderWithQuote(
            _pairManager,
            _side,
            _quoteAmount,
            _trader,
            _trader
        );
    }

    function openMarketOrderWithQuote(
        IPairManager _pairManager,
        Side _side,
        uint256 _quoteAmount,
        address _payer,
        address _recipient
    )
        external
        payable
        override
        whenNotPaused
        nonReentrant
        onlyRouter
        returns (uint256[] memory)
    {
        return
            _openMarketOrderWithQuote(
                _pairManager,
                _side,
                _quoteAmount,
                _payer,
                _recipient
            );
    }

    function cancelAllLimitOrder(IPairManager _pairManager)
        external
        override
        whenNotPaused
        nonReentrant
    {
        address _trader = _msgSender();
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            _pairManager
        );

        uint256 refundQuote;
        uint256 refundBase;
        uint256 quoteFilled;
        uint256 baseFilled;

        (
            quoteFilled,
            baseFilled
            //            uint256 feeQuote,
            //            uint256 feeBase
        ) = getAmountClaimable(_pairManager, _trader);

        PendingLimitOrder[]
            memory _listPendingLimitOrder = getPendingLimitOrders(
                _pairManager,
                _trader
            );

        require(
            _listPendingLimitOrder.length > 0,
            Errors.VL_NO_LIMIT_TO_CANCEL
        );

        uint128[] memory _listPips = new uint128[](
            _listPendingLimitOrder.length
        );
        uint64[] memory _orderIds = new uint64[](_listPendingLimitOrder.length);

        for (uint64 i = 0; i < _listPendingLimitOrder.length; i++) {
            PendingLimitOrder
                memory _pendingLimitOrder = _listPendingLimitOrder[i];

            if (_pendingLimitOrder.quantity == 0) {
                continue;
            }

            _listPips[i] = _pendingLimitOrder.pip;
            _orderIds[i] = _pendingLimitOrder.orderId;

            (uint256 refundQuantity, uint256 partialFilled) = _pairManager
                .cancelLimitOrder(
                    _pendingLimitOrder.pip,
                    _pendingLimitOrder.orderId
                );

            if (_pendingLimitOrder.isBuy) {
                refundQuote += _pairManager.calculatingQuoteAmount(
                    refundQuantity,
                    _pendingLimitOrder.pip
                );
            } else {
                refundBase += refundQuantity;
            }
        }

        delete limitOrders[address(_pairManager)][_trader];

        _withdrawCancelAll(
            _pairManager,
            _trader,
            Asset.Quote,
            refundQuote,
            quoteFilled
        );
        _withdrawCancelAll(
            _pairManager,
            _trader,
            Asset.Base,
            refundBase,
            baseFilled
        );

        emit AllLimitOrderCancelled(
            _trader,
            _pairManager,
            _listPips,
            _orderIds,
            _blockTimestamp()
        );
    }

    function cancelLimitOrder(
        IPairManager _pairManager,
        uint64 _orderIdx,
        uint128 _pip
    ) external override whenNotPaused nonReentrant {
        address _trader = _msgSender();

        SpotLimitOrder.Data[] storage _orders = limitOrders[
            address(_pairManager)
        ][_trader];
        require(_orderIdx < _orders.length, Errors.VL_INVALID_ORDER_ID);

        // save gas
        SpotLimitOrder.Data memory _order = _orders[_orderIdx];

        require(
            _order.baseAmount != 0 && _order.quoteAmount != 0,
            Errors.VL_NO_LIMIT_TO_CANCEL
        );

        (bool isFilled, , , ) = _pairManager.getPendingOrderDetail(
            _order.pip,
            _order.orderId
        );

        require(isFilled == false, Errors.VL_MUST_NOT_FILLED);

        // blank limit order data
        // we set the deleted order to a blank data
        // because we don't want to mess with order index (orderIdx)
        SpotLimitOrder.Data memory blankLimitOrderData;

        (uint256 refundQuantity, uint256 partialFilled) = _pairManager
            .cancelLimitOrder(_order.pip, _order.orderId);

        if (_order.isBuy) {
            uint256 quoteAmount = _pairManager.calculatingQuoteAmount(
                refundQuantity,
                _order.pip
            );

            _withdraw(_pairManager, _trader, Asset.Quote, quoteAmount, false);
            _withdraw(_pairManager, _trader, Asset.Base, partialFilled, true);
        } else {
            _withdraw(_pairManager, _trader, Asset.Base, refundQuantity, false);
            if (partialFilled > 0) {
                _withdraw(
                    _pairManager,
                    _trader,
                    Asset.Quote,
                    _pairManager.calculatingQuoteAmount(
                        partialFilled,
                        _order.pip
                    ),
                    true
                );
            }
        }
        delete _orders[_orderIdx];
        // = blankLimitOrderData;

        emit LimitOrderCancelled(
            _trader,
            _pairManager,
            _order.pip,
            _order.orderId,
            _blockTimestamp()
        );
    }

    function claimAsset(IPairManager _pairManager)
        external
        override
        whenNotPaused
        nonReentrant
    {
        address _trader = _msgSender();

        (uint256 quoteAmount, uint256 baseAmount) = getAmountClaimable(
            _pairManager,
            _trader
        );
        require(
            quoteAmount > 0 || baseAmount > 0,
            Errors.VL_NO_AMOUNT_TO_CLAIM
        );
        _clearLimitOrder(address(_pairManager), _trader);

        _withdraw(_pairManager, _trader, Asset.Quote, quoteAmount, true);
        _withdraw(_pairManager, _trader, Asset.Base, baseAmount, true);

        emit AssetClaimed(_trader, _pairManager, quoteAmount, baseAmount);
    }

    function getAmountClaimable(IPairManager _pairManager, address _trader)
        public
        view
        override
        returns (uint256 quoteAmount, uint256 baseAmount)
    {
        address _pairManagerAddress = address(_pairManager);

        SpotLimitOrder.Data[] memory listLimitOrder = limitOrders[
            _pairManagerAddress
        ][_trader];
        uint256 i = 0;
        uint256 _basisPoint = _pairManager.getBasisPoint();
        uint128 _feeBasis = feeBasis;
        IPairManager.ExchangedData memory exData = IPairManager.ExchangedData({
            baseAmount: 0,
            quoteAmount: 0,
            feeQuoteAmount: 0,
            feeBaseAmount: 0
        });
        for (i; i < listLimitOrder.length; i++) {
            if (listLimitOrder[i].pip == 0 && listLimitOrder[i].orderId == 0)
                continue;
            exData = _pairManager.accumulateClaimableAmount(
                listLimitOrder[i].pip,
                listLimitOrder[i].orderId,
                exData,
                _basisPoint,
                listLimitOrder[i].fee,
                _feeBasis
            );
        }
        return (exData.quoteAmount, exData.baseAmount);
    }

    function getPendingLimitOrders(IPairManager _pairManager, address _trader)
        public
        view
        override
        returns (PendingLimitOrder[] memory)
    {
        address _pairManagerAddress = address(_pairManager);
        SpotLimitOrder.Data[] storage listLimitOrder = limitOrders[
            _pairManagerAddress
        ][_trader];
        PendingLimitOrder[]
            memory listPendingOrderData = new PendingLimitOrder[](
                listLimitOrder.length
            );
        uint256 index = 0;
        for (uint256 i = 0; i < listLimitOrder.length; i++) {
            (
                bool isFilled,
                bool isBuy,
                uint256 quantity,
                uint256 partialFilled
            ) = _pairManager.getPendingOrderDetail(
                    listLimitOrder[i].pip,
                    listLimitOrder[i].orderId
                );
            if (!isFilled) {
                listPendingOrderData[index] = PendingLimitOrder({
                    isBuy: isBuy,
                    quantity: quantity,
                    partialFilled: partialFilled,
                    pip: listLimitOrder[i].pip,
                    blockNumber: listLimitOrder[i].blockNumber,
                    orderIdOfTrader: i,
                    orderId: listLimitOrder[i].orderId,
                    fee: listLimitOrder[i].fee
                });
                index++;
            }
        }
        for (uint256 i = 0; i < listPendingOrderData.length; i++) {
            if (listPendingOrderData[i].quantity != 0) {
                return listPendingOrderData;
            }
        }
        PendingLimitOrder[] memory blankListPendingOrderData;
        return blankListPendingOrderData;
    }

    function _getQuoteAndBase(IPairManager _managerAddress)
        internal
        view
        returns (SpotFactoryStorage.Pair memory pair)
    {

        pair =  spotFactory.getQuoteAndBase(address(_managerAddress));
        require(pair.BaseAsset != address(0), "!0x");

    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function setWithdrawBNB(IWithdrawBNB _withdrawBNB) external onlyOwner {
        withdrawBNB =_withdrawBNB;
    }

    function setRouter(address _positionRouter) external onlyOwner {
        positionRouter = _positionRouter;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setFactory(address _factoryAddress) external override onlyOwner {
        require(_factoryAddress != address(0), Errors.VL_EMPTY_ADDRESS);
        spotFactory = ISpotFactory(_factoryAddress);
    }

    function updateFee(uint16 _fee) external override onlyOwner {
        //max fee can be is 10%
        require(_fee <= 1000, "!F");
        fee = _fee;
    }

    function setWBNB(address _wbnb) external onlyOwner {
        WBNB = _wbnb;
    }

    function claimFee(
        IPairManager pairManager,
        uint256 feeBase,
        uint256 feeQuote,
        address recipient
    ) external onlyOwner {
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            pairManager
        );
        address pairManagerAddress = address(pairManager);

        (uint256 baseFeeFunding, uint256 quoteFeeFunding) = pairManager
            .getFee();

        if (_pairAddress.BaseAsset == WBNB) {
            _withdrawBNB(recipient, pairManagerAddress, baseFeeFunding);

        }else {
            TransferHelper.transferFrom(
                IERC20(_pairAddress.BaseAsset),
                pairManagerAddress,
                recipient,
                baseFeeFunding
            );
        }
        if (_pairAddress.QuoteAsset == WBNB) {
            _withdrawBNB(recipient, pairManagerAddress, quoteFeeFunding);
        }else {
            TransferHelper.transferFrom(
                IERC20(_pairAddress.QuoteAsset),
                pairManagerAddress,
                recipient,
                quoteFeeFunding
            );
        }


        pairManager.resetFee(baseFeeFunding, quoteFeeFunding);
    }

    //------------------------------------------------------------------------------------------------------------------
    // INTERNAL FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function _msgSender()
        internal
        view
        override(ContextUpgradeable)
        returns (address)
    {
        return msg.sender;
    }

    struct OpenLimitOrderState {
        uint64 orderId;
        uint256 sizeOut;
        uint256 quoteAmountFilled;
    }

    function _openLimitOrder(
        IPairManager _pairManager,
        uint256 _quantity,
        uint128 _pip,
        address _trader,
        Side _side
    ) internal {
        address _pairManagerAddress = address(_pairManager);
        OpenLimitOrderState memory state;
        uint256 quoteAmount;
        bool isBuy = _side == Side.BUY ? true : false;
        if (!isBuy) {
            // Sell limit
            // deposit base asset
            // with token has RFI we need deposit first
            // and get real balance transferred
            _quantity = _deposit(
                _pairManager,
                _trader,
                Asset.Base,
                _quantity.Uint256ToUint128()
            );
        }
        (state.orderId, state.sizeOut, state.quoteAmountFilled) = _pairManager
            .openLimit(_pip, _quantity.Uint256ToUint128(), isBuy, _trader, 0);
        if (isBuy) {
            // Buy limit
            quoteAmount =
                _pairManager.calculatingQuoteAmount(
                    (_quantity - state.sizeOut).Uint256ToUint128(),
                    _pip
                ) +
                state.quoteAmountFilled;
            //            quoteAmount += _feeCalculator(quoteAmount, fee);
            // deposit quote asset
            // with token has RFI we need deposit first
            // and get real balance transferred
            uint256 quoteAmountTransferred = _deposit(
                _pairManager,
                _trader,
                Asset.Quote,
                quoteAmount
            );

            require(quoteAmountTransferred == quoteAmount, "!RFI");
        } else {
            quoteAmount = _pairManager.calculatingQuoteAmount(
                (_quantity - state.sizeOut).Uint256ToUint128(),
                _pip
            );
        }

        if (_quantity > state.sizeOut) {
            limitOrders[_pairManagerAddress][_trader].push(
                SpotLimitOrder.Data({
                    pip: _pip,
                    orderId: state.orderId,
                    isBuy: isBuy,
                    quoteAmount: quoteAmount.Uint256ToUint128(),
                    baseAmount: (_quantity - state.sizeOut).Uint256ToUint128(),
                    blockNumber: block.number.Uint256ToUint40(),
                    fee: fee
                })
            );
        }

        if (isBuy) {
            // withdraw  base asset
            _withdraw(_pairManager, _trader, Asset.Base, state.sizeOut, true);
        }
        if (!isBuy) {
            // withdraw quote asset
            _withdraw(
                _pairManager,
                _trader,
                Asset.Quote,
                state.quoteAmountFilled,
                true
            );
        }

        emit LimitOrderOpened(
            state.orderId,
            _trader,
            _quantity - state.sizeOut,
            state.sizeOut,
            _pip,
            isBuy ? Side.BUY : Side.SELL,
            _pairManagerAddress,
            _blockTimestamp()
        );
    }

    function _openBuyLimitOrderExactInput(
        IPairManager _pairManager,
        uint256 _quantity,
        uint128 _pip,
        address _trader
    ) internal {
        address _pairManagerAddress = address(_pairManager);
        OpenLimitOrderState memory state;

        uint256 quoteAmount = _pairManager.calculatingQuoteAmount(
            _quantity.Uint256ToUint128(),
            _pip
        );

        uint256 quoteAmountTransferred = _deposit(
            _pairManager,
            _trader,
            Asset.Quote,
            quoteAmount
        );

        if (quoteAmountTransferred != quoteAmount) {
            _quantity = _pairManager.quoteToBase(quoteAmountTransferred, _pip);
        }

        (state.orderId, state.sizeOut, state.quoteAmountFilled) = _pairManager
            .openLimit(
                _pip,
                _quantity.Uint256ToUint128(),
                true,
                _trader,
                quoteAmountTransferred
            );
        uint256 baseAmountReceive = state.sizeOut;
        if (
            state.sizeOut == _quantity &&
            quoteAmountTransferred > state.quoteAmountFilled
        ) {
            _quantity = _pairManager.quoteToBase(
                quoteAmountTransferred - state.quoteAmountFilled,
                _pip
            );

            emit MarketOrderOpened(
                _trader,
                state.sizeOut,
                state.quoteAmountFilled,
                Side.BUY,
                _pairManager,
                _pairManager.getCurrentPip(),
                _blockTimestamp()
            );
            state.sizeOut = 0;

        }

        if (_quantity > state.sizeOut) {
            limitOrders[_pairManagerAddress][_trader].push(
                SpotLimitOrder.Data({
                    pip: _pip,
                    orderId: state.orderId,
                    isBuy: true,
                    quoteAmount: _pairManager
                        .calculatingQuoteAmount(
                            (_quantity - state.sizeOut).Uint256ToUint128(),
                            _pip
                        )
                        .Uint256ToUint128(),
                    baseAmount: (_quantity - state.sizeOut).Uint256ToUint128(),
                    blockNumber: block.number.Uint256ToUint40(),
                    fee: fee
                })
            );
        }
        _withdraw(_pairManager, _trader, Asset.Base, baseAmountReceive, true);

        emit LimitOrderOpened(
            state.orderId,
            _trader,
            _quantity - state.sizeOut,
            state.sizeOut,
            _pip,
            Side.BUY,
            _pairManagerAddress,
            _blockTimestamp()
        );
    }

    function _openMarketOrder(
        IPairManager _pairManager,
        Side _side,
        uint256 _quantity,
        address _payer,
        address _recipient
    ) internal returns (uint256[] memory) {
        uint256 sizeOut;
        uint256 quoteAmount;
        if (_side == Side.BUY) {

            (sizeOut, quoteAmount) = _pairManager.openMarket(
                _quantity,
                true,
                _payer
            );
            require(sizeOut == _quantity, Errors.VL_NOT_ENOUGH_LIQUIDITY);

            // deposit quote asset
            uint256 amountTransferred = _deposit(
                _pairManager,
                _payer,
                Asset.Quote,
                quoteAmount
            );

            require(amountTransferred == quoteAmount, "!RFI");

            // withdraw base asset
            // after BUY done, transfer base back to trader
            _withdraw(_pairManager, _recipient, Asset.Base, _quantity, true);

        } else {
            // SELL market
            uint256 baseAmountTransferred = _deposit(
                _pairManager,
                _payer,
                Asset.Base,
                _quantity
            );

            (sizeOut, quoteAmount) = _pairManager.openMarket(
                baseAmountTransferred,
                false,
                _payer
            );
            require(
                sizeOut == baseAmountTransferred,
                Errors.VL_NOT_ENOUGH_LIQUIDITY
            );

            _withdraw(_pairManager, _recipient, Asset.Quote, quoteAmount, true);
            _quantity = baseAmountTransferred;
        }

        emit MarketOrderOpened(
            _payer,
            _quantity,
            quoteAmount,
            _side,
            _pairManager,
            _pairManager.getCurrentPip(),
            _blockTimestamp()
        );
        return _calculatorAmounts(_side, _quantity, quoteAmount);
    }

    function _openMarketOrderWithQuote(
        IPairManager _pairManager,
        Side _side,
        uint256 _quoteAmount,
        address _payer,
        address _recipient
    ) internal returns (uint256[] memory) {
        uint256 sizeOutQuote;
        uint256 baseAmount;
        if (_side == Side.BUY) {
            // deposit quote asset
            uint256 amountTransferred = _deposit(
                _pairManager,
                _payer,
                Asset.Quote,
                _quoteAmount
            );
            (sizeOutQuote, baseAmount) = _pairManager.openMarketWithQuoteAsset(
                amountTransferred,
                true,
                _payer
            );

            require(
                sizeOutQuote == amountTransferred,
                Errors.VL_NOT_ENOUGH_LIQUIDITY
            );

            // withdraw base asset
            // after BUY done, transfer base back to trader
            _withdraw(_pairManager, _recipient, Asset.Base, baseAmount, true);
        } else {
            // SELL market
            uint256 amountTransferred = _deposit(
                _pairManager,
                _payer,
                Asset.Base,
                baseAmount
            );

            (sizeOutQuote, baseAmount) = _pairManager.openMarketWithQuoteAsset(
                amountTransferred,
                false,
                _payer
            );
            require(
                sizeOutQuote == _quoteAmount,
                Errors.VL_NOT_ENOUGH_LIQUIDITY
            );
            _withdraw(
                _pairManager,
                _recipient,
                Asset.Quote,
                _quoteAmount,
                true
            );
        }
        emit MarketOrderOpened(
            _payer,
            baseAmount,
            _quoteAmount,
            _side,
            _pairManager,
            _pairManager.getCurrentPip(),
            _blockTimestamp()
        );
        return _calculatorAmounts(_side, baseAmount, _quoteAmount);
    }

    function _clearLimitOrder(address _pairManagerAddress, address _trader)
        internal
    {
        if (limitOrders[_pairManagerAddress][_trader].length > 0) {
            SpotLimitOrder.Data[]
                memory subListLimitOrder = _clearAllFilledOrder(
                    IPairManager(_pairManagerAddress),
                    limitOrders[_pairManagerAddress][_trader]
                );
            delete limitOrders[_pairManagerAddress][_trader];
            for (uint256 i = 0; i < subListLimitOrder.length; i++) {
                if (subListLimitOrder[i].pip == 0) {
                    break;
                }
                limitOrders[_pairManagerAddress][_trader].push(
                    subListLimitOrder[i]
                );
            }
        }
    }

    function _clearAllFilledOrder(
        IPairManager _pairManager,
        SpotLimitOrder.Data[] memory listLimitOrder
    ) internal returns (SpotLimitOrder.Data[] memory) {
        SpotLimitOrder.Data[]
            memory subListLimitOrder = new SpotLimitOrder.Data[](
                listLimitOrder.length
            );
        uint256 index = 0;
        for (uint256 i = 0; i < listLimitOrder.length; i++) {
            (
                bool isFilled,
                ,
                uint256 size,
                uint256 partialFilled
            ) = _pairManager.getPendingOrderDetail(
                    listLimitOrder[i].pip,
                    listLimitOrder[i].orderId
                );
            if (!isFilled) {
                subListLimitOrder[index] = listLimitOrder[i];
                if (partialFilled > 0) {
                    subListLimitOrder[index].baseAmount = (size - partialFilled)
                        .Uint256ToUint128();
                    subListLimitOrder[index].quoteAmount = (
                        _pairManager.calculatingQuoteAmount(
                            size - partialFilled,
                            listLimitOrder[i].pip
                        )
                    ).Uint256ToUint128();
                }
                _pairManager.updatePartialFilledOrder(
                    listLimitOrder[i].pip,
                    listLimitOrder[i].orderId
                );
                index++;
            }
        }

        return subListLimitOrder;
    }

    function _depositBNB(address _pairManagerAddress, uint256 _amount)
        internal
    {
        require(msg.value >= _amount, Errors.VL_NEED_MORE_BNB);
        IWBNB(WBNB).deposit{value: _amount}();
        assert(IWBNB(WBNB).transfer(_pairManagerAddress, _amount));
    }

    function _withdrawBNB(
        address _trader,
        address _pairManagerAddress,
        uint256 _amount
    ) internal {
        IWBNB(WBNB).transferFrom(_pairManagerAddress, address(withdrawBNB), _amount);
        withdrawBNB.withdraw(_trader, _amount);
    }

    function _deposit(
        IPairManager _pairManager,
        address _payer,
        Asset _asset,
        uint256 _amount
    ) internal returns (uint256) {
        if (_amount == 0) return 0;
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            _pairManager
        );
        address pairManagerAddress = address(_pairManager);
        uint256 _fee;
        uint128 _feeBasis = feeBasis;
        if (_asset == Asset.Quote) {
            if (_pairAddress.QuoteAsset == WBNB) {
                _depositBNB(pairManagerAddress, _amount);
            } else {
                IERC20 quoteAsset = IERC20(_pairAddress.QuoteAsset);
                uint256 _balanceBefore = quoteAsset.balanceOf(
                    pairManagerAddress
                );
                TransferHelper.transferFrom(
                    quoteAsset,
                    _payer,
                    pairManagerAddress,
                    _amount
                );
                uint256 _balanceAfter = quoteAsset.balanceOf(
                    pairManagerAddress
                );
                _amount = _balanceAfter - _balanceBefore;
            }
        } else {
            if (_pairAddress.BaseAsset == WBNB) {
                _depositBNB(pairManagerAddress, _amount);
            } else {
                IERC20 baseAsset = IERC20(_pairAddress.BaseAsset);
                uint256 _balanceBefore = baseAsset.balanceOf(
                    pairManagerAddress
                );
                TransferHelper.transferFrom(
                    baseAsset,
                    _payer,
                    pairManagerAddress,
                    _amount
                );
                uint256 _balanceAfter = baseAsset.balanceOf(pairManagerAddress);
                _amount = _balanceAfter - _balanceBefore;
            }
        }
        return _amount;
    }



    function _withdraw(
        IPairManager _pairManager,
        address _recipient,
        Asset asset,
        uint256 _amount,
        bool isTakeFee
    ) internal {
        if (_amount == 0) return;
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            _pairManager
        );

        if (isTakeFee) {
            uint256 feeCalculatedAmount = _feeCalculator(_amount, fee);
            _amount -= feeCalculatedAmount;
            _increaseFee(_pairManager, feeCalculatedAmount, asset);
        }
        address pairManagerAddress = address(_pairManager);
        if (asset == Asset.Quote) {
            if (_pairAddress.QuoteAsset == WBNB) {
                _withdrawBNB(_recipient, pairManagerAddress, _amount);
            } else {
                TransferHelper.transferFrom(
                    IERC20(_pairAddress.QuoteAsset),
                    address(_pairManager),
                    _recipient,
                    _amount
                );
            }
        } else {
            if (_pairAddress.BaseAsset == WBNB) {
                _withdrawBNB(_recipient, pairManagerAddress, _amount);
            } else {
                TransferHelper.transferFrom(
                    IERC20(_pairAddress.BaseAsset),
                    address(_pairManager),
                    _recipient,
                    _amount
                );
            }
        }
    }

    function _withdrawCancelAll(
        IPairManager _pairManager,
        address _recipient,
        Asset asset,
        uint256 _amountRefund,
        uint256 _amountFilled
    ) internal {
        if (_amountFilled > 0) {
            uint256 feeCalculatedAmount = _feeCalculator(_amountFilled, fee);
            _amountFilled -= feeCalculatedAmount;
            _increaseFee(_pairManager, feeCalculatedAmount, asset);
        }

        _withdraw(
            _pairManager,
            _recipient,
            asset,
            _amountRefund + _amountFilled,
            false
        );
    }

    // _feeCalculator calculate fee
    function _feeCalculator(uint256 _amount, uint16 _fee)
        internal
        view
        returns (uint256 feeCalculatedAmount)
    {
        if (_fee == 0) {
            return 0;
        }
        feeCalculatedAmount = (_fee * _amount) / feeBasis;
    }

    function _increaseFee(
        IPairManager _pairManager,
        uint256 _fee,
        Asset asset
    ) internal {
        if (asset == Asset.Quote && _fee > 0) {
            _pairManager.increaseQuoteFeeFunding(_fee);
        }
        if (asset == Asset.Base && _fee > 0) {
            _pairManager.increaseBaseFeeFunding(_fee);
        }
    }

    function _calculatorAmounts(
        Side _side,
        uint256 baseAmount,
        uint256 quoteAmount
    ) internal returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);

        if (_side == Side.BUY) {
            amounts[0] = quoteAmount;
            amounts[1] = baseAmount;
        } else {
            amounts[0] = baseAmount;
            amounts[1] = quoteAmount;
        }

        return amounts;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../spot-exchange/libraries/types/SpotHouseStorage.sol";
import "./IPairManager.sol";

interface ISpotHouse {
    event SpotHouseInitialized(address owner);

    event MarketOrderOpened(
        address trader,
        uint256 quantity,
        uint256 openNational,
        SpotHouseStorage.Side side,
        IPairManager spotManager,
        uint128 currentPip,
        uint64 blockTimestamp
    );
    event LimitOrderOpened(
        uint64 orderId,
        address trader,
        uint256 quantity,
        uint256 sizeOut,
        uint128 pip,
        SpotHouseStorage.Side _side,
        address spotManager,
        uint64 blockTimestamp
    );

    event LimitOrderCancelled(
        address trader,
        IPairManager spotManager,
        uint128 pip,
        uint64 orderId,
        uint256 blockTimestamp
    );

    event AllLimitOrderCancelled(
        address trader,
        IPairManager spotManager,
        uint128[] pips,
        uint64[] orderIds,
        uint256 blockTimestamp
    );

    event AssetClaimed(
        address trader,
        IPairManager spotManager,
        uint256 quoteAmount,
        uint256 baseAmount
    );

    function openLimitOrder(
        IPairManager _spotManager,
        SpotHouseStorage.Side _side,
        uint256 _quantity,
        uint128 _pip
    ) external payable;

    function openBuyLimitOrderExactInput(
        IPairManager pairManager,
        SpotHouseStorage.Side side,
        uint256 quantity,
        uint128 pip
    ) external payable;

    function openMarketOrder(
        IPairManager _spotManager,
        SpotHouseStorage.Side _side,
        uint256 _quantity
    ) external payable;

    function openMarketOrderWithQuote(
        IPairManager _pairManager,
        SpotHouseStorage.Side _side,
        uint256 _quoteAmount
    ) external payable;

    function cancelLimitOrder(
        IPairManager _spotManager,
        uint64 _orderIdx,
        uint128 _pip
    ) external;

    function claimAsset(IPairManager _spotManager) external;

    function getAmountClaimable(IPairManager _spotManager, address _trader)
        external
        view
        returns (
            uint256 quoteAsset,
            uint256 baseAsset
            //            uint256 feeQuoteAmount,
            //            uint256 feeBaseAmount
        );

    function cancelAllLimitOrder(IPairManager _spotManager) external;

    function getPendingLimitOrders(IPairManager _spotManager, address _trader)
        external
        view
        returns (SpotHouseStorage.PendingLimitOrder[] memory);

    function setFactory(address _factoryAddress) external;

    function updateFee(uint16 _fee) external;

    function openMarketOrder(
        IPairManager _pairManager,
        SpotHouseStorage.Side _side,
        uint256 _quantity,
        address _payer,
        address _recipient
    ) external payable returns (uint256[] memory);

    function openMarketOrderWithQuote(
        IPairManager _pairManager,
        SpotHouseStorage.Side _side,
        uint256 _quoteAmount,
        address _payer,
        address _recipient
    ) external payable returns (uint256[] memory);
}

pragma solidity ^0.8.0;

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function balanceOf(address guy) external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../exchange/SpotOrderData.sol";
import "../../../interfaces/ISpotFactory.sol";
import "../../WithdrawBNB.sol";

contract SpotHouseStorage {
    using SpotLimitOrder for mapping(address => mapping(address => SpotLimitOrder.Data[]));

    ISpotFactory public spotFactory;

    address public WBNB;

    mapping(address => mapping(address => SpotLimitOrder.Data[]))
        public limitOrders;
    enum Side {
        BUY,
        SELL
    }

    uint128 feeBasis;

    // fee 0.01 %
    uint16 public fee;

    enum Asset {
        Quote,
        Base,
        Fee
    }

    struct PendingLimitOrder {
        bool isBuy;
        uint256 quantity;
        uint256 partialFilled;
        uint128 pip;
        uint256 blockNumber;
        uint256 orderIdOfTrader;
        uint64 orderId;
        uint16 fee;
    }

    struct OpenLimitResp {
        uint64 orderId;
        uint256 sizeOut;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;

    address public positionRouter;

    IWithdrawBNB public withdrawBNB;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );
    }

    function transferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        token.transferFrom(from, to, value);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../../../interfaces/IPairManager.sol";
import "./TradeConvert.sol";
import "./Convert.sol";
import "./PackedOrderId.sol";

library SpotHouseHelper {
    using TradeConvert for uint256;
    using Convert for uint256;
    using PackedOrderId for bytes32;

    // exchanged data return for liquidity
    // how many base -> quote and versa
    struct ExchangedData {
        int256 base;
        int256 quote;
        uint128 feeQuote;
        uint128 feeBase;
    }

    function accumulateClaimableAmount(
        address _pairAddress,
        uint128 _pip,
        uint64 _orderId,
        uint256 quoteAmount,
        uint256 baseAmount,
        uint256 basisPoint
    )
        internal
        view
        returns (
            uint256,
            uint256,
            int128,
            int128
        )
    {
        IPairManager _pairManager = IPairManager(_pairAddress);
        (
            bool isFilled,
            bool isBuy,
            uint256 baseSize,
            uint256 partialFilled
        ) = _pairManager.getPendingOrderDetail(_pip, _orderId);
        uint256 filledSize = isFilled ? baseSize : partialFilled;
        if (isBuy) {
            //BUY => can claim base asset
            baseAmount += filledSize;
        } else {
            // SELL => can claim quote asset
            quoteAmount += filledSize.baseToQuote(_pip, basisPoint);
        }
        return (quoteAmount, baseAmount, 0, 0);
    }

    struct AccPoolExchangedDataParams {
        bytes32 orderId;
        int128 baseAdjust;
        int128 quoteAdjust;
        uint128 feeQuote;
        uint128 feeBase;
    }

    // Accumulate the exchanged quote and the base amount, to the pool liquidity
    // don't need to returns because `params` works as a pointer reference
    function accumulatePoolExchangedData(
        address _pairAddress,
        uint256 basisPoint,
        AccPoolExchangedDataParams memory params
    ) internal view {
        (uint128 _pip, uint64 _orderId, bool isBuy) = params.orderId.unpack();
        IPairManager _pairManager = IPairManager(_pairAddress);
        (
            bool isFilled,
            ,
            uint256 baseSize,
            uint256 partialFilled
        ) = _pairManager.getPendingOrderDetail(_pip, _orderId);
        uint256 filledSize = isFilled ? baseSize : partialFilled;
        if (isBuy) {
            //BUY => can claim base asset
            params.baseAdjust += filledSize.toI128();
            params.quoteAdjust -= filledSize
                .baseToQuote(_pip, basisPoint)
                .toI128();
        } else {
            // SELL => can claim quote asset
            params.quoteAdjust += filledSize
                .baseToQuote(_pip, basisPoint)
                .toI128();
            params.baseAdjust -= filledSize.toI128();
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library SpotLimitOrder {
    struct Data {
        uint128 pip;
        uint64 orderId;
        bool isBuy;
        uint40 blockNumber;
        uint16 fee;
        uint128 quoteAmount;
        uint128 baseAmount;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../spot-exchange/libraries/types/SpotFactoryStorage.sol";

interface ISpotFactory {
    event PairManagerCreated(address pairManager);

    //    function createPairManager(
    //        address quoteAsset,
    //        address baseAsset,
    //        uint256 basisPoint,
    //        uint256 BASE_BASIC_POINT,
    //        uint128 maxFindingWordsIndex,
    //        uint128 initialPip,
    //        uint64 expireTime
    //    ) external;

    function getPairManager(address quoteAsset, address baseAsset)
        external
        view
        returns (address pairManager);

    function getQuoteAndBase(address pairManager)
        external
        view
        returns (SpotFactoryStorage.Pair memory);

    function isPairManagerExist(address pairManager)
        external
        view
        returns (bool);

    function getPairManagerSupported(address tokenA, address tokenB)
        external
        view
        returns (
            address baseToken,
            address quoteToken,
            address pairManager
        );
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Errors} from "./libraries/helper/Errors.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IWBNB.sol";


interface IWithdrawBNB {

    function withdraw(address recipient, uint256 _amount) external;

}

contract WithdrawBNB is IWithdrawBNB {

    using Address for address payable;
    IWBNB public WBNB;
    address public owner;
    address public spotHouse;

    modifier onlyOwner(){
        require(msg.sender == owner,Errors.VL_ONLY_OWNER );
        _;

    }

    modifier onlyCounterParty(){
        require(msg.sender == spotHouse, Errors.VL_ONLY_COUNTERPARTY );
        _;
    }


    receive() external payable {
        assert(msg.sender == address(WBNB));
        // only accept BNB via fallback from the WBNB contract
    }

    constructor (IWBNB _WBNB) {
        owner = msg.sender;
        WBNB = _WBNB;

    }


    function setWBNB(IWBNB _newWBNB) external onlyOwner {
        WBNB = _newWBNB;
    }

    function transferOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function setSpotHouse(address _newSpotHouse) external onlyOwner {
        spotHouse = _newSpotHouse;
    }


    function withdraw(address recipient, uint256 amount) external override onlyCounterParty {
        WBNB.withdraw(amount);
        payable(recipient).sendValue(amount);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../../interfaces/IPairManager.sol";

contract SpotFactoryStorage {
    address public spotHouse;

    address public liquidityPool;

    struct Pair {
        address BaseAsset;
        address QuoteAsset;
    }

    //  baseAsset address => quoteAsset address => spotManager address
    mapping(address => mapping(address => address)) internal pathPairManagers;

    mapping(address => Pair) internal allPairManager;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @author Musket
 */
pragma solidity ^0.8.0;

import "../spot-exchange/libraries/liquidity/Grid.sol";
import "../spot-exchange/libraries/helper/PackedOrderId.sol";
import "../spot-exchange/PairManager.sol";

contract TestGridOrder is PairManager {
    using PackedOrderId for uint128;

    constructor() {
        basisPoint = 10;
    }

    // ONLY TEST
    function supplyGridOrderTest(Grid.GridOrderData[] memory orders)
        external
        onlyOwner
    {
        _supplyGridOrder(orders);
    }

    struct CancelOrderParams {
        uint128 pip;
        uint64 orderId;
        bool isBuy;
    }

    function cancelOrders(CancelOrderParams[] memory orders) external {
        bytes32[] memory _orders = new bytes32[](orders.length);
        for (uint256 i = 0; i < orders.length; i++) {
            CancelOrderParams memory _order = orders[i];
            _orders[i] = _order.pip.pack(_order.orderId, _order.isBuy);
        }
        // mock by pass modifier
        liquidityPool = _msgSender();
        cancelGridOrders(_orders);
    }
}

pragma solidity ^0.8.0;

import "../spot-exchange/libraries/helper/PackedOrderId.sol";

contract TestPackedOrderId {
    function pack(
        uint128 _pip,
        uint64 _orderIdx,
        bool isBuy
    ) public pure returns (bytes32) {
        return PackedOrderId.pack(_pip, _orderIdx, isBuy);
    }

    function unpack(bytes32 _packed)
        public
        pure
        returns (
            uint128,
            uint64,
            bool
        )
    {
        return PackedOrderId.unpack(_packed);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./implement/LiquidityNFT.sol";
import "../interfaces/IPairManager.sol";
import "../interfaces/ISpotFactory.sol";
import "../interfaces/ILiquidityPool.sol";
import "./libraries/types/PositionLiquidityPoolStorage.sol";
import {PoolKey} from "./libraries/helper/PoolKey.sol";
import "./implement/Block.sol";
import "./libraries/liquidity/PoolLiquidity.sol";
import "./libraries/liquidity/Grid.sol";
import "./libraries/helper/TransferHelper.sol";
import "./libraries/helper/Convert.sol";
import "./libraries/helper/PackedOrderId.sol";
import "./libraries/helper/SpotHouseHelper.sol";
import "../interfaces/IRebalanceStrategy.sol";
import "./libraries/helper/U128Math.sol";
import {Errors} from "./libraries/helper/Errors.sol";

contract PositionLiquidityPool is
    ILiquidityPool,
    Block,
    PositionLiquidityPoolStorage,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{
    using TradeConvert for uint256;
    using SafeMath for uint256;
    using Convert for uint256;
    using Convert for int128;
    using U128Math for uint128;
    using PoolLiquidity for PoolLiquidity.PoolLiquidityInfo;
    using BitMathLiquidity for int128;
    using PoolLiquidity for int256;
    using PoolLiquidity for int128;
    using BalanceOfPool for BalanceOfPool.Balance;
    using PackedOrderId for bytes32;
    using PackedOrderId for bytes32;

    // TODO config input
    function initialize() external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();

        feeBasis = 0;
        feeShareRatio = 0;
        maxNumberOfGridOrderEachSide = 6;
    }

    struct AddLiquidityState {
        uint128 currentPip;
        uint128 basisPoint;
        uint128 quoteDeposited;
        uint128 priceOfFundingCertificate;
        uint128 netAssetValue;
        address user;
        IPairManager pairManager;
        PoolLiquidity.PoolLiquidityInfo poolInfo;
    }

    function addLiquidity(AddLiquidityParams memory params)
        external
        override
        nonReentrant
    {
        // initialize _state
        AddLiquidityState memory state;
        state.user = _msgSender();
        state.poolInfo = poolInfo[params.poolId];
        state.pairManager = IPairManager(state.poolInfo.pairManager);
        (state.currentPip, state.basisPoint) = state
            .pairManager
            .getCurrentPipAndBasisPoint();
        state.netAssetValue = getNetAssetValue(params.poolId);

        state.priceOfFundingCertificate = state
            .poolInfo
            .totalFundingCertificates == 0
            ? state.currentPip
            : (state.netAssetValue * state.basisPoint) /
                state.poolInfo.totalFundingCertificates;

        state.quoteDeposited = params
            .baseAmount
            .baseToQuote(state.currentPip, state.basisPoint)
            .add(params.quoteAmount);

        {
            LimitLiquidity memory limit = limitLiquidity[params.poolId];
            require(
                limit.liquidityLimitUser >= state.quoteDeposited,
                "Limit liquidity user"
            );
            require(
                limit.liquidityLimitPool >=
                    state.poolInfo.totalQuoteDeposited + state.quoteDeposited,
                "Limit liquidity pool"
            );
        }

        // mint liquidity nft
        uint256 tokenId = nftLiquidityPool.mint(state.user);

        // calculate user's liquidity information
        uint128 amountOfFundCertificates = state
            .poolInfo
            .totalFundingCertificates == 0
            ? params.baseAmount +
                params.quoteAmount.quoteToBase(
                    state.currentPip,
                    state.basisPoint
                )
            : (state.quoteDeposited * state.basisPoint) /
                state.priceOfFundingCertificate;
        liquidityInfo[tokenId] = LiquidityInfo.Data({
            poolId: params.poolId,
            baseAmount: params.baseAmount,
            quoteAmount: params.quoteAmount,
            priceOfFundingCertificate: state.priceOfFundingCertificate,
            amountOfFC: amountOfFundCertificates,
            quoteDeposited: state.quoteDeposited
        });

        if (params.baseAmount > 0)
            _transferFrom(
                getBaseAsset(state.pairManager),
                state.user,
                address(this),
                params.baseAmount
            );
        if (params.quoteAmount > 0)
            _transferFrom(
                getQuoteAsset(state.pairManager),
                state.user,
                address(this),
                params.quoteAmount
            );

        balanceOfPool[params.poolId].increaseBalanceOfPool(
            params.baseAmount,
            params.quoteAmount
        );

        poolInfo[params.poolId].updateLiquidity(
            params.baseAmount,
            params.quoteAmount,
            state.quoteDeposited,
            amountOfFundCertificates
        );

        // TODO read amountOfFundCertificates to event
        emit LiquidityAdded(
            params.poolId,
            state.user,
            params.baseAmount,
            params.quoteAmount,
            state.quoteDeposited
        );
    }

    struct StateRemoveLiquidity {
        int128 userPnl;
        uint128 totalClaimableAmountInQuote;
        uint128 claimableBaseAmount;
        uint128 claimableQuoteAmount;
        LiquidityInfo.Data liquidityInfo;
        uint256 totalClaimQuote;
        uint256 totalClaimBase;
    }

    function removeLiquidity(uint256 tokenId) external override nonReentrant {
        StateRemoveLiquidity memory state;

        state.liquidityInfo = liquidityInfo[tokenId];
        address tokenOwner = nftLiquidityPool.ownerOf(tokenId);
        require(tokenOwner == _msgSender(), "only token owner");

        // currently only support close all the liquidity.
        require(state.liquidityInfo.quoteDeposited > 0, "no liquidity");
        // TODO refactor this
        (uint128 _quoteLiquidity, uint128 _baseLiquidity) = getPoolLiquidity(
            state.liquidityInfo.poolId
        );

        PoolLiquidity.PoolLiquidityInfo memory _poolInfo = poolInfo[
            state.liquidityInfo.poolId
        ];
        IPairManager _pairManager = IPairManager(_poolInfo.pairManager);

        _claimAllFilledOrders(
            state.liquidityInfo.poolId,
            _poolInfo,
            _pairManager
        );

        {
            // new scope avoiding stack too deep error

            // calculate claimable amount
            (
                state.claimableBaseAmount,
                state.claimableQuoteAmount,
                state.totalClaimableAmountInQuote,
                state.userPnl
            ) = _getNftWithdrawInfo(tokenId, _quoteLiquidity, _baseLiquidity);

            {
                (uint256 quoteBalance, uint256 baseBalance) = getBalanceOfPool(
                    state.liquidityInfo.poolId
                );
                // avoid stack too deep
                while (
                    (baseBalance + state.totalClaimBase) <
                    state.claimableBaseAmount ||
                    (quoteBalance + state.totalClaimQuote) <
                    state.claimableQuoteAmount
                ) {
                    bytes32[] memory _cancelOrderIds = new bytes32[](2);
                    if (
                        (quoteBalance + state.totalClaimQuote) <
                        state.claimableQuoteAmount
                    ) {
                        if (_poolInfo.soRemovablePosBuy == type(int128).max) {
                            revert("No liquidity: Quote");
                        }
                        // try to cancel the buy order
                        uint8 _index = _poolInfo
                            .soRemovablePosBuy
                            .leftMostUnsetBitPos();
                        _cancelOrderIds[0] = _poolInfo.supplyOrders[_index];

                        _poolInfo.soRemovablePosBuy = _poolInfo
                            .soRemovablePosBuy
                            .markSoRemovablePos(_index);
                    }
                    if (
                        (baseBalance + state.totalClaimBase) <
                        state.claimableBaseAmount
                    ) {
                        if (_poolInfo.soRemovablePosSell == type(int128).max) {
                            revert("No liquidity: Base");
                        }
                        // try to cancel the sell order
                        uint8 _index = BitMathLiquidity.getPosOfSell(
                            _poolInfo.soRemovablePosSell.leftMostUnsetBitPos()
                        );

                        _cancelOrderIds[1] = _poolInfo.supplyOrders[_index];
                        _poolInfo.soRemovablePosSell = _poolInfo
                            .soRemovablePosSell
                            .markSoRemovablePos(
                                BitMathLiquidity.getIndexOrderOfSell(_index)
                            );
                    }
                    (uint256 _rBase, uint256 _rQuote) = _pairManager
                        .cancelGridOrders(_cancelOrderIds);

                    state.totalClaimBase += _rBase;
                    state.totalClaimQuote += _rQuote;
                }

                {
                    poolInfo[state.liquidityInfo.poolId].removeLiquidity(
                        LiquidityMath.safeSubLiquidity(
                            _baseLiquidity,
                            state.claimableBaseAmount
                        ),
                        LiquidityMath.safeSubLiquidity(
                            _quoteLiquidity,
                            state.claimableQuoteAmount
                        ),
                        state.liquidityInfo.quoteDeposited,
                        state.liquidityInfo.amountOfFC
                    );

                    balanceOfPool[state.liquidityInfo.poolId]
                        .accumulateBalanceOfPool(
                            uint128(
                                baseBalance +
                                    state.totalClaimBase -
                                    state.claimableBaseAmount
                            ),
                            uint128(
                                quoteBalance +
                                    state.totalClaimQuote -
                                    state.claimableQuoteAmount
                            )
                        );

                    _collectFundPairManager(
                        bytes32(0),
                        _pairManager,
                        state.totalClaimBase,
                        state.totalClaimQuote
                    );
                }
            }

            poolInfo[state.liquidityInfo.poolId].soRemovablePosSell = _poolInfo
                .soRemovablePosSell;
            poolInfo[state.liquidityInfo.poolId].soRemovablePosBuy = _poolInfo
                .soRemovablePosBuy;

            _transferOut(
                getBaseAsset(_pairManager),
                tokenOwner,
                state.claimableBaseAmount
            );

            _transferOut(
                getQuoteAsset(_pairManager),
                tokenOwner,
                state.claimableQuoteAmount
            );
        }
        // burn NFT
        delete liquidityInfo[tokenId];

        nftLiquidityPool.burn(tokenId);
        // emit event
        emit LiquidityRemoved(
            state.liquidityInfo.poolId,
            _msgSender(),
            tokenId,
            state.claimableBaseAmount,
            state.claimableQuoteAmount,
            state.totalClaimableAmountInQuote,
            state.userPnl
        );
    }

    function resupplyOrder(IPairManager _pairManager) external {}

    function rebalance(bytes32 poolId) external override nonReentrant {
        PoolLiquidity.PoolLiquidityInfo memory _poolInfo = poolInfo[poolId];

        ReBalanceState memory reBalanceState = ReBalanceState({
            soRemovablePosBuy: _poolInfo.soRemovablePosBuy,
            soRemovablePosSell: _poolInfo.soRemovablePosSell,
            claimableQuote: 0,
            claimableBase: 0,
            feeQuoteAmount: 0,
            feeBaseAmount: 0,
            pairManager: IPairManager(_poolInfo.pairManager),
            poolId: poolId
        });

        (
            uint256 poolQuoteLiquidity,
            uint256 poolBaseLiquidity
        ) = getPoolLiquidity(poolId);

        poolInfo[reBalanceState.poolId].quoteLiquidity = uint128(
            poolQuoteLiquidity
        );
        poolInfo[reBalanceState.poolId].baseLiquidity = uint128(
            poolBaseLiquidity
        );

        IRebalanceStrategy _rebalanceStrategy = IRebalanceStrategy(
            _poolInfo.strategy
        );

        _cancelRedundantGridOrders(
            reBalanceState,
            _poolInfo,
            _rebalanceStrategy
        );

        (uint256 pQBalance, uint256 pBBalance) = getBalanceOfPool(
            reBalanceState.poolId
        );

        // claim unclaim amount
        // because the unclaim amounts is already in the pair manager
        // we don't have to claim them then re-add them to the pairManager
        // avoid wasting gas fee
        (
            reBalanceState.claimableQuote,
            reBalanceState.claimableBase,
            reBalanceState.feeQuoteAmount,
            reBalanceState.feeBaseAmount
        ) = getPoolClaimable(
            reBalanceState.poolId,
            reBalanceState,
            _poolInfo.supplyOrders
        );

        reBalanceState.pairManager.decreaseQuoteFeeFunding(
            reBalanceState.feeQuoteAmount
        );
        reBalanceState.pairManager.decreaseBaseFeeFunding(
            reBalanceState.feeBaseAmount
        );

        // start reBalance
        Grid.GridOrderData[] memory _orders = _rebalanceStrategy
            .getSupplyPrices(
                reBalanceState.pairManager.getCurrentPip(),
                reBalanceState.claimableQuote.toU128().add(pQBalance.toU128()),
                reBalanceState.claimableBase.toU128().add(pBBalance.toU128())
            );

        if (_orders.length > 0) {
            {
                (
                    uint256 baseAmountUsed,
                    uint256 quoteAmountUsed,
                    bytes32[] memory _orderIds
                ) = reBalanceState.pairManager.supplyGridOrder(
                        _orders,
                        address(this),
                        abi.encode(
                            reBalanceState.claimableQuote,
                            reBalanceState.claimableBase
                        ),
                        reBalanceState.poolId
                    );
                for (uint256 i = 0; i < _orderIds.length; i++) {
                    // using memory to save gas
                    PoolLiquidity.pushSupply(
                        poolInfo[reBalanceState.poolId].supplyOrders,
                        reBalanceState,
                        _orderIds[i]
                    );
                }
                balanceOfPool[reBalanceState.poolId].decreaseBalanceOfPool(
                    uint128(baseAmountUsed),
                    uint128(quoteAmountUsed)
                );
            }

            // set to storage
            poolInfo[reBalanceState.poolId].soRemovablePosBuy = reBalanceState
                .soRemovablePosBuy;
            poolInfo[reBalanceState.poolId].soRemovablePosSell = reBalanceState
                .soRemovablePosSell;
        }
    }

    function changeRebalanceStrategy() external override {}

    // callback
    function posiAddLiquidityCallback(
        IERC20 baseToken,
        IERC20 quoteToken,
        uint256 baseAmountUsed,
        uint256 quoteAmountUsed,
        address user
    ) external {
        require(
            spotFactory.isPairManagerExist(_msgSender()),
            Errors.VL_SPOT_MANGER_NOT_EXITS
        );

        // transfer from user to the pair manager
        if (user == address(this)) {
            _transferOut(baseToken, _msgSender(), baseAmountUsed);
        } else
            TransferHelper.transferFrom(
                baseToken,
                user,
                _msgSender(),
                baseAmountUsed
            );

        if (user == address(this)) {
            _transferOut(quoteToken, _msgSender(), quoteAmountUsed);
        } else
            TransferHelper.transferFrom(
                quoteToken,
                user,
                _msgSender(),
                quoteAmountUsed
            );
    }

    function donatePool(
        bytes32 poolHash,
        uint256 base,
        uint256 quote
    ) external {
        IPairManager _pairManager = IPairManager(
            poolInfo[poolHash].pairManager
        );
        getQuoteAsset(_pairManager).transferFrom(
            _msgSender(),
            address(this),
            quote
        );
        getBaseAsset(_pairManager).transferFrom(
            _msgSender(),
            address(this),
            base
        );
        balanceOfPool[poolHash].increaseBalanceOfPool(
            uint128(base),
            uint128(quote)
        );
    }

    function addPool(IPairManager _pairManager, address _strategy)
        external
        onlyOwner
    {
        address _pairManagerAddress = address(_pairManager);
        bytes32 poolHash = PoolKey.computePoolKey(
            _pairManagerAddress,
            _strategy
        );
        require(
            poolInfo[poolHash].pairManager == address(0),
            "Pool already exist"
        );

        SpotFactoryStorage.Pair memory pair = spotFactory.getQuoteAndBase(
            _pairManagerAddress
        );
        require(
            address(pair.BaseAsset) != address(0) &&
                address(pair.QuoteAsset) != address(0),
            "!E"
        );
        bytes32[256] memory _supplyOrders;
        getQuoteAsset(_pairManager).approve(
            _pairManagerAddress,
            type(uint256).max
        );
        getBaseAsset(_pairManager).approve(
            _pairManagerAddress,
            type(uint256).max
        );

        poolInfo[poolHash] = PoolLiquidity.PoolLiquidityInfo({
            pairManager: _pairManagerAddress,
            strategy: _strategy,
            baseLiquidity: 0,
            quoteLiquidity: 0,
            supplyOrders: _supplyOrders,
            totalQuoteDeposited: 0,
            totalFundingCertificates: 0,
            soRemovablePosBuy: type(int128).max,
            soRemovablePosSell: type(int128).max
        });

        limitLiquidity[poolHash] = LimitLiquidity({
            liquidityLimitUser: 2000 * 10**18,
            liquidityLimitPool: 100000 * 10**18
        });

        emit PoolAdded(poolHash, _msgSender());
    }

    function receiveQuoteAndBase(
        bytes32 poolId,
        uint128 base,
        uint128 quote
    ) external override {
        require(
            spotFactory.isPairManagerExist(_msgSender()),
            Errors.VL_SPOT_MANGER_NOT_EXITS
        );
        balanceOfPool[poolId].increaseBalanceOfPool(base, quote);
    }

    //------------------------------------------------------------------------------------------------------------------
    // OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function setSpotFactory(ISpotFactory _spotFactory) external onlyOwner {
        emit SpotFactoryAdded(address(spotFactory), address(_spotFactory));
        spotFactory = _spotFactory;
    }

    function setNFTLiquidityPool(INonfungiblePositionLiquidityPool _new)
        external
        onlyOwner
    {
        nftLiquidityPool = _new;
    }

    function setMaxNumberOfGridOrderEachSide(
        uint8 _maxNumberOfGridOrderEachSide
    ) external onlyOwner {
        maxNumberOfGridOrderEachSide = _maxNumberOfGridOrderEachSide;
    }

    function updateLimitLiquidity(
        bytes32 poolId,
        uint128 limitUser,
        uint128 limitPool
    ) external onlyOwner {
        limitLiquidity[poolId] = LimitLiquidity({
            liquidityLimitUser: limitUser,
            liquidityLimitPool: limitPool
        });
    }

    //------------------------------------------------------------------------------------------------------------------
    // VIEW FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function getNftWithdrawInfo(uint256 nftId)
        external
        view
        returns (
            uint128 claimableBaseAmount,
            uint128 claimableQuoteAmount,
            uint128 totalClaimableAmountInQuote,
            int128 profitAndLoss
        )
    {
        LiquidityInfo.Data memory info = liquidityInfo[nftId];
        (uint128 _quoteLiquidity, uint128 _baseLiquidity) = getPoolLiquidity(
            info.poolId
        );
        (
            claimableBaseAmount,
            claimableQuoteAmount,
            totalClaimableAmountInQuote,
            profitAndLoss
        ) = _getNftWithdrawInfo(nftId, _quoteLiquidity, _baseLiquidity);
    }

    function getPoolLiquidity(bytes32 poolKey)
        public
        view
        override
        returns (uint128 quote, uint128 base)
    {
        PoolLiquidity.PoolLiquidityInfo memory pool = poolInfo[poolKey];
        IPairManager _pairManager = IPairManager(pool.pairManager);
        bytes32[256] memory _orderIds = pool.supplyOrders;
        (int128 quoteAdjust, int128 baseAdjust) = _pairManager
            .accumulatePoolExchangedData(
                _orderIds,
                feeShareRatio,
                feeBasis,
                pool.soRemovablePosBuy,
                pool.soRemovablePosSell
            );

        quote = LiquidityMath.safeAdjustLiquidity(
            pool.quoteLiquidity,
            quoteAdjust
        );
        base = LiquidityMath.safeAdjustLiquidity(
            pool.baseLiquidity,
            baseAdjust
        );
    }

    function getDataNonfungibleToken(uint256 tokenId)
        external
        view
        override
        returns (LiquidityInfo.Data memory)
    {
        return liquidityInfo[tokenId];
    }

    function getAllDataTokens(uint256[] memory tokens)
        external
        view
        override
        returns (LiquidityInfo.Data[] memory)
    {
        LiquidityInfo.Data[] memory allDataTokens = new LiquidityInfo.Data[](
            tokens.length
        );
        for (uint256 i = 0; i < tokens.length; i) {
            allDataTokens[i] = liquidityInfo[tokens[i]];
        }
        return allDataTokens;
    }

    // get pool PnL in the quote currency
    function getPoolPnL(bytes32 poolKey) public view override returns (int128) {
        uint128 totalLiquidityInQuote = getNetAssetValue(poolKey);
        return
            int128(totalLiquidityInQuote) -
            int128(poolInfo[poolKey].totalQuoteDeposited);
    }

    // @notice calculate current net asset value of liquidity pool converted to quote
    // @return net asset value of pool converted to quote
    function getNetAssetValue(bytes32 poolKey) public view returns (uint128) {
        PoolLiquidity.PoolLiquidityInfo memory pool = poolInfo[poolKey];
        (uint128 quote, uint128 base) = getPoolLiquidity(poolKey);
        (uint128 _pip, uint128 _basisPoint) = IPairManager(pool.pairManager)
            .getCurrentPipAndBasisPoint();
        return base.baseToQuote(_pip, _basisPoint).add(quote);
    }

    struct PoolClaimableState {
        uint8 countBitHasSupply;
        uint128 posTemp;
        bool isFilled;
        uint256 basisPoint;
    }

    function getPoolClaimable(
        bytes32 poolKey,
        ReBalanceState memory data,
        bytes32[256] memory orderIds
    )
        internal
        returns (
            uint256 quote,
            uint256 base,
            uint256 feeQuoteAmount,
            uint256 feeBaseAmount
        )
    {
        IPairManager.ExchangedData memory exData;
        int256 packSo = BitMathLiquidity.packInt128AndIn128(
            data.soRemovablePosBuy,
            data.soRemovablePosSell
        );

        PoolClaimableState memory state = PoolClaimableState({
            countBitHasSupply: uint8(
                255 - PoolLiquidity.countBitSet(uint256(packSo)) // TODO move to PoolLiquidity.countUnsetBit (not implemented for uint256 yet, needs implement and unit test)
            ),
            posTemp: 0,
            isFilled: false,
            basisPoint: IPairManager(data.pairManager).getBasisPoint()
        });

        {
            while (state.countBitHasSupply != 0) {
                state.posTemp = PoolLiquidity
                    .rightMostUnSetBitPosInt256(packSo)
                    .Uint256ToUint128();
                packSo = PoolLiquidity.markSoRemovablePosInt256(
                    packSo,
                    state.posTemp
                );
                state.countBitHasSupply--;
                if (state.posTemp == 127 || state.posTemp == 255) {
                    continue;
                }
                (uint128 _pip, uint64 _orderIdx, bool isBuy) = PackedOrderId
                    .unpack(orderIds[state.posTemp]);
                (exData, state.isFilled) = IPairManager(data.pairManager)
                    .accumulatePoolLiquidityClaimableAmount(
                        _pip,
                        _orderIdx,
                        exData,
                        state.basisPoint,
                        feeShareRatio,
                        feeBasis
                    );
                if (state.isFilled) {
                    if (state.posTemp < 127) {
                        data.soRemovablePosBuy = PoolLiquidity
                            .markSoRemovablePos(
                                data.soRemovablePosBuy,
                                uint8(state.posTemp)
                            );
                    } else {
                        data.soRemovablePosSell = PoolLiquidity
                            .markSoRemovablePos(
                                data.soRemovablePosSell,
                                uint8(
                                    BitMathLiquidity.getIndexOrderOfSell(
                                        uint256(state.posTemp)
                                    )
                                )
                            );
                    }
                }
            }
        }
        return (
            exData.quoteAmount + exData.feeQuoteAmount + data.claimableQuote,
            exData.baseAmount + exData.feeBaseAmount + data.claimableBase,
            exData.feeQuoteAmount,
            exData.feeBaseAmount
        );
    }

    function pendingReward(uint256 tokenId)
        external
        view
        override
        returns (uint256 rewardInQuote)
    {}

    function pendingRewardFee(address user, IPairManager _pairManager)
        private
        view
        returns (uint256 rewardFeeBase, uint256 rewardFeeQuote)
    {
        return (0, 0);
    }

    //    function getPoolBalanceQuoteBase(IPairManager _pairManager)
    //        public
    //        view
    //        returns (uint256 quote, uint256 base)
    //    {
    //        quote = getQuoteAsset(_pairManager).balanceOf(address(this));
    //        base = getBaseAsset(_pairManager).balanceOf(address(this));
    //    }

    function getBalanceOfPool(bytes32 poolId)
        public
        view
        returns (uint256 quote, uint256 base)
    {
        return (balanceOfPool[poolId].quote, balanceOfPool[poolId].base);
    }

    //------------------------------------------------------------------------------------------------------------------
    // INTERNAL FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    // @notice calculate assets that user would acquire on withdrawing NFT from Liquidity Pool
    // @return claimableBaseAmount: amount of base assets that user would acquire on withdrawing NFT from Liquidity Pool
    // @return claimableQuoteAmount: amount of quote assets that user would acquire on withdrawing NFT from Liquidity Pool
    // @return totalClaimableAmountInQuote: total net asset converted to quote that user would acquire on withdrawing NFT from Liquidity Pool
    // @return profitAndLoss: total PnL converted to quote that user would acquire on withdrawing NFT from Liquidity Pool
    function _getNftWithdrawInfo(
        uint256 nftId,
        uint256 poolQuoteLiquidity,
        uint256 poolBaseLiquidity
    )
        internal
        view
        returns (
            uint128 claimableBaseAmount,
            uint128 claimableQuoteAmount,
            uint128 totalClaimableAmountInQuote,
            int128 profitAndLoss
        )
    {
        uint256 totalFundingCertificates = poolInfo[liquidityInfo[nftId].poolId]
            .totalFundingCertificates;
        if (totalFundingCertificates != 0) {
            claimableBaseAmount = uint128(
                (poolBaseLiquidity * liquidityInfo[nftId].amountOfFC) /
                    totalFundingCertificates
            );

            claimableQuoteAmount = uint128(
                (poolQuoteLiquidity * liquidityInfo[nftId].amountOfFC) /
                    totalFundingCertificates
            );

            totalClaimableAmountInQuote = uint128(
                (uint256(liquidityInfo[nftId].amountOfFC) *
                    uint256(getNetAssetValue(liquidityInfo[nftId].poolId))) /
                    totalFundingCertificates
            );

            profitAndLoss =
                int128(totalClaimableAmountInQuote) -
                int128(liquidityInfo[nftId].quoteDeposited);
        }
    }

    function _msgSender() internal view override returns (address) {
        return msg.sender;
    }

    function _msgData() internal view override returns (bytes calldata) {
        return msg.data;
    }

    function _transferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        TransferHelper.transferFrom(token, sender, recipient, amount);
    }

    function _transferOut(
        IERC20 token,
        address recipient,
        uint256 amount
    ) private {
        // IF current balance doesn't enought, cancel orders and claim from the pairManager
        if (amount > 0) {
            token.transfer(recipient, amount);
        }
    }

    function getQuoteAsset(IPairManager _pairManager)
        internal
        view
        returns (IERC20)
    {
        return _pairManager.getQuoteAsset();
    }

    function getBaseAsset(IPairManager _pairManager)
        internal
        view
        returns (IERC20)
    {
        return _pairManager.getBaseAsset();
    }

    // @dev claim all filled orders
    function _claimAllFilledOrders(
        bytes32 _poolId,
        PoolLiquidity.PoolLiquidityInfo memory _liquidityPool,
        IPairManager _pairManager
    ) internal {
        uint128 pow127Of2 = 1 << 127;
        uint256 basisPoint = _pairManager.getBasisPoint();

        int128 openedBuyOrderMask = ~_liquidityPool.soRemovablePosBuy;
        uint256 claimableBaseAmount;

        while (
            openedBuyOrderMask != 0 && openedBuyOrderMask != int128(pow127Of2)
        ) {
            uint128 oldestOpenedBuyOrderIndex = openedBuyOrderMask
                .rightMostSetBitPos();

            (uint128 pip, uint64 orderId, ) = _liquidityPool
                .supplyOrders[oldestOpenedBuyOrderIndex]
                .unpack();

            (
                bool isFilled,
                ,
                uint256 baseSize,
                uint256 partialFilled
            ) = _pairManager.getPendingOrderDetail(pip, orderId);

            if (isFilled) {
                claimableBaseAmount += baseSize;
                _liquidityPool.soRemovablePosBuy = PoolLiquidity
                    .markSoRemovablePos(
                        _liquidityPool.soRemovablePosBuy,
                        uint8(oldestOpenedBuyOrderIndex)
                    );
            } else if (partialFilled > 0) {
                claimableBaseAmount += partialFilled;
                _pairManager.updatePartialFilledOrder(pip, orderId);
            }

            openedBuyOrderMask = openedBuyOrderMask.clearBitPositionInt128(
                uint8(oldestOpenedBuyOrderIndex)
            );
        }

        int128 openedSellOrderMask = ~_liquidityPool.soRemovablePosSell;
        uint256 claimableQuoteAmount;

        while (
            openedSellOrderMask != 0 && openedSellOrderMask != int128(pow127Of2)
        ) {
            uint128 oldestOpenedSellOrderIndex = openedSellOrderMask
                .rightMostSetBitPos();

            (uint128 pip, uint64 orderId, ) = _liquidityPool
                .supplyOrders[128 + oldestOpenedSellOrderIndex]
                .unpack();

            (
                bool isFilled,
                ,
                uint256 baseSize,
                uint256 partialFilled
            ) = _pairManager.getPendingOrderDetail(pip, orderId);

            if (isFilled) {
                claimableQuoteAmount += baseSize.baseToQuote(pip, basisPoint);
                _liquidityPool.soRemovablePosSell = PoolLiquidity
                    .markSoRemovablePos(
                        _liquidityPool.soRemovablePosSell,
                        uint8(oldestOpenedSellOrderIndex)
                    );
            } else if (partialFilled > 0) {
                claimableQuoteAmount += partialFilled.baseToQuote(
                    pip,
                    basisPoint
                );
                _pairManager.updatePartialFilledOrder(pip, orderId);
            }

            openedSellOrderMask = openedSellOrderMask.clearBitPositionInt128(
                uint8(oldestOpenedSellOrderIndex)
            );
        }
        _collectFundPairManager(
            _poolId,
            _pairManager,
            claimableBaseAmount,
            claimableQuoteAmount
        );
    }

    /**
    * @dev cancels redundant limit orders before rebalancing liquidity pool to guarantee that number of orders does
      not exceed PositionLiquidityPoolStorage.maxNumberOfGridOrderEachSide
      the amount get back is immediately re-supply to the pairManager so we don't need to claimFundBack avoiding redundant gasFee
      Such a merging orders mechanism
    */
    function _cancelRedundantGridOrders(
        ReBalanceState memory reBalanceState,
        PoolLiquidity.PoolLiquidityInfo memory _liquidityPool,
        IRebalanceStrategy _rebalanceStrategy
    ) internal {
        bytes32 _poolId = reBalanceState.poolId;
        IPairManager _pairManager = reBalanceState.pairManager;
        // count pending buy orders
        uint8 pendingOrderCount = reBalanceState
            .soRemovablePosBuy
            .countPendingSoOrder();

        // cancel oldest buy orders until order count = maxNumberOfGridOrderEachSide - numberOfGridEachSide
        uint256 totalBaseGetBack;
        uint256 totalQuoteGetBack;
        uint8 maxAllowedOrderCount = uint8(
            uint16(maxNumberOfGridOrderEachSide) -
                _rebalanceStrategy.getNumberOfSupplyOrdersEachSide()
        );

        while (pendingOrderCount > maxAllowedOrderCount) {
            uint8 oldestNotFilledOrderIndex = reBalanceState
                .soRemovablePosBuy
                .leftMostUnsetBitPos();
            (uint128 pip, uint64 orderIdx, ) = PackedOrderId.unpack(
                _liquidityPool.supplyOrders[oldestNotFilledOrderIndex]
            );
            (
                bool isFilled,
                ,
                uint256 baseSize,
                uint256 partialFilled
            ) = _pairManager.getPendingOrderDetail(pip, orderIdx);
            if (isFilled) {
                totalBaseGetBack += uint128(baseSize);
            } else {
                _pairManager.cancelLimitOrder(pip, orderIdx);
                totalBaseGetBack += uint128(partialFilled);
                totalQuoteGetBack += uint128((baseSize - partialFilled))
                    .baseToQuote(pip, uint128(_pairManager.getBasisPoint()));
            }
            reBalanceState.soRemovablePosBuy = PoolLiquidity.markSoRemovablePos(
                reBalanceState.soRemovablePosBuy,
                oldestNotFilledOrderIndex
            );
            pendingOrderCount--;
        }

        // count pending sell orders
        pendingOrderCount = reBalanceState
            .soRemovablePosSell
            .countPendingSoOrder();

        // cancel oldest sell orders until order count = maxNumberOfGridOrderEachSide - numberOfGridEachSide
        while (pendingOrderCount > maxAllowedOrderCount) {
            uint8 oldestNotFilledOrderIndex = reBalanceState
                .soRemovablePosSell
                .leftMostUnsetBitPos();
            (uint128 pip, uint64 orderIdx, ) = PackedOrderId.unpack(
                _liquidityPool.supplyOrders[128 + oldestNotFilledOrderIndex]
            );
            (
                bool isFilled,
                ,
                uint256 baseSize,
                uint256 partialFilled
            ) = _pairManager.getPendingOrderDetail(pip, orderIdx);
            if (isFilled) {
                totalQuoteGetBack += uint128(baseSize).baseToQuote(
                    pip,
                    uint128(_pairManager.getBasisPoint())
                );
            } else {
                _pairManager.cancelLimitOrder(pip, orderIdx);
                totalQuoteGetBack += uint128(partialFilled).baseToQuote(
                    pip,
                    uint128(_pairManager.getBasisPoint())
                );
                totalBaseGetBack += baseSize - partialFilled;
            }
            reBalanceState.soRemovablePosSell = PoolLiquidity
                .markSoRemovablePos(
                    reBalanceState.soRemovablePosSell,
                    oldestNotFilledOrderIndex
                );
            pendingOrderCount--;
        }
        reBalanceState.claimableQuote += totalQuoteGetBack;
        reBalanceState.claimableBase += totalBaseGetBack;
        //        _collectFundPairManager(_poolId,_pairManager, totalQuoteGetBack, totalBaseGetBack);
    }

    /**
     * @dev collect claimable assets from filled orders in pair manager
     */
    function _collectFundPairManager(
        bytes32 _poolId,
        IPairManager _pairManager,
        uint256 _baseAmount,
        uint256 _quoteAmount
    ) internal {
        _pairManager.collectFund(
            _pairManager.getBaseAsset(),
            address(this),
            _baseAmount
        );
        _pairManager.collectFund(
            _pairManager.getQuoteAsset(),
            address(this),
            _quoteAmount
        );

        if (_poolId != bytes32(0)) {
            balanceOfPool[_poolId].increaseBalanceOfPool(
                uint128(_baseAmount),
                uint128(_quoteAmount)
            );
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/VotesUpgradeable.sol";

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
//import "@openzeppelin/contracts/governance/utils/Votes.sol";

/// @title Manage the Liquidity NFT
/// @notice This NFT is voteable
abstract contract LiquidityNFT is
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    VotesUpgradeable
{
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Adjusts votes when tokens are transferred.
     *
     * Emits a {Votes-DelegateVotesChanged} event.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        _transferVotingUnits(from, to, 1);
        super._afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Returns the balance of `account`.
     */
    function _getVotingUnits(address account)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return balanceOf(account);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner.
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function tokensOfOwner(address owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 balance = balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance);

        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(owner, i);
        }

        return tokens;
    }

    function _burnNFT(uint256 tokenId) internal {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burn: caller is not owner nor approved"
        );
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../liquidity/PoolLiquidity.sol";
import "../liquidity/LiquidityInfo.sol";
import "../../../interfaces/ISpotFactory.sol";
import "../../../interfaces/INonfungiblePositionLiquidityPool.sol";
import "../liquidity/BalanceOfPool.sol";

contract PositionLiquidityPoolStorage {
    struct DepositAmount {
        uint128 base;
        uint128 quote;
    }

    struct LimitLiquidity {
        uint128 liquidityLimitUser;
        uint128 liquidityLimitPool;
    }

    ISpotFactory public spotFactory;

    INonfungiblePositionLiquidityPool public nftLiquidityPool;

    uint128 feeBasis;

    // fee 0.01 %
    uint16 public feeShareRatio;

    // hash(pair, strategy) => poolInfo
    mapping(bytes32 => PoolLiquidity.PoolLiquidityInfo) public poolInfo;
    // tokenId => LiquidityInfo
    mapping(uint256 => LiquidityInfo.Data) public liquidityInfo;
    // poolId => depositAmount
    mapping(bytes32 => DepositAmount) public depositAmount;

    mapping(bytes32 => LimitLiquidity) public limitLiquidity;

    function totalOrderSupply(bytes32 poolKey) public view returns (uint256) {
        return poolInfo[poolKey].supplyOrders.length;
    }

    uint8 public maxNumberOfGridOrderEachSide;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;

    mapping(bytes32 => BalanceOfPool.Balance) public balanceOfPool;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library PoolKey {
    function computePoolKey(address pair, address strategy)
        internal
        view
        returns (bytes32)
    {
        return keccak256(abi.encode(pair, strategy));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "./IERC721EnumerableUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (governance/utils/Votes.sol)
pragma solidity ^0.8.0;

import "../../utils/ContextUpgradeable.sol";
import "../../utils/CountersUpgradeable.sol";
import "../../utils/CheckpointsUpgradeable.sol";
import "../../utils/cryptography/draft-EIP712Upgradeable.sol";
import "./IVotesUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev This is a base abstract contract that tracks voting units, which are a measure of voting power that can be
 * transferred, and provides a system of vote delegation, where an account can delegate its voting units to a sort of
 * "representative" that will pool delegated voting units from different accounts and can then use it to vote in
 * decisions. In fact, voting units _must_ be delegated in order to count as actual votes, and an account has to
 * delegate those votes to itself if it wishes to participate in decisions and does not have a trusted representative.
 *
 * This contract is often combined with a token contract such that voting units correspond to token units. For an
 * example, see {ERC721Votes}.
 *
 * The full history of delegate votes is tracked on-chain so that governance protocols can consider votes as distributed
 * at a particular block number to protect against flash loans and double voting. The opt-in delegate system makes the
 * cost of this history tracking optional.
 *
 * When using this module the derived contract must implement {_getVotingUnits} (for example, make it return
 * {ERC721-balanceOf}), and can use {_transferVotingUnits} to track a change in the distribution of those units (in the
 * previous example, it would be included in {ERC721-_beforeTokenTransfer}).
 *
 * _Available since v4.5._
 */
abstract contract VotesUpgradeable is Initializable, IVotesUpgradeable, ContextUpgradeable, EIP712Upgradeable {
    function __Votes_init() internal onlyInitializing {
    }

    function __Votes_init_unchained() internal onlyInitializing {
    }
    using CheckpointsUpgradeable for CheckpointsUpgradeable.History;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 private constant _DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => address) private _delegation;
    mapping(address => CheckpointsUpgradeable.History) private _delegateCheckpoints;
    CheckpointsUpgradeable.History private _totalCheckpoints;

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) public view virtual override returns (uint256) {
        return _delegateCheckpoints[account].latest();
    }

    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastVotes(address account, uint256 blockNumber) public view virtual override returns (uint256) {
        return _delegateCheckpoints[account].getAtBlock(blockNumber);
    }

    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastTotalSupply(uint256 blockNumber) public view virtual override returns (uint256) {
        require(blockNumber < block.number, "Votes: block not yet mined");
        return _totalCheckpoints.getAtBlock(blockNumber);
    }

    /**
     * @dev Returns the current total supply of votes.
     */
    function _getTotalSupply() internal view virtual returns (uint256) {
        return _totalCheckpoints.latest();
    }

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) public view virtual override returns (address) {
        return _delegation[account];
    }

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) public virtual override {
        address account = _msgSender();
        _delegate(account, delegatee);
    }

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= expiry, "Votes: signature expired");
        address signer = ECDSAUpgradeable.recover(
            _hashTypedDataV4(keccak256(abi.encode(_DELEGATION_TYPEHASH, delegatee, nonce, expiry))),
            v,
            r,
            s
        );
        require(nonce == _useNonce(signer), "Votes: invalid nonce");
        _delegate(signer, delegatee);
    }

    /**
     * @dev Delegate all of `account`'s voting units to `delegatee`.
     *
     * Emits events {DelegateChanged} and {DelegateVotesChanged}.
     */
    function _delegate(address account, address delegatee) internal virtual {
        address oldDelegate = delegates(account);
        _delegation[account] = delegatee;

        emit DelegateChanged(account, oldDelegate, delegatee);
        _moveDelegateVotes(oldDelegate, delegatee, _getVotingUnits(account));
    }

    /**
     * @dev Transfers, mints, or burns voting units. To register a mint, `from` should be zero. To register a burn, `to`
     * should be zero. Total supply of voting units will be adjusted with mints and burns.
     */
    function _transferVotingUnits(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (from == address(0)) {
            _totalCheckpoints.push(_add, amount);
        }
        if (to == address(0)) {
            _totalCheckpoints.push(_subtract, amount);
        }
        _moveDelegateVotes(delegates(from), delegates(to), amount);
    }

    /**
     * @dev Moves delegated votes from one delegate to another.
     */
    function _moveDelegateVotes(
        address from,
        address to,
        uint256 amount
    ) private {
        if (from != to && amount > 0) {
            if (from != address(0)) {
                (uint256 oldValue, uint256 newValue) = _delegateCheckpoints[from].push(_subtract, amount);
                emit DelegateVotesChanged(from, oldValue, newValue);
            }
            if (to != address(0)) {
                (uint256 oldValue, uint256 newValue) = _delegateCheckpoints[to].push(_add, amount);
                emit DelegateVotesChanged(to, oldValue, newValue);
            }
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        CountersUpgradeable.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }

    /**
     * @dev Returns an address nonce.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev Returns the contract's {EIP712} domain separator.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev Must return the voting units held by an account.
     */
    function _getVotingUnits(address) internal view virtual returns (uint256);

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Checkpoints.sol)
pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";
import "./math/SafeCastUpgradeable.sol";

/**
 * @dev This library defines the `History` struct, for checkpointing values as they change at different points in
 * time, and later looking up past values by block number. See {Votes} as an example.
 *
 * To create a history of checkpoints define a variable type `Checkpoints.History` in your contract, and store a new
 * checkpoint for the current transaction block using the {push} function.
 *
 * _Available since v4.5._
 */
library CheckpointsUpgradeable {
    struct Checkpoint {
        uint32 _blockNumber;
        uint224 _value;
    }

    struct History {
        Checkpoint[] _checkpoints;
    }

    /**
     * @dev Returns the value in the latest checkpoint, or zero if there are no checkpoints.
     */
    function latest(History storage self) internal view returns (uint256) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : self._checkpoints[pos - 1]._value;
    }

    /**
     * @dev Returns the value at a given block number. If a checkpoint is not available at that block, the closest one
     * before it is returned, or zero otherwise.
     */
    function getAtBlock(History storage self, uint256 blockNumber) internal view returns (uint256) {
        require(blockNumber < block.number, "Checkpoints: block not yet mined");

        uint256 high = self._checkpoints.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (self._checkpoints[mid]._blockNumber > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high == 0 ? 0 : self._checkpoints[high - 1]._value;
    }

    /**
     * @dev Pushes a value onto a History so that it is stored as the checkpoint for the current block.
     *
     * Returns previous value and new value.
     */
    function push(History storage self, uint256 value) internal returns (uint256, uint256) {
        uint256 pos = self._checkpoints.length;
        uint256 old = latest(self);
        if (pos > 0 && self._checkpoints[pos - 1]._blockNumber == block.number) {
            self._checkpoints[pos - 1]._value = SafeCastUpgradeable.toUint224(value);
        } else {
            self._checkpoints.push(
                Checkpoint({_blockNumber: SafeCastUpgradeable.toUint32(block.number), _value: SafeCastUpgradeable.toUint224(value)})
            );
        }
        return (old, value);
    }

    /**
     * @dev Pushes a value onto a History, by updating the latest value using binary operation `op`. The new value will
     * be set to `op(latest, delta)`.
     *
     * Returns previous value and new value.
     */
    function push(
        History storage self,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) internal returns (uint256, uint256) {
        return push(self, op(latest(self), delta));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (governance/utils/IVotes.sol)
pragma solidity ^0.8.0;

/**
 * @dev Common interface for {ERC20Votes}, {ERC721Votes}, and other {Votes}-enabled contracts.
 *
 * _Available since v4.5._
 */
interface IVotesUpgradeable {
    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to a delegate's number of votes.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     */
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address);

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external;

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "../spot-exchange/libraries/liquidity/LiquidityInfo.sol";

interface INonfungiblePositionLiquidityPool is IERC721Upgradeable {
    function mint(address user) external returns (uint256 tokenId);

    function burn(uint256 tokenId) external;

    function voteFor() external;

    function voteAgainst() external;

    function getDataNonfungibleToken(uint256 tokenId)
        external
        view
        returns (LiquidityInfo.Data memory);
}

/**
 * @author Musket
 */
pragma solidity ^0.8.0;

import "hardhat/console.sol";

library BalanceOfPool {
    struct Balance {
        uint128 base;
        uint128 quote;
    }

    function increaseBalanceOfPool(
        BalanceOfPool.Balance storage self,
        uint128 _base,
        uint128 _quote
    ) internal {
        if (_base > 0) {
            self.base += _base;
        }
        if (_quote > 0) {
            self.quote += _quote;
        }
    }

    function decreaseBalanceOfPool(
        BalanceOfPool.Balance storage self,
        uint128 _base,
        uint128 _quote
    ) internal {
        if (_base > 0) {
            self.base = self.base - _base;
        }

        if (_quote > 0) {
            self.quote = self.quote - _quote;
        }
    }

    function accumulateBalanceOfPool(
        BalanceOfPool.Balance storage self,
        uint128 _base,
        uint128 _quote
    ) internal {
        self.base = _base;
        self.quote = _quote;
    }
}

pragma solidity ^0.8.0;

import "../spot-exchange/libraries/liquidity/PoolLiquidity.sol";
import "../spot-exchange/PositionLiquidityPool.sol";
import "./../spot-exchange/strategy/StableTokenStrategy.sol";

// @dev mock contract supports writing unit test for PositionLiquidityPool contract
contract TestPositionLiquidityPool is PositionLiquidityPool {
    using PoolLiquidity for PoolLiquidity.PoolLiquidityInfo;
    using PoolLiquidity for bytes32[256];
    using PoolLiquidity for int256;
    using PoolLiquidity for int128;
    using PackedOrderId for uint128;

    bytes32 dummyPoolId =
        0x0000000000000000000000000000000000000000000000000000000000000000;

    constructor() {
        // @dev initialize soRemovablePosBuy and soRemovablePosSell values for poolInfo[dummyPoolId]
        PoolLiquidity.PoolLiquidityInfo memory dummyPool;
        dummyPool.soRemovablePosBuy = type(int128).max;
        dummyPool.soRemovablePosSell = type(int128).max;
        poolInfo[dummyPoolId] = dummyPool;
        maxNumberOfGridOrderEachSide = 6;
    }

    // @dev set pair manager for poolInfo[dummyPoolId]
    function setPairManagerInDummyPositionLiquidityPool(address _pairManager)
        public
    {
        poolInfo[dummyPoolId].pairManager = _pairManager;
    }

    // @dev set rebalance strategy for poolInfo[dummyPoolId]
    function setRebalanceStrategyInDummyPositionLiquidityPool(
        address _rebalanceStrategy
    ) public {
        poolInfo[dummyPoolId].strategy = _rebalanceStrategy;
    }

    // @dev set new value of a mock supply order in supplyOrders and mark its position in soRemovablePosBuy or soRemovablePosSell
    function setSupplyOrderInDummyPositionLiquidityPool(
        bool _isBuy,
        uint128 _pip,
        uint64 _orderId,
        uint8 _position,
        bool _isFilled
    ) public {
        if (_isBuy) {
            poolInfo[dummyPoolId].soRemovablePosBuy = _isFilled
                ? poolInfo[dummyPoolId].soRemovablePosBuy.markSoRemovablePos(
                    _position
                )
                : poolInfo[dummyPoolId]
                    .soRemovablePosBuy
                    .clearBitPositionInt128(_position);
            poolInfo[dummyPoolId].supplyOrders[_position] = _pip.pack(
                _orderId,
                _isBuy
            );
            return;
        }
        poolInfo[dummyPoolId].soRemovablePosSell = _isFilled
            ? poolInfo[dummyPoolId].soRemovablePosSell.markSoRemovablePos(
                _position
            )
            : poolInfo[dummyPoolId].soRemovablePosSell.clearBitPositionInt128(
                _position
            );
        poolInfo[dummyPoolId].supplyOrders[_position + 128] = _pip.pack(
            _orderId,
            _isBuy
        );
        return;
    }

    // @dev cancel redundant grid orders in poolInfo[dummyPoolId]
    function cancelRedundantGridOrdersInDummyPositionLiquidityPool(
        IPairManager _pairManager
    ) public {
        //        _cancelRedundantGridOrders(
        //            dummyPoolId,
        //            poolInfo[dummyPoolId],
        //            _pairManager,
        //            IRebalanceStrategy(poolInfo[dummyPoolId].strategy)
        //
        //        );
    }

    function getDummyPositionLiquidityPoolInfo()
        public
        view
        returns (PoolLiquidity.PoolLiquidityInfo memory)
    {
        return poolInfo[dummyPoolId];
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../libraries/liquidity/Grid.sol";
import "../../interfaces/IRebalanceStrategy.sol";

import "hardhat/console.sol";

contract StableTokenStrategy is
    IRebalanceStrategy,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{
    uint16 public numberOfSupplyOrdersEachSide;
    uint128 public stepPip;

    function initialize() public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();

        numberOfSupplyOrdersEachSide = 2;
        stepPip = 2;
    }

    function getSupplyPrices(
        uint128 currentPip,
        uint128 quote,
        uint128 base
    ) external view override returns (Grid.GridOrderData[] memory) {
        if (currentPip > 100010 || currentPip < 99990) {
            currentPip = 100000;
        }

        require(
            currentPip - numberOfSupplyOrdersEachSide * stepPip > 0,
            "Out range"
        );

        Grid.GridOrderData[] memory grid = new Grid.GridOrderData[](
            numberOfSupplyOrdersEachSide * 2
        );

        uint256 amountQuoteEachGrid = quote / numberOfSupplyOrdersEachSide;

        uint256 amountBaseEachGrid = base / numberOfSupplyOrdersEachSide;

        for (uint128 i = 0; i < numberOfSupplyOrdersEachSide; i++) {
            // Sell grid
            grid[i] = Grid.GridOrderData(
                currentPip + ((i + 1) * stepPip),
                int256(amountBaseEachGrid)
            );

            // Buy gird
            grid[i + numberOfSupplyOrdersEachSide] = Grid.GridOrderData(
                currentPip - ((i + 1) * stepPip),
                -int256(amountQuoteEachGrid)
            );
        }
        return grid;
    }

    function updateNumberOfGridEachSide(uint16 _newNumberOfGrid)
        public
        onlyOwner
    {
        require(_newNumberOfGrid > 0, "!0");
        numberOfSupplyOrdersEachSide = _newNumberOfGrid;
    }

    function updateStepPip(uint128 _newStep) public onlyOwner {
        require(_newStep > 0, "!0");
        stepPip = _newStep;
    }

    function getNumberOfSupplyOrdersEachSide()
        external
        view
        override
        returns (uint16)
    {
        return numberOfSupplyOrdersEachSide;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

/**
 * @author Musket
 */
pragma solidity ^0.8.0;

import "../interfaces/ILiquidityPool.sol";
import "../spot-exchange/implement/LiquidityNFT.sol";
import "../interfaces/IPairManager.sol";
import "../interfaces/ISpotFactory.sol";
import "../spot-exchange/libraries/types/PositionLiquidityPoolStorage.sol";

contract MockPositionLiquidityPool {}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../interfaces/ISpotFactory.sol";
import "./PairManager.sol";
import "./libraries/types/SpotFactoryStorage.sol";
import "./implement/NoDelegateCall.sol";
import "./libraries/helper/Errors.sol";

contract SpotFactory is
    ISpotFactory,
    SpotFactoryStorage,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{
    function initialize(address _spotHouse) external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();

        spotHouse = _spotHouse;
    }

    // DIASBLE FOR PHASE II
    function createPairManager(
        address _quoteAsset,
        address _baseAsset,
        uint256 _basisPoint,
        uint256 _BASE_BASIC_POINT,
        uint128 _maxFindingWordsIndex,
        uint128 _initialPip,
        uint64 _expireTime
    ) external whenNotPaused {
        //        require(
        //            _quoteAsset != address(0) && _baseAsset != address(0),
        //            Errors.VL_EMPTY_ADDRESS
        //        );
        //        require(_quoteAsset != _baseAsset, Errors.VL_MUST_IDENTICAL_ADDRESSES);
        //        require(
        //            pathPairManagers[_baseAsset][_quoteAsset] == address(0),
        //            Errors.VL_SPOT_MANGER_EXITS
        //        );
        //
        //        address _pairManager;
        //        bytes memory bytecode = type(PairManager).creationCode;
        //        bytes32 salt = keccak256(
        //            abi.encodePacked(_baseAsset, _quoteAsset, address(this))
        //        );
        //        assembly {
        //            _pairManager := create2(0, add(bytecode, 32), mload(bytecode), salt)
        //        }
        //
        //        IPairManager(_pairManager).initializeFactory(
        //            _quoteAsset,
        //            _baseAsset,
        //            spotHouse,
        //            _basisPoint,
        //            _BASE_BASIC_POINT,
        //            _maxFindingWordsIndex,
        //            _initialPip,
        //            _expireTime,
        //            msg.sender,
        //            liquidityPool
        //        );
        //
        //        // save
        //        pathPairManagers[_baseAsset][_quoteAsset] = _pairManager;
        //
        //        allPairManager[_pairManager] = Pair({
        //            BaseAsset: _baseAsset,
        //            QuoteAsset: _quoteAsset
        //        });
        //
        //        emit PairManagerCreated(_pairManager);
    }

    function getPairManager(address quoteAsset, address baseAsset)
        external
        view
        override
        returns (address spotManager)
    {
        return pathPairManagers[baseAsset][quoteAsset];
    }

    function getPairManagerSupported(address tokenA, address tokenB)
        public
        view
        override
        returns (
            address baseToken,
            address quoteToken,
            address pairManager
        )
    {
        if (pathPairManagers[tokenA][tokenB] != address(0)) {
            return (tokenA, tokenB, pathPairManagers[tokenA][tokenB]);
        }
        if (pathPairManagers[tokenB][tokenA] != address(0)) {
            return (tokenB, tokenA, pathPairManagers[tokenB][tokenA]);
        }
    }

    function getQuoteAndBase(address pairManager)
        external
        view
        override
        returns (Pair memory)
    {
        return allPairManager[pairManager];
    }

    function isPairManagerExist(address pairManager)
        external
        view
        override
        returns (bool)
    {
        // Just 1 in 2 address need require != address 0x000
        // Because when we added pair, already require both of them difference address 0x00
        return allPairManager[pairManager].BaseAsset != address(0);
    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function setSpotHouse(address newSpotHouse) external onlyOwner {
        spotHouse = newSpotHouse;
    }

    function setLiquidityPool(address _liquidityPool) external onlyOwner {
        require(_liquidityPool != address(0), Errors.VL_EMPTY_ADDRESS);
        liquidityPool = _liquidityPool;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function addPairManagerManual(
        address _pairManager,
        address _baseAsset,
        address _quoteAsset
    ) external onlyOwner {
        require(
            _quoteAsset != address(0) && _baseAsset != address(0),
            Errors.VL_EMPTY_ADDRESS
        );
        require(_quoteAsset != _baseAsset, Errors.VL_MUST_IDENTICAL_ADDRESSES);
        require(
            pathPairManagers[_baseAsset][_quoteAsset] == address(0),
            Errors.VL_SPOT_MANGER_EXITS
        );

        // save
        pathPairManagers[_baseAsset][_quoteAsset] = _pairManager;

        allPairManager[_pairManager] = Pair({
            BaseAsset: _baseAsset,
            QuoteAsset: _quoteAsset
        });

        emit PairManagerCreated(_pairManager);
    }

    // IMPORTANT
    // This function only for dev. MUST remove when launch production
    function delPairManager(address pairManager) external onlyOwner {
        Pair storage pair = allPairManager[pairManager];
        pathPairManagers[address(pair.BaseAsset)][
            address(pair.QuoteAsset)
        ] = address(0);

        allPairManager[pairManager] = Pair({
            BaseAsset: address(0),
            QuoteAsset: address(0)
        });
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title Prevents delegatecall to a contract
/// @notice Base contract that provides a modifier for preventing delegatecall to methods in a child contract
abstract contract NoDelegateCall {
    /// @dev The original address of this contract
    address private immutable original;

    constructor() {
        // Immutables are computed in the init code of the contract, and then inlined into the deployed bytecode.
        // In other words, this variable won't change when it's checked at runtime.
        original = address(this);
    }

    /// @dev Private method is used instead of inlining into modifier because modifiers are copied into each method,
    ///     and the use of immutable means the address bytes are copied in every place the modifier is used.
    function checkNotDelegateCall() private view {
        require(address(this) == original);
    }

    /// @notice Prevents delegatecall into the modified method
    modifier noDelegateCall() {
        checkNotDelegateCall();
        _;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {Errors} from "./libraries/helper/Errors.sol";
import "./implement/LiquidityNFT.sol";
import "../interfaces/ILiquidityPool.sol";
import "../interfaces/INonfungiblePositionLiquidityPool.sol";

contract NonfungiblePositionLiquidityPool is
    INonfungiblePositionLiquidityPool,
    LiquidityNFT,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{
    address public counterParty;
    uint256 public tokenID;
    mapping(address => bool) public counterParties;

    modifier onlyCounterParty() {
        require(counterParties[_msgSender()], Errors.VL_ONLY_COUNTERPARTY);
        _;
    }

    function initialize() external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __ERC721_init("Position Liquidity Pool", "PLP");
        __EIP712_init("Position Liquidity NFT", "1.0.0");
        tokenID = 1000000;
    }

    function mint(address user)
        external
        override
        onlyCounterParty
        returns (uint256 tokenId)
    {
        tokenId = tokenID + 1;
        _mint(user, tokenId);
        tokenID = tokenId;
    }

    function burn(uint256 tokenId) external override onlyCounterParty {
        _burnNFT(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable)
        returns (string memory)
    {
        return "";
    }

    function getDataNonfungibleToken(uint256 tokenId)
        external
        view
        override
        returns (LiquidityInfo.Data memory)
    {
        return ILiquidityPool(counterParty).getDataNonfungibleToken(tokenId);
    }

    function getAllToken(address owner)
        external
        view
        returns (LiquidityInfo.Data[] memory, uint256[] memory)
    {
        uint256[] memory tokens = tokensOfOwner(owner);
        return (ILiquidityPool(counterParty).getAllDataTokens(tokens), tokens);
    }

    function _msgSender()
        internal
        view
        override(ContextUpgradeable)
        returns (address)
    {
        return msg.sender;
    }

    function _msgData()
        internal
        view
        override(ContextUpgradeable)
        returns (bytes calldata)
    {
        return msg.data;
    }

    function voteFor() external override {
        uint256 vote = 0;
    }

    function voteAgainst() external override {}

    //------------------------------------------------------------------------------------------------------------------
    // OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function setCounterParty(address _newCounterParty) external onlyOwner {
        counterParties[_newCounterParty] = true;
    }

    function rebokeCounterParty(address _account) external onlyOwner {
        counterParties[_account] = false;
    }
}

pragma solidity >=0.6.0 <=0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@positionex/posi-token/contracts/VestingScheduleBase.sol";
import "../interfaces/ILiquidityPool.sol";

interface IPositionReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission)
        external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

interface IPosiTreasury {
    function mint(address recipient, uint256 amount) external;
}

interface IPosiStakingManager {
    struct VestingData {
        uint64 vestingTime;
        uint192 amount;
    }

    enum Frequency {
        Daily, // 1 days
        Weekly, // 7 days
        Monthly, // 30 days
        Bimonthly, // 2 months
        Quarterly, // 3 months
        Biannually // 6 months
    }
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _referrer
    ) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function totalAllocPoint() external view returns (uint256);

    function poolInfo(uint256 pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accPositionPerShare,
            uint16 depositFeeBP,
            uint256 harvestInterval
        );

    function positionPerBlock() external view returns (uint256);
    function claimVestingBatch(Frequency[] memory freqs, uint256[] memory index) external;
    function getVestingSchedules(address user, Frequency freq) external view returns (VestingData[] memory);
}

interface ILiquidityNFT is IERC721 {
    function tokensOfOwner(address owner)
    external
    view
    returns (uint256[] memory);
}

//library U128Math {
//    function toU256(uint128 n) internal pure returns(uint256){
//        return uint256(n);
//    }
//    function add(uint128 a, uint128 b) internal pure returns (uint128){
//        return a + b;
//    }
//    function sub(uint128 a, uint128 b) internal pure returns (uint128){
//        return a - b;
//    }
//    function mul(uint128 a, uint256 b) internal pure returns (uint256){
//        return uint256(a)*b;
//    }
//}

// Staking Position Exchange Liquididty NFT
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Position is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract LiquidityNFTStakingV2 is
    ERC20Upgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    VestingScheduleBase
{
    using SafeMath for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using U128Math for uint128;

    // Info of each user.
    struct UserInfo {
        uint128 amount; // How many LP tokens the user has provided.
        uint128 rewardDebt; // Reward debt. See explanation below.
        uint128 rewardLockedUp; // Reward locked up.
        uint128 nextHarvestUntil; // When can the user harvest again.
        //
        // We do some fancy math here. Basically, any point in time, the amount of Positions
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPositionPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPositionPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        bytes32 poolId;
        uint256 totalStaked;
        uint256 allocPoint; // How many allocation points assigned to this pool. Positions to distribute per block.
        uint256 lastRewardBlock; // Last block number that Positions distribution occurs.
        uint256 accPositionPerShare; // Accumulated Positions per share, times 1e12. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint128 harvestInterval; // Harvest interval in seconds
    }

    // The Position TOKEN!
    IERC20 public position;
    IPosiStakingManager public posiStakingManager;
    ILiquidityPool public positionLiquidityPool;
    ILiquidityNFT public liquidityNFT;
    // Dev address.
    address public devAddress;
    // Deposit Fee address
    address public feeAddress;
    // Bonus muliplier for early position makers.
    uint256 public BONUS_MULTIPLIER;
    // Max harvest interval: 14 days.
    uint256 public MAXIMUM_HARVEST_INTERVAL;

    // Info of each pool.
    mapping(bytes32 => PoolInfo) public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(bytes32 => mapping(address => UserInfo)) public userInfo;
    bytes32[] public pools;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    // The block number when Position mining starts.
    uint256 public startBlock;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;

    uint256 public posiStakingPid;

    // Position referral contract address.
    IPositionReferral public positionReferral;
    // Referral commission rate in basis points.
    uint16 public referralCommissionRate;
    // Max referral commission rate: 10%.
    uint16 public MAXIMUM_REFERRAL_COMMISSION_RATE;

    uint16 harvestFeeShareRate;
    uint16 public MAXIMUM_HARVEST_FEE_SHARE;

    // user => poolId => nftId[]
    mapping(address => mapping(bytes32 => uint256[])) public userNft;
    // nftid => poolId => its index in userNft
    mapping(uint256 => mapping(bytes32 => uint256)) public nftOwnedIndex;

    event Deposit(address indexed user, bytes32 indexed pid, uint256 amount);
    event Withdraw(address indexed user, bytes32 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        bytes32 indexed pid,
        uint256 amount
    );
    event EmissionRateUpdated(
        address indexed caller,
        uint256 previousAmount,
        uint256 newAmount
    );
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );
    event RewardLockedUp(
        address indexed user,
        bytes32 indexed pid,
        uint256 amountLockedUp
    );
    event NFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    );

    function initialize(
        IERC20 _position,
        IPosiStakingManager _posiStakingManager,
        ILiquidityPool _positionLiquidityPool,
        ILiquidityNFT _liquidityNFT,
        uint256 _startBlock
    ) external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __ERC20_init("Position Staking Liquidity Token", "SL");

        position = _position;
        startBlock = _startBlock;

        posiStakingManager = _posiStakingManager;
        positionLiquidityPool = _positionLiquidityPool;
        liquidityNFT = _liquidityNFT;

        devAddress = _msgSender();
        feeAddress = _msgSender();

        referralCommissionRate = 100;
        MAXIMUM_REFERRAL_COMMISSION_RATE = 1000;

        harvestFeeShareRate = 1;
        MAXIMUM_HARVEST_FEE_SHARE = 10000;

        BONUS_MULTIPLIER = 1;

        MAXIMUM_HARVEST_INTERVAL = 14 days;

        totalAllocPoint = 0;

        _mint(address(this), 10 * 10**18);
    }

    function poolLength() external view returns (uint256) {
        return pools.length;
    }

    // get position per block form the staking manager share to the contract
    function getPositionPerBlock() public view returns (uint256) {
        (, uint256 allocPoint, , , , ) = posiStakingManager.poolInfo(
            posiStakingPid
        );
        uint256 totalAllocPoint = posiStakingManager.totalAllocPoint();
        uint256 posiPerBlock = posiStakingManager.positionPerBlock();
        return (posiPerBlock * allocPoint) / totalAllocPoint;
    }

    function getPlayerIds(address owner, bytes32 pid)
        public
        view
        returns (uint256[] memory)
    {
        return userNft[owner][pid];
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {
        emit NFTReceived(operator, from, tokenId, data);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY_OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------
    function updatePositionLiquidityPool(address _newLiquidityPool)
        public
        onlyOwner
    {
        positionLiquidityPool = ILiquidityPool(_newLiquidityPool);
    }

    function updateStakingManager(address _newStakingManager) public onlyOwner {
        posiStakingManager = IPosiStakingManager(_newStakingManager);
    }

    function updateLiquidityNFT(address _newLiquidityNFT) public onlyOwner {
        liquidityNFT = ILiquidityNFT(_newLiquidityNFT);
    }

    function approvePositionStakingManager() public onlyOwner {
        IERC20(address(this)).approve(
            address(posiStakingManager),
            type(uint256).max
        );
    }

    function stakePositionStakingManager() public onlyOwner {
        posiStakingManager.deposit(
            posiStakingPid,
            balanceOf(address(this)),
            address(0)
        );
    }

    function unStakePositionStakingManager(uint256 amount) public onlyOwner {
        posiStakingManager.withdraw(posiStakingPid, amount);
    }

    function harvestPositionStakingManagerOwner() public onlyOwner {
        posiStakingManager.deposit(posiStakingPid, 0, address(0));
    }

    function updateHarvestFeeShareRate(uint16 newRate) public onlyOwner {
        // max share 10%
        require(newRate <= 1000, "!F");
        harvestFeeShareRate = newRate;
    }

    function setPosiStakingPid(uint256 _posiStakingPid) public onlyOwner {
        posiStakingPid = _posiStakingPid;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        bytes32 _poolId,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        uint128 _harvestInterval,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "add: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "add: invalid harvest interval"
        );
        require(poolInfo[_poolId].lastRewardBlock == 0, "pool created");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        pools.push(_poolId);
        poolInfo[_poolId] = PoolInfo({
            poolId: _poolId,
            totalStaked: 0,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accPositionPerShare: 0,
            depositFeeBP: _depositFeeBP,
            harvestInterval: _harvestInterval
        });
    }

    // Update the given pool's Position allocation point and deposit fee. Can only be called by the owner.
    function set(
        bytes32 _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        uint128 _harvestInterval,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "set: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "set: invalid harvest interval"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending Positions on frontend.
    function pendingPosition(bytes32 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accPositionPerShare = pool.accPositionPerShare;
        uint256 lpSupply = pool.totalStaked;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 positionReward = multiplier
                .mul(getPositionPerBlock())
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accPositionPerShare = accPositionPerShare.add(
                positionReward.mul(1e12).div(lpSupply)
            );
        }
        uint256 pending = user.amount.mul(accPositionPerShare).div(1e12).sub(
            user.rewardDebt
        );
        return pending.add(user.rewardLockedUp);
    }

    // View function to see if user can harvest Positions.
    function canHarvest(bytes32 _pid, address _user)
        public
        view
        returns (bool)
    {
        UserInfo memory user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = pools.length;
        for (uint256 i = 0; i < length; ++i) {
            updatePool(pools[i]);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(bytes32 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        // SLOAD
        PoolInfo memory _pool = pool;
        if (block.number <= _pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = _pool.totalStaked;
        if (lpSupply == 0 || _pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(_pool.lastRewardBlock, block.number);
        uint256 positionReward = multiplier
            .mul(getPositionPerBlock())
            .mul(_pool.allocPoint)
            .div(totalAllocPoint);

        // TODO consider harvest reward here
        pool.accPositionPerShare = pool.accPositionPerShare.add(
            positionReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function harvestPositionStakingManager() public {
        uint256 _balanceBefore = position.balanceOf(address(this));
        posiStakingManager.deposit(posiStakingPid, 0, address(0));
        uint256 _balanceAfter = position.balanceOf(address(this));

        if (_balanceAfter > _balanceBefore) {
            uint256 shareRewardAmount = ((_balanceAfter - _balanceBefore) *
                harvestFeeShareRate) / MAXIMUM_HARVEST_FEE_SHARE;
            position.transfer(_msgSender(), shareRewardAmount);
        }
    }

    // Deposit LP tokens to PosiStakingManager for Position allocation.
    function stake(uint256 _nftId) public nonReentrant {
        _stake(_nftId, address(0));
    }

    function depositAll() public nonReentrant {
        uint256[] memory nfts = liquidityNFT.tokensOfOwner(msg.sender);
        for(uint256 index = 1; index < nfts.length; index++){
            LiquidityInfo.Data memory nftData = positionLiquidityPool
            .getDataNonfungibleToken(nfts[index]);
            if(nftData.poolId != bytes32(0))
                _stake(nfts[index], address(0));
        }
    }

    function stakeWithReferral(uint256 _nftId, address _referrer)
        public
        nonReentrant
    {
        _stake(_nftId, _referrer);
    }

    function _stake(uint256 _nftId, address _referrer) internal {
        LiquidityInfo.Data memory nftData = positionLiquidityPool
            .getDataNonfungibleToken(_nftId);
        require(nftData.poolId != bytes32(0), "invalid liquidity pool");
        uint256[] storage nftIds = userNft[msg.sender][nftData.poolId];
        if (nftIds.length == 0) {
            nftIds.push(0);
            nftOwnedIndex[0][nftData.poolId] = 0;
        }
        nftIds.push(_nftId);
        nftOwnedIndex[_nftId][nftData.poolId] = nftIds.length - 1;

        PoolInfo storage pool = poolInfo[nftData.poolId];
        UserInfo storage user = userInfo[nftData.poolId][msg.sender];
        updatePool(nftData.poolId);
        if (
            nftData.amountOfFC > 0 &&
            address(positionReferral) != address(0) &&
            _referrer != address(0) &&
            _referrer != msg.sender
        ) {
            positionReferral.recordReferral(msg.sender, _referrer);
        }
        payOrLockupPendingPosition(nftData.poolId);
        _transferNFTIn(_nftId);
        user.amount = user.amount.add(nftData.amountOfFC);
        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
        pool.totalStaked += nftData.amountOfFC;
        emit Deposit(msg.sender, nftData.poolId, _nftId);
    }

    // Withdraw LP tokens from PosiStakingManager.
    function unstake(uint256 _nftId) public nonReentrant {
        _unstake(_nftId);
    }

    function _unstake(uint256 _nftId) internal {
        LiquidityInfo.Data memory nftData = positionLiquidityPool
            .getDataNonfungibleToken(_nftId);
        //        if(_wPid != 0x0 && _pid != _wPid) return;
        PoolInfo storage pool = poolInfo[nftData.poolId];
        UserInfo storage user = userInfo[nftData.poolId][msg.sender];

        removeNftFromUser(_nftId, nftData.poolId);

        require(user.amount >= nftData.amountOfFC, "withdraw: not good");

        updatePool(nftData.poolId);

        payOrLockupPendingPosition(nftData.poolId);

        user.amount = user.amount.sub(nftData.amountOfFC);
        _transferNFTOut(_nftId);

        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
        pool.totalStaked -= nftData.amountOfFC;

        emit Withdraw(msg.sender, nftData.poolId, _nftId);
    }

    function withdraw(bytes32 pid) public nonReentrant {
        _withdraw(pid);
    }

    function _withdraw(bytes32 pid) internal {
        uint256[] memory nfts = userNft[msg.sender][pid];
        for (uint8 index = 1; index < nfts.length; index++) {
            if (nfts[index] > 0) {
                _unstake(nfts[index]);
            }
        }
    }

    function harvest(bytes32 pid) public nonReentrant {
        _harvest(pid);
    }

    function _harvest(bytes32 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.amount > 0, "No nft staked");
        updatePool(pid);
        payOrLockupPendingPosition(pid);
        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
    }

    function exit(bytes32 pid) external nonReentrant {
        _withdraw(pid);
        //        _harvest(pid);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(bytes32 _pid) public nonReentrant {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        uint256[] memory nfts = userNft[msg.sender][_pid];
        for (uint8 index = 1; index < nfts.length; index++) {
            uint256 _nftId = nftOwnedIndex[index][_pid];
            if (_nftId > 0) {
                _transferNFTOut(_nftId);
                emit EmergencyWithdraw(msg.sender, _pid, _nftId);
            }
        }
    }

    // Pay or lockup pending Positions.
    function payOrLockupPendingPosition(bytes32 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil =
                uint128(block.timestamp) +
                pool.harvestInterval;
        }

        uint256 pending = user
            .amount
            .mul(pool.accPositionPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(
                    user.rewardLockedUp
                );
                user.rewardLockedUp = 0;
                user.nextHarvestUntil =
                    uint128(block.timestamp) +
                    pool.harvestInterval;

                // send rewards
                safePositionTransfer(msg.sender, totalRewards);
                payReferralCommission(msg.sender, totalRewards);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = uint128(
                user.rewardLockedUp.add(uint128(pending))
            );
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }

    function removeNftFromUser(uint256 _nftId, bytes32 _pid) internal {
        uint256[] memory _nftIds = userNft[msg.sender][_pid];
        uint256 nftIndex = nftOwnedIndex[_nftId][_pid];
        require(_nftIds[nftIndex] == _nftId, "not gegoId owner");
        uint256 _nftArrLength = _nftIds.length - 1;
        uint256 tailId = _nftIds[_nftArrLength];
        userNft[msg.sender][_pid][nftIndex] = tailId;
        userNft[msg.sender][_pid][_nftArrLength] = 0;
        userNft[msg.sender][_pid].pop();
        nftOwnedIndex[tailId][_pid] = nftIndex;
        nftOwnedIndex[_nftId][_pid] = 0;
    }

    // Safe position transfer function, just in case if rounding error causes pool to not have enough Positions.
    function safePositionTransfer(address _to, uint256 _amount) internal {
        uint256 positionBal = position.balanceOf(address(this));
        if (_amount > positionBal) {
            posiStakingManager.deposit(posiStakingPid, 0, address(0));
            // ORIGIN CODE
            //  posiStakingManager.harvest(posiStakingPid);
        }
        // receive 5%
        position.transfer(_to, _amount * 5 / 100);
        _addSchedules(_to, _amount);
    }

    // Update dev address by the previous dev.
    function setDevAddress(address _devAddress) public {
        require(msg.sender == devAddress, "setDevAddress: FORBIDDEN");
        require(_devAddress != address(0), "setDevAddress: ZERO");
        devAddress = _devAddress;
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        require(_feeAddress != address(0), "setFeeAddress: ZERO");
        feeAddress = _feeAddress;
    }

    // Update the position referral contract address by the owner
    function setPositionReferral(IPositionReferral _positionReferral)
        public
        onlyOwner
    {
        positionReferral = _positionReferral;
    }

    // Update referral commission rate by the owner
    function setReferralCommissionRate(uint16 _referralCommissionRate)
        public
        onlyOwner
    {
        require(
            _referralCommissionRate <= MAXIMUM_REFERRAL_COMMISSION_RATE,
            "setReferralCommissionRate: invalid referral commission rate basis points"
        );
        referralCommissionRate = _referralCommissionRate;
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(address _user, uint256 _pending) internal {
        if (
            address(positionReferral) != address(0) &&
            referralCommissionRate > 0
        ) {
            address referrer = positionReferral.getReferrer(_user);
            uint256 commissionAmount = _pending.mul(referralCommissionRate).div(
                10000
            );

            if (referrer != address(0) && commissionAmount > 0) {
                position.transfer(referrer, commissionAmount);
                positionReferral.recordReferralCommission(
                    referrer,
                    commissionAmount
                );
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

    function _transferNFTOut(uint256 id) internal {
        liquidityNFT.safeTransferFrom(address(this), msg.sender, id);
    }

    function _transferNFTIn(uint256 id) internal {
        liquidityNFT.safeTransferFrom(msg.sender, address(this), id);
    }

    function _msgSender()
        internal
        view
        override(ContextUpgradeable)
        returns (address)
    {
        return msg.sender;
    }

    function _msgData()
        internal
        view
        override(ContextUpgradeable)
        returns (bytes calldata)
    {
        return msg.data;
    }

    function _transferLockedToken(address _to, uint192 _amount) internal override {
        position.transfer(_to, _amount);
    }

    function changePosition(address newtoken) public onlyOwner {
        position = IERC20(newtoken);
    }

    function claimVestingScheduleBatch(IPosiStakingManager.Frequency[] memory freqs) public {
        uint256[] memory freqsLength = new uint256[](freqs.length);
        for(uint256 i = 0; i < freqs.length; i++) {
            IPosiStakingManager.VestingData[] memory _vestingData = posiStakingManager.getVestingSchedules(address(this), freqs[i]);
            freqsLength[i] = _vestingData.length;
        }
        posiStakingManager.claimVestingBatch(freqs, freqsLength);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./library/VestingFrequencyHelper.sol";

abstract contract VestingScheduleBase {
    using VestingFrequencyHelper for VestingFrequencyHelper.Frequency;

    mapping (address => mapping(VestingFrequencyHelper.Frequency => VestingData[])) public vestingSchedule;
    mapping (address => bool) internal _isWhiteListVesting;

    struct VestingData {
        uint64 vestingTime;
        uint192 amount;
    }

    event WhiteListVestingChanged(address indexed _address, bool _isWhiteListVesting);

    function getVestingSchedules(address user, VestingFrequencyHelper.Frequency freq) public virtual view returns (VestingData[] memory) {
        return vestingSchedule[user][freq];
    }

    function claimVesting(VestingFrequencyHelper.Frequency freq, uint256 index) public virtual {
        bool success = _claimVesting(msg.sender, freq, index);
        require(success, "claimVesting: failed");
    }

    function claimVestingBatch(VestingFrequencyHelper.Frequency[] memory freqs, uint256[] memory index) public virtual {
        for(uint256 i = 0; i < freqs.length; i++) {
            _claimVesting(msg.sender, freqs[i], index[i]);
        }
    }

    function _claimVesting(address user, VestingFrequencyHelper.Frequency freq, uint256 index) internal returns (bool success) {
        VestingData[] memory vestingSchedules = vestingSchedule[user][freq];
        require(index < vestingSchedules.length, "claimVesting: index out of range");
        for (uint256 i = 0; i <= index; i++) {
            VestingData memory schedule = vestingSchedules[i];
            if(block.timestamp >= schedule.vestingTime){
                // remove the vesting schedule
                _removeFirstSchedule(vestingSchedule[user][freq]);
                // transfer locked token
                _transferLockedToken(user, schedule.amount);
            }else{
                // don't need to shift to the next schedule
                // because the vesting schedule is sorted by timestamp
                return false;
            }
        }
        return true;
    }

    function _removeFirstSchedule(VestingData[] storage schedules) internal {
        for (uint256 i = 0; i < schedules.length-1; i++) {
            schedules[i] = schedules[i + 1];
        }
        schedules.pop();
    }

    function _addSchedules(address _to, uint256 _amount) internal virtual {
        // receive 5% after 1 day
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Daily, _amount * 5 / 100);
        // receive 10% after 7 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Weekly, _amount * 10 / 100);
        // receive 10% after 30 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Monthly, _amount * 10 / 100);
        // receive 20% after 60 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Bimonthly, _amount * 20 / 100);
        // receive 20% after 90 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Quarterly, _amount * 20 / 100);
        // receive 30% after 180 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Biannually, _amount * 30 / 100);
    }

    function _lockVestingSchedule(address _to, VestingFrequencyHelper.Frequency _freq, uint256 _amount) internal {
        vestingSchedule[_to][_freq].push(VestingData({
            amount: uint192(_amount),
            vestingTime: uint64(_freq.toTimestamp())
        }));
    }

    // use for mocking test
    function _setVestingTime(address user, uint8 freq, uint256 index, uint256 timestamp) internal {
        vestingSchedule[user][VestingFrequencyHelper.Frequency(freq)][index].vestingTime = uint64(timestamp);
    }

    function _setWhitelistVesting(address user, bool val) internal {
        _isWhiteListVesting[user] = val;
        emit WhiteListVestingChanged(user, val);
    }

    function _isWhitelistVesting(address user) internal view returns (bool) {
        return _isWhiteListVesting[user];
    }

    function _transferLockedToken(address _to, uint192 _amount) internal virtual;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

library VestingFrequencyHelper {
    enum Frequency {
        Daily, // 1 days
        Weekly, // 7 days
        Monthly, // 30 days
        Bimonthly, // 2 months
        Quarterly, // 3 months
        Biannually // 6 months
    }

    function toTimestamp(Frequency _freq) internal view returns (uint256) {
        if (_freq == Frequency.Daily) {
            return block.timestamp + 86400;
        } else if (_freq == Frequency.Weekly) {
            return block.timestamp + 604800;
        } else if (_freq == Frequency.Monthly) {
            return block.timestamp + 2592000;
        } else if (_freq == Frequency.Bimonthly) {
            return block.timestamp + 5184000;
        } else if (_freq == Frequency.Quarterly) {
            return block.timestamp + 7776000;
        } else if (_freq == Frequency.Biannually) {
            return block.timestamp + 182 days;
        }
        return 0;
    }

}

pragma solidity >=0.6.0 <=0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../interfaces/ILiquidityPool.sol";

interface IPositionReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission)
        external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

interface IPosiTreasury {
    function mint(address recipient, uint256 amount) external;
}

interface IPosiStakingManager {
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _referrer
    ) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function totalAllocPoint() external view returns (uint256);

    function poolInfo(uint256 pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accPositionPerShare,
            uint16 depositFeeBP,
            uint256 harvestInterval
        );

    function positionPerBlock() external view returns (uint256);
}

//library U128Math {
//    function toU256(uint128 n) internal pure returns(uint256){
//        return uint256(n);
//    }
//    function add(uint128 a, uint128 b) internal pure returns (uint128){
//        return a + b;
//    }
//    function sub(uint128 a, uint128 b) internal pure returns (uint128){
//        return a - b;
//    }
//    function mul(uint128 a, uint256 b) internal pure returns (uint256){
//        return uint256(a)*b;
//    }
//}

// Staking Position Exchange Liquididty NFT
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Position is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract LiquidityNFTStaking is
    ERC20Upgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{
    using SafeMath for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using U128Math for uint128;

    // Info of each user.
    struct UserInfo {
        uint128 amount; // How many LP tokens the user has provided.
        uint128 rewardDebt; // Reward debt. See explanation below.
        uint128 rewardLockedUp; // Reward locked up.
        uint128 nextHarvestUntil; // When can the user harvest again.
        //
        // We do some fancy math here. Basically, any point in time, the amount of Positions
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPositionPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPositionPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        bytes32 poolId;
        uint256 totalStaked;
        uint256 allocPoint; // How many allocation points assigned to this pool. Positions to distribute per block.
        uint256 lastRewardBlock; // Last block number that Positions distribution occurs.
        uint256 accPositionPerShare; // Accumulated Positions per share, times 1e12. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint128 harvestInterval; // Harvest interval in seconds
    }

    // The Position TOKEN!
    IERC20 public position;
    IPosiStakingManager public posiStakingManager;
    ILiquidityPool public positionLiquidityPool;
    IERC721 public liquidityNFT;
    // Dev address.
    address public devAddress;
    // Deposit Fee address
    address public feeAddress;
    // Bonus muliplier for early position makers.
    uint256 public BONUS_MULTIPLIER;
    // Max harvest interval: 14 days.
    uint256 public MAXIMUM_HARVEST_INTERVAL;

    // Info of each pool.
    mapping(bytes32 => PoolInfo) public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(bytes32 => mapping(address => UserInfo)) public userInfo;
    bytes32[] public pools;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    // The block number when Position mining starts.
    uint256 public startBlock;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;

    uint256 public posiStakingPid;

    // Position referral contract address.
    IPositionReferral public positionReferral;
    // Referral commission rate in basis points.
    uint16 public referralCommissionRate;
    // Max referral commission rate: 10%.
    uint16 public MAXIMUM_REFERRAL_COMMISSION_RATE;

    uint16 harvestFeeShareRate;
    uint16 public MAXIMUM_HARVEST_FEE_SHARE;

    // user => poolId => nftId[]
    mapping(address => mapping(bytes32 => uint256[])) public userNft;
    // nftid => poolId => its index in userNft
    mapping(uint256 => mapping(bytes32 => uint256)) public nftOwnedIndex;

    event Deposit(address indexed user, bytes32 indexed pid, uint256 amount);
    event Withdraw(address indexed user, bytes32 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        bytes32 indexed pid,
        uint256 amount
    );
    event EmissionRateUpdated(
        address indexed caller,
        uint256 previousAmount,
        uint256 newAmount
    );
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );
    event RewardLockedUp(
        address indexed user,
        bytes32 indexed pid,
        uint256 amountLockedUp
    );
    event NFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    );

    function initialize(
        IERC20 _position,
        IPosiStakingManager _posiStakingManager,
        ILiquidityPool _positionLiquidityPool,
        IERC721 _liquidityNFT,
        uint256 _startBlock
    ) external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __ERC20_init("Position Staking Liquidity Token", "SL");

        position = _position;
        startBlock = _startBlock;

        posiStakingManager = _posiStakingManager;
        positionLiquidityPool = _positionLiquidityPool;
        liquidityNFT = _liquidityNFT;

        devAddress = _msgSender();
        feeAddress = _msgSender();

        referralCommissionRate = 100;
        MAXIMUM_REFERRAL_COMMISSION_RATE = 1000;

        harvestFeeShareRate = 1;
        MAXIMUM_HARVEST_FEE_SHARE = 10000;

        BONUS_MULTIPLIER = 1;

        MAXIMUM_HARVEST_INTERVAL = 14 days;

        totalAllocPoint = 0;

        _mint(address(this), 10 * 10**18);
    }

    function poolLength() external view returns (uint256) {
        return pools.length;
    }

    // get position per block form the staking manager share to the contract
    function getPositionPerBlock() public view returns (uint256) {
        (, uint256 allocPoint, , , , ) = posiStakingManager.poolInfo(
            posiStakingPid
        );
        uint256 totalAllocPoint = posiStakingManager.totalAllocPoint();
        uint256 posiPerBlock = posiStakingManager.positionPerBlock();
        return (posiPerBlock * allocPoint) / totalAllocPoint;
    }

    function getPlayerIds(address owner, bytes32 pid)
        public
        view
        returns (uint256[] memory)
    {
        return userNft[owner][pid];
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {
        emit NFTReceived(operator, from, tokenId, data);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY_OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------
    function updatePositionLiquidityPool(address _newLiquidityPool)
        public
        onlyOwner
    {
        positionLiquidityPool = ILiquidityPool(_newLiquidityPool);
    }

    function updateStakingManager(address _newStakingManager) public onlyOwner {
        posiStakingManager = IPosiStakingManager(_newStakingManager);
    }

    function updateLiquidityNFT(address _newLiquidityNFT) public onlyOwner {
        liquidityNFT = IERC721(_newLiquidityNFT);
    }

    function approvePositionStakingManager() public onlyOwner {
        IERC20(address(this)).approve(
            address(posiStakingManager),
            type(uint256).max
        );
    }

    function stakePositionStakingManager() public onlyOwner {
        posiStakingManager.deposit(
            posiStakingPid,
            balanceOf(address(this)),
            address(0)
        );
    }

    function unStakePositionStakingManager(uint256 amount) public onlyOwner {
        posiStakingManager.withdraw(posiStakingPid, amount);
    }

    function harvestPositionStakingManagerOwner() public onlyOwner {
        posiStakingManager.deposit(posiStakingPid, 0, address(0));
    }

    function updateHarvestFeeShareRate(uint16 newRate) public onlyOwner {
        // max share 10%
        require(newRate <= 1000, "!F");
        harvestFeeShareRate = newRate;
    }

    function setPosiStakingPid(uint256 _posiStakingPid) public onlyOwner {
        posiStakingPid = _posiStakingPid;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        bytes32 _poolId,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        uint128 _harvestInterval,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "add: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "add: invalid harvest interval"
        );
        require(poolInfo[_poolId].lastRewardBlock == 0, "pool created");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        pools.push(_poolId);
        poolInfo[_poolId] = PoolInfo({
            poolId: _poolId,
            totalStaked: 0,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accPositionPerShare: 0,
            depositFeeBP: _depositFeeBP,
            harvestInterval: _harvestInterval
        });
    }

    // Update the given pool's Position allocation point and deposit fee. Can only be called by the owner.
    function set(
        bytes32 _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        uint128 _harvestInterval,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "set: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "set: invalid harvest interval"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending Positions on frontend.
    function pendingPosition(bytes32 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accPositionPerShare = pool.accPositionPerShare;
        uint256 lpSupply = pool.totalStaked;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 positionReward = multiplier
                .mul(getPositionPerBlock())
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accPositionPerShare = accPositionPerShare.add(
                positionReward.mul(1e12).div(lpSupply)
            );
        }
        uint256 pending = user.amount.mul(accPositionPerShare).div(1e12).sub(
            user.rewardDebt
        );
        return pending.add(user.rewardLockedUp);
    }

    // View function to see if user can harvest Positions.
    function canHarvest(bytes32 _pid, address _user)
        public
        view
        returns (bool)
    {
        UserInfo memory user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = pools.length;
        for (uint256 i = 0; i < length; ++i) {
            updatePool(pools[i]);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(bytes32 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        // SLOAD
        PoolInfo memory _pool = pool;
        if (block.number <= _pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = _pool.totalStaked;
        if (lpSupply == 0 || _pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(_pool.lastRewardBlock, block.number);
        uint256 positionReward = multiplier
            .mul(getPositionPerBlock())
            .mul(_pool.allocPoint)
            .div(totalAllocPoint);

        // TODO consider harvest reward here
        pool.accPositionPerShare = pool.accPositionPerShare.add(
            positionReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function harvestPositionStakingManager() public {
        uint256 _balanceBefore = position.balanceOf(address(this));
        posiStakingManager.deposit(posiStakingPid, 0, address(0));
        uint256 _balanceAfter = position.balanceOf(address(this));

        if (_balanceAfter > _balanceBefore) {
            uint256 shareRewardAmount = ((_balanceAfter - _balanceBefore) *
                harvestFeeShareRate) / MAXIMUM_HARVEST_FEE_SHARE;
            position.transfer(_msgSender(), shareRewardAmount);
        }
    }

    // Deposit LP tokens to PosiStakingManager for Position allocation.
    function stake(uint256 _nftId) public nonReentrant {
        _stake(_nftId, address(0));
    }

    function stakeWithReferral(uint256 _nftId, address _referrer)
        public
        nonReentrant
    {
        _stake(_nftId, _referrer);
    }

    function _stake(uint256 _nftId, address _referrer) internal {
        LiquidityInfo.Data memory nftData = positionLiquidityPool
            .getDataNonfungibleToken(_nftId);
        require(nftData.poolId != bytes32(0), "invalid liquidity pool");
        uint256[] storage nftIds = userNft[msg.sender][nftData.poolId];
        if (nftIds.length == 0) {
            nftIds.push(0);
            nftOwnedIndex[0][nftData.poolId] = 0;
        }
        nftIds.push(_nftId);
        nftOwnedIndex[_nftId][nftData.poolId] = nftIds.length - 1;

        PoolInfo storage pool = poolInfo[nftData.poolId];
        UserInfo storage user = userInfo[nftData.poolId][msg.sender];
        updatePool(nftData.poolId);
        if (
            nftData.amountOfFC > 0 &&
            address(positionReferral) != address(0) &&
            _referrer != address(0) &&
            _referrer != msg.sender
        ) {
            positionReferral.recordReferral(msg.sender, _referrer);
        }
        payOrLockupPendingPosition(nftData.poolId);
        _transferNFTIn(_nftId);
        user.amount = user.amount.add(nftData.amountOfFC);
        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
        pool.totalStaked += nftData.amountOfFC;
        emit Deposit(msg.sender, nftData.poolId, _nftId);
    }

    // Withdraw LP tokens from PosiStakingManager.
    function unstake(uint256 _nftId) public nonReentrant {
        _unstake(_nftId);
    }

    function _unstake(uint256 _nftId) internal {
        LiquidityInfo.Data memory nftData = positionLiquidityPool
            .getDataNonfungibleToken(_nftId);
        //        if(_wPid != 0x0 && _pid != _wPid) return;
        PoolInfo storage pool = poolInfo[nftData.poolId];
        UserInfo storage user = userInfo[nftData.poolId][msg.sender];

        removeNftFromUser(_nftId, nftData.poolId);

        require(user.amount >= nftData.amountOfFC, "withdraw: not good");

        updatePool(nftData.poolId);

        payOrLockupPendingPosition(nftData.poolId);

        user.amount = user.amount.sub(nftData.amountOfFC);
        _transferNFTOut(_nftId);

        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
        pool.totalStaked -= nftData.amountOfFC;

        emit Withdraw(msg.sender, nftData.poolId, _nftId);
    }

    function withdraw(bytes32 pid) public nonReentrant {
        _withdraw(pid);
    }

    function _withdraw(bytes32 pid) internal {
        uint256[] memory nfts = userNft[msg.sender][pid];
        for (uint8 index = 1; index < nfts.length; index++) {
            if (nfts[index] > 0) {
                _unstake(nfts[index]);
            }
        }
    }

    function harvest(bytes32 pid) public nonReentrant {
        _harvest(pid);
    }

    function _harvest(bytes32 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.amount > 0, "No nft staked");
        updatePool(pid);
        payOrLockupPendingPosition(pid);
        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
    }

    function exit(bytes32 pid) external nonReentrant {
        _withdraw(pid);
        //        _harvest(pid);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(bytes32 _pid) public nonReentrant {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        uint256[] memory nfts = userNft[msg.sender][_pid];
        for (uint8 index = 1; index < nfts.length; index++) {
            uint256 _nftId = nftOwnedIndex[index][_pid];
            if (_nftId > 0) {
                _transferNFTOut(_nftId);
                emit EmergencyWithdraw(msg.sender, _pid, _nftId);
            }
        }
    }

    // Pay or lockup pending Positions.
    function payOrLockupPendingPosition(bytes32 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil =
                uint128(block.timestamp) +
                pool.harvestInterval;
        }

        uint256 pending = user
            .amount
            .mul(pool.accPositionPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(
                    user.rewardLockedUp
                );
                user.rewardLockedUp = 0;
                user.nextHarvestUntil =
                    uint128(block.timestamp) +
                    pool.harvestInterval;

                // send rewards
                safePositionTransfer(msg.sender, totalRewards);
                payReferralCommission(msg.sender, totalRewards);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = uint128(
                user.rewardLockedUp.add(uint128(pending))
            );
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }

    function removeNftFromUser(uint256 _nftId, bytes32 _pid) internal {
        uint256[] memory _nftIds = userNft[msg.sender][_pid];
        uint256 nftIndex = nftOwnedIndex[_nftId][_pid];
        require(_nftIds[nftIndex] == _nftId, "not gegoId owner");
        uint256 _nftArrLength = _nftIds.length - 1;
        uint256 tailId = _nftIds[_nftArrLength];
        userNft[msg.sender][_pid][nftIndex] = tailId;
        userNft[msg.sender][_pid][_nftArrLength] = 0;
        userNft[msg.sender][_pid].pop();
        nftOwnedIndex[tailId][_pid] = nftIndex;
        nftOwnedIndex[_nftId][_pid] = 0;
    }

    // Safe position transfer function, just in case if rounding error causes pool to not have enough Positions.
    function safePositionTransfer(address _to, uint256 _amount) internal {
        uint256 positionBal = position.balanceOf(address(this));
        if (_amount > positionBal) {
            posiStakingManager.deposit(posiStakingPid, 0, address(0));
            // ORIGIN CODE
            //  posiStakingManager.harvest(posiStakingPid);
        }
        position.transfer(_to, _amount);
    }

    // Update dev address by the previous dev.
    function setDevAddress(address _devAddress) public {
        require(msg.sender == devAddress, "setDevAddress: FORBIDDEN");
        require(_devAddress != address(0), "setDevAddress: ZERO");
        devAddress = _devAddress;
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        require(_feeAddress != address(0), "setFeeAddress: ZERO");
        feeAddress = _feeAddress;
    }

    // Update the position referral contract address by the owner
    function setPositionReferral(IPositionReferral _positionReferral)
        public
        onlyOwner
    {
        positionReferral = _positionReferral;
    }

    // Update referral commission rate by the owner
    function setReferralCommissionRate(uint16 _referralCommissionRate)
        public
        onlyOwner
    {
        require(
            _referralCommissionRate <= MAXIMUM_REFERRAL_COMMISSION_RATE,
            "setReferralCommissionRate: invalid referral commission rate basis points"
        );
        referralCommissionRate = _referralCommissionRate;
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(address _user, uint256 _pending) internal {
        if (
            address(positionReferral) != address(0) &&
            referralCommissionRate > 0
        ) {
            address referrer = positionReferral.getReferrer(_user);
            uint256 commissionAmount = _pending.mul(referralCommissionRate).div(
                10000
            );

            if (referrer != address(0) && commissionAmount > 0) {
                position.transfer(referrer, commissionAmount);
                positionReferral.recordReferralCommission(
                    referrer,
                    commissionAmount
                );
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

    function _transferNFTOut(uint256 id) internal {
        liquidityNFT.safeTransferFrom(address(this), msg.sender, id);
    }

    function _transferNFTIn(uint256 id) internal {
        liquidityNFT.safeTransferFrom(msg.sender, address(this), id);
    }

    function _msgSender()
        internal
        view
        override(ContextUpgradeable)
        returns (address)
    {
        return msg.sender;
    }

    function _msgData()
        internal
        view
        override(ContextUpgradeable)
        returns (bytes calldata)
    {
        return msg.data;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../interfaces/IPositionRouter.sol";
import "../interfaces/ISpotFactory.sol";
import "../interfaces/IWBNB.sol";
import "../interfaces/ISpotHouse.sol";
import "./libraries/types/SpotHouseStorage.sol";
import "./libraries/types/SpotFactoryStorage.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "./libraries/types/PositionRouterStorage.sol";

contract PositionRouter is
    PositionRouterStorage,
    IPositionRouter,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{


    modifier ensure(uint256 deadline) {
        require(deadline >= blockNumber(), "PositionRouter: EXPIRED");
        _;
    }

    receive() external payable {
        assert(msg.sender == WBNB); // only accept BNB via fallback from the WBNB contract
    }

    function initialize(
        ISpotFactory _factory,
        ISpotHouse _spotHouse,
        IUniswapV2Router02 _uniSwapRouterV2,
        address _WBNB
    ) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();
        factory = _factory;
        spotHouse = _spotHouse;
        uniSwapRouterV2 = _uniSwapRouterV2;
        WBNB = _WBNB;
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);
        if (pairManager == address(0)) {
            amounts = uniSwapRouterV2.getAmountsOut(amountIn, path);
            _deposit(path[0], msg.sender, amounts[0]);
            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2.swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                to,
                deadline
            );
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                amounts = spotHouse.openMarketOrderWithQuote(
                    IPairManager(pairManager),
                    side,
                    uint256(amountIn),
                    msg.sender,
                    to
                );
            } else {
                amounts = spotHouse.openMarketOrder(
                    IPairManager(pairManager),
                    side,
                    uint256(amountIn),
                    msg.sender,
                    to
                );
            }
        }
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);
        if (pairManager == address(0)) {
            amounts = uniSwapRouterV2.getAmountsIn(amountOut, path);
            _deposit(path[0], msg.sender, amounts[0]);
            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2.swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                to,
                deadline
            );
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                amounts = spotHouse.openMarketOrder(
                    IPairManager(pairManager),
                    side,
                    uint256(amountOut),
                    msg.sender,
                    to
                );
            } else {
                amounts = spotHouse.openMarketOrderWithQuote(
                    IPairManager(pairManager),
                    side,
                    uint256(amountOut),
                    msg.sender,
                    to
                );
            }
        }
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WBNB, "!BNB");
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);

        if (pairManager == address(0)) {
            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2.swapExactETHForTokens{value: msg.value}(
                amountOutMin,
                path,
                to,
                deadline
            );
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                amounts = spotHouse.openMarketOrderWithQuote{value: msg.value}(
                    IPairManager(pairManager),
                    side,
                    uint256(msg.value),
                    msg.sender,
                    to
                );
            } else {
                amounts = spotHouse.openMarketOrder{value: msg.value}(
                    IPairManager(pairManager),
                    side,
                    uint256(msg.value),
                    msg.sender,
                    to
                );
            }
        }
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == WBNB, "!BNB");
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);

        if (pairManager == address(0)) {
            amounts = uniSwapRouterV2.getAmountsIn(amountOut, path);
            _deposit(path[0], msg.sender, amounts[0]);
            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2.swapTokensForExactETH(
                amountOut,
                amountInMax,
                path,
                to,
                deadline
            );
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                amounts = spotHouse.openMarketOrder(
                    IPairManager(pairManager),
                    side,
                    amountOut,
                    msg.sender,
                    to
                );
            } else {
                amounts = spotHouse.openMarketOrderWithQuote(
                    IPairManager(pairManager),
                    side,
                    amountOut,
                    msg.sender,
                    to
                );
            }
        }
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == WBNB, "!BNB");
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);

        if (pairManager == address(0)) {
            amounts = uniSwapRouterV2.getAmountsOut(amountIn, path);
            _deposit(path[0], msg.sender, amounts[0]);

            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2.swapExactTokensForETH(
                amountIn,
                amountOutMin,
                path,
                to,
                deadline
            );
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                amounts = spotHouse.openMarketOrderWithQuote(
                    IPairManager(pairManager),
                    side,
                    amountIn,
                    msg.sender,
                    to
                );
            } else {
                amounts = spotHouse.openMarketOrder(
                    IPairManager(pairManager),
                    side,
                    amountIn,
                    msg.sender,
                    to
                );
            }
        }
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);

        if (pairManager == address(0)) {
            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2.swapExactETHForTokens{value: msg.value}(
                amountOut,
                path,
                to,
                deadline
            );
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                amounts = spotHouse.openMarketOrder{value: msg.value}(
                    IPairManager(pairManager),
                    side,
                    amountOut,
                    msg.sender,
                    to
                );
            } else {
                amounts = spotHouse.openMarketOrderWithQuote{value: msg.value}(
                    IPairManager(pairManager),
                    side,
                    uint256(msg.value),
                    msg.sender,
                    to
                );
            }
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);
        if (pairManager == address(0)) {
            uint256 balanceBefore = IERC20(path[0]).balanceOf(address(this));
            _deposit(path[0], msg.sender, amountIn);
            uint256 balanceAfter = IERC20(path[0]).balanceOf(address(this));
            //            _deposit(path[0], msg.sender, amountIn);
            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    balanceAfter - balanceBefore,
                    amountOutMin,
                    path,
                    to,
                    deadline
                );
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                spotHouse.openMarketOrderWithQuote(
                    IPairManager(pairManager),
                    side,
                    uint256(amountIn),
                    msg.sender,
                    to
                );
            } else {
                spotHouse.openMarketOrder(
                    IPairManager(pairManager),
                    side,
                    uint256(amountIn),
                    msg.sender,
                    to
                );
            }
        }
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        require(path[0] == WBNB, "!BNB");
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);

        if (pairManager == address(0)) {
            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: msg.value
            }(amountOutMin, path, to, deadline);
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                spotHouse.openMarketOrderWithQuote{value: msg.value}(
                    IPairManager(pairManager),
                    side,
                    uint256(msg.value),
                    msg.sender,
                    to
                );
            } else {
                spotHouse.openMarketOrder{value: msg.value}(
                    IPairManager(pairManager),
                    side,
                    uint256(msg.value),
                    msg.sender,
                    to
                );
            }
        }
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        require(path[path.length - 1] == WBNB, "!BNB");
        (
            SpotHouseStorage.Side side,
            address pairManager
        ) = getSideAndPairManager(path);

        if (pairManager == address(0)) {
            uint256 balanceBefore = IERC20(path[0]).balanceOf(address(this));
            _deposit(path[0], msg.sender, amountIn);
            uint256 balanceAfter = IERC20(path[0]).balanceOf(address(this));

            if (!isApprove(path[0])) {
                _approve(path[0]);
            }
            uniSwapRouterV2.swapExactTokensForETHSupportingFeeOnTransferTokens(
                balanceAfter - balanceBefore,
                amountOutMin,
                path,
                to,
                deadline
            );
        } else {
            if (side == SpotHouseStorage.Side.BUY) {
                spotHouse.openMarketOrderWithQuote(
                    IPairManager(pairManager),
                    side,
                    amountIn,
                    msg.sender,
                    to
                );
            } else {
                spotHouse.openMarketOrder(
                    IPairManager(pairManager),
                    side,
                    amountIn,
                    msg.sender,
                    to
                );
            }
        }
    }

    //------------------------------------------------------------------------------------------------------------------
    // INTERNAL FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------


    function _deposit(
        address token,
        address from,
        uint256 amount
    ) internal {
        IERC20(token).transferFrom(from, address(this), amount);
    }


    function _approve(address token) internal {
        IERC20(token).approve(address(uniSwapRouterV2), type(uint256).max);
    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function setFactory(ISpotFactory _newFactory) public onlyOwner {
        factory = _newFactory;
    }

    function setUniSwpRouter(IUniswapV2Router02 _newUniSwpRouter)
        public
        onlyOwner
    {
        uniSwapRouterV2 = _newUniSwpRouter;
    }

    function setWBNB(address _newWBNB) external onlyOwner {
        WBNB = _newWBNB;
    }

    function setSpotHouse(ISpotHouse _newSpotHouse) external onlyOwner {
        spotHouse = _newSpotHouse;
    }

    //------------------------------------------------------------------------------------------------------------------
    // VIEWS FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------
    function getSideAndPairManager(address[] calldata path)
        public
        view
        returns (SpotHouseStorage.Side side, address pairManager)
    {
        address quoteToken;
        (, quoteToken, pairManager) = isPosiDexSupportPair(
            path[0],
            path[path.length - 1]
        );

        if (quoteToken == path[0]) {
            // Buy
            // path[0] -> path[path.length - 1] and path[0] is quote
            side = SpotHouseStorage.Side.BUY;
        } else {
            side = SpotHouseStorage.Side.SELL;
        }
    }

    function getReserves(address tokenA, address tokenB) external view returns(uint reservesA, uint reservesB) {
        (reservesA, reservesB ,) = IUniswapV2Pair(
            IUniswapV2Factory(uniSwapRouterV2.factory()).getPair(tokenA, tokenB)
        ).getReserves();
    }

    function isApprove(address token) public view returns (bool) {
        return
            IERC20(token).allowance(address(this), address(uniSwapRouterV2)) > 0
                ? true
                : false;
    }

    function isPosiDexSupportPair(address tokenA, address tokenB)
        public
        view
        override
        returns (
            address baseToken,
            address quoteToken,
            address pairManager
        )
    {
        (baseToken, quoteToken, pairManager) = factory.getPairManagerSupported(
            tokenA,
            tokenB
        );
    }

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        (
            SpotHouseStorage.Side side,
            address pairManagerAddress
        ) = getSideAndPairManager(path);

        uint256 sizeOut;
        uint256 openOtherSide;

        if (pairManagerAddress != address(0)) {
            IPairManager pairManager = IPairManager(pairManagerAddress);
            amounts = new uint256[](2);
            if (side == SpotHouseStorage.Side.BUY) {
                // quote
                (sizeOut, openOtherSide) = pairManager.getAmountEstimate(
                    amountIn,
                    true,
                    false
                );
                amounts[0] = sizeOut;
                amounts[1] = openOtherSide;
            } else {
                (sizeOut, openOtherSide) = pairManager.getAmountEstimate(
                    amountIn,
                    false,
                    true
                );
                amounts[0] = sizeOut;
                amounts[1] = openOtherSide;
            }
        } else {
            amounts = uniSwapRouterV2.getAmountsOut(amountIn, path);
        }
    }

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        (
            SpotHouseStorage.Side side,
            address pairManagerAddress
        ) = getSideAndPairManager(path);
        uint256 sizeOut;
        uint256 openOtherSide;

        if (pairManagerAddress != address(0)) {
            IPairManager pairManager = IPairManager(pairManagerAddress);
            amounts = new uint256[](2);

            if (side == SpotHouseStorage.Side.BUY) {
                // quote
                (sizeOut, openOtherSide) = pairManager.getAmountEstimate(
                    amountOut,
                    true,
                    true
                );

                amounts[0] = openOtherSide;
                amounts[1] = sizeOut;
            } else {
                (sizeOut, openOtherSide) = pairManager.getAmountEstimate(
                    amountOut,
                    false,
                    false
                );
                amounts[0] = openOtherSide;
                amounts[1] = sizeOut;
            }
        } else {
            amounts = uniSwapRouterV2.getAmountsIn(amountOut, path);
        }
    }

    function blockNumber() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}

pragma solidity ^0.8.0;

interface IPositionRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function isPosiDexSupportPair(address tokenA, address tokenB)
        external
        view
        returns (
            address baseToken,
            address quoteToken,
            address pairManager
        );

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
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

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

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

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../../../interfaces/IUniswapV2Router.sol";
import "../../../interfaces/ISpotHouse.sol";

contract PositionRouterStorage {

    ISpotFactory public factory;

    ISpotHouse public spotHouse;

    address public WBNB;

    IUniswapV2Router02 public uniSwapRouterV2;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

/**
 * @author Musket
 */
pragma solidity ^0.8.0;

import "../spot-exchange/PositionRouter.sol";

contract MockPositionRouter is PositionRouter {
    function blockNumber() internal view override returns (uint256) {
        return 1;
    }
}

pragma solidity ^0.8.0;

import "../exchange/TickPosition.sol";
import "../exchange/LiquidityBitmap.sol";
import "../../../interfaces/IPairManager.sol";

library PosiRouterLibrary {
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);

    struct SingleSlot {
        uint128 pip;
        //0: not set
        //1: buy
        //2: sell
        uint8 isFullBuy;
    }

    struct SwapState {
        uint256 remainingSize;
        // the tick associated with the current price
        uint128 pip;
        uint32 basisPoint;
        uint32 baseBasisPoint;
        uint128 startPip;
        uint128 remainingLiquidity;
        uint8 isFullBuy;
        bool isSkipFirstPip;
        uint128 lastMatchedPip;
    }

    enum CurrentLiquiditySide {
        NotSet,
        Buy,
        Sell
    }
    struct StepComputations {
        uint128 pipNext;
    }
}

/**
 * @author Musket
 */
pragma solidity ^0.8.0;

import "./PoolLiquidity.sol";
import "../../../interfaces/IPairManager.sol";
import "./PoolLiquidity.sol";
import "../helper/TradeConvert.sol";
import "../../PositionLiquidityPool.sol";

library PositionLiquidityPoolFunction {
    using PackedOrderId for bytes32;
    using TradeConvert for uint256;
    using Convert for uint256;
    using Convert for int128;

    // NO USE, SO BORING
    function claimFilledOrder(
        bytes32 poolId,
        IPairManager _pairManager,
        PoolLiquidity.PoolLiquidityInfo memory data
    ) internal returns (PoolLiquidity.PoolLiquidityInfo memory) {
        uint256 quoteAmount;
        uint256 baseAmount;
        uint256 _basisPoint = _pairManager.getBaseBasisPoint();

        // uint256 _basisPoint = _pairManager.getBasisPoint();
        bytes32[256] memory _supplyOrders = data.supplyOrders;
        for (uint256 i = 0; i < _supplyOrders.length; i++) {
            if (_supplyOrders[i] == 0x0) {
                continue;
            }
            (uint128 _pip, uint64 _orderId, bool isBuy) = _supplyOrders[i]
                .unpack();
            (
                bool isFilled,
                ,
                uint256 baseSize,
                uint256 partialFilled
            ) = _pairManager.getPendingOrderDetail(_pip, _orderId);

            uint256 filledSize;
            if (isFilled) {
                // TODO claim with fee when filled
                // collect
                filledSize = baseSize;
                if (
                    isBuy &&
                    !BitMathLiquidity.isSoRemoveable(data.soRemovablePosBuy, i)
                ) {
                    // buy -> claim base
                    baseAmount += filledSize;
                    data.soRemovablePosBuy = PoolLiquidity.markSoRemovablePos(
                        data.soRemovablePosBuy,
                        uint8(i)
                    );
                } else if (
                    i > 127 &&
                    !BitMathLiquidity.isSoRemoveable(data.soRemovablePosSell, i)
                ) {
                    // sell -> claim quote
                    quoteAmount += filledSize.baseToQuote(_pip, _basisPoint);
                    data.soRemovablePosSell = PoolLiquidity.markSoRemovablePos(
                        data.soRemovablePosSell,
                        uint8(i - 128)
                    );
                }
            } else if (partialFilled > 0) {
                if (isBuy) {
                    baseAmount += partialFilled;
                } else {
                    quoteAmount += partialFilled.baseToQuote(_pip, _basisPoint);
                }
                _pairManager.updatePartialFilledOrder(_pip, _orderId);
            }
        }

        _pairManager.collectFund(
            _pairManager.getBaseAsset(),
            address(this),
            baseAmount
        );

        _pairManager.collectFund(
            _pairManager.getQuoteAsset(),
            address(this),
            quoteAmount
        );

        return data;
    }

    struct PoolClaimableState {
        uint8 countBitHasSupply;
        uint128 posTemp;
        bool isFilled;
        uint256 basisPoint;
        uint16 feeShareRatio;
        uint128 feeBasis;
    }
    //    function getPoolClaimable(
    //        bytes32 poolKey,
    //        PoolLiquidity.PoolLiquidityInfo memory pool,
    //        uint128 feeBasis,
    //        uint16  feeShareRatio
    //    )
    //        public
    //        view
    //        returns (
    //            uint256 quote,
    //            uint256 base,
    //            uint256 feeQuoteAmount,
    //            uint256 feeBaseAmount
    //        )
    //    {
    //        bytes32[256] memory _orderIds = pool.supplyOrders;
    //        IPairManager.ExchangedData memory exData;
    //        int256 packSo = BitMathLiquidity.packInt128AndIn128(
    //            pool.soRemovablePosBuy,
    //                pool.soRemovablePosSell
    //        );
    //
    //        PoolClaimableState memory state = PoolClaimableState({
    //            countBitHasSupply: uint8(
    //                255 - PoolLiquidity.countBitSet(uint256(packSo))
    //            ),
    //            posTemp: 0,
    //            isFilled: false,
    //            basisPoint: IPairManager(pool.pairManager).getBasisPoint(),
    //            feeShareRatio : feeShareRatio,
    //            feeBasis : feeBasis
    //        });
    //
    //        {
    //            while (state.countBitHasSupply != 0) {
    //                state.posTemp = PoolLiquidity
    //                    .rightMostUnSetBitPosInt256(packSo)
    //                    .Uint256ToUint128();
    //                packSo = PoolLiquidity.markSoRemovablePosInt256(packSo, state.posTemp);
    //                state.countBitHasSupply--;
    //                if (state.posTemp == 127 || state.posTemp == 255) {
    //                    continue;
    //                }
    //                (uint128 _pip, uint64 _orderIdx, bool isBuy) = _orderIds[
    //                    state.posTemp
    //                ].unpack();
    //                (exData, state.isFilled) = IPairManager(pool.pairManager)
    //                    .accumulatePoolLiquidityClaimableAmount(
    //                        _pip,
    //                        _orderIdx,
    //                        exData,
    //                        state.basisPoint,
    //                            state.feeShareRatio,
    //                            state.feeBasis
    //                    );
    //                if (state.isFilled) {
    //                    if (state.posTemp < 127) {
    //                        pool.soRemovablePosBuy = PoolLiquidity.markSoRemovablePos(
    //                            pool.soRemovablePosBuy,
    //                            uint8(state.posTemp)
    //                        );
    //                    } else  {
    //                        pool.soRemovablePosSell = PoolLiquidity.markSoRemovablePos(
    //                            pool.soRemovablePosSell,
    //                            uint8(
    //                                BitMathLiquidity.getIndexOrderOfSell(
    //                                    uint256(state.posTemp)
    //                                )
    //                            )
    //                        );
    //                    }
    //                }
    //            }
    //        }
    //        return (
    //            exData.quoteAmount + exData.feeQuoteAmount,
    //            exData.baseAmount + exData.feeBaseAmount,
    //            exData.feeQuoteAmount,
    //            exData.feeBaseAmount
    //        );
    //    }
}

pragma solidity ^0.8.0;

import "../spot-exchange/libraries/liquidity/Grid.sol";

contract TestGrid {
    function generateGrid(
        uint256 currentPip,
        uint80 lowerLimit,
        uint80 upperLimit,
        uint16 gridCount,
        uint128 baseAmount,
        uint128 quoteAmount
    ) public pure returns (Grid.GridOrderData[] memory) {
        return
            Grid.generateGrid(
                currentPip,
                lowerLimit,
                upperLimit,
                gridCount,
                baseAmount,
                quoteAmount
            );
    }

    function generateGridPrice(
        uint256 currentPip,
        uint80 lowerLimit,
        uint80 upperLimit,
        uint16 gridCount
    )
        public
        pure
        returns (
            uint256[] memory,
            uint256 bidCount,
            uint256 askCount
        )
    {
        return
            Grid.generateGridArithmeticPrice(
                currentPip,
                lowerLimit,
                upperLimit,
                gridCount
            );
    }
}

pragma solidity ^0.8.0;

import "../spot-exchange/libraries/helper/Timers.sol";

contract TestTimer {
    using Timers for uint64;

    uint256 public now;
    uint64 expireTime;

    function mockNow(uint256 mock) public {
        now = mock;
    }

    function updateExpireTime(uint64 _expireTime) public {
        expireTime = _expireTime;
    }

    function isExpired() public view returns (bool) {
        // If not set expireTime for this pair
        // expireTime is 0 and unlimited time to expire
        if (expireTime == 0) {
            return false;
        }
        return expireTime.passed(_now());
    }

    function _now() public view returns (uint256) {
        return now;
    }
}

pragma solidity ^0.8.0;

import "../spot-exchange/libraries/exchange/TickPosition.sol";

contract TickPositionTest {
    mapping(uint128 => TickPosition.Data) public tickPosition;
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract MockReflexToken is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, 10000 * 10**18);
    }

    function mint(address recipient, uint256 amount) public {
        _mint(recipient, amount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        uint256 realAmount = (99 * amount) / 100;

        _balances[to] += realAmount;

        emit Transfer(from, to, realAmount);

        _afterTokenTransfer(from, to, realAmount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "!O");
        _;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000000 * 10**18);
        owner = msg.sender;
    }

    function mint(address recipient, uint256 amount) public onlyOwner {
        _mint(recipient, amount);
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }
}
//pragma solidity ^0.8.0;
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//
//contract MockToken is ERC20 {
//
//    address public owner;
//    modifier onlyOwner() {
//        require( msg.sender == owner, "!O");
//        _;
//    }
//    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
//        _mint(msg.sender, 10000 * 10**18);
//        owner = msg.sender;
//    }
//
//    function mint(address recipient, uint256 amount) public  onlyOwner {
//        _mint(recipient, amount);
//    }
//
//    function setOwner(address _owner)  public onlyOwner{
//        owner =_owner;
//    }
//}

pragma solidity ^0.8.0;

import "../spot-exchange/libraries/helper/SpotHouseHelper.sol";

contract TestSpotHouseHelper {
    struct TestParams {
        uint128 pip;
        uint64 orderId;
        bool isBuy;
    }

    function accumulatePoolExchangedData(
        address _pairAddress,
        uint256 basisPoint,
        TestParams[] memory params
    ) public view returns (int256 quote, int256 base) {
        SpotHouseHelper.AccPoolExchangedDataParams memory _d;
        for (uint256 i = 0; i < params.length; i++) {
            _d.orderId = PackedOrderId.pack(
                params[i].pip,
                params[i].orderId,
                params[i].isBuy
            );
            SpotHouseHelper.accumulatePoolExchangedData(
                _pairAddress,
                basisPoint,
                _d
            );
        }
        return (_d.quoteAdjust, _d.baseAdjust);
    }
}

pragma solidity ^0.8.0;

import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Pair.sol";

contract Migrator {
    IUniswapV2Router02 public router;
    IUniswapV2Factory public factory;

    function migrate(IUniswapV2Pair pair) external {
        //        address user = msg.sender;
        //        address migrator = address(this);
        //
        //        uint256 balanceLPOfUser = pair.balanceOf(user);
        //        require(balanceLPOfUser > 0, "!0");
        //        pair.transferFrom(user, migrator, balanceLPOfUser);
        //
        //        (uint256 amount1, uint256 amount2) = pair.router.removeLiquidity(
        //            pair.token0(),
        //            pair.token1(),
        //            balanceLPOfUser,
        //            1,
        //            1,
        //            migrator,
        //            uint(-1)
        //        );
    }
}

/**
 * @author Musket
 */
pragma solidity ^0.8.0;

import "../spot-exchange/PositionLiquidityPool.sol";

contract MockPositionLiquidityPool02 is PositionLiquidityPool {
    //    PoolLiquidity.PoolLiquidityInfo public data;
    using PoolLiquidity for PoolLiquidity.PoolLiquidityInfo;
    using PoolLiquidity for bytes32[256];
    using PoolLiquidity for int256;
    using PoolLiquidity for int128;
    using PackedOrderId for uint128;

    bytes32 hashID =
        0x0000000000000000000000000000000000000000000000000000000000000000;

    constructor() {
        bytes32[256] memory _supplyOrders;

        poolInfo[hashID] = PoolLiquidity.PoolLiquidityInfo({
            pairManager: 0x0000000000000000000000000000000000000000,
            strategy: 0x0000000000000000000000000000000000000000,
            baseLiquidity: 0,
            quoteLiquidity: 0,
            supplyOrders: _supplyOrders,
            totalQuoteDeposited: 0,
            totalFundingCertificates: 0,
            soRemovablePosBuy: type(int128).max,
            soRemovablePosSell: type(int128).max
        });
    }

    function setPairManager(address _pairManager) public {
        poolInfo[hashID].pairManager = _pairManager;
    }

    function pushSupplyBuy(bytes32 value) public {
        PoolLiquidity.PoolLiquidityInfo storage data = poolInfo[hashID];
        ILiquidityPool.ReBalanceState memory reBalanceState = ILiquidityPool
            .ReBalanceState({
                soRemovablePosBuy: data.soRemovablePosBuy,
                soRemovablePosSell: data.soRemovablePosSell,
                claimableQuote: 0,
                claimableBase: 0,
                feeQuoteAmount: 0,
                feeBaseAmount: 0,
                pairManager: IPairManager(data.pairManager),
                poolId: hashID
            });
        data.supplyOrders.pushSupply(reBalanceState, value);
        data.soRemovablePosBuy = reBalanceState.soRemovablePosBuy;
    }

    function pushSupplySell(bytes32 value) public {
        PoolLiquidity.PoolLiquidityInfo storage data = poolInfo[hashID];

        ILiquidityPool.ReBalanceState memory reBalanceState = ILiquidityPool
            .ReBalanceState({
                soRemovablePosBuy: data.soRemovablePosBuy,
                soRemovablePosSell: data.soRemovablePosSell,
                claimableQuote: 0,
                claimableBase: 0,
                feeQuoteAmount: 0,
                feeBaseAmount: 0,
                pairManager: IPairManager(data.pairManager),
                poolId: hashID
            });
        data.supplyOrders.pushSupply(reBalanceState, value);
        data.soRemovablePosSell = reBalanceState.soRemovablePosSell;
    }

    function pack(
        uint128 pip,
        uint64 orderIdx,
        bool isBuy
    ) public view returns (bytes32) {
        return pip.pack(orderIdx, isBuy);
    }

    function claim() public {
        //
        //        PoolLiquidity.PoolLiquidityInfo memory data = poolInfo[hashID];
        //        PositionLiquidityPoolFunction.getPoolClaimable(
        //            hashID,
        //            data,
        //        feeBasis,
        //                feeShareRatio
        //
        //        );
        //
        //        console.log("soRemovablePosBuy mock: ", uint128(data.soRemovablePosBuy));
        //
        //        poolInfo[hashID].soRemovablePosBuy = data.soRemovablePosBuy;
        //        poolInfo[hashID].soRemovablePosSell = data.soRemovablePosSell;
    }
}