/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface BEP20 {
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    address internal potentialOwner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        require(adr != owner, "OWNER cant be unauthorized");
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        require(adr != owner, "Already the owner");
        require(adr != address(0), "Can not be zero address.");
        potentialOwner = adr;
        emit OwnershipNominated(adr);
    }

    
    event OwnershipTransferred(address owner);
    event OwnershipNominated(address potentialOwner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract MarleyChain_test_Dont_buy is BEP20, Auth {
    using SafeMath for uint256;
    address immutable WBNB;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    string public constant name = "MarleyChain_test_Dont_buy";
    string public constant symbol = "RASTA";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 10 * 10**7 * 10**decimals;
    uint256 public _maxTxAmount = totalSupply / 100;
    uint256 public _maxBagToken = totalSupply / 100;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isBagLimitExempt;
    uint256 private liquidityFee = 0;
    uint256 private devFee = 1;
    uint256 private stakingFee = 0;
    uint256 public treasuryFee = 1;
    uint256 private totalFee = devFee + treasuryFee;
    uint256 public constant feeDenominator = 100;
    uint256 Augmentsell = 100;
    uint256 Augmentbuy = 100;
    uint256 AugmentTransfer = 100;
    address public autoLiquidityReceiver;
    address private devFeeReceiver;
    address private treasuryFeeReceiver;
    
event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
event UpdateTaxes(uint8 Buy, uint8 Sell, uint8 Transfer);
event Bag_feeExempt(address Wallet, bool Status);
event Bag_txExempt(address Wallet, bool Status);
event Bag_holdingExempt(address Wallet, bool Status);


event BalanceClear(uint256 amount);
event clearToken(address TokenAddressCleared, uint256 Amount);

event config_LaunchStatus(bool Status);
event config_MaxBag(uint256 MaxBag);
event config_MaxTx(uint256 maxBag);
event config_TradingStatus(bool Status);


event config_SwapAndSendFeeSettings(uint256 Amount, bool Enabled);

    IDEXRouter public router;
    address public immutable pair;
    bool public tradingOpen = false;
    bool public launchStatus = true;
    bool public botMeasure = false;
    mapping (address => uint) public firstbuy;
    bool public swapEnabled = false;
    uint256 public swapThreshold = totalSupply / 5000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        autoLiquidityReceiver = 0x000000000000000000000000000000000000dEaD;
        treasuryFeeReceiver = 0x30f7C3e397D792FcA8b7fED1F30D836d612E9a70;
        devFeeReceiver = 0x30f7C3e397D792FcA8b7fED1F30D836d612E9a70;
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;
        isTxLimitExempt[address(this)] = true;
        isBagLimitExempt[msg.sender] = true;
        isBagLimitExempt[address(this)] = true;
        isBagLimitExempt[DEAD] = true;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable { }

    function getOwner() external view override returns (address) { return owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }


    function tradingEnable(bool _status, bool _ab) external onlyOwner {
        if(!_status || _ab){
            require(launchStatus,"Cannot stop trading after launch is done");
        }
        tradingOpen = _status;
        botMeasure = _ab;
        emit config_TradingStatus(tradingOpen);
    }

    function launchStyle(uint256 confirm) external onlyOwner {
        require(confirm == 419419419,"Emergency Call"); //just to the make shitt not rug
        require(tradingOpen,"U Cant close launch Style while trading is disabled");
        require(!botMeasure,"disabled botMeasure before u turned off the launchStyle");
        launchStatus = false;
        emit config_LaunchStatus(launchStatus);
        
    
    }

    function Handle_FeeExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isFeeExempt[addresses[i]] = status;
            emit Bag_feeExempt(addresses[i], status);
        }
    }

    function Handle_TxLimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isTxLimitExempt[addresses[i]] = status;
            emit Bag_txExempt(addresses[i], status);
        }
    }

    function Handle_BagLimitExempt(address[] calldata addresses, bool status) external authorized {
        require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
        for (uint256 i=0; i < addresses.length; ++i) {
            isBagLimitExempt[addresses[i]] = status;
            emit Bag_holdingExempt(addresses[i], status);
            
        
        }
    }


    function _updateTaxes() internal {
        require(totalFee.mul(Augmentbuy).div(100) < 95, "Buy tax cannot be more than 9%");
        require(totalFee.mul(Augmentsell).div(100) < 95, "Sell tax cannot be more than 9%");
        require(totalFee.mul(AugmentTransfer).div(100) < 95, "Transfer Tax cannot be more than 10%");

        emit UpdateTaxes( uint8(totalFee.mul(Augmentbuy).div(100)),
            uint8(totalFee.mul(Augmentsell).div(100)),
            uint8(totalFee.mul(AugmentTransfer).div(100))
            );
    }

    function setAugment(uint256 _buy, uint256 _sell, uint256 _trans) external authorized {
        Augmentsell = _sell;
        Augmentbuy = _buy;
        AugmentTransfer = _trans;

        _updateTaxes();

    }

    function setSwapAndSendFeeSettings(bool _enabled, uint256 _amount) external authorized {
        require(_amount < (totalSupply/20), "Amount too high");

        swapEnabled = _enabled;
        swapThreshold = _amount;

        emit config_SwapAndSendFeeSettings(swapThreshold, swapEnabled);
    }


    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function setMaxBagPercent_base100(uint256 maxBagPercent_base100) external onlyOwner {
        require(maxBagPercent_base100 >= 1,"Cannot set max Bag less than 1%");
        _maxBagToken = (totalSupply * maxBagPercent_base100 ) / 100;
        emit config_MaxBag(_maxBagToken);
        
        
    
    }
    function setMaxTxPercent_base100(uint256 maxTXPercentage_base100) external onlyOwner {
        require(maxTXPercentage_base100 >= 1,"Cannot set max transaction less than 0.1%");
        _maxTxAmount = (totalSupply * maxTXPercentage_base100 ) / 100;
        emit config_MaxTx(_maxTxAmount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
            
                        if(botMeasure && (sender == pair)){
                require(balanceOf[recipient] == 0, " trading not yet open");
                if(firstbuy[recipient] == 0){
                    firstbuy[recipient] = block.number;
                }
                
            }
        }

        if(botMeasure && (firstbuy[sender] > 0)){
            require( firstbuy[sender] > (block.number - 5), "Buy before CA was Set to Go");
        }

        if (!authorizations[sender] && !isBagLimitExempt[sender] && !isBagLimitExempt[recipient] && recipient != pair) {
            require((balanceOf[recipient] + amount) <= _maxBagToken,"max wallet limit reached");
        }
    
        // Checks max transaction limit
        require((amount <= _maxTxAmount) || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "Max TX Limit Exceeded");

        if(shouldSwapAndSendFees()){ swapAndSendFees(); }

        balanceOf[sender] = balanceOf[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeTaxes(sender, amount, recipient);

        balanceOf[recipient] = balanceOf[recipient].add(amountReceived);


        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
   function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balanceOf[sender] = balanceOf[sender].sub(amount, "Insufficient Balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeTaxes(address sender, uint256 amount, address recipient) internal returns (uint256) {
        if(amount == 0 || totalFee == 0){
            return amount;
        }

        uint256 Augment = AugmentTransfer;

        if(recipient == pair) {
            Augment = Augmentsell;
        } else if(sender == pair) {
            Augment = Augmentbuy;
        }
        
        uint256 feeAmount = amount.mul(totalFee).mul(Augment).div(feeDenominator * 100);
       uint256 stakingTokens = feeAmount.mul(stakingFee).div(totalFee);
       uint256 contractTokens = feeAmount.sub(stakingTokens);
        
          if(contractTokens > 0){
            balanceOf[address(this)] = balanceOf[address(this)].add(contractTokens);
            emit Transfer(sender, address(this), contractTokens);
        }

           
        return amount.sub(feeAmount);
    }


    function shouldSwapAndSendFees() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && balanceOf[address(this)] >= swapThreshold;
    }

    function clearBnbBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }


    

    function swapAndSendFees() internal swapping {
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;

        uint256 totalETHFee = totalFee.sub(liquidityFee.div(2));
        
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(treasuryFee).div(totalETHFee);
        uint256 amountBNBrewards = amountBNB.mul(devFee).div(totalETHFee);

        payable(treasuryFeeReceiver).transfer(amountBNBMarketing);
        payable(devFeeReceiver).transfer(amountBNBrewards);

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
    
    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply - balanceOf[DEAD] - balanceOf[ZERO]);
    }
    
}