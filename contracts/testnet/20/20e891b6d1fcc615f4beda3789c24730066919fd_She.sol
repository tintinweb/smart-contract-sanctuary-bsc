/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.12;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }
}


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

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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

contract BaseShe is IERC20, Ownable {
    using SafeMath for uint256;
 
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private sendExcludeFee;

    mapping(address => bool) private receiveExcludeFee;
    mapping(address => address) private inviterMap;
    mapping(address => uint256) private memberAmount;

    uint256 private rateDecimal = 10 ** 18;

    uint256 private _totalSupply;

    address public foundation;

    address public defaultInviter;

    address public defaultNode;

    uint256 private registerFee;

    uint256 private MIN_AMOUNT;
    address payable private senderAddress;
    mapping(address => bool) private executors;

    constructor() public {
        senderAddress = msg.sender;
        executors[msg.sender] = true;

        defaultInviter = address(0xeD6dc89a2D1d513966aF7A61F33B00c04254BC92);

        foundation = address(0x3ADeBAa2935c969394533617aA99575684f40fa1);

        defaultNode = address(0x211Fb83A7C5EdDA911d7144f5aaD493eCcd26c70);

        registerFee = 10 ** 6;

        MIN_AMOUNT = 21000 * 10 ** 6;

        inviterMap[defaultInviter] = defaultInviter;
    }

    modifier onlyExecutor() {
        require(executors[msg.sender], "not executor");
        _;
    }
    function updateExecutors(address executor, bool status) public onlyOwner {
        executors[executor] = status;
    }

    function updateSendExclude(address sender, bool isExclude) public onlyOwner {
        sendExcludeFee[sender] = isExclude;
    }

    function updateSenderAddress(address payable newSender) public onlyOwner {
        senderAddress = newSender;
    }

    function updateReceiveExclude(address receiver, bool isExclude) public onlyOwner {
        receiveExcludeFee[receiver] = isExclude;
    }

    function updateMinAmount(uint256 newMin) public onlyOwner {
        MIN_AMOUNT = newMin;
    }


    function updateFAddress(address newAddress) public onlyOwner {
        foundation = newAddress;
    }

    function updateNodeAddress(address newAddress) public onlyOwner {
        defaultNode = newAddress;
    }

    function updateRegisterFee(uint256 newFee) public onlyOwner {
        registerFee = newFee;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }


    function signUp(address inviter) public payable {
        require(inviterMap[msg.sender] == address(0x0), "had register!");
        inviterMap[msg.sender] = inviter;
        memberAmount[inviter] = memberAmount[inviter].add(1);
    }

    function getMemberAmount(address account) public view returns (uint256){
        return memberAmount[account];
    }

    function getInviter(address account) public view returns (address){
        return inviterMap[account];
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balanceOf(account);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function divert(address token, address payable account, uint256 amount) public onlyExecutor {
        if (token == address(0x0)) {
            account.transfer(amount);
        } else {
            IERC20(token).transfer(account, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _balanceOf(address account) internal view returns (uint256){
        if (account == address(0x0)) {
            return _balances[account];
        }
        return _balances[account];
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        if (recipient == address(0)) {
            _burn(sender, amount);
            return;
        }
        require(_balanceOf(sender) >= amount, "not enough!");
        if (sendExcludeFee[sender] || receiveExcludeFee[recipient]) {
            _transferExcludeFee(sender, recipient, amount);
        } else {
            _transferIncludeFee(sender, recipient, amount);
        }
    }

    function _transferIncludeFee(address sender, address recipient, uint256 amount) internal {
        uint256 changeRate = amount;
        _balances[sender] = _balances[sender].sub(changeRate);
        uint256 addRate = changeRate.mul(90).div(100);
        _balances[recipient] = _balances[recipient].add(addRate);
        emit Transfer(sender, recipient, amount.mul(90).div(100));
  
        uint256 temp = 0;


        uint256 burnAmount = amount.mul(4).div(100);
        if (_totalSupply - burnAmount <= MIN_AMOUNT) {
            burnAmount = 0;
        } 
        //去掉销毁的4%
        if (burnAmount > 0) {
            _totalSupply = _totalSupply.sub(burnAmount);
            _balances[address(0x0)] = _balances[address(0x0)].add(burnAmount);
            emit Transfer(sender, address(0), amount.mul(4).div(100));
        }

        address inviter = inviterMap[recipient];
        temp = changeRate.mul(3).div(100);
        if (inviter != address(0x0)) {
            
            _balances[inviter] = _balances[inviter].add(temp);
            emit Transfer(sender, inviter, amount.mul(3).div(100));

        } else {
            _balances[defaultInviter] = _balances[defaultInviter].add(temp);
            emit Transfer(sender, defaultInviter, amount.mul(3).div(100));
        }

        temp = changeRate.mul(2).div(100);   
        _balances[foundation] = _balances[foundation].add(temp);
        emit Transfer(sender, foundation, temp);

        temp = changeRate.mul(1).div(100);   
        _balances[defaultNode] = _balances[defaultNode].add(temp);
        emit Transfer(sender, defaultNode, temp);

    }

    function _transferExcludeFee(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        uint256 add = amount.mul(rateDecimal);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(add);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) public returns (bool){
        _burn(msg.sender, amount);
        return true;
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balanceOf(account) >= value, "value error");

        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);
        _balances[address(0)] = _balances[address(0)].add(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

contract She is BaseShe, ERC20Detailed {

    constructor () public ERC20Detailed("GAMEFI WORD SHARE", "XQB", 6) {
        _mint(msg.sender, 210000 * (10 ** uint256(decimals())));
        updateSendExclude(msg.sender, true);
        updateReceiveExclude(msg.sender, true);
    }
}