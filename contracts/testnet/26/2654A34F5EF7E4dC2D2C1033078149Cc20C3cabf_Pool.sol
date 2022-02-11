/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IApeRouter01 {
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

interface IApeRouter02 is IApeRouter01 {
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

contract Pool {
    mapping(address => uint256) public depositBalance;

    struct BlockBalance {
        uint256 blockNumber;
        uint256 depositBalance;
        uint256 values;
    }

    mapping(address => BlockBalance[]) public depositBlocks;
    mapping(address => bool) public isAddedAsset;

    uint256 public totalDeposit;
    address[] public assets;
    address public depositToken;
    address public wETH;

    address public pancakeRouter;

    constructor() {
        depositToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        wETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        pancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    }

    function deposit(uint256 amount) public {
        require(amount > 0, "INVALID_AMOUNT");
        depositBalance[msg.sender] = depositBalance[msg.sender] + amount;

        BlockBalance memory blockBalance;
        blockBalance.blockNumber = block.number;
        blockBalance.depositBalance = amount;
        blockBalance.values = _getPoolValues() + amount;
        depositBlocks[msg.sender].push(blockBalance);

        totalDeposit = totalDeposit + amount;

        require(
            IERC20(depositToken).transferFrom(msg.sender, address(this), amount)
        );
    }

    function swap(address[] calldata path, uint256 amountIn) public {
        uint256[] memory amountsOut = IApeRouter02(pancakeRouter).getAmountsOut(
            amountIn,
            path
        );

        uint256 amountOutMin = (995 * amountsOut[1]) / 1000;

        address token = path[0] == depositToken ? path[1] : path[0];
        if (!isAddedAsset[token]) {
            isAddedAsset[token] = true;
            assets.push(token);
        }
        require(IERC20(path[0]).approve(pancakeRouter, amountIn));
        IApeRouter02(pancakeRouter).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 20 minutes
        );
    }

    function exit(uint256 indexWallet) public {
        uint256 currentValues = _getPoolValues();
        BlockBalance memory blockBalance = depositBlocks[msg.sender][
            indexWallet
        ];

        require(blockBalance.depositBalance > 0, "EMPTY_BALANCE");

        uint256 depositTokenBalance = _getAssetBalance(depositToken);
        uint256 totalProfit;
        uint256 totalLoss;

        if (currentValues >= blockBalance.values) {
            // profit
            totalProfit = currentValues - blockBalance.values;
            uint256 myProfit;
            if (totalProfit > 0) {
                uint256 ratio = blockBalance.depositBalance * totalProfit;
                if (ratio >= totalDeposit) {
                    myProfit = ratio / totalDeposit;
                }
            }
            uint256 totalExit = blockBalance.depositBalance + myProfit;

            if (depositTokenBalance >= totalExit) {
                require(IERC20(depositToken).transfer(msg.sender, totalExit));
            } else {
                uint256 amountNeed = totalExit - depositTokenBalance;
                _swapToDeposit(amountNeed, currentValues);
                require(IERC20(depositToken).transfer(msg.sender, totalExit));
            }

            totalDeposit = totalDeposit - blockBalance.depositBalance;
            depositBlocks[msg.sender][indexWallet].depositBalance = 0;
        } else {
            // loss
            totalLoss = blockBalance.values - currentValues;
            uint256 myLoss;
            if (totalLoss > 0) {
                uint256 ratio = blockBalance.depositBalance * totalLoss;
                if (ratio >= totalDeposit) {
                    myLoss = ratio / totalDeposit;
                }
            }

            uint256 totalExit = blockBalance.depositBalance - totalLoss;

            if (depositTokenBalance >= totalExit) {
                require(IERC20(depositToken).transfer(msg.sender, totalExit));
            } else {
                uint256 amountNeed = totalExit - depositTokenBalance;
                _swapToDeposit(amountNeed, currentValues);
                require(IERC20(depositToken).transfer(msg.sender, totalExit));
            }

            totalDeposit = totalDeposit - blockBalance.depositBalance;
            depositBlocks[msg.sender][indexWallet].depositBalance = 0;
        }
    }
    
    function getPoolValues() public view returns (uint256){
        return _getPoolValues();
    }

    // internal
    function _swapToDeposit(uint256 amountNeed, uint256 totalValues) internal {
        uint256 tokenValue;
        uint256 percent;
        uint256 amountOutToken;
        uint256 totalSwap = amountNeed;

        for (uint256 i = 0; i < assets.length; i++) {
            if (i == assets.length - 1) {
                amountOutToken = totalSwap;
                totalSwap = 0;
            } else {
                tokenValue = _getValueInDepositToken(assets[i]);
                percent = (tokenValue * 10000) / totalValues;
                amountOutToken = (percent * amountNeed) / 10000;
                totalSwap = totalSwap - amountOutToken;
            }

            _swapExact(assets[i], depositToken, amountOutToken);
        }

        require(totalSwap == 0);
    }

    function _swap(
        address token0,
        address token1,
        uint256 amountIn
    ) internal {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        uint256[] memory amountsOut = IApeRouter02(pancakeRouter).getAmountsOut(
            amountIn,
            path
        );

        uint256 amountOutMin = (995 * amountsOut[1]) / 1000;
        require(IERC20(path[0]).approve(pancakeRouter, amountIn));
        IApeRouter02(pancakeRouter).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 20 minutes
        );
    }

    function _swapExact(
        address token0,
        address token1,
        uint256 amountNeed
    ) internal {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        uint256[] memory amountsIn = IApeRouter02(pancakeRouter).getAmountsIn(
            amountNeed,
            path
        );

        uint256 amountInMax = (1005 * amountsIn[0]) / 1000;
        require(IERC20(path[0]).approve(pancakeRouter, amountInMax));
        IApeRouter02(pancakeRouter).swapTokensForExactTokens(
            amountNeed,
            amountInMax,
            path,
            address(this),
            block.timestamp + 20 minutes
        );
    }

    function _getPoolValues() internal view returns (uint256) {
        uint256 totalValues = _getAssetBalance(depositToken);
        for (uint256 i = 0; i < assets.length; i++) {
            totalValues = totalValues + _getValueInDepositToken(assets[i]);
        }

        return totalValues;
    }

    function _getValueInDepositToken(address token)
        internal
        view
        returns (uint256)
    {
        uint256 assetBalance = _getAssetBalance(token);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = depositToken;

        uint256[] memory amountsOut = IApeRouter02(pancakeRouter).getAmountsOut(
            assetBalance,
            path
        );

        return amountsOut[1];
    }

    function _getAssetBalance(address token) internal view returns (uint256) {
        if (token == wETH) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }
}