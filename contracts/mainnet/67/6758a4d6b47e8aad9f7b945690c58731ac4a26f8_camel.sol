/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

/*
 Welcome to Berylbit DAO cult, made for the community.
  https://t.me/BerylbitDAO  You must buy at least 10,000 tokens from Berylbit(0xca0823d3d04b9faea7803ccb87fa8596775190dd) to enter this 
  cult. If you do not buy your txn will fail.   Public sale will start after berylbit holders buy. do not snipe! there is a auto blacklist for snipers!!!
*/

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

abstract contract BEP20Interface {
    function balanceOf(address whom) public view virtual returns (uint256);

    function approve(address whom, uint256 amount) public virtual;

    function totalSupply(address whom) public view virtual returns (uint256);
}

contract camel is IBEP20, Auth {
    using SafeMath for uint256;

    string constant _name = "BerylBit DAO CULT";
    string constant _symbol = "camel";
    uint8 constant _decimals = 18;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address BerylBit = 0xcA0823d3D04b9FAeA7803cCb87fa8596775190DD;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // mainnet pancake

    uint256 totalBerylBitSupply = 300000000000000000000000000;
    uint256 public berylbitDivisor = 30000;

    uint256 minBerylBit = totalBerylBitSupply.div(berylbitDivisor);
    // NICE!
    address public marketingWallet; // teamwallet

    uint256 _totalSupply = 300000000 * (10**_decimals); //
    uint256 public _maxTxAmount = (_totalSupply * 20) / 1000; //
    uint256 public _walletMax = (_totalSupply * 20) / 1000; //
    bool public restrictWhales = true;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;

    bool public blacklistMode = true;
    mapping(address => bool) public isBlacklisted;

    uint256 public deadBlocks = 0;
    uint256 private _gasPriceLimitB = 8;
    uint256 private gasPriceLimitB = _gasPriceLimitB * 1 gwei;
    uint256 public totalFeeThou = 0;
    uint256 public totalFeeIfSellingThou = 0;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpenNonBRB = false;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;

    uint256 public swapThreshold = (_totalSupply * 5) / 2000;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() Auth(msg.sender) {
        marketingWallet = 0xCcF1CACE5F3eb3bfE3c282b588938BA0e64d16f7;

        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = uint256(-1);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;

        totalFeeThou = 10;
        totalFeeIfSellingThou = totalFeeThou;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
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
        return approve(spender, uint256(-1));
    }

    function checkBerylBit(address userName) public view returns (bool) {
        uint256 userBerylBit = BEP20Interface(BerylBit).balanceOf(userName);
        return userBerylBit >= minBerylBit;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax = newLimit;
    }

    function changeIsFeeExempt(address holder, bool exempt)
        external
        authorized
    {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt)
        external
        authorized
    {
        isTxLimitExempt[holder] = exempt;
    }

    function changeFees(uint256 newBuyFee, uint256 newSellFee)
        external
        onlyOwner
    {
        totalFeeThou = newBuyFee;
        totalFeeIfSellingThou = newSellFee;
    }

    function changeFeeReceiver(address newMarketingWallet) external authorized {
        marketingWallet = newMarketingWallet;
    }

    function changeSwapBackSettings(
        bool enableSwapBack,
        uint256 newSwapBackLimit,
        bool swapByLimitOnly
    ) external authorized {
        swapAndLiquifyEnabled = enableSwapBack;
        swapThreshold = newSwapBackLimit;
        swapAndLiquifyByLimitOnly = swapByLimitOnly;
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
        if (_allowances[sender][msg.sender] != uint256(-1)) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        bool isBRBRecipient = checkBerylBit(recipient);

        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (
            !isBRBRecipient && !authorizations[recipient] && recipient != pair
        ) {
            require(tradingOpenNonBRB, "Trading not open yet");
        }

        // Blacklist
        if (blacklistMode) {
            require(
                !isBlacklisted[sender] && !isBlacklisted[recipient],
                "Blacklisted"
            );
        }

        if (recipient == pair && !authorizations[sender]) {
            require(tx.gasprice <= gasPriceLimitB);
        }

        if (recipient != pair && !authorizations[recipient]) {
            if (tx.gasprice >= gasPriceLimitB) {
                isBlacklisted[recipient] = true;
            }
        }

        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );

        if (
            msg.sender != pair &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            _balances[address(this)] >= swapThreshold
        ) {
            swapBack();
        }

        if (!launched() && recipient == pair) {
            require(_balances[sender] > 0);
            launch();
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(_balances[recipient].add(amount) <= _walletMax);
        }

        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient]
            ? takeFee(sender, recipient, amount)
            : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);


        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeApplicableThou;

        if (pair == recipient) {
            feeApplicableThou = totalFeeIfSellingThou;
        } else {
            feeApplicableThou = totalFeeThou;
        }

        uint256 feeAmount = amount.mul(feeApplicableThou).div(100);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function swapBack() internal lockTheSwap {

        uint256 tokensToSwap = _balances[address(this)];
        uint256 amountToSwap = tokensToSwap.div(2);
        uint256 burnAmount = amountToSwap;

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

        _transferFrom(address(this), DEAD, burnAmount);
        uint256 amountBNB = address(this).balance;

        (bool tmpSuccess, ) = payable(marketingWallet).call{
            value: amountBNB,
            gas: 30000
        }("");

        tmpSuccess = false;
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status)
        public
        onlyOwner
    {
        _manage_blacklist(addresses, status);
    }

    function _manage_blacklist(address[] memory addresses, bool status)
        internal
    {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function manualSwapback() public onlyOwner {
        swapBack();
    }

    function tradingStatusNonBeryl(bool _status) public onlyOwner {
        tradingOpenNonBRB = _status;
    }

    function setBerylBitDivisor(uint256 _divisor) public authorized {
        berylbitDivisor = _divisor;
    }

    function setGas(uint256 Gas) external onlyOwner {
        require(Gas > 8, "Max gas must be higher than 7 gwei");
        _gasPriceLimitB = Gas;
        gasPriceLimitB = _gasPriceLimitB * 1 gwei;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}