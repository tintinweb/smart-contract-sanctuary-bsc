// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./Address.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IPYE.sol";
import "./IERC20.sol";
import "./IWETH.sol";
import "./IPYESwapFactory.sol";
import "./IPYESwapPair.sol";
import "./IPYESwapRouter.sol";


contract MoonForce is IPYE, Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    // Fees
    struct Fees {
        uint256 marketingFee;
        uint256 buybackFee;
        address marketingAddress;
    }

    // Transaction fee values
    struct FeeValues {
        uint256 transferAmount;
        uint256 marketing;
        uint256 buyBack;
    }


    // Fee Type / Value
    mapping (string => uint) feeType;

    // Token details
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _tTotal = 10 * 10**9 * 10**9;

    // Users states
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isBountyExempt;


    string constant _name = "TestToken";
    string constant _symbol = "TEST";
    uint8 constant _decimals = 9;

    Fees public _defaultFees;
    Fees private _previousFees;
    Fees private _emptyFees;

    IPYESwapRouter public pyeSwapRouter;
    address public pyeSwapPair;
    address public WBNB;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = 5 * 10**8 * 10**9;

    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;

    bool public autoBuybackEnabled = false;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _tTotal / 2000; // 0.005%
    bool private inSwap;

    modifier swapping() { inSwap = true; _; inSwap = false; }

    event BuybackMultiplierActive(uint256 duration);

    constructor(address _router, address _marketing) {
        _balances[_msgSender()] = _tTotal;

        pyeSwapRouter = IPYESwapRouter(_router);
        WBNB = pyeSwapRouter.WETH();
        pyeSwapPair = IPYESwapFactory(pyeSwapRouter.factory())
        .createPair(address(this), WBNB, true);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(pyeSwapRouter)] = true;
        _isExcludedFromFee[pyeSwapPair] = true;

        isTxLimitExempt[_msgSender()] = true;
        isTxLimitExempt[pyeSwapPair] = true;
        isTxLimitExempt[address(pyeSwapRouter)] = true;

        isBountyExempt[pyeSwapPair] = true;
        isBountyExempt[address(this)] = true;
        isBountyExempt[_burnAddress] = true;

        _defaultFees = Fees(
            300,
            100,
            _marketing
        );

        // initialize feeType
        feeType["buyBackFee"] = 0; // 1%
        feeType["stakingLPFee"] = 0; // 0%

        IPYESwapPair(pyeSwapPair).updateTotalFee(1400);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMarketingPercent(uint256 _marketingFee) external onlyOwner {
        _defaultFees.marketingFee = _marketingFee;
    }

    function setBuyBackPercent(uint256 _burnFee) external onlyOwner {
        _defaultFees.buybackFee = _burnFee;
    }

    function setMarketingAddress(address _marketing) external onlyOwner {
        require(_marketing != address(0), "PYE: Address Zero is not allowed");
        _defaultFees.marketingAddress = _marketing;
    }

    function updateRouterAndPair(address _router, address _pair) public onlyOwner {
        _isExcludedFromFee[address(pyeSwapRouter)] = false;
        _isExcludedFromFee[pyeSwapPair] = false;
        pyeSwapRouter = IPYESwapRouter(_router);
        pyeSwapPair = _pair;
        WBNB = pyeSwapRouter.WETH();

        _isExcludedFromFee[address(pyeSwapRouter)] = true;
        _isExcludedFromFee[pyeSwapPair] = true;

        isBountyExempt[pyeSwapPair] = true;

        isTxLimitExempt[pyeSwapPair] = true;
        isTxLimitExempt[address(pyeSwapRouter)] = true;

        IPYESwapPair(pyeSwapPair).updateTotalFee(getTotalFee());
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**4
        );
    }

    //to receive BNB from pyeRouter when swapping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (FeeValues memory) {
        FeeValues memory values = FeeValues(
            0,
            calculateFee(tAmount, _defaultFees.marketingFee),
            calculateFee(tAmount, _defaultFees.buybackFee)
        );

        values.transferAmount = tAmount.sub(values.marketing).sub(values.buyBack);
        return values;
    }

    function calculateFee(uint256 _amount, uint256 _fee) private pure returns (uint256) {
        if(_fee == 0) return 0;
        return _amount.mul(_fee).div(
            10**4
        );
    }

    function removeAllFee() private {
        _previousFees = _defaultFees;
        _defaultFees = _emptyFees;
    }

    function restoreAllFee() private {
        _defaultFees = _previousFees;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        checkTxLimit(from, amount);

        if(shouldBuyAndLiquify()){ buyAndLiquify(); }
        if(shouldAutoBuyback()){ triggerAutoBuyback(); }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        //transfer amount, it will take tax
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();

        FeeValues memory _values = _getValues(amount);
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(_values.transferAmount);
        _takeFees(_values);

        emit Transfer(sender, recipient, _values.transferAmount);

        if(!takeFee)
            restoreAllFee();
    }

    function _takeFees(FeeValues memory values) private {
        _takeFee(values.marketing, _defaultFees.marketingAddress);
        _takeFee(values.buyBack, _burnAddress);
    }

    function _takeFee(uint256 tAmount, address recipient) private {
        if(recipient == address(0)) return;
        if(tAmount == 0) return;

        _balances[address(this)] = _balances[address(this)].add(tAmount);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldBuyAndLiquify() internal view returns (bool) {
        return msg.sender != pyeSwapPair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pyeSwapPair
        && !inSwap
        && autoBuybackEnabled
        && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number // After N blocks from last buyback
        && address(this).balance >= autoBuybackAmount;
    }

    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, _burnAddress);
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        pyeSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(_burnAddress)).sub(balanceOf(address(0)));
    }

    function getTotalFee() internal view returns (uint256) {
        return _defaultFees.marketingFee
            .add(_defaultFees.buybackFee);
    }

    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external onlyOwner {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external onlyOwner {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function clearBuybackMultiplier() external onlyOwner {
        buybackMultiplierTriggeredAt = 0;
    }

    function buyAndLiquify() internal swapping {
        uint256 amountToSwap = _balances[address(this)];

        _approve(address(this), address(pyeSwapRouter), amountToSwap);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;

        pyeSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalFee = getTotalFee();
        uint256 amountBNBMarketing = amountBNB.mul(_defaultFees.marketingFee).div(totalFee);

        payable(_defaultFees.marketingAddress).transfer(amountBNBMarketing);
    }
}