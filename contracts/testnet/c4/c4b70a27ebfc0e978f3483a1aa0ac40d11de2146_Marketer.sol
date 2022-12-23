/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;
// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
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

// File: contracts\interfaces\IPancakeRouter01.sol

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

// File: contracts\interfaces\IPancakeRouter02.sol

pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {

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

// File: contracts\interfaces\IPancakeFactory.sol

pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// File: contracts\libraries\SafeMath.sol

pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

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

// File: contracts\interfaces\IPancakePair.sol

pragma solidity >=0.5.0;

interface IPancakePair {
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

// File: contracts\libraries\PancakeLibrary.sol

pragma solidity >=0.5.0;



library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }
	

    //calculates the CREATE2 address for a pair without making any external calls

    // bscMain
    // function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
    //     (address token0, address token1) = sortTokens(tokenA, tokenB);
    //     pair = address(uint(keccak256(abi.encodePacked(
    //             hex'ff',
    //             factory,
    //             keccak256(abi.encodePacked(token0, token1)),
    //             hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
    //         ))));
    // }	

	//bscTest
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
       (address token0, address token1) = sortTokens(tokenA, tokenB);
       pair = address(uint(keccak256(abi.encodePacked(
               hex'ff',
               factory,
               keccak256(abi.encodePacked(token0, token1)),
               hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074' // init code hash
           ))));
    }
	
    // Heco
    // function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
    //     (address token0, address token1) = sortTokens(tokenA, tokenB);
    //     pair = address(uint(keccak256(abi.encodePacked(
    //             hex'ff',
    //             factory,
    //             keccak256(abi.encodePacked(token0, token1)),
    //             hex'2ad889f82040abccb2649ea6a874796c1601fb67f91a747a80e08860c73ddf24' // init code hash
    //         ))));
    // }	
	

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT[AI]');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// File: contracts\interfaces\IERC20.sol

pragma solidity >=0.5.0;

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

// File: contracts\interfaces\IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}


// File: contracts\PancakeRouter.sol

pragma solidity =0.6.6;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes memory) {
        return msg.data;
    }
}

abstract contract Ownable is Context {

	mapping(address => bool) public manager;

    event OwnershipTransferred(address indexed newOwner, bool isManager);


    constructor() public{
        _setOwner(_msgSender(), true);
    }

    modifier onlyOwner() {
        require(manager[_msgSender()], "Ownable: caller is not the owner");
        _;
    }

    function setOwner(address newOwner,bool isManager) public virtual onlyOwner {
        _setOwner(newOwner,isManager);
    }

    function _setOwner(address newOwner, bool isManager) private {
        manager[newOwner] = isManager;
        emit OwnershipTransferred(newOwner, isManager);
    }

    function withdrawStuckTokens(address token, uint256 amount) public onlyOwner {
        if(token == address(0)){
            payable(msg.sender).transfer(amount);
        }else{
            IERC20(token).transfer(msg.sender, amount);
       }
	}
}

