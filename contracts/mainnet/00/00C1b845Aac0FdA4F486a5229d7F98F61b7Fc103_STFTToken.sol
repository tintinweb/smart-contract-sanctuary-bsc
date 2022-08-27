/**
 *Submitted for verification at BscScan.com on 2022-08-27
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



contract STFTToken is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "starfield token";
    string private _symbol = "STFT";
    uint8 private _decimals = 18;
    address public  deadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public marketingWalletAddress = payable(0x61A61f492E2667Be7A1907e574099D00e1d234A0); 
    address public recipientLpAddress = address(0x5fD3b71552DEcCeAeEa4037A1f22B7CaF9B811BF) ;
    // TEST:0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684   USDT：0x55d398326f99059fF775485246999027B3197955
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    //test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   0x10ED43C718714eb63d5aA57B78B54704E256024E
    address  public wapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint256 public genesisBlock;

    uint256 private minimumTokensBeforeSwap = 30000 * 10**_decimals; 
    uint256 _saleKeepFee = 1000;

    uint256 private _totalSupply = 10* 10**8 * 10**_decimals;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;
   

    uint256 public _tranferDestoryFee = 20;
    uint256 public _tranferBackLpFee = 20;
    uint256 public _tranferLpFenhongFee = 40;
    uint256 public _tranferHolderFenhongFee = 10;
    uint256 public _tranferMarketingFee = 10;
    uint256 public _tranferTotalFee = 6;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    TokenDistributor public _tokenDistributorLp;
    TokenDistributor public _tokenDistributorHolder;
    TokenDistributor public _tokenDistributorBackLp;

    uint256 distributorGas = 500000;
    address private fromAddress;
    address private toAddress;
   mapping (address => bool) public isDividendExempt;

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping(address => bool) private _updated;
    uint256 public currentIndex;  
    uint256 public minFenhongVal = 50000*10**_decimals;
    uint256 public minFenHongLP =  1* 10**_decimals;
    uint256 public curPerFenhongHolderLP = 0;
    uint256 public lpFnehongNum = 0 ;

    address[] public shareholders2;
    mapping(address => uint256) public shareholderIndexes2;
    mapping(address => bool) private _updated2;
    uint256 public currentIndex2;  
    uint256 public minFenhongVal2 = 80000*10**_decimals;
    uint256 public minFenHongToken =  100000 * 10**_decimals;
    uint256 public curPerFenhongHolderToken = 0;
   uint256 public tokenFnehongNum = 0 ;

    uint256 internal constant magnitude = 2**128;   

    bool inSwapAndLiquify;
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
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

    constructor () {
  
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(wapV2RouterAddress);  

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isDividendExempt[address(uniswapPair)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(deadAddress)] = true;
        isDividendExempt[owner()] = true;

        recipientLpAddress = owner();
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;

        _tokenDistributorLp = new TokenDistributor(usdtAddress);
        _tokenDistributorHolder = new TokenDistributor(usdtAddress);
        _tokenDistributorBackLp = new TokenDistributor(usdtAddress);

        isDividendExempt[address(_tokenDistributorLp)] = true;
        isDividendExempt[address(_tokenDistributorHolder)] = true;
        isDividendExempt[address(_tokenDistributorBackLp)] = true;

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

    function setMarketAddress(address addr) external onlyOwner {
        marketingWalletAddress = payable(addr);
    }

    function setRecipientLpAddress(address addr) external onlyOwner {
        recipientLpAddress = addr;
    }
    function setDividendExempt(address addr,bool b) external onlyOwner {
        isDividendExempt[addr] = b;
    }

    function setFenhongMinNum(uint256 n1,uint256 n2,uint256 n3) external onlyOwner {
        if(n1 != 0 )
        {   
            minFenhongVal = n1*10**_decimals;//lp
        }
        if(n2 != 0 )
        {
            minFenhongVal2 = n2*10**_decimals;//toekn
        }
        if(n3 != 0 )
        {
            minimumTokensBeforeSwap = n3 * 10**_decimals;
        }
    }
    function setHoldeTokenLP(uint256 val) external onlyOwner {
        minFenHongLP =  val * 10**_decimals;
    }

    function setHoldeTokenNum(uint256 val) external onlyOwner {
        minFenHongToken =  val * 10**_decimals;
    }

    function setDistributorGas(uint256 val) external onlyOwner {
        distributorGas = val;
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
       
        if((recipient == uniswapPair && !isTxLimitExempt[sender])||(!isMarketPair[sender] && !isMarketPair[recipient]))
        {
              uint256 balance = balanceOf(sender);
              if (amount == balance) {
                amount = amount.sub(amount.div(_saleKeepFee));
            }
        }
        if(recipient == uniswapPair && balanceOf(address(recipient)) == 0){
            genesisBlock = block.number;
        }

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if ( !inSwapAndLiquify && !isMarketPair[sender]) 
            {
                if(sender !=  address(uniswapV2Router))
                {
                    swapAndLiquify();    
                }
            }
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);
          
           fromAddress = sender;
           toAddress = recipient;  
            if(!isDividendExempt[fromAddress]  )//LP
            {
                setShare(fromAddress);
                setShareToken(fromAddress);
            } 
            if(!isDividendExempt[toAddress]  ) {//Token
                setShare(toAddress);
                setShareToken(toAddress);
            }
     
            if(balanceOf(address(_tokenDistributorLp)) >= minFenhongVal && curPerFenhongHolderLP== 0 ) {
                uint256 nowbanance = balanceOf(address(_tokenDistributorLp));//当前拥有
                uint256 totalHolderLp = IUniswapV2Pair(uniswapPair).totalSupply() - IUniswapV2Pair(uniswapPair).balanceOf(owner());
               
                lpFnehongNum = nowbanance;
                if(totalHolderLp >0)
                {
                    curPerFenhongHolderLP = lpFnehongNum.mul(magnitude).div(totalHolderLp);
                }
               
            }
            
            if(balanceOf(address(_tokenDistributorHolder)) >= minFenhongVal2 && curPerFenhongHolderToken == 0 ) {
                uint256 nowbanance = balanceOf(address(_tokenDistributorHolder));//当前拥有
                uint256 totalHolderToken = totalSupply() - balanceOf(uniswapPair) - balanceOf(owner())-balanceOf(address(this))
                -balanceOf(deadAddress)-balanceOf(address(_tokenDistributorLp))-balanceOf(address(_tokenDistributorHolder))
                -balanceOf(address(_tokenDistributorBackLp));
                tokenFnehongNum  = nowbanance;
                if(totalHolderToken > 0)
                {
                    curPerFenhongHolderToken = nowbanance.mul(magnitude).div(totalHolderToken);
                }
            }

            if(curPerFenhongHolderLP != 0)
            {
                process(distributorGas) ;
            }
            if(curPerFenhongHolderToken != 0)
            {
                process2(distributorGas) ;
            }

            return true;
        }
    }
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0)return;
       
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount ){
                currentIndex = 0;
                curPerFenhongHolderLP = 0;
                lpFnehongNum = 0;
                return;
            }
            uint256 amount   = IUniswapV2Pair(uniswapPair).balanceOf(shareholders[currentIndex]).mul(curPerFenhongHolderLP).div(magnitude);//持有人的数量*每个币可以分红的数量/一个大数 
            if( balanceOf(address(_tokenDistributorLp))  < amount || lpFnehongNum < amount )
            {
                currentIndex = 0;
                curPerFenhongHolderLP = 0;
                lpFnehongNum = 0;
                return;
            }
            distributeDividendHolderLp(shareholders[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


      function process2(uint256 gas) private {
        uint256 shareholderCount = shareholders2.length;
        if(shareholderCount == 0)return;
       
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                curPerFenhongHolderToken = 0;
                tokenFnehongNum = 0;
                return;
            }
            uint256 amount   = balanceOf(shareholders2[currentIndex]).mul(curPerFenhongHolderToken).div(magnitude);
            if(balanceOf(address(_tokenDistributorHolder))  < amount || tokenFnehongNum < amount)
            {
                tokenFnehongNum = 0;
                currentIndex = 0;
                curPerFenhongHolderToken = 0;
                return;
            }
          
            distributeDividendHolderToken(shareholders2[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


    function distributeDividendHolderLp(address shareholder ,uint256 amount) internal {
        lpFnehongNum = lpFnehongNum - amount;   
        _basicTransfer(address(_tokenDistributorLp),shareholder,amount);
    }

    function distributeDividendHolderToken(address shareholder ,uint256 amount) internal {
         tokenFnehongNum = tokenFnehongNum - amount;
        _basicTransfer(address(_tokenDistributorHolder),shareholder,amount);
    }


    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    
     function swapAndLiquify() private lockTheSwap {
        if(balanceOf(address(_tokenDistributorBackLp)) >= minimumTokensBeforeSwap)
        {
            uint256 tAmount =  balanceOf(address(_tokenDistributorBackLp));
            uint256 letfBackLpToken =  tAmount.div(2);
            _basicTransfer(address(_tokenDistributorBackLp),address(this), tAmount);
            swapTokensForUsdt(letfBackLpToken,address(_tokenDistributorBackLp));

            uint256 initialBalance = IERC20(usdtAddress).balanceOf(address(this));
            IERC20(usdtAddress).transferFrom(address(_tokenDistributorBackLp), address(this), IERC20(usdtAddress).balanceOf(address(_tokenDistributorBackLp)));
            uint256 newBalance = IERC20(usdtAddress).balanceOf(address(this)).sub(initialBalance);
            addLiquidityUsdt(tAmount.sub(letfBackLpToken),newBalance);
        }
    }
    
      function swapTokensForUsdt(uint256 tokenAmount,address recipient) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdtAddress);

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
    
     function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(usdtAddress).approve(address(uniswapV2Router), usdtAmount);
        uniswapV2Router.addLiquidity(
            address(this),
            address(usdtAddress),
            tokenAmount,
            usdtAmount,
            0,
            0,
            recipientLpAddress,
            block.timestamp+100
        );
    }
  
  
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair[recipient] || (!isMarketPair[sender] && !isMarketPair[recipient])) {//转账
 
            feeAmount = amount.mul(_tranferTotalFee).div(100);
            
            uint256  _tranferDestoryFeeNum = feeAmount.mul(_tranferDestoryFee).div(100);
            _takeFee(sender,address(deadAddress), _tranferDestoryFeeNum);
         
            uint256  _tranferBackLpFeeNum = feeAmount.mul(_tranferBackLpFee).div(100);
            _takeFee(sender,address(_tokenDistributorBackLp), _tranferBackLpFeeNum);

         
            uint256  _tranferLpFenhongFeeNum = feeAmount.mul(_tranferLpFenhongFee).div(100);
            _takeFee(sender,address(_tokenDistributorLp), _tranferLpFenhongFeeNum);

            
            uint256  _tranferHolderFenhongFeeNum = feeAmount.mul(_tranferHolderFenhongFee).div(100);
            _takeFee(sender,address(_tokenDistributorHolder), _tranferHolderFenhongFeeNum);
            
             uint256  _tranferMarketingFeeNum = feeAmount.mul(_tranferMarketingFee).div(100);
            _takeFee(sender,address(marketingWalletAddress), _tranferMarketingFeeNum);
        }
        
        return amount.sub(feeAmount);
    }
   function _takeFee(address sender, address recipient,uint256 tAmount) private {
        if (tAmount == 0 ) return;
        _balances[recipient] = _balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }


    
    function setShare(address shareholder) private {
        if(_updated[shareholder] ){      
            if(IUniswapV2Pair(uniswapPair).balanceOf(shareholder) < minFenHongLP) quitShare(shareholder);              
            return;  
        }
        if(IUniswapV2Pair(uniswapPair).balanceOf(shareholder) < minFenHongLP) return;  
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

    function setShareToken(address shareholder) private {

        if(_updated2[shareholder] ){      
            if(balanceOf(shareholder) < minFenHongToken) quitShareToken(shareholder);              
            return;  
        }
        if(balanceOf(shareholder) < minFenHongToken) return;  
        addShareholderToken(shareholder);
        _updated2[shareholder] = true;
          
    }
    function addShareholderToken(address shareholder) internal {
        shareholderIndexes2[shareholder] = shareholders2.length;
        shareholders2.push(shareholder);
    }
    function quitShareToken(address shareholder) private {
        removeShareholderToken(shareholder);   
        _updated2[shareholder] = false; 
    }
    function removeShareholderToken(address shareholder) internal {
        shareholders2[shareholderIndexes2[shareholder]] = shareholders2[shareholders2.length-1];
        shareholderIndexes2[shareholders2[shareholders2.length-1]] = shareholderIndexes2[shareholder];
        shareholders2.pop();
    }


    function clamErcOther(address erc,address recipient,uint256 amount) public onlyAdmin
    {
        IERC20(erc).transfer(recipient, amount);
    }
}

contract TokenDistributor  {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}