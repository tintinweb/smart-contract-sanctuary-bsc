// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/ISwap.sol";
import "./interfaces/IVault.sol";
import "./interfaces/INToken.sol";
import "./libraries/DataTypes.sol";


contract Swap is ISwap {
    // contract address of PancakeRouter on testnet
    address public constant PANCAKE_V2_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    // contract address of PancakeRouter on mainnet
    //address private constant PANCAKE_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function wBNB() public pure override returns(address) {
        return IPancakeRouter02(PANCAKE_V2_ROUTER).WETH();
    }

    function swapBNBForTokens(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to
    ) external override payable {
        address[] memory path = new address[](2);

        path[0] = wBNB();
        path[1] = _tokenOut;

        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactETHForTokens{value: msg.value}(
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function swapTokensForBNB(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external override {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER, _amountIn);

        address[] memory path = new address[](2);

        path[0] = _tokenIn;
        path[1] = wBNB();

        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactTokensForETH(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function swapTokensForTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external override {
        address WETH = wBNB();

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER, _amountIn);

        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }

        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external view override returns (uint256) {
        address[] memory path;
        if (_tokenIn == wBNB() || _tokenOut == wBNB()) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = wBNB();
            path[2] = _tokenOut;
        }

        // same length as path
        uint256[] memory amountOutMins = IPancakeRouter02(PANCAKE_V2_ROUTER).getAmountsOut(
            _amountIn, //Amount of Token 1
            path //Token 1, Token 2
        );

        return amountOutMins[path.length - 1]; //Token 1 amount
    }


    function getTokenPrice(uint256 _amount, address _tokenIn, address _tokenOut) public view override returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        uint[] memory price = IPancakeRouter02(PANCAKE_V2_ROUTER).getAmountsOut(_amount, path);
        return price[0];
    }

    function getVaultTVL(address _tokenOut, address _vault) public override returns(uint256) {
        DataTypes.TokenOut[] memory tokenOuts = IVault(_vault).getTokenOuts();
        uint256 tvl;
        for (uint256 i=0; i < tokenOuts.length; i++){
            uint256 tvlAux = getTokenPrice(tokenOuts[i].percent, tokenOuts[i].tokenAddress, _tokenOut);
            tvl = tvl + tvlAux;
        }
        return tvl;
    }

    function getShareTokenPrice(address _tokenOut, address _vault) public override returns(uint256) {
        //DataTypes.TokenOut[] memory tokenOuts = IVault(_vault).getTokenOuts();
        uint256 totalSupply = INToken(IVault(_vault).nTokenAddress()).scaledTotalSupply();
        uint256 tvl = getVaultTVL(_tokenOut, _vault);
        /*
        for (uint256 i=0; i < tokenOuts.length; i++){
            uint256 tvlAux = getTokenPrice(tokenOuts[i].percent, tokenOuts[i].tokenAddress, _tokenOut);
            tvl = tvl + tvlAux;
        }
        */
        return tvl/totalSupply;
    }

    function getUserTVL(address _tokenOut, address _user, address _vault) external override returns(uint256) {
        uint256 shareTokenPrice = this.getShareTokenPrice(_tokenOut, _vault);
        uint256 numTokens = INToken(IVault(_vault).nTokenAddress()).getUserBalance(_user);
        return shareTokenPrice * numTokens;
    }




}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface IPancakeRouter02 {
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface ISwap {
    function wBNB() external pure returns(address);

    function swapBNBForTokens(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to
    ) external payable;

    function swapTokensForBNB(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external;

    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    )  external view returns (uint256);

    function swapTokensForTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external;

    function getTokenPrice(
        uint256 _amount,
        address _tokenIn,
        address _tokenOut
    ) external returns (uint256);

    function getShareTokenPrice(
        address _tokenOut,
        address _vault
    ) external returns (uint256);

    function getVaultTVL(
        address _tokenOut,
        address _vault
    ) external returns (uint256);

    function getUserTVL(
      address _tokenOut,
      address _user,
      address _vault
    ) external returns (uint256);

}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "../libraries/DataTypes.sol";

interface IVault {
    event Initialized(
        address indexed vaultAddress,
        address indexed creator,
        string vaultName,
        string nTokenName,
        string nTokenSymbol,
        address[] tokenAddresses,
        uint256[] percents,
        uint256 entryFeeRate,
        uint256 maintenanceFeeRate,
        uint256 performanceFeeRate
    );

    event EditTokens(
        address indexed vaultAddress,
        address indexed creator,
        address[] newTokenAddresses,
        uint256[] newPercents
    );

    event TakeFee(
        address indexed treasury,
        address indexed vaultAddress,
        address indexed creator,
        uint256 creatorFee,
        uint256 platformFee
    );

    event Deposit(
        address indexed vaultAddress,
        address indexed creator,
        address indexed investor,
        uint256 amountInBNB,
        uint256 amountInBUSD,
        uint256 entryFee
    );

    event Withdraw(address indexed to, uint256 amount);

    function deposit() external payable;
    function withdraw(uint256 _amount) external;

    function nTokenAddress() external view returns(address);
/*
    function getBalance(
        address _user
    ) external returns (uint256);

    function getTotalSupply(
    ) external returns (uint256);
    */

    function getTokenOuts(
    ) external returns (DataTypes.TokenOut[] memory);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface INToken {

    event Mint(address indexed from, uint256 value);
    event Burn(address indexed from, uint256 value);

    function mint(address user, uint256 amount) external;
    function burn(address user, uint256 amount) external;

    function scaledTotalSupply() external returns (uint256);
    function getUserBalance(address user) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

library DataTypes {
    struct VaultData {
        string vaultName;
        string nTokenName;
        string nTokenSymbol;
        address[] tokenAddresses;
        uint256[] percents;
    }

    struct TokenOut {
        address tokenAddress;
        uint256 percent;
    }
}