/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
//Context
abstract contract Context{
    function _msgSender() internal view virtual returns (address){
        return msg.sender;
    }
}
//Ownerble
abstract contract Ownable is Context{
    address private _owner;
    constructor(){
        _owner = _msgSender();
    }
    modifier onlyOwner(){
        require(_owner == _msgSender(), "Ownable: caller is not owner");
        _;
    }
}
//Pausable
abstract contract Pausable is Context, Ownable{
    event Paused(address account);
    event Unpaused( address account);
    bool private _paused;
    constructor(){
        _paused = false;
    }
    function paused() public view virtual returns (bool){
        return _paused;
    }
    modifier whenNotPause(){
        require(!paused(),"Pausable: paused");
        _;
    }
    modifier whenPaused(){
        require(paused(), "Pausable: not paused");
        _;
    }
    function pause() external whenNotPause onlyOwner{
        _paused = true;
        emit Paused(_msgSender());
    }
    function unPause() external whenNotPause onlyOwner{
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
//Hero Cat
contract HeroCats is Context, Pausable{
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    //
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    //
    constructor(){
        _name = "Hero Cats 2502";
        _symbol = "HCC2502";
        _decimals = 18;
        _totalSupply = 170*10**6*10**18;
        _balances[_msgSender()] += _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    //
    function name() external view returns (string memory){
        return _name;
    }
    function symbol() external view returns (string memory){
        return _symbol;
    }
    function decimals() external view returns (uint8){
        return _decimals;
    }
    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }
    //
    function balanceOf(address account) external view returns (uint256){
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) external returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) external view returns (uint256){
        return _allowances[owner][spender];
    }
    function approval(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool){
        require(_balances[from] >= amount, "Transfer amount exceeds balance");
        uint256 currAllow = _allowances[from][_msgSender()];
        require(currAllow >= amount, "Transfer amount exceeds allowance");
        _transfer(from, to, amount);
        unchecked{
            _approve(from, _msgSender(), currAllow-amount);
        }
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal whenNotPause virtual{
        require(sender != address(0), "Transfer from zero address");
        require(recipient != address(0), "Transfer to zero address");
        uint256 sb = _balances[sender];
        require(sb >= amount, "Transfer amount exceeds balance");
        unchecked{
            _balances[sender] = sb - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual{
        require(owner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        require(_balances[owner] >= amount, "Approve exceeds balance");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    //
    function burn(address account, uint256 amount) external onlyOwner{
        require(account != address(0), "Burn from zero address");
        uint256 accBalance = _balances[account];
        require(accBalance >= amount, "Burn amount exceeds balance");
        unchecked{
            _balances[account] = accBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}