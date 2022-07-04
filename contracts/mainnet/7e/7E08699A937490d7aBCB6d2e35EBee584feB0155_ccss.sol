/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
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

contract ccss is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    mapping (address => bool) public pairs;
    mapping (address => bool) public routers;
    
    address public marketAddress = 0x605515A606Cf4332C232e2271Dc602dEd406a180;
    address public refAddress = 0xB202769fd33EE27dE45ff41d1127058Fe9879897;

    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public isBlacklist;

    uint256 public tradingEnabledTimestamp;

    uint256 public minRefNum = 1;
    mapping (address => address) public uplines;
    mapping (address => bool) public noUplines;
    
    constructor() public {
        uint256 total = 15000000*10**18;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);

        noUplines[msg.sender] = true;
        noUplines[address(this)] = true;
        noUplines[refAddress] = true;
        routers[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
        routers[0x6E4ff7c7dBAbaf53408428421eeA4bD26Dc8A52B] = true;
    }

    function symbol() external pure returns (string memory) {
        return "CCSS";
    }

    function name() external pure returns (string memory) {
        return "CCSS11";
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

        _register(sender, recipient, amount);

        if(isExcludedFromFees[sender] || isExcludedFromFees[recipient]) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }

        uint256 receiveAmount = amount;
        if(pairs[sender] || pairs[recipient]) {
            require(block.timestamp >= tradingEnabledTimestamp, "trade not open");
            if(block.timestamp <= tradingEnabledTimestamp + 6) {
                if(!routers[sender] && !pairs[sender]) {
                    isBlacklist[sender] = true;
                }
                if(!routers[recipient] && !pairs[recipient]) {
                    isBlacklist[recipient] = true;
                }
            }

            uint256 one = amount/100;

            uint256 marketAmount = 2*one;
            _balances[marketAddress] += marketAmount;
            emit Transfer(sender, marketAddress, marketAmount);


            uint256 burnAmount = one;
            _totalSupply -= burnAmount;
            emit Transfer(sender, address(0), burnAmount);

            _refPayoutToken(sender, recipient, one);

            receiveAmount -= 6*one;
        }

        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
    }

    function _register(address sender, address recipient, uint256 amount) internal { 
        if(uplines[recipient]!=address(0) || noUplines[recipient]) {
            return;
        }

        if(pairs[sender]) {
            uplines[recipient] = refAddress;
            return;
        }

        if(pairs[recipient] || routers[recipient]) {
            return;
        }

        if(sender != recipient && amount >= minRefNum) {
            uplines[recipient] = sender;
        }
    }

    function _refPayoutToken(address sender, address recipient, uint256 amount) private {
        address addr = sender;
        if(pairs[sender]) {
            addr = recipient;
        }

        address up = uplines[addr];
        uint256 totalPayout = 0;
       
        for(uint8 i = 1; i < 3; i++) {
            if(up == address(0)) break;
            uint256 reward = amount*(3-i);
            _balances[up] += reward;
            totalPayout += reward;
            emit Transfer(sender, up, reward);
            up = uplines[up];
        }

        totalPayout = amount*3 - totalPayout;
        if(totalPayout > 0) {
            _balances[refAddress] += totalPayout;
            emit Transfer(sender, refAddress, totalPayout);
        }
    }

    function setPair(address _pair, bool b) external onlyOwner {
        pairs[_pair] = b;
    }

    function setRouters(address _r, bool b) external onlyOwner {
        routers[_r] = b;
    }

    function setExcludeFee(address a, bool b) external onlyOwner {
        isExcludedFromFees[a] = b;
    }

    function setTrade(uint256 t) external onlyOwner {
        tradingEnabledTimestamp = t;
    }

    function setBlacklist(address a, bool b) external onlyOwner {
        isBlacklist[a] = b;
    }
    function setMinRefNum(uint256 newMinRefNum) external onlyOwner {
        minRefNum = newMinRefNum;
    }
}