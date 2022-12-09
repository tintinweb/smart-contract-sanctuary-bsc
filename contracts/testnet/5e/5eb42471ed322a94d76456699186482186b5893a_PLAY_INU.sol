/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

/*
  _____  _           __     __  _____ _   _ _    _ 
 |  __ \| |        /\\ \   / / |_   _| \ | | |  | |
 | |__) | |       /  \\ \_/ /    | | |  \| | |  | |
 |  ___/| |      / /\ \\   /     | | | . ` | |  | |
 | |    | |____ / ____ \| |     _| |_| |\  | |__| |
 |_|    |______/_/    \_\_|    |_____|_| \_|\____/ 
                                                   
                                                   
                                                                        
*/

pragma solidity ^0.8.0;


interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function add_liquedityETH(
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
            uint256 _liquedity
        );

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

interface IERC20Extended {
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
// This contract helps to add Authorizers
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

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}



interface IDividendDistributor {
    function setDistributionStandard(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function claimDividend(address _user) external;

    function getPaidEarnings(address shareholder)
        external
        view
        returns (uint256);

    function getUnpaidEarnings(address shareholder)
        external
        view
        returns (uint256);

    function totalDistributed() external view returns (uint256);
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20Extended public BUSD =
        IERC20Extended(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    IDexRouter public router;

    address[] public shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10**BUSD.decimals());

    uint256 currentIndex;

    bool initialized;
    modifier initializer() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address _router) {
        _token = msg.sender;
        router = IDexRouter(_router);
    }

    function setDistributionStandard(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }


    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }
    //This function distribute the amounts
    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend(address _user) external {
        distributeDividend(_user);
    }

    function getPaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return shares[shareholder].totalRealised;
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

// main contract
contract PLAY_INU is IERC20Extended, Auth {
    using SafeMath for uint256;

    string private constant _name = "PLAY INU";
    string private constant _symbol = "PNU";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_00 * 10**_decimals;

    address public BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);


    IDexRouter public router;    //Router
    address public pair;         //Pair
    address public liquedityReceiver;
    address public marketFeeReceiver;
    address public devFeeReceiver;

   

    uint256 public totalBuyFee = 0;
    uint256 public totalSellFee = 0;
    uint256 public feeDenominator = 100;

    DividendDistributor public distributor;
    uint256 public distributorGas = 500000;
    uint256 public target_liquedity = 25;
    uint256 public target_liquedityDenominator = 100;


    uint256 _liquedityBuyFee = 2;      // 2% on Buying
    uint256 _reflectionBuyFee = 9;     // 9% on Buying
    uint256 _marketBuyFee = 1;         // 1% on Buying
    uint256 _devBuyFee = 0;            // 0% on Buying

    uint256 _liqueditySellFee = 2;     // 2% on Selling
    uint256 _reflectionSellFee = 9;    // 9% on Selling
    uint256 _marketSellFee = 1;        // 1% on Selling
    uint256 _devSellFee = 0;           // 0% on Selling

    uint256 _liquedityFeeCounter;
    uint256 _reflectionFeeCounter;
    uint256 _marketFeeCounter;
    uint256 _devFeeCounter;


    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isDividendExempt;

    bool public enableSwap = true;
    uint256 public swapLimit = _totalSupply / 20000;

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

