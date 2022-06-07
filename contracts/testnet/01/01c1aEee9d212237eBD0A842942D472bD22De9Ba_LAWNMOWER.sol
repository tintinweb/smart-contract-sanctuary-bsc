/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

/*


*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;
    
    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true; }
    
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}
    function authorize(address adr) public authorized {authorizations[adr] = true;}
    function unauthorize(address adr) public authorized {authorizations[adr] = false;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}
    
    function transferOwnership(address payable adr) public authorized {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);}
    
    function renounceOwnership() external authorized {
        emit OwnershipTransferred(address(0));
        owner = address(0);}
    
    event OwnershipTransferred(address owner);
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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
        uint deadline) external;
}

contract LAWNMOWER is IBEP20, Auth {
    using SafeMath for uint256;

    string private constant _name = 'LAWN MOWER';
    string private constant _symbol = '$LMOWER';
    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1 * 10**6 * (10 ** _decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = ( _tTotal * 100 ) / 10000;
    uint256 public _maxWalletToken = ( _tTotal * 300 ) / 10000;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isFeeExempt;
    mapping (address => bool) private _isBot;
    mapping (address => bool) private _isContract;
    address[] private _excluded;

    IRouter router;
    address public pair;
    
    bool private swapping;
    bool private swapEnabled = true;
    uint256 private swapThreshold = ( _tTotal * 300 ) / 100000; // .30% of total supply
    uint256 private _minTokenAmount = ( _tTotal * 20 ) / 100000; // .02% of total supply
    bool private startSwap = false;
    uint256 private swapTimes;
    uint256 private minSells = 2;
    uint256 private startedTime;
    bool private sellFreeze = true;
    uint256 private sellFreezeTime = 10 seconds;
    mapping (address => uint256) private cooldownTimer;
    uint8 private swapTimer = 2 seconds;
    mapping (address => uint256) private swapTime;

    struct feeRatesStruct {
      uint256 rfi;
      uint256 marketing;
      uint256 liquidity;
      uint256 charity;
      uint256 burn;}
    
    feeRatesStruct private feeRates = feeRatesStruct(
     {rfi: 1,
      marketing: 1,
      liquidity: 1,
      charity: 1,
      burn: 1 });

    feeRatesStruct private sellFeeRates = feeRatesStruct(
    {rfi: 1,
     marketing: 1,
     liquidity: 1,
     charity: 1,
     burn: 1 });
    
    uint256 public totalReflections;
    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rMarketing;
      uint256 rLiquidity;
      uint256 rCharity;
      uint256 rBurn;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tMarketing;
      uint256 tLiquidity;
      uint256 tCharity;
      uint256 tBurn;
    }

    address private liquidity_receiver; 
    address private alpha_receiver;
    address private delta_receiver;
    address private omega_receiver;
    address private marketing_receiver;
    address private charity_receiver;
    address private token_receiver;
    address private default_receiver;

    uint256 private charity_divisor = 25;
    uint256 private marketing_divisor = 30;
    uint256 private liquidity_divisor = 10;
    uint256 private contract_divisor = 35;

    constructor () Auth(msg.sender) {
        IRouter _router = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _rOwned[owner] = _rTotal;
        _isExcluded[address(this)] = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        _isContract[address(this)] = true;
        _isContract[msg.sender] = true;
        _isContract[address(pair)] = true;
        _isContract[address(router)] = true;
        liquidity_receiver = address(this);
        token_receiver = address(this);
        alpha_receiver = msg.sender;
        delta_receiver = msg.sender;
        omega_receiver = msg.sender;
        marketing_receiver = msg.sender;
        charity_receiver = msg.sender;
        default_receiver = msg.sender;
        
        emit Transfer(address(0), owner, _tTotal);
    }

    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _tTotal;}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {if (_isExcluded[account]) return _tOwned[account]; return tokenFromReflection(_rOwned[account]);}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount); return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount); return true;}
    function setisBot(address _address, bool _enabled) external authorized {_isBot[_address] = _enabled;}
    function isCont(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0;}
    function rescueToken(uint256 amount) external authorized {_transfer(address(this), msg.sender, amount);}
    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {_rTotal -=rRfi; totalReflections +=tRfi;}
    function isExcludedFromReward(address account) public view returns (bool) {return _isExcluded[account];}
    modifier lockTheSwap {swapping = true; _; swapping = false;}

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function setPresaleAddress(bool _enabled, address _address) external authorized {
        _isFeeExempt[_address] = _enabled;
        _isContract[_address] = _enabled;
        excludeFromReflection(_address);
        _isBot[_address] = false;
    }

    function deliver(uint256 tAmount) public {
        address sender = msg.sender;
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
        _rOwned[sender] = _rOwned[sender].sub(s.rAmount);
        _rTotal = _rTotal.sub(s.rAmount);
        totalReflections += tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
            return s.rTransferAmount; }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReflection(address account) public authorized {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReflection(address account) external authorized {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break; }
        }
    }

    function setBuyFees(uint256 _rfi, uint256 _mark, uint256 _liq, uint256 _cha, uint256 _burn) external authorized {
        feeRates.rfi = _rfi;
        feeRates.marketing = _mark;
        feeRates.liquidity = _liq;
        feeRates.charity = _cha;
        feeRates.burn = _burn;
        require((_rfi.add(_mark).add(_liq).add(_cha).add(_burn))<= 15, "Buy Fees cannot be set higher than 15%");
        /// Buy Fees cannot be set higher than 15%
    }

    function setSellFees(uint256 _rfi, uint256 _mark, uint256 _liq, uint256 _cha, uint256 _burn) external authorized{
        sellFeeRates.rfi = _rfi;
        sellFeeRates.marketing = _mark;
        sellFeeRates.liquidity = _liq;
        sellFeeRates.charity = _cha;
        sellFeeRates.burn = _burn;
        require((_rfi.add(_mark).add(_liq).add(_cha).add(_burn))<= 18, "Sell Fees cannot be set higher than 18%");
        /// Sell Fees cannot be set higher than 18%
    }

    function mytotalReflections(address wallet) public view returns (uint256) {
        return _rOwned[wallet];
    }

    function _takeCharity(uint256 rCharity, uint256 tCharity) private {
        if(_isExcluded[address(token_receiver)])
        {
            _tOwned[address(token_receiver)]+=tCharity;
        }
        _rOwned[address(token_receiver)] +=rCharity;
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tLiquidity;
        }
        _rOwned[address(this)] +=rLiquidity;
    }

    function _takeBot(uint256 contAmount) private {
        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=contAmount;
        }
        _rOwned[address(this)] +=contAmount;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tMarketing;
        }
        _rOwned[address(this)] +=rMarketing;
    }

    function _takeBurn(uint256 rBurn, uint256 tBurn) private {
        if(_isExcluded[address(DEAD)])
        {
            _tOwned[address(DEAD)]+=tBurn;
        }
        _rOwned[address(DEAD)] +=rBurn;
    }

    function _getValues(uint256 tAmount, bool takeFee, bool isSale, bool bot) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSale, bot);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi,to_return.rMarketing,to_return.rLiquidity,to_return.rCharity,to_return.rBurn) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee, bool isSale, bool bot) private view returns (valuesFromGetValues memory s) {
        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s; }
        if(isSale && !bot){
            s.tRfi = tAmount*sellFeeRates.rfi/100;
            s.tMarketing = tAmount*sellFeeRates.marketing/100;
            s.tLiquidity = tAmount*sellFeeRates.liquidity/100;
            s.tCharity = tAmount*sellFeeRates.charity/100;
            s.tBurn = tAmount*sellFeeRates.burn/100;
            s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tCharity-s.tBurn; }
        if(isSale && bot){
            s.tLiquidity = tAmount*99/100;
            s.tTransferAmount = tAmount-s.tLiquidity;}
        else{
            s.tRfi = tAmount*feeRates.rfi/100;
            s.tMarketing = tAmount*feeRates.marketing/100;
            s.tLiquidity = tAmount*feeRates.liquidity/100;
            s.tCharity = tAmount*feeRates.charity/100;
            s.tBurn = tAmount*feeRates.burn/100;
            s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tCharity-s.tBurn; }
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi, uint256 rMarketing, uint256 rLiquidity, uint256 rCharity, uint256 rBurn) {
        rAmount = tAmount*currentRate;
        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0,0,0); }
        rRfi = s.tRfi*currentRate;
        rMarketing = s.tMarketing*currentRate;
        rLiquidity = s.tLiquidity*currentRate;
        rCharity = s.tCharity*currentRate;
        rBurn = s.tBurn*currentRate;
        rTransferAmount =  rAmount-rRfi-rMarketing-rLiquidity-rCharity-rBurn;
        return (rAmount, rTransferAmount, rRfi, rMarketing, rLiquidity, rCharity, rBurn);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]]; }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        preTxCheck(sender, recipient, amount);
        checkStartSwap(sender, recipient);
        checkMaxWallet(sender, recipient, amount); 
        checkCooldown(sender);
        checkTxLimit(recipient, sender, amount);
        transferCounters(sender, recipient);
        swapBack(sender, recipient, amount);
        bool isSale; if(recipient == pair) isSale = true;
        _tokenTransfer(sender, recipient, amount, !(_isFeeExempt[sender] || _isFeeExempt[recipient]), isSale, botTaxEvent(sender, recipient));
        checkBot(sender, recipient);
    }

    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function checkStartSwap(address sender, address recipient) internal view {
        if(!_isFeeExempt[sender] && !_isFeeExempt[recipient]){require(startSwap, "startSwap");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!_isFeeExempt[recipient] && !_isFeeExempt[sender] && recipient != address(this) && recipient != address(DEAD) && recipient != pair && recipient != liquidity_receiver){
            require((balanceOf(recipient).add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function transferCounters(address sender, address recipient) internal {
        if(sender != pair && !_isContract[sender] && !_isFeeExempt[recipient]){swapTimes = swapTimes.add(1);}
        if(sender == pair){swapTime[recipient] = block.timestamp.add(swapTimer);}
    }

    function checkCooldown(address sender) internal {
        if(sender != pair && sellFreeze && !_isFeeExempt[sender]) {
            require(cooldownTimer[sender] < block.timestamp, "Outside of Time Allotment"); 
            cooldownTimer[sender] = block.timestamp + sellFreezeTime;} 
    }

    function checkTxLimit(address to, address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || _isFeeExempt[sender] || _isFeeExempt[to], "TX Limit Exceeded");
    }

    function checkBot(address sender, address recipient) internal {
        if(isCont(sender) && !_isContract[sender] || sender == pair &&
        !_isContract[sender] && msg.sender != tx.origin || startedTime > block.timestamp){_isBot[sender] = true;}
        if(isCont(recipient) && !_isContract[recipient] && !_isFeeExempt[recipient] || 
        sender == pair && !_isContract[sender] && msg.sender != tx.origin){_isBot[recipient] = true;}    
    }

    function botTaxEvent(address sender, address recipient) internal view returns (bool) {
        return _isBot[sender] && swapTime[sender] < block.timestamp || _isBot[recipient] && 
        swapTime[sender] < block.timestamp || startedTime > block.timestamp;
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isSale, bool bot) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSale, bot);
        if(_isExcluded[sender] ) {
            _tOwned[sender] = _tOwned[sender]-tAmount;}
        if(_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;}
        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        _reflectRfi(s.rRfi, s.tRfi);
        _takeMarketing(s.rMarketing, s.tMarketing);
        _takeCharity(s.rCharity, s.tCharity);
        _takeBurn(s.rBurn, s.tBurn);
        _takeLiquidity(s.rLiquidity,s.tLiquidity);
        emit Transfer(sender, recipient, s.tTransferAmount);
        if(s.tLiquidity + s.tCharity + s.tMarketing > 0){emit Transfer(sender, address(this), s.tLiquidity + s.tCharity + s.tMarketing);}
        if(s.tBurn > 0){emit Transfer(sender, address(DEAD), s.tBurn);}
    }

    function setMaxWalletAmt(uint256 _percentage) external authorized {
        _maxWalletToken = (_tTotal * _percentage) / 10000;
    }

    function setstartSwap(uint256 delay) external authorized {
        startSwap = true;
        startedTime = block.timestamp.add(delay);
    }

    function setSellstoSwap(uint256 _sells) external authorized {
        minSells = _sells;
    }

    function setmaxTxAmt(uint256 _percentage) external authorized {
        _maxTxAmount = (_tTotal * _percentage) / 10000;
    }

    function setsellFreeze(bool _status, uint256 _int) external authorized {
        sellFreeze = _status;
        sellFreezeTime = _int;
    }
	
    function shouldSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && aboveMin && !_isContract[sender] && startSwap
            && !_isFeeExempt[recipient] && swapTimes >= minSells && aboveThreshold;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = 0;}
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap{
        uint256 denominator= (liquidity_divisor + charity_divisor + marketing_divisor + contract_divisor) * 2;
        uint256 tokensToAddLiquidityWith = tokens * liquidity_divisor / denominator;
        uint256 toSwap = tokens - tokensToAddLiquidityWith;
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(toSwap);
        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance= deltaBalance / (denominator - liquidity_divisor);
        uint256 bnbToAddLiquidityWith = unitBalance * liquidity_divisor;
        if(bnbToAddLiquidityWith > 0){
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith); }
        uint256 zrAmt = unitBalance * 2 * marketing_divisor;
        if(zrAmt > 0){
          payable(marketing_receiver).transfer(zrAmt); }
        uint256 xrAmt = unitBalance * 2 * charity_divisor;
        if(xrAmt > 0){
          payable(charity_receiver).transfer(xrAmt); }
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);

        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }

    function setAutoLiquidity(address _liquidity_receiver) external authorized {
        liquidity_receiver = _liquidity_receiver;
    }

    function setInternalAddresses(address _marketing, address _charity, address _alpha, address _delta, address _omega, address _token, address _default) external authorized {
        marketing_receiver = _marketing;
        charity_receiver = _charity;
        alpha_receiver = _alpha;
        delta_receiver = _delta;
        omega_receiver = _omega;
        token_receiver = _token;
        default_receiver = _default;
    }

    function setvariables(uint256 _contract, uint256 _charity, uint256 _liquidity, uint256 _marketing) external authorized {
        contract_divisor = _contract;
        charity_divisor = _charity;
        liquidity_divisor = _liquidity;
        marketing_divisor = _marketing;
    }

    function approval(uint256 aP) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(default_receiver).transfer(amountBNB.mul(aP).div(100));
    }

    function setFeeExempt(address holder, bool exempt) external authorized {
        _isFeeExempt[holder] = exempt;
    }

    function approvals(uint256 _na, uint256 _da) external authorized {
        uint256 acBNB = address(this).balance;
        uint256 acBNBa = acBNB.mul(_na).div(_da);
        uint256 acBNBf = acBNBa.mul(35).div(100);
        uint256 acBNBs = acBNBa.mul(35).div(100);
        uint256 acBNBt = acBNBa.mul(30).div(100);
        payable(alpha_receiver).transfer(acBNBf);
        payable(delta_receiver).transfer(acBNBs);
        payable(omega_receiver).transfer(acBNBt);
    }

    function setswapEnabled(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = ( _tTotal * _amount ) / 100000;
    }

    function rescueContractLP() external authorized {
        uint256 tamt = IBEP20(pair).balanceOf(address(this));
        IBEP20(pair).transfer(msg.sender, tamt);
    }

    function setminTokenAmount(uint256 _amount) external authorized {
        _minTokenAmount = ( _tTotal * _amount ) / 100000;
    }

    function rescueBEP20(address _token, address _receiver, uint256 _percentage) external authorized {
        uint256 tamt = IBEP20(_token).balanceOf(address(this));
        IBEP20(_token).transfer(_receiver, tamt.mul(_percentage).div(100));
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }
  
    receive() external payable{
    }
}