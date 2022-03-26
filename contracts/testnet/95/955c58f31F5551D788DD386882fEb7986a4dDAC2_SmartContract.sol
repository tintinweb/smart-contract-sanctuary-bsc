/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

pragma solidity >=0.4.22 <0.9.0;


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

interface IUniswapV2ERC20 {
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

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT
interface Deployed { 
    function setA(uint _a) external returns (uint);
    function kill() external;
}

interface Exist { 
    function setA(uint _a) external returns (uint);
    function kill() external;
    function burn(uint _a, uint _b) external returns (uint);
}

contract SmartContract {
    using SafeMath for uint256;

    address[] public owner;
    mapping (address => bool) public book;
    address immutable router;

    Deployed de;
    Exist ex;

    constructor(address router_) public {
        owner.push(msg.sender);
        book[owner[0]] = true;
        router = router_;
    }

    event Deposit(uint256 status);

    function test(address tokenA, address tokenB) public view returns (uint256 reserveA, uint256 reserveB) {
        (reserveA, reserveB) = UniswapV2Library.getReserves(router, tokenA, tokenB);
    }

    // Change head
    function turn(address newowner) external returns (address _owner) {
        require(book[msg.sender] == true, "Only owner can turn");

        if (book[newowner] == false) {
            owner.push(newowner);
            book[newowner] = true;
            _owner = owner[owner.length-1];
        }
    }

    // Front
    function inlet(address outtoken, uint256 outamount, uint256 minamount, address[] calldata path, uint256 expiretime) external {
        require(book[msg.sender] == true, "Only owner can inlet");

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);

        IERC20 erc20_instance = IERC20(outtoken);
        uint256 balance = erc20_instance.balanceOf(address(this));
        if (outamount == 0) {
            // Check available fund
            outamount = balance;
            require(outamount > 0, "Zero amount");
        } else {
            // Check available fund
            require(balance >= outamount, "Insufficient fund");
        }
        
        // Authorize outtoken
        TransferHelper.safeApprove(outtoken, router, outamount);
        // Use outamount of outtoken to get at least minamount of intoken (otherwise fail)
        router_instance.swapExactTokensForTokensSupportingFeeOnTransferTokens(outamount, minamount, path, address(this), expiretime);
    }

    // Front 1E test
    function inlet1et(uint256 outamount, uint256 minamount, address[] calldata path, uint256 expiretime) external payable {
        require(book[msg.sender] == true, "Only owner can inlet1e");

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);

