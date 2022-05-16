/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

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
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract Illuminaughty is IBEP20, Ownable {
    using SafeMath for uint256;

    string constant _name = "Illuminaughty";
    string constant _symbol = "Naughty";
    uint8 constant _decimals = 18;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    //address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    uint256 public _totalSupply = 1_000_000_000 * (10 ** _decimals);
    bool public removeBurnFromSupply = true;

    uint256 public _maxTxAmount = _totalSupply * 5 / 1000;
    uint256 public _walletMax = _totalSupply * 2 / 100;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;

    uint256 public liquidityFee = 2;
    uint256 public marketingFee = 2;
    uint256 public burnFee = 2;
    uint256 public extraFeeOnSell = 6;

    uint256 public totalFee = 6;
    uint256 public totalFeeIfSelling = 12;

    address public autoLiquidityReceiver;
    address public marketingWallet;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = false;
    uint256 public launchedAt = 0;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapThreshold = _totalSupply * 4 / 1000;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () Ownable(msg.sender) {
        
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;

        autoLiquidityReceiver = msg.sender;
        marketingWallet = 0x0b32fE0c67dD3F858034091aBeC0b5fB6E384d30;

        isFeeExempt[marketingWallet] = true;
        isTxLimitExempt[marketingWallet] = true;

        isFeeExempt[autoLiquidityReceiver] = true;
        isTxLimitExempt[autoLiquidityReceiver] = true;

        totalFee = liquidityFee.add(marketingFee).add(burnFee);
        totalFeeIfSelling = totalFee.add(extraFeeOnSell);

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

   function changeTxLimit(uint256 newLimit) external onlyOwner {
        _maxTxAmount = newLimit;
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function changeFees(uint256 newLiqFee, uint256 newMarketingFee, uint256 newBurnFee, uint256 newExtraSellFee) external onlyOwner {
        require((newLiqFee + newMarketingFee + newBurnFee) <= 15, "Taxes cannot be greater than 15%");
        require(newExtraSellFee <= 10, "Added sell tax cannot be greater than 10%");

        liquidityFee = newLiqFee;
        marketingFee = newMarketingFee;
        burnFee = newBurnFee;
        extraFeeOnSell = newExtraSellFee;
        
        totalFee = liquidityFee.add(marketingFee).add(burnFee);
        totalFeeIfSelling = totalFee.add(extraFeeOnSell);
    }

    function changeFeeReceivers(address newLiquidityReceiver, address newMarketingWallet) external onlyOwner {
        autoLiquidityReceiver = newLiquidityReceiver;
        marketingWallet = newMarketingWallet;
    }

    function changeSwapBackSettings(bool _enabled, uint256 _percentage_base10000) external onlyOwner {
        swapAndLiquifyEnabled  = _enabled;
        swapThreshold = _totalSupply.div(10000).mul(_percentage_base10000);
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

        if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]){
            require(tradingOpen,"Trading not open yet");
            require(amount <= _maxTxAmount, "TX Limit Exceeded");

            if (recipient != pair) {
                uint256 heldTokens = balanceOf(recipient);                        
                require((heldTokens + amount) <= _walletMax,"Total Holding is currently limited, you can not buy that much.");
            }
        }

        if(msg.sender != pair 
        && !inSwapAndLiquify 
        && swapAndLiquifyEnabled 
        && _balances[address(this)] >= swapThreshold) { swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeApplicable = pair == recipient ? totalFeeIfSelling : totalFee;
        uint256 feeAmount = amount.mul(feeApplicable).div(100);

        if(burnFee > 0){
            uint256 burnTokens = feeAmount.mul(burnFee).div(totalFee); 
            _balances[DEAD] = _balances[DEAD].add(burnTokens);
            emit Transfer(sender, DEAD, burnTokens);

            feeAmount =  feeAmount.sub(burnTokens);

            if(removeBurnFromSupply){
                _totalSupply = _totalSupply.sub(burnTokens);
            }
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    // switch Trading
    function tradingStatus() public onlyOwner {
        tradingOpen = true;
        launchedAt = block.number;
    }

    function enableSupplyBurn(bool enabled) public onlyOwner {
        removeBurnFromSupply = enabled;
    }

    function swapBack() internal lockTheSwap {
        uint256 tokensToLiquify = swapThreshold;
        
        uint256 _feeTotal = totalFee.sub(burnFee);

        uint256 amountToLiquify = tokensToLiquify.mul(liquidityFee).div(_feeTotal).div(2);
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
        uint256 totalBNBFee = _feeTotal.sub(liquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);   
        uint256 amountBNBMarketing = amountBNB.sub(amountBNBLiquidity);

        payable(marketingWallet).transfer(amountBNBMarketing);

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

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(autoLiquidityReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function burn(uint256 _value) public{
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= _balances[_who]);
        _balances[_who] = _balances[_who].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Transfer(_who, DEAD, _value);
    }   

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}