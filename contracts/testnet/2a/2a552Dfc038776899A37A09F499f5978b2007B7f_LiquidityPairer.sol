//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IPresaleDatabase.sol";

interface ITokenLocker {
    function giveDiscount(address user) external;
}

/**
    Presale contract talks to the liquidity pairer to have liquidity paired
 */
contract LiquidityPairer {

    // WETH - Wrapped BNB
    address public immutable WETH;

    // Type 0 = Restricted | Type 1 = Standard (Uniswap) | Type 2 = Balancer
    mapping ( address => uint8 ) public dexType;

    // Presale Database
    IPresaleDatabase public database;

    // Governance
    modifier onlyOwner {
        require(
            msg.sender == database.getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(
        address database_,
        address WETH_
    ) {
        database = IPresaleDatabase(database_);
        WETH = WETH_;
    }

    /** 
        Registers `DEX_` To Use Call Associated With `dexType_`
        @param DEX - Dex To Register
        @param dexType_ - Type Of Dex | 1 - Standard | 2 - Balancer
     */
    function registerDEX(address DEX, uint8 dexType_) external onlyOwner {
        require(
            dexType_ <= 2,
            'Invalid DEX Type'
        );

        dexType[DEX] = dexType_;
    }

    // Add require that only Sales can interact with this
    function pair(
        address projectToken,
        address backingToken,
        address DEX
    ) external {
        
        // sale is caller
        address sale = msg.sender;
        address saleOwner = database.getSaleOwner(sale);

        require(
            database.isSale(sale),
            'Only Presale Can Call'
        );
        require(
            saleOwner != address(0),
            'Zero Owner'
        );
        require(
            dexType[DEX] != 0,
            'Not Approved DEX'
        );
        require(
            balanceOf(projectToken) > 0,
            'Zero Project'
        );
        require(
            balanceOf(backingToken) > 0,
            'Zero Backing'
        );

        if (dexType[DEX] == 1) {
            _pairMakingStandardCall(projectToken, backingToken, DEX, saleOwner, sale);
        } else {
            _pairMakingBalancerCall(projectToken, backingToken, DEX, saleOwner, sale);
        }
    }

    function _pairMakingStandardCall(address projectToken, address backingToken, address DEX, address projectOwner, address sale) internal {
        
        // Fetch Balances In Contract
        uint nTokens = balanceOf(projectToken);
        uint nBacking = balanceOf(backingToken);

        // Instantiate DEX
        IUniswapV2Router02 router = IUniswapV2Router02(DEX);

        // Fetch LP Token Address
        bool noPairCheck = IUniswapV2Factory(router.factory()).getPair(projectToken, backingToken) == address(0);

        // minimums
        uint256 minTokens = noPairCheck ? nTokens : 0;
        uint256 minBacking = noPairCheck ? nBacking : 0;

        // Approve Of DEX For Project Token
        IERC20(projectToken).approve(DEX, nTokens);

        // If Backing Is BNB
        if (isWETH(backingToken)) {
            // Add Liquidity
            router.addLiquidityETH{value: nBacking}(
                projectToken,
                nTokens,
                minTokens,  // ensure first creation event
                minBacking, // ensure first creation event
                address(this),
                block.timestamp + 10
            );
        } else {
            // Approve DEX For Backing Token
            IERC20(backingToken).approve(DEX, nBacking);

            // Add Liquidity
            router.addLiquidity(
                projectToken,
                backingToken,
                nTokens,
                nBacking,
                minTokens,   // ensure first creation event
                minBacking,  // ensure first creation event
                address(this),
                block.timestamp + 10
            );
        }

        // Fetch LP Token Address
        address _pair = IUniswapV2Factory(router.factory()).getPair(projectToken, backingToken);

        // handle fee and LP distribution
        _handleFeesAndDistribution(_pair, projectOwner, sale);

        // refund dust from LP pairing if any
        if (balanceOf(projectToken) > 0) {
            IERC20(projectToken).transfer(projectOwner, balanceOf(projectToken));
        }
        if (balanceOf(backingToken) > 0) {
            if (isWETH(backingToken)) {
                payable(projectOwner).transfer(balanceOf(backingToken));
            } else {
                IERC20(backingToken).transfer(projectOwner, balanceOf(backingToken));
            }
        }
    }

    function _pairMakingBalancerCall(address projectToken, address backingToken, address DEX, address projectOwner, address sale) internal {

        projectToken;
        backingToken;
        DEX;
        projectOwner;
        sale;
        dexType[projectToken] = 1;
        delete dexType[projectToken];
        
    }

    function _handleFeesAndDistribution(address _pair, address projectOwner, address sale) internal {

        // take fee out of accrued BNB and Tokens
        uint fee = database.getFee(sale);
        address receiver = database.getFeeReceiver();

        // take fee
        uint256 pairFee = IERC20(_pair).balanceOf(address(this)) * fee / 10**5;
        if (pairFee > 0 && receiver != address(0)) {
            IERC20(_pair).transfer(receiver, pairFee);
        }

        // send remaining LP tokens back to project owner
        IERC20(_pair).transfer(projectOwner, IERC20(_pair).balanceOf(address(this)));

        // give project owner a lock discount
        address locker = database.tokenLocker();
        if (locker != address(0)) {
            ITokenLocker(locker).giveDiscount(projectOwner);
        }
    }

    function isWETH(address token) public view returns (bool) {
        return token == WETH;
    }

    function balanceOf(address token) public view returns (uint256) {
        return isWETH(token) ? address(this).balance : IERC20(token).balanceOf(address(this));
    }

    receive() external payable {}
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IPresaleDatabase {
    function registerParticipation(address user, uint256 amount) external;
    function isOwner(address owner, address sale) external view returns (bool);
    function startPresale() external;
    function endPresale(uint256 amountRaised) external;
    function liquidityPairer() external view returns (address);
    function isWhitelisted(address user) external view returns (bool);
    function getHardCap(address sale) external view returns (uint256);
    function getMaxContribution(address sale) external view returns (uint256);
    function getMinContribution(address sale) external view returns (uint256);
    function getExchangeRate(address sale) external view returns (uint256);
    function getLiquidityRate(address sale) external view returns (uint256);
    function getDuration(address sale) external view returns (uint256);
    function getBackingToken(address sale) external view returns (address);
    function getPresaleToken(address sale) external view returns (address);
    function getDEX(address sale) external view returns (address);
    function isDynamic(address sale) external view returns (bool);
    function isWETH(address sale) external view returns (bool);
    function getSaleOwner(address sale) external view returns (address);
    function getFeeReceiver() external view returns (address);
    function getFee(address sale) external view returns (uint256);
    function isSale(address sale) external view returns (bool);
    function tokenLocker() external view returns (address);
    function getOwner() external view returns (address);
}