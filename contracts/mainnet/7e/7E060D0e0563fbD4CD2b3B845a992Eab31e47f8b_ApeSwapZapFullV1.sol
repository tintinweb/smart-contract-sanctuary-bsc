// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         

 * App:             https://apeswap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Discord:         https://discord.com/invite/apeswap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "./ApeSwapZap.sol";
import "./extensions/bills/ApeSwapZapTBills.sol";
import "./extensions/ApeSwapZapLPMigrator.sol";
import "./extensions/pools/ApeSwapZapPools.sol";
import "./extensions/pools/lib/ITreasury.sol";
import "./lib/IApeRouter02.sol";

contract ApeSwapZapFullV1 is
    ApeSwapZap,
    ApeSwapZapTBills,
    ApeSwapZapLPMigrator,
    ApeSwapZapPools
{
    constructor(IApeRouter02 _router, ITreasury _goldenBananaTreasury)
        ApeSwapZap(_router)
        ApeSwapZapLPMigrator(_router)
        ApeSwapZapPools(_goldenBananaTreasury)
    {}
}

// SPDX-License-Identifier: MIT
 pragma solidity 0.8.15;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
 pragma solidity 0.8.15;

import "./IApeRouter01.sol";

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

// SPDX-License-Identifier: MIT
 pragma solidity 0.8.15;

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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.6;

interface IApePair {
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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.6;

interface IApeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreasury {
    function adminAddress() external view returns (address);

    function banana() external view returns (IERC20);

    function bananaReserves() external view returns (uint256);

    function buy(uint256 _amount) external;

    function buyFee() external view returns (uint256);

    function emergencyWithdraw(uint256 _amount) external;

    function goldenBanana() external view returns (IERC20);

    function goldenBananaReserves() external view returns (uint256);

    function maxBuyFee() external view returns (uint256);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function sell(uint256 _amount) external;

    function setAdmin(address _adminAddress) external;

    function setBuyFee(uint256 _fee) external;

    function transferOwnership(address newOwner) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 

interface IBEP20RewardApeV5 {
    function REWARD_TOKEN() external view returns (IERC20);

    function STAKE_TOKEN() external view returns (IERC20);

    function bonusEndBlock() external view returns (uint256);

    function owner() external view returns (address);

    function poolInfo()
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accRewardTokenPerShare
        );

    function renounceOwnership() external;

    function rewardPerBlock() external view returns (uint256);

    function startBlock() external view returns (uint256);

    function totalRewardsAllocated() external view returns (uint256);

    function totalRewardsPaid() external view returns (uint256);

    function totalStaked() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function userInfo(address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) external;

    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    function setBonusEndBlock(uint256 _bonusEndBlock) external;

    function pendingReward(address _user) external view returns (uint256);

    function updatePool() external;

    function deposit(uint256 _amount) external;

    function depositTo(uint256 _amount, address _user) external;

    function withdraw(uint256 _amount) external;

    function rewardBalance() external view returns (uint256);

    function getUnharvestedRewards() external view returns (uint256);

    function depositRewards(uint256 _amount) external;

    function totalStakeTokenBalance() external view returns (uint256);

    function getStakeTokenFeeBalance() external view returns (uint256);

    function setRewardPerBlock(uint256 _rewardPerBlock) external;

    function skimStakeTokenFees(address _to) external;

    function emergencyWithdraw() external;

    function emergencyRewardWithdraw(uint256 _amount) external;

