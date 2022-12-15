// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Ownable.sol";
import "IERC20.sol";

import "IPancakePair.sol";
import "IUniswapV2Router01.sol";
import "IWETH.sol";

import "IERC20ElasticSupply.sol";
import "IGenesisLiquidityPool.sol";
import "IGenesisLiquidityPoolNative.sol";


contract SaveRenBTCBSC is Ownable {

    IUniswapV2Router01 public immutable router;

    address public immutable WBNB;
    address public immutable GEX;
    address public immutable RENBTC;
    address public immutable BTCB;
    
    address public immutable Pancake_BTCB_RENBTC;
    address public immutable Pancake_BTCB_WBNB;
    address public immutable GLP_RENBTC;
    address public immutable GLP_BNB;


    constructor() {
        router = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        GEX = 0x2743Bb6962fb1D7d13C056476F3Bc331D7C3E112;
        RENBTC = 0xfCe146bF3146100cfe5dB4129cf6C82b0eF4Ad8c;
        BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;

        Pancake_BTCB_WBNB = 0x61EB789d75A95CAa3fF50ed7E47b96c132fEc082;
        Pancake_BTCB_RENBTC = 0x8c9910c8562e7058561713A2f8Eb6b84cA247e02;

        GLP_RENBTC = 0x5ae76CbAedf4E0F710C2b429890B4cCC0737104D;
        GLP_BNB = 0xA4df7a003303552AcDdF550A0A65818c4A218315;

        _approveBTCBNB(type(uint256).max);
    }

    /// @dev Contract needs to receive BNB from WBNB contract. If this is not 
    /// present, contract will throw an error when BNB is sent to it.
    receive() external payable {}

    function _approveBTCBNB(uint256 amount) internal {
        IERC20(GEX).approve(GLP_RENBTC, amount);
    }

    function mint(uint256 amount) external onlyOwner {
        require(amount <= 1e24);
        IERC20ElasticSupply(GEX).mint(address(this), amount);
    }

    function burn() external onlyOwner {
        uint256 gexAmount = IERC20(GEX).balanceOf(address(this));
        IERC20ElasticSupply(GEX).burn(address(this), gexAmount);
    }

    function extractRENBTC() external onlyOwner {
        uint256 gexAmount = IERC20(GEX).balanceOf(address(this));
        IGenesisLiquidityPool(GLP_RENBTC).redeemSwap(gexAmount, 0);
    }

    function withdrawRENBTC() external onlyOwner {
        uint256 renbtcAmount = IERC20(RENBTC).balanceOf(address(this));
        IERC20(RENBTC).transfer(owner(), renbtcAmount);
    }

    function transferRENBTCtoBNB() external onlyOwner {
        // Redeem GEX for RENBTC
        uint256 gexAmount = IERC20(GEX).balanceOf(address(this));
        IGenesisLiquidityPool(GLP_RENBTC).redeemSwap(gexAmount, 0);
        uint256 renbtcAmount = IERC20(RENBTC).balanceOf(address(this));

        // Swap RENBTC for BTCB
        uint256 btcbAmount = _swapRENBTCforBTCB(renbtcAmount);

        // Swap RENBTC for BTCB
        uint256 bnbAmount = _swapBTCBforBNB(btcbAmount);
        
        // Mint GEX for BNB
        IGenesisLiquidityPoolNative(GLP_BNB).mintSwapNative{value: bnbAmount}(0);
    }

    function _swapRENBTCforBTCB(uint256 amountInRENBTC) private returns(uint256) {
        address[] memory tradePath = new address[](2);
        tradePath[0] = RENBTC;
        tradePath[1] = BTCB;
        uint256 amountOutBTCB = router.getAmountsOut(amountInRENBTC, tradePath)[0];

        IERC20(RENBTC).transfer(Pancake_BTCB_RENBTC, amountInRENBTC);
        IPancakePair(Pancake_BTCB_RENBTC).swap(amountOutBTCB, 0, address(this), new bytes(0));
        return amountOutBTCB;
    }

    function _swapBTCBforBNB(uint256 amountInBTCB) private returns(uint256) {
        address[] memory tradePath = new address[](2);
        tradePath[0] = BTCB;
        tradePath[1] = WBNB;
        uint256 amountOutWBNB = router.getAmountsOut(amountInBTCB, tradePath)[0];

        IERC20(BTCB).transfer(Pancake_BTCB_WBNB, amountInBTCB);
        IPancakePair(Pancake_BTCB_WBNB).swap(0, amountOutWBNB, address(this), new bytes(0));

        // Unwrap BNB
        IWETH(WBNB).withdraw(amountOutWBNB);
        return amountOutWBNB;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IUniswapV2Router01 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "IERC20.sol";


/**
* @title IERC20ElasticSupply
* @author Geminon Protocol
* @dev Interface for the ERC20ElasticSupply contract
*/
interface IERC20ElasticSupply is IERC20 {

    function addMinter(address newMinter) external;
    function removeMinter(address minter) external;
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function maxAmountMintable() external view returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ICollectible.sol";


interface IGenesisLiquidityPool is ICollectible {

    // +++++++++++++++++++  PUBLIC STATE VARIABLES  +++++++++++++++++++++++++

    function initMintedAmount() external view returns(uint256);

    function poolWeight() external view returns(uint16);
    
    function mintedGEX() external view returns(int256);

    function balanceCollateral() external view returns(uint256);

    function balanceGEX() external view returns(uint256);
    
    function blockTimestampLast() external view returns(uint64);
    
    function lastCollatPrice() external view returns(uint256);
    
    function meanPrice() external view returns(uint256);
    
    function lastPrice() external view returns(uint256);
    
    function meanVolume() external view returns(uint256);
    
    function lastVolume() external view returns(uint256);

    function isMigrationRequested() external view returns(bool);
    
    function isRemoveRequested() external view returns(bool);    
    

    // ++++++++++++++++++++++++++  MIGRATION  +++++++++++++++++++++++++++++++

    function receiveMigration(uint256 amountGEX, uint256 amountCollateral, uint256 initMintedAmount) external;

    function bailoutMinter() external returns(uint256);

    function lendCollateral(uint256 amount) external returns(uint256);

    function repayCollateral(uint256 amount) external returns(uint256);

    
    // ++++++++++++++++++++++++  USE FUNCTIONS  +++++++++++++++++++++++++++++
    
    function mintSwap(uint256 inCollatAmount, uint256 minOutGEXAmount) external;

    function redeemSwap(uint256 inGEXAmount, uint256 minOutCollatAmount) external;
    
    
    // ++++++++++++++++++++  INFORMATIVE FUNCTIONS  +++++++++++++++++++++++++

    function collateralPrice() external view returns(uint256);

    function collateralQuote() external view returns(uint256);

    function getCollateralValue() external view returns(uint256);

    function GEXPrice() external view returns(uint256);

    function GEXQuote() external view returns(uint256);

    function amountFeeMint(uint256 amountGEX) external view returns(uint256);

    function amountFeeRedeem(uint256 amountGEX) external view returns(uint256);

    function getMintInfo(uint256 inCollatAmount) external view returns(
        uint256 collateralPriceUSD, 
        uint256 gexPriceUSD,
        uint256 collatQuote,
        uint256 gexQuote,
        uint256 fee,
        uint256 feeAmount,
        uint256 outGEXAmount,
        uint256 finalGEXPriceUSD,
        uint256 priceImpact
    );

    function getRedeemInfo(uint256 inGEXAmount) external view returns(
        uint256 collateralPriceUSD, 
        uint256 gexPriceUSD,
        uint256 collatQuote,
        uint256 gexQuote,
        uint256 fee,
        uint256 feeAmount,
        uint256 outCollatAmount,
        uint256 finalGEXPriceUSD,
        uint256 priceImpact
    );

    function amountOutGEX(uint256 inCollatAmount) external view returns(uint256);

    function amountOutCollateral(uint256 inGEXAmount) external view returns(uint256);

    function amountMint(uint256 outGEXAmount) external view returns(uint256);

    function amountBurn(uint256 inGEXAmount) external view returns(uint256);

    function variableFee(uint256 amountGEX, uint256 baseFee) external view returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
* @title ICollectible
* @author Geminon Protocol
* @notice Interface for smart contracts whose fees have
* to be collected by the FeeCollector contract.
*/
interface ICollectible {
    function collectFees() external returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "IGenesisLiquidityPool.sol";


interface IGenesisLiquidityPoolNative is IGenesisLiquidityPool {

    function receiveMigrationNative(uint256 amountGEX, uint256 initMintedAmount) external payable;

    function repayCollateralNative() external payable returns(uint256);

    function mintSwapNative(uint256 minOutGEXAmount) external payable;
}