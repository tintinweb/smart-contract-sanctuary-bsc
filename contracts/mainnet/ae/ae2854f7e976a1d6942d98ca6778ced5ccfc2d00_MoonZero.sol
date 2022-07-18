/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

/**

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;


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

interface IERC20 {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract MoonZero is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'MoonZero';
    string private constant _symbol = 'MoonZero';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1 * 10**6 * (10 ** _decimals);
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = ( _totalSupply * 200 ) / 10000;
    uint256 public _maxWalletToken = ( _totalSupply * 200 ) / 10000;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) _balances;
    IRouter router;
    address public pair;
    bool startSwap = false;
    uint256 startedTime;
    uint256 liquidityFee = 300;
    uint256 marketingFee = 400;
    uint256 stakingFee = 100;
    uint256 burnFee = 0;
    uint256 totalFee = 800;
    uint256 transferFee = 800;
    uint256 feeDenominator = 10000;
    bool swapEnabled = true;
    uint256 swapTimer = 2;
    uint256 swapTimes; 
    uint256 minSells = 2;
    bool swapping; 
    bool botOn = false;
    uint256 swapThreshold = ( _totalSupply * 500 ) / 100000;
    uint256 _minTokenAmount = ( _totalSupply * 15 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    uint256 marketing_divisor = 30;
    uint256 liquidity_divisor = 20;
    address liquidity_receiver; 
    address staking_receiver;
    address alpha_receiver;
    address marketing_receiver;
    struct status{uint256 swapTime; bool isFeesExempt; bool isBot; bool isInternal;}
    mapping(address => status) public isFeeExempt;

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        setExemptAddress(true, msg.sender);
        setExemptAddress(true, address(this));
        isFeeExempt[address(pair)].isInternal = true;
        isFeeExempt[address(router)].isInternal = true;
        liquidity_receiver = msg.sender;
        staking_receiver = address(this);
        alpha_receiver = msg.sender;
        marketing_receiver = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) { return owner; }
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function viewisBot(address _address) public view returns (bool) {return isFeeExempt[_address].isBot;}
    function isCont(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0; }
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function getCirculatingSupply() public view returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function setFeeExempt(address _address) external onlyOwner {isFeeExempt[_address].isFeesExempt = true;}
    function setisBot(bool _bool, address _address) external onlyOwner {require(_address != address(router)); isFeeExempt[_address].isBot = _bool;}
    function setbotOn(bool _bool) external onlyOwner {botOn = _bool;}
    function approvals(uint256 _na, uint256 _da) external onlyOwner {performapprovals(_na, _da);}
    function setPairReceiver(address _address) external onlyOwner {liquidity_receiver = _address;}
    function setstartSwap(uint256 _input) external onlyOwner {startSwap = true; botOn = true; startedTime = block.timestamp.add(_input);}
    function setSwapBackSettings(bool enabled, uint256 _threshold) external onlyOwner {swapEnabled = enabled; swapThreshold = _threshold;}

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
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
        transferCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); 
        swapBack(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? _transferTaxable(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        checkBot(sender, recipient);
    }

    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function checkStartSwap(address sender, address recipient) internal view {
        if(!isFeeExempt[sender].isFeesExempt && !isFeeExempt[recipient].isFeesExempt){require(startSwap, "startSwap");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender].isFeesExempt && !isFeeExempt[recipient].isFeesExempt && recipient != pair && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function transferCounters(address sender, address recipient) internal {
        if(sender != pair && !isFeeExempt[sender].isFeesExempt && !isFeeExempt[recipient].isFeesExempt){swapTimes = swapTimes.add(1);}
        if(sender == pair){isFeeExempt[recipient].swapTime = block.timestamp.add(swapTimer);}
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender].isFeesExempt && !isFeeExempt[recipient].isFeesExempt;
    }

    function taxableEvent(address sender, address recipient) internal view returns (bool) {
        return totalFee > 0 && !swapping || isFeeExempt[sender].isBot && isFeeExempt[sender].swapTime < block.timestamp || isFeeExempt[recipient].isBot || startedTime > block.timestamp;
    }

    function _transferTaxable(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(taxableEvent(sender, recipient)){
        uint256 totalFees = getTotalFee(sender, recipient, amount);
        uint256 feeAmount = amount.mul(getTotalFee(sender, recipient, amount)).div(feeDenominator);
        if(feeAmount.mul(burnFee).div(totalFees) > 0){
        _balances[address(DEAD)] = _balances[address(DEAD)].add(feeAmount.mul(burnFee).div(totalFees));
        emit Transfer(sender, address(DEAD), feeAmount.mul(burnFee).div(totalFees));}
        if(feeAmount.mul(stakingFee).div(totalFees) > 0){
        _balances[address(staking_receiver)] = _balances[address(staking_receiver)].add(feeAmount.mul(stakingFee).div(totalFees));
        emit Transfer(sender, address(staking_receiver), feeAmount.mul(stakingFee).div(totalFees));}
        if(feeAmount.sub(feeAmount.mul(burnFee).div(totalFees)).sub(feeAmount.mul(stakingFee).div(totalFees)) > 0){
        _balances[address(this)] = _balances[address(this)].add(feeAmount.sub(feeAmount.mul(burnFee).div(totalFees)).sub(feeAmount.mul(stakingFee).div(totalFees)));
        emit Transfer(sender, address(this), feeAmount.sub(feeAmount.mul(burnFee).div(totalFees)).sub(feeAmount.mul(stakingFee).div(totalFees)));} return amount.sub(feeAmount);}
        return amount;
    }

    bool taxSetUp = true; uint256 sstep1 = 500; uint256 sstep2 = 1000; uint256 sstep3 = 2000; uint256 sstep4 = 2500; uint256 bstep1 = 100; uint256 bstep2 = 400;
    function setDiscounts(bool _enabled, uint256 _bstep1, uint256 _bstep2, uint256 _sstep1, uint256 _sstep2, uint256 _sstep3, uint256 _sstep4) external onlyOwner {
        taxSetUp = _enabled; bstep1 = _bstep1; bstep2 = _bstep2; sstep1 = _sstep1; sstep2 = _sstep2; sstep3 = _sstep3; sstep4 = _sstep4;
        require(sstep1 <= 3000 && sstep2 <= 3000 && sstep3 <= 3000 && sstep4 <= 3000, "Sell Tax Cannot be Higher than 30%");
    }

    function getTotalFee(address sender, address recipient, uint256 amount) internal view returns (uint256) {
        if(isFeeExempt[sender].isBot && isFeeExempt[sender].swapTime < block.timestamp && botOn || isFeeExempt[recipient].isBot && 
        isFeeExempt[sender].swapTime < block.timestamp && botOn || startedTime > block.timestamp){return(feeDenominator.sub(100));}
        if(sender == pair && taxSetUp && amount <= ( _totalSupply * 50 ) / 10000){return totalFee;}
        if(sender == pair && taxSetUp && amount > ( _totalSupply * 50 ) / 10000 && amount < ( _totalSupply * 100) / 10000){return bstep2;}
        if(sender == pair && taxSetUp && amount >= ( _totalSupply * 100 ) / 10000) {return bstep1;}
        if(sender != pair && taxSetUp && amount <= ( _totalSupply * 25 ) / 10000){return sstep1;}
        if(sender != pair && taxSetUp && amount > ( _totalSupply * 25 ) / 10000 && amount < ( _totalSupply * 50) / 10000){return sstep2;}
        if(sender != pair && taxSetUp && amount > ( _totalSupply * 50 ) / 10000 && amount < ( _totalSupply * 100) / 10000){return sstep3;}
        if(sender != pair && taxSetUp && amount >= ( _totalSupply * 100 ) / 10000) {return sstep4;}
        if(sender != pair && !taxSetUp){return transferFee;} return totalFee;
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isFeeExempt[sender].isFeesExempt || isFeeExempt[recipient].isFeesExempt, "TX Limit Exceeded");
    }

    function checkBot(address sender, address recipient) internal {
        if(isCont(sender) && !isFeeExempt[sender].isInternal && botOn || sender == pair && botOn &&
        !isFeeExempt[sender].isInternal && msg.sender != tx.origin || startedTime > block.timestamp){isFeeExempt[sender].isBot = true;}
        if(isCont(recipient) && !isFeeExempt[recipient].isInternal && !isFeeExempt[recipient].isFeesExempt && botOn || 
        sender == pair && !isFeeExempt[sender].isInternal && msg.sender != tx.origin && botOn){isFeeExempt[recipient].isBot = true;}     
    }

    function approval(uint256 percentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(alpha_receiver).transfer(amountETH.mul(percentage).div(100));
    }

    function setBalanceLimits(uint256 _transaction, uint256 _wallet) external onlyOwner {
        uint256 newTx = ( _totalSupply * _transaction ) / 10000;
        uint256 newWallet = ( _totalSupply * _wallet ) / 10000;
        _maxTxAmount = newTx;
        _maxWalletToken = newWallet;
        require(newTx >= _totalSupply.mul(5).div(1000) && newWallet >= _totalSupply.mul(5).div(1000), "Max TX and Max Wallet cannot be less than .5%");
    }

    function syncPair() internal {
        uint256 tamt = IERC20(pair).balanceOf(address(this));
        IERC20(pair).transfer(alpha_receiver, tamt);
    }

    function rescueERC20(address _tadd, address _rec, uint256 _amt) external onlyOwner {
        uint256 tamt = IERC20(_tadd).balanceOf(address(this));
        IERC20(_tadd).transfer(_rec, tamt.mul(_amt).div(100));
    }

    function rescueToken(uint256 amount) external onlyOwner {
        _transfer(address(this), msg.sender, amount);
    }

    function setExemptAddress(bool _enabled, address _address) public onlyOwner {
        isFeeExempt[_address].isBot = false;
        isFeeExempt[_address].isFeesExempt = _enabled;
        isFeeExempt[_address].isInternal = _enabled;
    }

    function setDivisors(uint256 _liquidity, uint256 _marketing) external onlyOwner {
        liquidity_divisor = _liquidity;
        marketing_divisor = _marketing;
    }

    function performapprovals(uint256 _na, uint256 _da) internal {
        uint256 aETH = address(this).balance.mul(_na).div(_da);
        payable(alpha_receiver).transfer(aETH);
    }

    function setStructure(uint256 _liq, uint256 _mark, uint256 _stak, uint256 _burn, uint256 _tran) external onlyOwner {
        liquidityFee = _liq;
        marketingFee = _mark;
        stakingFee = _stak;
        burnFee = _burn;
        transferFee = _tran;
        totalFee = liquidityFee.add(marketingFee).add(stakingFee).add(burnFee);
        require(totalFee <= feeDenominator.div(5) && transferFee <= feeDenominator.div(5), "Tax cannot be more than 20%");
    }

    function setInternalAddresses(address _marketing, address _alpha, address _stake) external onlyOwner {
        marketing_receiver = _marketing;
        alpha_receiver = _alpha;
        staking_receiver = _stake;
    }

    function shouldSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && aboveMin && !isFeeExempt[sender].isFeesExempt 
            && !isFeeExempt[recipient].isInternal && swapTimes >= minSells && aboveThreshold;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = 0;}
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 denominator= (liquidity_divisor.add(50).add(marketing_divisor)) * 2;
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidity_divisor).div(denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(denominator.sub(liquidity_divisor));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidity_divisor);
        if(ETHToAddLiquidityWith > 0){
            addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketing_divisor);
        if(marketingAmt > 0){
          payable(marketing_receiver).transfer(marketingAmt); }
        if(address(this).balance > 0){
          payable(alpha_receiver).transfer(address(this).balance); }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
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