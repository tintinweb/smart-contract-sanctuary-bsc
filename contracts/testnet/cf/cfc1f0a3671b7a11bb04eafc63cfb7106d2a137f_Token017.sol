/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;


interface IUniswapV2Factory {
    /*
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    */
    function createPair(address tokenA, address tokenB) external returns (address pair);
    /*
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    */
}

interface IUniswapV2Pair {
    /*
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
    */
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    /*
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
    */
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    /*
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
    */
}


contract Token017 {

    uint public constant MAX = type(uint256).max;

    string public name = "Token 017";
    string public symbol = "T017";
    uint8 public decimals = 18;
    uint public totalSupplyAtLaunch = 1_000_000 * ( 10 ** decimals );
    uint public totalSupply = totalSupplyAtLaunch;
    
    bool public isTradingEnabled;
    uint public tradingEnabledTime; 

    uint8 public taxDev = 10;
    uint8 public taxMarketing = 5;
    uint8 public taxReward = 0;
    uint8 public taxTransfer = 5;

    address payable public token;
    address payable public deployer;      
    address payable public owner;

    // TESTNET addresses
    address public addressBurn = payable(0xe5A56BDcb7ef0655D06FB842d8fE8C7ecAf3785D); // TESTNET burn   
    address public addressDev = payable(0x91b50BEA858D8A378F19FBE522cEC08EfF01d4Ca); // TESTNET dev 
    address public addressMarketing = payable(0xBa87f373E1D46e2f2B32deecd90cF2C2002E852a); // TESTNET marketing
    address public addressReward = payable(0xd360A90144a3ea66C35D01E4Ad969Df41f607479); // TESTNET reward
    address public addressRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // pancake.kiemtienonline360.com/#/swap

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;
    mapping(address => bool) private router;
    mapping(address => bool) private blacklist;
    mapping(address => bool) private exempt;

    event Approval(address indexed owner, address indexed spender, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);
    event TransferFrom(address indexed from, address indexed to, uint amount, address indexed msgsender);
    
    receive() external payable {}

    constructor() {

        token = payable(address(this));
        exempt[token] = true;     

        deployer = payable(msg.sender);
        exempt[deployer] = true;

        owner = payable(msg.sender);
        exempt[owner] = true; // needed when creating LP - essential
        balances[owner] = totalSupplyAtLaunch;
        emit Transfer(address(0), owner, totalSupplyAtLaunch);


        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;


        exempt[addressBurn] = true;
        exempt[addressDev] = true;
        exempt[addressMarketing] = true;
        exempt[addressReward] = true;

    }

    function allowance(address holder, address spender) public view returns(uint) {
        return allowances[holder][spender];
    }
      
    // approve is for selling via DEX router
    function approve(address spender, uint amount) public returns(bool) { // spender is router address
        router[spender] = true;
        exempt[spender] = true; // needed for transfer functions???
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address holder) public view returns(uint) {
        return balances[holder];
    }

    function getOwner() public view returns(address) {
        return owner;
    }
    

    // for buys / wallet transfers
    function transfer(address to, uint amount) public returns(bool) {
        require(balanceOf(msg.sender) >= amount, "Balance too low");
        balances[msg.sender] -= amount;

// on a buy, 'from'/msg.sender is pair
// on a wallet transfer neither 'from' nor 'to' is pair

        uint _tax;
        if (!exempt[to]){
            _tax = ( amount * taxDev ) / 100;
            balances[addressDev] += _tax;
            emit Transfer(msg.sender, addressDev, _tax); // optional if you want tax amount deducted shown on Tx receipt
        }

        balances[to] += amount - _tax;
        emit Transfer(msg.sender, to, amount - _tax);

        return true;
    }
    

    // for sells
    function transferFrom(address from, address to, uint amount) public returns(bool) {
        require(balanceOf(from) >= amount, "Balance too low");
        require(allowances[from][msg.sender] >= amount, "Allowance too low");
        balances[from] -= amount;

// on a sell,'to' is pair (receives tokens from holder), and msg.sender (=spender) is the router address
// this function called when adding liquidity

        uint _tax;
        if (!exempt[from]){ 
            _tax = ( amount * taxMarketing ) / 100;
            balances[addressMarketing] += _tax;
            emit TransferFrom(from, addressMarketing, _tax, msg.sender);
        }

        balances[to] += amount - _tax;
        emit TransferFrom(from, to, amount - _tax, msg.sender);

        return true;   
    }
    
}