//SPDX-License-Identifier: MiT
pragma solidity ^0.8.6;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    // function WETH() external pure returns (address);
    // function addLiquidity( address tokenA, address tokenB, uint amountADesired,uint amountBDesired, uint amountAMin,uint amountBMin, address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    // function addLiquidityETH(address token,uint amountTokenDesired, uint amountTokenMin,uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    // function removeLiquidity(address tokenA,address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    // function removeLiquidityETH(address token,uint liquidity, uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
    // function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    // function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    // function swapExactTokensForTokens(uint amountIn,uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    // function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    // function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    // function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    // function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    // function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    // function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    // function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    // function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    // function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    // function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    // function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    // function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin,  uint amountETHMin, address to,uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    // function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    // function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path,address to,uint deadline) external payable;
    // function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path,address to,uint deadline) external;
}

interface IUniswapV2Factory {
    // event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    // function feeTo() external view returns (address);
    // function feeToSetter() external view returns (address);
    // function getPair(address tokenA, address tokenB) external view returns (address pair);
    // function allPairs(uint) external view returns (address pair);
    // function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    // function setFeeTo(address) external;
    // function setFeeToSetter(address) external;
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

    event Cast(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender, uint amount0In,uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}



library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b;require(c >= a, "SafeMath: addition overflow");return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return sub(a, b, "SafeMath: subtraction overflow");}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b <= a, errorMessage);uint256 c = a - b; return c;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;}uint256 c = a * b;require(c / a == b, "SafeMath: multiplication overflow");return c;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return div(a, b, "SafeMath: division by zero");}
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b > 0, errorMessage);uint256 c = a / b;return c;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return mod(a, b, "SafeMath: modulo by zero");}
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { require(b != 0, errorMessage);return a % b;}
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _transferOwnership(_msgSender());}
    function owner() public view virtual returns (address) {return _owner;}
    modifier onlyOwner() {require(owner() == _msgSender(), "Ownable: caller is not the owner");_;}
    function renounceOwnership() public virtual onlyOwner {_transferOwnership(address(0));}
    function transferOwnership(address newOwner) public virtual onlyOwner { require(newOwner != address(0), "Ownable: new owner is the zero address");_transferOwnership(newOwner);}
    function _transferOwnership(address newOwner) internal virtual { address oldOwner = _owner; _owner = newOwner; emit OwnershipTransferred(oldOwner, newOwner);}
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) { return _name;}
    function symbol() public view virtual override returns (string memory) {return _symbol;}
    function decimals() public view virtual override returns (uint8) {return 18;}
    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) { _transfer(_msgSender(), recipient, amount);return true; }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public virtual override returns (bool) {_approve(_msgSender(), spender, amount);return true;}
    function transferFrom(address sender, address recipient,uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _make(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: cast to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    // function _burn(address account, uint256 amount) internal virtual {
    //     require(account != address(0), "ERC20: burn from the zero address");
    //     _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
    //     _totalSupply = _totalSupply.sub(amount);
    //     emit Transfer(account, address(0), amount);
    // }
    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

















contract BEP20GKC is Ownable, ERC20 {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public uniswapV2Pair;
    mapping(address => bool) public _isUPair;
    


    mapping(address => bool) _isExtbmd; 
    
    address deadAddr = address(0x000000000000000000000000000000000000dEaD);
    address[] _arrGd;
    mapping(address => uint256) _countGd;
    mapping(address => bool) _isGd;

    address fzjjAddr = 0x7919E719ECc48ded8CeA4FEcB2D9D752639c647E;
    uint256 public gdfh; 
    uint256 public lpfh; 
    uint256 public _lpfh; 

    event RewardAmt(address user, uint256 amt);

    struct GDINFO {
        address gd;
        uint256 num;
    }

    bool inLPReward;
    modifier lockTheLp {
        inLPReward = true;
        _;
        inLPReward = false;
    }
    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    address private fromAddress;
    address private toAddress;

    uint256 currentIndex;  
    uint256 distributorGas = 500000;
    uint256 public lpFeeShareTime;

    uint256 amtLimit = 10000 * 10 ** 18;
    
   
    constructor(address[] memory _exts, GDINFO[] memory _gdinfo)
        ERC20("GoldKeyCoin", "GKC")
    {
        require(_addGd(_gdinfo),"write gd is error");
        _initSwap();
        _transferOwnership(address(0x06f13F21C7b1e60931DA57703bB4B963247C010c));

        _wrtExtBMD(address(this));
        _wrtExtBMD(owner());
        _wrtExtBMDs(_exts);
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[deadAddr] = true;
        _make(owner(), 500_0000 * 10 ** decimals());
    }

    function _initSwap() private {
        address dex =  address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address usdt =  address(0x55d398326f99059fF775485246999027B3197955);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(dex);
        uniswapV2Router = _uniswapV2Router;
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(usdt));
        uniswapV2Pair = IUniswapV2Pair(_uniswapV2Pair);
        _isUPair[_uniswapV2Pair] = true;
    }

    function _transfer(address from, address to, uint256 amt) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amt == 0) {return super._transfer(from, to, 0);}

        

        if( balanceOf(address(this)) >= gdfh
            && gdfh >= amtLimit
            && !isPair(from)
            && from != address(this)
        ){
            require(_issueGD(),"gd reward is error");
        }

        bool takeFee;
        if (isExtBMD(from) || isExtBMD(to))takeFee = true;
        if (!takeFee) {
            if(isRouter(from) || isRouter(to)){}else{
                if (!isPair(from) && !isPair(to)){
                  
                }else{
                    if (isPair(to))amt = _takeAmt(from, amt);
                }
            }
        }
        super._transfer(from, to, amt);


        if(fromAddress == address(0) ) fromAddress = from;
        if(toAddress == address(0)) toAddress = to;
        if(!isDividendExempt[fromAddress] && !isPair(fromAddress)) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && !isPair(toAddress)) setShare(toAddress);
        fromAddress = from;
        toAddress = to;

        
        if(
            balanceOf(address(this)) >= lpfh
            && !inLPReward
            && from != address(this)
            && lpFeeShareTime < block.timestamp
        ){
            if(lpfh >= amtLimit && _lpfh <= 0){
                _lpfh = lpfh;
                delete lpfh;
            }
            if(_lpfh > 0)process(distributorGas);
            lpFeeShareTime = block.timestamp;
        }
    }

    function _takeAmt(address from, uint256 amt) private returns(uint256){
        uint256 _amt = calcFmt(amt,9);
        lpfh += calcFmt(amt,5);
        gdfh += calcFmt(amt,2);
        super._transfer(from, fzjjAddr, calcFmt(amt,2));
        super._transfer(from, address(this), _amt.sub(calcFmt(amt,2)));
        return amt.sub(_amt);
    }


    function _addGd(GDINFO[] memory gdinfo) private returns(bool){
        uint256 lens = gdinfo.length;
        require(lens > 0, "addrs length 0");
        for (uint256 i; i < lens; i++){
            require(!_isCt(gdinfo[i].gd),"addrs is contract");
            _countGd[gdinfo[i].gd] = gdinfo[i].num;
            _isGd[gdinfo[i].gd] = true;
            _arrGd.push(gdinfo[i].gd);
        }
        return true;
    }
    

    function _issueGD() private returns(bool){
        uint256 lens = _arrGd.length;
        require(lens > 0 && gdfh > 0, "number or balance is zero");
        uint256 _gdfh = gdfh;
        delete gdfh;
        for (uint256 i = 0; i < lens; i++) {
            if(!_isGd[_arrGd[i]])continue;
            uint256 _amt = calcFmt(_gdfh, _countGd[_arrGd[i]]);
            super._transfer(address(this), _arrGd[i], _amt);
        }
        return true;
    }

    function _calcAmtLp(address _user, uint256 _total) private view  returns(uint256){
        //全网手续费÷全网总LP值x个人LP值【LP值的大小是按添加流动性时GKC的数量计算的，相同的U，GKC价格越低，LP值越大】。
        return _total.mul(uniswapV2Pair.balanceOf(_user)).div(uniswapV2Pair.totalSupply());
    }


    function isExtBMD(address addr) private view returns(bool){
        return _isExtbmd[addr];
    }
    function _wrtExtBMDs(address[] memory addrs) private returns(bool){
        uint256 lens = addrs.length;
        require(lens > 0, "addrs length 0");
        for (uint256 i; i < lens; i++){
            require(_wrtExtBMD(addrs[i]),"add BMDs error");
        }
        return true;
    }
    function _wrtExtBMD(address addr) private returns(bool){
        require(!_isCt(addr),"addrs is contract");
        if(_isExtbmd[addr])return false;
        _isExtbmd[addr] = true;
        return true;
    }
   
    
    function calcFmt(uint256 amount, uint256 fee) private pure returns (uint256){
        if (amount <= 0)return 0;
        if (fee <= 0)return amount;
        return amount.mul(fee).div(100);
    }
    function isPair(address inAddr) private view returns(bool){
        return address(uniswapV2Pair) == inAddr;
    }
    function isRouter(address inAddr) private view returns(bool){
        return address(uniswapV2Router) == inAddr;
    }
    function _isZero(address from) private pure returns(bool){
        return from == address(0x0);
    }
    function _isCt(address account_) private view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account_) }
        return (codehash != accountHash && codehash != 0x0);
    }











    function process(uint256 gas) private lockTheLp {
        uint256 shareholderCount = shareholders.length;
 
        if(shareholderCount == 0)return;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
 
        uint256 iterations = 0;
 
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount)delete currentIndex;
 
            uint256 amount = _calcAmtLp(shareholders[currentIndex], _lpfh);
            if( amount <= 0) {
                 currentIndex++;
                 iterations++;
                 return;
            }
            if(balanceOf(address(this))  < amount )return;

            distributeDividend(shareholders[currentIndex], amount);
            
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
            if(currentIndex >= shareholderCount){
                delete _lpfh;
            }
        }
    }
    function distributeDividend(address shareholder ,uint256 amount) private {
        super._transfer(address(this), shareholder, amount);
    }
 
    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(uniswapV2Pair.balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(uniswapV2Pair.balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;   
    }
 
    function addShareholder(address shareholder) private {
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

//==============================================================================
    receive() external payable {}
}