// intializing the addresses

    constructor(
    ) Auth(msg.sender) {
        // address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
        address _router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        liquedityReceiver = 0xBA02934d2DD50445Fd08E975eDE02CA6C609d4db;
        marketFeeReceiver = 0xef0f9017a5f8E8b07F2035392704ebFa9be8C85E;
        devFeeReceiver = 0x3Ad05873811E988Cb0840aFD239190f9ac6c2d54;

        router = IDexRouter(_router);
        pair = IDexFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        distributor = new DividendDistributor(_router);



        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isFeeExempt[liquedityReceiver] = true;
        isFeeExempt[marketFeeReceiver] = true;
        isFeeExempt[devFeeReceiver] = true;
     


        _allowances[address(this)][address(router)] = _totalSupply;
        _allowances[address(this)][address(pair)] = _totalSupply;

        _balances[liquedityReceiver] = _totalSupply;
        emit Transfer(address(0), liquedityReceiver, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external pure override returns (uint256) {
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


    // Transfers Tokens

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transfer(sender, recipient, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        

      

        if (inSwap) {
            return _simpleTransfer(sender, recipient, amount);
        }
        
        if (shouldSwapBack()) {
            swapBack();
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived;
        if (isFeeExempt[sender] || isFeeExempt[recipient] || (sender != pair && recipient != pair)) {
            amountReceived = amount;
        } else {
            uint256 feeAmount;
            if (sender == pair) {
                feeAmount = amount.mul(totalBuyFee).div(feeDenominator);
                amountReceived = amount.sub(feeAmount);
                takeFee(sender, feeAmount);
                setBuyFeeCount(amount);
            } else {
                feeAmount = amount.mul(totalSellFee).div(feeDenominator);
                amountReceived = amount.sub(feeAmount);
                takeFee(sender, feeAmount);
                setSellFeeCount(amount);
            }
        }

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _simpleTransfer(
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

    // This function get calls internally to take fee 
    function takeFee(address sender, uint256 feeAmount)
        internal {
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
    }

    function setBuyFeeCount(uint256 _amount) internal {
        _liquedityFeeCounter = _amount.mul(_liquedityBuyFee).div(feeDenominator);
        _reflectionFeeCounter = _amount.mul(_reflectionBuyFee).div(
            feeDenominator
        );
        _marketFeeCounter = _amount.mul(_marketBuyFee).div(feeDenominator);
        _devFeeCounter = _amount.mul(_devBuyFee).div(feeDenominator);
    }

    function setSellFeeCount(uint256 _amount) internal {
        _liquedityFeeCounter = _amount.mul(_liqueditySellFee).div(feeDenominator);
        _reflectionFeeCounter = _amount.mul(_reflectionSellFee).div(
            feeDenominator
        );
        _marketFeeCounter = _amount.mul(_marketSellFee).div(feeDenominator);
        _devFeeCounter = _amount.mul(_devSellFee).div(feeDenominator);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            enableSwap &&
            _balances[address(this)] >= swapLimit;
    }

    function swapBack() internal swapping {
        uint256 totalFee = _liquedityFeeCounter
            .add(_reflectionFeeCounter)
            .add(_marketFeeCounter)
            .add(_devFeeCounter);
        
        uint256 dynamic_liquedityFee = isOverLiquified(
            target_liquedity,
            target_liquedityDenominator
        )
            ? 0
            : _liquedityFeeCounter;
        
        uint256 amountToLiquify = swapLimit
            .mul(dynamic_liquedityFee)
            .div(totalFee)
            .div(2);
        
        uint256 amountToSwap = swapLimit.sub(amountToLiquify);

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

        uint256 totalBNBFee = totalFee.sub(dynamic_liquedityFee.div(2));

        uint256 amountBNBForLiqudity = amountBNB
            .mul(dynamic_liquedityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBForReflection = amountBNB.mul(_reflectionFeeCounter).div(
            totalBNBFee
        );
        uint256 amountBNBForMarket = amountBNB.mul(_marketFeeCounter).div(
            totalBNBFee
        );
        uint256 amountBNBForDev = amountBNB.mul(_devFeeCounter).div(
            totalBNBFee
        );

        try distributor.deposit{value: amountBNBForReflection}() {} catch {}
        payable(marketFeeReceiver).transfer(amountBNBForMarket);
        payable(devFeeReceiver).transfer(amountBNBForDev);

        if (amountToLiquify > 0) {
            router.add_liquedityETH{value: amountBNBForLiqudity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquedityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBForLiqudity, amountToLiquify);
        }

        _liquedityFeeCounter = 0;
        _reflectionFeeCounter = 0;
        _marketFeeCounter = 0;
        _devFeeCounter = 0;
    }

    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    function getPaidDividend(address shareholder)
        public
        view
        returns (uint256)
    {
        return distributor.getPaidEarnings(shareholder);
    }

    function getUnpaidDividend(address shareholder)
        external
        view
        returns (uint256)
    {
        return distributor.getUnpaidEarnings(shareholder);
    }

    function getTotalDistributedDividend() external view returns (uint256) {
        return distributor.totalDistributed();
    }

    function setFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }



    function setDividendExempt(address holder, bool exempt)
        external
        authorized
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

 

    //Owner & Authoized user Can set the fees
    function setBuyFee(
        uint256 _liquedityFee,
        uint256 _reflectionFee,
        uint256 _marketFee,
        uint256 _devFee,
        uint256 _feeDenominator
    ) public authorized {
        _liquedityBuyFee = _liquedityFee;
        _reflectionBuyFee = _reflectionFee;
        _marketBuyFee = _marketFee;
        _devBuyFee = _devFee;
        totalBuyFee = _liquedityFee.add(_reflectionFee).add(_marketFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(totalBuyFee <= feeDenominator.mul(15).div(100), "Can't be greater than 15%");
    }

    function setSellFee(
        uint256 _liquedityFee,
        uint256 _reflectionFee,
        uint256 _marketFee,
        uint256 _devFee,
        uint256 _feeDenominator
    ) public authorized {
        _liqueditySellFee = _liquedityFee;
        _reflectionSellFee = _reflectionFee;
        _marketSellFee = _marketFee;
        _devSellFee = _devFee;
        totalSellFee = _liquedityFee.add(_reflectionFee).add(_marketFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(totalSellFee <= feeDenominator.mul(15).div(100), "Can't be greater than 15%");
    }

    function setFeeReceivers(
        address _liquedityReceiver,
        address _marketFeeReceiver,
        address _devFeeReceiver
    ) external authorized {
        liquedityReceiver = _liquedityReceiver;
        marketFeeReceiver = _marketFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }

    function setTargetLiquedity(uint256 _target, uint256 _denominator)
        external
        authorized
    {
        target_liquedity = _target;
        target_liquedityDenominator = _denominator;
    }

    function setSwapBack(bool _enabled, uint256 _amount)
        external
        authorized
    {
        enableSwap = _enabled;
        swapLimit = _amount;
    }


    function setDistributionStandard(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external authorized {
        distributor.setDistributionStandard(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000, "Gas must be lower than 750000");
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquedityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquedityBacking(accuracy) > target;
    }
}

// Library used to perfoem math operations
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}