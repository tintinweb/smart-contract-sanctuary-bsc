// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../libraries/HedgepieLibraryBsc.sol";
import "../../interfaces/IHedgepieInvestor.sol";

interface IStrategy {
    function deposit(uint256) external;

    function withdraw(uint256) external;

    function balance() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function getPricePerFullShare() external view returns (uint256);
}

contract BeefyVaultAdapterBsc is BaseAdapter {
    /**
     * @notice Construct
     * @param _strategy  address of strategy
     * @param _stakingToken  address of staking token
     * @param _router  address of router for LP
     * @param _swapRouter  address of swap router
     * @param _wbnb  address of wbnb
     * @param _name  adatper name
     * @param _hedgepieAuthority HedgepieAuthority address
     */
    constructor(
        address _strategy,
        address _stakingToken,
        address _router,
        address _swapRouter,
        address _wbnb,
        string memory _name,
        address _hedgepieAuthority
    ) BaseAdapter(_hedgepieAuthority) {
        strategy = _strategy;
        stakingToken = _stakingToken;
        repayToken = _strategy;
        router = _router;
        swapRouter = _swapRouter;
        wbnb = _wbnb;
        name = _name;
    }

    /**
     * @notice Deposit with BNB
     * @param _tokenId YBNFT token id
     */
    function deposit(
        uint256 _tokenId
    ) external payable override onlyInvestor returns (uint256 amountOut) {
        UserAdapterInfo storage userInfo = userAdapterInfos[_tokenId];

        // 1. get stakingToken
        if (router == address(0)) {
            amountOut = HedgepieLibraryBsc.swapOnRouter(
                msg.value,
                address(this),
                stakingToken,
                swapRouter,
                wbnb
            );
        } else {
            amountOut = HedgepieLibraryBsc.getLP(
                IYBNFT.AdapterParam(0, stakingToken, address(this)),
                wbnb,
                msg.value
            );
        }

        // 2. deposit to vault
        uint256 repayAmt = IERC20(repayToken).balanceOf(address(this));
        IERC20(stakingToken).approve(strategy, amountOut);
        IStrategy(strategy).deposit(amountOut);
        repayAmt = IERC20(repayToken).balanceOf(address(this)) - repayAmt;
        require(repayAmt != 0, "Failed to deposit");

        // 3. update user info
        userInfo.amount += repayAmt;
        userInfo.invested += amountOut;

        return msg.value;
    }

    /**
     * @notice Withdraw the deposited BNB
     * @param _tokenId YBNFT token id
     * @param _amount amount of repayToken to withdraw
     */
    function withdraw(
        uint256 _tokenId,
        uint256 _amount
    ) external payable override onlyInvestor returns (uint256 amountOut) {
        UserAdapterInfo storage userInfo = userAdapterInfos[_tokenId];

        if (_amount == 0) return 0;

        // 1. withdraw from vault
        uint256 lpOut = IERC20(stakingToken).balanceOf(address(this));
        IStrategy(strategy).withdraw(_amount);
        lpOut = IERC20(stakingToken).balanceOf(address(this)) - lpOut;

        // 2. swap withdrawn lp to bnb
        if (router == address(0)) {
            amountOut = HedgepieLibraryBsc.swapForBnb(
                lpOut,
                address(this),
                stakingToken,
                swapRouter,
                wbnb
            );
        } else {
            amountOut = HedgepieLibraryBsc.withdrawLP(
                IYBNFT.AdapterParam(0, stakingToken, address(this)),
                wbnb,
                lpOut
            );
        }

        // 3. update userInfo
        userInfo.amount -= _amount;
        if (lpOut >= userInfo.invested) userInfo.invested = 0;
        else userInfo.invested -= lpOut;

        // 4. send withdrawn bnb to investor
        if (amountOut != 0) {
            (bool success, ) = payable(msg.sender).call{value: amountOut}("");
            require(success, "Failed to send bnb");
        }
    }

    /**
     * @notice Claim the pending reward
     * @param _tokenId YBNFT token id
     */
    function claim(
        uint256 _tokenId
    ) external payable override onlyInvestor returns (uint256 amountOut) {
        UserAdapterInfo storage userInfo = userAdapterInfos[_tokenId];

        // 1. check if reward is generated
        uint256 wantAmt = ((userInfo.amount *
            IStrategy(strategy).getPricePerFullShare()) / 1e18);
        uint256 wantShare = ((
            wantAmt > userInfo.invested ? wantAmt - userInfo.invested : 0
        ) * 1e18) / IStrategy(strategy).getPricePerFullShare();

        // 2. if reward is not generated
        if (wantAmt <= userInfo.invested || wantShare == 0) {
            if (userInfo.rewardDebt1 == 0) return 0;

            amountOut = userInfo.rewardDebt1;
            userInfo.rewardDebt1 = 0;

            // send reward in bnb
            _sendToInvestor(amountOut, _tokenId);
            return amountOut;
        }

        // 3. withdraw reward from vault
        uint256 lpOut = IERC20(stakingToken).balanceOf(address(this));
        IStrategy(strategy).withdraw(wantShare);
        lpOut = IERC20(stakingToken).balanceOf(address(this)) - lpOut;
        require(lpOut != 0, "Failed to claim");

        // 4. swap reward to bnb
        if (router == address(0)) {
            amountOut =
                HedgepieLibraryBsc.swapForBnb(
                    lpOut,
                    address(this),
                    stakingToken,
                    swapRouter,
                    wbnb
                ) +
                userInfo.rewardDebt1;
        } else {
            amountOut =
                HedgepieLibraryBsc.withdrawLP(
                    IYBNFT.AdapterParam(0, stakingToken, address(this)),
                    wbnb,
                    lpOut
                ) +
                userInfo.rewardDebt1;
        }

        // 5. update user info
        userInfo.amount -= wantShare;
        userInfo.rewardDebt1 = 0;

        // 6. send reward in bnb to investor
        if (amountOut != 0) _sendToInvestor(amountOut, _tokenId);
    }

    /**
     * @notice Return the pending reward by BNB
     * @param _tokenId YBNFT token id
     */
    function pendingReward(
        uint256 _tokenId
    ) external view override returns (uint256 reward, uint256) {
        UserAdapterInfo memory userInfo = userAdapterInfos[_tokenId];

        uint256 wantAmt = ((userInfo.amount *
            IStrategy(strategy).getPricePerFullShare()) / 1e18);

        if (wantAmt <= userInfo.invested)
            return (userInfo.rewardDebt1, userInfo.rewardDebt1);

        wantAmt -= userInfo.invested;

        if (router == address(0)) {
            address[] memory pathStake = IPathFinder(authority.pathFinder())
                .getPaths(swapRouter, stakingToken, wbnb);

            if (stakingToken != wbnb)
                reward += wantAmt == 0
                    ? 0
                    : IPancakeRouter(swapRouter).getAmountsOut(
                        wantAmt,
                        pathStake
                    )[pathStake.length - 1];
        } else {
            address token0 = IPancakePair(stakingToken).token0();
            address token1 = IPancakePair(stakingToken).token1();
            address[] memory path0 = IPathFinder(authority.pathFinder())
                .getPaths(swapRouter, token0, wbnb);
            address[] memory path1 = IPathFinder(authority.pathFinder())
                .getPaths(swapRouter, token1, wbnb);

            (uint112 reserve0, uint112 reserve1, ) = IPancakePair(stakingToken)
                .getReserves();

            uint256 amount0 = (reserve0 * wantAmt) /
                IPancakePair(stakingToken).totalSupply();
            uint256 amount1 = (reserve1 * wantAmt) /
                IPancakePair(stakingToken).totalSupply();

            if (token0 == wbnb) reward += amount0;
            else
                reward += amount0 == 0
                    ? 0
                    : IPancakeRouter(swapRouter).getAmountsOut(amount0, path0)[
                        path0.length - 1
                    ];

            if (token1 == wbnb) reward += amount1;
            else
                reward += amount1 == 0
                    ? 0
                    : IPancakeRouter(swapRouter).getAmountsOut(amount1, path1)[
                        path1.length - 1
                    ];
        }
        return (reward + userInfo.rewardDebt1, reward + userInfo.rewardDebt1);
    }

    /**
     * @notice Remove funds
     * @param _tokenId YBNFT token id
     */
    function removeFunds(
        uint256 _tokenId
    ) external payable override onlyInvestor returns (uint256 amountOut) {
        UserAdapterInfo storage userInfo = userAdapterInfos[_tokenId];
        if (userInfo.amount == 0) return 0;

        // 1. withdraw all from Vault
        amountOut = IERC20(stakingToken).balanceOf(address(this));
        IStrategy(strategy).withdraw(userInfo.amount);
        amountOut = IERC20(stakingToken).balanceOf(address(this)) - amountOut;

        // 2. calc reward
        uint256 rewardPercent = 0;
        if (amountOut > userInfo.invested) {
            rewardPercent =
                ((amountOut - userInfo.invested) * 1e12) /
                amountOut;
        }

        // 3. swap withdrawn lp to bnb
        if (router == address(0)) {
            amountOut = HedgepieLibraryBsc.swapForBnb(
                amountOut,
                address(this),
                stakingToken,
                swapRouter,
                wbnb
            );
        } else {
            amountOut = HedgepieLibraryBsc.withdrawLP(
                IYBNFT.AdapterParam(0, stakingToken, address(this)),
                wbnb,
                amountOut
            );
        }

        // 4. remove userInfo and stake pendingReward to rewardDebt1
        uint256 reward = (amountOut * rewardPercent) / 1e12;
        userInfo.amount = 0;
        userInfo.invested = 0;
        userInfo.rewardDebt1 += reward;

        // 5. send withdrawn bnb to investor
        (bool success, ) = payable(authority.hInvestor()).call{
            value: amountOut - reward
        }("");
        require(success, "Failed to send bnb to investor");
    }

    /**
     * @notice Update funds
     * @param _tokenId YBNFT token id
     */
    function updateFunds(
        uint256 _tokenId
    ) external payable override onlyInvestor returns (uint256 amountOut) {
        if (msg.value == 0) return 0;

        UserAdapterInfo storage userInfo = userAdapterInfos[_tokenId];

        // 1. get LP
        if (router == address(0)) {
            amountOut = HedgepieLibraryBsc.swapOnRouter(
                msg.value,
                address(this),
                stakingToken,
                swapRouter,
                wbnb
            );
        } else {
            amountOut = HedgepieLibraryBsc.getLP(
                IYBNFT.AdapterParam(0, stakingToken, address(this)),
                wbnb,
                msg.value
            );
        }

        // 2. deposit to vault
        uint256 repayAmt = IERC20(repayToken).balanceOf(address(this));
        IERC20(stakingToken).approve(strategy, amountOut);
        IStrategy(strategy).deposit(amountOut);
        repayAmt = IERC20(repayToken).balanceOf(address(this)) - repayAmt;
        require(repayAmt != 0, "Failed to update funds");

        // 3. update user info
        userInfo.amount = repayAmt;
        userInfo.invested = amountOut;

        return msg.value;
    }

    receive() external payable {}
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IYBNFT.sol";
import "../interfaces/IAdapter.sol";
import "../interfaces/IPathFinder.sol";
import "../interfaces/IPancakePair.sol";
import "../interfaces/IPancakeRouter.sol";
import "../interfaces/IOffchainOracle.sol";
import "../interfaces/IHedgepieAuthority.sol";

import "../base/BaseAdapter.sol";

library HedgepieLibraryBsc {
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address constant ORACLE = 0xfbD61B037C325b959c0F6A7e69D8f37770C2c550;

    function swapOnRouter(
        uint256 _amountIn,
        address _adapter,
        address _outToken,
        address _router,
        address _wbnb
    ) public returns (uint256 amountOut) {
        address[] memory path = IPathFinder(
            IHedgepieAuthority(IAdapter(_adapter).authority()).pathFinder()
        ).getPaths(_router, _wbnb, _outToken);
        uint256 beforeBalance = IERC20(_outToken).balanceOf(address(this));

        IPancakeRouter(_router)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _amountIn
        }(0, path, address(this), block.timestamp + 2 hours);

        uint256 afterBalance = IERC20(_outToken).balanceOf(address(this));
        amountOut = afterBalance - beforeBalance;
    }

    function swapForBnb(
        uint256 _amountIn,
        address _adapter,
        address _inToken,
        address _router,
        address _wbnb
    ) public returns (uint256 amountOut) {
        if (_inToken == _wbnb) {
            IWrap(_wbnb).withdraw(_amountIn);
            amountOut = _amountIn;
        } else {
            address[] memory path = IPathFinder(
                IHedgepieAuthority(IAdapter(_adapter).authority()).pathFinder()
            ).getPaths(_router, _inToken, _wbnb);
            uint256 beforeBalance = address(this).balance;

            IERC20(_inToken).approve(_router, _amountIn);

            IPancakeRouter(_router)
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    _amountIn,
                    0,
                    path,
                    address(this),
                    block.timestamp + 2 hours
                );

            uint256 afterBalance = address(this).balance;
            amountOut = afterBalance - beforeBalance;
        }
    }

    function getMRewards(uint256 _tokenId, address _adapterAddr)
        public
        view
        returns (uint256 reward, uint256 reward1)
    {
        BaseAdapter.AdapterInfo memory adapterInfo = IAdapter(_adapterAddr)
            .mAdapter();
        BaseAdapter.UserAdapterInfo memory userInfo = IAdapter(_adapterAddr)
            .userAdapterInfos(_tokenId);

        if (
            IAdapter(_adapterAddr).rewardToken() != address(0) &&
            adapterInfo.totalStaked != 0 &&
            adapterInfo.accTokenPerShare1 != 0
        ) {
            reward =
                (userInfo.amount *
                    (adapterInfo.accTokenPerShare1 - userInfo.userShare1)) /
                1e12 +
                userInfo.rewardDebt1;
        }

        if (
            IAdapter(_adapterAddr).rewardToken1() != address(0) &&
            adapterInfo.totalStaked != 0 &&
            adapterInfo.accTokenPerShare2 != 0
        ) {
            reward1 =
                (userInfo.amount *
                    (adapterInfo.accTokenPerShare2 - userInfo.userShare2)) /
                1e12 +
                userInfo.rewardDebt2;
        }
    }

    function getLP(
        IYBNFT.AdapterParam memory _adapter,
        address wbnb,
        uint256 _amountIn
    ) public returns (uint256 amountOut) {
        address[2] memory tokens;
        tokens[0] = IPancakePair(_adapter.token).token0();
        tokens[1] = IPancakePair(_adapter.token).token1();
        address _router = IAdapter(_adapter.addr).router();

        uint256[2] memory tokenAmount;
        unchecked {
            tokenAmount[0] = _amountIn / 2;
            tokenAmount[1] = _amountIn - tokenAmount[0];
        }

        if (tokens[0] != wbnb) {
            tokenAmount[0] = swapOnRouter(
                tokenAmount[0],
                _adapter.addr,
                tokens[0],
                _router,
                wbnb
            );
            IERC20(tokens[0]).approve(_router, tokenAmount[0]);
        }

        if (tokens[1] != wbnb) {
            tokenAmount[1] = swapOnRouter(
                tokenAmount[1],
                _adapter.addr,
                tokens[1],
                _router,
                wbnb
            );
            IERC20(tokens[1]).approve(_router, tokenAmount[1]);
        }

        if (tokenAmount[0] != 0 && tokenAmount[1] != 0) {
            if (tokens[0] == wbnb || tokens[1] == wbnb) {
                (, , amountOut) = IPancakeRouter(_router).addLiquidityETH{
                    value: tokens[0] == wbnb ? tokenAmount[0] : tokenAmount[1]
                }(
                    tokens[0] == wbnb ? tokens[1] : tokens[0],
                    tokens[0] == wbnb ? tokenAmount[1] : tokenAmount[0],
                    0,
                    0,
                    address(this),
                    block.timestamp + 2 hours
                );
            } else {
                (, , amountOut) = IPancakeRouter(_router).addLiquidity(
                    tokens[0],
                    tokens[1],
                    tokenAmount[0],
                    tokenAmount[1],
                    0,
                    0,
                    address(this),
                    block.timestamp + 2 hours
                );
            }
        }
    }

    function withdrawLP(
        IYBNFT.AdapterParam memory _adapter,
        address wbnb,
        uint256 _amountIn
    ) public returns (uint256 amountOut) {
        address[2] memory tokens;
        tokens[0] = IPancakePair(_adapter.token).token0();
        tokens[1] = IPancakePair(_adapter.token).token1();

        address _router = IAdapter(_adapter.addr).router();
        address swapRouter = IAdapter(_adapter.addr).swapRouter();

        IERC20(_adapter.token).approve(_router, _amountIn);

        if (tokens[0] == wbnb || tokens[1] == wbnb) {
            address tokenAddr = tokens[0] == wbnb ? tokens[1] : tokens[0];
            (uint256 amountToken, uint256 amountETH) = IPancakeRouter(_router)
                .removeLiquidityETH(
                    tokenAddr,
                    _amountIn,
                    0,
                    0,
                    address(this),
                    block.timestamp + 2 hours
                );

            amountOut = amountETH;
            amountOut += swapForBnb(
                amountToken,
                _adapter.addr,
                tokenAddr,
                swapRouter,
                wbnb
            );
        } else {
            (uint256 amountA, uint256 amountB) = IPancakeRouter(_router)
                .removeLiquidity(
                    tokens[0],
                    tokens[1],
                    _amountIn,
                    0,
                    0,
                    address(this),
                    block.timestamp + 2 hours
                );

            amountOut += swapForBnb(
                amountA,
                _adapter.addr,
                tokens[0],
                swapRouter,
                wbnb
            );
            amountOut += swapForBnb(
                amountB,
                _adapter.addr,
                tokens[1],
                swapRouter,
                wbnb
            );
        }
    }

    function getBNBPrice() public view returns (uint256) {
        return IOffchainOracle(ORACLE).getRate(WBNB, USDT, false);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IHedgepieInvestor {
    function treasury() external view returns (address);

    function updateFunds(uint256 _tokenId) external;

    function deposit(uint256 _tokenId) external;

    function withdraw(uint256 _tokenId) external;

    function claim(uint256 _tokenId) external;

    function pendingReward(
        uint256 _tokenId,
        address _account
    ) external returns (uint256 amountOut, uint256 withdrawable);
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

// SPDX-License-Identifier: None
pragma solidity ^0.8.4;

interface IYBNFT {
    struct AdapterParam {
        uint256 allocation;
        address token;
        address addr;
    }

    function getCurrentTokenId() external view returns (uint256);

    function performanceFee(uint256 tokenId) external view returns (uint256);

    function getTokenAdapterParams(
        uint256 tokenId
    ) external view returns (AdapterParam[] memory);

    function exists(uint256) external view returns (bool);

    function mint(
        uint256[] calldata,
        address[] calldata,
        address[] calldata,
        uint256,
        string memory
    ) external;

    function updateTVLInfo(
        uint256 _tokenId,
        uint256 _value,
        bool _adding
    ) external;

    function updateTradedInfo(
        uint256 _tokenId,
        uint256 _value,
        bool _adding
    ) external;

    function updateProfitInfo(
        uint256 _tokenId,
        uint256 _value,
        bool _adding
    ) external;

    function updateParticipantInfo(
        uint256 _tokenId,
        address _account,
        bool _adding
    ) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "./IWrap.sol";
import "../base/BaseAdapter.sol";

interface IAdapter {
    function stakingToken() external view returns (address);

    function strategy() external view returns (address);

    function name() external view returns (string memory);

    function rewardToken() external view returns (address);

    function rewardToken1() external view returns (address);

    function router() external view returns (address);

    function swapRouter() external view returns (address);

    function authority() external view returns (address);

    function deposit(
        uint256 _tokenId
    ) external payable returns (uint256 amountOut);

    function withdraw(
        uint256 _tokenId,
        uint256 _amount
    ) external payable returns (uint256 amountOut);

    function claim(
        uint256 _tokenId
    ) external payable returns (uint256 amountOut);

    function pendingReward(
        uint256 _tokenId
    ) external view returns (uint256 amountOut, uint256 withdrawable);

    function adapterInfos(
        uint256 _tokenId
    ) external view returns (BaseAdapter.AdapterInfo memory);

    function userAdapterInfos(
        uint256 _tokenId
    ) external view returns (BaseAdapter.UserAdapterInfo memory);

    function mAdapter() external view returns (BaseAdapter.AdapterInfo memory);

    function removeFunds(
        uint256 _tokenId
    ) external payable returns (uint256 amount);

    function getUserAmount(
        uint256 _tokenId
    ) external view returns (uint256 amount);

    function updateFunds(
        uint256 _tokenId
    ) external payable returns (uint256 amount);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IPathFinder {
    function getPaths(
        address _router,
        address _inToken,
        address _outToken
    ) external view returns (address[] memory);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint256);

    function fee() external view returns (uint24);

    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IPancakeRouter {
    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IOffchainOracle {
    function getRate(
        address srcToken,
        address dstToken,
        bool
    ) external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

interface IHedgepieAuthority {
    /* ========== EVENTS ========== */

    event GovernorPushed(
        address indexed from,
        address indexed to,
        bool _effectiveImmediately
    );
    event PathManagerPushed(
        address indexed from,
        address indexed to,
        bool _effectiveImmediately
    );
    event AdapterManagerPushed(
        address indexed from,
        address indexed to,
        bool _effectiveImmediately
    );

    event GovernorPulled(address indexed from, address indexed to);
    event PathManagerPulled(address indexed from, address indexed to);
    event AdapterManagerPulled(address indexed from, address indexed to);

    event HInvestorUpdated(address indexed from, address indexed to);
    event HYBNFTUpdated(address indexed from, address indexed to);
    event HAdapterListUpdated(address indexed from, address indexed to);
    event PathFinderUpdated(address indexed from, address indexed to);

    /* ========== VIEW ========== */

    function governor() external view returns (address);

    function pathManager() external view returns (address);

    function adapterManager() external view returns (address);

    function hInvestor() external view returns (address);

    function hYBNFT() external view returns (address);

    function hAdapterList() external view returns (address);

    function pathFinder() external view returns (address);

    function paused() external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/IYBNFT.sol";
import "../interfaces/IPathFinder.sol";
import "../interfaces/IHedgepieInvestor.sol";
import "../interfaces/IHedgepieAuthority.sol";

import "./HedgepieAccessControlled.sol";

abstract contract BaseAdapter is HedgepieAccessControlled {
    struct UserAdapterInfo {
        uint256 amount; // Staking token amount
        uint256 userShare1; // Reward tokens' share
        uint256 userShare2; // Reward tokens' share
        uint256 rewardDebt1; // Reward Debt for reward tokens
        uint256 rewardDebt2; // Reward Debt for reward tokens
        uint256 invested; // invested lp token amount
    }

    struct AdapterInfo {
        uint256 accTokenPerShare1; // Accumulated per share for first reward token
        uint256 accTokenPerShare2; // Accumulated per share for first reward token
        uint256 totalStaked; // Total staked staking token
    }

    uint256 public pid;

    address public stakingToken;

    address public rewardToken;

    address public rewardToken1;

    address public repayToken;

    address public strategy;

    address public router;

    address public swapRouter;

    address public wbnb;

    string public name;

    AdapterInfo public mAdapter;

    // nft id => UserAdapterInfo
    mapping(uint256 => UserAdapterInfo) public userAdapterInfos;

    constructor(
        address _hedgepieAuthority
    ) HedgepieAccessControlled(IHedgepieAuthority(_hedgepieAuthority)) {}

    /** @notice get user staked amount */
    function getUserAmount(
        uint256 _tokenId
    ) external view returns (uint256 amount) {
        return userAdapterInfos[_tokenId].amount;
    }

    /**
     * @notice deposit to strategy
     * @param _tokenId YBNFT token id
     */
    function deposit(
        uint256 _tokenId
    ) external payable virtual returns (uint256 amountOut) {}

    /**
     * @notice withdraw from strategy
     * @param _tokenId YBNFT token id
     * @param _amount amount of staking tokens to withdraw
     */
    function withdraw(
        uint256 _tokenId,
        uint256 _amount
    ) external payable virtual returns (uint256 amountOut) {}

    /**
     * @notice claim reward from strategy
     * @param _tokenId YBNFT token id
     */
    function claim(
        uint256 _tokenId
    ) external payable virtual returns (uint256 amountOut) {}

    /**
     * @notice Remove funds
     * @param _tokenId YBNFT token id
     */
    function removeFunds(
        uint256 _tokenId
    ) external payable virtual returns (uint256 amountOut) {}

    /**
     * @notice Update funds
     * @param _tokenId YBNFT token id
     */
    function updateFunds(
        uint256 _tokenId
    ) external payable virtual returns (uint256 amountOut) {}

    /**
     * @notice Get pending token reward
     * @param _tokenId YBNFT token id
     */
    function pendingReward(
        uint256 _tokenId
    ) external view virtual returns (uint256 reward, uint256 withdrawable) {}

    /**
     * @notice internal function to send bnb to investor
     * @param _tokenId YBNFT token id
     */
    function _sendToInvestor(uint256 _amount, uint256 _tokenId) internal {
        uint256 taxAmount = (_amount *
            IYBNFT(authority.hYBNFT()).performanceFee(_tokenId)) / 1e4;
        (bool success, ) = payable(
            IHedgepieInvestor(authority.hInvestor()).treasury()
        ).call{value: taxAmount}("");
        require(success, "Failed to send bnb to Treasury");

        (success, ) = payable(msg.sender).call{value: _amount - taxAmount}("");
        require(success, "Failed to send bnb");
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

interface IWrap {
    function deposit(uint256 amount) external;

    function withdraw(uint256 share) external;

    function deposit() external payable;
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "../interfaces/IHedgepieAuthority.sol";

abstract contract HedgepieAccessControlled {
    /* ========== EVENTS ========== */

    event AuthorityUpdated(IHedgepieAuthority indexed authority);

    string UNAUTHORIZED = "UNAUTHORIZED"; // save gas

    string PAUSED = "PAUSED"; // save gas

    /* ========== STATE VARIABLES ========== */

    IHedgepieAuthority public authority;

    /* ========== Constructor ========== */

    constructor(IHedgepieAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }

    /* ========== MODIFIERS ========== */

    modifier whenNotPaused() {
        require(!authority.paused(), PAUSED);
        _;
    }

    modifier onlyGovernor() {
        require(msg.sender == authority.governor(), UNAUTHORIZED);
        _;
    }

    modifier onlyPathManager() {
        require(msg.sender == authority.pathManager(), UNAUTHORIZED);
        _;
    }

    modifier onlyAdapterManager() {
        require(msg.sender == authority.adapterManager(), UNAUTHORIZED);
        _;
    }

    modifier onlyInvestor() {
        require(msg.sender == authority.hInvestor(), UNAUTHORIZED);
        _;
    }

    /* ========== GOV ONLY ========== */

    function setAuthority(
        IHedgepieAuthority _newAuthority
    ) external onlyGovernor {
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }
}