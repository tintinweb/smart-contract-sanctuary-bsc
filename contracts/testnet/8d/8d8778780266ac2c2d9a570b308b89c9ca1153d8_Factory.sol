/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// solidity // SPDX-License-Identifier: UNLICENSED
pragma solidity = 0.8.17;


// import './librares/math.sol';
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
    address public factory  = address(0x0); ////手续费地址为工厂地址

    address public tokenA   = address(0x0);
    address public tokenB   = address(0x0); 

    uint256 private reserveA;           // uses single storage slot, accessible via getReserves
    uint256 private reserveB;           // uses single storage slot, accessible via getReserves
    uint256 private blockTimestampLast; // uses single storage slot, accessible via getReserves


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
  
    constructor() payable{
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
    function initialize(address _tokenA,address _tokenB) public onlyFactory{

        require(tokenA != address(0x0) && tokenB != address(0x0) && tokenA != tokenB,'init failed!');

        tokenA = _tokenA;
        tokenB = _tokenB;

        sync();
    }
    function swap( 

        address _tokenIn,
        address _tokenOut,
        uint256 _valueIn,
        uint256 _valueOut,
        uint256 _offsetRate,//滑点，千分比
        address _to) external lock onlyFactory{
            
        require(_valueIn > 0 && _valueOut > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        require(_offsetRate >= 0 && _offsetRate <= 300);//滑点不超过30%
        require(_tokenIn    ==  tokenA || _tokenIn   ==     tokenB);
        require(_tokenOut   ==  tokenA || _tokenOut  ==     tokenB);
        require(_tokenOut   !=  _tokenIn);

        //检测充值
        uint256 _last = _tokenIn == tokenA ? reserveA : reserveB;
        require(IERC20(_tokenIn).balanceOf(address(this)) >= _last.add(_valueIn),'');


        uint    _feeRate = Factory(factory).get_fee();
        address _feeAddr = Factory(factory).get_feeAddr();

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
    function mint() external lock onlyFactory returns (bool) {
        (uint256 _reserveA, uint256 _reserveB,) = getReserves(); // gas savings
        uint256 balanceA = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceB = IERC20(tokenB).balanceOf(address(this));
        uint256 amountA = balanceA.sub(_reserveA);
        uint256 amountB = balanceB.sub(_reserveB);
        require(amountA > 0 && amountB > 0);
        //第一次添加流通性
        // if (_reserveA.mul(_reserveB) == 0) {
        //     sync();
        // }

        sync();

        emit Mint(msg.sender, amountA, amountB);

        return true;

    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to,uint256 amountA,uint256 amountB) external lock onlyFactory returns (bool) {
        (uint256 _reserveA, uint256 _reserveB,) = getReserves(); // gas savings
        uint256 balanceA = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceB = IERC20(tokenB).balanceOf(address(this));

        require(_reserveA >= amountA && _reserveB >= amountB, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        require(balanceA >= amountA && balanceB >= amountB, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        TransferHelper.safeTransfer(tokenA, to, amountA);
        TransferHelper.safeTransfer(tokenB, to, amountB);

        sync();

        emit Burn(msg.sender, amountA, amountB, to);

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
    mapping(address => bool) private mainPairToken;
    
    address[]   private allPairs;
    address     private owner;
    address     private feeAddr;

    uint      private fee = 3;//所有交易对的手续费,千分比

    event PairCreated(address indexed token0, address indexed token1, address pair);

    struct lockLog  {
        address pairAddr;
        uint256 lockA;
        uint256 lockB;
    }

    mapping(address=>mapping(address=>lockLog)) private lockList;

    constructor() payable{ owner = msg.sender;}

   
    function get_fee()public view returns (uint) {
        return fee;
    }
    function set_fee(uint _fee)public returns (bool) {
        require(_fee >= 0 && _fee <= 100);//千分比
        fee = _fee;
        return true;
    }
    function get_feeAddr()public view returns (address) {
        return feeAddr;
    }
    function set_mainPairToken(address _token,bool _status) public returns(bool) {
        mainPairToken[_token] = _status;
        return true;
    }
    function get_Pair(address tokenA, address tokenB) public view returns (address pair){
        pair = getPair[tokenA][tokenB];
    }
    // function allPairs(uint) external view returns (address pair);
    // function allPairsLength() external view returns (uint);
    function createPair(address tokenA,address tokenB) external returns(address addr){
        require(tokenA != tokenB,'');
        // require(!mainPairToken[tokenA] || !mainPairToken[tokenB],'validPairToken');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        bytes memory bytecode= type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(address(this)));

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
     //添加流动性
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA_MAX,
        uint256 amountB_MAX
    ) public returns (uint256 amountA, uint256 amountB) {
        require(amountA_MAX > 0 && amountB_MAX > 0);
        address pair = getPair[tokenA][tokenB];
        require(pair != address(0x0),'pair is null');
        (amountA, amountB) = quoteLiquidity(pair, amountA_MAX, amountB_MAX);
        require(amountA > 0 && amountB > 0);
        require(amountA_MAX >= amountA && amountB_MAX >= amountB,'Liquidity too low!');
        
        
        require(IERC20(tokenA).allowance(msg.sender,address(this)) >= amountA,'balanceA too low!');
        require(IERC20(tokenB).allowance(msg.sender,address(this)) >= amountB,'balanceB too low!');

        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);

        lockLog memory _log = lockLog(pair,amountA,amountB);
        _log.lockA = _log.lockA.add(amountA);
        _log.lockB = _log.lockB.add(amountB);

        lockList[msg.sender][pair] = _log;

        Pair(pair).mint();

    }
    //计算流通性输入量
    function quoteLiquidity(
        address pair,
        uint256 amountA_MAX,
        uint256 amountB_MAX
    ) internal virtual returns (uint256 amountA, uint256 amountB) {

        (uint256 reserveA, uint256 reserveB,) = Pair(pair).getReserves();
        //第一次加入流通池
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountA_MAX, amountB_MAX);
        } else {
            uint256 a_rate = reserveA.mul(100).div(reserveA.add(reserveB));
            uint256 b_rate = 100 - a_rate;
            amountB = amountA.mul(100).div(a_rate).mul(b_rate).div(100);
            // amountB = quote(amountA_MAX, reserveA, reserveB);
        }
    }
    //移除流通性
    function removeLiquidity(
        address tokenA,
        address tokenB
    ) public returns (uint256 amountA, uint256 amountB) {
        address pair = getPair[tokenA][tokenB];

        lockLog memory _log = lockList[msg.sender][pair];

        require(_log.lockA > 0 && _log.lockB > 0,'no lock log.');

        amountA = _log.lockA; 
        amountB = _log.lockB;

        uint256 balanceA = IERC20(tokenA).balanceOf(address(pair));
        uint256 balanceB = IERC20(tokenB).balanceOf(address(pair));
        require(balanceA >= amountA,'balance too low');
        require(balanceB >= amountB,'balance to low');

        Pair(pair).burn(msg.sender,amountA,amountB);

        _log.lockA = 0;
        _log.lockB = 0;

        lockList[msg.sender][pair] = _log;

    }
}