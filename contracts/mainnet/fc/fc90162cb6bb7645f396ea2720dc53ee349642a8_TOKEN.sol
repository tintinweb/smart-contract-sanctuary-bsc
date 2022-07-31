/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
        _owner = _owner;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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




interface DividendCon{
    function getLevel(address addr) view external returns(uint256);
}


contract TOKEN is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public _router;
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public uniswapV2Pair;
    uint256 public startTimeForSwap;
    

    address private poolWallet;
    address private marketingWallet;

    uint256 private pool;
    uint256 private tax;
    uint256 private resLimit;
    address public uAddr;
    address public dividendAddr; 

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private blackMap;

    mapping(address => uint256) public buyTotalMap;
    uint256 stopBurnLimit = 10000000 ether; // 10000000 ether

    uint256 public superNodeReward;
    uint256 public createNodeReward;
    uint256 public destoryRate;

    FeeInfo[] buyRateList;
    FeeInfo[] sellRateList;
    FeeInfo[] destoryRateList;
    bool inSwapAndLiquify;

    struct FeeInfo{
        address addr;
        uint256 rate;
        uint8 rewardType;
    }

    struct AdvanceInfo{
        uint256 total; 
        uint256 startTime; 
    }

    AdvanceInfo[] advanceInfoList;

    

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BurnFee(address indexed from, address indexed to, uint256 amount);
    event DividendFee(address indexed from, address indexed to, uint256 amount);
    event FundFee(address indexed from, address indexed to, uint256 amount);
    event MarketingFee(address indexed from, address indexed to, uint256 amount);
    event TaxFee(address indexed from, address indexed to, uint256 amount);

    

    constructor() ERC20("PES", "PES") {
        _mint(msg.sender, 10000000000 * 1e18);
        _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        poolWallet = 0x7595dCfD12096d0f750aae23bbb2CC4b3EABB225; 
        marketingWallet = 0x5580C37f6fb2829CF9a0DF2e6C5DBBf2df36bd68;
        dividendAddr = 0x48B94D9d6885615D0B941C974e1e020eF8ADbFF7;
        uAddr = 0x55d398326f99059fF775485246999027B3197955;
        address backPool = 0xE50081849f78a3d0283012F7F6ABE178322E7d8B;

        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this),uAddr);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Pair(_uniswapV2Pair);
        
        pool = 10;
        tax = 100;
        resLimit =  10;
        destoryRate = 50;

        address zeroAddr = address(0);

     
        buyRateList.push(FeeInfo(poolWallet,15,0));
        buyRateList.push(FeeInfo(zeroAddr,15,0));
        buyRateList.push(FeeInfo(backPool,15,0));
        buyRateList.push(FeeInfo(marketingWallet,5,0));

      
        sellRateList.push(FeeInfo(poolWallet,30,0));
        sellRateList.push(FeeInfo(zeroAddr,20,0));
        sellRateList.push(FeeInfo(backPool,20,0));
        sellRateList.push(FeeInfo(marketingWallet,10,0));
        sellRateList.push(FeeInfo(dividendAddr,10,2));
        sellRateList.push(FeeInfo(dividendAddr,10,1));

     
        destoryRateList.push(FeeInfo(zeroAddr,600,0));
        destoryRateList.push(FeeInfo(dividendAddr,100,1));
        destoryRateList.push(FeeInfo(dividendAddr,100,2));
        destoryRateList.push(FeeInfo(poolWallet,100,0));
        destoryRateList.push(FeeInfo(marketingWallet,100,0));


        advanceInfoList.push(AdvanceInfo(0,0));
        advanceInfoList.push(AdvanceInfo(5000000 ether,1659330000));
        advanceInfoList.push(AdvanceInfo(1000000 ether,1659330900));
        advanceInfoList.push(AdvanceInfo(500000 ether,1659331800));
        startTimeForSwap = 1659333600;
        




        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[poolWallet] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[dividendAddr] = true;
        _isExcludedFromFees[backPool] = true;

    }

    receive() external payable {}


     function setDividendWallet(address addr) public onlyOwner {
         _isExcludedFromFees[dividendAddr] = false;
        dividendAddr = addr;
        _isExcludedFromFees[dividendAddr] = true;
    }

    function setStopBurnLimit(uint256 limit) public onlyOwner{
        stopBurnLimit = limit;
    }

    function getBuyRateList() view public returns(FeeInfo[] memory){
        return buyRateList;
    }
    function setBuyRateList(uint8 index,uint256 rate,address addr) public onlyOwner{
        FeeInfo storage info = buyRateList[index];
        info.addr = addr;
        info.rate = rate;
    }

    function getSellRateList() view public returns(FeeInfo[] memory){
        return sellRateList;
    }

    function setSellRateList(uint8 index,uint256 rate,address addr) public onlyOwner{
        FeeInfo storage info = sellRateList[index];
        info.addr = addr;
        info.rate = rate;
    }

    function getDestoryRateList() view public returns(FeeInfo[] memory){
        return destoryRateList;
    }

    function setDestoryRateList(uint8 index,uint256 rate,address addr) public onlyOwner{
        FeeInfo storage info = destoryRateList[index];
        info.addr = addr;
        info.rate = rate;
    }

    function getAdvanceInfoList() view public returns(AdvanceInfo[] memory){
        return advanceInfoList;
    }

    function setAdvanceInfoList(uint8 index,uint256 total,uint256 startTime) public onlyOwner{
        AdvanceInfo storage info = advanceInfoList[index];
        info.total = total;
        info.startTime = startTime;
    }

    function setDestoryRate(uint256 rate) public onlyOwner{
        destoryRate = rate;
    }


    function setPair(address _pair) public onlyOwner {uniswapV2Pair = IUniswapV2Pair(_pair);}

    
    function setPoolWallet(address addr) public onlyOwner {
        _isExcludedFromFees[poolWallet] = false;
        poolWallet = addr;
        _isExcludedFromFees[poolWallet] = true;
    }
    function getPoolWallet() public view returns(address){return  poolWallet;}


    function setPoolFee(uint256 value) public onlyOwner {pool = value;}
    function getPoolFee() public view returns(uint256){return  pool;}
    function setTax(uint256 value) public onlyOwner {tax = value;}
    function getTax() public view returns(uint256){return  tax;}
    function setResLimit(uint256 value) public onlyOwner {resLimit = value;}
    function getResLimit() public view returns(uint256){return  resLimit;}
    function setStartTimeForSwap(uint256 _timestamp) public onlyOwner {startTimeForSwap = _timestamp;}
    function setMarketingWallet(address addr) public onlyOwner {
         _isExcludedFromFees[marketingWallet] = false;
        marketingWallet = addr;
        _isExcludedFromFees[marketingWallet] = true;
    }
    function getMarketingWallet() public view returns(address){return  marketingWallet;}


    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(msg.sender == owner(),"error"); 
        _isExcludedFromFees[account] = excluded; 
        emit ExcludeFromFees(account, excluded);
    }

    function listExcludeFromFees(address[] memory accounts, bool excluded) public onlyOwner {
        for(uint i = 0;i<accounts.length;i++){
            address addr = address(accounts[i]);
            _isExcludedFromFees[addr] = excluded; 
        }
    }
    
    function isExcludedFromFees(address account) public view returns (bool) {        
        return _isExcludedFromFees[account];
    } 


    function setBlack(address account, bool flag) public onlyOwner {
        blackMap[account] = flag; 
    }
    
    function isBlack(address account) public view returns (bool) {        
        return blackMap[account];
    } 
    
   



    function _innerTrans(address from, address to, uint256 amount,uint8 rewardType) private{
        if(to == address(0)){
            super._transfer(from, address(this), amount);
            super._burn(address(this),amount);
        }else if(to == dividendAddr){
            super._transfer(from, to, amount);
            if(rewardType == 2){
                superNodeReward = superNodeReward.add(amount);
            }else{
                createNodeReward = createNodeReward.add(amount);
            }
        } else{
           super._transfer(from, to, amount);
        }

    }

    function sellAndDestory(uint256 amount) private {
        uint256 totalSupply = super.totalSupply();
        if(totalSupply>stopBurnLimit){
            uint256 destoryAmount = amount.mul(destoryRate).div(1000);
            if(balanceOf(address(uniswapV2Pair))>=destoryAmount){
                for(uint8 i;i<destoryRateList.length;i++){
                    FeeInfo memory info = destoryRateList[i];
                    uint256 fee = destoryAmount.mul(info.rate).div(1000);
                    _innerTrans(address(uniswapV2Pair),info.addr,fee,info.rewardType);
                } 
            }
                       
        }
    }

    function getLevel(address addr) view public returns(uint256){
        return DividendCon(dividendAddr).getLevel(addr);
        // return 1;
    }
 
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");         
        require(!isBlack(from) && !isBlack(to),"black");

        // not whitelist
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            
            if(startTimeForSwap > block.timestamp && (to == address(uniswapV2Pair) || from == address(uniswapV2Pair))){ // not start
                require(getLevel(from)>0 || getLevel(to)>0,"not start");
                if(from == address(uniswapV2Pair)){ // buy
                    AdvanceInfo memory info = advanceInfoList[getLevel(to)];
                    require(info.startTime <= block.timestamp,"not start");
                    require(info.total >= amount.add(buyTotalMap[to]),"over white limit");
                    buyTotalMap[to] = amount.add(buyTotalMap[to]);
                }
            }

            if (from == address(uniswapV2Pair) && to == _router){
                // 
            } else if (from == _router) {// remove liquidity
             
            } else if (from == address(uniswapV2Pair) || to == address(uniswapV2Pair)) {

                if (to == address(uniswapV2Pair)){ // sell
                    if (balanceOf(from).mul(resLimit).div(1000) < amount){ // save limit
                        revert("Not allowed to sell");
                    }

                    uint256 orgAmount = amount;

                    uint256 totalFee;
                    for(uint8 i;i<sellRateList.length;i++){
                        FeeInfo memory info = sellRateList[i];
                        uint256 fee = amount.mul(info.rate).div(1000);
                        _innerTrans(from,info.addr,fee,info.rewardType);
                        totalFee = totalFee.add(fee);
                    }
                    amount = amount.sub(totalFee); 
                    super._transfer(from, to, amount);
                    sellAndDestory(orgAmount);   
                    return;
                }else{// buy
                    uint256 totalFee;
                    for(uint8 i;i<buyRateList.length;i++){
                        FeeInfo memory info = buyRateList[i];
                        uint256 fee = amount.mul(info.rate).div(1000);
                        _innerTrans(from,info.addr,fee,info.rewardType);
                        totalFee = totalFee.add(fee);
                    }
                    amount = amount.sub(totalFee);
                }
                
            } else {
                uint256 taxFee = amount.mul(tax).div(1000);
                // super._transfer(from, burnWallet, taxFee);
                super._burn(from,taxFee);
                amount = amount.sub(taxFee);
            }
        }      

        super._transfer(from, to, amount);
    }
    
}