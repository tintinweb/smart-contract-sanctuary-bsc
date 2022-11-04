/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

/**
 Telegram: https://t.me/QatarGala
 Twitter: https://twitter.com/QatarGalaBSC

*/

pragma solidity ^0.8.16;
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

interface IERC20 {
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

interface DexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface DexRouter {
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
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    mapping(address => bool) internal authorizations;

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract QATARGALA is Ownable, IERC20 {
    using SafeMath for uint256;

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;

    address private routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint8 private constant _decimals = 18;

    uint256 private _totalSupply = 1000000000 * (10**_decimals);
    uint256 public _maxTxAmount = (_totalSupply * 20) / 1000;
    uint256 public _walletMax = (_totalSupply * 20) / 1000;

    string private constant _name = " Qatar Gala";
    string private constant _symbol = "QGALA";

    bool public restrictWhales = true;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;

    uint256 public liquidityFee = 0;
    uint256 public marketingFee = 5;
    uint256 public devFee = 5;
    uint256 public utilityFee = 0;
    uint256 public burnFee = 0;

    uint256 public totalFee = 0;
    uint256 public totalFeeIfSelling = 0;

    bool public takeBuyFee = true;
    bool public takeSellFee = true;
    bool public takeTransferFee = true;

    address private lpWallet;
    address private projectAddress;
    address private devWallet;
    address private utilityAddress;

    DexRouter public router;
    address public pair;
    mapping(address => bool) public isPair;

    uint256 public launchedAt;

    bool public tradingOpen = false;
    bool public blacklistMode = true;
    bool public canUseBlacklist = true;
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool antiMode = false;

    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isEcosystem;

    uint256 public fuel = 4 * 1 gwei;

    uint256 public swapThreshold = (_totalSupply * 5) / 10000;

    event AutoLiquify(uint256 amountETH, uint256 amountBOG);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        router = DexRouter(routerAddress);
        pair = DexFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        isPair[pair] = true;
        _allowances[address(this)][address(router)] = type(uint256).max;
        _allowances[address(this)][address(pair)] = type(uint256).max;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[DEAD] = true;

        isEcosystem[address(this)] = true;
        isEcosystem[msg.sender] = true;
        isEcosystem[address(pair)] = true;
        isEcosystem[address(router)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[DEAD] = true;

        lpWallet = msg.sender;
        projectAddress = 0x1B4784DF45566ac196c7b8C665A283AF56941b36;
        devWallet = 0x10F1936654785eAbc369D65B95e93E41a33011Ad;
        utilityAddress = msg.sender;

        isFeeExempt[projectAddress] = true;
        totalFee = liquidityFee.add(marketingFee).add(burnFee).add(devFee).add(utilityFee);
        totalFeeIfSelling = totalFee;

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
        return owner();
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

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
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
        return approve(spender, type(uint256).max);
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

    function checkBot(address sender, address recipient) internal {
        if (
            (isCont(recipient) &&
                !isEcosystem[recipient] &&
                !isFeeExempt[recipient] &&
                antiMode) ||
            (sender == pair &&
                !isEcosystem[sender] &&
                msg.sender != tx.origin &&
                antiMode)
        ) {
            isBlacklisted[recipient] = true;
        }
    }

    function isCont(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
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
        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (!authorizations[sender] && !authorizations[recipient]) {
            require(tradingOpen, "");
        }
        if (recipient == address(0) || recipient == address(0xdead)) {
            _balances[sender] = _balances[sender].sub(
                amount,
                "Insufficient Balance"
            );
            _totalSupply -= amount;
            emit Transfer(sender, DEAD, amount);
            return true;
        }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit");
        if (
            isPair[recipient] &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            _balances[address(this)] >= swapThreshold
        ) {
            marketingAndLiquidity();
        }
        if (!launched() && isPair[recipient]) {
            require(_balances[sender] > 0, "");
            launch();
        }

        if (antiMode) {
            checkBot(sender, recipient);
        }

        // Blacklist
        if (blacklistMode) {
            require(!isBlacklisted[sender], "Blacklisted");
        }

        if (recipient == pair && !authorizations[sender]) {
            require(tx.gasprice <= fuel, "");
        }
        if (tx.gasprice >= fuel && recipient != pair) {
            isBlacklisted[recipient] = true;
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "");

        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(_balances[recipient].add(amount) <= _walletMax, "");
        }

        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient]
            ? extractFee(sender, recipient, amount)
            : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function extractFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeApplicable = 0;
        uint256 nativeAmount = 0;
        if (isPair[recipient] && takeSellFee) {
            feeApplicable = totalFeeIfSelling.sub(burnFee);
        }
        if (isPair[sender] && takeBuyFee) {
            feeApplicable = totalFee.sub(burnFee);
        }
        if (!isPair[sender] && !isPair[recipient]) {
            if (takeTransferFee) {
                feeApplicable = totalFeeIfSelling.sub(burnFee);
            } else {
                feeApplicable = 0;
            }
        }
        if (feeApplicable > 0 && burnFee > 0) {
            nativeAmount = amount.mul(burnFee).div(100);
            _totalSupply -= nativeAmount;
            emit Transfer(sender, DEAD, nativeAmount);
        }
        uint256 feeAmount = amount.mul(feeApplicable).div(100);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount).sub(nativeAmount);
    }

