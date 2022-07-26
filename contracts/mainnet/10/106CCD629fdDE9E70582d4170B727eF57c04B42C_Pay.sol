/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity ^0.6.12;
interface ERC20 {
 function balanceOf(address tokenOwner) external view returns (uint balance);
 function approve(address spender, uint tokens) external returns (bool success);
 function transferFrom(address from, address to, uint tokens) external returns (bool success);
function burn(uint256 amount) external ;
function transfer(address to, uint tokens) external returns (bool success);
}
contract owned {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner,"Caller is not owner");
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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
contract Pay is owned{
    using SafeMath for uint256;
    address private address1;
    address private address2;
    ERC20   private erc20Token;
    ERC20   private erc20Token1;
    ERC20   private erc20Token2;
    ERC20   private erc20Token3;
    ERC20   private erc20Token4;
    ERC20   private erc20Token5;
    ERC20   private muktoken;
    address private wallet1;
    address private wallet2;
    address private wallet3;
    address private wallet4;
    address private wallet5;
    address private wallet6;
    address private swapAddress; 

    IUniswapV2Router02 public immutable uniswapV2Router;

    constructor() public {

        erc20Token = ERC20(0x55d398326f99059fF775485246999027B3197955);
        erc20Token1 = ERC20(0x7087e081E03Ff23186AE8631590Bf9639495e3Bb);
        erc20Token2 = ERC20(0xfff08a69464f455eA95eA4252f2a31a7Cb470eCC);
        erc20Token3 = ERC20(0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153);
        erc20Token4 = ERC20(0x41515885251e724233c6cA94530d6dcf3A20dEc7);
        erc20Token5 = ERC20(0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A);
        muktoken = ERC20(0xcB1fB6DD943BFF519e2FF6F3C0B38E81ac381603);
        swapAddress = address(0x59980F3A63D1D86745ffeE845d6aFE18fD8c8D37);
        wallet1 = address(0x5Ce3191ED640c161e00Fc282f5D20505De298f46);
        wallet2 = address(0x6BCF549e5D8C4c1A51c138B9757E91537aD2dbc0);
        wallet3 = address(0xE33569BCFcd5F0d2f6E1c97E85Ad543423e7E81B);
        wallet4 = address(0x412d365667B8c4fFF53399803d1Ea40eE7dAAe53);
        wallet5 = address(0xd2051134C66107CEa4DDB79103FC990095c5B1B7);
        wallet6 = address(0xcBA288b8064218095033A41f8834c9AA42403e4E);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

    }

    function pay1(uint256 amount1,uint256 amount2,uint256 amount3) public {
        erc20Token.transferFrom(msg.sender,swapAddress,amount1);
        //distributer
        erc20Token1.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token1.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token1.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token1.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));
        
        muktoken.transferFrom(msg.sender,wallet1,amount3.mul(60).div(100));
        muktoken.transferFrom(msg.sender,wallet5,amount3.mul(10).div(100));
        muktoken.transferFrom(msg.sender,wallet6,amount3.mul(1).div(100));
        //burn
        muktoken.transferFrom(msg.sender,address(1),amount3.mul(29).div(100));

    }
    function pay2(uint256 amount1,uint256 amount2,uint amount3) public {
        erc20Token.transferFrom(msg.sender,swapAddress,amount1);
        //distributer
        erc20Token2.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token2.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token2.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token2.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));

        muktoken.transferFrom(msg.sender,wallet1,amount3.mul(60).div(100));
        muktoken.transferFrom(msg.sender,wallet5,amount3.mul(10).div(100));
        muktoken.transferFrom(msg.sender,wallet6,amount3.mul(1).div(100));
        //burn
        muktoken.transferFrom(msg.sender,address(1),amount3.mul(29).div(100));
    }
    function pay3(uint256 amount1,uint256 amount2,uint256 amount3) public {
        erc20Token.transferFrom(msg.sender,swapAddress,amount1);
        //distributer
        erc20Token3.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token3.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token3.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token3.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));

        muktoken.transferFrom(msg.sender,wallet1,amount3.mul(60).div(100));
        muktoken.transferFrom(msg.sender,wallet5,amount3.mul(10).div(100));
        muktoken.transferFrom(msg.sender,wallet6,amount3.mul(1).div(100));
        //burn
        muktoken.transferFrom(msg.sender,address(1),amount3.mul(29).div(100));
    }
    function pay4(uint256 amount1,uint256 amount2,uint256 amount3) public {
        erc20Token.transferFrom(msg.sender,swapAddress,amount1);
        //distributer
        erc20Token4.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token4.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token4.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token4.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));
        
        muktoken.transferFrom(msg.sender,wallet1,amount3.mul(60).div(100));
        muktoken.transferFrom(msg.sender,wallet5,amount3.mul(10).div(100));
        muktoken.transferFrom(msg.sender,wallet6,amount3.mul(1).div(100));
        //burn
        muktoken.transferFrom(msg.sender,address(1),amount3.mul(29).div(100));
    }
    function pay5(uint256 amount1,uint256 amount2,uint256 amount3) public {
        erc20Token.transferFrom(msg.sender,swapAddress,amount1);
        //distributer
        erc20Token5.transferFrom(msg.sender,wallet1,amount2.mul(65).div(100));
        erc20Token5.transferFrom(msg.sender,wallet2,amount2.mul(13).div(100));
        erc20Token5.transferFrom(msg.sender,wallet3,amount2.mul(12).div(100));
        erc20Token5.transferFrom(msg.sender,wallet4,amount2.mul(10).div(100));
        
        muktoken.transferFrom(msg.sender,wallet1,amount3.mul(60).div(100));
        muktoken.transferFrom(msg.sender,wallet5,amount3.mul(10).div(100));
        muktoken.transferFrom(msg.sender,wallet6,amount3.mul(1).div(100));
        //burn
        muktoken.transferFrom(msg.sender,address(1),amount3.mul(29).div(100));
    }
    function _approve(address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        erc20Token.approve(spender,amount);
    }
    function burnERC20Token() public onlyOwner {
        uint256 contractSwapTokenBalance = muktoken.balanceOf(address(this));
        muktoken.burn(contractSwapTokenBalance);
    }
    function transferERC20Token(address recipient) public onlyOwner {
        uint256 contractSwapTokenBalance = muktoken.balanceOf(address(this));
        muktoken.transfer(recipient,contractSwapTokenBalance);
    }
    function transferUsdtToken(address recipient) public onlyOwner {
        uint256 contractSwapTokenBalance = erc20Token.balanceOf(address(this));
        erc20Token.transfer(recipient,contractSwapTokenBalance);
    }
}