/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

// File: @uniswap\lib\contracts\libraries\TransferHelper.sol

pragma solidity >=0.6.0;

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



// File: contracts\interfaces\IFarmageddonFactory.sol

pragma solidity >=0.5.0;

interface IFarmageddonFactory {
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

// File: contracts\interfaces\IFarmageddonPair.sol

pragma solidity >=0.5.0;

interface IFarmageddonPair {
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

// File: contracts\libraries\FarmageddonLibrary.sol

pragma solidity >=0.5.0;



library FarmageddonLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'FarmageddonLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'FarmageddonLibrary: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {
        pair = IFarmageddonFactory(factory).getPair(tokenA,tokenB);
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IFarmageddonPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'FarmageddonLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'FarmageddonLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'FarmageddonLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'FarmageddonLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(10000 - fee);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint fee) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'FarmageddonLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'FarmageddonLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(10000 - fee);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path, uint fee) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'FarmageddonLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, fee);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path, uint fee) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'FarmageddonLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, fee);
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

contract Ownable {
    address private _owner;

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender), "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

// File: contracts\interfaces\IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// File: contracts\FarmageddonRouter.sol

pragma solidity =0.6.6;


contract FGMegaRouter is Ownable {
    using SafeMath for uint;

    address[] public factoryList;
    mapping (address => uint) public factoryFee;
    mapping (address => bool) public isFactoryListed;
    address public immutable  WETH;
    address public treasury = 0x5CdDC17F39222B6C9ED3D27E09C297DaA55EB17E;
    uint256 public Fee = 5;
    

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'FarmageddonRouter: EXPIRED');
        _;
    }

    constructor(address _factory, uint _factoryFee, address _WETH) public {
        factoryList.push(_factory);
        factoryFee[_factory] = _factoryFee;
        isFactoryListed[_factory] = true;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
    }

    function setFee(uint256 _Fee) public onlyOwner {
        Fee = _Fee;
    }

    function addFactory(address _factory, uint256 defaultfee) external onlyOwner {
        require(!isFactoryListed[_factory], " FG: Factory already listed ");
        factoryList.push(_factory);
        factoryFee[_factory] = defaultfee;
        isFactoryListed[_factory] = true;
    }

    function removeFactory(address _factory) external onlyOwner {
        require(isFactoryListed[_factory], "FG: Factory is not in the List");
        for (uint256 i = 0; i < factoryList.length; i++) {
            if (factoryList[i] == _factory) {
                factoryList[i] = factoryList[factoryList.length - 1];
                delete isFactoryListed[_factory];
                delete factoryFee[_factory];
                factoryList.pop();
            }
        }
    }



    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to, address factory) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = FarmageddonLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? FarmageddonLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IFarmageddonPair(FarmageddonLibrary.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    function findBestPriceOUT(uint256 amountIn, address[] memory path) public view returns (address factory, uint256[] memory amounts) {
        factory = address(0x0);
        amounts[0] = 0;
        for (uint i = 0; i < factoryList.length; i++){
            uint256[] memory amountCheck = FarmageddonLibrary.getAmountsOut(factoryList[i], amountIn, path, factoryFee[factory]);
            if (amountCheck[amountCheck.length -1] > amounts[amounts.length -1]) {
                factory = factoryList[i];

            }
        }
        amounts = FarmageddonLibrary.getAmountsOut(factory, amountIn, path, factoryFee[factory]);
    }

    function findBestPriceIN(uint256 amountIn, address[] memory path) public view returns (address factory, uint256[] memory amounts) {
        factory = address(0x0);
        amounts[0] = 0;
        for (uint i = 0; i < factoryList.length; i++){
            uint256[] memory amountCheck = FarmageddonLibrary.getAmountsOut(factoryList[i], amountIn, path, factoryFee[factory]);
            if (amountCheck[amountCheck.length -1] < amounts[amounts.length -1] || amounts[0] == 0) {
                factory = factoryList[i];
            }
        }
        amounts = FarmageddonLibrary.getAmountsOut(factory, amountIn, path, factoryFee[factory]);
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual  ensure(deadline) returns (uint[] memory amounts) {
        // amounts = FarmageddonLibrary.getAmountsOut(factory, amountIn, path, factoryFee(factory));
        address factory;
        (factory, amounts) = findBestPriceOUT(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'FarmageddonRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FarmageddonLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to, factory);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual   ensure(deadline) returns (uint[] memory amounts) {
        // amounts = FarmageddonLibrary.getAmountsIn(factory, amountOut, path);
        address factory;
        (factory, amounts) = findBestPriceIN(amountOut, path);
        require(amounts[0] <= amountInMax, 'FarmageddonRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FarmageddonLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to, factory);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
         
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'FarmageddonRouter: INVALID_PATH');
        uint amountIn = _chargeRouterFee(path, msg.value, 1);
        // amounts = FarmageddonLibrary.getAmountsOut(factory, amountIn, path);
        address factory;
        (factory, amounts) = findBestPriceOUT(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'FarmageddonRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(FarmageddonLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to, factory);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
         
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'FarmageddonRouter: INVALID_PATH');
        // amounts = FarmageddonLibrary.getAmountsIn(factory, amountOut, path);
        address factory;
        (factory, amounts) = findBestPriceIN(amountOut, path);
        uint routerSwapFee = _chargeRouterFeeForExactTokens(path, amounts[0], 2);
        require(amounts[0] + routerSwapFee <= amountInMax, 'FarmageddonRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FarmageddonLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this), factory);
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        amounts[amounts.length -1] = _chargeRouterFee(path, amounts[amounts.length - 1], 1);

        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
         
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'FarmageddonRouter: INVALID_PATH');
        // amounts = FarmageddonLibrary.getAmountsOut(factory, amountIn, path);
        address factory;
        (factory, amounts) = findBestPriceOUT(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'FarmageddonRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FarmageddonLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this), factory);
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        amounts[amounts.length -1] = _chargeRouterFee(path, amounts[amounts.length - 1], 1);

        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
         
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'FarmageddonRouter: INVALID_PATH');
        // amounts = FarmageddonLibrary.getAmountsIn(factory, amountOut, path);
        address factory;
        (factory, amounts) = findBestPriceIN(amountOut, path);
        uint routerSwapFee = _chargeRouterFeeForExactTokens(path, amounts[0], 1);
        require(amounts[0] + routerSwapFee <= msg.value, 'FarmageddonRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(FarmageddonLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to, factory);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0] - routerSwapFee);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to, address factory) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = FarmageddonLibrary.sortTokens(input, output);
            IFarmageddonPair pair = IFarmageddonPair(FarmageddonLibrary.pairFor(factory, input, output));
            (uint amount0Out, uint amount1Out) = getinfo(pair, input, token0, factory);
            address to = i < path.length - 2 ? FarmageddonLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function getinfo(IFarmageddonPair pair, address input, address token0, address factory) internal view returns (uint amount0Out, uint amount1Out){
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            uint amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            uint amountOutput = FarmageddonLibrary.getAmountOut(amountInput, reserveInput, reserveOutput, factoryFee[factory]);
            (amount0Out, amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual   ensure(deadline) {
        address factory;
        (factory,) = findBestPriceOUT(amountIn, path);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FarmageddonLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to, factory);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'FarmageddonRouter: INSUFFICIENT_OUTPUT_AMOUNT'
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
         
        payable
        ensure(deadline)
    {
        require(path[0] == WETH, 'FarmageddonRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();

        amountIn = _chargeRouterFee(path, amountIn, 2);
        address factory;
        (factory,) = findBestPriceOUT(amountIn, path);
        assert(IWETH(WETH).transfer(FarmageddonLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to, factory);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'FarmageddonRouter: INSUFFICIENT_OUTPUT_AMOUNT'
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
         
        ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'FarmageddonRouter: INVALID_PATH');
        address factory;
        (factory,) = findBestPriceOUT(amountIn, path);
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, FarmageddonLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this), factory);
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'FarmageddonRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);

        amountOut = _chargeRouterFee(path, amountOut, 1);

        TransferHelper.safeTransferETH(to, amountOut);
    }

    // router fee functions

    function _chargeRouterFee(address[] memory path, uint amountIn, uint feeMode) internal returns (uint adjustedAmountIn) {
        // transfer router fee to treasury from msg.sender
        uint routerSwapFeeBps = (path.length - 1) * Fee;
        uint routerSwapFee = amountIn.mul(routerSwapFeeBps) / 10000;
        adjustedAmountIn = amountIn.sub(routerSwapFee);
        if (feeMode == 1) {
            TransferHelper.safeTransferETH(treasury, routerSwapFee);
        } else {
           TransferHelper.safeTransferFrom(
                path[0], 
                address(this),
                treasury, routerSwapFee
            );
        }        
    }

    function _chargeRouterFeeForExactTokens(address[] memory path, uint amountIn, uint feeMode) internal returns (uint routerSwapFee) {
        // For `swapTokensForExactTokens()` we need to mark it up based on the calculated amountIn
        uint routerSwapFeeBps = (path.length - 1) * Fee;
        routerSwapFee = amountIn.mul(routerSwapFeeBps) / 10000;
        // transfer router fee to treasury from msg.sender
        if (feeMode == 1) {
            TransferHelper.safeTransferETH(treasury, routerSwapFee);
        }
    }


}