    function sweepToken(address token) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../ApeSwapZap.sol";
import "./lib/IBEP20RewardApeV5.sol";
import "./lib/ITreasury.sol";

abstract contract ApeSwapZapPools is ApeSwapZap {
    using SafeERC20 for IERC20;

    IERC20 public immutable BANANA;
    IERC20 public immutable GNANA;
    ITreasury public immutable GNANA_TREASURY; // Golden Banana Treasury

    event ZapLPPool(
        IERC20 inputToken,
        uint256 inputAmount,
        IBEP20RewardApeV5 pool
    );
    event ZapLPPoolNative(uint256 inputAmount, IBEP20RewardApeV5 pool);
    event ZapSingleAssetPool(
        IERC20 inputToken,
        uint256 inputAmount,
        IBEP20RewardApeV5 pool
    );
    event ZapSingleAssetPoolNative(
        uint256 inputAmount,
        IBEP20RewardApeV5 pool
    );

    constructor(ITreasury goldenBananaTreasury) {
        /// @dev Can't access immutable variables in constructor
        ITreasury gnanaTreasury = goldenBananaTreasury;
        GNANA_TREASURY = gnanaTreasury;
        BANANA = gnanaTreasury.banana();
        GNANA = gnanaTreasury.goldenBanana();
    }

    /// @notice Zap token into banana/gnana pool
    /// @param inputToken Input token to zap
    /// @param inputAmount Amount of input tokens to zap
    /// @param path Path from input token to stake token
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @param pool Pool address
    function zapSingleAssetPool(
        IERC20 inputToken,
        uint256 inputAmount,
        address[] calldata path,
        uint256 minAmountsSwap,
        uint256 deadline,
        IBEP20RewardApeV5 pool
    ) external nonReentrant {
        uint256 balanceBefore = _getBalance(inputToken);
        inputToken.safeTransferFrom(msg.sender, address(this), inputAmount);
        inputAmount = _getBalance(inputToken) - balanceBefore;

        __zapInternalSingleAssetPool(
            inputToken,
            inputAmount,
            path,
            minAmountsSwap,
            deadline,
            pool
        );
        emit ZapSingleAssetPool(inputToken, inputAmount, pool);
    }

    /// @notice Zap native into banana/gnana pool
    /// @param path Path from input token to stake token
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @param pool Pool address
    function zapSingleAssetPoolNative(
        address[] calldata path,
        uint256 minAmountsSwap,
        uint256 deadline,
        IBEP20RewardApeV5 pool
    ) external payable nonReentrant {
        uint256 inputAmount = msg.value;
        IERC20 inputToken = IERC20(WNATIVE);
        IWETH(WNATIVE).deposit{ value: inputAmount }();

        __zapInternalSingleAssetPool(
            inputToken,
            inputAmount,
            path,
            minAmountsSwap,
            deadline,
            pool
        );
        emit ZapSingleAssetPoolNative(inputAmount, pool);
    }

    /// @notice Zap token into banana/gnana pool
    /// @param inputToken Input token to zap
    /// @param inputAmount Amount of input tokens to zap
    /// @param lpTokens Tokens of LP to zap to
    /// @param path0 Path from input token to LP token0
    /// @param path1 Path from input token to LP token1
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @param pool Pool address
    function zapLPPool(
        IERC20 inputToken,
        uint256 inputAmount,
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        uint256 deadline,
        IBEP20RewardApeV5 pool
    ) external nonReentrant {
        IApePair pair = IApePair(address(pool.STAKE_TOKEN()));
        require(
            (lpTokens[0] == pair.token0() &&
                lpTokens[1] == pair.token1()) ||
                (lpTokens[1] == pair.token0() &&
                    lpTokens[0] == pair.token1()),
            "ApeSwapZap: Wrong LP pair for Pool"
        );

        _zapInternal(
            inputToken,
            inputAmount,
            lpTokens,
            path0,
            path1,
            minAmountsSwap,
            minAmountsLP,
            address(this),
            deadline
        );

        uint256 balance = pair.balanceOf(address(this));
        pair.approve(address(pool), balance);
        pool.depositTo(balance, msg.sender);
        pair.approve(address(pool), 0);
        emit ZapLPPool(inputToken, inputAmount, pool);
    }

    /// @notice Zap native into banana/gnana pool
    /// @param lpTokens Tokens of LP to zap to
    /// @param path0 Path from input token to LP token0
    /// @param path1 Path from input token to LP token1
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @param pool Pool address
    function zapLPPoolNative(
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        uint256 deadline,
        IBEP20RewardApeV5 pool
    ) external payable nonReentrant {
        IApePair pair = IApePair(address(pool.STAKE_TOKEN()));
        require(
            (lpTokens[0] == pair.token0() &&
                lpTokens[1] == pair.token1()) ||
                (lpTokens[1] == pair.token0() &&
                    lpTokens[0] == pair.token1()),
            "ApeSwapZap: Wrong LP pair for Pool"
        );

        _zapNativeInternal(
            lpTokens,
            path0,
            path1,
            minAmountsSwap,
            minAmountsLP,
            address(this),
            deadline
        );

        uint256 balance = pair.balanceOf(address(this));
        pair.approve(address(pool), balance);
        pool.depositTo(balance, msg.sender);
        pair.approve(address(pool), 0);
        emit ZapLPPoolNative(msg.value, pool);
    }

        /// @notice Zap token into banana/gnana pool
    /// @param inputToken Input token to zap
    /// @param inputAmount Amount of input tokens to zap
    /// @param path Path from input token to stake token
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @param pool Pool address
    function __zapInternalSingleAssetPool(
        IERC20 inputToken,
        uint256 inputAmount,
        address[] calldata path,
        uint256 minAmountsSwap,
        uint256 deadline,
        IBEP20RewardApeV5 pool
    ) internal {
        IERC20 stakeToken = pool.STAKE_TOKEN();

        uint256 amount = inputAmount;
        IERC20 neededToken = stakeToken == GNANA ? BANANA : stakeToken;

        if (inputToken != neededToken) {
            require(
                path[0] == address(inputToken),
                "ApeSwapZap: wrong path path[0]"
            );
            require(
                path[path.length - 1] == address(neededToken),
                "ApeSwapZap: wrong path path[-1]"
            );

            inputToken.approve(address(router), inputAmount);
            uint256[] memory amounts = router.swapExactTokensForTokens(
                inputAmount,
                minAmountsSwap,
                path,
                address(this),
                deadline
            );
            amount = amounts[amounts.length - 1];
        }

        if (stakeToken == GNANA) {
            uint256 beforeAmount = _getBalance(stakeToken);
            IERC20(BANANA).approve(address(GNANA_TREASURY), amount);
            GNANA_TREASURY.buy(amount);
            amount = _getBalance(stakeToken) - beforeAmount;
        }

        stakeToken.approve(address(pool), amount);
        pool.depositTo(amount, msg.sender);
        stakeToken.approve(address(pool), 0);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ICustomBill {
    function principalToken() external returns (address);

    function deposit(
        uint256 _amount,
        uint256 _maxPrice,
        address _depositor
    ) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../ApeSwapZap.sol";
import "./lib/ICustomBill.sol";

abstract contract ApeSwapZapTBills is ApeSwapZap {
    event ZapTBill(IERC20 inputToken, uint256 inputAmount, ICustomBill bill);
    event ZapTBillNative(uint256 inputAmount, ICustomBill bill);

    /// @notice Zap single token to LP
    /// @param inputToken Input token to zap
    /// @param inputAmount Amount of input tokens to zap
    /// @param lpTokens Tokens of LP to zap to
    /// @param path0 Path from input token to LP token0
    /// @param path1 Path from input token to LP token1
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @param bill Treasury bill address
    /// @param maxPrice Max price of treasury bill
    function zapTBill(
        IERC20 inputToken,
        uint256 inputAmount,
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        uint256 deadline,
        ICustomBill bill,
        uint256 maxPrice
    ) external nonReentrant {
        IApePair pair = IApePair(bill.principalToken());
        require(
            (lpTokens[0] == pair.token0() &&
                lpTokens[1] == pair.token1()) ||
                (lpTokens[1] == pair.token0() &&
                    lpTokens[0] == pair.token1()),
            "ApeSwapZap: Wrong LP pair for TBill"
        );

        _zapInternal(
            inputToken,
            inputAmount,
            lpTokens,
            path0,
            path1,
            minAmountsSwap,
            minAmountsLP,
            address(this),
            deadline
        );

        uint256 balance = pair.balanceOf(address(this));
        pair.approve(address(bill), balance);
        bill.deposit(balance, maxPrice, msg.sender);
        pair.approve(address(bill), 0);
        emit ZapTBill(inputToken, inputAmount, bill);
    }

    /// @notice Zap native token to Treasury Bill
    /// @param lpTokens Tokens of LP to zap to
    /// @param path0 Path from input token to LP token0
    /// @param path1 Path from input token to LP token1
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @param bill Treasury bill address
    /// @param maxPrice Max price of treasury bill
    function zapTBillNative(
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        uint256 deadline,
        ICustomBill bill,
        uint256 maxPrice
    ) external payable nonReentrant {
        IApePair pair = IApePair(bill.principalToken());
        require(
            (lpTokens[0] == pair.token0() &&
                lpTokens[1] == pair.token1()) ||
                (lpTokens[1] == pair.token0() &&
                    lpTokens[0] == pair.token1()),
            "ApeSwapZap: Wrong LP pair for TBill"
        );

        _zapNativeInternal(
            lpTokens,
            path0,
            path1,
            minAmountsSwap,
            minAmountsLP,
            address(this),
            deadline
        );

        uint256 balance = pair.balanceOf(address(this));
        pair.approve(address(bill), balance);
        bill.deposit(balance, maxPrice, msg.sender);
        pair.approve(address(bill), 0);
        emit ZapTBillNative(msg.value, bill);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../lib/IApeRouter02.sol";
import "../lib/IApePair.sol";

abstract contract ApeSwapZapLPMigrator is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IApeRouter02 public immutable apeRouter;

    event LPMigrated(
        IApePair lp,
        IApeRouter02 fromRouter,
        IApeRouter02 toRouter,
        uint256 amount
    );

    constructor(IApeRouter02 router) {
        apeRouter = router;
    }

    /// @notice Zap non APE-LPs to APE-LPs
    /// @param router The non APE-LP router
    /// @param lp LP address to zap
    /// @param amount Amount of LPs to zap
    /// @param amountAMinRemove The minimum amount of token0 to receive after removing liquidity
    /// @param amountBMinRemove The minimum amount of token1 to receive after removing liquidity
    /// @param amountAMinAdd The minimum amount of token0 to add to APE-LP on add liquidity
    /// @param amountBMinAdd The minimum amount of token1 to add to APE-LP on add liquidity
    /// @param deadline Unix timestamp after which the transaction will revert
    function zapLPMigrator(
        IApeRouter02 router,
        IApePair lp,
        uint256 amount,
        uint256 amountAMinRemove,
        uint256 amountBMinRemove,
        uint256 amountAMinAdd,
        uint256 amountBMinAdd,
        uint256 deadline
    ) external nonReentrant {
        address token0 = lp.token0();
        address token1 = lp.token1();

        IERC20(address(lp)).safeTransferFrom(msg.sender, address(this), amount);
        lp.approve(address(router), amount);
        (uint256 amountAReceived, uint256 amountBReceived) = router
            .removeLiquidity(
                token0,
                token1,
                amount,
                amountAMinRemove,
                amountBMinRemove,
                address(this),
                deadline
            );

        IERC20(token0).approve(address(apeRouter), amountAReceived);
        IERC20(token1).approve(address(apeRouter), amountBReceived);
        (uint256 amountASent, uint256 amountBSent, ) = apeRouter.addLiquidity(
            token0,
            token1,
            amountAReceived,
            amountBReceived,
            amountAMinAdd,
            amountBMinAdd,
            msg.sender,
            deadline
        );

        if (amountAReceived - amountASent > 0) {
            IERC20(token0).safeTransfer(
                msg.sender,
                amountAReceived - amountASent
            );
        }
        if (amountBReceived - amountBSent > 0) {
            IERC20(token1).safeTransfer(
                msg.sender,
                amountBReceived - amountBSent
            );
        }

        emit LPMigrated(lp, router, apeRouter, amount);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         

 * App:             https://apeswap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Discord:         https://discord.com/invite/apeswap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IApeSwapZap {
    function zap(
        IERC20 _inputToken,
        uint256 _inputAmount,
        address[] memory _lpTokens, //[tokenA, tokenB]
        address[] calldata _path0,
        address[] calldata _path1,
        uint256[] memory _minAmountsSwap, //[A, B]
        uint256[] memory _minAmountsLP, //[amountAMin, amountBMin]
        address _to,
        uint256 _deadline
    ) external;

    function zapNative(
        address[] memory _lpTokens, //[tokenA, tokenB]
        address[] calldata _path0,
        address[] calldata _path1,
        uint256[] memory _minAmountsSwap, //[A, B]
        uint256[] memory _minAmountsLP, //[amountAMin, amountBMin]
        address _to,
        uint256 _deadline
    ) external payable;

    function getMinAmounts(
        uint256 _inputAmount,
        address[] calldata _path0,
        address[] calldata _path1
    )
        external
        view
        returns (
            uint256[2] memory _minAmountsSwap,
            uint256[2] memory _minAmountsLP
        );
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         

 * App:             https://apeswap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Discord:         https://discord.com/invite/apeswap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "./IApeSwapZap.sol";
import "./lib/IApeRouter02.sol";
import "./lib/IApeFactory.sol";
import "./lib/IApePair.sol";
import "./lib/IWETH.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ApeSwapZap is IApeSwapZap, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct BalanceLocalVars {
        uint256 amount0;
        uint256 amount1;
        uint256 balanceBefore;
    }

    IApeRouter02 public immutable router;
    IApeFactory public immutable factory;
    address public immutable WNATIVE;

    event Zap(address inputToken, uint256 inputAmount, address[] lpTokens);
    event ZapNative(uint256 inputAmount, address[] lpTokens);

    constructor(IApeRouter02 _router) {
        router = _router;
        factory = IApeFactory(router.factory());
        WNATIVE = router.WETH();
    }

    /// @dev The receive method is used as a fallback function in a contract
    /// and is called when ether is sent to a contract with no calldata.
    receive() external payable {
        require(
            msg.sender == WNATIVE,
            "ApeSwapZap: Only receive ether from wrapped"
        );
    }

    /// @notice Zap single token to LP
    /// @param inputToken Input token
    /// @param inputAmount Input amount
    /// @param lpTokens Tokens of LP to zap to
    /// @param path0 Path from input token to LP token0
    /// @param path1 Path from input token to LP token1
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param to address to receive LPs
    /// @param deadline Unix timestamp after which the transaction will revert
    function zap(
        IERC20 inputToken,
        uint256 inputAmount,
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        address to,
        uint256 deadline
    ) external override nonReentrant {
        _zapInternal(
            inputToken,
            inputAmount,
            lpTokens,
            path0,
            path1,
            minAmountsSwap,
            minAmountsLP,
            to,
            deadline
        );
    }

    /// @notice Zap native token to LP
    /// @param lpTokens Tokens of LP to zap to
    /// @param path0 Path from input token to LP token0
    /// @param path1 Path from input token to LP token1
    /// @param minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param to address to receive LPs
    /// @param deadline Unix timestamp after which the transaction will revert
    function zapNative(
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        address to,
        uint256 deadline
    ) external payable override nonReentrant {
        _zapNativeInternal(
            lpTokens,
            path0,
            path1,
            minAmountsSwap,
            minAmountsLP,
            to,
            deadline
        );
    }

    /// @notice get min amounts for swaps
    /// @param inputAmount total input amount for swap
    /// @param path0 path from input token to LP token0
    /// @param path1 path from input token to LP token1
    function getMinAmounts(
        uint256 inputAmount,
        address[] calldata path0,
        address[] calldata path1
    )
        external
        view
        override
        returns (
            uint256[2] memory minAmountsSwap,
            uint256[2] memory minAmountsLP
        )
    {
        require(
            path0.length >= 2 || path1.length >= 2,
            "ApeSwapZap: Needs at least one path"
        );

        uint256 inputAmountHalf = inputAmount / 2;

        uint256 minAmountSwap0 = inputAmountHalf;
        if (path0.length != 0) {
            uint256[] memory amountsOut0 = router.getAmountsOut(
                inputAmountHalf,
                path0
            );
            minAmountSwap0 = amountsOut0[amountsOut0.length - 1];
        }

        uint256 minAmountSwap1 = inputAmountHalf;
        if (path1.length != 0) {
            uint256[] memory amountsOut1 = router.getAmountsOut(
                inputAmountHalf,
                path1
            );
            minAmountSwap1 = amountsOut1[amountsOut1.length - 1];
        }

        address token0 = path0.length == 0 ? path1[0] : path0[path0.length - 1];
        address token1 = path1.length == 0 ? path0[0] : path1[path1.length - 1];

        IApePair lp = IApePair(factory.getPair(token0, token1));
        (uint256 reserveA, uint256 reserveB, ) = lp.getReserves();
        if (token0 == lp.token1()) {
            (reserveA, reserveB) = (reserveB, reserveA);
        }
        uint256 amountB = router.quote(minAmountSwap0, reserveA, reserveB);

        minAmountsSwap = [minAmountSwap0, minAmountSwap1];
        minAmountsLP = [minAmountSwap0, amountB];
    }

    function _zapInternal(
        IERC20 inputToken,
        uint256 inputAmount,
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        address to,
        uint256 deadline
    ) internal {
        uint256 balanceBefore = _getBalance(inputToken);
        inputToken.safeTransferFrom(msg.sender, address(this), inputAmount);
        inputAmount = _getBalance(inputToken) - balanceBefore;

        _zapPrivate(
            inputToken,
            inputAmount,
            lpTokens,
            path0,
            path1,
            minAmountsSwap,
            minAmountsLP,
            to,
            deadline,
            false
        );
        emit Zap(address(inputToken), inputAmount, lpTokens);
    }

    function _zapNativeInternal(
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        address to,
        uint256 deadline
    ) internal {
        uint256 inputAmount = msg.value;
        IERC20 inputToken = IERC20(WNATIVE);
        IWETH(WNATIVE).deposit{ value: inputAmount }();

        _zapPrivate(
            inputToken,
            inputAmount,
            lpTokens,
            path0,
            path1,
            minAmountsSwap,
            minAmountsLP,
            to,
            deadline,
            true
        );
        emit ZapNative(inputAmount, lpTokens);
    }

    function _transfer(
        address token,
        uint256 amount,
        bool native
    ) internal {
        if (amount == 0) return;
        if (token == WNATIVE && native) {
            IWETH(WNATIVE).withdraw(amount);
            // 2600 COLD_ACCOUNT_ACCESS_COST plus 2300 transfer gas - 1
            // Intended to support transfers to contracts, but not allow for further code execution
            (bool success, ) = msg.sender.call{ value: amount, gas: 4899 }("");
            require(success, "native transfer error");
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }

    function _getBalance(IERC20 token) internal view returns (uint256 balance) {
        balance = token.balanceOf(address(this));
    }

    function _zapPrivate(
        IERC20 inputToken,
        uint256 inputAmount,
        address[] memory lpTokens, //[tokenA, tokenB]
        address[] calldata path0,
        address[] calldata path1,
        uint256[] memory minAmountsSwap, //[A, B]
        uint256[] memory minAmountsLP, //[amountAMin, amountBMin]
        address to,
        uint256 deadline,
        bool native
    ) private {
        require(to != address(0), "ApeSwapZap: Can't zap to null address");
        require(
            lpTokens.length == 2,
            "ApeSwapZap: need exactly 2 tokens to form a LP"
        );
        require(
            factory.getPair(lpTokens[0], lpTokens[1]) != address(0),
            "ApeSwapZap: Pair doesn't exist"
        );

        BalanceLocalVars memory vars;

        inputToken.approve(address(router), inputAmount);

        vars.amount0 = inputAmount / 2;
        vars.balanceBefore = 0;
        if (lpTokens[0] != address(inputToken)) {
            require(
                path0[0] == address(inputToken),
                "ApeSwapZap: wrong path path0[0]"
            );
            require(
                path0[path0.length - 1] == lpTokens[0],
                "ApeSwapZap: wrong path path0[-1]"
            );
            vars.balanceBefore = _getBalance(IERC20(lpTokens[0]));
            router.swapExactTokensForTokens(
                vars.amount0,
                minAmountsSwap[0],
                path0,
                address(this),
                deadline
            );
            vars.amount0 =
                _getBalance(IERC20(lpTokens[0])) -
                vars.balanceBefore;
        }

        vars.amount1 = inputAmount / 2;
        if (lpTokens[1] != address(inputToken)) {
            require(
                path1[0] == address(inputToken),
                "ApeSwapZap: wrong path path1[0]"
            );
            require(
                path1[path1.length - 1] == lpTokens[1],
                "ApeSwapZap: wrong path path1[-1]"
            );
            vars.balanceBefore = _getBalance(IERC20(lpTokens[1]));
            router.swapExactTokensForTokens(
                vars.amount1,
                minAmountsSwap[1],
                path1,
                address(this),
                deadline
            );
            vars.amount1 =
                _getBalance(IERC20(lpTokens[1])) -
                vars.balanceBefore;
        }

        IERC20(lpTokens[0]).approve(address(router), vars.amount0);
        IERC20(lpTokens[1]).approve(address(router), vars.amount1);
        (uint256 amountA, uint256 amountB, ) = router.addLiquidity(
            lpTokens[0],
            lpTokens[1],
            vars.amount0,
            vars.amount1,
            minAmountsLP[0],
            minAmountsLP[1],
            to,
            deadline
        );

        if (lpTokens[0] == WNATIVE) {
            // Ensure WNATIVE is called last
            _transfer(lpTokens[1], vars.amount1 - amountB, native);
            _transfer(lpTokens[0], vars.amount0 - amountA, native);
        } else {
            _transfer(lpTokens[0], vars.amount0 - amountA, native);
            _transfer(lpTokens[1], vars.amount1 - amountB, native);
        }
    }
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