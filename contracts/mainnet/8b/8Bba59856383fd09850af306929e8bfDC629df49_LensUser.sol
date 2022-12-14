// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IERC20 {
    function balanceOf(address _who) external view returns (uint256);
    function decimals() external view returns (uint8);
}

interface IUniswapV2Router01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IBooster {
    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        bool shutdown;
    }
    function poolInfo(uint256 _index) external view returns (PoolInfo memory);
    function crvLockRewards() external view returns (address);
}

interface IWomLpToken {
    function pool() external view returns (address);
    function underlyingToken() external view returns (address);
}

interface IWomPool {
    function quotePotentialWithdraw(address _token, uint256 _liquidity) external view returns (uint256);
}

contract LensUser {
    address internal constant WOM_STABLE_MAIN_POOL = 0x312Bc7eAAF93f1C60Dc5AfC115FcCDE161055fb0;
    address internal constant WOM_STABLE_SIDE_POOL = 0x0520451B19AD0bb00eD35ef391086A692CFC74B2;
    address internal constant WOM_BNB_POOL = 0x0029b7e8e9eD8001c868AA09c74A1ac6269D4183;
    address internal constant WOM_WMX_POOL = 0xeEB5a751E0F5231Fc21c7415c4A4c6764f67ce2e;

    address internal constant WOM_TOKEN = 0xAD6742A35fB341A9Cc6ad674738Dd8da98b94Fb1;
    address internal constant BUSD_TOKEN = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal constant WBNB_TOKEN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address internal constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getUserBalancesDefault(
        IBooster _booster,
        address _user
    ) public view returns(
        uint256[] memory lpTokenBalances,
        uint256[] memory underlyingBalances,
        uint256[] memory usdOuts,
        uint256 womWmxBalance,
        uint256 womWmxUsdOut
    ) {
        (lpTokenBalances, underlyingBalances, usdOuts) = getUserBalances(_booster, _user, defaultPools());
        (womWmxBalance, womWmxUsdOut) = getUserWmxWom(IBooster(_booster).crvLockRewards(), _user);
    }

    function defaultPools() public pure returns (uint256[] memory) {
        uint256[] memory poolIds = new uint256[](12);
        for (uint256 i = 0; i < 12; i++) {
            poolIds[i] = i;
        }
        return poolIds;
    }

    function getUserWmxWom(
        address _crvLockRewards,
        address _user
    ) public view returns(
        uint256 womWmxBalance,
        uint256 usdOut
    ) {
        womWmxBalance = IERC20(_crvLockRewards).balanceOf(_user);
        if (womWmxBalance > 0) {
            address[] memory path = new address[](2);
            path[0] = WOM_TOKEN;
            path[1] = BUSD_TOKEN;
            uint256[] memory amountsOut = IUniswapV2Router01(PANCAKE_ROUTER).getAmountsOut(womWmxBalance, path);
            usdOut = amountsOut[1];
        }
    }

    function getUserBalances(
        IBooster _booster,
        address _user,
        uint256[] memory _poolIds
    ) public view returns(
        uint256[] memory lpTokenBalances,
        uint256[] memory underlyingBalances,
        uint256[] memory usdOuts
    ) {
        uint256 len = _poolIds.length;
        lpTokenBalances = new uint256[](len);
        underlyingBalances = new uint256[](len);
        usdOuts = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            // 1. LP token balance
            IBooster.PoolInfo memory poolInfo = _booster.poolInfo(_poolIds[i]);
            uint256 lpTokenBalance = IERC20(poolInfo.crvRewards).balanceOf(_user);
            lpTokenBalances[i] = lpTokenBalance;
            if (lpTokenBalance == 0) {
                continue;
            }

            // 2. Underlying balance
            address pool = IWomLpToken(poolInfo.lptoken).pool();
            address underlyingToken = IWomLpToken(poolInfo.lptoken).underlyingToken();
            try IWomPool(pool).quotePotentialWithdraw(underlyingToken, lpTokenBalance) returns (uint256 underlyingBalance) {
                underlyingBalances[i] = underlyingBalance;

                // 3. Usd outs
                usdOuts[i] = getUsdOut(pool, lpTokenBalance, underlyingBalance);
            } catch {}
        }
    }

    function getUsdOut(
        address _pool,
        uint256 _lpTokenAmountIn,
        uint256 _underlyingTokenOutEstimation
    ) public view returns (uint256) {
        // 1. Assume all the tokens in (BUSD-USDC-USDT-DAI) and (BUSD-HAY) are equal to $1.
        if (_pool == WOM_STABLE_MAIN_POOL || _pool == WOM_STABLE_SIDE_POOL) {
            return _underlyingTokenOutEstimation;
        } else if (_pool == WOM_WMX_POOL) {
            // 2.1. Estimate amount out in WOM.
            try IWomPool(_pool).quotePotentialWithdraw(WOM_TOKEN, _lpTokenAmountIn) returns (uint256 womOut) {
                // 2.2. get WOM in BUSD out at pancake.
                address[] memory path = new address[](2);
                path[0] = WOM_TOKEN;
                path[1] = BUSD_TOKEN;
                uint256[] memory amountsOut = IUniswapV2Router01(PANCAKE_ROUTER).getAmountsOut(womOut, path);
                return amountsOut[1];
            } catch {}
            return 0;
        } else if (_pool == WOM_BNB_POOL) {
            // 2.1. Estimate amount out in BNB.
            try IWomPool(_pool).quotePotentialWithdraw(WBNB_TOKEN, _lpTokenAmountIn) returns (uint256 bnbOut) {
                // 2.2. get WOM in BUSD out at pancake.
                address[] memory path = new address[](2);
                path[0] = WBNB_TOKEN;
                path[1] = BUSD_TOKEN;
                uint256[] memory amountsOut = IUniswapV2Router01(PANCAKE_ROUTER).getAmountsOut(bnbOut, path);
                return amountsOut[1];
            } catch {
            }
            return 0;
        } else {
            revert("unsupported pool");
        }
    }

    // OTHER HELPERS

    function getWomLpBalances(
        IBooster _booster,
        address _user,
        uint256[] memory _poolIds
    ) public view returns(uint256[] memory balances) {
        uint256 len = _poolIds.length;
        balances = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            IBooster.PoolInfo memory poolInfo = _booster.poolInfo(i);
            balances[i] = IERC20(poolInfo.crvRewards).balanceOf(_user);
        }
    }

    function quoteUnderlyingAmountOut(
        address _lpToken,
        uint256 _lpTokenAmountIn
    ) public view returns(uint256) {
        address pool = IWomLpToken(_lpToken).pool();
        address underlyingToken = IWomLpToken(_lpToken).underlyingToken();
        return IWomPool(pool).quotePotentialWithdraw(underlyingToken, _lpTokenAmountIn);
    }
}