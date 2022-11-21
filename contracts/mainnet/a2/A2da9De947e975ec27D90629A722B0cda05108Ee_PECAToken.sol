/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    // 钩子
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner"); // msg.sender调用这钱包地址
        _;
    }
   // 放弃权限
    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    // 更改权限
    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is thezeroAddress address");
        _owner = newOwner;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not beingzeroAddress, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// eip20
interface IERC20 {
    // 总供应量
    function totalSupply() external view returns (uint256);
    // 查询余额
    function balanceOf(address account) external view returns (uint256);
    // 转账（自己转）
    function transfer(address recipient, uint256 amount) external returns (bool);
    // 查询授权
    function allowance(address owner, address spender) external view returns (uint256);
    // 授权
    function approve(address spender, uint256 amount) external returns (bool);
    // 转账（别人转）
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    // 授权事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PECAToken is IERC20, Ownable { // is就是继承
    using SafeMath for uint256;

    uint8 private _decimals = 18;  //小数位数
    string private _name = "PE Consensus Agreement";
    string private _symbol = "PECA";

    uint256 private _totalSupply; // 代币总供应量
    uint256 public burnLimit; // 销毁限制
    uint256 public maxTransferAmount; // 最大转账金额
    uint256 private _fee; // 手续费分子
    uint256 private _buyFee; // 买入手续费分子
    uint256 private _sellFee; // 卖出手续费分子
    uint256 private _denominator; // 手续费分母

    address public uniswapV2Pair; // 交易对地址

    address private zeroAddress = address(0);

    mapping (address => uint256) private _balances; // 地址余额映射
    mapping (address => mapping (address => uint256)) private _allowances; // 授权余额
    mapping (address => bool) private _blacklist; // 推荐关系黑名单
    mapping (address => bool) private _blackTransferlist; // 转账黑名单
    mapping (address => Relation) private _relationShip; // 推荐关系映射

    address private _feeAddress;  // 收手续费地址


    constructor (){ // 构造函数
        _owner = msg.sender;
        _feeAddress = 0xC7878cAbf7a0C594158621c9fc33827f7bBE9Ff2;
        _totalSupply = 100000000*10**_decimals; //发行数量
        burnLimit = 10000000*10**_decimals; // 燃烧限制
        maxTransferAmount = 100000000*10**_decimals; // 单笔转账限制
        _balances[_owner] = _totalSupply;
        _fee = 0;  //手续费  50表示百分之5
        _buyFee = 50; //买入5%滑点
        _sellFee = 100; //卖出10%滑点
        _denominator = 1000; // 分母
        _blacklist[address(this)] = true;
        // 触发事件
        emit Transfer(zeroAddress, _owner, _totalSupply);
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function decimals() public view  returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // 有授权才能调用
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {// 不检查溢出 减少gas费
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    // 增加授权
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    // 减少授权
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance belowzeroAddress");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != zeroAddress, "ERC20: approve from thezeroAddress address");
        require(spender != zeroAddress, "ERC20: approve to thezeroAddress address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // 内部方法
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != zeroAddress, "ERC20: transfer from thezeroAddress address");
        require(recipient != zeroAddress, "ERC20: transfer to thezeroAddress address");

        // 限制黑名单转账
        require(!getInTransferBlacklist(sender), "ERC20: the address is on the blacklist");

        require(amount > 0, "Transfer amount must be greater thanzeroAddress");
        require(amount <= maxTransferAmount, "Transfer amount exceeds the maximum limit");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] = senderBalance.sub(amount);

         if (sender == address(uniswapV2Pair)){ // 买入
            uint256 recipientAmount = _buySlipPointTransfer(sender, amount);
            _transferToken(sender, recipient, recipientAmount);
        } else if (recipient == address(uniswapV2Pair)) { // 卖出
            uint256 recipientAmount = _sellSlipPointTransfer(sender, amount);
            _transferToken(sender, recipient, recipientAmount);
        } else { // 普通转账
            if (!getInBlacklist(sender) && !getInBlacklist(recipient)){ // 挖矿合约 虚拟机合约 交易对合约不参与建立关系
                _relationEstablish(sender, recipient); // 创建推荐关系
            }
            _transferToken(sender, recipient, amount);
        }
    }

    // 卖出滑点
    function _sellSlipPointTransfer(address sender, uint256 amount) internal returns (uint256 recipientAmount){
        uint256 sellFee = amount.mul(_sellFee).div(_denominator);
        // 卖出滑点到收手续费地址
        _transferToken(sender, _feeAddress, sellFee);
        recipientAmount = amount.sub(sellFee);
    }
    // 买入滑点
    function _buySlipPointTransfer(address sender, uint256 amount) internal returns (uint256 recipientAmount){
        uint256 buyFee = amount.mul(_buyFee).div(_denominator);
        // 卖出滑点到收手续费地址
        _transferToken(sender, _feeAddress, buyFee);
        recipientAmount = amount.sub(buyFee);
    }

    //扣手续费
    function _feeSlipPointTransfer(address sender, uint256 amount) internal returns (uint256 recipientAmount){
        uint256 fee = amount.mul(_fee).div(_denominator);
        // 转账手续费到收手续费地址
        _transferToken(sender, _feeAddress, fee);
        recipientAmount = amount.sub(fee);
    }