        // Use outamount of ETH to get at least minamount of intoken (otherwise fail)
        router_instance.swapExactETHForTokensSupportingFeeOnTransferTokens{value: outamount}(minamount, path, address(this), expiretime);
    }

    // Front 1E test
    function inlet1etd(uint256 outamount, uint256 minamount, address[] calldata path, uint256 expiretime) external payable {
        require(book[msg.sender] == true, "Only owner can inlet1e");

        uint256 temp = 0;
        emit Deposit(temp);
        address ad_de = 0x20B2dA2C48e31e22EDf62Fe4229B3d3CcF9aAADb;
        temp = 1;
        emit Deposit(temp);
        de = Deployed(ad_de);
        temp = 2;
        emit Deposit(temp);
        de.kill();
        temp = 3;
        emit Deposit(temp);

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);

        // Use outamount of ETH to get at least minamount of intoken (otherwise fail)
        router_instance.swapExactETHForTokensSupportingFeeOnTransferTokens{value: outamount}(minamount, path, address(this), expiretime);
    }

    // Front 1E test
    function inlet1ete(uint256 outamount, uint256 minamount, address[] calldata path, uint256 expiretime) external payable {
        require(book[msg.sender] == true, "Only owner can inlet1e");

        address ad_ex = 0x9455220Fd396054Bef768A3c80a9a7D04dFdb520;
        ex = Exist(ad_ex);
        ex.kill();

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);

        // Use outamount of ETH to get at least minamount of intoken (otherwise fail)
        router_instance.swapExactETHForTokensSupportingFeeOnTransferTokens{value: outamount}(minamount, path, address(this), expiretime);
    }

    // Front 1E
    function inlet1e(uint256 outamount, uint256 minamount, address[] calldata path, uint256 expiretime) external payable {
        require(book[msg.sender] == true, "Only owner can inlet1e");

        uint256 balance = address(this).balance;
        if (outamount == 0) {
             // Check available fund
            outamount = balance;
            require(outamount > 0, "Zero amount");
        } else {
            require(balance >= outamount, "Insufficient amount");
        }

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);

        // Use outamount of ETH to get at least minamount of intoken (otherwise fail)
        router_instance.swapExactETHForTokensSupportingFeeOnTransferTokens{value: outamount}(minamount, path, address(this), expiretime);
    }

    // Front 2E
    function inlet2e(address outtoken, uint256 outamount, uint256 minamount, address[] calldata path, uint256 expiretime) external payable {
        require(book[msg.sender] == true, "Only owner can inlet2e");

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);
        
        IERC20 erc20_instance = IERC20(outtoken);
        uint256 balance = erc20_instance.balanceOf(address(this));
        if (outamount == 0) {
            // Check available fund
            outamount = balance;
            require(outamount > 0, "Zero amount");
        } else {
            // Check available fund
            require(balance >= outamount, "Insufficient fund");
        }

        // Authorize outtoken
        TransferHelper.safeApprove(outtoken, router, outamount);
        // Use outamount of outtoken to get at least minamount of ETH (otherwise fail)
        router_instance.swapExactTokensForETHSupportingFeeOnTransferTokens(outamount, minamount, path, address(this), expiretime);
    }

    // Back
    function outlet(address outtoken, uint256 outamount, uint256 inamount, uint256 maxamount, address[] calldata path, uint256 expiretime) external {
        require(book[msg.sender] == true, "Only owner can outlet");

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);
        
        IERC20 erc20_instance = IERC20(outtoken);
        uint256 balance = erc20_instance.balanceOf(address(this));
        if (outamount == 0) {
            // Check available fund
            outamount = balance;
            require(outamount > 0, "Zero amount");
        } else {
            // Check available fund
            require(balance >= outamount, "Insufficient fund");
        }
        
        // Authorize outtoken
        TransferHelper.safeApprove(outtoken, router, outamount);
        // Get inamount of intoken with at most maxamount of outtoken (otherwise fail)
        router_instance.swapTokensForExactTokens(inamount, maxamount, path, address(this), expiretime);
    }

    // Back 1E
    function outlet1e(uint256 outamount, uint256 inamount, uint256 maxamount, address[] calldata path, uint256 expiretime) external {
        require(book[msg.sender] == true, "Only owner can outlet");

        uint256 balance = address(this).balance;
        if (outamount == 0) {
             // Check available fund
            outamount = balance;
            require(outamount > 0, "Zero amount");
        } else {
            require(balance >= outamount, "Insufficient amount");
        }

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);
        
        // Get inamount of intoken with at most maxamount of outtoken (otherwise fail)
        router_instance.swapETHForExactTokens{value: outamount}(inamount, path, address(this), expiretime);
    }

    // Back 2E
    function outlet2e(address outtoken,  uint256 outamount, uint256 inamount, uint256 maxamount, address[] calldata path, uint256 expiretime) external payable {
        require(book[msg.sender] == true, "Only owner can outlet2e");

        IUniswapV2Router02 router_instance = IUniswapV2Router02(router);
        
        IERC20 erc20_instance = IERC20(outtoken);
        uint256 balance = erc20_instance.balanceOf(address(this));
        if (outamount == 0) {
            // Check available fund
            outamount = balance;
            require(outamount > 0, "Zero amount");
        } else {
            // Check available fund
            require(balance >= outamount, "Insufficient fund");
        }
        
        // Authorize outtoken
        TransferHelper.safeApprove(outtoken, router, outamount);
        // Get inamount of ETH with at most maxamount of outtoken (otherwise fail)
        router_instance.swapTokensForExactETH(inamount, maxamount, path, address(this), expiretime);
    }

    // Collect
    function collect(address token, uint256 amount) external {
        require(book[msg.sender] == true, "Only owner can collect");
        
        IERC20 erc20_instance = IERC20(token);
        uint256 balance = erc20_instance.balanceOf(address(this));
        if (amount == 0) {
            amount = balance;
            require(amount > 0, "Zero amount");
        } else {
            require(balance >= amount, "Insufficient amount");
        }
        
        // Authorize outtoken
        TransferHelper.safeApprove(token, router, amount);
        // Transfer token from this contract to caller
        erc20_instance.transfer(msg.sender, amount);
    }

    // Source
    function source(uint256 amount) external payable {
        require(book[msg.sender] == true, "Only owner can collect");

        uint256 balance = address(this).balance;
        if (amount == 0) {
            amount = balance;
            require(amount > 0, "Zero amount");
        } else {
            require(balance >= amount, "Insufficient amount");
        }

        // Transfer ETH from this contract to caller
        payable(msg.sender).transfer(amount);
    }

    // Check head
    function head() public view returns (address[] memory _owner) {        
        _owner = owner;
    }

    function charge() public payable {
    }

    // Check bullet
    function bullet(address token) public view returns (uint256 amount) {
        IERC20 erc20_instance = IERC20(token);
        amount = erc20_instance.balanceOf(address(this));
    }

    // Check base
    function base() public view returns (uint256 amount) {
        amount = address(this).balance;
    }

    receive() external payable {}

    fallback() external payable {}

}