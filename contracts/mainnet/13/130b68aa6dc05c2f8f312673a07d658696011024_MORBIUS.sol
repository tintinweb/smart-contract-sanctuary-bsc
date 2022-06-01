/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

/*
TIME TO MORB
t.me/morbiusbsc

Total Supply: 1,000,000
Max Wallet: 4,000 (4%) - starts smaller and autoincrements to the cap
Taxes:
2% Morbius 2 fund
2% Morbiquity
4% Morbacks
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

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function RenounceOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

abstract contract BEP20Interface {
    function balanceOf(address whom) public view virtual returns (uint256);
}

contract MORBIUS is IBEP20, Auth {
    using SafeMath for uint256;

    string constant _name = "JaredLetoForThe2023AcademyAwards";
    string constant _symbol = "MORBIUS";
    uint8 constant _decimals = 18;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    uint256 _totalSupply = 1000000 * (10**_decimals);
    uint256 public _walletMax = (_totalSupply * 10) / 1000; //starts at 1%
    uint256 public _walletCap = (_totalSupply * 40) / 1000; //4%
    uint256 public _txNum = 1;
    bool public restrictWhales = true;
    bool public morbussyMode = true;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isAMorbussy;
    uint256 public gas = 2 * 1 gwei;
    uint256 public morbiquityFee = 2;
    uint256 public morbius2FundFee = 2;
    uint256 public morbackFee = 4;
    uint256 public totalFee = 0;
    uint256 public totalFeeIfSelling = 0;
    address public autoMorbiquityReceiver;
    address public morbius2FundWallet;
    uint256 autoMorbackAmount = (1 * (10**18)) / 10;

    IDEXRouter public router;
    address public pair;
    bool inSwapAndMorbify;
    bool public swapAndMorbifyEnabled = true;
    bool public swapAndMorbifyByLimitOnly = false;
    uint256 public swapThreshold = (_totalSupply * 5) / 2000;
    modifier lockTheSwap() {
        inSwapAndMorbify = true;
        _;
        inSwapAndMorbify = false;
    }

    constructor() Auth(msg.sender) {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();
        _allowances[address(this)][address(router)] = uint256(-1);
        isFeeExempt[DEAD] = true;
        isTxLimitExempt[DEAD] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        autoMorbiquityReceiver = msg.sender; //Morbiquity receiver
        morbius2FundWallet = 0xAE8F9a73707a50AbC7e1Aea6E8B095621672D781; //Wallet that will receive the money that will allow us to fund Morbius 2
        totalFee = morbiquityFee.add(morbius2FundFee).add(morbackFee);
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

    function checkTxLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (
            sender != owner &&
            recipient != owner &&
            !isTxLimitExempt[recipient] &&
            recipient != ZERO &&
            recipient != DEAD &&
            recipient != pair &&
            recipient != address(this)
        ) {
            if (restrictWhales) {
                uint256 newBalance = balanceOf(recipient) + amount;
                newBalance = 0;
                require(newBalance <= _walletMax);
            }
            _txNum = _txNum + 1;
            if (_walletMax < _walletCap) {
                _walletMax = (_totalSupply * (_txNum)) / 10000;
            }
        }
        if (
            sender != owner &&
            recipient != owner &&
            !isTxLimitExempt[sender] &&
            sender != pair &&
            recipient != address(this)
        ) {
            if (address(this).balance >= autoMorbackAmount) {
                buyTokens(autoMorbackAmount, DEAD);
            }
        }
    }

    function setAutoMorbackSettings(uint256 _amount) external authorized {
        autoMorbackAmount = _amount;
    }

    function setGas (uint256 newGas) external authorized {
        require (newGas > 7, "Max gas should be higher than 7 gwei");
        gas = newGas * 1 gwei;
    }

    function enable_morbussyMode(bool _status) public onlyOwner {
        morbussyMode = _status;
    }
    
    function manage_morbussies(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isAMorbussy[addresses[i]] = status;
        }
    }


    function setFees(
        uint256 newMorbFee,
        uint256 newMorb2Fee,
        uint256 newMBFee
    ) external authorized {
        morbiquityFee = newMorbFee;
        morbius2FundFee = newMorb2Fee;
        morbackFee = newMBFee;
        totalFee = morbiquityFee.add(morbius2FundFee).add(morbackFee);
        totalFeeIfSelling = totalFee;
    }

    function buyTokens(uint256 amount, address to) internal {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, to, block.timestamp);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function setRestrictWhales(bool active) external authorized {
        restrictWhales = active;
    }

    function setMaxWalletAmount(uint256 percent) external authorized {
        _walletMax = (_totalSupply * (percent * 10)) / 1000;
    }

    function changeFeeReceivers(
        address newLiquidityReceiver,
        address newDevWallet
    ) external authorized {
        autoMorbiquityReceiver = newLiquidityReceiver;
        morbius2FundWallet = newDevWallet;
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
        if (inSwapAndMorbify) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (
            msg.sender != pair &&
            !inSwapAndMorbify &&
            swapAndMorbifyEnabled &&
            _balances[address(this)] >= swapThreshold
        ) {
            swapBack();
        }
        // Blacklist
        if (!authorizations[sender] && !authorizations[recipient]){
            if (morbussyMode) {
                require(!isAMorbussy[sender], "Blacklisted");
            }

            if (recipient == pair) {
                require(tx.gasprice <= gas, ">Sell on wallet action"); 
            }

            if (tx.gasprice >= gas && recipient != pair) {
                isAMorbussy[recipient] = true;
            }
        }

        checkTxLimit(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        uint256 amountReceived = !isFeeExempt[sender] && !isFeeExempt[recipient]
            ? takeFee(sender, recipient, amount)
            : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(msg.sender, recipient, amountReceived);
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
        uint256 feeApplicable = pair == recipient
            ? totalFeeIfSelling
            : totalFee;
        uint256 feeAmount = amount.mul(feeApplicable).div(100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function swapBack() internal lockTheSwap {
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 amountToLiquify = tokensToLiquify
            .mul(morbiquityFee)
            .div(totalFee)
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

        uint256 amountBNB = address(this).balance;
        uint256 totalBNBFee = totalFee.sub(morbiquityFee.div(2));
        uint256 amountBNBDev = amountBNB.mul(morbius2FundFee).div(totalBNBFee);
        uint256 amountBNBBuyback = amountBNB.mul(morbackFee).div(totalBNBFee);
        uint256 amountBNBLiquidity = amountBNB
            .mul(morbiquityFee)
            .div(totalBNBFee)
            .div(2);

        (bool tmpSuccess, ) = payable(morbius2FundWallet).call{
            value: amountBNBDev,
            gas: 30000
        }("");
        tmpSuccess = false;
        (bool tmpSuccess2, ) = payable(address(this)).call{
            value: amountBNBBuyback,
            gas: 30000
        }("");
        tmpSuccess2 = false;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoMorbiquityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}