/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-30 0x4De437C0f79Edc9f239a9B22d73fA8Cb701c0CA6
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

pragma solidity ^0.8.15;
// SPDX-License-Identifier: MIT
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the ow  ner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




contract Token is Context, IERC20, IERC20Metadata, Ownable {
    address public pair;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public _isBlacklisted;
    uint256 public _launchedAt = 0;
    uint256 public _blocknumber = 3;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    constructor(){
        _name = "Galactose";
        _symbol = "GT";
        _mint(msg.sender, 50000 * 10 ** decimals());
    }

    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _transfer(address sender,address recipient,uint256 amount) internal virtual {
        require(!_isBlacklisted[msg.sender], 'Blacklisted address');      //如果发送方是黑名单则禁止交易
        if(pair != address(0)){
                if(sender == pair){
                    if (_launchedAt == 0) {
                        _launchedAt = block.number;//初始化lauchAt赋值当前块的数量
                    }
                    if (block.number < _launchedAt + _blocknumber) { //如果在 blocknumber3个区块间内抢到
                       addBot(msg.sender);                                    //则添加黑名单
                    }
                    uint x = amount * 6 / 100;
                    _balances[sender] -= amount;
                    _balances[recipient] += amount - x;
                    emit Transfer(sender, recipient, amount - x);
                    Intergenerational_rewards(sender, x);
                }else if(recipient == pair){
                    uint x = amount * 6 / 100;
                    _balances[sender] -= amount;
                    _balances[recipient] += amount - x;
                    emit Transfer(sender, recipient, amount - x);
                    Intergenerational_rewards(sender, x);
                }else{
                    if(amount >= 2 * 10 ** 18){ // 0.2
                        add_next_add(recipient);
                    }
                    _balances[sender] -= amount;
                    _balances[recipient] += amount;
                    emit Transfer(sender, recipient, amount);
                }
            }else{
                _balances[sender] -= amount;
                _balances[recipient] += amount;
                emit Transfer(sender, recipient, amount);
        }
    }

    //添加黑名单的函数
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
    //移除黑名单的函数
    function moveBot(address recipient) public onlyOwner {
        if (_isBlacklisted[recipient]) _isBlacklisted[recipient] = false;
    }

    function setPair(address _pair) public onlyOwner {
        pair = _pair;
    }

    function setLaunchedAt(uint256 launchedat) public onlyOwner {
        _launchedAt = launchedat;
    }

    function setBlocknumber(uint256 blocknumber) public onlyOwner {
        _blocknumber = blocknumber;
    }

    mapping(address=>address)public pre_add;

    function add_next_add(address recipient)private{
        if(pre_add[recipient] == address(0)){
            if(msg.sender == pair)return;
            pre_add[recipient]=msg.sender;
        }
    }

    function Intergenerational_rewards(address sender,uint amount)private{
        address pre = pre_add[sender];
        uint total = amount;
        uint a;
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/6;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/12;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/12;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/12;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/12;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/12;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/12;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/12;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/12;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 10 * 10 ** 18){
            a = amount/6;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }if(total!=0){
        _balances[address(this)] += total;
        emit Transfer(sender, address(this), total);
    }
    }

    //绑定推进关系
    function bind(address _target) external{
        pre_add[msg.sender] = _target;
    }

    //查询推荐人
    function getBind(address _target) external view returns(address){
        return pre_add[_target];
    }
}