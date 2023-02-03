/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;


interface ITRUTHRouter {
    function factory() external view returns (address);
    function WETH() external view returns (address);

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
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external view returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external view returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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

interface ITRUTHFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getDenomFee() external view returns (uint256);
    function getSwapFee() external view returns (uint256);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

    function fetchAllPairs() external view returns (address[] memory);
}

interface ITRUTHPair {
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

contract LPSeller {

    ITRUTHRouter private constant router = ITRUTHRouter(0x39255DA12f96Bb587c7ea7F22Eead8087b0a59ae);
    ITRUTHFactory private constant factory = ITRUTHFactory(0x2c34577F8c582Ec919DCe9f5E94Cf1e83A814A1a);

    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping ( address => bool ) public ignoreToken;

    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, 'Only Owner');
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setIgnoreToken(address token, bool ignore) external onlyOwner {
        ignoreToken[token] = ignore;
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawETH() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function trigger() external {

        // fetch all LP tokens
        address[] memory tokens = fetchAllPairs();

        // for gas efficiency
        uint len = tokens.length;

        // loop through all pairs
        for (uint i = 0; i < len;) {
            
            // continue if pair is to be ignored
            if (ignoreToken[tokens[i]]) {
                unchecked { ++i; }
                continue;
            }

            // fetch both tokens from the pair
            (address token0, address token1) = fetchTokens(tokens[i]);

            if (token1 != BNB && token1 != BUSD) {
                uint balance = IERC20(token1).balanceOf(address(this));
                if (IERC20(token1).allowance(msg.sender, address(this)) >= balance) {
                    IERC20(token1).transferFrom(msg.sender, address(this), balance);
                    balance = IERC20(token1).balanceOf(address(this));
                    if (token0 == BNB) {
                        _sellForBNB(token1);
                    } else {
                        _sellForBUSD(token1);
                    }
                }
            }

            if (token0 != BNB && token0 != BUSD) {
                uint balance = IERC20(token0).balanceOf(address(this));
                if (IERC20(token0).allowance(msg.sender, address(this)) >= balance) {
                    IERC20(token0).transferFrom(msg.sender, address(this), balance);
                    balance = IERC20(token0).balanceOf(address(this));
                    if (token1 == BNB) {
                        _sellForBNB(token0);
                    } else {
                        _sellForBUSD(token0);
                    }
                }
            }

            unchecked { ++i; }
        }

        delete tokens;
    }

    function fetchTokens(address pair) public view returns (address, address) {
        return ( ITRUTHPair(pair).token0(), ITRUTHPair(pair).token1() );
    }
    
    function fetchAllPairs() public view returns (address[] memory) {
        return factory.fetchAllPairs();
    }

    function _sellForBNB(address token) internal {

        uint balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = BNB;

        IERC20(token).approve(address(router), balance);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(balance, 1, path, msg.sender, block.timestamp + 100);

        delete path;
    }

    function _sellForBUSD(address token) internal {
        
        uint balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = BUSD;

        IERC20(token).approve(address(router), balance);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(balance, 1, path, msg.sender, block.timestamp + 1000);

        delete path;
    }

    receive() external payable {}
}