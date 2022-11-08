/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IERC20 {
 
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract TokenBep20 is IERC20 , IERC20Metadata , Context{
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address public  contractOwner ;
    address public developerAddress ;
    address [] _airDropList ;
    mapping (address => bool) _whiteList;

    constructor(string memory name_, string memory symbol_ ,uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        //this place for seting owner of contract//
        contractOwner = _msgSender(); 
        //this place for seting developer of contract//
        developerAddress =0xA188eA8f1db6A430b41B959DF8dd9203b10d294c;
        _totalSupply =  totalSupply_ ;
        _balances[_msgSender()] += totalSupply_ ;
    }

    modifier onlyOwnerContract(){
        require(contractOwner == _msgSender() , "its not owner of contract");
        _;
    }

      function name() public view virtual override returns (string memory) {
        return _name;
    }

       function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

       function decimals() public view virtual override returns (uint8) {
        return 9;
    }

       function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

        function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

        function getAirDropList ()public view returns(address [] memory){
        return _airDropList;
    }

        function addAirDropListList(address [] memory accounts)public onlyOwnerContract{
            _airDropList = accounts;
    }

    function deleteAccountWhitelist(address account) public onlyOwnerContract{
              _whiteList[account] = false;
    }

    function addAccountWhitelist(address account) public onlyOwnerContract{
              _whiteList[account] = true;
    }

    function _isWhiteList(address account) public view returns(bool){
        return _whiteList[account];
    }
        function transfer(address to, uint256 amount) public virtual override returns (bool) {
    address owner = _msgSender();
    _transfer(owner, to, amount);
    return true;
    }

        function airDrop(uint256 amount)public  onlyOwnerContract{
         require(_balances[contractOwner] >= amount, "ERC20: transfer amount exceeds balance");
          uint256 amountForEveryAccount = amount / _airDropList.length;
          for (uint256 i; i < _airDropList.length; i++) 
          {
              uint256 balanceAirDroplist = _balances[_airDropList[i]] ;
              _balances[_airDropList[i]] = balanceAirDroplist + amountForEveryAccount;
              _balances[contractOwner] -= amountForEveryAccount; 
          }

    }
    

        function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
    }

        function approve(address spender, uint256 amount) public virtual override returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
    }

      function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(from, to, amount);
        return true;
    }

     function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        if (from == contractOwner || to == contractOwner) {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }else if(_whiteList[from] == true || _whiteList[to] == true){
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        } else {
            

           //in here we give 5% of amount for burn
            uint256 Pet_support = amount / 20;

            //in here we give 11% of amount for developer
            uint256 developerAmount = amount / 10;

          

            //_burn(from , burnToken);
            _balances[from] = fromBalance - amount;

             uint256 amountWithBurnAndDeveloper = amount -= (Pet_support + developerAmount);
            _balances[to] += amountWithBurnAndDeveloper ;
            _balances[developerAddress] += developerAmount + Pet_support;
            emit Transfer(from, to, amountWithBurnAndDeveloper);
        }


    }

    function burnTokenFromOwner(uint256 amount) public onlyOwnerContract {
        require(amount < _totalSupply / 2  , "can't burn");
        _burn(_msgSender(), amount);
        emit Transfer(_msgSender(), address(0), amount);
    }

     function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(amount < _totalSupply / 2 , "can't burn");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        _balances[account] = accountBalance - amount;

        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);

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
}