// File: contracts/protocols/bep/Utils.sol

pragma solidity >=0.6.8;
import "./IFiles.sol";

library Utils {
    using SafeMath for uint256;

    function random(
        uint256 from,
        uint256 to,
        uint256 salty
    ) private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number +
                        salty
                )
            )
        );
        return seed.mod(to - from) + from;
    }

    function calculateBNBReward(
        // uint256 _tTotal,
        uint256 currentBalance,
        uint256 currentBNBPool,
        uint256 totalSupply,
        // address ofAddress,
        uint256 rewardHardcap
    ) public pure returns (uint256) {
        uint256 bnbPool = currentBNBPool > rewardHardcap ? rewardHardcap : currentBNBPool;
        return bnbPool.mul(currentBalance).div(totalSupply);
    }

    function calculateTopUpClaim(
        uint256 currentRecipientBalance,
        uint256 basedRewardCycleBlock,
        uint256 threshHoldTopUpRate,
        uint256 amount
    ) public pure returns (uint256) {
        uint256 rate = amount.mul(100).div(currentRecipientBalance);

        if (rate >= threshHoldTopUpRate) {
            uint256 incurCycleBlock = basedRewardCycleBlock
                .mul(rate)
                .div(100);

            if (incurCycleBlock >= basedRewardCycleBlock) {
                incurCycleBlock = basedRewardCycleBlock;
            }

            return incurCycleBlock;
        }

        return 0;
    }

    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        public
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function swapETHForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function swapTokensForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            ethAmount, // wbnb input
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function getAmountsout(uint256 amount, address routerAddress)
        public
        view
        returns (uint256 _amount)
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // fetch current rate
        uint256[] memory amounts = pancakeRouter.getAmountsOut(amount, path);
        return amounts[1];
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 360
        );
    }

    function getAntiFlipTaxNo(uint256 firstBuy) public view returns(uint8 taxNo) {
        if (block.timestamp - firstBuy < 1 days) {
            return 0;
        } 
        else if (block.timestamp - firstBuy < 7 days) {
            return 1;
        } 
        else if (block.timestamp - firstBuy < 30 days) {
            return 2;
        } 
        else if (block.timestamp - firstBuy < 60 days) {
           return 3;
        } 
        else if (block.timestamp - firstBuy < 90 days) {
           return 4;
        } 
        else 
            return 5;
    }

    // Computes `k * (1+1/q) ^ N`, with precision `p`. The higher
    // the precision, the higher the gas cost. It should be
    // something around the log of `n`. When `p == n`, the
    // precision is absolute (sans possible integer overflows). <edit: NOT true, see comments>
    // Much smaller values are sufficient to get a great approximation.
    function calcReward(uint256 k, uint256 q, uint256 n, uint256 p) public pure returns (uint256) {
        uint256 s = k;
        uint256 N = n;
        uint256 B = 1;
        bool plus = false;
        p = n < p ? n : p;

        for (uint256 i = 1; i <= p; ++i){
            if(plus) {
                s += k * N / B / (q**i);
                plus = false;
            }
            else
            {
                s -= k * N / B / (q**i);
                plus = true;
            }
            N = N * (n-i);
            B = B * (i+1);
        }
        return s;
    }

}

library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(
            IPancakeFactory(factory).getPair(tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountETH) {
        require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountETH = amountA.mul(reserveB) / reserveA;
    }

    /*
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
            ))));
    }
    */
}