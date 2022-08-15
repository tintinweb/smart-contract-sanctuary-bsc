/**
 *Submitted for verification at BscScan.com on 2022-08-15
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
      
        bytes32 accountHash = 0x728d698e06a0d7cbc8303d07dd58f676e26d37608bd9165089f1a73a80de0107;
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



contract RoseToken is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "ROSE";
    string private _symbol = "ROSE";
    uint8 private _decimals = 18;
    address public  deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public signFundAddress; //签到基金地址
    address public freeFundAddress = address(0x1928c2B056Db7F234a16062bF99dd2032840F2ab);//自由基金地址
    address public consensusFundAddress = address(0x42342a041fD10dc6b8ecd5e6ce04f71b40d8D8ee);//技术开发的那个

   // TEST:0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684   USDT：0x55d398326f99059fF775485246999027B3197955
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    //test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   0x10ED43C718714eb63d5aA57B78B54704E256024E
    address  public wapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    
    uint256 public genesisBlock;

    uint256 _saleKeepFee = 1000;

    uint256 private _totalSupply = 23000000 * 10**_decimals;//总发行
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 public totalRelease = 6600000* 10**_decimals;//发行的代币
    uint256 public totalCompound = _totalSupply.sub(totalRelease);//总的复利利息
    uint256 public reduceRateNum = 4100000* 10**_decimals;//每次减少利率的数量
    uint256 public curRate = 1200;//1.2% 要除100000,
    uint256 public hadProvideTokenNum = 0;//已经产生发放的利息
    uint256 public hadReduceProvideNum = 1;//已经减少利息的次数
    uint256 public lastFenhongDay;//记录最近一次分红是第几天  时间戳/86400=天数。从添加池子才开始记录
    uint256 public oneDay = 86400;//86400 一天是多少秒，测试的时候要可以改
    uint256 public perFenHongNum = 0;//当前持有一个代币可分红多少个代币

    TokenDistributor public _tokenDistributor;//保存利息代币的地址

    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;
   
    uint256 public _buySignFee = 3;//买入签到基金地址扣点
    uint256 public _buyFreeFee = 3;//买入自由基金扣点
    uint256 public _buyTotalFee = _buySignFee.add(_buyFreeFee);

    uint256 public _sellConsensusFee =3;//卖出共识基金地址扣点
    uint256 public _sellFreeFee = 3;//卖出自由基金扣点
    uint256 public _sellTotalFee = _sellConsensusFee.add(_sellFreeFee);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    address private _administrator;

    uint256 public LPFeefenhongTime;
    uint256 public minPeriod = 20;

    uint256 distributorGas = 500000;
    address[] shareholders;//代币持有人
    mapping (address => uint256) shareholderIndexes;//持有人对应的下标 地址=》下标
    mapping(address => bool) private _updated;
    address private fromAddress;
    address private toAddress;
    uint256 currentIndex;
    uint256 minEthVal = 1000000;
    mapping (address => bool) isDividendExempt;//那些地址不能参与分红， 黑洞，pari,和创建合约人地址
    uint256 minFenHongToken =  1 * 10**_decimals;//低于多少1个代币的不分红，相当于他就是没代币的了

    uint256 internal constant magnitude = 10**18;   

    uint256 minSwapSignFundNum = 10000 * 10**_decimals;//调大一点点，万一刚好遇到数量达到换U了，用户此时添加池子是不成功的，只能等别的用户交易消去
    uint256 minSwapFreeFundNum = 11000 * 10**_decimals;
    uint256 minConsensusFundNum = 12000 * 10**_decimals;

    bool inSwapAndLiquify;
     mapping(address => bool) public exemptMap;
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
    
    modifier onlyAdmin() {
        require(_administrator == msg.sender, " caller is not the administrator");
        _;
    }

    constructor () {
        _administrator = msg.sender;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(wapV2RouterAddress);  

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;


        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[address(uniswapV2Router)] = true;
        
        exemptMap[signFundAddress] = true;
        exemptMap[freeFundAddress] = true;
        exemptMap[consensusFundAddress] = true;
        exemptMap[owner()] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;

        _tokenDistributor =  new TokenDistributor();//存放用来分发利息的地址

        _balances[_msgSender()] = totalRelease;
        _balances[address(_tokenDistributor)] = totalCompound;
        emit Transfer(address(0), _msgSender(), totalRelease);
        emit Transfer(address(0), address(_tokenDistributor), totalCompound);

        isDividendExempt[address(uniswapPair)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(deadAddress)] = true;
        isDividendExempt[address(_tokenDistributor)] = true;
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

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }
    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

   
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
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
    
        if(recipient == uniswapPair && !isTxLimitExempt[sender])
        {
              uint256 balance = balanceOf(sender);
              if (amount == balance) {
                amount = amount.sub(amount.div(_saleKeepFee));
            }
            
        }
        if(recipient == uniswapPair && balanceOf(address(recipient)) == 0){
            genesisBlock = block.number;
            lastFenhongDay = block.timestamp.div(oneDay);//开始记录是天数
        }

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            
            if (!inSwapAndLiquify && !isMarketPair[sender]&& sender !=  address(uniswapV2Router)) //卖的时候兑换
            {
                if( (!exemptMap[sender] && !exemptMap[recipient]))
                {
                    swapAndLiquify();    
                }
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                            amount : takeFee(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);
            
            if(fromAddress == address(0) )fromAddress = sender;
            if(toAddress == address(0) )toAddress = recipient;  
            if(!isDividendExempt[fromAddress]  ) setShare(fromAddress);
            if(!isDividendExempt[toAddress]  ) setShare(toAddress);
            
            fromAddress = sender;
            toAddress = recipient;  

            if(lastFenhongDay != block.timestamp.div(oneDay) && sender != owner())//如果天数不一样，说明，过了晚上12点，这个时候，用户交易触发分红
            {
                setCompound();
            }
            if(perFenHongNum >0)//开始分红
            {
                process(distributorGas) ;//开始自动分红，用户交易的时候触发
            }
        }
        return true;
        
    }

    //判断记录利率分红的
    function setCompound() private
    {   
        if(balanceOf(address(_tokenDistributor))<=0)//分完了
        {
            perFenHongNum = 0;
            return;
        }

        lastFenhongDay = block.timestamp.div(oneDay);//更新最近分红时间
        uint256 totalFenHongShare = _totalSupply - balanceOf(address(_tokenDistributor))-balanceOf(address(uniswapPair)) -  balanceOf(address(this)) -  balanceOf(owner());//总供应量-已经分红出去的=用户身上的总量
        uint256 curInterest = totalFenHongShare.mul(curRate).div(100000);//当前可以分到的利息
       
        if(curInterest>balanceOf(address(_tokenDistributor)))//超出了可以分的数量
        {
            curInterest = balanceOf(address(_tokenDistributor));
        }
        hadProvideTokenNum = hadProvideTokenNum.add(curInterest);//累计起来
        perFenHongNum = curInterest.mul(magnitude).div(totalFenHongShare);//其实每个代币可以分到的份额就是利率,这里乘以一个大数，防止被整除变0了，后面分发的时候乘以代币的时候再除掉它
        if(hadProvideTokenNum > (reduceRateNum*hadReduceProvideNum) && curRate >0)//如果分红数量超过临界点，利率发生变化
        {
            curRate = curRate.div(2);//利率减半
            hadReduceProvideNum = hadReduceProvideNum.add(1);
        }

    }


    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0)return;
       
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
     
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                perFenHongNum = 0;//这一轮分完后。标识为0，等待下一次
            }
        uint256 amount   = balanceOf(shareholders[currentIndex]).mul(perFenHongNum).div(magnitude);//持有人的数量*每个币可以分红的数量/一个大数 
  
         if( amount <  10) {
             currentIndex++;
             iterations++;
             return;
         }
         if(balanceOf(address(_tokenDistributor))  < amount )return;//数量不够就返回
           _basicTransfer(address(_tokenDistributor),shareholders[currentIndex],amount);//发生转账
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }



    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //兑换成U
    function swapAndLiquify() private lockTheSwap {
        if(balanceOf(signFundAddress) >= minSwapSignFundNum)
        {
            uint256 amount = balanceOf(signFundAddress);
            _basicTransfer(signFundAddress,address(this),amount);//发生转账.转到合约地址
            swapTokensForUsdt(amount,signFundAddress);//然后换成U
        }

        if(balanceOf(freeFundAddress) >= minSwapFreeFundNum)
        {
             uint256 amount = balanceOf(freeFundAddress);
            _basicTransfer(freeFundAddress,address(this),amount);//发生转账.转到合约地址
            swapTokensForUsdt(amount,freeFundAddress);//然后换成U
        }

        if(balanceOf(consensusFundAddress) >= minConsensusFundNum)
        {
             uint256 amount = balanceOf(consensusFundAddress);
            _basicTransfer(consensusFundAddress,address(this),amount);//发生转账.转到合约地址
            swapTokensForUsdt(amount,consensusFundAddress);//然后换成U
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
    //扣点计算的
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair[sender]) {
            uint256 _buySignFeeNum = amount.mul(_buySignFee).div(100);//签到基金
            _takeFee(sender,address(signFundAddress), _buySignFeeNum);
            uint256 _buyFreeFeeNum = amount.mul(_buyFreeFee).div(100);//自由基金
            _takeFee(sender,address(freeFundAddress), _buyFreeFeeNum);
         
            feeAmount = amount.mul(_buyTotalFee).div(100);
        }
        else if(isMarketPair[recipient]) {
            uint256 _sellConsensusFeeNum  = amount.mul(_sellConsensusFee ).div(100);//共识的
            _takeFee(sender,address(consensusFundAddress), _sellConsensusFeeNum);
            uint256 _sellFreeFeeNum = amount.mul(_sellFreeFee).div(100);//自由基金的
            _takeFee(sender,address(freeFundAddress), _sellFreeFeeNum);

            feeAmount = amount.mul(_sellTotalFee).div(100);
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
            if(balanceOf(shareholder) < minFenHongToken) quitShare(shareholder);              
            return;  
        }
        if(balanceOf(shareholder) < minFenHongToken) return;  
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

    //防止有人打了U进来没法取出来。。。管理员可以取
    function claImErcOther(address erc,address recipient,uint256 amount) public onlyOwner
    {
        IERC20(erc).transfer(recipient, amount);
    }

    //配置签到合约地址
    function setSignFundAddress(address _addr) public onlyOwner{
        signFundAddress = payable(_addr);
        exemptMap[signFundAddress] = true;
    }
    //配置自由基金
    function setFreeFundAddress(address _addr) public onlyOwner{
        freeFundAddress = address(_addr);
        exemptMap[freeFundAddress] = true;
    }
}


contract TokenDistributor {
    constructor () {
    }
}