/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT
interface IERC20 {

    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    require(b <= a, errorMessage);
    uint c = a - b;
    return c;
  }
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint a, uint b) internal pure returns (uint) {
    return div(a, b, "SafeMath: division by zero");
  }
  function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  function mod(uint a, uint b) internal pure returns (uint) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

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
contract usdtReceiver {
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    constructor() {
        IERC20(usdt).approve(msg.sender,~uint(0));
    }
}
contract TuNian is Context, IERC20, Ownable {

    using SafeMath for uint;

    address fundaddress = 0x587BF0F3bB32F1083c744116C85F2afaB906AfdA;
    address lpreceive;

    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public immutable pair;

    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    mapping (address => bool) public isWhite;
    mapping(address => bool) public isblacked;
    mapping(address => bool) public ishavetoken;
    
    address[] public HoldList;

    bool isLaunch;
    uint killtime;
    uint launchTime;
    uint dividendfee = 2;
    uint fundfee = 2;
    uint fundfee1H;
    uint lpfee = 1;
    uint private constant E18 = 1000000000000000000;
    uint private constant MAX = ~uint(0);
    uint private _totalSupply = 202300000000 * E18;
    uint private _decimals = 18;
    string private _symbol = "TuNian";
    string private _name = "TuNian";
    IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IUniswapV2Router02 public immutable uniswapV2Router;
    usdtReceiver public USDTReceiver;

    bool inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(uint _fundfee1H,address recipient,uint _killtime){

        lpreceive = msg.sender;
        _balances[recipient] = _totalSupply;
        fundfee1H = _fundfee1H;
        killtime = _killtime;
        ishavetoken[recipient] = true;
        HoldList.push(recipient);
        IUniswapV2Router02 Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IUniswapV2Factory(Router.factory()).createPair(address(this), usdt);
        uniswapV2Router = Router;
        USDTReceiver = new usdtReceiver();
        isWhite[recipient] = true;
        isWhite[fundaddress] = true;
        isWhite[owner()] = true;
        isWhite[address(this)] = true;
        emit Transfer(address(0), recipient, _totalSupply);

    }

    receive() external payable {}

    function decimals() public view  returns(uint) {
        return _decimals;
    }
    function symbol() public view  returns (string memory) {
        return _symbol;
    }
    function name() public view  returns (string memory) {
        return _name;
    }
    function totalSupply() public override view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public override view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function getHoldlist() view external returns(address[] memory){
        return HoldList;
    }
    function launch() public onlyOwner {
        require(!isLaunch, "BEP20: Allready launch");
        isLaunch = true;
        launchTime = block.timestamp;
    }
    function setblackAddress(address account, bool value) public onlyOwner{
        isblacked[account] = value;
    }
    function setFundWallet(address newaddress) external onlyOwner { 
        fundaddress = newaddress;
    }
    function setfundfee1H(uint _fundfee1H) external onlyOwner { 
        fundfee1H = _fundfee1H;
    }
    function setfee(uint _fundfee,uint _lpfee,uint _dividendfee) external onlyOwner { 
        fundfee = _fundfee;
        lpfee = _lpfee;
        dividendfee = _dividendfee;
    }
    function _transfer(address sender, address to, uint amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount,"exceed balance!");
        require(!isblacked[sender], "black address");
        
        if(to != pair && !ishavetoken[to] && to != address(this)){
            ishavetoken[to] = true;
            HoldList.push(to);
        }
        if(isWhite[sender] || isWhite[to]){
            _tokenTransfer(sender,to,amount,false);
        }else{
            require(isLaunch, "BEP20: Transfer not open");
            if (sender == pair && block.timestamp < launchTime + killtime) {
                isblacked[to] = true;
            }
            if(to == pair){
                require(amount <= _balances[sender].mul(99).div(100),"Exceeding the maximum selling ratio!");
            }
            _tokenTransfer(sender,to,amount,true);
        }
        
    }
    function _tokenTransfer(address sender, address to, uint amount, bool ishaveFee) private {

        if(!ishaveFee){
                _balances[sender] = _balances[sender].sub(amount);
                _balances[to] = _balances[to].add(amount);
                emit Transfer(sender, to, amount);
        }else{
            uint fundamount;
            if(block.timestamp < launchTime + 3600 && to == pair){
                fundamount = amount.mul(fundfee1H).mul(100).div(10000);
            }else{
                fundamount = amount.mul(fundfee).mul(100).div(10000);
            }
            uint otheramount = amount.mul(dividendfee.add(lpfee)).mul(100).div(10000);
            uint leftamount = amount.sub(fundamount.add(otheramount));

            _balances[sender] = _balances[sender].sub(amount);
            _balances[fundaddress] = _balances[fundaddress].add(fundamount);
            _balances[address(this)] = _balances[address(this)].add(otheramount);
            _balances[to] = _balances[to].add(leftamount);

            emit Transfer(sender, to, leftamount);
            emit Transfer(sender, fundaddress, fundamount);
            emit Transfer(sender, address(this), otheramount);
        }
    } 
    function DistributeAndLiquify() external {

        uint balance = _balances[address(this)];
        uint distriamount = balance.mul(dividendfee).div(dividendfee.add(lpfee));
        uint liquifyamount = balance.sub(distriamount);
        swapTokensForUSDT(distriamount);
        uint usdtAmount = USDT.balanceOf(address(this));
        uint totalbalance;
        for(uint i = 0; i < HoldList.length; i++) {
            if(_balances[HoldList[i]] >= 100000000 * E18){
                totalbalance += _balances[HoldList[i]];
            }
        }
        if(totalbalance > 0){
            for(uint i = 0; i < HoldList.length; i++){
                if(_balances[HoldList[i]] >= 100000000 * E18){
                    uint reward = _balances[HoldList[i]].mul(usdtAmount).div(totalbalance);
                    USDT.transfer(HoldList[i],reward);
                }
            } 
        }else{
            USDT.transfer(fundaddress,usdtAmount);
        }
        
        swapAndLiquify(liquifyamount);
    }
    function swapAndLiquify(uint amount) private lockTheSwap {
    
        uint half = amount.div(2);
        uint otherHalf = amount.sub(half);
        uint initialBalance = USDT.balanceOf(address(this));
        
        swapTokensForUSDT(half); 
        uint newBalance = USDT.balanceOf(address(this)).sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
    }
    function swapTokensForUSDT(uint tokenAmount) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(USDTReceiver),
            block.timestamp
        );
        uint usdtamount = USDT.balanceOf(address(USDTReceiver));
        IERC20(usdt).transferFrom(address(USDTReceiver), address(this), usdtamount);

    }
    function addLiquidity(uint tokenAmount, uint usdtAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        USDT.approve(address(uniswapV2Router), usdtAmount);
        uniswapV2Router.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0, 
            0, 
            lpreceive,
            block.timestamp
        );

    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setisWhite(address[] memory account, bool iswhite) external onlyOwner {
        require(account.length > 0, "no account");
        for(uint i = 0; i < account.length; i++) {
            isWhite[account[i]] = iswhite;
        }
    }
    function claimLeftToken(address token) external onlyOwner {
        uint left = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(_msgSender(), left);
    }

}