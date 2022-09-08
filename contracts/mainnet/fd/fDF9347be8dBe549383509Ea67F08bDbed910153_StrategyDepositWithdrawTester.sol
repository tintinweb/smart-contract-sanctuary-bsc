// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./interfaces/IPancakeRouter.sol";
import "./interfaces/strategy/IDexStrategy.sol";
import "./interfaces/IWETH.sol";

contract StrategyDepositWithdrawTester {

    IPancakeRouter public router;
    address public native;

    event Test(
        address indexed strategyAddress,
        uint256 amountIn,
        uint256 amountOut,
        uint256 deltaInOut
    );

    constructor(address router_) {
        router = IPancakeRouter(router_);
        native = router.WETH();
    }

    function testDepositWithdraw(
        address strategyAddress
    ) payable external returns (uint256 amountOut) {
        address thisAddress = address(this);
        uint256 amountIn = msg.value;
        IWETH weth = IWETH(native);
        weth.deposit{value: amountIn}();
        IERC20(native).approve(strategyAddress, amountIn);
        uint256 amountInternal = IDexStrategy(strategyAddress).deposit(amountIn, thisAddress);
        amountOut = IDexStrategy(strategyAddress).withdraw(amountInternal, thisAddress);
        uint256 deltaInOut = amountIn > amountOut ? amountIn - amountOut : 0;
        IERC20(native).transfer(msg.sender, amountOut);
        emit Test(strategyAddress, amountIn, amountOut, deltaInOut);
    }

    receive() external payable {
        assert(msg.sender == native);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./../IStructs.sol";

interface IStrategyStructs is IStructs {
    /* Structs: Strategy */
    struct StrategyFarm {
        IDexShareRewardPool pool;
        uint256 id;
        uint256 percent;
        bool isStakingTokenLP;
        address stakingToken;
        address rewardToken;
        address token0;
        address token1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IStrategyPublish {
    /* Structs */
    struct PublishData {
        bool published;
        address publisher;
    }

    /* View methods */
    function publishInfo() external view returns (PublishData memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IStrategyProfitManagement {
    /* View methods */
    function profit() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IStrategyStructs.sol";

interface IStrategy is IStrategyStructs {
    /* Non-view methods */
    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_,
        uint256 profit_,
        InitializationFarm[] memory farms_
    ) external returns (bool);
    function updateStrategy(
        InitializationFarm[] memory farms_,
        uint256 profit_
    ) external returns (bool);
    function deposit(
        uint256 amount,
        address to
    ) external returns (uint256 mintAmount);
    function harvest() external returns (uint256 nativeAmount, uint256 feeAmount);
    function autoHarvest(uint256 automationPaymentAmount) external returns (uint256 nativeAmount, uint256 feeAmount);
    function withdraw(
        uint256 amount,
        address from
    ) external returns (uint256 nativeOutput);
    function pause() external returns (bool);
    function unpause() external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IStrategyStructs.sol";
import "./IStrategyProfitManagement.sol";
import "./IStrategyPublish.sol";
import "./IStrategy.sol";

interface IDexStrategy is IStrategyStructs, IStrategyProfitManagement, IStrategyPublish, IStrategy {}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IDexShareRewardPool.sol";

interface IStructs {
    /* Structs: for Factory and Strategy */
    struct ETFBurnConfiguration {
        uint256[] minAmountsOut;
        address[] intermediaries;
    }

    struct TokenInfo {
        bool isLP;
        bool isETF;
        address token0;
        address token1;
    }

    struct FarmWithoutPercent {
        IDexShareRewardPool pool;
        uint256 id;
        bool isStakingTokenLP;
        address stakingToken;
        address rewardToken;
        address token0;
        address token1;
    }

    struct InitializationFarm {
        IDexShareRewardPool pool;
        uint256 id;
        uint256 percent;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IPancakeRouterPart {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter is IPancakeRouterPart {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDexShareRewardPool {
    /* Structs */
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 token;
        uint256 allocPoint;
        uint256 lastRewardTime;
        uint256 accRewardPerShare;
        bool isStarted;
    }

    /* View methods */
    function dexshare() external view returns (IERC20); // dexShare pool
    function rewardToken() external view returns (IERC20); // regulation pool
    function poolInfo(uint256 id) external view returns (PoolInfo memory);
    function userInfo(uint256 id, address account) external view returns (UserInfo memory);

    /* Non-view methods */
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
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