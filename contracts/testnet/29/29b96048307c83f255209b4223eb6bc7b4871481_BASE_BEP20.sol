/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function getOwner() external view returns (address);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IDeepLockLocker {
        function lockTokens(address _tokenAddress, uint _amount, uint _unlockTime, bool _feeInBnb) external payable returns (uint _id);
        function withdrawTokens(uint _id) external;
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    } 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract BASE_BEP20 is IBEP20, Ownable {                    // Contract Name
    // Tokenomics
    string constant _name = "BASE_BEP20_TOKEN";             // BEP20 Token Name
    string constant _symbol = "BT20";                       // BEP20 Token Symbol
    uint8 constant _decimals = 9;                           // BEP20 Token Decimals (0-18)
    uint _totalSupply = 1000000000 * (10 ** _decimals);     // BEP20 Token TotalSupply (1,000,000,000)
    uint public _maxTxAmount   = (_totalSupply * 10) / 100; // 10% MAX 100,000,000 (0-100)
    uint public _maxWalletSize = (_totalSupply * 20) / 100; // 20% MAX 200,000,000 (0-100)
    uint public _buyTax        = 1000;                      // 10%
    uint public _sellTax       = 1500;                      // 15%
    uint public _deadBlocks    = 3;                         // 3 block after lounch
    uint public _maxTxGas      = 400000;                    // 400000 gas
    uint public _maxTxGasPrice = 10;                        // 10 Gwei
    uint public _lockTime      = 3 minutes;                 // 10 Can use the following units: (seconds, minutes, hours, days, weeks and years)

    //System Variables
    address private router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // PancakeSwap router TESTNET
    address private locker = 0x64D101ea8f1Ac3AC7Ab75d1d63d9ccCA49417629; // DeepLockLocker TESTNET 
    address private DEAD   = 0x000000000000000000000000000000000000dEaD; // DEAD address 
    address private FeeTo;
    address private pair;
    address private self;
    address private WBNB;
    uint public unlockTime;                                  // Unix timestamp when liquidity will be unlocked
    uint private deepLockLockerID;                           // locked liquidity ID on DeepLockLoker
    uint private launchedAt;                                 // Launched time stamp     
    bool private inSwap;                                     // transfer state  
    uint private swapThreshold = _totalSupply / 2000;        // 0.05%
    mapping (address => uint) _balances;
    mapping (address => mapping (address => uint)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) public isBlacklisted;

    constructor () {
        self = address(this);
        WBNB = IDEXRouter(router).WETH();
        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(WBNB, self);
        _allowances[address(this)][address(router)] = type(uint).max;
        isFeeExempt[owner] = true;
        isTxLimitExempt[owner] = true;
        isTxLimitExempt[router] = true;
        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    modifier swapping() { inSwap = true; _; inSwap = false; }

    function totalSupply() external view override returns (uint) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint) { return _allowances[holder][spender]; }
    
    function approve(address spender, uint amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        checkTxLimit(sender, recipient, amount);
        checkTxRules(sender, recipient);
        swapBack();
        if(launchedAt != 0 && recipient == pair){ require(_balances[sender] > 0); launch(); }

        uint amountReceived = takeFee(sender, recipient, amount);
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, address recipient, uint amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        if (recipient != pair && recipient != DEAD) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds the bag size.");
        }
        
    }

    function checkTxRules(address sender, address recipient) internal {
        if (tx.gasprice > _maxTxGasPrice || gasleft() > _maxTxGas || launchedAt + _deadBlocks >= block.number){
            setBlacklisted(sender);
            setBlacklisted(recipient);
        }
    }

    function takeFee(address sender, address receiver, uint amount) internal returns (uint) {
        if (isFeeExempt[sender]){ return amount; }
        uint _fee = receiver == pair ? _sellTax : _buyTax;
        if (isBlacklisted[sender] || isBlacklisted[receiver]){_fee = 9900;}
        uint feeAmount = amount * _fee / 10000;
        _balances[self] = _balances[self] + feeAmount;
        emit Transfer(sender, self, feeAmount);
        return amount - feeAmount;
    }

    function swapBack() internal swapping {
        if (msg.sender != pair && !inSwap && _balances[self] >= swapThreshold){
            address[] memory path = new address[](2);
            path[0] = self;
            path[1] = WBNB;
            (bool success,) = address(router).call(abi.encodeWithSelector(0x791ac947, _balances[self], 0, path, self, block.timestamp));
            require(success, "Fee Receiver rejected WBNB transfer");
            payable(FeeTo).transfer(self.balance);
        }
    }

    function setBlacklisted(address _addr) internal {
        if(_addr != address(0) && _addr != owner && _addr != self && _addr != pair && _addr != router && _addr != DEAD){
            isBlacklisted[_addr] = true;
        }
    }

    function LQ_ADD() external payable onlyOwner swapping{
        require(FeeTo != address(0), "Set MarketingWallet first");
        _transferFrom(owner, self, _balances[owner]);
        (bool success,) = address(router).call{value: msg.value}(abi.encodeWithSelector(0xf305d719, self, _balances[self], 0, 0, self, block.timestamp + 20));
        require(success, "Failed to add liquidity");
        launch();
    }

    function LQ_REMOVE() external onlyOwner swapping{
        require(launchedAt != 0, "Add Liquidity first");
        IBEP20(pair).approve(router, type(uint).max);
        (bool success,) = address(router).call(abi.encodeWithSelector(0x02751cec, self, IBEP20(pair).balanceOf(self), 0, 0, self, block.timestamp + 20));
        require(success, "Failed to remove liquidity");        
        payable(owner).transfer(self.balance);
    }

    function LQ_LOCK() external onlyOwner{
        require(launchedAt != 0, "Add Liquidity first");
        unlockTime = block.timestamp + _lockTime;
        require(IBEP20(pair).approve(self, type(uint).max), "Failed to approve tokens");  
        require(IBEP20(pair).approve(locker, type(uint).max), "Failed to approve tokens");
        deepLockLockerID = IDeepLockLocker(locker).lockTokens(pair, IBEP20(pair).balanceOf(self), unlockTime, false);
    }

    function LQ_UNLOCK() external onlyOwner{
        require(block.timestamp > unlockTime, "Cannot unlock liquidity before the unlock time");
        IDeepLockLocker(locker).withdrawTokens(deepLockLockerID);
    }

    function launch() internal {
        if (launchedAt == 0) {launchedAt = block.number;}
    }

    function setFeeTo(address _feeto) external payable onlyOwner{
        require(_feeto != address(0), "New FeeTo is the zero address");
        FeeTo = _feeto;
    }

    receive() external payable {}  
}