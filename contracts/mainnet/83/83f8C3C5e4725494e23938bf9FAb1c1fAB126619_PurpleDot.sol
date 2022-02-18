/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: Unlicensed
//
// AHHHHHHHHHH PURPLE DOT EMOJI AHHHHHHHHHHH WHAT DOES IT MEAN AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
// 
// Tax: 4% LP
//
// Telegram: t.me/PurpleDotbsc

pragma solidity ^0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

interface IBEP20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}


contract PurpleDot is IBEP20, Ownable {
    
    using SafeMath for uint256;

    string _name = unicode"🟣";
    string _symbol = unicode"🟣";
    uint8 constant _decimals = 9;
    uint256 constant _totalSupply = 2 ** 12 * (10 ** _decimals); // 
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    // Allows us to see how much supply is actually held outside of pcs and burn addresses, this can also be used for calculating a dynamic swapThreshold
    function getActiveSupply() public view returns (uint256) {
        return getCirculatingSupply().sub(balanceOf(pancakeV2BNBPair));
    }
    uint256 constant _maxHold = _totalSupply / 50; 
    uint256 constant _feeDenominator = 1000;
    uint256 public marketingFee = 10;
    uint256 public liquidityFee = 30; // 3% LP tax
    uint256 totalFee = liquidityFee + marketingFee;
    function getTotalFee() public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return _feeDenominator.sub(1); }
        return totalFee;
    }
    uint256 launchedAt;
    uint256 public swapThreshold = _totalSupply / 5000; // 0.02%
    address public autoLiquidityReceiver;
	address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Mainnet - WBNB Token
//    address constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // Testnet - WBNB Token
    address public coinDeployer;
    address public marketingFeeReceiver = 0xE6087c6911cF08078F9424E9f0D319b6858E0798 ;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isMaxHoldExempt;
    mapping (address => bool) isFeeExempt;
    address[] pairs;
    address pancakeV2BNBPair;
    IDEXRouter router;
    bool swapEnabled = true;
    bool feesOnNormalTransfers = false;
    bool inSwap;
    modifier checkSwap() { inSwap = true; _; inSwap = false; }
    event AutoLiquify(uint256 amountToLiquify, uint256 amountBNBLiquidity);

    receive() external payable { }

    // IBEP20 implementation
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function name() external view override returns (string memory) { return _name; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function totalSupply() external pure override returns (uint256) { return _totalSupply; }

    constructor() Ownable() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
	//	router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
    	autoLiquidityReceiver = DEAD;
        _allowances[address(this)][address(router)] = ~uint256(0);
        pairs.push(pancakeV2BNBPair);
        isMaxHoldExempt[DEAD] = true;
        isMaxHoldExempt[pancakeV2BNBPair] = true;
        isMaxHoldExempt[address(this)] = true;
        isMaxHoldExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[msg.sender] = true;
        coinDeployer = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    event DeployerTransferred (address indexed oldDecider, address indexed newDecider);

    modifier onlyDeployer {
        require(_isCoinDeployer(msg.sender), "Only the coin decider can do this."); _;
    }

    function _isCoinDeployer(address account) internal view returns (bool) {
        return account == coinDeployer;
    }

    // Can be used to change the person who decides the coin besides the deployer, and can be used to delegate it to a separate contract in the future
    function transferCoinDeployer(address newDeployer) public onlyDeployer {
        address oldDeployer = coinDeployer;
        coinDeployer = newDeployer;
        emit DeployerTransferred(oldDeployer, newDeployer);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        if(shouldSwapBack()){ swapBack(); } // This is what engages the "reflections" token sell mechanism
        if(!launched() && recipient == pancakeV2BNBPair){ require(_balances[sender] > 0); launch(); }
        if(!isMaxHoldExempt[recipient]){
            require((_balances[recipient] + (amount - amount * totalFee / _feeDenominator)) <= _maxHold, "Wallet cannot hold more than 1%");
        }
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function approveMax(address spender) external returns (bool) {
        return approve(spender, ~uint256(0));
    }

    // Checking if the sender is a liqpair controls whether fees are taken on buy or sell (in this case it's both)
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) return false;
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] || recipient == liqPairs[i]) return true;
        }
        return feesOnNormalTransfers;
    }

    // Refers to taking tax on buys and sells
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee()).div(_feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
    
    function swapBack() internal checkSwap {
        uint256 amountToLiquify = _balances[address(this)].div(2);
        uint256 amountToSwap = _balances[address(this)].sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;
        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        )
        {
            uint256 amountBNBLiquidity = address(this).balance.sub(balanceBefore);
            if(amountToLiquify > 0){
                try router.addLiquidityETH{ value: amountBNBLiquidity }(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                ) {
                    emit AutoLiquify(amountToLiquify, amountBNBLiquidity);
                } catch {
                    emit AutoLiquify(0, 0);
                }
            }
        } catch {}
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    // Debug function - Distributes stuck BNB to coin decider
    function clearStuckBNB() public onlyDeployer {
        payable(coinDeployer).transfer(address(this).balance);
    }

    // Debug function - Manually sell tokens from the contract if the swapThreshold is met
    function clearStuckToken() public onlyDeployer {
        if(shouldSwapBack()){
            swapBack();
        }
    }

    // Debug function - Manually set the swap threshold for the contract
    function setSwapThresholdDiv(uint256 _div) public onlyDeployer {
        swapThreshold = _totalSupply / _div;
    }

}