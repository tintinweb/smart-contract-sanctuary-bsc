/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
// File: F22/lib/IUniswapV2Router.sol



pragma solidity ^0.8.0;

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



// pragma solidity >=0.6.2;

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
// File: F22/lib/Context.sol


pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: F22/lib/Ownable.sol


pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: F22/lib/SafeMath.sol


pragma solidity ^0.8.0;
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
// File: F22/lib/IERC20.sol


pragma solidity ^0.8.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: F22/Luck.sol


pragma solidity ^0.8.0;



contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}



contract Luck is Ownable,ERC20{
    using SafeMath for uint256;

    IUniswapV2Router02 public router;
    IUniswapV2Pair public pair;
    address public bnb;
    address public platAddress;
    address public receiveAddress;

    uint public platRatio = 0.01*1e18;
    uint public LPRatio = 0.02*1e18;
    uint public burnRatio = 0.02*1e18;
    uint public addLPAmount = 1000*1e18;

    receive() external payable {}

    constructor(address _bnb, address _platAddress, address _receiveAddress, address _router) ERC20('Luck2023','LK23'){
        bnb = _bnb;
        platAddress = _platAddress;
        receiveAddress = _receiveAddress;
        _mint(msg.sender,202300*1e18);
        nowOutAmount = 0;
        router = IUniswapV2Router02(_router);
        pair = IUniswapV2Pair(pairFor(router.factory(),address(this),bnb));
        delivers[platAddress] = true;
        delivers[receiveAddress] = true;
        delivers[address(this)] = true;
        delivers[address(0x00)] = true;
    }

    function mintTo(address adrs, uint amounts) public onlyOperators{
        _mint(adrs,amounts);
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if(!delivers[sender] && !delivers[recipient] && sender != address(router)){
            uint platAmount = amount.mul(platRatio).div(1e18);
            uint LPAmount = amount.mul(LPRatio).div(1e18);
            uint burnAmount = amount.mul(burnRatio).div(1e18);

            _burn(sender,burnAmount);

            super._transfer(sender,address(this),LPAmount+platAmount);
            if(recipient != address(pair) && sender != address(pair) && balanceOf(address(this)) >= addLPAmount){

                uint balanceLast = payable(address(this)).balance;
                _approve(address(this), address(router), addLPAmount);
                swap(addLPAmount*2/3,address(this));
                (,uint amountBNB) = payable(address(this)).balance.trySub(balanceLast);
                router.addLiquidityETH{value: amountBNB/2}(address(this),addLPAmount/3,0,0,receiveAddress,block.timestamp+60);
                payable(platAddress).transfer(payable(address(this)).balance);
            }

            amount = amount.mul(1e18-platRatio-LPRatio-burnRatio).div(1e18);
        }
        
        super._transfer(sender,recipient,amount);
    }

    uint public nowBurnAmount;
    uint public lastBurnAmount;
    uint public nowOutAmount;
    uint public lastOutAmount;
    uint public lastTotal;
    uint public startTime = 1672848000;
    uint public lastUpdateTime;
    uint public oneDay = 86400;

    modifier updateLastData(){
        (,uint timeSub) = block.timestamp.trySub(startTime);
        timeSub = timeSub.div(oneDay);
        (,uint timeSub2) = lastUpdateTime.trySub(startTime);
        timeSub2 = timeSub2.div(oneDay);
        if(timeSub == timeSub2+1){
            lastBurnAmount = nowBurnAmount;
            lastOutAmount = nowOutAmount;
            lastTotal = totalSupply();
            nowBurnAmount = 0;
            nowOutAmount = 0;
            lastUpdateTime = block.timestamp;
        }else if(timeSub > timeSub2+1){
            lastBurnAmount = 0;
            nowBurnAmount = 0;
            lastOutAmount = 0;
            nowOutAmount = 0;
            lastUpdateTime = block.timestamp;
        }
        _;
    }

    function _mint(address account,uint amount) internal override updateLastData(){
        super._mint(account,amount);
        nowOutAmount = nowOutAmount.add(amount);
    }

    function _burn(address account, uint amount) internal override updateLastData{
        super._burn(account,amount);
        nowBurnAmount = nowBurnAmount.add(amount);
    }

    function burn(uint amount) public{
        _burn(msg.sender,amount);
    }

    function getLastData() public view returns(uint output,uint burnAmount, uint totalAmount){
        (,uint timeSub) = block.timestamp.trySub(startTime);
        timeSub = timeSub.div(oneDay);
        (,uint timeSub2) = lastUpdateTime.trySub(startTime);
        timeSub2 = timeSub2.div(oneDay);
        if(timeSub == timeSub2+1)  return (nowOutAmount,nowBurnAmount,lastTotal);
        else if(timeSub > timeSub2+1)  return (0,0,lastTotal);
        else return (lastOutAmount,lastBurnAmount,lastTotal);
    }
    
    function getNowData() public view returns(uint output,uint burnAmount, uint totalAmount){
        (,uint timeSub) = block.timestamp.trySub(startTime);
        timeSub = timeSub.div(oneDay);
        (,uint timeSub2) = lastUpdateTime.trySub(startTime);
        timeSub2 = timeSub2.div(oneDay);
        if(timeSub == timeSub2+1)  return (0,0,totalSupply());
        else if(timeSub > timeSub2+1)  return (0,0,totalSupply());
        else return (nowOutAmount,nowBurnAmount,totalSupply());
    }

    mapping (address => bool) public delivers;
    function setDelivers(address[] memory _delivers, bool flag) public onlyOwner{
        for(uint i=0;i<_delivers.length;i++){
            delivers[_delivers[i]] = flag;
        }
    }

    function swap(uint amountIn, address to) private{
        address[] memory path = new address[](2); 
        path[0] = address(this);
        path[1] = bnb;
        router.swapExactTokensForETH(amountIn, 0, path, to, block.timestamp+60);
    }

    function setReceive(address _plat, address _receive) public onlyOwner{
        platAddress = _plat;
        receiveAddress = _receive;
    }

    function setBNB(address _bnb) public onlyOwner{
        bnb = _bnb;
    }

    function setRatio(uint _plat, uint _LP, uint _burnRatio) public onlyOwner{
        platRatio = _plat;
        LPRatio = _LP;
        burnRatio = _burnRatio;
    }

    function setPair(address _pair) public onlyOwner{
        pair = IUniswapV2Pair(_pair);
    }

    function setRouter(address _router) public onlyOwner{
        router = IUniswapV2Router02(_router);
    }

    function setAddLPAmount(uint _addLPAmount) public onlyOwner{
        addLPAmount = _addLPAmount;
    }

    mapping (address => bool) public operators;
    modifier onlyOperators(){
        require(operators[msg.sender],"Caller is not the operator");
        _;
    }
    function setOperator(address[] memory operatorList, bool flag) public onlyOwner{
        for(uint i=0;i<operatorList.length;i++){
            operators[operatorList[i]] = flag;
        }
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address thisPair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        uint tem = uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                // hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074' // init code hash
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'   // Change to INIT_CODE_PAIR_HASH of Pancake Factory
            )));
        thisPair = address(uint160(tem));
    }
}