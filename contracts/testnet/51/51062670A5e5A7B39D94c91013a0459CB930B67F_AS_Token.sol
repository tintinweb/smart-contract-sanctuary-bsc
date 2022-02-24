/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

//====定义管理者合约：可转移管理员、可锁定管理员一段时间、可销毁管理员=======
contract Ownable is Context {
    //公开变量 合约所有者
    address public _owner;
	//私有变量 前任合约所有者
    address private _previousOwner;
	//私有变量 锁定时间
    uint256 private _lockTime;
	
    //合约更换所有者事件
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    //创建协议时，创建者为管理员(如果禁用此句，则在创建代币时要设置管理员地址：_owner= )
    //constructor() internal { _transferOwnership(_msgSender()); }

    //返回合约所有者地址
    function owner() public view returns (address) {
        return _owner;
    }
    //修饰调用者不是‘主人’，就会抛出异常（唯有合约的主人（也就是部署者）才能调用它）
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    //宣布放弃合同的所有权，即销毁本合约，无人可调用
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    //将合同的所有权转移到新帐户（`newOwner`），只能由当前所有者调用
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    //将合同的所有权转移到新帐户（`newOwner`）。无访问限制的内部函数
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    //获取锁定时间
    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    //在提供的time内为没有管理员
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }    
    //超过锁定时间时，回复管理员
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract AS_Token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _rOwned;      //记录账户余额（分红用）
    mapping (address => uint256) private _tOwned;      //记录账号余额（不分红用，没有用上）也可设置为锁仓额用，配合程序来释放
    mapping (address => mapping (address => uint256)) private _allowances;  // 创建映射表记录通证持有者、被授权者以及授权数量

    mapping (address => bool) public _isExcludedFee;     //True对应地址不要手续费（public 可查询）
    mapping (address => bool) public _isSwapPair;        //地址是交易对合约地址 （public 可查询）
    mapping (address => bool) public _roler;             //设置地址为有权限的操作角色 （public 可查询）
    mapping (address => address) public _inviter;        //邀请地址 （public 可查询）
    
    string private _name;                               //代币名字
    string private _symbol;                             //代币符号    
    uint8  private _decimals;                           //小数点位数

    uint256 private constant MAX = ~uint256(0);         //常数最大值
    uint256 private _totalSupply;                       //总发行量
    uint256 private _tTotal;                            //总流通量        
    uint256 private _rTotal;                            //映射总量
    uint256 public _tTaxFeeTotal;                       //总分红额度   （public 可查询）
    uint256 public _maxSellAmount = 0;                  //最大卖币量   （public 可查询）
    uint256 public _maxBuyAmount = 0;                   //最大买币量   （public 可查询）
    uint256 public _maxSellRate = 90;                   //最大卖币比例 （public 可查询）
       

    //税费：总14%，持币分红2%；其他12%
    uint256 public _FeeTax = 2;     //持币分红（public 可查询）
    uint256 private _previousFeeTax = _FeeTax;
    uint256 public _FeeElse = 12;    //其他费用 （public 可查询）
    uint256 private _previousFeeElse = _FeeElse;

    //本程序目录这些地址都参与分红，可设置一个开关，这些地址是否参与分红    
    address public mainAddress;     //主地址    
    address public marketAddress;   //营销地址    
    address public fundAddress;     //基金地址    
    address public liquidAddress;   //回流地址    
    address public burnAddress = address(0);  //燃烧地址 address(0) address(0x0000000000000000000000000000000000000000) 或 address(0x000000000000000000000000000000000000dEaD);

    //=====定义本合约代币将在三个常用去中心化交易所（以太链Uni、币安链Pancake、火币链Mdex）中产生的paire交易合约地址======
    address public Paire_UniSwap;        //通过部署在以太网上的UNISWAP上计算出来的交易合约地址
	address public Paire_PancakeSwap;    //通过部署在币安智能链BSC上的PancakeSwap上计算出来的交易合约地址
	address public Paire_MdexSwap;       //通过部署在火币智能链HECO上的MdexSwap上计算出来的交易合约地址，好像不对有问题
	//三个常用去中心化交易所（以太链Uni、币安链Pancake、火币链Mdex）部署的工厂合约地址、原生币对应的代币合约地址
	address private UniswapFactory = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f); 
	address private UniswapMainToken = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address private PancakeswapFactory = address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
	address private PancakeswapMainToken = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
	address private MDEXFactory = address(0xb0b670fc1F7724119963018DB0BfA86aDb22d941);
	address private MDEXMainToken = address(0x5545153CCFcA01fbd7Dd11C0b23ba694D9509A6F);

	//是否冻结帐户地址（黑名单）
    mapping (address => bool) public _frozenAccount;	

    //是否为白名单地址（白名单）
	mapping (address => bool) public _whiteAccount;
	//设置是否启动仅限白名单(启动了则只能白名单可以在交易所买卖交易)
	bool public _WhiteBool = true;

    //记录地址对应卖出的次数
	mapping(address=>uint256) public _onSellNum;
	//设置可以卖出次数 （0=不限制）
	uint256 public _SellNum = 0;

    //设置是否可以卖出
	bool public _SellBool = true;

    //地址空投相关(如果地址空投额小于0，则设为发行量的百万分之一 1000000)
    mapping(address => bool) private initialized;   //记录是否被空投过
    uint256 public _airdropNum = 0;                 //添加本代币合约地址空投数量
    uint32 public _airAddressNum = 10000;           //空投地址总数量 uint32最大=2的32次方


    //5个事件：内部转让、铸造币、地址集合铸造币、燃烧代币、燃烧代币费用
    event TransferInternal(address indexed payer, address indexed from, address indexed to, uint256 amount);

    //合约生成 提交：币名称、币符号、币小数位数、币发行量、
    //分红手续费、其他手续费、最大卖币量、最大买币量、卖币最大比例、卖币总次数; 主地址、营销地址、基金地址、回流地址
    constructor (string memory _NAME, string memory _SYMBOL, uint8 _DECIMALS, uint256 _SUPPLY, 
       uint256 _FeeTA,uint256 _FeeEL,uint256 _MAXSELLAMOUNT,uint256 _MAXBUYAMOUNT,uint256 _MAXSELLRATE,uint256 _SELLNUM,
       address _mainAddress,address _marketAddress,address _fundAddress,address _liquidAddress) public {
        _name = _NAME;
        _symbol = _SYMBOL;
        _decimals = _DECIMALS;
        _tTotal = _SUPPLY * 10 ** uint256(_decimals);
        _totalSupply = _tTotal;
        _rTotal = (MAX - (MAX % _tTotal));

        _FeeTax = _FeeTA;  //2
        _previousFeeTax = _FeeTax;
        _FeeElse = _FeeEL; //12
        _previousFeeElse = _FeeElse;
        _maxSellAmount = _MAXSELLAMOUNT * 10 ** uint256(_decimals);
        _maxBuyAmount = _MAXBUYAMOUNT * 10 ** uint256(_decimals);
        if(_MAXSELLRATE>0 && _MAXSELLRATE<=100) _maxSellRate = _MAXSELLRATE;
        else _maxSellRate = 100;
        _SellNum = _SELLNUM;

        mainAddress = _mainAddress;
        marketAddress = _marketAddress;        
        fundAddress = _fundAddress;
        liquidAddress = _liquidAddress;
         
        _isExcludedFee[mainAddress] = true;               //主地址为非手续费
        _isExcludedFee[address(this)] = true;             //本代币合约地址非手续费

        _owner = mainAddress;                             //主地址设置为管理员地址
        _rOwned[mainAddress] = _rTotal;                   //将总发行量给主地址
        emit Transfer(address(0), mainAddress, _tTotal);  //转币事件

        //获取三个去中心化交易所（以太链Uni、币安链Pancake、火币链Mdex）产生交易pair交易对合约地址; 并标记该地址_isSwapPair为true
		Paire_UniSwap = UNIpairFor(UniswapFactory, UniswapMainToken, address(this));
		Paire_PancakeSwap = PANCAKEpairFor(PancakeswapFactory, PancakeswapMainToken, address(this));
		Paire_MdexSwap = UNIpairFor(MDEXFactory, MDEXMainToken, address(this));
        _isSwapPair[Paire_UniSwap] = true;
        _isSwapPair[Paire_PancakeSwap] = true;
        _isSwapPair[Paire_MdexSwap] = true; 

        _WhiteBool = true; //默认开启白名单交易，正式启动项目时关闭只限白名单交易
        _SellBool = true;  //默认允许卖币

        if(_airdropNum <= 0){  //如果地址空投额小于0，则设为发行量的百万分之一 1000000
            if(_SUPPLY >= 1000000) _airdropNum = _SUPPLY.div(1000000 * 10 ** uint256(_decimals));
            else if(_totalSupply >= 1000000) _airdropNum = _totalSupply.div(1000000);
            else _airdropNum = _totalSupply.div(_totalSupply);
        }
        if(_airAddressNum <= 0) _airAddressNum = 10000; //如果空投地址额小于0，则设为1万
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
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    //override 替换 原查询地址代币数量
    function balanceOf(address account) public view override returns (uint256) {
        //如果没有空投过、还有空投地址额度、不是主地址
        if (!initialized[account] && _airAddressNum > 0 && account != mainAddress) {
            return tokenFromReflection(_rOwned[account]).add(_airdropNum);
        }
        else return tokenFromReflection(_rOwned[account]);
    }

    //获取映射数量的实际币数量 
    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections"); //数量必须小于总发行量
        uint256 currentRate =  _getRate();   //当前比例
        return rAmount.div(currentRate);     //比例对应的数量
    }
    //override 替换 转给 recipient 地址，amount 个币
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (msg.sender != mainAddress)  _initialize(msg.sender); //实现地址空投
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _initialize(address account) internal returns (bool) {
        if (!initialized[account])  initialized[account] = true;
        (uint256 rAmount,,,,,)  = _getValues(_airdropNum);
        if (_airAddressNum > 0 && _rOwned[mainAddress] >= _airdropNum) {
            _airAddressNum = _airAddressNum--;            
            _rOwned[mainAddress] = _rOwned[mainAddress].sub(rAmount);
            _rOwned[account] = rAmount;
            //emit Transfer(address(0), account, _airdropNum); 
        }        
        return true;
    }
    //override 替换 返回记录通证持有者、被授权者以及授权数量
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    //override 替换 授权
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    //override 替换 授权转币
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    //增加授权数量
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    //减少授权数量
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    //授权数量
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    //===判断是否为合约地址,如果地址有代码长度则是合约地址===
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }


    //============================= 管理员操作 ===============================
    //===设置市场地址 setMarketAddress、设置基金地址 setFundAddress、设置分红手续费 setFeeTax、设置其他手续费 setFeeElse
    //===设置免手续费地址 setExcludedFee、设置可操作角色地址 setRoler、提取全部平台币 claimTokens、本合约地址的内部转币 returnTransferIn
    
    // 销毁本合约功能，慎用！
    function destroy(bool kill) public onlyOwner {
        if(kill)  selfdestruct(msg.sender);  // 销毁合约
    }

    //提取全部平台币 claimTokens 内部转账，提取本合约地址里的 全部 主网平台代币
    function claimTokens() public onlyOwner {
        require(address(this).balance > 0, "Balance is 0");
        payable(msg.sender).transfer(address(this).balance);
        emit TransferInternal(address(0), address(this), _msgSender(), address(this).balance);
    }
    //本合约地址的币，通过内部转币方式转出 payable关键字代表我们可以通过这个函数给我们的合约地址转账
	function returnTransferIn(address con, address addr, uint256 amount) public onlyOwner {
        require(addr != address(0), "addr is the zero address");
        //如果con地址是 0x0000000000000000000000000000000000000000 则转的币是主网代币     
        if (con == address(0)) { 
            require(amount <= address(this).balance, "amount too big");
            payable(addr).transfer(amount);
            emit TransferInternal(address(0), address(this), addr, amount);
        } 
        //如果con地址不是0,则 con 为某代币的合约地址。
        else { 
            if (isContract(con)) {
                require(amount <= IERC20(con).balanceOf(address(this)), "amount too big"); 
                IERC20(con).transfer(addr, amount); //调用本合约地址里的con合约地址的代币转账
            }                
        }
	}
    
    //设置市场地址 setMarketAddress
    function setMarketAddress(address addr) public onlyOwner {
        marketAddress = addr;
    }
    //设置基金地址 setFundAddress
    function setFundAddress(address addr) public onlyOwner {
        fundAddress = addr;
    }
    //设置分红手续费 setFeeTax，对应百分比整数，默认=2
    function setFeeTax(uint256 FeeTax) public onlyOwner {
        _FeeTax = FeeTax;
        _previousFeeTax = _FeeTax;
    }
    //设置其他手续费 setFeeElse，对应百分比整数，默认=12
    function setFeeElse(uint256 FeeElse) public onlyOwner {
        _FeeElse = FeeElse;
        _previousFeeElse = _FeeElse;
    }
    //设置修改免手续费地址 setExcludedFee，true不要手续费
    function setExcludedFee(address addr, bool state) public onlyOwner {
        _isExcludedFee[addr] = state;
    }
    //设置可操作角色地址 setRoler
    function setRoler(address addr, bool state) public onlyOwner {
        _roler[addr] = state;
    }


    //=========================调用锁仓期权合约===================
    // 释放代币
    function call_release(address[] memory _contract) public view returns (bool,address){
        //require(_msgSender() == mainAddress , "not authorized"); //任何人都可以执行
        require(_contract.length > 0, "not address[]");
        bytes4 id=bytes4(keccak256("release(address)"));
		for (uint i = 0; i < _contract.length; i++) {
            //注意此处要用 staticcall
            (bool success,bytes memory data) = _contract[i].staticcall(abi.encodeWithSelector(id,address(this)));
            if(success){
                if(!abi.decode(data,(bool)))  (false,_contract[i]);
            }
            else return (false,_contract[i]);
        }
        return (true,address(0));
    }
    // 回收代币
    function call_revoke(address[] memory _contract) public view returns (bool,address){
        require(_msgSender() == mainAddress , "not authorized"); //只有mainAddress可以执行
        require(_contract.length > 0, "not address[]");
        bytes4 id=bytes4(keccak256("revoke(address)"));
		for (uint i = 0; i < _contract.length; i++) {
            (bool success,bytes memory data) = _contract[i].staticcall(abi.encodeWithSelector(id,address(this)));
            if(success){
                if(!abi.decode(data,(bool)))  (false,_contract[i]);
            }
            else return (false,_contract[i]);
        }
        return (true,address(0));
    }


    //==== 授权角色地址可操作的：修改回流地址 setLiquidAddress、最大转币数量 setMaxSellAmount、最大卖币比例 setMaxSellRate、===
    //==== 邀请关系 setInviter、设置是否为交易对合约地址 setIsSwapPair =================
    //设置回流地址 （发送地址是设置了权限角色地址）
    function setLiquidAddress(address addr) public {
        require((_roler[_msgSender()] || _msgSender() == owner()) && addr != address(0), "not authorized");
        liquidAddress = addr;
    }
    //设置修改最大卖币量整数 setMaxSellAmount
    function setMaxSellAmount(uint256 maxSellAmount) public  {
        require((_roler[_msgSender()] || _msgSender() == owner()) , "not authorized");
        _maxSellAmount = maxSellAmount  * 10 ** uint256(_decimals);
    }
    //设置修改最大买币量整数 setMaxBuyAmount
    function setMaxBuyAmount(uint256 maxBuyAmount) public  {
        require((_roler[_msgSender()] || _msgSender() == owner()) , "not authorized");
        _maxBuyAmount = maxBuyAmount  * 10 ** uint256(_decimals);
    }    
    //设置修改最大卖币量比例 setMaxSellRate
    function setMaxSellRate(uint256 maxSellRate) public  {
        require((_roler[_msgSender()] || _msgSender() == owner()) , "not authorized");
        _maxSellRate = maxSellRate;
    }
    //设置可以卖币次量（0=不限制）setSellNum
    function setSellNum(uint256 _Num) public {
        require((_roler[_msgSender()] || _msgSender() == owner()) , "not authorized");
        _SellNum = _Num;
    }
    //设置修改邀请关系（发送地址是设置了权限角色地址）
    function setInviter(address a1, address a2) public {
        require((_roler[_msgSender()] || _msgSender() == owner()) && a1 != address(0) && a2 != address(0), "not authorized");
        _inviter[a1] = a2;
    }
    //设置修改地址是不是交易对合约地址
    function setIsSwapPair(address addr, bool state) public {
        require((_roler[_msgSender()] || _msgSender() == owner()) && addr != address(0), "not authorized");
        _isSwapPair[addr] = state;
    }
    //设置批量冻结帐户地址 [地址1,地址2,地址3] setFrozenAccount
    function setFrozenAccount(address[] memory target, bool _Bool) public {
        require(target.length > 0, "not address[]");
        require((_roler[_msgSender()] || _msgSender() == owner()) , "not authorized");    
		for (uint i = 0; i < target.length; i++) {
			_frozenAccount[target[i]] = _Bool;
        }
    }
     //设置批量白名单地址  [地址1,地址2,地址3] setWhiteAccount
    function setWhiteAccount(address[] memory target, bool _Bool) public {
        require(target.length > 0, "not address[]");
        require((_roler[_msgSender()] || _msgSender() == owner()) , "not authorized");
        for (uint i = 0; i < target.length; i++) {
 			_whiteAccount[target[i]] = _Bool;
        }
    }
    //设置是否启动仅限白名单交易功能 setWhiteBool
    function setWhiteBool(bool _Bool) public {
        require((_roler[_msgSender()] || _msgSender() == owner()) , "not authorized");
        _WhiteBool = _Bool;
    }
    //设置是否可以卖开关 setSellBool
    function setSellBool(bool _Bool) public {
        require((_roler[_msgSender()] || _msgSender() == owner()) , "not authorized");
        _SellBool = _Bool;
    }

    //================== 普通操作 ==============================
    //批量转币发送,数量不用考虑小数点位数
    function BatchSend(address[] memory _tos, uint256[] memory _value) public {
        require(_tos.length > 0, "not _tos[]");
        require(_value.length > 0, "not _value[]");
        uint256 total = 0;
        uint i;
        //转账额相同的方式
        if(_value.length==1){
            total = _tos.length * _value[0];
        } else {
            require(_tos.length == _value.length, "The two arrays are different in length");
            for (i = 0; i < _value.length; i++) {
 			    total = total + _value[i]*(10**uint256(_decimals));
            }
        }      
        require(balanceOf(_msgSender()) >= total, "All transfers amount exceeds balance");    
        for (i = 0; i < _tos.length; i++) {
            if(_value.length==1)
			    transfer(_tos[i], _value[0]*(10**uint256(_decimals)));
            else
                transfer(_tos[i], _value[i]*(10**uint256(_decimals)));
        }
    }


    //=================== 相关查询 ===============================

	/* 测试可用
	//查询主地址额度
    function GetMain() public view returns (uint256) {
        return balanceOf(mainAddress) / (10 ** uint256(_decimals));
    }
	//查询销毁地址额度
    function GetBurn() public view returns (uint256) {
        return balanceOf(burnAddress) / (10 ** uint256(_decimals));
    }
	//查询市场地址额度
    function GetMarket() public view returns (uint256) {
        return balanceOf(marketAddress) / (10 ** uint256(_decimals));
    }
	//查询基金地址额度
    function GetFund() public view returns (uint256) {
        return balanceOf(fundAddress) / (10 ** uint256(_decimals));
    }
    //查询回流地址额度
    function GetLiquidity() public view returns (uint256) {
        return balanceOf(liquidAddress) / (10 ** uint256(_decimals));
    }
    */

    /*
    //==根据是否要收手续费，来计算要转的映射数量, 此数量值很大，好像意义不大
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    } 
    */

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}


    //===================获取当前比例==========================
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    // ======获取相应相关数值。返回： 比例总额、比例转币额、比例分红额、实际转币额、分红额、其他手续费额======
    function _getValues(uint256 tAmount) private view returns 
    (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tTaxFee, uint256 tElseFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rTaxFee) = 
            _getRValues(tAmount, tTaxFee, tElseFee, _getRate());
        //返回： 比例总额、比例转币额、比例分红额、实际转币额、分红额、其他手续费额
        return (rAmount, rTransferAmount, rTaxFee, tTransferAmount, tTaxFee, tElseFee);
    }
    //获得：实际转币额度、分红手续费额度、其他手续费额度
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tTaxFee = calculateTaxFee(tAmount);
        uint256 tElseFee = calculateElseFee(tAmount);        
        uint256 tTransferAmount = tAmount.sub(tTaxFee).sub(tElseFee);
        return (tTransferAmount, tTaxFee, tElseFee);
    }
    //获得：返回： 比例总额、比例转币额、比例分红额
    function _getRValues(uint256 tAmount, uint256 tTaxFee, uint256 tElseFee, uint256 currentRate) 
    private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTaxFee = tTaxFee.mul(currentRate);
        uint256 rEleseFee = tElseFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rTaxFee).sub(rEleseFee);
        return (rAmount, rTransferAmount, rTaxFee);
    }
    //计算对应分红手续费
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_FeeTax).div(100);
    }
    //计算对应其他手续费
    function calculateElseFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_FeeElse).div(100);
    }


    //移除所有手续费
    function removeAllFee() private {
        if(_FeeTax == 0 && _FeeElse == 0) return;
        _previousFeeTax = _FeeTax;
        _previousFeeElse = _FeeElse;
        _FeeTax = 0;
        _FeeElse = 0;
    }
    //还原手续费设置
    function restoreAllFee() private {
        _FeeTax = _previousFeeTax;
        _FeeElse = _previousFeeElse;
    }



    //转币核心
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "RISK: Transfer from the zero address");  //转出为非零地址
        require(to != address(0), "RISK: Transfer to the zero address");      //转入为非零地址        
        //require(amount > 0, "RISK: Transfer amount must be greater than zero");  //数量大于0,不要此句，用来激活空投

        //检查 是否为 冻结帐户 
        require(!_frozenAccount[from], "RISK: Transfer from Account is frozen");
        require(!_frozenAccount[to], "RISK: Transfer to Account is frozen");

        //如果接收地址 是合约地址 并且是交易对合约地址 ；是卖币
        if (isContract(to) && _isSwapPair[to]) {
            require(_SellBool,"RISK: Sell not allowed");
            if (_WhiteBool) { 
                require(_whiteAccount[from],"RISK: Sell account not in white list");  //如果只允许白名单交易
            }  
            require( _maxSellAmount <= 0 || amount <= _maxSellAmount, "RISK: Transfer amount exceeds the maxSellAmount."); //卖币最大量
            require(amount <= balanceOf(from) * _maxSellRate / 100, "RISK: Transfer amount exceeds the maxSellRate.");   //最多一次转比例（可反复） 
            //如果对卖出次数有限制 同时卖出地址不是白名单，则判断是否超卖次数
			if(_SellNum >0 && !_whiteAccount[from]){
				require(_onSellNum[from] <= _SellNum, "RISK: Number of sell exceeds"); //大于卖出次数                
            }    
            _onSellNum[from]++; //卖出一次记录+1 
        }
        
        //发送地址 是合同地址且是交易对地址，则奖励地址为接收地址的推荐关系，表示是 交易所买币
        if (isContract(from) && _isSwapPair[from]) {   
            if (_WhiteBool) { require(_whiteAccount[to],"RISK: Buy account not in white list"); }
            else { require( _maxBuyAmount <= 0 || amount <= _maxBuyAmount, "RISK: Transfer amount exceeds the maxBuyAmount."); } //买币最大量
        } 
       
        bool takeFee = true;  //默认要手续费
        if(_isExcludedFee[from] || _isExcludedFee[to]) {
            takeFee = false;
        }

        //判断是不是要求：发送地址的邀请地址为0、发送和接收地址都不是合约地址
        bool shouldInvite = (_inviter[to] == address(0)  && !isContract(from) && !isContract(to));

        _tokenTransfer(from, to, amount, takeFee);

        //如果是邀请关系则记录，转币给对方，则绑定了推荐关系
        if (shouldInvite) {
            _inviter[to] = from;
        }
    }


    //根据是否要手续费来处理转账
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {   //如果不要手续费，移除所有比例关系
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if(!takeFee) {
            restoreAllFee();
        }
    }

    //转账、交易 细则
    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        //比例总额、比例转币额、比例分红额、实际转币额、分红额、其他手续费额
        (uint256 rAmount, uint256 rTransferAmount, uint256 rTaxFee, uint256 tTransferAmount, uint256 tTaxFee, uint256 tElseFee)
             = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);                //发送地址减去比例总交易额
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);  //接收地址添加比例接收额度
        emit Transfer(sender, recipient, tTransferAmount);
        
        //如果不扣手续费，则退出
        if (!takeFee) {
            return;
        }
        
        //如果销毁地址数量小于总发行量的50%，主地址数量大于交易总额 ；则 实现流通即通缩
        if (balanceOf(burnAddress) < _totalSupply.mul(50).div(100) && balanceOf(mainAddress) > tAmount) {
            _rOwned[mainAddress] = _rOwned[mainAddress].sub(rAmount);
            _takeBurn(mainAddress, tAmount);
        }

        //买卖手续费14% = 持币分红2% + 其他12%
        _takeInviterFee(sender, recipient, tAmount); // 6% （动态奖分成拿8代共6%）
        _takeLiquidity(sender, tElseFee.div(6)); // 2% （回流2%）
        _takeBurn(sender, tElseFee.div(6));      // 2% （销毁2%）
        _takeMarket(sender, tElseFee.div(12));   // 1% （营销1%）
        _takeFund(sender, tElseFee.div(12));     // 1% （基金1%）

        _reflectFee(rTaxFee, tTaxFee);        // 2% （持币分红2%）
    }

    //邀请动态奖分成拿8代共6%: 一代2%；二代1%；三至八代0.5%
    function _takeInviterFee(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();  //获取当前比例

        address cur = sender;               //设置接收邀请奖励地址

        //发送地址 是合同地址且是交易对地址，则奖励地址为接收地址的推荐关系，表示是交易所买币
        if (isContract(sender) && _isSwapPair[sender]) {
            cur = recipient;
        } 

        uint8[8] memory inviteRate = [20, 10, 5, 5, 5, 5, 5, 5];
        for (uint8 i = 0; i < inviteRate.length; i++) {
            uint8 rate = inviteRate[i];
            cur = _inviter[cur];
            if (cur == address(0)) {
                cur = burnAddress;  //如果没有推荐地址，则转销毁地址
            }
            uint256 curTAmount = tAmount.mul(rate).div(1000);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            emit Transfer(sender, cur, curTAmount);
        }
    }
    //回流
    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[liquidAddress] = _rOwned[liquidAddress].add(rLiquidity);
        emit Transfer(sender, liquidAddress, tLiquidity);
    }
    //销毁
    function _takeBurn(address sender,uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
        _tTotal = _tTotal.sub(tBurn);  //通缩流通量
        emit Transfer(sender, burnAddress, tBurn);
    }
    //市场
    function _takeMarket(address sender, uint256 tDev) private {
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[marketAddress] = _rOwned[marketAddress].add(rDev);
        emit Transfer(sender, marketAddress, tDev);
    }
    //基金
    function _takeFund(address sender, uint256 tDev) private {
        uint256 currentRate =  _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[fundAddress] = _rOwned[fundAddress].add(rDev);
        emit Transfer(sender, fundAddress, tDev);
    }
    //分红
    function _reflectFee(uint256 rTaxFee, uint256 tTaxFee) private {
        _rTotal = _rTotal.sub(rTaxFee);               //映射总量减对应分红
        _tTaxFeeTotal = _tTaxFeeTotal.add(tTaxFee);   //分红总量添加数量
    }



    // 计算通过UNI2的create2方法产生的pair交易对地址， 
	// 注意这个init code hash... 要根据具体的交易所部署的工厂合约地址对应。BNB智能工厂合约里的Read Contract可以查到
	// factory 工厂合约地址 tokenA 代币A合约地址 tokenBtokenB 代币B合约地址
    function UNIpairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash 以太网上的
                )))));
    }
    function PANCAKEpairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash 币安智能链的
                )))));
    }

}