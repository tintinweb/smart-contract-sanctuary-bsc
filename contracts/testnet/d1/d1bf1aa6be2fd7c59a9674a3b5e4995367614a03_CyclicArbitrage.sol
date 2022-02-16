/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

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


interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract CyclicArbitrage{
    using SafeMath for uint;
    address _owner;

    constructor () public {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function get_token(address tokenAddress) external onlyOwner{
        uint balance0 = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, balance0);
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function getReserves(address pair, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountsOut(address pair, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(pair, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsOutV2(address[] memory pairs, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < pairs.length; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(pairs[i], path[2*i], path[2*i + 1]);
            amounts[2*i + 1] = getAmountOut(amounts[2*i], reserveIn, reserveOut);
            if(i != pairs.length-1){
                amounts[2*i + 2] = amounts[2*i + 1];
            }
        }
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function _swap(uint[] memory amounts,address pair, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? pair : _to;
            IUniswapV2Pair(pair).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    function cyclic(//0xF98F6C94408Df5Bf1697d36281e07e154dB77837
        uint amountIn,
        address[] calldata pair,
        address[] calldata paths
    ) external onlyOwner returns (uint[] memory amounts) {
        uint amountInPath = amountIn;
        for(uint i; i < pair.length; i++){
            address[] memory path = new address[](2);
            path[0] = paths[i*2];
            path[1] = paths[i*2+1];
            amounts = getAmountsOut(pair[i], amountInPath, path);
            if(i == pair.length-1){
                require(amounts[amounts.length - 1] >= amountIn, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
            }
            if(i==0){
                safeTransferFrom(path[0], msg.sender, pair[i], amounts[0]);
            }
            address _to = i < pair.length-1 ? pair[i+1] : msg.sender;
            _swap(amounts, pair[i], path, _to);
            amountInPath = amounts[amounts.length - 1];
        }
    }

    function cyclicV2(//0x7c7792273869226D74281C5E768f6238bb4A66A4
        uint amountIn,
        address[] calldata pairs,
        address[] calldata paths
    ) external onlyOwner returns (uint[] memory amounts) {
        amounts = getAmountsOutV2(pairs,amountIn,paths);
        require(amounts[amounts.length - 1] >= amountIn, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');

        safeTransferFrom(paths[0], msg.sender, pairs[0], amountIn);
        for(uint i; i < pairs.length; i++){
            address[] memory path = new address[](2);
            path[0] = paths[i*2];
            path[1] = paths[i*2+1];
            uint[] memory tempAmounts = new uint[](2);
            tempAmounts[0] = amounts[i*2];
            tempAmounts[1] = amounts[i*2+1];
            address _to = i < pairs.length-1 ? pairs[i+1] : msg.sender;
            _swap(tempAmounts, pairs[i], path, _to);
        }
    }

    function swap_routers( //0x09f8e8bc5f241841c51a6872cf7ae578f758e87b 0xf1bd56862d18d7678916458286469d6728012440  0x9b72f4F388064a098962573a4FBc91EdCd6D2880 0xb1f49c2F4235858e9757A7F97cdb27De8821C086
        uint[] calldata value,
        address[] calldata routerAddrs, 
        address[] calldata pairs, 
        address[] calldata paths
    ) external onlyOwner returns (uint[] memory amounts) {
        amounts = getAmountsOutV2(pairs,value[0],paths);
        if(value[1] >= 1){
            emit monitorTokenAmounts(value[1], amounts);
            return amounts;
        }
        require(amounts[amounts.length - 1] >= value[0], 'cyclic: INSUFFICIENT_OUTPUT_AMOUNT');
        uint aimTokenReserved = IERC20(paths[0]).balanceOf(address(this));
        if(value[2] >= 1){
            emit monitorTokenAmounts(value[2], amounts);
            return amounts;
        }
        for(uint i=0; i<routerAddrs.length; i++){
            address[] memory path = new address[](2);
            path[0] = paths[i*2];
            path[1] = paths[i*2+1];
            uint allowanceAmounts = IERC20(path[0]).allowance(address(this),routerAddrs[i]);
            if(allowanceAmounts < 100000000000000000000000){
                IERC20(path[0]).approve(routerAddrs[i], 115792089237316195423570985008687907853269984665640564039457584007913129639935);
            }
            uint[] memory tempAmounts;
            if(i == 0){
                tempAmounts = IPancakeRouter02(routerAddrs[i]).swapExactTokensForTokens(value[0], amounts[2*i + 1], path, address(this), block.timestamp);
                if(value[3] >= 1){
                    emit monitorTokenAmounts(value[3], tempAmounts);
                    return amounts;
                }
            }else{
                tempAmounts = IPancakeRouter02(routerAddrs[i]).swapExactTokensForTokens(IERC20(path[0]).balanceOf(address(this)), amounts[2*i + 1], path, address(this), block.timestamp);
                if(value[4] >= 1){
                    emit monitorTokenAmounts(value[4], tempAmounts);
                    return amounts;
                }
            }
            if(value[5] >= 1){
                emit monitorTokenAmounts(value[5], tempAmounts);
                return amounts;
            }
        }
        require(IERC20(paths[0]).balanceOf(address(this)) > aimTokenReserved,'valueOut less than valueIn');
    }

    function swap_routers_simply( //0x09f8e8bc5f241841c51a6872cf7ae578f758e87b 0xf1bd56862d18d7678916458286469d6728012440  0x9b72f4F388064a098962573a4FBc91EdCd6D2880 0xb1f49c2F4235858e9757A7F97cdb27De8821C086
        uint value,
        address[] calldata routerAddrs, 
        address[] calldata pairs, 
        address[] calldata paths
    ) external onlyOwner () {
        // amounts = getAmountsOutV2(pairs,value,paths);
        // require(amounts[amounts.length - 1] >= value, 'cyclic: INSUFFICIENT_OUTPUT_AMOUNT');
        
        uint aimTokenReserved = IERC20(paths[0]).balanceOf(address(this));
        for(uint i=0; i<routerAddrs.length; i++){
            address[] memory path = new address[](2);
            path[0] = paths[i*2];
            path[1] = paths[i*2+1];
            uint allowanceAmounts = IERC20(path[0]).allowance(address(this),routerAddrs[i]);
            if(allowanceAmounts < 100000000000000000000000){
                IERC20(path[0]).approve(routerAddrs[i], 115792089237316195423570985008687907853269984665640564039457584007913129639935);
            }
            if(i == 0){
                IPancakeRouter02(routerAddrs[i]).swapExactTokensForTokens(value, 0, path, address(this), block.timestamp);
            }else{
                IPancakeRouter02(routerAddrs[i]).swapExactTokensForTokens(IERC20(path[0]).balanceOf(address(this)), 0, path, address(this), block.timestamp);
            }
        }
        require(IERC20(paths[0]).balanceOf(address(this)) > aimTokenReserved,'valueOut less than valueIn');
    }

    event monitorTokenAmounts(uint tag,uint[] amounts);
}



/*
入参是：value、pair和path
value：需要输入的值
pair和path，则是对应的值，
*/