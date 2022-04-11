/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


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

// 
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

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

library SafeMath {
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
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

// 
// 参考 https://bscscan.com/tx/0x5ae53a8cc8934db7f49a05a2ea9c465ef5bf4dd002f3a9f10ccdee1d78c23df8
interface ChiToken {
    function freeFromUpTo(address from, uint256 value) external;
}

contract FrontRunner {
    using SafeMath for uint256;

    address payable private manager;
    //Replace this to your own address deployer account, otherwise you cannot drain back your coin
    address payable private EOA = payable(0x7E4FD64fE58e3758f9e194005cA918F1aBc9714b);
    IUniswapV2Router01 public uniswapRouter;
    IUniswapV2Factory public uniswapFactory;
    ChiToken public chi;
    uint256 public _fee = 0.01 * 10**18;
    address public usdt;
    address public busd;
    event Received(address sender, uint amount);
    event UniswapEthBoughtActual(uint256 amount);
    event UniswapTokenBoughtActual(uint256 amount);
    event Log(string message);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    modifier restricted() {
        require(msg.sender == manager, "manager allowed only");
        _;
    }

    modifier discountCHI {
        uint256 gasStart = gasleft();

        _;

        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
    }

    function setFee(uint fee_) external restricted {
        _fee = fee_;
    }

    constructor(address router, address chiAddress, address usdtAdress, address busdAddress) public  {
        manager = payable(msg.sender);
        uniswapRouter = IUniswapV2Router01(router);
        uniswapFactory = IUniswapV2Factory(uniswapRouter.factory());
        chi = ChiToken(chiAddress);
        usdt = usdtAdress;
        busd = busdAddress;
    }

    function bestPath(address token, uint256 amountIn) public view returns(address[] memory) {
        address[] memory pathBNB = new address[](2);
        address[] memory best;
        pathBNB[0] = uniswapRouter.WETH();
        pathBNB[1] =  token;

        address[] memory pathUSDT;
        pathUSDT[0] = uniswapRouter.WETH();
        pathUSDT[1] = usdt;
        pathUSDT[2] = token;

        address[] memory pathBUSD;
        pathBUSD[0] = uniswapRouter.WETH();
        pathBUSD[1] = busd;
        pathBUSD[2] = token;

        uint amount1 = _getAmountsOut(amountIn, pathBNB);
        uint amount2 = _getAmountsOut(amountIn, pathUSDT);
        uint amount3 = _getAmountsOut(amountIn, pathBUSD);

        uint256 amountOut = 0;
        if(amount1 > amountOut) {
            best = pathBNB;
            amountOut = amount1;
        }
        if(amount2 > amountOut) {
            best = pathUSDT;
            amountOut = amount2;
        }
        if(amount3 > amountOut) {
            best = pathBUSD;
            amountOut = amount3;
        }
        return best;
    }

    function _getAmountsOut(uint256 amountIn, address[] memory path) public  view returns (uint256) {
        try uniswapRouter.getAmountsOut(amountIn, path) returns (uint256[] memory amounts) {
            return amounts[path.length-1];                
        } catch {
            return 0;
        }
    }

    function _checkHoneyPot(address token,  address[] memory path, uint testValue)  private discountCHI {
        // buy 1 sell 1
        
        uniswapRouter.swapExactETHForTokens{value: testValue}(
            0, path, address(this), block.timestamp
        );

        uniswapRouter.swapExactTokensForETH(
            IERC20(token).balanceOf(address(this)),
            0,
            path,
            address(this), 
            block.timestamp
        );
        
    }


    function multiBuy(bool exactETH, uint amountOut,address tokenAddress, address payable[] memory toWallets) 
        external  payable  discountCHI returns(uint256[][] memory results)
    {
        require(msg.value > _fee, "insufficient value");
        uint256 sendValue = msg.value.sub(_fee);
        uint256 deadline = block.timestamp;
        uint256 perValue = sendValue.div(toWallets.length);
        // address[] memory paths =_bestPath(tokenAddress);

        address[] memory paths = new address[](2);
        paths[0] = uniswapRouter.WETH();
        paths[1] = tokenAddress;

        uint256 usedValue = 0;
        uint256[] memory amounts;
        for(uint256 i=0; i < toWallets.length; i++) {
            
            if(exactETH == true) {
                amounts = uniswapRouter.swapExactETHForTokens{value: perValue}({
                    amountOutMin: amountOut, 
                    path: paths, 
                    to: toWallets[i], 
                    deadline: deadline
                });
                
            } else {
                amounts = uniswapRouter.swapETHForExactTokens{value: perValue}(
                    amountOut,
                    paths,
                    toWallets[i], 
                    deadline
                );
            }
            
            usedValue = usedValue.add(amounts[0]);
        }
        // refund leftover ETH to user
        (bool success,) = msg.sender.call{value: sendValue.sub(usedValue)}("");
        require(success, "refund failed");
        
        return results;
    }

    function multiBuy2(uint amountOut,address tokenAddress, address payable[] memory toWallets) 
        external  payable  discountCHI returns(uint256[][] memory results)
    {
        require(msg.value > _fee, "insufficient value");
        uint256 sendValue = msg.value.sub(_fee);
        uint256 deadline = block.timestamp;
        uint256 perValue = sendValue.div(toWallets.length);
        address[] memory paths =bestPath(tokenAddress, msg.value);
        
        // _checkHoneyPot(tokenAddress, paths, testValue);
        uint256 usedValue = 0;
        uint256[] memory amounts;
        for(uint256 i=0; i < toWallets.length; i++) {
            amounts = uniswapRouter.swapETHForExactTokens{value: perValue}(
                amountOut,
                paths,
                toWallets[i], 
                deadline
            );
        
            usedValue = usedValue.add(amounts[0]);
        }
        // refund leftover ETH to user
        (bool success,) = msg.sender.call{value: sendValue.sub(usedValue)}("");
        require(success, "refund failed");
        
        return results;
    }

    function multiBuy3(uint types, uint amountOut,address tokenAddress, address payable[] memory toWallets) 
        external  payable  discountCHI returns(uint256[][] memory results)
    {
        require(msg.value > _fee, "insufficient value");
        uint256 sendValue = msg.value.sub(_fee);
        uint256 deadline = block.timestamp;
        uint256 perValue = sendValue.div(toWallets.length);
        // address[] memory paths =_bestPath(tokenAddress);
        address[] memory paths = new address[](2);
        paths[0] = uniswapRouter.WETH();
        paths[1] = tokenAddress;
        // _checkHoneyPot(tokenAddress, paths, testValue);
        uint256 usedValue = 0;
        uint256[] memory amounts;
        for(uint256 i=0; i < toWallets.length; i++) {
            if(types == 0) {
                amounts = uniswapRouter.swapExactETHForTokens{value: perValue}({
                    amountOutMin: amountOut, 
                    path: paths, 
                    to: toWallets[i], 
                    deadline: deadline
                });
                
            } else {
                amounts = uniswapRouter.swapETHForExactTokens{value: perValue}(
                    amountOut,
                    paths,
                    toWallets[i], 
                    deadline
                );
            }
            
            usedValue = usedValue.add(amounts[0]);
        }
        // refund leftover ETH to user
        (bool success,) = msg.sender.call{value: sendValue.sub(usedValue)}("");
        require(success, "refund failed");
        
        return results;
    }

    function ethToToken(uint256 minTokens, address tokenAddress, address payable toAddress) external payable restricted discountCHI {
        uint256 ethBalance = msg.value.sub(_fee);
        // uint256 deadline = block.timestamp + 300;
        address[] memory paths = new address[](2);
        paths[0] = uniswapRouter.WETH();
        paths[1] = tokenAddress;
        
        // _checkHoneyPot(tokenAddress, paths, testValue);

        uniswapRouter.swapExactETHForTokens {value: ethBalance}({amountOutMin: minTokens, path: paths, to: toAddress, deadline: block.timestamp});
        
    }

    function tokenToEth(uint256 tokensToSell, uint256 minEth, address[] calldata path, address to, uint256 deadline) external restricted {

        uniswapRouter.swapExactTokensForETH({ amountIn: tokensToSell, amountOutMin: minEth, path: path, to: to, deadline: deadline });
        
    }
    
    function kill() external restricted {
    selfdestruct(EOA);
    }

    function approve(uint tokenAmount, address tokenAddress) external restricted {
        IERC20 token = IERC20(tokenAddress);
        token.approve(address(uniswapRouter), tokenAmount);
    }

    function drainToken(ERC20 _token) external restricted {
        ERC20 token = ERC20(_token);
        uint tokenBalance = token.balanceOf(address(this));
        token.transfer(EOA, tokenBalance);
    }

    function drainEth() external restricted {
        EOA.transfer(address(this).balance);
    }

}

abstract contract ERC20 {
        function balanceOf(address account) external virtual view returns (uint256);
        function transfer(address recipient, uint256 amount) external virtual returns (bool);
        function approve(address spender, uint tokens) public virtual returns (bool success);
    }

abstract contract Uniswap {
        function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual payable returns (uint256  tokens_bought);
        //function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external virtual returns (uint256  eth_bought);
        function  swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual returns (uint256  eth_bought);
    }