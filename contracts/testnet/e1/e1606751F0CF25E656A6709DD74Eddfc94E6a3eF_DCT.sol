/**
 *Submitted for verification at BscScan.com on 2022-04-09
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

// dex (pancakeswap)
interface IUniswapV2Factory {
    // 创建池子
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// 池子接口
interface IUniswapV2Pair {}

// 路由接口
interface IUniswapV2Router01 {
    // 工厂方法
    function factory() external pure returns (address);
}

// v2继承v1
interface IUniswapV2Router02 is IUniswapV2Router01 {}

// dct代币合约
contract DCT is IERC20, Ownable { // is就是继承
    using SafeMath for uint256;

    uint8 private _decimals = 18;
    string private _name = "DCT Token";
    string private _symbol = "DCT";

    uint256 private _lpFee;
    uint256 private _daoFee;
    uint256 private _angelFee1;
    uint256 private _angelFee2;
    uint256 private _blackFee;
    uint256 private _denominator;
    uint256 private _totalSupply;
    uint256 public burnLimit;
    uint256 public maxTransferAmount;

    address private zeroAddress = address(0);
    address private fundAddress = 0x2618E49B8c049053120659690A33895feA44c49f; // 基金地址
    address private daoAddress = 0x6228174d5E50F2987607Ea94b7aC3E77E09Ea269;  // dao地址
    address private poolAddress = 0x0e0f35F0f4269E5167d920652ebFCF78E6b18375; // 矿池地址
    address private lpAddress = 0x155c19877fee0443543c648271e5DFF02647551e;   // lp地址
    address private angelAddress1 = 0x155c19877fee0443543c648271e5DFF02647551e; // 天使奖励地址
    address private angelAddress2 = 0x155c19877fee0443543c648271e5DFF02647551e; // 同级天使奖励地址

    IUniswapV2Pair public immutable uniswapV2Pair;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances; // 授权余额
    mapping (address => bool) private _whiteList;
    mapping (address => bool) private _blacklist;
    mapping (address => Relation) private _relationShip;


    constructor (address router_, address usdt_){ // 构造函数
        _owner = msg.sender;
        _totalSupply = 100000000*10**_decimals;
        burnLimit = 10000000*10**_decimals; // 燃烧限制
        maxTransferAmount = 5000*10**_decimals; // 单笔转账限制
        _balances[_owner] = _totalSupply;
        _lpFee = 80;
        _daoFee = 20;
        _angelFee1 = 30;
        _angelFee2 = 20;
        _blackFee = 50;
        _denominator = 1000; // 分母
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_); // pancakeswap 路由地址
        // address(this)代表当前合约地址 usdt_代表USDT合约地址
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdt_)); // pancakewap 的池子地址

        // 触发事件
        emit Transfer(zeroAddress, fundAddress, _balances[fundAddress]);
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

        // 黑名单条件判断
        require(!getInBlacklist(sender), "ERC20: User cannot transfer out");

        require(amount > 0, "Transfer amount must be greater thanzeroAddress");
        require(amount <= maxTransferAmount, "Transfer amount exceeds the maximum limit");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        // 保留持币地址数量
        if (amount == senderBalance){
            amount = amount - 10;
        }

        _balances[sender] = senderBalance.sub(amount);

        if (sender == address(uniswapV2Pair)){ // 买入
            uint256 recipientAmount = _buySlipPointTransfer(sender, amount);
            _transferToken(sender, recipient, recipientAmount);
        } else if (recipient == address(uniswapV2Pair)) { // 卖出
            uint256 recipientAmount = _sellSlipPointTransfer(sender, amount);
            _transferToken(sender, recipient, recipientAmount);
        } else { // 普通转账
            _relationEstablish(sender, recipient); // 创建推荐关系
            _transferToken(sender, recipient, amount);
        }
    }

    // 买入滑点
    function _buySlipPointTransfer(address sender, uint256 amount) internal returns (uint256 recipientAmount){
        uint256 lpFee = amount.mul(_lpFee).div(_denominator);
        uint256 daoFee = amount.mul(_daoFee).div(_denominator);
        // lp滑点到lp地址
        _transferToken(sender, lpAddress, lpFee);
        // dao滑点到dao地址
        _transferToken(sender, daoAddress, daoFee);
        uint256 totalFee = lpFee + daoFee;
        recipientAmount = amount.sub(totalFee);
    }

    // 卖出滑点
    function _sellSlipPointTransfer(address sender, uint256 amount) internal returns (uint256 recipientAmount){
        uint256 angelFee1 = amount.mul(_angelFee1).div(_denominator);
        uint256 angelFee2 = amount.mul(_angelFee2).div(_denominator);
        uint256 blackFee = amount.mul(_blackFee).div(_denominator);
        _transferToken(sender, angelAddress1, angelFee1);
        _transferToken(sender, angelAddress2, angelFee2);
        if (balanceOf(zeroAddress) < burnLimit){ // 销毁总量至1000万时停止
            _transferToken(sender, zeroAddress, blackFee);
        } else {
            _transferToken(sender, daoAddress, blackFee);
        }
        
        uint256 totalFee = angelFee1 + angelFee2 + blackFee;
        recipientAmount = amount.sub(totalFee);
    }


    // 接收者增加余额
    function _transferToken(address sender, address recipient, uint256 amount) internal {
        if (amount > 0){
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    // 加入黑名单
    function includeBlacklist(address account) external onlyOwner {
        _blacklist[account] = true;
    }

    // 移除黑名单
    function excludeBlacklist(address account) external onlyOwner {
        _blacklist[account] = false;
    }

    // 查询黑名单
    function getInBlacklist(address account) public view returns (bool) {
        return _blacklist[account];
    }

    // 设置燃烧限制
    function setBurnLimit(uint256 limit_) external onlyOwner {
        burnLimit = limit_ * 10 ** decimals();
    }

    // 设置单笔转账最大限制
    function setMaxTransfer(uint256 maxLimit_) external onlyOwner {
        maxTransferAmount = maxLimit_ * 10 ** decimals();
    }

    // 设置手续费
    function setFeeRate(
        uint256 lpFee_,
        uint256 daoFee_, 
        uint256 angelFee1_, 
        uint256 angelFee2_, 
        uint256 blackFee_, 
        uint256 denominator_) external onlyOwner {
        _lpFee = lpFee_;
        _daoFee = daoFee_;
        _angelFee1 = angelFee1_;
        _angelFee2 = angelFee2_;
        _blackFee = blackFee_;
        _denominator = denominator_;
    }

    // 设置手续费收款地址
    function setAccountAddress(
        address fundAddress_, 
        address daoAddress_, 
        address poolAddress_, 
        address lpAddress_,
        address angelAddress1_,
        address angelAddress2_) external onlyOwner{
        fundAddress = fundAddress_;
        daoAddress = daoAddress_;
        poolAddress = poolAddress_;
        lpAddress = lpAddress_;
        angelAddress1 = angelAddress1_;
        angelAddress2 = angelAddress2_;
    }

    // 10代关系
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
    }

    function _relationEstablish(address sender, address recipient) internal {
        if (_relationShip[recipient].one == zeroAddress){
            _relationShip[recipient].one = sender;
            if (_relationShip[recipient].two == zeroAddress && _relationShip[sender].one != zeroAddress){
            _relationShip[recipient].two = _relationShip[sender].one;
            }
            if (_relationShip[recipient].three == zeroAddress && _relationShip[sender].two != zeroAddress){
                _relationShip[recipient].three = _relationShip[sender].two;
            }
            if (_relationShip[recipient].four == zeroAddress && _relationShip[sender].three != zeroAddress){
                _relationShip[recipient].four = _relationShip[sender].three;
            }
            if (_relationShip[recipient].five == zeroAddress && _relationShip[sender].four != zeroAddress){
                _relationShip[recipient].five = _relationShip[sender].four;
            }
            if (_relationShip[recipient].six == zeroAddress && _relationShip[sender].five != zeroAddress){
                _relationShip[recipient].six = _relationShip[sender].five;
            }
            if (_relationShip[recipient].seven == zeroAddress && _relationShip[sender].six != zeroAddress){
                _relationShip[recipient].seven = _relationShip[sender].six;
            }
            if (_relationShip[recipient].eight == zeroAddress && _relationShip[sender].seven != zeroAddress){
                _relationShip[recipient].eight = _relationShip[sender].seven;
            }
            if (_relationShip[recipient].nine == zeroAddress && _relationShip[sender].eight != zeroAddress){
                _relationShip[recipient].nine = _relationShip[sender].eight;
            }
            if (_relationShip[recipient].ten == zeroAddress && _relationShip[sender].nine != zeroAddress){
                _relationShip[recipient].ten = _relationShip[sender].nine;
            }
        }
    }

    // 查询推荐关系
    function getRelation(address account) external view returns(Relation memory){
        return _relationShip[account];
    }

}