/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// Sources flattened with hardhat v2.12.6 https://hardhat.org

// File contracts/interfaces/IDEXFactory.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


// File contracts/interfaces/IDEXRouter.sol

pragma solidity 0.8.17;

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


// File contracts/interfaces/IERC20.sol

interface IERC20 {
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


// File contracts/interfaces/ITaxHandler.sol

pragma solidity 0.8.17;

interface ITaxHandler {
    function process() external;

    function setRewardPool(address _address) external;
    function setLiquidityPool(address _address) external;
    function setOperationsPool(address _address) external;
    function setMarketingPool(address _address) external;
    function setCharityPool(address _address) external;

    function setMinPeriod(uint256 _minPeriod) external;

    function setRewardpoolTax(uint256 _rewardTax) external;
    function setLiquidityTax(uint256 _liquidityTax) external;
    function setOperationsTax(uint256 _operationsTax) external;
    function setMarketingTax(uint256 _marketingTax) external;
    function setCharityTax(uint256 _charityTax) external;
}


// File contracts/lib/Auth.sol

pragma solidity 0.8.17;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
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
        require(adr!=address(0));
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


// File contracts/src/TaxHandler.sol

pragma solidity 0.8.17;





contract TaxHandler is ITaxHandler,Auth {
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public rewardPool;
    address public liquidityPool;
    address public operationsPool;
    address public marketingPool;
    address public charityPool;
    IERC20 public token;
    uint256 public taxToReward;
    uint256 public taxToLiquidity;
    uint256 public taxToOperations;
    uint256 public taxToMarketing;
    uint256 public taxToCharity;
    uint256 public lastDistributeTime;

    IDEXRouter public router;
    uint256 public minPeriod = 1 hours;

    constructor(address _router) Auth(msg.sender){
        token = IERC20(msg.sender);
        router = IDEXRouter(_router);
    }

    function process() external override {
        uint256 amount = token.balanceOf(address(this));
        if(amount>0&&shouldDistribute()) {
            lastDistributeTime = block.timestamp;
            uint256 totalTax = taxToReward + taxToLiquidity + taxToOperations + taxToMarketing + taxToCharity;
            uint256 amountForReward = amount * taxToReward / totalTax;
            uint256 amountForLiquidity = amount*taxToLiquidity / totalTax;
            uint256 amountForOperations = amount*taxToOperations / totalTax;
            uint256 amountForMarketing = amount*taxToMarketing / totalTax;
            uint256 amountForCharity = amount*taxToCharity / totalTax;

            token.transfer(rewardPool, amountForReward);

            addLiquidity(amountForLiquidity);
            swapTokens(amountForOperations, operationsPool);
            swapTokens(amountForMarketing, marketingPool);
            swapTokens(amountForCharity, charityPool);
        }
    }

    function swapTokens(
        uint256 amount,
        address recipient
    ) internal {
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = BUSD;
        token.approve(address(router), amount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            recipient, 
            block.timestamp
        );
    }

    function addLiquidity(
        uint256 tokenAmount
    ) internal {
        uint256 halfTokenAmount = tokenAmount / 2;
        uint256 busdAmount = tokenAmount - halfTokenAmount;
        uint256 busdBalanceBefore = IERC20(BUSD).balanceOf(address(this));
        swapTokens(halfTokenAmount, address(this));
        uint256 busdBalanceAfter = IERC20(BUSD).balanceOf(address(this));
        uint256 busdBalance = busdBalanceAfter - busdBalanceBefore;
        IERC20(BUSD).approve(address(router), busdBalance);
        token.approve(address(router), halfTokenAmount);
        router.addLiquidity(
            address(token),
            BUSD,
            halfTokenAmount,
            busdBalance,
            0,
            0,
            address(this),
            block.timestamp
        );
    }   

    function setRewardPool(address _address) external override authorized {
        rewardPool = _address;
    }
    function setLiquidityPool(address _address) external override authorized {
        liquidityPool = _address;
    }
    function setOperationsPool(address _address) external override authorized {
        operationsPool = _address;
    }
    function setMarketingPool(address _address) external override authorized {
        marketingPool = _address;
    }
    function setCharityPool(address _address) external override authorized {
        charityPool = _address;
    }
    function shouldDistribute() internal view returns(bool) {
        return lastDistributeTime + minPeriod < block.timestamp;
    }
    function setMinPeriod(uint256 _minPeriod) external override authorized {
        minPeriod = _minPeriod;
    }
    function setRewardpoolTax(uint256 _rewardTax) external override authorized {
        taxToReward = _rewardTax;
    }
    function setLiquidityTax(uint256 _liquidityTax) external override authorized {
        taxToLiquidity = _liquidityTax;
    }
    function setOperationsTax(uint256 _operationsTax) external override authorized {
        taxToOperations = _operationsTax;
    }
    function setMarketingTax(uint256 _marketingTax) external override authorized {
        taxToMarketing = _marketingTax;
    }
    function setCharityTax(uint256 _charityTax) external override authorized {
        taxToCharity = _charityTax;
    }
}


// File contracts/src/Strelka.sol

pragma solidity 0.8.17;






contract Strelka is IERC20, Auth {
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    string constant _name = "Strelka AI";
    string constant _symbol = "STRELKA_AI";
    uint8 constant _decimals = 18;
    
    uint256 constant _totalSupply = 100000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public taxRewardPool = 100;
    uint256 public taxLiquidity = 100;
    uint256 public taxOperations = 100;
    uint256 public taxMarketing = 300;
    uint256 public taxCharity = 100;
    uint256 public feeDenominator = 10000;
    
    IDEXRouter public router;
    address public pair;
    bool public addingLiquidity;
    bool processing = false;
    mapping (address => bool) isTxLimitExempt;
    uint256 public _maxTxAmount = 450000 * (10 ** _decimals);
    bool public antiBotEnabled = true;
    uint256 public cooldownTime = 30 seconds;
    mapping(address => uint256) public purchasedTime;

    ITaxHandler public taxHandler;

    modifier process() {
        processing = true; _; processing = false;
    }

    constructor (
        address _dexRouter,
        address _admin
    ) Auth(_admin) {
        router = IDEXRouter(_dexRouter);
        addingLiquidity = true;
        pair = IDEXFactory(router.factory()).createPair(BUSD, address(this));

        taxHandler = new TaxHandler(_dexRouter);
        taxHandler.setRewardpoolTax(taxRewardPool);
        taxHandler.setLiquidityTax(taxLiquidity);
        taxHandler.setOperationsTax(taxOperations);
        taxHandler.setMarketingTax(taxMarketing);
        taxHandler.setCharityTax(taxCharity);

        _allowances[address(this)][address(router)] = _totalSupply;
        _allowances[address(taxHandler)][address(router)] = _totalSupply;

        isTxLimitExempt[_admin] = true;

        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[_admin] = _totalSupply;
        emit Transfer(address(0), _admin, _totalSupply);

        addingLiquidity = false;
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
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(sender==address(taxHandler)) {
            return _basicTransfer(sender, recipient, amount);
        }

        if(sender==address(pair)) { // When buying STRELKA in BUSD
            if(antiBotEnabled) {
                checkBot(sender, recipient, amount);
            }
            purchasedTime[recipient] = block.timestamp;
            _balances[sender] = _balances[sender] - amount;
            uint256 amountReceived = takeTax(sender, amount);
            _balances[recipient] = _balances[recipient] + amountReceived;
            emit Transfer(sender, recipient, amountReceived);
            return true;
        } else if(!addingLiquidity && recipient==address(pair)) { 
            _balances[sender] = _balances[sender] - amount;
            uint256 amountReceived = takeTax(sender, amount);
            _balances[recipient] = _balances[recipient] + amountReceived;
            emit Transfer(sender, recipient, amountReceived);
            return true;
        } else {
            if(shouldProcess()) {
                addingLiquidity = true;
                processFee();
                addingLiquidity = false;
            }
            return _basicTransfer(sender, recipient, amount);
        }
    }

    function checkBot(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        require(block.timestamp>purchasedTime[recipient]+cooldownTime, "You can make another purchase after cooldown time");
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function shouldProcess() internal view returns (bool) {
        return msg.sender != pair
        && !processing;
    }

    function processFee() internal process {
        try taxHandler.process() {} catch {}
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeTax(address sender, uint256 amount) internal returns (uint256) {
        uint256 totalTax = taxRewardPool + taxLiquidity + taxOperations + taxMarketing + taxCharity;
        uint256 buyTaxAmount = amount*(totalTax)/feeDenominator;
        _balances[address(taxHandler)] = _balances[address(taxHandler)] + buyTaxAmount;
        emit Transfer(sender, address(taxHandler), buyTaxAmount);
        return amount - buyTaxAmount;
    }

    function setTaxs(
        uint256 _reward, 
        uint256 _liquidity,
        uint256 _operations,
        uint256 _marketing,
        uint256 _charity,
        uint256 _feeDenominator
    ) external onlyOwner {
        require(_feeDenominator<=10000, "Fee denominator can not be set over 100%");
        uint256 _total = _reward + _liquidity + _operations + _marketing + _charity;
        require(_total<=_feeDenominator/10, "Total tax can not be set over 10%"); /// Tax cannot exceed 10%

        taxRewardPool = _reward;
        taxLiquidity = _liquidity;
        taxOperations = _operations;
        taxMarketing = _marketing;
        taxCharity = _charity;
        feeDenominator = _feeDenominator;

        taxHandler.setRewardpoolTax(_reward);
        taxHandler.setLiquidityTax(_liquidity);
        taxHandler.setOperationsTax(_operations);
        taxHandler.setMarketingTax(_marketing);
        taxHandler.setCharityTax(_charity);
    }

    function setAddingLiquidity(bool _addingLiquidity) external onlyOwner {
        addingLiquidity = _addingLiquidity;
    }

    function setRewardPool(address _address) external onlyOwner {
        taxHandler.setRewardPool(_address);
    }
    function setLiquidityPool(address _address) external onlyOwner {
        taxHandler.setLiquidityPool(_address);
    }
    function setOperationsPool(address _address) external onlyOwner {
        taxHandler.setOperationsPool(_address);
    }
    function setMarketingPool(address _address) external onlyOwner {
        taxHandler.setMarketingPool(_address);
    }
    function setCharityPool(address _address) external onlyOwner {
        taxHandler.setCharityPool(_address);
    }
    function setMinPeriod(uint256 _minPeriod) external onlyOwner {
        taxHandler.setMinPeriod(_minPeriod);
    }
    function setTxLimit(uint256 amount) external onlyOwner {
        require(amount > 4000);
        _maxTxAmount = amount * (10**_decimals);
    }
    function setAntibot(bool _enable) external onlyOwner {
        antiBotEnabled = _enable;
    }
    function setCooldownTime(uint256 _time) external onlyOwner {
        require(_time < 300);
        cooldownTime = _time;
    }
    function withdrawETH(address payable _addr, uint256 amount) public onlyOwner {
        _addr.transfer(amount);
    }
}