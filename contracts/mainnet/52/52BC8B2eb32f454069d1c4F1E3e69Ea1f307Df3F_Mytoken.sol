/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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

//ERC20标准
interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    /* 这会通知客户端销毁的数量 */
    event Burn(address indexed from, uint256 value);
}

//安全运算
contract Yunsuan {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

//操作权限
abstract contract Only {
    address internal owner;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"Only Owner");
        _;
    }

    modifier onlyBefore(uint _time){
        require(
            block.timestamp <= _time,
            "Function called too early."
        );
        _;
    }

    modifier onlyAfter(uint _time) {
        require(
            block.timestamp >= _time,
            "Function called too early."
        );
        _;
    }

    modifier onlyonce(address[] memory list, address user){
        for(uint i = 0;i < list.length;i++){
            require(list[i] != user,"Only Once");
        }
        _;
    }

}

//代币基本玩法
contract Mytoken is ERC20Interface, Yunsuan, Only {
    //初始化代币参数
        string public name;//币名
        string public symbol;//币符号
        uint public decimals;//币精度
        uint256 private _totalSupply;//总量
    //初始化时间
        uint public Contractstarttime = block.timestamp;//合约创建时间
    //初始化团队
        //技术方地址
        address internal Technical = 0xB8DF121DE5b22898Ffa46025fFa6bB761e4d3F44;
        //项目方地址
        address public Project = 0x52e71C5c0fA4a39625495D80b3daA226244Fc1b5;
        //社区地址
        address public Community = 0xDFb3DE9CA3deEb8b0dCeE72337F7B974ee26E3E4;
        //管理员地址
        address public Admin = 0xF7F7697045F07ea4EB4fD9725a88E900e2AC2C92;
        //白名单地址
        address public Theuser = 0x7ca357bdB64ded5eeb6401900E5185EA5577666c;
    //初始化交易所
        //Pancakeswap
            //address public uniswapV2Pair;
            address private PancakeFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
            address public PancakeRoute = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            IUniswapV2Router02 private ROUTER;
        //WBNB
            address private WBNBaddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //初始化映射关系
        //金钱
        mapping(address => uint) balances;
        //授权
        mapping(address => mapping(address => uint)) allowed;
    //初始化
    constructor(
        string memory c_name,
        string memory c_sumbol,
        uint c_decimal,
        uint c_supply
    ){
        name = c_name;
        symbol = c_sumbol;
        decimals = c_decimal;
        _totalSupply = c_supply * 10 ** decimals;
        ROUTER = IUniswapV2Router02(PancakeRoute);
        //初始化金额
        //balances[owner] = _totalSupply * 5 / 10;
        balances[Admin] = _totalSupply;
        //balances[owner] = _totalSupply;
        //balances[address(this)] = _totalSupply * 5 / 10;
        //_approveTokenIfNeeded(_totalSupply * 5 / 10 ether);
    }
    
    //获取除仓库的余额总量
    function totalSupply() override public view returns (uint) {
        return _totalSupply  - balances[address(this)];
    }

    //获取余额
    function balanceOf(address tokenOwner) override public view returns (uint balance) {
        return balances[tokenOwner];
    }

    //获取A授权给B多少币
    function allowance(address tokenOwner, address spender) override public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    //请求授权
    function approve(address spender, uint tokens) override public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    //合约授权给交易所
    function _approveTokenIfNeeded(uint tokens) public returns (bool success){
        require(balances[address(this)] > tokens,"Invalid money");
        allowed[address(this)][PancakeRoute] = tokens;
        emit Approval(address(this), PancakeRoute, tokens);
        return true;
    }

    //转账
    function transfer(address to, uint tokens) override public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        //balances[to] = safeAdd(balances[to], tokens);
        jizhi(to,tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    //机制
        function jizhi(address _to, uint256 _value) private{
            uint res;

            if(_value >= 1 ether){
                //4%销毁
                uint burn_ = _value * 4 / 100;
                _totalSupply = Yunsuan.safeSub(_totalSupply,burn_);
                //2%回流营销钱包
                uint huiliu_ = _value * 2 / 100;
                balances[Community] = Yunsuan.safeAdd(balances[Community], huiliu_);
                //6%入仓分红
                uint fenhong_ = _value * 6 / 100;
                balances[Theuser] = Yunsuan.safeAdd(balances[Theuser], fenhong_);
                //到账额
                res = _value - (burn_ + huiliu_ + fenhong_);
            }else{
                res = _value;
            }

            balances[_to] = Yunsuan.safeAdd(balances[_to], res);//给收款人加钱
        }

    //授权转账
    function transferFrom(address from, address to, uint tokens) override public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    //销毁自己资产
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] > _value);
        require(_value >= 0);
        balances[msg.sender] = safeSub(balances[msg.sender], _value);//减掉发送者的钱
        _totalSupply = safeSub(_totalSupply,_value);//更新总发行量
        emit Burn(msg.sender, _value);
        return true;
    }
    
    //取合约地址的钱
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }


    //更新授权
        //修改Owner地址
        function Setowner(address newaddress) public returns(bool){
            if(msg.sender == owner){
                owner = newaddress;
                return true;
            }else{
                return false;
            }
        }
        //修改技术方地址
        function Settechnical(address newaddress) public returns(bool){
            if(msg.sender == Technical){
                Technical = newaddress;
                return true;
            }else{
                return false;
            }
        }
        //修改项目方地址
        function Setproject(address newaddress) public returns(bool){
            if(msg.sender == Project){
                Project = newaddress;
                return true;
            }else{
                return false;
            }
        }
        //修改技术方地址
        function Setcommunity(address newaddress) public returns(bool){
            if(msg.sender == Community){
                Community = newaddress;
                return true;
            }else{
                return false;
            }
        }
}