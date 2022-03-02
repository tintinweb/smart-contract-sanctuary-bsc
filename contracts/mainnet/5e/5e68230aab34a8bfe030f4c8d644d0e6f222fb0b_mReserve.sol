/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswap {
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    //Factory
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint256);
}

interface WhaleDoge {
    function nDoges() external view returns (uint256);
    function dogeTurn() external view returns (uint256);
    function DogeAssets(uint256 _whichDogeAsset) external view returns (address);
    function treat() external view returns (uint256);
    function pct4LP() external view returns (uint256);
    function round() external view returns (uint256);
    function dogewhaleLPs(uint256 _whichLP) external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function bnbPrice() external view returns (uint256);
    function dogewhalePrice() external view returns (uint256);
    function reserveValue() external view returns (uint256);
    function DogeReserveValue() external view returns (uint256, uint256);
    function DogeReserveValueTotal() external view returns (uint256);

    function wBNBbUSD_LP() external view returns (address);
    function factory() external view returns (address);
    function router() external view returns (address);
}

contract mReserve is Context, Initializable {
    using SafeMath for uint256;
    address public deployer;
    uint public one_pct;
    address public whaledoge;

    //DEX
    address public factory;
    address public router;

    //DEX Ref
    address public wBNBLP;

    function init() external initializer {
        deployer = _msgSender();
        one_pct = 1*10**16;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    // NO TIME TO EXPLAIN, SET IT UP ===============================================================>
    /////////////////////////////////////////////////////////////////////////////////////////////////
    function setWhaleDoge_Contract_Address(address whaledoge_addy) public virtual returns (bool) {
        require (_msgSender() == deployer, "not deployer");
        whaledoge = whaledoge_addy;
        factory = WhaleDoge(whaledoge).factory();
        router = WhaleDoge(whaledoge).router();
        return true;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    // MATH FUNCTIONS ==============================================================================>
    /////////////////////////////////////////////////////////////////////////////////////////////////
    function _pct(uint _value, uint _percentageOf) internal virtual returns (uint256 res) {
        res = (_value * _percentageOf) / 10 ** 18;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // RESERVE MANAGEMENT FUNTIONS ==============================================================================>
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function SwapToBNB(address _reserveManager) public virtual returns (uint256) {
        require(_msgSender() == whaledoge, "Only Contract");
        address[] memory path = new address[](2);
        path[0] = whaledoge;
        path[1] = IUniswap(router).WETH();

        address LP = IUniswap(factory).getPair(path[0], path[1]);

        uint amountIn = _pct(IERC20(whaledoge).balanceOf(address(this)), one_pct * (100-(WhaleDoge(whaledoge).pct4LP() / 2)));
        // uint amountIn = IERC20(path[0]).balanceOf(address(this));
        uint amountOut = IUniswap(router).getAmountOut(amountIn, IERC20(path[0]).balanceOf(LP), IERC20(path[1]).balanceOf(LP));
        uint amountOutMin = amountOut - _pct(amountOut, 5*10**16);

        IERC20(path[0]).approve(router, amountIn);
        IUniswap(router).swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), block.timestamp+120);

        //Reward the Reserve Manager

        //grabs the treat without basis from dogewhale contract and places it into basis, and executes getAmountOut to the LP BUSD WBNB to get how much bnb $20 is at the time of calling
        uint256 reward = IUniswap(router).getAmountOut(WhaleDoge(whaledoge).treat()*10**18, IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).balanceOf(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16), IERC20(path[1]).balanceOf(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16));

        if (IERC20(path[1]).balanceOf(address(this)) >= reward*3) {
            // IERC20(path[1]).approve(_msgSender(), amountIn);
            IERC20(path[1]).transfer(_reserveManager, reward);
        }
        return reward;
    }

    function addLiquidity(address whichLP) external returns (bool) {
        require(_msgSender() == whaledoge, "Only Contract");

        uint256 reserveWhaleDogeBalance = IERC20(whaledoge).balanceOf(address(this));
        address wethAddy = IUniswap(router).WETH();
        address flexRouter = address(0);

        if (whichLP == 0x1815AA745e84a560F5B02f0829c5b015aE814224) {
            flexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (whichLP == 0x4cc004270DF47931C9D23501461AbfFa27a4A4f6) {
            flexRouter = 0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7;
        }

        uint amountBDesired = IUniswap(flexRouter).getAmountOut(reserveWhaleDogeBalance, IERC20(whaledoge).balanceOf(whichLP), IERC20(wethAddy).balanceOf(whichLP));
        IERC20(whaledoge).approve(flexRouter, reserveWhaleDogeBalance);
        IERC20(wethAddy).approve(flexRouter, amountBDesired);
        IUniswap(flexRouter).addLiquidity(whaledoge, wethAddy, reserveWhaleDogeBalance, amountBDesired, 0, 0, whaledoge, block.timestamp+120);
        return true;
    }

    function SwapToDOGEs(address doge2get) public virtual returns (bool){
        require(_msgSender() == whaledoge, "Only Contract");
        address[] memory path = new address[](2);
        path[0] = IUniswap(router).WETH();
        path[1] = doge2get;

        address LP = IUniswap(factory).getPair(path[0], path[1]);
        uint amountIn = IERC20(path[0]).balanceOf(address(this));
        uint amountOut = IUniswap(router).getAmountOut(amountIn, IERC20(path[0]).balanceOf(LP), IERC20(path[1]).balanceOf(LP));

        if (doge2get == 0xfb5B838b6cfEEdC2873aB27866079AC55363D37E) {
            //return true;
            uint256 slippage = 8*10**16;
            uint amountOutMin = amountOut - _pct(amountOut, slippage);
            IERC20(path[0]).approve(router, amountIn);
            IUniswap(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, whaledoge, block.timestamp+120);
        } else {
            uint256 slippage = 2*10**14;
            uint amountOutMin = amountOut - _pct(amountOut, slippage);
            IERC20(path[0]).approve(router, amountIn);
            IUniswap(router).swapExactTokensForTokens(amountIn, amountOutMin, path, whaledoge, block.timestamp+120);
        }

        return true;
    }
}