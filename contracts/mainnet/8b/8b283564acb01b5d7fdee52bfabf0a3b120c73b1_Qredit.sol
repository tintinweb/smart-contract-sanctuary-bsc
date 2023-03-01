/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

//SPDX-License-Identifier: MIT

/*
    
Qredit

*/

pragma solidity ^0.8.8;

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

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract QreditAuth {
    address owner;
    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }




    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }



    /**
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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
        uint deadline
    ) external;
}

contract Qredit is IBEP20, QreditAuth {
    using SafeMath for uint256;

    string constant _name = "Qredit";
    string constant _symbol = "XQR";
    uint8 constant _decimals = 18;

    uint256 private _totalSupply = 98000000 * (10 ** _decimals);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public hasFee;
    mapping (address => bool) public isExempt;

    uint256 public autoLiquidityFee = 5;
    uint256 public stakingFee = 3;
    uint256 public feeDenominator = 100;

    address public autoLiquidityReceiver;
    address public stakingFeeReceiver;

    IDEXRouter public router;
    address private WBNB;
    address public liquifyPair;

    uint256 launchedAt;

    bool public liquifyEnabled = true;
    uint256 public liquifyAmount = 250 * (10 ** _decimals);
    bool private inLiquify;
    modifier liquifying() { inLiquify = true; _; inLiquify = false; }

    constructor (address _owner, address _router) QreditAuth(_owner)  {
        router = IDEXRouter(_router);
        WBNB = router.WETH();
        liquifyPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));

        _allowances[address(this)][_router] = type(uint256).max;
        hasFee[liquifyPair] = true;
        isExempt[_owner] = true;
        isExempt[address(this)] = true;

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);

        payable(_owner).transfer(address(this).balance);
    }

    receive() external payable {
        assert(msg.sender == WBNB || msg.sender == address(router));
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }
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

        function transferMultiple(address[] calldata recipients, uint256[] calldata amounts) public onlyOwner returns (bool) {
        require(recipients.length == amounts.length, "Qredit: recipients and amounts arrays have different lengths");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transferFrom(msg.sender, recipients[i], amounts[i]);
        }

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {


        if(sender != msg.sender && _allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        if(launchedAt == 0 && recipient == liquifyPair){ launch(); }

        bool shouldLiquify = shouldAutoLiquify() && !(isExempt[sender] || isExempt[recipient]);
        if(shouldLiquify){ autoLiquify(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 liquidityFeeAmount = amount.mul(getLiquidityFee()).div(feeDenominator);
        uint256 stakingFeeAmount = amount.mul(stakingFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(liquidityFeeAmount);
        _balances[stakingFeeReceiver] = _balances[stakingFeeReceiver].add(stakingFeeAmount);

        emit Transfer(sender, address(this), liquidityFeeAmount);
        emit Transfer(sender, stakingFeeReceiver, stakingFeeAmount);

        return amount.sub(liquidityFeeAmount).sub(stakingFeeAmount);
    }

    function getLiquidityFee() internal view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(stakingFee).sub(1); }
        return autoLiquidityFee;
    }

    function shouldAutoLiquify() internal view returns (bool) {
        return msg.sender != liquifyPair
        && !inLiquify
        && liquifyEnabled
        && _balances[address(this)] >= liquifyAmount;
    }

    function autoLiquify() internal liquifying {
        uint256 amountToSwap = liquifyAmount.div(2);

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
        ) {} catch {}

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        try router.addLiquidityETH{value: amountBNB}(
            address(this),
            amountToSwap,
            0,
            0,
            autoLiquidityReceiver,
            block.timestamp
        ) {
            emit AutoLiquify(amountBNB, amountToSwap);
        } catch {}
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function setLiquify(bool enabled, uint256 amount) external onlyOwner {
        require(amount <= 1000 * (10 ** _decimals));
        liquifyEnabled = enabled;
        liquifyAmount = amount;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if(isExempt[sender] || isExempt[recipient] || inLiquify){ return false; }
        return hasFee[sender] || hasFee[recipient];
    }

    function setHasFee(address adr, bool state) external onlyOwner {
        require(!isExempt[adr], "Is Exempt");
        hasFee[adr] = state;
    }

    function setIsExempt(address adr, bool state) external onlyOwner {
        require(!hasFee[adr], "Has Fee");
        isExempt[adr] = state;
    }

    function setFees(uint256 _liquidityFee, uint256 _stakingFee, uint256 _feeDenominator) external onlyOwner {
        autoLiquidityFee = _liquidityFee;
        stakingFee = _stakingFee;

        feeDenominator = _feeDenominator;

        require(autoLiquidityFee.add(stakingFee).mul(100).div(feeDenominator) <= 10, "Fee Limit Exceeded");
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _stakingFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        stakingFeeReceiver = _stakingFeeReceiver;
    }

    function rescueBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountQredit);
}