    // 接收者增加余额
    function _transferToken(address sender, address recipient, uint256 amount) internal {
        if (amount > 0){
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    // 设置池子地址
    function setUniswapV2Pair(address _uniswapV2Pair) external onlyOwner {
        uniswapV2Pair = _uniswapV2Pair;
    }
    // 设置收手续费地址
    function setFeeRate(address feeAddress) external onlyOwner {
        _feeAddress = feeAddress;
    }

    // 设置手续费
    function setFeeRate(uint256 fee) external onlyOwner {
        _fee = fee;
    }

    // 加入推荐黑名单
    function includeBlacklist(address account) external onlyOwner {
        _blacklist[account] = true;
    }

    // 转账黑名单
    function includeTransferBlackList(address account) external onlyOwner{
        _blackTransferlist[account] = true;
    }

    // 移除推荐关系黑名单
    function excludeBlacklist(address account) external onlyOwner {
        _blacklist[account] = false;
    }

    // 移除转账系黑名单
    function excludeTransferBlacklist(address account) external onlyOwner {
        _blackTransferlist[account] = false;
    }

    // 查询推荐关系黑名单
    function getInBlacklist(address account) public view returns (bool) {
        return _blacklist[account];
    }

    // 查询转账黑名单
    function getInTransferBlacklist(address account) public view returns (bool) {
        return _blackTransferlist[account];
    }

    // 设置燃烧限制
    function setBurnLimit(uint256 limit_) external onlyOwner {
        burnLimit = limit_ * 10 ** decimals();
    }

    // 设置单笔转账最大限制
    function setMaxTransfer(uint256 maxLimit_) external onlyOwner {
        maxTransferAmount = maxLimit_ * 10 ** decimals();
    }

    // 12代关系
    struct Relation{
        address one;
        address two;
        address three;
        address four;
        address five;
        address six;
        address seven;
        address eight;
        address nine;
        address ten;
        address eleven;
        address twelve;
    }

    function relationEstablish(address user, Relation memory _relation) external onlyOwner{
        require(_relation.one != zeroAddress, "Superior cannot be zero address");
        _relationShip[user] = Relation(_relation.one,_relation.two,_relation.three,_relation.four,_relation.five,_relation.six,_relation.seven,_relation.eight,_relation.nine,_relation.ten,_relation.eleven,_relation.twelve);
       
    }
    function _relationEstablish(address sender, address recipient) internal {
        bool loop;
        if (_relationShip[recipient].one == zeroAddress){
            _relationShip[recipient].one = sender;
            if (_relationShip[recipient].two == zeroAddress && _relationShip[sender].one != zeroAddress){
                if (_relationShip[sender].one == recipient){
                    loop = true;
                }
                _relationShip[recipient].two = _relationShip[sender].one;
            }
            if (_relationShip[recipient].three == zeroAddress && _relationShip[sender].two != zeroAddress){
                if (_relationShip[sender].two == recipient){
                    loop = true;
                }
                _relationShip[recipient].three = _relationShip[sender].two;
            }
            if (_relationShip[recipient].four == zeroAddress && _relationShip[sender].three != zeroAddress){
                if (_relationShip[sender].three == recipient){
                    loop = true;
                }
                _relationShip[recipient].four = _relationShip[sender].three;
            }
            if (_relationShip[recipient].five == zeroAddress && _relationShip[sender].four != zeroAddress){
                if (_relationShip[sender].four == recipient){
                    loop = true;
                }
                _relationShip[recipient].five = _relationShip[sender].four;
            }
            if (_relationShip[recipient].six == zeroAddress && _relationShip[sender].five != zeroAddress){
                if (_relationShip[sender].five == recipient){
                    loop = true;
                }
                _relationShip[recipient].six = _relationShip[sender].five;
            }
            if (_relationShip[recipient].seven == zeroAddress && _relationShip[sender].six != zeroAddress){
                if (_relationShip[sender].six == recipient){
                    loop = true;
                }
                _relationShip[recipient].seven = _relationShip[sender].six;
            }
            if (_relationShip[recipient].eight == zeroAddress && _relationShip[sender].seven != zeroAddress){
                if (_relationShip[sender].seven == recipient){
                    loop = true;
                }
                _relationShip[recipient].eight = _relationShip[sender].seven;
            }
            if (_relationShip[recipient].nine == zeroAddress && _relationShip[sender].eight != zeroAddress){
                if (_relationShip[sender].eight == recipient){
                    loop = true;
                }
                _relationShip[recipient].nine = _relationShip[sender].eight;
            }
            if (_relationShip[recipient].ten == zeroAddress && _relationShip[sender].nine != zeroAddress){
                if (_relationShip[sender].nine == recipient){
                    loop = true;
                }
                _relationShip[recipient].ten = _relationShip[sender].nine;
            }
            if (_relationShip[recipient].eleven == zeroAddress && _relationShip[sender].ten != zeroAddress){
                if (_relationShip[sender].ten == recipient){
                    loop = true;
                }
                _relationShip[recipient].eleven = _relationShip[sender].ten;
            }
            if (_relationShip[recipient].twelve == zeroAddress && _relationShip[sender].eleven != zeroAddress){
                if (_relationShip[sender].eleven == recipient){
                    loop = true;
                }
                _relationShip[recipient].twelve = _relationShip[sender].eleven;
            }
        }

        if (loop){
            delete _relationShip[recipient];
        }
    }

    // 查询推荐关系
    function getRelation(address account) external view returns(Relation memory){
        return _relationShip[account];
    }

}