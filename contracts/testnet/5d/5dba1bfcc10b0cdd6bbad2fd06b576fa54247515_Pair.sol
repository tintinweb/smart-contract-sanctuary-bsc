/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// solidity // SPDX-License-Identifier: UNLICENSED
pragma solidity = 0.8.17;

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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }

}
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
contract Pair{
    using SafeMath for uint256;
    address private factory  = address(0x0); ////手续费地址为工厂地址

    address public tokenA   = address(0x0);
    address public tokenB   = address(0x0); 

    uint256 private reserveA;           // uses single storage slot, accessible via getReserves
    uint256 private reserveB;           // uses single storage slot, accessible via getReserves
    uint256 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    mapping(address=>uint256) private liquidity_user0;
    mapping(address=>uint256) private liquidity_user1;

    event Sync(uint256 reserveA, uint256 reserveB, uint256 blockTimestampLast);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        address indexed pair,
        uint256 amountIn,
        uint256 amountOut,
        address indexed to
    );
  
    constructor(){
        factory = msg.sender;
    }
    modifier onlyFactory() {
        require(msg.sender == factory, "caller is not the factory");
        _;
    }
    //一个锁，使用该modifier的函数在unlocked==1时才可以进入，
    //第一个调用者进入后，会将unlocked置为0，此使第二个调用者无法再进入
    //执行完_部分的代码后，才会再将unlocked置1，重新将锁打开
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, ': LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    function getFactory() public view returns(address){
        return factory;
    }
    //用于获取两个代币在池子中的数量和最后更新的时间
    function getReserves() public view returns (uint256 _reserveA, uint256 _reserveB, uint256 _blockTimestampLast) {
        _reserveA = reserveA;
        _reserveB = reserveB;
        _blockTimestampLast = blockTimestampLast;
    }

    //初始代币交易对
    function initialize(address _tokenA,address _tokenB) external onlyFactory{

        tokenA = _tokenA;
        tokenB = _tokenB;

        // sync();
    }
    function swap( 
        address _tokenIn,
        address _tokenOut,
        uint256 _valueIn,
        uint256 _valueOut,
        uint256 _offsetRate,//滑点，千分比
        address _to) external lock{
            
        require(_valueIn > 0 && _valueOut > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        require(_offsetRate >= 0 && _offsetRate <= 300);//滑点不超过30%
        require(_tokenIn    ==  tokenA || _tokenIn   ==     tokenB);
        require(_tokenOut   ==  tokenA || _tokenOut  ==     tokenB);
        require(_tokenOut   !=  _tokenIn);

        //检测充值
        uint256 _last = _tokenIn == tokenA ? reserveA : reserveB;
        require(IERC20(_tokenIn).balanceOf(address(this)) >= _last.add(_valueIn),'');


        uint    _feeRate = Factory(factory).get_fee();
        address _feeAddr = address(factory);

        (uint256 _valueGet,uint256 _valueFee,uint256 _valueAll) = getAmountOut(_tokenIn , _valueIn, _feeRate);
        //滑点计算,可以多于滑点，不能少
        if(_valueOut < _valueAll){
            uint256 _offset = _valueOut.mul(_offsetRate).div(1000);
            require(_valueOut.add(_offset) >= _valueAll,'offset rate');
        }

        TransferHelper.safeTransfer(_tokenOut, _to, _valueGet);
        TransferHelper.safeTransfer(_tokenOut, _feeAddr, _valueFee);

        sync();
        emit Swap(msg.sender, address(this), _valueIn, _valueGet, _to);
    }
    // this low-level function should be called from a contract which performs important safety checks
    function addLiquidity(uint256 input_0, uint256 input_1) external lock {
        require(input_0 > 0 && input_1 > 0,"ZERO INPUT");
       
        uint256 _input_0;
        uint256 _input_1;
         //第一次加入流通池
        if (reserveA == 0 && reserveB == 0) {
            (_input_0, _input_1) = (input_0, input_1);
        } else {
            uint256 a_rate = reserveA.mul(100).div(reserveA.add(reserveB));
            uint256 b_rate = 100 - a_rate;
            _input_1 = input_1.mul(100).div(a_rate).mul(b_rate).div(100);
            _input_0 = input_0;
        }
        require(_input_1 <= input_1,"OUT OF MAX");

        TransferHelper.safeTransferFrom(tokenA, msg.sender, address(this), _input_0);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, address(this), _input_1);

        liquidity_user0[msg.sender] = liquidity_user0[msg.sender].add(_input_0);
        liquidity_user1[msg.sender] = liquidity_user1[msg.sender].add(_input_1);

        sync();

        emit Mint(msg.sender, _input_0, _input_1);

    }

    // this low-level function should be called from a contract which performs important safety checks
    function subLiquidity(address to,uint256 output_0,uint256 output_1) external lock returns (bool) {
        require(output_0 <= liquidity_user0[msg.sender]);
        require(output_1 <= liquidity_user1[msg.sender]);

        uint256 balance0 = IERC20(tokenA).balanceOf(address(this));
        uint256 balance1 = IERC20(tokenB).balanceOf(address(this));

        require(balance0 >= output_0 && balance1 >= output_1, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');

        TransferHelper.safeTransfer(tokenA, to, output_0);
        TransferHelper.safeTransfer(tokenB, to, output_1);

        sync();

        emit Burn(msg.sender, output_0, output_1, to);

        return true;
    }
     // force balances to match reserves
    function skim(address to) external lock onlyFactory{

        TransferHelper.safeTransfer(tokenA, to, IERC20(tokenA).balanceOf(address(this)).sub(reserveA));
        TransferHelper.safeTransfer(tokenB, to, IERC20(tokenB).balanceOf(address(this)).sub(reserveB));

    }
    function sync() private {

        reserveA  = IERC20(tokenA).balanceOf(address(this));
        reserveB  = IERC20(tokenB).balanceOf(address(this));

        blockTimestampLast = uint32(block.timestamp % 2**32);

        emit Sync(reserveA, reserveB, blockTimestampLast);
    }
    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(address _tokenIn,uint256 _amountIn,uint _feeRate)  public view returns (uint256 _valueGet,uint256 _valueFee,uint256 _valueAll) {
        // (100 + 1) * (2000 - N) = 100 * 2000
        // 200000 / (100 + 1) = 2000 - N
        // 2000 - 200000 / (100 + 1) = N

        if(_tokenIn == address(tokenA)){
            _valueAll = reserveB - reserveA * reserveB / (reserveA + _amountIn);
        }
        else{
            _valueAll = reserveA - reserveA * reserveB / (reserveB + _amountIn);
        }
        _valueFee = _valueAll.mul(_feeRate).div(1000);
        _valueGet = _valueAll.sub(_valueFee);
    }
}
contract Factory{
    using SafeMath for uint256;
    // 获取交易对的pair地址
    mapping(address => mapping(address => address)) private getPair;
    
    address[]   private allPairs;
    address     private owner;
    address     private feeAddr;

    uint      private fee = 3;//所有交易对的手续费,千分比

    event PairCreated(address indexed token0, address indexed token1, address pair);

    constructor() payable{ owner = msg.sender; }

    function skim(address _token,address _to)external{
        if(_token == address(0x0)){
            TransferHelper.safeTransferETH( _to, address(this).balance);
        }
        else{
            uint256 _balance = IERC20(_token).balanceOf(address(this));
            TransferHelper.safeTransfer(_token, _to, _balance);
        }
    }
   
    function get_fee()public view returns (uint) {
        return fee;
    }
    function set_fee(uint _fee)external {
        require(_fee >= 0 && _fee <= 100);//千分比
        fee = _fee;
    }
    function setFeeTo(address _feeTo) external {
        require(msg.sender == owner, 'swap: FORBIDDEN');
        feeAddr = _feeTo;
    }
    function get_feeAddr()public view returns (address) {
        return feeAddr;
    }
    function get_Pair(address tokenA, address tokenB) public view returns (address pair){
        pair = getPair[tokenA][tokenB];
    }

    function createPair(address tokenA,address tokenB) external returns(address addr){
        
        require(tokenA != tokenB,'');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        bytes memory bytecode= type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0,token1));
        assembly {
             addr := create2(
             0,
             add(bytecode,0x20),
             mload(bytecode),
             salt
          )
        }
      
        Pair(addr).initialize(token0,token1);

        getPair[token0][token1] = addr;
        getPair[token1][token0] = addr; // 双向交易对
        
        allPairs.push(addr);

        emit PairCreated(token0, token1, addr);
    
     }
}