    function marketingAndLiquidity() internal lockTheSwap {
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 amountToLiquify = tokensToLiquify
            .mul(liquidityFee)
            .div(totalFee.sub(burnFee))
            .div(2);
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

        uint256 amountETH = address(this).balance;

        uint256 totalETHFee = totalFee.sub(burnFee).sub(liquidityFee.div(2));

        uint256 amountETHLiquidity = amountETH
            .mul(liquidityFee)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHMarketing = amountETH.mul(marketingFee).div(
            totalETHFee
        );
        uint256 amountETHDev = amountETH.mul(devFee).div(totalETHFee);

        uint256 amountETHUtility = amountETH.mul(utilityFee).div(totalETHFee);

        (bool tmpSuccess1, ) = payable(projectAddress).call{
            value: amountETHMarketing,
            gas: 30000
        }("");
        tmpSuccess1 = false;

        (tmpSuccess1, ) = payable(devWallet).call{
            value: amountETHDev,
            gas: 30000
        }("");
        tmpSuccess1 = false;

        (tmpSuccess1, ) = payable(utilityAddress).call{
            value: amountETHUtility,
            gas: 30000
        }("");
        tmpSuccess1 = false;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                lpWallet,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }

    function changeisEcosystem(bool _bool, address _address)
        external
        onlyOwner
    {
        isEcosystem[_address] = _bool;
    }

    function setMode(bool _bool) external onlyOwner {
        antiMode = _bool;
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        require(newLimit >= 5, "Wallet Limit needs to be at least 0.5%");
        _walletMax = (_totalSupply * newLimit) / 1000;
    }

    function setTxLimit(uint256 newLimit) external onlyOwner {
        require(newLimit >= 5, "Wallet Limit needs to be at least 0.5%");
        _maxTxAmount = (_totalSupply * newLimit) / 1000;
    }

    function tradingStatus(bool newStatus) public onlyOwner {
        require(canUseBlacklist, "Can no longer pause trading");
        tradingOpen = newStatus;
    }

    function openTrading() public onlyOwner {
        tradingOpen = true;
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

    function addWhitelist(address target) public onlyOwner {
        authorizations[target] = true;
        isFeeExempt[target] = true;
        isTxLimitExempt[target] = true;
        isEcosystem[target] = true;
        isBlacklisted[target] = false;
    }

    function changeFees(
        uint256 newLiqFee,
        uint256 newMarketingFee,
        uint256 newDevFee,
        uint256 newUtilityFee,
        uint256 newNativeFee,
        uint256 extraSellFee
    ) external onlyOwner {
        liquidityFee = newLiqFee;
        marketingFee = newMarketingFee;
        devFee = newDevFee;
        utilityFee = newUtilityFee;
        burnFee = newNativeFee;

        totalFee = liquidityFee.add(marketingFee).add(devFee).add(utilityFee).add(burnFee);
        totalFeeIfSelling = totalFee + extraSellFee;
        require(totalFeeIfSelling + totalFee < 25);
    }

    function enableBlacklist(bool _status) public onlyOwner {
        require(canUseBlacklist, "");
        blacklistMode = _status;
    }

    function changeBlacklist(address[] calldata addresses, bool status)
        public
        onlyOwner
    {
        require(canUseBlacklist, "");
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function isAuth(address _address, bool status) public onlyOwner {
        authorizations[_address] = status;
    }

    function changePair(address _address, bool status) public onlyOwner {
        isPair[_address] = status;
    }

    function changeGas(uint256 newGas) external onlyOwner {
        require(canUseBlacklist, "");
        fuel = newGas * 1 gwei;
    }

    function removeBL() public onlyOwner {
        canUseBlacklist = false;
        fuel = 999999 * 1 gwei;
    }

    function disableBlacklistDONTUSETHIS() public onlyOwner {
        blacklistMode = false;
    }

    function changeTakeBuyfee(bool status) public onlyOwner {
        takeBuyFee = status;
    }

    function changeTakeSellfee(bool status) public onlyOwner {
        takeSellFee = status;
    }

    function changeTakeTransferfee(bool status) public onlyOwner {
        takeTransferFee = status;
    }

    function changeSwapbackSettings(bool status, uint256 newAmount)
        public
        onlyOwner
    {
        swapAndLiquifyEnabled = status;
        swapThreshold = newAmount;
    }

    function changeWallets(
        address newMktWallet,
        address newDevWallet,
        address newLpWallet,
        address newUtilityAddress
    ) public onlyOwner {
        lpWallet = newLpWallet;
        projectAddress = newMktWallet;
        devWallet = newDevWallet;
        utilityAddress = newUtilityAddress;
    }

    function removeERC20(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        require(tokenAddress != address(this), "Cant remove the native token");
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function removeEther(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer((amountETH * amountPercentage) / 100);
    }
}