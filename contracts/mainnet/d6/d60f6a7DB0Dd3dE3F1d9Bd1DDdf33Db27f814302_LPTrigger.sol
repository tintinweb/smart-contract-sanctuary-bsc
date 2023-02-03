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

interface IFeeTo {
    function withdrawBatch(address[] calldata _tokens) external;
}

contract LPTrigger {

    ITRUTHRouter private constant router = ITRUTHRouter(0x39255DA12f96Bb587c7ea7F22Eead8087b0a59ae);
    ITRUTHFactory private constant factory = ITRUTHFactory(0x2c34577F8c582Ec919DCe9f5E94Cf1e83A814A1a);

    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    IFeeTo private constant feeTo = IFeeTo(0x8de2bc99DcB41186A0a7410B21e0FC973B601eb8);
    IFeeTo private constant feeToToo = IFeeTo(0x8970596C6733Bc1808CeC73a9fB499D84F35354D);

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

    function trigger() external payable {

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

            // determine which is BUSD or BNB
            bool buyToken0 = ( token0 == BUSD || token0 == BNB );

            // buy token0 or token1 first, unless it is BNB
            if (buyToken0) {

                if (token0 == BUSD) {

                    // buy BUSD with BNB
                    buyWithBNB(BUSD, address(this).balance / (len*2));

                    // buy token1 with less than half the BUSD
                    buyWithBUSD(token1, IERC20(BUSD).balanceOf(address(this)) * 10 / 25);
                } else {

                    // token0 is BNB, so just buy token1
                    buyWithBNB(token1, address(this).balance / (len*3));
                }

            } else {

                if (token1 == BUSD) {

                    // buy BUSD with BNB
                    buyWithBNB(BUSD, address(this).balance / (len*2));

                    // buy token0 with half the BUSD
                    buyWithBUSD(token0, IERC20(BUSD).balanceOf(address(this)) * 10 / 25);
                } else {

                    // token1 is BNB, so just buy token0
                    buyWithBNB(token0, address(this).balance / (len*3));
                }

            }

            // pair liquidity, triggering fees
            pairLiquidity(token0, token1);

            unchecked { ++i; }
        }

        // trigger both fee recipients
        _triggerBoth(tokens);

        // if any BNB is left over, refund it
        if (address(this).balance > 0) {
            (bool s,) = payable(0xb7EE8cb807eF7ef493B902b93E60f22D268355c1).call{value: address(this).balance}("");
            require(s);
        }

        // if any BUSD is left over, refund it
        if (IERC20(BUSD).balanceOf(address(this)) > 0) {
            IERC20(BUSD).transfer(0xb7EE8cb807eF7ef493B902b93E60f22D268355c1, IERC20(BUSD).balanceOf(address(this)));
        }
    }

    function triggerReceivers() external {
        
        // fetch all LP tokens
        address[] memory tokens = fetchAllPairs();

        // trigger both
        _triggerBoth(tokens);
    }

    function fetchTokens(address pair) public view returns (address, address) {
        return ( ITRUTHPair(pair).token0(), ITRUTHPair(pair).token1() );
    }
    
    function fetchAllPairs() public view returns (address[] memory) {
        return factory.fetchAllPairs();
    }

    function buyWithBNB(address token, uint amount) internal {

        address[] memory path = new address[](2);
        path[0] = BNB;
        path[1] = token;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            1, path, address(this), block.timestamp + 1000
        );
    }

    function buyWithBUSD(address token, uint256 amount) internal {
        
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = token;
        
        IERC20(BUSD).approve(address(router), amount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 1, path, address(this), block.timestamp + 1000);
    }

    function pairLiquidity(address token0, address token1) internal {

        uint amount0 = IERC20(token0).balanceOf(address(this));
        uint amount1 = IERC20(token1).balanceOf(address(this));

        if (token0 != BNB) {
            IERC20(token0).approve(address(router), amount0);
        }

        if (token1 != BNB) {
            IERC20(token1).approve(address(router), amount1);
        }

        if (token0 == BNB || token1 == BNB) {

            router.addLiquidityETH{value: address(this).balance}(
                token0 == BNB ? token1 : token0, 
                token0 == BNB ? amount1 : amount0, 
                1, 
                1, 
                0xb7EE8cb807eF7ef493B902b93E60f22D268355c1, 
                block.timestamp + 1000
            );

        } else {

            router.addLiquidity(
                token0, token1, amount0, amount1, 1, 1, 0xb7EE8cb807eF7ef493B902b93E60f22D268355c1, block.timestamp + 1000
            );

        }

    }

    function _triggerBoth(address[] memory tokens) internal {
        feeTo.withdrawBatch(tokens);
        feeToToo.withdrawBatch(tokens);
    }
    
    receive() external payable {}
}