abstract contract Swap is Ownable{
    using SafeMath for uint;

    address public factory;
    address public WETH;
    IPancakeRouter02 public pancakeRouter;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PancakeRouter: EXPIRED');
        _;
    }

    constructor() public {
        
    //bscTest
	updatePancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3,
                        0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc,
                        0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
    }

     function updatePancakeRouter(address newRouter,address newFactory,address newWETH) public onlyOwner {
        pancakeRouter = IPancakeRouter02(newRouter);
        factory =   newFactory;
        WETH    = newWETH;
    }
    
    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = PancakeLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? PancakeLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IPancakePair(PancakeLibrary.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }


    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = PancakeLibrary.sortTokens(input, output);
            IPancakePair pair = IPancakePair(PancakeLibrary.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1,) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = PancakeLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? PancakeLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure returns (uint amountB) {
        return PancakeLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
    public
    pure
    returns (uint amountOut)
    {
        return PancakeLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
    public
    pure
    returns (uint amountIn)
    {
        return PancakeLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
    public
    view
    returns (uint[] memory amounts)
    {
        return PancakeLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
    public
    view
    returns (uint[] memory amounts)
    {
        return PancakeLibrary.getAmountsIn(factory, amountOut, path);
    }

	

 
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

}


contract Marketer is Swap{

    struct vipTypeInfo{
        uint256 price;
        uint256 duration;
    }
    mapping(uint256 => vipTypeInfo) public vipType;
    mapping(address => uint256) public userEndTime;
    IERC20 public USDT;

    event BuyVip(address user, uint256 typeId, uint256 price, uint256 duration, uint256 endTime);

     modifier vipVerify() {
        require(userEndTime[msg.sender] >= block.timestamp, 'Permission denied');
        _;
    }

    constructor() public {
        USDT = IERC20(0x86DD9032c8c4C799855A67CB60985abB1cdFF993);

    }
    
    function buyVip(uint256 _typeId)public{
        
       require(USDT.transferFrom(msg.sender , address(this) ,vipType[_typeId].price ),"transferFrom Fail");
       uint256 startTime = userEndTime[msg.sender] > block.timestamp ? userEndTime[msg.sender] : block.timestamp;
       userEndTime[msg.sender]  = startTime.add(vipType[_typeId].duration);
       emit BuyVip(msg.sender, _typeId, vipType[_typeId].price, vipType[_typeId].duration,  userEndTime[msg.sender] );

    }

    function isVip(address user)public view returns(bool,uint256){
        return (userEndTime[user] >= block.timestamp,userEndTime[user]);
    }

    function setVipType(uint256 _typeId, uint256 _price, uint256 _duration) public onlyOwner{
        _setVipType(_typeId,_price,_duration);
    }

    function _setVipType(uint256 _typeId, uint256 _price, uint256 _duration) internal{
       vipType[_typeId].price = _price;
       vipType[_typeId].duration = _duration;
    }

    function setUserEndTime(address _user, uint256 _endTime)public onlyOwner{
        userEndTime[_user] = _endTime;
    }

    function setUsdt(address _usdt)public onlyOwner{
        USDT = IERC20(_usdt);
    }

    struct walletInfo{
        address wallet;
        uint256 bnb_balances;
        uint256 token_balances;
    }

    function getBalances(address[] calldata wallets, address token)
        external
        view
        returns ( walletInfo[] memory){

        walletInfo[] memory walletInfos = new walletInfo[](wallets.length);

        for (uint256 i = 0; i < wallets.length; i++) {
            walletInfos[i].wallet = wallets[i];
            walletInfos[i].bnb_balances = wallets[i].balance;
            walletInfos[i].token_balances = IERC20(token).balanceOf(wallets[i]);
        }
        return walletInfos;
    }


    function batchTransferForToken(address _token, address[] calldata to, uint256[] calldata amount) external vipVerify {
        IERC20 token = IERC20(_token);
        for (uint i = 0; i < to.length; i++) {
            require(token.transferFrom(msg.sender ,to[i] ,amount[i]),"transferFrom Fail");
        }
    }

    function batchTransferForEth(address[] calldata to, uint256[] calldata amount) external payable vipVerify{
        uint256 leftEth = msg.value;
        for (uint i = 0; i < to.length; i++) {
            require(leftEth >= amount[i],"Insufficient quantity");
            leftEth = leftEth.sub(amount[i]);
            payable(to[i]).transfer(amount[i]);
        }
    }

    // ETH - TOKEN || ETH - TOKENU - TOKEN
    function buyToken(address[] calldata path)external payable vipVerify{
        require(path[0] != path[1], 'INVALID_PATH');
        uint256 amountIn = msg.value;
        uint256 tokenBal = IERC20(path[1]).balanceOf(address(this));

        address tokenU = path[0];
        
        if(tokenU != WETH){
            address jumpPair = IPancakeFactory(factory).getPair(WETH, tokenU);
            require(jumpPair != address(0),"no pair to jump");            

            IWETH(WETH).deposit{value: amountIn}();
            address[] memory jumpPath = new address[](2);
            jumpPath[0] = WETH;
            jumpPath[1] = tokenU;

            uint256 tokenUBal = IERC20(tokenU).balanceOf(address(this));
            TransferHelper.safeTransfer(
                    jumpPath[0], IPancakeFactory(factory).getPair(jumpPath[0], jumpPath[1]), amountIn);
            
            _swapSupportingFeeOnTransferTokens(jumpPath, address(this));
            amountIn = IERC20(tokenU).balanceOf(address(this)).sub(tokenUBal);

        }else{
            IWETH(WETH).deposit{value: amountIn}();
        }


        TransferHelper.safeTransfer(
                    path[0], PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn);
        _swapSupportingFeeOnTransferTokens(path, address(this));
        
        uint256 tokenAmountOut =  IERC20(path[1]).balanceOf(address(this)).sub(tokenBal);
        
        address[] memory sellPath = new address[](2);
        sellPath[0] = path[1];
        sellPath[1] = path[0];
        TransferHelper.safeTransfer(
                    sellPath[0], PancakeLibrary.pairFor(factory, sellPath[0], sellPath[1]), tokenAmountOut/1000);
        _swapSupportingFeeOnTransferTokens(sellPath, msg.sender);

        IERC20(path[1]).transfer(msg.sender,  IERC20(path[1]).balanceOf(address(this)).sub(tokenBal));
        
    }

	receive() external payable {}

}