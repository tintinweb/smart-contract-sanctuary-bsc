/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract BartMAN is IBEP20, Auth {
    uint256 public constant MASK = type(uint128).max;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant DEAD_NON_CHECKSUM =
        0x000000000000000000000000000000000000dEaD;
    address constant _dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string constant _name = "BartMAN";
    string constant _symbol = "$BM";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100_000_000_000_000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;

    uint256 internal liquidityFee = 1;
    uint256 internal MarketingFee = 9;
    uint256 internal sellliquidityFee = 1;
    uint256 internal sellMarketingFee = 9;
    uint256 internal totalFee = 10;

    uint256 internal feeDenominator = 100;
    address internal MarketingFeeReceiver =
        address(0x3AD0AA4a19195dC40E820eFb6aba84759D8cfAD9);

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event UpdatedThresholdValues(bool status, uint256 threshold);
    event UpdatedBuyTaxFeePercentages(uint256 buyTaxFee);
    event UpdatedSellTaxFeePercentages(uint256 sellTaxFee);

    constructor() Auth(address(0xA51643AEd6133D81B22E45162e135C46E5EA3BDa)) {
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();
        isFeeExempt[address(0xA51643AEd6133D81B22E45162e135C46E5EA3BDa)] = true;

        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[address(0xA51643AEd6133D81B22E45162e135C46E5EA3BDa)] = _totalSupply;
        emit Transfer(address(0), address(0xA51643AEd6133D81B22E45162e135C46E5EA3BDa), _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = shouldNotTakeFee(sender, recipient)
            ? amount
            : takeFee(sender, recipient, amount);

        if (shouldSwapBack()) {
            swapBack();
        }

        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function shouldNotTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        return isFeeExempt[sender] || isFeeExempt[recipient];
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getTotalFee(bool selling) internal returns (uint256) {
        if (selling) {
            totalFee = sellliquidityFee + sellMarketingFee;
            return totalFee;
        }
        if (!selling) {
            totalFee = liquidityFee + MarketingFee;
            return totalFee;
        }
        return (liquidityFee + MarketingFee);
    }

    function takeFee(
        address sender,
        address receiver,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeAmount = (amount * (getTotalFee(receiver == pair))) /
            (feeDenominator);
        _balances[address(this)] = _balances[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return (amount - feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator
        )
            ? 0
            : sellliquidityFee;
        uint256 amountToLiquify = (swapThreshold * (dynamicLiquidityFee)) /
            (totalFee) /
            (2);
        uint256 amountToSwap = swapThreshold - (amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance - (balanceBefore);

        uint256 totalBNBFee = totalFee - (dynamicLiquidityFee / (2));

        uint256 amountBNBLiquidity = (amountBNB * (dynamicLiquidityFee)) /
            (totalBNBFee) /
            (2);

        uint256 amountBNBMarketing = (amountBNB * (sellMarketingFee)) /
            (totalBNBFee);
        if (amountBNBMarketing > 0) {
            payable(MarketingFeeReceiver).transfer(amountBNBMarketing);
        }

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
        if (address(this).balance > 0) {
            payable(MarketingFeeReceiver).transfer(address(this).balance);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setBuyFees(uint256 _buyLiquidityFee, uint256 _buyMarketingFee)
        external
        authorized
    {
        liquidityFee = _buyLiquidityFee;
        MarketingFee = _buyMarketingFee;
        require(
            (liquidityFee + MarketingFee) <= 10,
            "You can't set more than 10%"
        );
        emit UpdatedBuyTaxFeePercentages((liquidityFee + MarketingFee));
    }

    function setSellFees(uint256 _SellLiquidityFee, uint256 _SellMarketingFee)
        external
        authorized
    {
        sellliquidityFee = _SellLiquidityFee;
        sellMarketingFee = _SellMarketingFee;
        require(
            (sellliquidityFee + sellMarketingFee) <= 15,
            "You can't set more than 15%"
        );
        emit UpdatedSellTaxFeePercentages(
            (sellliquidityFee + sellMarketingFee)
        );
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        authorized
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        emit UpdatedThresholdValues(swapEnabled, swapThreshold);
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        authorized
    {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_totalSupply - (balanceOf(DEAD)) - (balanceOf(ZERO)));
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return (accuracy * (balanceOf(pair) * (2))) / (getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}