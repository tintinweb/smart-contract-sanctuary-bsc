/**
 *Submitted for verification at BscScan.com on 2022-04-16
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
	
	//bscTest
    //calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
       (address token0, address token1) = sortTokens(tokenA, tokenB);
       pair = address(uint(keccak256(abi.encodePacked(
               hex'ff',
               factory,
               keccak256(abi.encodePacked(token0, token1)),
               hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074' // init code hash
           ))));
    }
	
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner,isManager);
    }

    function _setOwner(address newOwner, bool isManager) private {
        manager[newOwner] = isManager;
        emit OwnershipTransferred(newOwner, isManager);
    }
}

contract MyContract is IPancakeRouter02, Ownable{
    using SafeMath for uint;

    address public immutable override factory;
    address public immutable override WETH;
    //address public TETH;

    event isProfitable(bool _status);

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PancakeRouter: EXPIRED');
        _;
    }

    constructor() public {

        // bscMain
        // factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
        // WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
		
        
        //bscTest
        factory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
        WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

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
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = PancakeLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT[E_T_F_T]');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = PancakeLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'PancakeRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'PancakeRouter: INVALID_PATH');
        amounts = PancakeLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT[E_E_F_T]');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'PancakeRouter: INVALID_PATH');
        amounts = PancakeLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'PancakeRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'PancakeRouter: INVALID_PATH');
        amounts = PancakeLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT[E_T_F_E]');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'PancakeRouter: INVALID_PATH');
        amounts = PancakeLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'PancakeRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT[E_T_F_T.]'
        );
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    virtual
    override
    payable
    ensure(deadline)
    {
        require(path[0] == WETH, 'PancakeRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT[E_T_F_T.]'
        );
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    virtual
    override
    ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'PancakeRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT[E_T_F_E.]');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return PancakeLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
    public
    pure
    virtual
    override
    returns (uint amountOut)
    {
        return PancakeLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
    public
    pure
    virtual
    override
    returns (uint amountIn)
    {
        return PancakeLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
    public
    view
    virtual
    override
    returns (uint[] memory amounts)
    {
        return PancakeLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
    public
    view
    virtual
    override
    returns (uint[] memory amounts)
    {
        return PancakeLibrary.getAmountsIn(factory, amountOut, path);
    }

    function sellAll(address[] calldata path, address from, address to, uint deadline)
    external
    virtual
    ensure(deadline) {
	
        //require(path[path.length - 1] == WETH, 'PancakeRouter: INVALID_PATH');
		
        uint amountIn = IERC20(path[0]).balanceOf(from);
        require(amountIn > 0, 'Super clip: no tokens to sell');//没有可售出代币
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
        if(from == address(this)){
            TransferHelper.safeTransfer(
            path[0], PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn
            );
        }else{
            TransferHelper.safeTransferFrom(
                path[0], from, PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn
            );
        }
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
		
		
        if(to != address(this)){
            TransferHelper.safeTransfer(path[path.length - 1],to, amountOut);
        }
		
    }


    function sellRate(address[] memory path, address from, address to, uint rate ,uint deadline)
    public
    ensure(deadline) {
	
        //require(path[path.length - 1] == WETH, 'PancakeRouter: INVALID_PATH');
		
        uint amountIn = IERC20(path[0]).balanceOf(from);
        amountIn = amountIn * rate / 10000;
        require(amountIn > 0, 'Super clip: no tokens to sell');//没有可售出代币
		
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
        if(from == address(this)){
            TransferHelper.safeTransfer(
            path[0], PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn
            );
        }else{
            TransferHelper.safeTransferFrom(
                path[0], from, PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn
            );
        }
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
		
		if(to != address(this)){
            TransferHelper.safeTransfer(path[path.length - 1],to, amountOut);
        }
    }

    struct Order {
        uint buyAmountIn;
        uint buyAmountOutMin;
        uint slipPoint;
        uint transactionFee;
    }

    struct Payoff{
        uint amountIn;
        uint p;
        uint amountOutMin;
        bool isP;

    }

    function clipBuy(
        Order calldata order,
        address[] calldata path,
        uint deadline,
        address bUser,
        uint bBal
    )
    external
    virtual
    payable
    ensure(deadline)
    {
		
		// 两个path不能相同
        require(path[0] != path[1], 'PancakeRouter: INVALID_PATH');
		
		// 获取 夹子交易 的 amountIn 和  amountOutMin
        (Payoff memory payoff , uint currentbBal) = checkBuyAmountIn(order, path, bUser);
        
        require(bBal == currentbBal, 'PancakeRouter: TOO_SLOW');
        
		if(payoff.isP){
           
            // 给交易对合约转 amountIn 数量的 path[0] TOKEN
            assert(IERC20(path[0]).transfer(PancakeLibrary.pairFor(factory, path[0], path[1]),payoff.amountIn));
            
            // 获取目前有多少TOKEN
            uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
            
            // 交换TOKEN
            _swapSupportingFeeOnTransferTokens(path, address(this));
            
            //判断得到的 是否满足 最小接受代币数量
            require(
                IERC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore) >= payoff.amountOutMin,
                'PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT[B]'
            );
			
			
            address[] memory sellPath = new address[](2);
            sellPath[0] = path[1];
            sellPath[1] = path[0];
            sellRate(sellPath,address(this),address(this),1,deadline);
        }

    }


    //baseCoinAddress：WETH合约
    //contractAddress: 代币合约
    //buyAmountIn: 被夹交易的买入金额
    //buyAmountOutMin: 被夹交易的得到代币的最小数量
    //slipPoint: 代币的滑点
    //gas：gas最大费用
    //仅用于同池子


    // out  夹子交易 的 amountIn 和  amountOutMin
    // a 大单最低获得的token数量
    // d 夹子机器人 weth成本
    // p 夹子机器人预计收益  当收益大于成本 才会盈利

    
    function checkBuyAmountIn(
        Order memory order,
        address[] memory path,
        address bUser
        )
    public view returns (Payoff memory payoff , uint bBal) {
        bBal = IERC20(path[1]).balanceOf(bUser);

		// 获取交易对地址 和 流动性
        address pair = PancakeLibrary.pairFor(factory, path[0], path[1]);
        uint poolValue = IERC20(path[0]).balanceOf(pair);//流动性
        uint tokenValue = IERC20(path[1]).balanceOf(pair);//代币流动性

        //夹子最大买入  WETH数量
        (payoff.amountIn, payoff.p, ,payoff.amountOutMin,) = check(path,poolValue, tokenValue, order.buyAmountIn,order.buyAmountOutMin,order.slipPoint);

        //可以盈利
        if(payoff.p > payoff.amountIn.add(order.transactionFee * 2)){
            payoff.isP = true;
        }
       
       
    }

	//夹子最大买入  WETH数量
	//poolValue 池子WETH的数量
	//tokenValue 池子TOKEN的数量
	//buyAmountIn: 被夹交易的买入金额
	//buyAmountOutMin: 被夹交易的得到代币的最小数量
    //slipPoint: 代币的滑点
	//a: 大单本身能得到数量
	//d: 夹子最大买入 WETH数量
    //e： 夹子得到的Token数量
    //f：夹子实际得到的 token数量(去掉滑点)
    //g：夹子实际卖出的 token数量(去掉滑点)
    //p: 最终利润
	
    function check(address[] memory path , uint poolValue, uint tokenValue, uint buyAmountIn, uint buyAmountOutMin,  uint slipPoint) public view returns (uint amountIn,uint p,uint b,uint amountOutMin ,uint k) {
        		
        
		uint a;
        // 获取夹子可买入的 WETH数量, 交易的Token数量， 实际得到的Token数量   
        (amountIn,k,a,b) = libraryAmountCheck(path,poolValue,  tokenValue,  buyAmountIn, buyAmountOutMin);      

         //夹子实际得到的  token数量
        amountOutMin = slipPointCheck(b, slipPoint);
        //夹子实际可以卖出的 token数量
        uint g = slipPointCheck(amountOutMin, slipPoint);
        
        uint i = tokenValue.sub(a).sub(b); //池子Token代币
        uint h = poolValue.add(buyAmountIn); //池子WETH代币
        h = h.add(amountIn);
        
        p = PancakeLibrary.getAmountOut(g, i, h);//卖出能得到多少WETH
        
    }
	
	//卖出能得到多少
	//poolValue 池子WETH的数量
	//tokenValue 池子TOKEN的数量
	//buyAmountIn: 被夹交易的买入金额
	//buyAmountOutMin: 被夹交易的得到代币的最小数量
    //slipPoint: 代币的滑点
	//d: 夹子最大买入 WETH数量
	//a: 大单本身能得到Token数量
	//e： 夹子得到的Token数量
	//j: 薄饼的扣税
	//k：夹子买之后 大单可买入的数量
    //f：夹子实际得到的 token数量
    //g：夹子实际卖出的 token数量
    //p: 最终利润

    function libraryAmountCheck(address[] memory path, uint poolValue, uint tokenValue, uint buyAmountIn, uint buyAmountOutMin) public view returns (uint d, uint k,uint a, uint b) {
        a = PancakeLibrary.getAmountOut(buyAmountIn, poolValue, tokenValue);
        require(a > buyAmountOutMin, 'PancakeRouter: insufficient trading profit[1]');//没有可操作的利润	
        uint currentB = a.sub(buyAmountOutMin); 
       //计算购买滑点利差 需要的ETH数量     并验证大单是否会失败
       // 10000×40×0.2  /  10000-2000
        uint256 currentPoolValue = poolValue;
        uint256 currentTokenValue = tokenValue;

        uint currentD;
        uint currentK;
		
		
		

        for(uint i = 1; i < 21; i++){

            currentD = PancakeLibrary.getAmountIn(currentB.mul(i), poolValue, tokenValue);

            

            currentPoolValue = poolValue.add(currentD);
            currentTokenValue = tokenValue.sub(currentB.mul(i));            

            //lastE = PancakeLibrary.getAmountOut(currentD, poolValue, tokenValue);
            currentK = PancakeLibrary.getAmountOut(buyAmountIn, currentPoolValue, currentTokenValue);

             // 判断大单是否能买进  和合约余额够不够 提前调出循环
            if(currentK > buyAmountOutMin && IERC20(path[0]).balanceOf(address(this)) >= currentD){
                b = currentB.mul(i);
                d = currentD;
                k = currentK;
                //e = lastE;               
               
            }else{
                break;
            }
        }



        require(d > 0,'PancakeRouter: insufficient trading profit[2]');
        require(k > buyAmountOutMin, 'PancakeRouter:Large order transactions will fail');

    }
	
	//夹子实际得到数量 （滑点的数量）
    function slipPointCheck(uint amount, uint slipPoint) internal pure returns (uint) {
        if( slipPoint == 0){
            return amount;
        }
        if(slipPoint > 100){
            slipPoint = 100;
        }
        return amount * (100 - slipPoint) / 100;
    }

    function balanceOfContract(address contractAddress)  public view returns (uint) {
        return IERC20(contractAddress).balanceOf(address(this));
    }
	
	function withdrawStuckTokens(address token) public onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
		IERC20(token).transfer(msg.sender, amount);
	}
	
    function withdrawStuckTokensTwo(address token, uint256 amount) public onlyOwner {
       IERC20(token).transfer(msg.sender, amount);
	}

	function withdrawStuckEth() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
	
	receive() external payable {}

    function destoryContract() public onlyOwner{ 
        selfdestruct(msg.sender);  // 执行此函数之后，当前合约已经被销毁  合约者地址以及变量全部被销毁
    }
}