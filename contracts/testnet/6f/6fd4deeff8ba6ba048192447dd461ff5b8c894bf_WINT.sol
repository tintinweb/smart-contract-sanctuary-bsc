// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract WINT is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _owner;
    
    struct RecordStr{
            address Owner;//msg.sender;
            bytes32 privateKey;
            string Data;
            bool exists;
    }

    mapping(bytes32=> RecordStr) private records;


    constructor()  {
        _name = "winsci";
        _symbol = "SCI";
        _decimals = 4;
        _totalSupply = 2202202200000000;
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function store( string calldata _userKey, string calldata _data) external returns(bytes32){
        bytes32 _indexKey = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        bytes32 _privateKey = keccak256(abi.encodePacked(_userKey));
        require(records[_indexKey].exists != true,"Record of your Index Key already exists!");
        records[_indexKey] = RecordStr({Owner: msg.sender, privateKey: _privateKey, Data: _data, exists: true});
        //emit storeE(_indexKey);
        return (_indexKey);
    }

    function retrive(bytes32 _indexKey, string calldata _privateKey) external view returns(string memory){
      if(records[_indexKey].exists == true && records[_indexKey].privateKey == keccak256(abi.encodePacked(_privateKey))){
        return records[_indexKey].Data;
      }else{
        return 'Record dose not exists';
      }
    }

    function update(bytes32 _indexKey, string calldata _privateKey, string calldata _data) external  returns(bool){
        if(records[_indexKey].exists == true && records[_indexKey].Owner == msg.sender && records[_indexKey].privateKey == keccak256(abi.encodePacked(_privateKey))){
        records[_indexKey].Data = _data;
        return true;
        }else{
        return false;
        }
    }

    function remove(bytes32 _indexKey, string calldata _privateKey) external  returns(bool){
        if(records[_indexKey].exists == true && records[_indexKey].Owner == msg.sender && records[_indexKey].privateKey == keccak256(abi.encodePacked(_privateKey))){
        delete records[_indexKey];
        return true;
        }else{
        return false;
        }
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function mint(uint256 amount) public  virtual  returns (bool) {
        require(_msgSender() == _owner,"Owmer Only!");
        _mint(_msgSender(), amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function burn(uint256 amount) public  virtual  returns (bool) {
        require(_msgSender() == _owner,"Owmer Only!");
        _burn(_owner, amount);
        return true;
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
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}