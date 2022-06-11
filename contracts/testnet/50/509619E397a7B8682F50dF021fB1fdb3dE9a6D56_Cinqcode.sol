/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface InterfaceLP {
    function sync() external;
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Cinqcode is ERC20Detailed, Ownable, MinterRole {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    InterfaceLP public pairContract;

    bool public initialDistributionFinished;

    mapping(address => bool) allowTransfer;
    mapping(address => bool) _isFeeExempt;

    modifier initialDistributionLock() {
        require(
            initialDistributionFinished ||
                isOwner() ||
                allowTransfer[msg.sender]
        );
        _;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 5 * 10**7 * 10**DECIMALS;

    /********************buy fee***********************/
    uint256 public buyLiquidityFee = 1;
    uint256 public buyTreasuryFee = 3;
    uint256 public buyDevelopmentFee = 3;
    uint256 public buyTotalFee = buyLiquidityFee.add(buyTreasuryFee).add(buyDevelopmentFee);
    /********************sell fee**********************/
    uint256 public sellLiquidityFee = 1;
    uint256 public sellTreasuryFee = 3;
    uint256 public sellDevelopmentFee = 5;
    uint256 public sellTotalFee = sellLiquidityFee.add(sellTreasuryFee).add(sellDevelopmentFee);


    uint256 public feeDenominator = 100;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public TreasuryReceiver;
    address public DevelopmentReceiver;

    uint256 targetLiquidity = 50;
    uint256 targetLiquidityDenominator = 100;

    bool public autoRebase = false;
    uint256 public rebaseRate = 437118656;//1.000437118656
    uint256 public rateDecimals = 13;
    uint256 public rebaseFrequency = 30 minutes;

    uint256 public transferDevAmount = 0;

    uint256 public lastRebasedTime;

    uint256 public launchTime;

    IDEXRouter public router;
    address public pair;

    bool public Islaunch = false;

    struct user {
        uint256 firstBuy;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    mapping(address => user) public tradeData;

    bool public swapEnabled = true;
    uint256 private gonSwapThreshold = (TOTAL_GONS * 10) / 10000;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = ~uint128(0);

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    constructor() ERC20Detailed("Cinqcode", "CINQ", uint8(DECIMALS)) {
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        autoLiquidityReceiver = 0xD54F812133031D0c970C46Dcc5c0eA31704363aA;
        TreasuryReceiver = 0xD54F812133031D0c970C46Dcc5c0eA31704363aA;
        DevelopmentReceiver = 0xD54F812133031D0c970C46Dcc5c0eA31704363aA;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        pairContract = InterfaceLP(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[TreasuryReceiver] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        initialDistributionFinished = false;
        _isFeeExempt[TreasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;

        _transferOwnership(TreasuryReceiver);
        emit Transfer(address(0x0), TreasuryReceiver, _totalSupply);
    }

    function updateBlacklist(address _user, bool _flag) public onlyOwner{
        blacklist[_user] = _flag;
    }

    function rebase() internal {
        if ( inSwap ) return;

        uint256 deltaTime = block.timestamp - lastRebasedTime;
        uint256 times = deltaTime.div(rebaseFrequency);
        uint256 epoch = times.mul(rebaseFrequency);

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply.mul((10**rateDecimals).add(rebaseRate)).div(10**rateDecimals);
        }
        
        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        lastRebasedTime = lastRebasedTime.add(epoch);
 
        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function setAutoRebase(bool enabled) external onlyOwner {
        if (enabled) {
            autoRebase = true;
            lastRebasedTime = block.timestamp;
        } else {
            autoRebase = false;
        }
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        initialDistributionLock
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = InterfaceLP(_address);
        _isFeeExempt[_address];
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) external view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], 'in_blacklist');
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        if (
            pair == recipient &&
            !excludedAccount
        ) {           

            uint blkTime = block.timestamp;
          
            uint256 sellPercent; 
            require(launchTime <= block.timestamp, "Not launched!"); 

            if(blkTime <= launchTime + 172800){
                sellPercent = this.balanceOf(sender).mul(1).div(100);
            }
            else if(launchTime + 172800 < blkTime && blkTime <= launchTime + 345600){
                sellPercent = this.balanceOf(sender).mul(2).div(100);
            }
            else if(blkTime > 345600){
                sellPercent = this.balanceOf(sender).mul(3).div(100);
            }
            require(amount <= sellPercent, "ERR: Can't sell more than set %");                      
            
            if( blkTime > tradeData[sender].lastTradeTime + 86400) {
                tradeData[sender].lastTradeTime = blkTime;
                tradeData[sender].tradeAmount = amount;                
            }
            else if( (blkTime < tradeData[sender].lastTradeTime + 86400) && (( blkTime > tradeData[sender].lastTradeTime)) ){
                require(tradeData[sender].tradeAmount + amount <= sellPercent, "ERR: Can't sell more than 1% in One day");
                tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
            }
        } 

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : transferFee(sender, recipient, gonAmount);
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function transferFee(address sender, address recipient, uint256 gonAmount)
        internal
        returns (uint256)
    {       
        if( _isFeeExempt[sender] || _isFeeExempt[recipient] || !Islaunch)
            return gonAmount;

        uint256 transferAmount = gonAmount.mul(75).div(100);
        uint256 devAmount = gonAmount.mul(20).div(100);
        uint256 treasuryAmount = gonAmount.mul(5).div(100);  

        transferDevAmount = transferDevAmount.add(devAmount);

        _gonBalances[TreasuryReceiver] = _gonBalances[TreasuryReceiver].add(
            treasuryAmount
        );  
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            devAmount
        );
        emit Transfer(sender, address(this), devAmount.div(_gonsPerFragment));

        emit Transfer(
            sender,
            TreasuryReceiver,
            treasuryAmount.div(_gonsPerFragment));         
        return transferAmount;
    }
 

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    function swapBack() internal swapping {
        uint256 realTotalFee = buyTreasuryFee.add(sellTotalFee);
        uint256 realLiquidityFee = buyLiquidityFee.add(sellLiquidityFee);

        uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator
        )
            ? 0
            : realLiquidityFee;
        uint256 contractTokenBalance = _gonBalances[address(this)].div(
            _gonsPerFragment
        );

        contractTokenBalance = contractTokenBalance.sub(transferDevAmount);

        uint256 amountToLiquify = contractTokenBalance
            .mul(dynamicLiquidityFee)
            .div(realTotalFee)
            .div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

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

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 totalETHFee = realTotalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountETHLiquidity = amountETH
            .mul(dynamicLiquidityFee)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHDevelopment = amountETH.mul(buyDevelopmentFee.add(sellDevelopmentFee).add(transferDevAmount)).div(totalETHFee);
        uint256 amountETHTreasury = amountETH.mul(buyTreasuryFee.add(sellTreasuryFee)).div(
            totalETHFee
        );

        transferDevAmount = 0;

        (bool success, ) = payable(TreasuryReceiver).call{
            value: amountETHTreasury,
            gas: 30000
        }("");
        (success, ) = payable(DevelopmentReceiver).call{
            value: amountETHDevelopment,
            gas: 30000
        }("");

        success = false;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
    }

    

    function takeFee(address sender, address recipient, uint256 gonAmount)
        internal
        returns (uint256)
    {
        uint256 _totalFee = buyTotalFee;
        if(recipient == pair) {
            _totalFee = sellTotalFee;
        }

        uint256 feeAmount = gonAmount.mul(_totalFee).div(feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            feeAmount
        );
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        return gonAmount.sub(feeAmount);
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        initialDistributionLock
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        initialDistributionLock
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        initialDistributionLock
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function setInitialDistributionFinished() external onlyOwner {
        initialDistributionFinished = true;
    }

    function enableTransfer(address _addr) external onlyOwner {
        allowTransfer[_addr] = true;
    }

    function setFeeExempt(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setLaunchTime(uint256 _launchTime) external onlyOwner{
        if(!Islaunch){
            launchTime = _launchTime;
            Islaunch = true;
        }
    }

    function setFeeInclude(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = false;
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return (pair == from || pair == to) && (!_isFeeExempt[from]);
    }


    function setSwapBackSettings(
        bool _enabled,
        uint256 _num,
        uint256 _denom
    ) external onlyOwner {
        swapEnabled = _enabled;
        gonSwapThreshold = TOTAL_GONS.div(_denom).mul(_num);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _gonBalances[address(this)].sub(transferDevAmount) >= gonSwapThreshold;
    }

    function shouldRebase() internal view returns (bool) {
        return
            autoRebase &&
            msg.sender != pair &&
            !inSwap &&
            block.timestamp >= (lastRebasedTime + rebaseFrequency);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function setTargetLiquidity(uint256 target, uint256 accuracy) external onlyOwner {
        targetLiquidity = target;
        targetLiquidityDenominator = accuracy;
    }
    

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }
  

    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold.div(_gonsPerFragment);
    }

    function manualSync() external {
        InterfaceLP(pair).sync();
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _TreasuryReceiver,
        address _DevelopmentReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        TreasuryReceiver = _TreasuryReceiver;
        DevelopmentReceiver = _DevelopmentReceiver;
    }
   
    function setBuyFees(
        uint256 _buyLiquidityFee,
        uint256 _buyDevelopmentFee,
        uint256 _buyTreasuryFee
    )external onlyOwner{
        buyLiquidityFee = _buyLiquidityFee;
        buyDevelopmentFee = _buyDevelopmentFee;
        buyTreasuryFee = _buyTreasuryFee;
        buyTotalFee = buyLiquidityFee.add(buyDevelopmentFee).add(buyTreasuryFee);
        require(buyTotalFee <= 30, 'Fee too high!');
    }

    function setSellFees(
        uint256 _sellLiquidityFee,
        uint256 _sellDevelopmentFee,
        uint256 _sellTreasuryFee
    )external onlyOwner{
        sellLiquidityFee = _sellLiquidityFee;
        sellDevelopmentFee = _sellDevelopmentFee;
        sellTreasuryFee = _sellTreasuryFee;
        sellTotalFee = sellLiquidityFee.add(sellDevelopmentFee).add(sellTreasuryFee);
        require(sellTotalFee <= 30, 'Fee too high!');
    }

    function clearStuckBalance(uint256 amountPercentage, address adr) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(adr).transfer(
            (amountETH * amountPercentage) / 100
        );
    }

    function rescueToken(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }
    
    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    receive() external payable {}
}