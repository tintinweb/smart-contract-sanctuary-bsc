// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BabyETHMerge is IBEP20, Context, Ownable {
    string private _name = "Baby ETH Merge";
    string private _symbol = "Baby Merge";
    uint8 private _decimals = 18;
    uint256 public _totalSupply = 1000000000 * 10**_decimals;

    uint256 public liquidityFee = 1;
    uint256 public marketingFee = 2;
    uint256 public devFee = 1;
    uint256 public totalFee = liquidityFee + marketingFee + devFee;
    uint256 public totalFeeIfSelling = totalFee;

    uint256 public maxWallet = (_totalSupply * 3) / 100;
    uint256 public maxTransaction = (_totalSupply * 3) / 100;

    address public devWallet = 0xC76df58853797da8AF6cCDd3715c9C81821F0327;
    address public marketingWallet = 0xb75CbaFbF6Af96D1659eebc8ACef701e9a25BA72;
    address public autoLiquidityReceiver;

    mapping(address => uint256) public _balanceOf;
    mapping(address => mapping(address => uint256)) public _allowance;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isMaxWalletExempt;

    receive() external payable {}

    IDEXRouter public router;
    address public pair;
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 3) / 2000;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _balanceOf[owner()] = _totalSupply;
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowance[address(this)][address(router)] = type(uint256).max;
        isFeeExempt[address(this)] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[devWallet] = true;
        isFeeExempt[marketingWallet] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[pair] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[owner()] = true;
        isMaxWalletExempt[pair] = true;

        autoLiquidityReceiver = _msgSender();
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balanceOf[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowance[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowance[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(_msgSender(), recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowance[sender][_msgSender()] != type(uint256).max) {
            _allowance[sender][_msgSender()] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (
            _msgSender() != pair &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            _balanceOf[address(this)] >= swapThreshold
        ) {
            swapBack();
        }
        checkTxLimit(sender, amount);
        checkWalletSize(recipient, amount);
        require(amount <= _balanceOf[sender], "Insufficient balance.");
        _balanceOf[sender] -= amount;
        uint256 amountReceived = !isFeeExempt[sender]
            ? takeFee(sender, recipient, amount)
            : amount;
        _balanceOf[recipient] += amountReceived;
        emit Transfer(_msgSender(), recipient, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(amount <= _balanceOf[sender], "Insufficient balance.");
        _balanceOf[sender] -= amount;
        _balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(
            amount <= maxTransaction || isTxLimitExempt[sender],
            "Transaction limit exceeded."
        );
    }

    function checkWalletSize(address recipient, uint256 amount) internal view {
        require(
            _balanceOf[recipient] + amount <= maxWallet ||
                isMaxWalletExempt[recipient],
            "Wallet size exceeded."
        );
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeApplicable = pair == recipient
            ? totalFeeIfSelling
            : totalFee;
        uint256 feeAmount = (amount * feeApplicable) / 100;
        _balanceOf[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);
        return amount - feeAmount;
    }

    function swapBack() internal lockTheSwap {
        uint256 tokensToLiquify = _balanceOf[address(this)];
        uint256 amountToLiquify = (tokensToLiquify * liquidityFee) /
            totalFee /
            2;
        uint256 amountToSwap = tokensToLiquify - amountToLiquify;

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
        uint256 totalBNBFee = totalFee - (liquidityFee / 2);
        uint256 amountBNBLiquidity = (amountBNB * liquidityFee) /
            totalBNBFee /
            2;
        uint256 amountBNBMarketing = (amountBNB * marketingFee) / totalBNBFee;
        uint256 amountBNBDev = (amountBNB * devFee) / totalBNBFee;
        (
            bool MarketingSuccess, /* bytes memory data */

        ) = payable(marketingWallet).call{
                value: amountBNBMarketing,
                gas: 30000
            }("");
        require(MarketingSuccess, "receiver rejected ETH transfer");
        (
            bool devSuccess, /* bytes memory data */

        ) = payable(devWallet).call{value: amountBNBDev, gas: 30000}("");
        require(devSuccess, "receiver rejected ETH transfer");

        if (amountToLiquify > 0) {
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

    function setFees(
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        devFee = _devFee;
        totalFee = liquidityFee + marketingFee + devFee;
        totalFeeIfSelling = totalFee;
    }

    function setMaxWallet(uint256 _maxWallet) external onlyOwner {
        maxWallet = (_totalSupply * _maxWallet) / 1000;
    }

    function setMaxTransaction(uint256 _maxTransaction) external onlyOwner {
        maxTransaction = (_totalSupply * _maxTransaction) / 1000;
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _marketingWallet,
        address _devWallet
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingWallet = _marketingWallet;
        devWallet = _devWallet;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsMaxWalletExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isMaxWalletExempt[holder] = exempt;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapAndLiquifyEnabled = _enabled;
        swapThreshold = _amount;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
}