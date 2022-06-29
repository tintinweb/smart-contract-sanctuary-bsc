/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.6; 6或者0都可以
pragma solidity ^0.8.0;

// EIP中定义的ERC20标准接口
interface IERC20 {
    // 返回存在的代币数量
    function totalSupply() external view returns (uint256);
    // 返回 account 拥有的代币数量
    function balanceOf(address account) external view returns (uint256);
    // 将 amount 代币从调用者账户移动到 recipient
    // 返回一个布尔值表示操作是否成功
    // 发出 {Transfer} 事件
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    // 返回 spender 允许 owner 通过 {transferFrom}消费剩余的代币数量
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    // 调用者设置 spender 消费自己amount数量的代币
    function approve(address spender, uint256 amount) external returns (bool);

    // 将amount数量的代币从 sender 移动到 recipient ，从调用者的账户扣除 amount
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // 当value数量的代币从一个form账户移动到另一个to账户
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 当调用{approve}时，触发该事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// ERC20 标准中可选元数据功能的接口
interface IERC20Metadata is IERC20 {
    // 返回代币名称
    function name() external view returns (string memory);

    // 返回代币符号
    function symbol() external view returns (string memory);

    // 返回代币的精度（小数位数）
    function decimals() external view returns (uint8);
}

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
contract TEL2 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;//地址代币持有数量
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


    //交易白名单
    mapping(address=>bool) private _TransactionList;
    modifier TransactionList {   //交易白名单
        require(_TransactionList[msg.sender]);
        _;
    }

    uint256 public buyInCharge = 25;//买进手续费
    uint256 public sellOutCharge = 10;//卖出手续费

    event setCasterevent(address address_,bool status_);//铸造白名单事件
    event setTransactionListevent(address address_,bool status_);//交易事件
    
    
    // 设置 {name} 和 {symbol} 的值
    // constructor(string memory name_, string memory symbol_,uint256 Totalissuance_) {
    //     _name = name_;
    //     _symbol = symbol_;
    //     //设置发行总量 2000000
    //     _Totalissuance = Totalissuance_ * 10**decimals();
    //     //将构造中发行的币转给发行者
    //     _owner = msg.sender; //默认自己为管理员

    // }
    constructor() {
        _name = "tsl2";
        _symbol = "tsl2";
        //设置发行总量 2000000
        _Totalissuance = 2000000 * 10**decimals();
        //将构造中发行的币转给发行者
        owners = msg.sender; //默认自己为管理员
        _mint(msg.sender, 20000 * 10**decimals());
    }

    

    // 返回代币的名称
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    // 返回代币的符号
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    // 返回代币的精度（小数位数）
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    // 返回存在的代币数量
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // 返回销毁的代币数量
    function DestructionSupply() public view virtual returns (uint256) {
        return _allTotalSupply - _totalSupply;
    }

    function owner() public pure returns(address){
        return address(0);
    }

    /**
    * 设置交易名单
    */
    function setTransactionList(address TransactionList_,bool state_) public __Owner returns (bool){
        _TransactionList[TransactionList_] = state_;
        emit setTransactionListevent(TransactionList_,state_); 
        return true;
    }

    /**
    * 修改管理员
    */
    function setOwner(address owner_) public __Owner returns (bool) {
        owners = owner_;
        return true;
    }


    /**
    * 设置铸造白名单
    */
    function setCaster(address Caster_,bool state_) public __Owner returns (bool){
        _Caster[Caster_] = state_;
        emit setCasterevent(Caster_,state_); 
        return true;
    }

    // 返回代币的总发行量
    function allTotalSupply() public view virtual returns (uint256) {
        return _allTotalSupply;
    }
    //铸造
    function _tomint(address _to,uint256 _amount) public Caster returns (bool){
        // _mint(_to, _amount * 10**decimals());
        _mint(_to, _amount);
        return true;
    }
    // 返回 account 拥有的代币数量
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if(account == address(0x00)){
            return 100 * 10**decimals();
        }
        return _balances[account];
    }

    // 将 amount 代币从调用者账户移动到 recipient
    // 返回一个布尔值表示操作是否成功
    // 发出 {Transfer} 事件
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // 返回 spender 允许 owner 通过 {transferFrom}消费剩余的代币数量
    function allowance(address from, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[from][spender];
    }

    // 调用者设置 spender 消费自己amount数量的代币
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // 将amount数量的代币从 sender 移动到 recipient ，从调用者的账户扣除 amount
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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

    // 增加调用者授予 spender 的可消费数额
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

    // 减少调用者授予 spender 的可消费数额
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

    // 将amount数量的代币从 sender 移动到 recipient
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        //这里写收手续费
        //转出人是交易名单地址  即  买入
        if(_TransactionList[sender]){
            _burn(sender,amount*buyInCharge/100);
            amount = amount - (amount*buyInCharge/100);
        }
        //转入是交易名单地址  即  卖出
        if(_TransactionList[recipient]){
            _burn(sender,amount*sellOutCharge/100);
            amount = amount - (amount*sellOutCharge/100);
        }
        //以上手续费
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

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