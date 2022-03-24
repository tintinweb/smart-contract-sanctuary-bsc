/**
 *Submitted for verification at BscScan.com on 2022-03-24
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

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
   
    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

contract CCB is IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private _decimals = 6;
    string private _name = "CCB Token";
    string private _symbol = "CCB";

    uint256 private _fundFee;
    uint256 private _ecologyFee;
    uint256 private _businessFee;
    uint256 private _nodeFee;
    uint256 private _unionFee;
    uint256 private _relation1;
    uint256 private _relation2;
    uint256 private _relation3;
    uint256 private _denominator;
    uint256 private _totalSupply;
    uint256 private _maxTransferAmount;
    uint256 public limit;

    address private zeroAddress = address(0);
    address private fundAddress = 0x2010Cef841a348b10cb31c69C69624DFaB266C4b;
    address private ecologyAddress = 0x6228174d5E50F2987607Ea94b7aC3E77E09Ea269;
    address private businessAddress = 0x0e0f35F0f4269E5167d920652ebFCF78E6b18375;
    address private nodeAddress = 0x155c19877fee0443543c648271e5DFF02647551e;
    address private unionAddress = 0x59F37A306C1Bbf3Fa0803ae747a0CDdF933eDEAc;

    IUniswapV2Pair public immutable uniswapV2Pair;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _whiteList;
    mapping (address => bool) private _blacklist;
    mapping (address => Relation) _relationShip;

    struct Relation{
        address one;
        address two;
        address three;
        address four;
        address five;
        address six;
        address seven;
        address eight;
    }

    constructor (address router_, address usdt_){
        _owner = msg.sender;
        _totalSupply = 10000000*10**_decimals;
        _balances[_owner] = _totalSupply;
        _maxTransferAmount = 1000*10**_decimals;
        limit = 1*10**_decimals;
        _fundFee = 100;
        _ecologyFee = 100;
        _businessFee = 100;
        _unionFee = 100;
        _nodeFee = 200;
        _relation1 = 50;
        _relation2 = 30;
        _relation3 = 20;
        _denominator = 10000;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_);
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdt_));
        emit Transfer(address(0), _owner, _totalSupply);
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

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

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != zeroAddress, "ERC20: transfer from thezeroAddress address");
        require(recipient != zeroAddress, "ERC20: transfer to thezeroAddress address");

        require(!getInBlacklist(sender), "ERC20: User cannot transfer out");

        require(amount > 0, "Transfer amount must be greater thanzeroAddress");
        require(amount <= _maxTransferAmount, "Transfer amount exceeds the maximum limit");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] = senderBalance.sub(amount);

        if (sender == address(uniswapV2Pair)){
            uint256 recipientAmount = _feeDistributionTransfer(sender, recipient, amount);
            _transferToken(sender, recipient, recipientAmount);
        } else {
            _transferToken(sender, recipient, amount);
        }

        // 交易对地址、白名单地址（挖矿合约、两个锁仓合约，在转入代币之前先这些地址加入白名单）不参与任何关系绑定
        if (recipient != address(uniswapV2Pair) && sender != address(uniswapV2Pair) && !getInWhiteList(sender) && !getInWhiteList(recipient)){
            if (amount >= limit){// 创建关系时必须要满足最低转账限制才能创建成功
                _relationEstablish(sender, recipient);
            }
        }
    }

    function _feeDistributionTransfer(address sender, address recipient, uint256 amount) internal returns (uint256 recipientAmount){
        uint256 totalFee;
        {
            uint256 fundFee = amount.mul(_fundFee).div(_denominator);
            uint256 ecologyFee = amount.mul(_ecologyFee).div(_denominator);
            uint256 businessFee = amount.mul(_businessFee).div(_denominator);
            uint256 nodeFee = amount.mul(_nodeFee).div(_denominator);
            uint256 unionFee = amount.mul(_unionFee).div(_denominator);
            uint256 relation1Fee = amount.mul(_relation1).div(_denominator);
            uint256 relation2Fee = amount.mul(_relation2).div(_denominator);
            uint256 relation3Fee = amount.mul(_relation3).div(_denominator);
            _transferToken(sender, fundAddress, fundFee);
            _transferToken(sender, ecologyAddress, ecologyFee);
            _transferToken(sender, businessAddress, businessFee);
            _transferToken(sender, nodeAddress, nodeFee);
            _transferToken(sender, unionAddress, unionFee);
            _relationTransfer(sender, recipient, fundAddress, relation1Fee, relation2Fee, relation3Fee);
            totalFee = fundFee + ecologyFee + businessFee + nodeFee + unionFee + relation1Fee + relation2Fee + relation3Fee*6;
        }
        recipientAmount = amount.sub(totalFee);
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
        }
    }

    function _relationTransfer(address sender, address recipient, address fund, uint256 first,  uint256 second, uint256 three) internal {

        if (_relationShip[recipient].one != zeroAddress){
            _transferToken(sender, _relationShip[recipient].one, first);
        } else {
            _transferToken(sender, fund, first + second + three*6);
            return;
        }

        if (_relationShip[recipient].two != zeroAddress){
            _transferToken(sender, _relationShip[recipient].two, second);
        }else {
            _transferToken(sender, fund, second + three*6);
            return;
        }

        if (_relationShip[recipient].three != zeroAddress){
            _transferToken(sender, _relationShip[recipient].three, three);
        }else {
            _transferToken(sender, fund, three*6);
            return;
        }

        if (_relationShip[recipient].four != zeroAddress){
            _transferToken(sender, _relationShip[recipient].four, three);
        }else {
            _transferToken(sender, fund, three*5);
            return;
        }

        if (_relationShip[recipient].five != zeroAddress){
            _transferToken(sender, _relationShip[recipient].five, three);
        }else {
            _transferToken(sender, fund, three*4);
            return;
        }

        if (_relationShip[recipient].six != zeroAddress){
            _transferToken(sender, _relationShip[recipient].six, three);
        }else {
            _transferToken(sender, fund, three*3);
            return;
        }

        if (_relationShip[recipient].seven != zeroAddress){
            _transferToken(sender, _relationShip[recipient].seven, three);
        }else {
            _transferToken(sender, fund, three*2);
            return;
        }

        if (_relationShip[recipient].eight != zeroAddress){
            _transferToken(sender, _relationShip[recipient].eight, three);
        }else {
            _transferToken(sender, fund, three);
        }
    }

    function _transferToken(address sender, address recipient, uint256 amount) internal {
        if (amount > 0){
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    function includeWhiteList(address account) external onlyOwner{
        _whiteList[account] = true;
    }

    function excludeWhiteList(address account) external onlyOwner{
        _whiteList[account] = false;
    }

    function getInWhiteList(address account) public view returns(bool){
        return _whiteList[account];
    }

    function includeBlacklist(address account) external onlyOwner {
        _blacklist[account] = true;
    }

    function excludeBlacklist(address account) external onlyOwner {
        _blacklist[account] = false;
    }

    function getInBlacklist(address account) public view returns (bool) {
        return _blacklist[account];
    }

    function setLimit(uint256 limit_) external onlyOwner {
        limit = limit_;
    }

    function setMaxTransfer(uint256 maxLimit_) external onlyOwner {
        _maxTransferAmount = maxLimit_;
    }

    function setFeeRate(
        uint256 fundFee_,
        uint256 ecologyFee_, 
        uint256 businessFee_, 
        uint256 nodeFee_, 
        uint256 relation1_, 
        uint256 relation2_, 
        uint256 relation3_,
        uint256 unionFee_) external onlyOwner {
        _fundFee = fundFee_;
        _ecologyFee = ecologyFee_;
        _businessFee = businessFee_;
        _nodeFee = nodeFee_;
        _relation1 = relation1_;
        _relation2 = relation2_;
        _relation3 = relation3_;
        _unionFee = unionFee_;
    }

    function setAccountAddress(
        address fundAddress_, 
        address ecologyAddress_, 
        address businessAddress_, 
        address nodeAddress_,
        address unionAddress_) external onlyOwner{
        fundAddress = fundAddress_;
        ecologyAddress = ecologyAddress_;
        businessAddress = businessAddress_;
        nodeAddress = nodeAddress_;
        unionAddress = unionAddress_;
    }

}