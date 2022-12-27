/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);
}

contract BestDexRate {
    struct Data {
        string name;
        IRouter router;
        IFactory factory;
    }

    function getMaxAmount(
        Data[] calldata _param,
        uint256 _amountIn,
        address[] calldata inOutToken
    )
        external
        view
        returns (
            uint256 maxAmount,
            address maxRouter,
            string memory name
        )
    {
        for (uint8 i = 0; i < _param.length; ) {
            // step1 : get pair
            address pair = _param[i].factory.getPair(
                inOutToken[0],
                inOutToken[1]
            );
            if (pair != address(0)) {
                // step2 : get reserve
                (uint112 reserve0, uint112 reserve1, ) = IPair(pair)
                    .getReserves();

                //step3 : get token0 for reserve compare
                address token0 = IPair(pair).token0();

                //step4 : reserve compare
                uint256 reserve;
                if (token0 == inOutToken[0]) {
                    reserve = uint256(reserve0);
                } else {
                    reserve = uint256(reserve1);
                }

                // if we have amountIn > reserves then do:
                if (reserve > _amountIn) {
                    uint256 amountOut = (
                        _param[i].router.getAmountsOut(_amountIn, inOutToken)
                    )[1];
                    if (amountOut > maxAmount) {
                        maxAmount = amountOut;
                        maxRouter = address(_param[i].router);
                        name = _param[i].name;
                    }
                }
            }
            unchecked {
                i++;
            }
        }

        return (maxAmount, maxRouter, name);
    }
}