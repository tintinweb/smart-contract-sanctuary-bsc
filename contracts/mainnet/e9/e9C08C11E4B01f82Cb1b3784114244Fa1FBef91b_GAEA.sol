/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

/*

@CyclopsBSC, Gaea fork.

Initial Supply: 50,000
Min APY: 100,000%
Max APY: 600,000%

13% Buy Tax:
1% Burn
3% Liquidity
4% Marketing 
5% buybacks

14% Sell Tax:
1%  Burn
3% Liquidity 
5% Marketing 
5% buybacks

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ILpPair {
    function sync() external;
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract GAEA is ERC20Detailed, Ownable {

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "Cyclops";
    string public _symbol = "Cyclops";
    uint8 public _decimals = 5;

    ILpPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 50 * 10**3 * 10**DECIMALS;

    uint256 public liquidityFee = 30;
    uint256 public universeFee = 50;
    uint256 public marketingAndDevFee = 40;
    uint256 public sellFee = 10;
    uint256 public burnFee = 10;
    uint256 public totalFee = liquidityFee+(universeFee)+(marketingAndDevFee)+(burnFee);
    uint256 public feeDenominator = 1000;
    uint256 public holders = 0;
    uint256 public immutable deployTimestamp;

    uint256 public constant MAX_REBASE = 4967; // 600,000% APY
    uint256 public constant MIN_REBASE = 3944; // 100,000% APY

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public universeReceiver;
    address public marketingReceiver;
    address public burn;
    address public pairAddress;
    bool public swapEnabled = true;
    IDexRouter public router;
    address public pair;
    bool inSwap = false;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = 500 * 10**9 * 10**DECIMALS;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 public constant REBASE_FREQUENCY = 30 minutes;
    
    mapping (address => bool) public walletIsHolder;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public ammPairs;

    constructor() ERC20Detailed("Cyclops", "Cyclops", uint8(DECIMALS)) Ownable() {

        router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        pair = IDexFactory(router.factory()).createPair(router.WETH(), address(this));
      
        autoLiquidityReceiver = address(0xdead);
        universeReceiver = 0xa060CAF0245753eaa06d366686d26A4ac82C8165; 
        marketingReceiver = 0x9A8377DbEc98Eaf8F53e323273EE3dF3a7bA0d34;
        burn = DEAD;

        _allowedFragments[address(this)][address(router)] = MAX_UINT256;
        pairAddress = pair;
        pairContract = ILpPair(pair);
        ammPairs[pair] = true;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS/(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = false;
        _autoAddLiquidity = false;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        deployTimestamp = block.timestamp;
        
        holders += 1;
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function rebase() internal {
        
        if ( inSwap ) return;
        uint256 rebaseRate;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime / REBASE_FREQUENCY;
        uint256 epoch = times * (REBASE_FREQUENCY/60);

        rebaseRate = calculateRebaseRate();

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply* ((10**RATE_DECIMALS)+rebaseRate) / (10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS / (_totalSupply);
        _lastRebasedTime = _lastRebasedTime + (times*(REBASE_FREQUENCY));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to,  uint256 value) external override validRecipient(to) returns (bool) {
        
        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
            require(_allowedFragments[from][msg.sender] > value,"Insufficient Allowance");
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender]-(value);
        }
        _transferFrom(from, to, value);
        return true;
    }

    function calculateRebaseRate() public view returns (uint256){
        uint256 rebaseRate;
        if(holders + MIN_REBASE >= ((block.timestamp - deployTimestamp)/1200)){
            rebaseRate = holders + MIN_REBASE - ((block.timestamp - deployTimestamp)/1200);
        }
        if(rebaseRate <= MIN_REBASE){
            return MIN_REBASE;
        }
        if(rebaseRate >= MAX_REBASE){
            return MAX_REBASE;
        }
        return rebaseRate;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount*(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from]-(gonAmount);
        _gonBalances[to] = _gonBalances[to]+(gonAmount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
           rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        if(balanceOf(recipient) >= totalSupply()/10000 && !walletIsHolder[recipient]){
            holders += 1;
            walletIsHolder[recipient] = true;
        }

        if(balanceOf(sender) < totalSupply()/10000 && holders > 0 && walletIsHolder[recipient]){
            holders -= 1;
            walletIsHolder[recipient] = false; 
        }

        if(!_isFeeExempt[recipient] && !ammPairs[recipient]){
            require(balanceOf(recipient) + amount <= totalSupply()/100, "Max wallet exceeded");
        }

        uint256 gonAmount = amount*(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender]-(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient]+(gonAmountReceived);


        emit Transfer(sender, recipient, gonAmountReceived/(_gonsPerFragment));
        return true;
    }

    function takeFee(address sender, address recipient, uint256 gonAmount) internal  returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _universeFee = universeFee;

        if (recipient == pair) {
            _totalFee = totalFee+(sellFee);
            _universeFee = universeFee+(sellFee);
        }

        uint256 feeAmount = gonAmount/(feeDenominator)*(_totalFee);
       
        _gonBalances[burn] = _gonBalances[burn]+(gonAmount/(feeDenominator)*(burnFee));
        _gonBalances[address(this)] = _gonBalances[address(this)]+(gonAmount/(feeDenominator)*(_universeFee+(marketingAndDevFee)));
        _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver]+(gonAmount/(feeDenominator)*(liquidityFee));
        
        emit Transfer(sender, address(this), feeAmount/(_gonsPerFragment));
        return gonAmount-(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver]/(_gonsPerFragment);
        _gonBalances[address(this)] = _gonBalances[address(this)]+(_gonBalances[autoLiquidityReceiver]);
        _gonBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount/(2);
        uint256 amountToSwap = autoLiquidityAmount-(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

        uint256 amountETHLiquidity = address(this).balance-(balanceBefore);

        if (amountToLiquify > 0&&amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(address(this), amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp);
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {

        uint256 amountToSwap = _gonBalances[address(this)]/(_gonsPerFragment);

        if( amountToSwap == 0) {return;}

        // never sell more than 1% of the supply.
        if( amountToSwap > totalSupply()/100){
            amountToSwap = totalSupply()/100;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

        uint256 amountETHToMarketingAndDev = address(this).balance-(balanceBefore);

        (bool success, ) = payable(universeReceiver).call{value: amountETHToMarketingAndDev * (universeFee)/(universeFee+(marketingAndDevFee)),gas: 30000}("");
        (success, ) = payable(marketingReceiver).call{value: (amountETHToMarketingAndDev*(marketingAndDevFee)/(universeFee+(marketingAndDevFee)))/3,gas: 30000}("");
        (success, ) = payable(0x02877dfc4E3BFaf17da6E4bC868FC4A36cf2D9a2).call{value: (amountETHToMarketingAndDev*(marketingAndDevFee)/(universeFee+(marketingAndDevFee)))/3,gas: 30000}("");
        (success, ) = payable(0xef1BdA97ff4B6BfB3b15e919A0Abf05a23A9B74E).call{value: (amountETHToMarketingAndDev*(marketingAndDevFee)/(universeFee+(marketingAndDevFee)))/3,gas: 30000}("");
    }

    function forceSwapback() external onlyOwner {
        swapBack();
    }

    function manageAmmPairs(address ammpair, bool enabled) external onlyOwner {
        require(pair != ammpair, "can't change status of default pair");
        ammPairs[ammpair] = enabled;
    }

    function withdrawAllToUniverse() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)]/(_gonsPerFragment);
        require( amountToSwap > 0,"There is no token deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, universeReceiver, block.timestamp);
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return _autoRebase && (_totalSupply < MAX_SUPPLY) && msg.sender != pair && !inSwap && block.timestamp >= (_lastRebasedTime + REBASE_FREQUENCY);
    }

    // force rebase
    function manualRebase() external onlyOwner {
        if((_totalSupply < MAX_SUPPLY) && msg.sender != pair && !inSwap && block.timestamp >= (_lastRebasedTime + REBASE_FREQUENCY)){
            rebase();
        }
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return _autoAddLiquidity && !inSwap && msg.sender != pair && block.timestamp >= (_lastAddLiquidityTime + 2 hours);
    }

    function shouldSwapBack() internal view returns (bool) {
        return !inSwap && msg.sender != pair; 
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue-subtractedValue;
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool){
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender]+(addedValue);
        emit Approval(msg.sender,spender,_allowedFragments[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool){
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS-(_gonBalances[DEAD])-(_gonBalances[ZERO]))/(_gonsPerFragment);
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        ILpPair(pair).sync();
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _universeReceiver, address _marketingReceiver, address _burn) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        universeReceiver = _universeReceiver;
        marketingReceiver = _marketingReceiver;
        burn = _burn;
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair]/(_gonsPerFragment);
        return
            accuracy*(liquidityBalance*(2))/(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }
    
    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = ILpPair(_address);
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who]/(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    receive() external payable {}
}