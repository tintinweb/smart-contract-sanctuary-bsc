/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{ value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value : weiValue}(data);
        if (success) {
            return returndata;
        } else {

            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address public _owner;
    constructor(){
        _owner=_msgSender();
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

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

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

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

contract UniswapHelper is Context, Ownable {

    using SafeMath for uint256;
    using Address for address;

    constructor () {
    }
    event approve1(address addressIn,address router,uint amountIn);
    event buyToken1(uint amountIn, uint amountOutMin, address[] path, address to, uint deadline);

    // //兑换token
    // function buyToken(uint amountIn,address[] calldata addresses, address router, uint256 maxFee) external payable returns (uint[] memory amounts){
    //     require(maxFee<=50&&maxFee>=0,"the maxFee error");
    //     uint _amountOut=getSwapTokenPrice(amountIn,addresses[0],addresses[1],router);
    //     IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
    //     if(addresses[0]==_uniswapV2Router.WETH()){
    //         amounts=_uniswapV2Router.swapExactETHForTokens(_amountOut.mul(100-maxFee).div(100),addresses,_msgSender(),block.timestamp);
    //     }else if(addresses[1]==_uniswapV2Router.WETH()){
    //         amounts=_uniswapV2Router.swapExactTokensForETH (amountIn,_amountOut.mul(100-maxFee).div(100),addresses,_msgSender(),block.timestamp);
    //     }else{
    //         amounts=_uniswapV2Router.swapExactTokensForTokens(amountIn,_amountOut.mul(100-maxFee).div(100),addresses,_msgSender(),block.timestamp);
    //     }
    // }
    function approve(uint amountIn, address[] calldata addresses, address router) external {
        IERC20(addresses[0]).approve(address(router), amountIn);
        emit approve1(addresses[0],router,amountIn);
    }
    //兑换token
    function buyToken(uint amountIn,address[] calldata addresses, address router, uint256 maxFee) external{
        require(maxFee<=50&&maxFee>=0,"the maxFee error");
        uint _amountOut=getSwapTokenPrice(amountIn,addresses[0],addresses[1],router);
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        // if(addresses[0]==_uniswapV2Router.WETH()){
        //     amounts=_uniswapV2Router.swapExactETHForTokens(_amountOut.mul(100-maxFee).div(100),addresses,_msgSender(),block.timestamp);
        // }else if(addresses[1]==_uniswapV2Router.WETH()){
            emit buyToken1(amountIn,_amountOut.mul(100-maxFee).div(100),addresses,_msgSender(),block.timestamp);
            // amounts=_uniswapV2Router.swapExactTokensForETH (amountIn,_amountOut.mul(100-maxFee).div(100),addresses,_msgSender(),block.timestamp);
        // }else{
        //     amounts=_uniswapV2Router.swapExactTokensForTokens(amountIn,_amountOut.mul(100-maxFee).div(100),addresses,_msgSender(),block.timestamp);
        // }
    }

    //获取池子详情 tokenA、B剩余量以及最后一次交易时间
    function getReserves(address tokenA, address tokenB, address router) external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast){
        require(tokenA!=address(0),"the tokenA error");
        require(tokenB!=address(0),"the tokenB error");
        require(router!=address(0),"the router error");
        (reserve0,reserve1,blockTimestampLast) = IUniswapV2Pair(getPairAddress(tokenA,tokenB,router)).getReserves();
    }

    //获取单价 入场tokenA：amountA  出场tokenB最多获得amountOut
    function getSwapTokenPrice(uint256 amountA,address tokenA, address tokenB, address router) public view returns(uint amountOut){
        require(amountA>0,"the amountA error");
        require(tokenA!=address(0),"the tokenA error");
        require(tokenB!=address(0),"the tokenB error");
        require(router!=address(0),"the router error");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint[] memory amounts=_uniswapV2Router.getAmountsOut(amountA,path);
        amountOut = amounts[1];
    }
    //获取池子地址
    function getPairAddress(address tokenA, address tokenB, address router) public view returns (address pair){
        require(tokenA!=address(0),"the tokenA error");
        require(tokenB!=address(0),"the tokenB error");
        require(router!=address(0),"the router error");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(tokenA, tokenB);
        require(pair!=address(0),"the pair no create");
    }
    // //获取价格
    // function getTokenPrice(uint256 amountA,address tokenA, address tokenB, address router) external view returns(uint256 amountOut){
    //     require(amountA>0,"the amountA error");
    //     require(tokenA!=address(0),"the tokenA error");
    //     require(tokenB!=address(0),"the tokenB error");
    //     require(router!=address(0),"the router error");
    //     IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
    //     address pair=getPairAddress(tokenA,tokenB,router);
    //     uint256 reserveA = IERC20(tokenA).balanceOf(pair);
    //     uint256 reserveB = IERC20(tokenB).balanceOf(pair);
    //     amountOut = _uniswapV2Router.quote(amountA,reserveA,reserveB);
    // }
}