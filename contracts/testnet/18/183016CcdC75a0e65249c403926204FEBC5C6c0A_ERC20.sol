// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import './SafeMath.sol';

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20, SafeMath {
    address private contractOwner;
    address private contractDev;
    bool public freeze = false;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) private frozenAccs;

    uint constant devAllocation = 1000000;
    uint constant totalTimeOfAllocation = 31104000; //12*30*24*60*60
    uint public percentOfAllocation = 10;
    uint public lastTimeOfAllocation = 0;
    uint public devAllocationRemaining = 1000000;

    uint256 private _totalSupply;
    uint8 public decimals;
    string public name;
    string public symbol;

    event FreezeContract(uint time, uint blockNumber);
    event UnfreezeContract(uint time, uint blockNumber);
    event FreezeWallet(address indexed target, uint time, uint blockNumber);
    event UnfreezeWallet(address indexed target, uint time, uint blockNumber);
    event SetDev(address indexed target, uint time, uint blockNumber);
    event BeginTokenEventGeneration(uint time, uint blockNumber);
    event ReleaseAllocation(address indexed target, uint time, uint blockNumber, uint amount);
    event Mint(address indexed minter, address indexed account, uint256 amount);
    event Burn(address indexed burner, address indexed account, uint256 amount);

    //    constructor(string memory n, string memory s, uint256 ts, uint8 d) {
    //        contractOwner = msg.sender;
    //        name = n;
    //        symbol = s;
    //        _totalSupply = ts;
    //        balances[msg.sender] = ts;
    //        decimals = d;
    //    }

    modifier ownerOnly() {
        require(msg.sender == contractOwner, 'Contract: not OWNER');
        _;
    }

    modifier canDevRelease() {
        require(msg.sender == contractDev, 'Contract: not DEV');
        require(lastTimeOfAllocation > 0, 'Contract: admin not allow yet');
        _;
    }

    modifier freezeToken() {
        require(!freeze, 'Contract: this contract is FREEZING');
        _;
    }

    modifier isWalletActive() {
        require(!frozenAccs[msg.sender], 'Contract: this wallet is FREEZING');
        _;
    }

    constructor() {
        contractOwner = msg.sender;
        name = 'Minh20';
        symbol = 'm20';
        _totalSupply = 100000000000000000000000;
        balances[msg.sender] = 100000000000000000000000;
        decimals = 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return allowances[owner][spender];
    }

    function freezeContract() ownerOnly public {
        freeze = true;
        emit FreezeContract(block.timestamp, block.number);
    }

    function unfreezeContract() ownerOnly public {
        freeze = false;
        emit UnfreezeContract(block.timestamp, block.number);
    }

    function freezeWallet(address target) ownerOnly public {
        frozenAccs[target] = true;
        emit FreezeWallet(target, block.timestamp, block.number);
    }

    function unfreezeWallet(address target) ownerOnly public {
        delete(frozenAccs[target]);
        emit UnfreezeWallet(target, block.timestamp, block.number);
    }

    function setDevWallet(address devAddress) ownerOnly public {
        contractDev = devAddress;
        emit SetDev(devAddress, block.timestamp, block.number);
    }

    function beginTokenEventGeneration() ownerOnly public {
        lastTimeOfAllocation = block.timestamp;
        emit BeginTokenEventGeneration(block.timestamp, block.number);
    }

    function releaseDevAllocation() canDevRelease public {
        if (devAllocationRemaining == devAllocation) {
            releaseAllocation(percentOfAllocation);
        } else {
            uint percent = safeMul(safeDiv(safeSub(block.timestamp, lastTimeOfAllocation), totalTimeOfAllocation), 100);
            releaseAllocation(percent);
        }
        this.beginTokenEventGeneration();
    }

    function releaseAllocation(uint percent) internal {
        uint amount = safeDiv(safeMul(devAllocation, percent), 100);
        balances[contractDev] = safeAdd(balances[contractDev], amount);
        devAllocationRemaining = safeSub(devAllocationRemaining, amount);
        emit ReleaseAllocation(contractDev, block.timestamp, block.number, amount);
    }

    function approve(address spender, uint256 amount) freezeToken isWalletActive public virtual override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint amount) freezeToken isWalletActive public virtual override returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], amount);
        balances[to] = safeAdd(balances[to], amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) freezeToken isWalletActive public virtual override returns (bool success) {
        balances[from] = safeSub(balances[from], amount);
        allowances[from][msg.sender] = safeSub(allowances[from][msg.sender], amount);
        balances[to] = safeAdd(balances[to], amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function mintTo(address to, uint amount) freezeToken ownerOnly public {
        require(amount > 0, 'Contract: amount is not valid');

        _totalSupply = safeAdd(_totalSupply, amount);
        balances[to] = safeAdd(balances[to], amount);

        emit Mint(msg.sender, to, amount);
    }

    function burnFrom(address from, uint amount) freezeToken ownerOnly public {
        require(balances[from] >= amount, 'Contract: insufficient balance');

        balances[from] = safeSub(balances[from], amount);
        _totalSupply = safeSub(_totalSupply, amount);

        emit Burn(msg.sender, from, amount);
    }
}

pragma solidity ^0.8.0;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}