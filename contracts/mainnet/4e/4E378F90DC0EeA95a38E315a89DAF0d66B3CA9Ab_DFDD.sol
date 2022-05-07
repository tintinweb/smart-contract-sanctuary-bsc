/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract DFDD is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    mapping (address => bool) public pairs;
    mapping (address => uint256) public pairAmounts;
    address public marketAddress = 0xaE1e87718248582583978c534d97C6a0f8fDc369;

    mapping(uint256 => address) public id2Address;
    uint256 public next_id = 1;

    mapping (address => bool) public isExcludedFromFees;
    uint256 public tradingEnabledTimestamp;
    
    constructor() public {
        uint256 total = 1588*10**18;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);
    }

    function symbol() external pure returns (string memory) {
        return "DFDD";
    }

    function name() external pure returns (string memory) {
        return "DFDD";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;

        uint256 receiveAmount = amount;

        if((pairs[sender] || pairs[recipient]) && !isExcludedFromFees[sender] && !isExcludedFromFees[recipient]) {
            require(block.timestamp >= tradingEnabledTimestamp, "trade not open");
            uint256 marketAmount = amount*3/100;
            _balances[marketAddress] += marketAmount;
            emit Transfer(sender, marketAddress, marketAmount);

            address addr = sender;
            if(pairs[recipient]) {
                addr = recipient;
            }

            uint256 liquidityAmount = amount/50;
            _balances[address(this)] += liquidityAmount;
            emit Transfer(sender, address(this), liquidityAmount);

            pairAmounts[addr] += liquidityAmount;
            receiveAmount = receiveAmount - marketAmount - liquidityAmount;
        }else {
            for(uint256 i = 0; i < next_id; i++) {
                address addr = id2Address[i];
                uint256 addrAmount = pairAmounts[addr];
                if(pairs[addr] && addrAmount > 0) {
                    _balances[address(this)] -= addrAmount;
                    _balances[addr] += addrAmount;
                    IPancakePair(addr).sync();
                    emit Transfer(address(this), addr, addrAmount);
                    pairAmounts[addr] = 0;
                }
            }
        }

        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
    }

    function addPair(address _pair) external onlyOwner {
        pairs[_pair] = true;
        uint256 id = next_id++;
        id2Address[id] = _pair;
    }

    function setPair(address _pair, bool b) external onlyOwner {
        pairs[_pair] = b;
    }

    function setExcludeFee(address a, bool b) external onlyOwner {
        isExcludedFromFees[a] = b;
    }

    function setTrade(uint256 t) external onlyOwner {
        tradingEnabledTimestamp = t;
    }
}

interface IPancakePair{
    function sync() external;
}