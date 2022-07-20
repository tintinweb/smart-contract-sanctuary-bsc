/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/*
HAMSTRONAUT :
- REWARDS IN BNB
- COMMUNITY TOKEN
- CONTRACT RENOUNCED
- LIQUIDITY BURNED 
- DEFLATIONARY

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

/**
 * Standard SafeMath, stripped down to just add/sub/mul/div
 */
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}


/**
 * BEP20 standard interface.
 */
interface BEP20 {
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

/* Standard IDEXFactory */
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/* Standard IDEXRouter */
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

/* Interface for the DividendDistributor */
interface DividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address shareholder) external;
    function getUnpaidEarnings(address shareholder) external view returns (uint256);
}

/* Token contract */
contract HAMSTRONAUT is BEP20 {
    using SafeMath for uint256;


    // Addresses
    address distributorAddress;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address private _owner;

    address public constant marketingFeeReceiver = 0x5f69af3dcaDD534b0Ec7231E0EAAd662c38EAF3a;
    address public constant autoLiquidityReceiver = DEAD;

    // Name and symbol
    string constant _name = "HAMSTRONAUT";
    string constant _symbol = "HAMSTRO";
    uint8 constant _decimals = 18;

    // Total supply
    uint256 public _totalSupply = 1000000000 * (10 ** _decimals);
    uint256 public _maxWallet =  _totalSupply * 300  / 10000; // 3%

    // Mappings
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;

    // Fee variables
    uint256 constant liquidityFee = 150;
    uint256 constant marketingFee = 400;
    uint256 constant reflectionFee = 300;
    uint256 constant totalFee = 850;
    uint256 constant feeDenominator = 10000;

    // Burn Fee
    uint256 constant burnFee = 50;

    // Sell amount of tokens when a sell takes place
    uint256 public swapThreshold = _totalSupply * 5 / 10000; // 0.05% of supply
    uint256 public maxSwapThreshold = _totalSupply * 50 / 10000; // 0.5% of supply

    DividendDistributor distributor;
    uint256 constant distributorGas = 300000;

    // Other variables
    IDEXRouter public router;
    address public pair;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    /* Token constructor */
    constructor (address _distributorAddress) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributorAddress = _distributorAddress;
        distributor = DividendDistributor(distributorAddress);

        _owner = msg.sender;
        isFeeExempt[_owner] = true;

        // Exempt from dividend
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[_owner] = true;

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
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

    // Main transfer function
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        if(sender != _owner && recipient != _owner && recipient != pair)
            require(balanceOf(recipient) + amount <= _maxWallet, "Transfer amount exceeds the maxWallet.");

        // Check if we should do the swapback
        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    // Do a normal transfer
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Check if sender is not feeExempt
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    // Take Fees and burn
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        uint256 burnAmount = amount.mul(burnFee).div(feeDenominator);
        _balances[DEAD] = _balances[DEAD].add(burnAmount);
        emit Transfer(sender, DEAD, burnAmount);

        return amount.sub(feeAmount.add(burnAmount));
    }

    // Check if we should sell tokens
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && _balances[address(this)] >= swapThreshold;
    }

    // Main swapback to sell tokens for WBNB
    function swapBack() internal swapping {
        uint256 amountToSwap = _balances[address(this)] ;
        if(amountToSwap >= maxSwapThreshold){
            amountToSwap = maxSwapThreshold;
        }
        uint256 amountToLiquify = amountToSwap.mul(liquidityFee).div(totalFee).div(2);
        amountToSwap = amountToSwap.sub(amountToLiquify);


        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}


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

        payable(marketingFeeReceiver).transfer(address(this).balance);

    }

    // Let people claim there dividend
    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    // Check how much earnings are unpaid
    function getUnpaidEarnings(address shareholder) external view returns (uint256) {
        return distributor.getUnpaidEarnings(shareholder);
    }

    function transferForeignToken(address _token) external {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = BEP20(_token).balanceOf(address(this));
        payable(marketingFeeReceiver).transfer(_contractBalance);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AutoLiquify(uint256 amountBNB, uint256 amountHAMSTRO);

}