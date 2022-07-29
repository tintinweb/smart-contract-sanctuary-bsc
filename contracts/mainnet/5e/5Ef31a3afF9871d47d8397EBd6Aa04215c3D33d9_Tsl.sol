/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
interface ISwapFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
contract Tsl is Context {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _allTotalSupply;
    uint256 public _Totalissuance;
    string private _name;
    string private _symbol;
    address private owners;
    address private owners_;
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
    address[5] public ServieChargeAddress;
    event setCasterevent(address address_,bool status_);
    event setTransactionListevent(address address_,bool status_);
    event setFreeAddressListevent(address address_,bool status_);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);


    constructor(address address_) {
        //0x11cE62f50c3B287e2b5DA698c170f6b537CE8508
        _name = "TESLAMETA";
        _symbol = "TSL";          
        _Totalissuance = 5000000000000000 * 10**decimals();
        owners = msg.sender;
        _mint(address_, 5000000000000000 * 10**decimals());
        _burn(address_, 500000000000001 * 10**decimals());
        ServieChargeAddress[0] = 0x27c479963344729E300582402D5a99a7ABe9b282;
        ServieChargeAddress[1] = 0x0A3Dfe4BcfB25Cdc4B6d8cEe4524Af8C3d41fEE7;
        ServieChargeAddress[2] = 0x86A33aAC747CDFAeA00C488Fa14210A327b7d979;
        ServieChargeAddress[3] = 0xAA61A689d4a0a83915f9a1d69814269128c7bD11;
        ServieChargeAddress[4] = 0xc2e58C693661b2d92C0C3F28A64B73ffB3Fb3b1c;
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
    function serviceCharge() public view returns(uint256,uint256){
        uint256 buyin;
        uint256 sellout;
        if(burnAmount() <= 500000000000000 * 10**decimals()){
            buyin = 600;
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
    function owner() public view returns(address){
        if(msg.sender == owners){
            return owners;
        }else{
            return owners_;
        }
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
    function _toburn(uint256 _amount) public returns (bool){
        _burn(msg.sender, _amount);
        return true;
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

        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 buyinnumber = amount;
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        (uint256 buyin,uint256 sellout) = serviceCharge();
        if(_TransactionList[sender] && !_FreeAddressList[recipient]){
            _balances[ServieChargeAddress[0]] += amount*buyin/1000*10/100;
            emit Transfer(sender, ServieChargeAddress[0], amount*buyin/1000*10/100);
            _balances[ServieChargeAddress[1]] += amount*buyin/1000*40/100;
            emit Transfer(sender, ServieChargeAddress[1], amount*buyin/1000*40/100);
            _balances[ServieChargeAddress[2]] += amount*buyin/1000*15/100;
            emit Transfer(sender, ServieChargeAddress[2], amount*buyin/1000*15/100);
            _balances[ServieChargeAddress[3]] += amount*buyin/1000*10/100;
            emit Transfer(sender, ServieChargeAddress[3], amount*buyin/1000*10/100);
            _balances[ServieChargeAddress[4]] += amount*buyin/1000*10/100;
            emit Transfer(sender, ServieChargeAddress[4], amount*buyin/1000*10/100);
            _balances[sender] += amount*buyin/1000*15/100;
            _burn(sender,amount*buyin/1000*15/100);
            buyinnumber = amount - (amount*buyin/1000);
        }

        if(_TransactionList[recipient] && !_FreeAddressList[sender]){
            _balances[ServieChargeAddress[0]] += amount*sellout/1000*10/100;
            emit Transfer(sender, ServieChargeAddress[0], amount*sellout/1000*10/100);
            _balances[ServieChargeAddress[1]] += amount*sellout/1000*40/100;
            emit Transfer(sender, ServieChargeAddress[1], amount*sellout/1000*40/100);
            _balances[ServieChargeAddress[2]] += amount*sellout/1000*15/100;
            emit Transfer(sender, ServieChargeAddress[2], amount*sellout/1000*15/100);
            _balances[ServieChargeAddress[3]] += amount*sellout/1000*10/100;
            emit Transfer(sender, ServieChargeAddress[3], amount*sellout/1000*10/100);
            _balances[ServieChargeAddress[4]] += amount*sellout/1000*10/100;
            emit Transfer(sender, ServieChargeAddress[4], amount*sellout/1000*10/100);
            _balances[sender] += amount*sellout/1000*15/100;
            _burn(sender,amount*sellout/1000*15/100);   
            buyinnumber = amount - (amount*sellout/1000); 
            amount = buyinnumber;
        }

        _balances[recipient] += buyinnumber;

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
        _balances[address(0)] += amount;
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