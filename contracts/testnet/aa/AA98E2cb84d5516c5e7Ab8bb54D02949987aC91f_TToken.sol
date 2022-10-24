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

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

contract TToken is IBEP20, Ownable {
    string private constant _name = "TToken";
    string private constant _symbol = "TT";
    uint8 private constant _decimals = 18;

    uint256 _totalSupply = 1000000000 * 10**_decimals;
    uint256 liquidityFee = 1;
    uint256 devFee = 3;
    uint256 public totalFee = liquidityFee + devFee;
    uint256 totalFeeIfSelling = totalFee;
    uint256 maxWallet = (_totalSupply * 2) / 100;
    uint256 maxTransaction = (_totalSupply * 2) / 100;

    address public feeReceiver;
    address public autoLiquidityReceiver;

    mapping(address => uint256) _balanceOf;
    mapping(address => mapping(address => uint256)) _allowance;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isMaxWalletExempt;
    mapping(address => bool) public isBlacklisted;

    IDEXRouter public router;
    address public pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 3) / 2000;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        _balanceOf[owner()] = _totalSupply;
        _allowance[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[address(this)] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[feeReceiver] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[pair] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[owner()] = true;
        isMaxWalletExempt[pair] = true;

        feeReceiver = msg.sender;
        autoLiquidityReceiver = msg.sender;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

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
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
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
        if (_allowance[sender][msg.sender] != type(uint256).max) {
            require(
                amount <= _allowance[sender][msg.sender],
                "Insufficient Allowance"
            );
            _allowance[sender][msg.sender] -= amount;
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

        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= _balanceOf[sender], "Insufficient balance");
        require(
            !isBlacklisted[recipient] && !isBlacklisted[sender],
            "Address is blacklisted"
        );
        checkTxLimit(sender, amount);
        checkWalletSize(recipient, amount);
        if (
            msg.sender != pair &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            _balanceOf[address(this)] >= swapThreshold
        ) {
            swapBack();
        }

        _balanceOf[sender] -= amount;
        uint256 amountReceived = !isFeeExempt[sender]
            ? takeFee(sender, recipient, amount)
            : amount;
        _balanceOf[recipient] += amountReceived;
        emit Transfer(msg.sender, recipient, amountReceived);
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
        uint256 amountBNBDev = (amountBNB * devFee) / totalBNBFee;
        (
            bool devSuccess, /* bytes memory data */

        ) = payable(feeReceiver).call{value: amountBNBDev, gas: 30000}("");
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

    function blacklistAddress(address _address, bool _value)
        external
        onlyOwner
    {
        isBlacklisted[_address] = _value;
    }

    function bulkIsBlacklisted(address[] memory _accounts, bool _value)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _accounts.length; i++) {
            isBlacklisted[_accounts[i]] = _value;
        }
    }

    function setFees(uint256 _liquidityFee, uint256 _devFee)
        external
        onlyOwner
    {
        liquidityFee = _liquidityFee;
        devFee = _devFee;
        totalFee = liquidityFee + devFee;
        totalFeeIfSelling = totalFee;
    }

    function setMaxWallet(uint256 _maxWallet) external onlyOwner {
        maxWallet = (_totalSupply * _maxWallet) / 100;
    }

    function setMaxTransaction(uint256 _maxTransaction) external onlyOwner {
        maxTransaction = (_totalSupply * _maxTransaction) / 100;
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _feeReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        feeReceiver = _feeReceiver;
    }

    function setThreshold(uint256 _swapThreshold) external onlyOwner {
        swapThreshold = (_totalSupply * _swapThreshold) / 2000;
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

    function manualSend() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(feeReceiver).transfer(contractETHBalance);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountToken);
}