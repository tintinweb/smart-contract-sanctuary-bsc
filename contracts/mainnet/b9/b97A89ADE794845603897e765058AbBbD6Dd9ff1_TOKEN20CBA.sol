/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

//SPDX-License-Identifier: MiT
pragma solidity ^0.8.6;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity( address tokenA, address tokenB, uint amountADesired,uint amountBDesired, uint amountAMin,uint amountBMin, address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token,uint amountTokenDesired, uint amountTokenMin,uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA,address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token,uint liquidity, uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin,  uint amountETHMin, address to,uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path,address to,uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path,address to,uint deadline) external;
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

    //黑名单
    mapping(address => bool) public isBlacked;
    //白名单
    mapping(address => bool) public isWhitelist;

    event EventWhitelist(address indexed addr, bool isBool);
    function setWhitelist(address addr_, bool isBool_) public onlyOwner{
        if(isWhitelist[addr_] != isBool_){
            isWhitelist[addr_] = isBool_;
            emit EventWhitelist(addr_, isBool_);
        }
    }

    event EventIsWhitelists(address[] adds, bool isExclude);
    function setWhiteListAdds(address[] calldata adds_, bool isExclude_) public onlyOwner{
        require(adds_.length >0 , "address list is zero");
        for(uint256 i = 0; i < adds_.length; i++) {
            isWhitelist[adds_[i]] = isExclude_;
        }
        emit EventIsWhitelists(adds_, isExclude_);
    }

    event EventBlacked(address indexed addr, bool isBool);
    function setBlacked(address addr_, bool isBool_) public onlyOwner{
        _setBlacked(addr_, isBool_);
    }

    function _setBlacked(address addr_, bool isBool_) internal {
        if(isBlacked[addr_] != isBool_){
            isBlacked[addr_] = isBool_;
            emit EventBlacked(addr_, isBool_);
        }
    }

    

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
    function _cast(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: cast to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

interface CBB {
    function getUserInvite(address to_) external view returns(address[] memory);
}

contract ReceiveUsdt is Ownable {
    IERC20 public usdt;
    constructor(address usdt_) {
        usdt = IERC20(usdt_);
    }

    function transferBack(uint256 amount) public onlyOwner{
        usdt.transfer(owner(), amount);
    }
}

















contract TOKEN20CBA is Ownable, ERC20 {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    CBB public cbb;

    
    mapping(address => bool) public isUniswapPair;

    
    
    
    
    
    uint256[2] private buyFee = [10000,2000];
    
    uint256[4] private sellFee = [2500,5000,2000,2500];
    
    uint256[10] private invitFee = [3000,2000,1000,1000,500,500,500,500,500,500];
    
    uint256 public lpTotal;
    
    uint256 public nftTotal;
    
    uint256 public mintScale = 2000;
    
    uint256 private feeDenominator = 100000;
    
    uint256 public nowFee = 12;
    
    uint256 public _rewardCount;
    
    uint256 public _balanceCount;
    
    uint256 private validBalance = 50 * (10 ** 18);
    
    mapping(address => bool) private isValid;


    
    address public assignAddr = 0x8eDDFAFff9dC5680eA53fA3061C70AAfA6779A20;
    
    address public deadAddr = 0x000000000000000000000000000000000000dEaD;
    
    address public nftAddr = 0xAf185B3e49e50459185cDfEBb592658aAfb1ed1b;
    
    address public pubAddr = 0xb3B10F259493db545424CA578c75dC2A668dd8C7;
    
    address public growAddr = 0xAe0D9973DD6DA3361d625a5f6FF083BF864F8633;


    
    

    //usdt 0x55d398326f99059fF775485246999027B3197955
    //dex 0x10ED43C718714eb63d5aA57B78B54704E256024E
    IERC20 private usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address private dex = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    ReceiveUsdt public receiveUsdt;

    uint256 private totalSupply_ = 110660000 * (10 ** 18);

    uint256 private constant MAX_SUPPLY = ~uint256(0)/1e18;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint256 private TOTAL_GONS;
    uint256 public pairBalance;

    
    uint256 public _lastRebasedTime;
    uint256 public _gonsPerFragment;
    uint256 public _lastEveryDayTime;
    uint256 public _lastNowAllotTotal;

    uint256 private _blackAddrTime;

    
    
    constructor(address cbb_) ERC20("Treasure Coin","TPC"){ 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(dex);
        uniswapV2Router = _uniswapV2Router;
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), address(usdt));
        uniswapV2Pair = _uniswapV2Pair;
        isUniswapPair[uniswapV2Pair] = true;
        receiveUsdt = new ReceiveUsdt(address(usdt));

        cbb = CBB(cbb_);

        setWhitelist(deadAddr, true);
        setWhitelist(nftAddr, true);
        setWhitelist(pubAddr, true);
        setWhitelist(growAddr, true);
        setWhitelist(address(this), true);
        setWhitelist(owner(), true);
        

        
        
        _totalSupply = totalSupply_;
        TOTAL_GONS = MAX_UINT256/1e18 - (MAX_UINT256/1e18 % _totalSupply);
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _balances[msg.sender] = TOTAL_GONS;
        emit Transfer(address(0x0), msg.sender, _totalSupply);

    }

    receive() external payable {}



    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!isBlacked[from] && !isBlacked[to], "address is blacklited");
        if(amount == 0) {super._transfer(from, to, 0);return;}

        if(_balanceCount >= 80000 && _balanceCount < 150000){
            if(nowFee >=12)setFee(true);
        }else if(_balanceCount >= 150000 && _balanceCount < 250000){
            if(nowFee >=6)setFee(true);
        }else if(_balanceCount >= 250000){
            if(nowFee >=3)setFee(false);
        }

        
        
        

        if(IUniswapV2Pair(uniswapV2Pair).totalSupply() <= 0 && to == uniswapV2Pair){_blackAddrTime = block.timestamp;}

        if(inSwapAndLiquify){
            _basicTransfer(from, to, amount);
            return;
        }
        bool canSwap = balanceOf(address(this)) >= lpTotal;
        if( canSwap
            && !inSwapAndLiquify
            && !isUniswapPair[from]
            && from != owner()
            && to != owner()
        ){
            if(lpTotal>0)swapAndLiquify(lpTotal);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (to==uniswapV2Pair && isWhitelist[from]==false && isWhitelist[to]==false){
            if (gonAmount >= _balances[from].div(10**18).mul(uint(10 ** 18).sub(1))  ){
                gonAmount = _balances[from].div(10**18).mul(uint(10 ** 18).sub(1));
            }
        }

        if (from == uniswapV2Pair){
            pairBalance = pairBalance.sub(amount);
        }else{
            _balances[from] = _balances[from].sub(gonAmount);
            _checkValidSub(from);
        }

        uint256 gonAmountReceived = (!isWhitelist[from] && !isWhitelist[to]) ? takeFeeFunc(from, to, gonAmount) : gonAmount;

        if (to == uniswapV2Pair){
            pairBalance = pairBalance.add(gonAmountReceived.div(_gonsPerFragment));
        }else{
            _balances[to] = _balances[to].add(gonAmountReceived);
            _checkValidAdd(to);
        }
        emit Transfer(from, to, gonAmountReceived.div(_gonsPerFragment));
    }
    
    function _basicTransfer(address from_, address to_, uint256 amount_) internal {
        uint256 gonAmount = amount_.mul(_gonsPerFragment);
        if (from_ == uniswapV2Pair){
            pairBalance = pairBalance.sub(amount_);
        }else{
            _balances[from_] = _balances[from_].sub(gonAmount);
            _checkValidSub(from_);
        }
        if (to_ == uniswapV2Pair){
            pairBalance = pairBalance.add(amount_);
        }else{
            _balances[to_] = _balances[to_].add(gonAmount);
            _checkValidAdd(to_);
        }
    }

    function _checkValidSub(address user) private {
        if(balanceOf(user) < validBalance && isValid[user]){
            if(_balanceCount > 0){
                isValid[user] = false;
                _balanceCount--;
            }
        }
    }

    function _checkValidAdd(address user) private {
        if(balanceOf(user) >= validBalance && !isValid[user]){
            isValid[user] = true;
            _balanceCount++;

        }
    }

    function transferAdd(address from, address to, uint amount) private {
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount.div(_gonsPerFragment));
    }

    event EventTeamReward(address from, address to, uint256 a, uint256 b, uint256 fee);
    function takeFeeFunc(address from_, address to_, uint256 gonAmount) internal returns (uint256) {
        uint256 _gonAmount = gonAmount;
        uint256 allFees;
        uint256 aFee;
        uint256 bFee;
        uint256 cFee;
        uint256 dFee;
        if(nowFee <= 0){return gonAmount;}
        if(isUniswapPair[from_]){
            if(block.timestamp <= _blackAddrTime.add(3 minutes))_setBlacked(to_,true);
            aFee = _calcFees(gonAmount,buyFee[0]);
            if(aFee>0)_sendeReward(from_, to_, gonAmount, aFee);
            bFee = _calcFees(gonAmount,buyFee[1]);
            if(bFee>0){
                transferAdd(from_,address(this),bFee);
                lpTotal += bFee.div(_gonsPerFragment);
            }
            allFees = aFee.add(bFee);
            if(allFees > 0)gonAmount = gonAmount.sub(allFees);
            if(!isContract(to_)){
                emit EventTeamReward(from_, to_, _gonAmount.div(_gonsPerFragment), gonAmount.div(_gonsPerFragment), nowFee);
            }
        }
        if(isUniswapPair[to_]){
            aFee = _calcFees(gonAmount,sellFee[0]);
            bFee = _calcFees(gonAmount,sellFee[1]);
            cFee = _calcFees(gonAmount,sellFee[2]);
            dFee = _calcFees(gonAmount,sellFee[3]);
            if(bFee >0 )nftTotal += bFee.div(_gonsPerFragment);
            allFees = aFee.add(bFee).add(cFee).add(dFee);

            if(aFee>0)transferAdd(from_,deadAddr,aFee);
            if(bFee>0)transferAdd(from_,nftAddr,bFee);
            if(cFee>0)transferAdd(from_,pubAddr,cFee);
            if(dFee>0)transferAdd(from_,growAddr,dFee);
            if(allFees > 0)gonAmount = gonAmount.sub(allFees);
        }
        return gonAmount;
    }

    function balanceOf(address account_) public view override returns (uint256) {
        return account_ == uniswapV2Pair ? pairBalance : _balances[account_].div(_gonsPerFragment);
    }

    function _sendeReward(address from_, address to_, uint amount_, uint iFee) private {
        address[] memory _parent = cbb.getUserInvite(to_);
        uint256 _iFee = iFee;
        uint a_;
        for(uint8 i = 0; i < 10; i++){
            address pI = _parent[i];
            if(pI == address(0))break;
            if(balanceOf(pI) < (1000 * 10 ** 18))continue;
            a_ = _calcFees(amount_,invitFee[i]);
            _iFee = _iFee.sub(a_);
            if(a_>0){
                _balances[pI] = _balances[pI].add(a_);
                emit Transfer(from_, pI, a_.div(_gonsPerFragment));
            }
        }
        if(_iFee>0){
            _balances[assignAddr] = _balances[assignAddr].add(_iFee);
            emit Transfer(from_, assignAddr, _iFee.div(_gonsPerFragment));
        }
    }
    function setFee(bool bool_) private {
        nowFee = bool_ ? nowFee.div(2) : 0;
        mintScale = bool_ ? mintScale.div(2) : 0;
        uint[2] memory buyFee_ = buyFee;
        uint[4] memory sellFee_ = sellFee;
        uint[10] memory invitFee_ = invitFee;
        for(uint i = 0;i < 10;i++){
            if(i < 2){
                buyFee_[i] = bool_ ? buyFee_[i].div(2) : 0;
            }
            if(i < 4){
                sellFee_[i] = bool_ ? sellFee_[i].div(2) : 0;
            }
            invitFee_[i] = bool_ ? invitFee_[i].div(2) : 0;
        }
        buyFee = buyFee_;
        sellFee = sellFee_;
        invitFee = invitFee_;
    }

    function _calcFees(uint256 amount, uint256 fee) private view returns(uint256){
        if(amount <= 0){return 0;}
        if(fee <= 0){return amount;}
        return amount.div(feeDenominator).mul(fee);
    }

    function isContract(address account_) private view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account_) }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function returnJSData() external view returns(uint, uint, uint, uint, uint, uint){
        
        uint price;
         (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if (reserve0 == 0 || reserve1 == 0) {
            price =  0;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(10 ** decimals(), path);
        if(amounts[0] == 0){price = 0;}
        if(amounts[1] == 0){price = 0;}else{price = amounts[1];}
        return (
            price,
            _lastNowAllotTotal,
            0,
            balanceOf(deadAddr),
            balanceOf(pubAddr),
            balanceOf(growAddr)
        );
    }











    function manualRebase() external {
        require(shouldRebase(),"rebase not required");
        rebase();
    }

    event LogRebase(uint256 indexed epoch, uint256 totalSupply, uint256 count);
    function rebase() internal {
        if ( inSwapAndLiquify ) return;
        uint256 total;
        uint256 _timestamp = block.timestamp;
        
        if(_timestamp >= _lastEveryDayTime.add(24 hours)){
            uint a = totalSupply_.div(feeDenominator).mul(mintScale);
            total = a;
            _lastNowAllotTotal = a;
            _lastEveryDayTime = _timestamp;
            _rewardCount = 0;
        }else{
            if(_rewardCount >= 24)return;
            total = _lastNowAllotTotal;
        }
        _rewardCount++;

        uint256 rebaseRate = total.div(24);
        
        
        
            _totalSupply = _totalSupply.add(rebaseRate);
       

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        

        emit LogRebase(_timestamp, _totalSupply, _rewardCount);
    }

    function shouldRebase() internal view returns (bool) {
        return
        // _autoRebase&& 
        (_totalSupply < MAX_SUPPLY)&& 
        !isUniswapPair[msg.sender]&& 
        !inSwapAndLiquify;
        
    }

    
    
    
   
    
    
    
    








    bool inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiqudity);
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = usdt.balanceOf(address(receiveUsdt));
        lpTotal = lpTotal.sub(contractTokenBalance);
        swapTokensForToken(half);
        uint256 newBalance = usdt.balanceOf(address(receiveUsdt)).sub(initialBalance);
        receiveUsdt.transferBack(newBalance);
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(receiveUsdt),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        usdt.approve(address(uniswapV2Router), usdtAmount);
        uniswapV2Router.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            usdtAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

}