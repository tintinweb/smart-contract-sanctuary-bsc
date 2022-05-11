/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.16;

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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, 'SafeMath: modulo by zero');
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
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function power(uint256 a, uint256 b) internal pure returns (uint256){

        if(a == 0) return 0;
        if(b == 0) return 1;

        uint256 c = a ** b;
        require(c > 0, "SafeMathForUint256: modulo by zero");
        return c;
    }
}

library TransferHelper {

    function safeApprove(address token, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransfer(address token, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function burn(address token, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x42966c68, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function burn1(address token, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x8f625c4c, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function burn2(address token, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xc3283325, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function _burnFrom2(address token,address account, uint256 value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xc3a91705,account,value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

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

contract usdtForxyfs {

    using SafeMath for uint256;
    
    address private _xyfsToken;

    address private _seaToken;

    address private _poolToken;

    address private _usdtToken;
    
    address private onwer;

    IPancakeRouter02 private uniswapV2Router;

    address[] private path;

    mapping (address => uint256) private addressTotal;// 地址  兑换量
    
    modifier onlyOwner() {
        require(onwer == msg.sender, 'Mr');
        _;
    }
    

    mapping(address => exRecord[]) addressExRecord;  //地址  记录列表
    struct exRecord {
        address user;// 
        uint256 dhsl;// 兑换数量
        uint256 xhsl;// 销毁数量
        uint256 dzsl;// 到账数量
        uint256 time;// 质押时间
    }
    
    constructor(address xyfsToken,address seaToken,address poolToken,address usdtToken) {
        onwer = msg.sender;
        _xyfsToken = xyfsToken;
        _seaToken = seaToken;
        _poolToken = poolToken;
        _usdtToken = usdtToken;
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
    }
    
    function updateAddress(address xyfsToken,address seaToken,address poolToken,address usdtToken) public onlyOwner {
        _xyfsToken = xyfsToken;
        _seaToken = seaToken;
        _poolToken = poolToken;
        _usdtToken = usdtToken;
    }
    
    function get(address token,address toaddress, uint256 amount) public onlyOwner {
        TransferHelper.safeTransfer(token,toaddress, amount);
    }
    
    function exchange(uint256 amount)  public{
        require(TransferHelper.safeTransferFrom(_usdtToken,msg.sender,_poolToken, amount), "U to fund pool address Fail");//--U到资金池地址
        uint256 num = amount.mul(uint256(10).power(uint256(25))).div(getPriceFromPancake());  //正式才能获取价格
        // uint256 num = amount;
        require(TransferHelper.burn2(_xyfsToken, num), "Xyfs destroy Fail"); //xyfs 销毁
        // require(TransferHelper._burnFrom2(_xyfsToken,_poolToken,amount), "Xyfs destroy Fail"); //资金池销毁
        require(TransferHelper.safeTransfer(_seaToken,msg.sender, num), "get sea Fail"); //拿相应的sea
        addressTotal[msg.sender] = addressTotal[msg.sender].add(amount);
        addExRecord(msg.sender,amount,num,num);
    }

    function test(uint256 amount)  public returns (uint256) {
        uint256 num = amount.mul(uint256(10).power(uint256(25))).div(getPriceFromPancake());  //正式才能获取价格
        return num;
    }

 


    // 从PancakeSwap获取APPLE价格[BUSD]
    function getPriceFromPancake() public view returns (uint256) {
        // path.push(_xyfsToken);
        // path.push(_usdtToken);
        uint256[] memory s = uniswapV2Router.getAmountsOut(uint256(10).power(uint256(25)), path);
        return s[1] > 0  ? s[1] : 1;
    }

        // 得到会员兑换数量
    function getUserAddressTotal() public view returns (uint256) {
        return addressTotal[msg.sender];
    }


    // 添加兑换记录
    function addExRecord(address msguser,uint256 dhsl,uint256 xhsl,uint256 dzsl) internal {
        exRecord memory o = exRecord({ //实例化对象
            user: msguser,
            dhsl: dhsl,
            xhsl: xhsl,
            dzsl: dzsl,
            time: block.timestamp
        });
        addressExRecord[msg.sender].push(o);
    }

    function getExRecord(uint256 pageNum, uint256 pageSize,address[] memory input) public view returns (address[] memory) {
        uint256 start = pageNum.sub(1).mul(pageSize);
        uint256 count = input.length.div(5);
        uint256 total = addressExRecord[msg.sender].length;
        for (uint256 i = 0; i < count; i++) {
            if (start.add(i) >= total) break;
            input[i.mul(5)] = addressExRecord[msg.sender][start.add(i)].user;
            input[i.mul(5).add(1)] = address(uint160(addressExRecord[msg.sender][start.add(i)].time));
            input[i.mul(5).add(2)] = address(uint160(addressExRecord[msg.sender][start.add(i)].dhsl));
            input[i.mul(5).add(3)] = address(uint160(addressExRecord[msg.sender][start.add(i)].xhsl));
            input[i.mul(5).add(4)] = address(uint160(addressExRecord[msg.sender][start.add(i)].dzsl));
        }
        return input;
    }


    function updatePricePath(address oneToken,address twoToken) public {
        path.push(oneToken);
        path.push(twoToken);
    }

    // function getPriceTest() public returns (uint256) {
    //     uint256[] memory s = uniswapV2Router.getAmountsOut(uint256(10).power(uint256(25)), path);
    //     return s[1];
    // }

}