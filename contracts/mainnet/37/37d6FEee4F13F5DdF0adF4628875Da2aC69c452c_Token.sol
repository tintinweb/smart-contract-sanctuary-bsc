/**
 *Submitted for verification at BscScan.com on 2022-08-11
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
    //nft合约地址
    address _nftAddress = 0xCDB82DeA49BD62c1ef4822599a2B8356a08B7276;
    
    //黑洞地址
    address public holdAddr = 0x0000000000000000000000000000000000000001;

    //卖出营销钱包   2%
    address public tarAddr1 = 0xEbfc596460D377377BA1518a3F13Ee58f09a1c2E;
    //卖出市值管理   1%
    address public tarAddr2 = 0x03E642697aD023674649CB99D30A876AF1f87A0b;
    //卖出生态基金   1%
    address public tarAddr3 = 0xD8F0DcF2B086F8bCfC33Ff60DD5Aa4DDe660bB4C;
    //卖出动态地址 动态涨跌
    address public descAddr = 0xEbfc596460D377377BA1518a3F13Ee58f09a1c2E;

    //转账营销钱包 4%
    address public transAddr1 = 0xEbfc596460D377377BA1518a3F13Ee58f09a1c2E;
    //转账市值管理 2%
    address public transAddr2 = 0x03E642697aD023674649CB99D30A876AF1f87A0b;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    //买入销毁费率
    uint256 public buyHoldFee = 2;
    //多代分红费率
    uint256 public bounsFee = 2;
    //买入NFT分红费率
    uint256 public buyNftFee = 1;

    //卖出销毁费率
    uint256 public saleHoldFee = 3;
    //卖出NFT分红费率
    uint256 public saleNftFee = 3;
    //卖出目标地址1
    uint256 public _tarFee1 = 2;
    //卖出目标地址2
    uint256 public _tarFee2 = 1;
    //卖出目标地址3
    uint256 public _tarFee3 = 1;

    //转账销毁费率
    uint256 public transHoldFee = 4;
    //转账指定地址费率1
    uint256 public transTarFee1 = 4;
    //转账指定地址费率2
    uint256 public transTarFee2 = 2;

    //资金池代币数量
    uint256 public liquidAmount = 0;

    //变化基数
    uint256 public _changeNum = 50000 * 10 ** 18;
    //24小时变化阈值
    uint256 public _changeTotalNum = 500000 * 10 ** 18;
    //24小时变化量
    uint256 public _changeTotal = 0;
    //卖出动态费率
    uint256 public _rate = 0;
    //时间锚点
    uint256 public times;

    //交易开关
    bool public swapEnable = true;

    //白名单
    mapping(address => bool) public allowList;
    //黑名单
    mapping(address => bool) public blackList;

    //发币区块
    uint public counter = 0;
    //杀前3个交易者
    uint public kill = 3;

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    constructor(){
        _name = "Crypto Zillion";
        _symbol = "CZ";
        _mint(msg.sender, 100000000000000 * 10 ** decimals());
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
        require(!blackList[sender] && !blackList[recipient], "is black");
        if(allowList[sender] || allowList[recipient]){
            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
        if(!allowList[sender] && !allowList[recipient]){
            require(balanceOf(recipient) + amount <= 60000000000 * 10 ** 18, "balance too much");
            counter += 1;
            //杀前多少交易的人 默认为0，即不杀
            if(counter < 0){
                blackList[recipient] = true;
            }
        }
        if(pair != address(0)){
            _changeTotal += amount;
            if(sender == pair){
                require(swapEnable, "swap no enable");
                uint x = amount / 100;

                _balances[sender] -= amount;

                _balances[_nftAddress] += x * buyNftFee;
                emit Transfer(sender, _nftAddress, x * buyNftFee);

                _balances[holdAddr] += x * buyHoldFee;
                emit Transfer(sender, holdAddr, x * buyHoldFee);

                Intergenerational_rewards(recipient, x * bounsFee);

                _balances[recipient] += x * (100 - buyNftFee - buyHoldFee - bounsFee);
                emit Transfer(sender, recipient, x * (100 - buyNftFee - buyHoldFee - bounsFee));
            }else if(recipient == pair){
                require(swapEnable, "swap no enable");
                require(amount <= balanceOf(sender) * 9 / 10, "amount too much");
                _balances[sender] -= amount;

                uint x = amount / 100;

                _balances[_nftAddress] += x * saleNftFee;
                emit Transfer(sender, _nftAddress, x * saleNftFee);

                _balances[holdAddr] += x * saleHoldFee;
                emit Transfer(sender, holdAddr, x * saleHoldFee);

                _balances[tarAddr1] += x * _tarFee1;
                emit Transfer(sender, tarAddr1, x * _tarFee1);

                _balances[tarAddr2] += x * _tarFee2;
                emit Transfer(sender, tarAddr2, x * _tarFee2);

                _balances[tarAddr3] += x * _tarFee3;
                emit Transfer(sender, tarAddr3, x * _tarFee3);

                _balances[descAddr] += x * _rate;
                emit Transfer(sender, descAddr, x * _rate);

                _balances[recipient] += x * (100 - saleNftFee - saleHoldFee - _tarFee1 - _tarFee2 - _tarFee3 - _rate);
                emit Transfer(sender, recipient, x * (100 - saleNftFee - saleHoldFee - _tarFee1 - _tarFee2 - _tarFee3 - _rate));
            }else{
                require(amount <= balanceOf(sender) * 9 / 10, "amount too much");
                if(amount >= 1 * 10 ** 18){
                    add_next_add(recipient);
                }
                _balances[sender] -= amount;

                uint x = amount / 100;

                _balances[holdAddr] += x * transHoldFee;
                emit Transfer(sender, holdAddr, x * transHoldFee);

                _balances[transAddr1] += x * transTarFee1;
                emit Transfer(sender, transAddr1, x * transTarFee1);

                _balances[transAddr2] += x * transTarFee2;
                emit Transfer(sender, transAddr2, x * transTarFee2);
                
                _balances[recipient] += amount;
                emit Transfer(sender, recipient, amount);
            }
        }else{
            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }

    //修改滑点
    function change() external onlyOwner {
        uint256 currentBalance = balanceOf(pair);
        if(currentBalance > liquidAmount){
            uint256 n = currentBalance - liquidAmount;
            uint256 i = n / _changeNum;
            if(i > 0){
                if(i <= 19){
                    _rate = i;
                }else{
                    _rate = 19;
                }
            }
            if(block.timestamp >= times && _changeTotal <= _changeTotalNum){
                _rate = 0;
                liquidAmount = currentBalance;
            }else if(block.timestamp >= times && _changeTotal < _changeTotalNum){
                times = block.timestamp + 24 hours;
                _changeTotal = 0;
            }
        }
    }
        
    //设置资金池金额 含精度
    function setLiquidAmount(uint256 _target) public onlyOwner {
        liquidAmount = _target;
    }

    function setPair(address _pair) public onlyOwner {
        pair = _pair;
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
        if(pre!=address(0)){
            a = amount/4;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount*3/4;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(total!=0){
            _balances[address(this)] += total;
            emit Transfer(sender, address(this), total);
        }
    }

    //修改nft地址
    function setNFTAddress(address _target) external onlyOwner{
        _nftAddress = _target;
    }

    //代币提现
    function withdraw(address _token, address _target, uint256 _amount) external onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "no balance");
		IERC20(_token).transfer(_target, _amount);
    }

    //设置交易开关
    function setSwapEnable(bool _target) external onlyOwner{
        swapEnable = _target;
    }

    //白名单设置
    function addAllowList(address _target, bool _bool) external onlyOwner{
        allowList[_target] = _bool;
    }

    //黑名单设置
    function addBlackList(address _target, bool _bool) external onlyOwner{
        blackList[_target] = _bool;
    }

    //修改卖出目标1
    function setTarAddr1(address _target) external onlyOwner{
        tarAddr1 = _target;
    }

    //修改卖出目标2
    function setTarAddr2(address _target) external onlyOwner{
        tarAddr1 = _target;
    }

    //修改卖出目标3
    function setTarAddr3(address _target) external onlyOwner{
        tarAddr3 = _target;
    }

    //修改动态地址
    function setDescAddr(address _target) external onlyOwner{
        descAddr = _target;
    }

    //修改转账地址1
    function setTransAddr1(address _target) external onlyOwner{
        transAddr1 = _target;
    }

    //修改转账地址2
    function setTransAddr2(address _target) external onlyOwner{
        transAddr2 = _target;
    }

}