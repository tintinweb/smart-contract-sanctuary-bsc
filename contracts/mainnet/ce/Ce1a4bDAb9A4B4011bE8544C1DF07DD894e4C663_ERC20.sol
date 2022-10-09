/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.6; 6或者0都可以
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _circulation = 1000000000 * 10**18;
    uint256 private _allTotalSupply;//总发行量
    uint256 private _totalSupply;//代币当前量  总发行量 - 销毁
    string private _name = "Decentralized MT4";
    string private _symbol = "DMT4";
    uint256 public _minimum = 1 * 10**16;//最小持币量
    //管理员
    address private owners_;
    modifier Owner {
        require(owners_ == msg.sender);
        _;
    }
    //收手续费的地址集合(薄饼的路由合约以及代币合约)
    mapping(address=>bool) public _TransactionList;
    //不收手续费的地址集合
    mapping(address=>bool) public _FreeAddressList;
    //黑名单的地址集合(只可以入币  不可以出币)
    mapping(address=>bool) public  _blacklistAddressList;
    //合约白名单
    mapping(address=>bool) private _WhiteListContract;
    modifier WhiteList {   //合约白名单
        require(_WhiteListContract[msg.sender]);
        _;
    }

    //收取交易手续费的地址
    address public _serviceAddress;




    /**
    * ----事件
    */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);

    /**
    * 构造
    *   ---- totalSupply_ 初始发行
    *   ---- serviceAddress_ 手续费收取地址
    */
    constructor(uint256 totalSupply_ , address serviceAddress_) {
        _serviceAddress = serviceAddress_;
        owners_ = msg.sender;
        _mint(msg.sender, totalSupply_ * 10**decimals());
    }
    /**
    * 修改管理员
    */
    function setOwner(address owners) 
        public 
        Owner 
        returns (bool)
    {
        owners_ = owners;
        return true;
    }
    /****
    * 修改手续费地址
    */
    function setServiceAddress(address serviceAddress_) 
        public 
        Owner 
        returns (bool)
    {
        _serviceAddress = serviceAddress_;
        return true;
    }
    /****
    * 设置收手续费的地址集合(薄饼的路由合约以及代币合约)
    */
    function setTransactionList(address TransactionList_,bool state_) 
        public 
        Owner 
        returns (bool)
    {
        _TransactionList[TransactionList_] = state_;
        return true;
    }
    /****
    * 设置不收手续费的地址集合
    */
    function setFreeAddressList(address FreeAddressList_,bool state_) 
        public 
        Owner 
        returns (bool)
    {
        _FreeAddressList[FreeAddressList_] = state_;
        return true;
    }
    /****
    * 设置黑名单的地址集合(只可以入币  不可以出币)
    */
    function setBlacklistAddressList_(address blacklistAddressList_,bool state_) 
        public 
        Owner 
        returns (bool)
    {
        _blacklistAddressList[blacklistAddressList_] = state_;
        return true;
    }
    /****
    * 修改合约白名单
    */
    function setWhiteListContract(address WhiteListContract_,bool state_) 
        public 
        Owner 
        returns (bool)
    {
        _WhiteListContract[WhiteListContract_] = state_;
        return true;
    }

    /**
    * 铸造
    */
    function toMint(address to_,uint256 amount_) 
        public 
        WhiteList 
        returns(bool)
        {
            _mint(to_,amount_);
            return true;
        }

    function name() 
        public 
        view
        virtual 
        returns (string memory) 
    {
        return _name;
    }
    function symbol() 
        public 
        view 
        virtual 
        returns (string memory) 
    {
        return _symbol;
    }
    function decimals() 
        public 
        view 
        virtual 
        returns (uint8) 
    {
        return 18;
    }
    /**
    * 返回管理员地址
    */
    function owner()
        public 
        view 
        returns(address)
    {
        return owners_;
    }
    /**
    * 返回代币总发行量
    */
    function alltotalSupply() 
        public 
        view 
        virtual 
        returns (uint256)
    {
        return _allTotalSupply;
    }
    /**
    * 返回存在的代币数量
    */
    function totalSupply() 
        public 
        view 
        virtual 
        returns (uint256) 
    {
        return _totalSupply;
    }
    /**
    * 返回代币的销毁数量
    */
    function burnAmount() 
        public 
        view 
        virtual 
        returns (uint256) 
    {
        return _allTotalSupply - _totalSupply;
    }
    /**
    * 地址是否在白名单中
    */
    function WhiteListContract(address address_) 
        public 
        view 
        returns (bool)
    {
        return _WhiteListContract[address_];
    }
    /**
    * 交易手续费
    */
    function serviceCharge() 
        public 
        view 
        returns(uint256)
    {
        uint256 service_;
        if(burnAmount() < 10000000 * 10**decimals()){
            service_ = 30;
        }else if(burnAmount() >= 10000000 * 10**decimals() && burnAmount() < 30000000 * 10**decimals()){
            service_ = 20;
        }else if(burnAmount() >= 30000000 * 10**decimals() && burnAmount() < 100000000 * 10**decimals()){
            service_ = 10;
        }else if(burnAmount() > 100000000 * 10**decimals() && burnAmount() <= 300000000 * 10**decimals()){
            service_ = 5;
        }else{
            service_ = 0;
        }
        return service_;
    }
    function balanceOf(address account)
        public
        view
        virtual
        returns (uint256)
    {
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
    function allowance(address owners, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[owners][spender];
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_blacklistAddressList[sender] == false, "ERC20: Address is not tradable");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        uint256 buyinnumber = amount;
        uint256 service_ = serviceCharge();
        if(_TransactionList[sender] && !_FreeAddressList[recipient]){
            _balances[_serviceAddress] += amount*service_/1000;
            emit Transfer(sender, _serviceAddress, amount*service_/1000);
            buyinnumber = amount - (amount*service_/1000);
        }

        if(_TransactionList[recipient] && !_FreeAddressList[sender]){
            _balances[_serviceAddress] += amount*service_/1000;
            emit Transfer(sender,_serviceAddress, amount*service_/1000);  
            buyinnumber = amount - (amount*service_/1000); 
            amount = buyinnumber;
        }
        _balances[recipient] += buyinnumber;
        uint256 fromsurplus = _balances[sender];
        require(
            fromsurplus >= _minimum,
            "ERC20: Cannot transfer out all"
        );
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_allTotalSupply + amount <= _circulation, "ERC20: Upper limit of issuance");
        _beforeTokenTransfer(address(0), account, amount);
        _allTotalSupply += amount;
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
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
    function _approve(
        address owners,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owners != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owners][spender] = amount;
        emit Approval(owners, spender, amount);
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
    ) internal virtual {
        
    }
}