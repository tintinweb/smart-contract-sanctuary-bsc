/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FMIBNB is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _creator;

    uint256 private _totalSupply;
    uint256 private _initialSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _platformFee;
    bool private _powerSwitch;

    struct burnInit {
        string toAddress;
        uint256 amount;
    }

    struct mintInit {
        address toAddress;
        uint256 amount;
    }

    mapping(address => mapping(string => burnInit)) private burnInitReq;
    mapping(string => mapping(string => mintInit)) private mintInitReq;

    event BurnInit(string uuId, address fromAddress, string toAddress, uint256 amount);
    event MintInit(string uuId, string fromAddress, address toAddress, uint256 amount);
    event Burn(string uuId, address fromAddress, string toAddress, uint256 amount);
    event Mint(string uuId, string fromAddress, address toAddress, uint256 amount);


    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 platformFee_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _platformFee = platformFee_;
        _creator = msg.sender;
        _decimals = decimals_;
        _balances[msg.sender] = _totalSupply;
        _initialSupply = _totalSupply;
    }


    function burnInitiate(string memory uuId, address fromAddress, string memory toAddress, uint256 amount) public checkPowerStatus returns (string memory) {
        require(fromAddress != address(0), "BRIDGE: burn from the zero address");
        require(bytes(uuId).length != 0, "BRIDGE: uuId is empty");
        require(bytes(burnInitReq[fromAddress][uuId].toAddress).length == 0 && burnInitReq[fromAddress][uuId].amount == 0, "BRIDGE: request already exist");
        require(bytes(toAddress).length != 0, "BRIDGE: toAddress is empty");
        require(amount != 0, "BRIDGE: invalid amount");
        require(balanceOf(fromAddress) >= amount, "BRIDGE: insuficiant token balance");

        burnInitReq[fromAddress][uuId].toAddress = toAddress;
        burnInitReq[fromAddress][uuId].amount = amount;
        emit BurnInit(uuId,fromAddress,toAddress,amount);
        return uuId; 
    }

    function mintInitiate(string memory uuId, string memory fromAddress, address toAddress, uint256 amount) public checkPowerStatus onlyCreator returns (string memory) {
        require(toAddress != address(0), "BRIDGE: mint from the zero address");
        require(bytes(uuId).length != 0, "BRIDGE: uuId is empty");
        require(mintInitReq[fromAddress][uuId].toAddress == address(0) && mintInitReq[fromAddress][uuId].amount == 0, "BRIDGE: request already exist");
        require(bytes(fromAddress).length != 0, "BRIDGE: fromAddress is empty");
        require(amount != 0, "BRIDGE: invalid amount");
        require(balanceOf(_creator) >= amount, "BRIDGE: insuficiant token balance creator");
        mintInitReq[fromAddress][uuId].toAddress = toAddress;
        mintInitReq[fromAddress][uuId].amount = amount;
        emit MintInit(uuId,fromAddress,toAddress,amount);
        return uuId; 
    }

    function actualBurn(string memory uuId, address fromAddress, string memory toAddress, uint256 amount) public checkPowerStatus onlyCreator returns (string memory) {
        require(bytes(uuId).length != 0, "BRIDGE: uuId is empty");
        require(bytes(toAddress).length != 0, "BRIDGE: toAddress is empty");
        require(amount != 0, "BRIDGE: invalid amount");
        require(burnInitReq[fromAddress][uuId].amount == amount, "BRIDGE: invalid amount");
        if(keccak256(abi.encodePacked(burnInitReq[fromAddress][uuId].toAddress)) != keccak256(abi.encodePacked(toAddress))) {
            return "BRIDGE: invalid request toaddress";
        } 
        _burn(fromAddress, amount);
        emit Burn(uuId,fromAddress,toAddress,amount);
        delete burnInitReq[fromAddress][uuId];
        return uuId; 
    }

    function actualMint(string memory uuId, string memory fromAddress, address toAddress, uint256 amount) public checkPowerStatus onlyCreator returns (string memory) {
        require(bytes(uuId).length != 0, "BRIDGE: uuId is empty");
        require(bytes(fromAddress).length != 0, "BRIDGE: fromAddress is empty");
        require(amount != 0, "BRIDGE: invalid amount");
        require(balanceOf(_creator) >= amount, "BRIDGE: insuficiant funds creator"); 
        require(mintInitReq[fromAddress][uuId].amount == amount, "BRIDGE: invalid amount");
        require(mintInitReq[fromAddress][uuId].toAddress == toAddress, "BRIDGE: invalid request toaddress");

        _mint(toAddress, amount);
        emit Mint(uuId,fromAddress,toAddress,amount);
        delete mintInitReq[fromAddress][uuId];
        return uuId; 
    }
    


    function setPowerSwitch(bool switchStatus) public onlyCreator returns (bool) {
        return _powerSwitch = switchStatus;
    }

    function setPlatformFee(uint256 platformFees) public onlyCreator returns (uint256) {
        return _platformFee = platformFees;
    }

    function burnRequestsFull(address fromAddress, string memory uuId) public view returns (burnInit memory) {
        return burnInitReq[fromAddress][uuId];
    }

    function mintRequestsFull(string memory fromAddress, string memory uuId) public view returns (mintInit memory) {
        return mintInitReq[fromAddress][uuId];
    }

    function burnRequests(address fromAddress, string memory uuId) public view returns (string memory, uint256) {
        return (burnInitReq[fromAddress][uuId].toAddress, burnInitReq[fromAddress][uuId].amount);
    }

    function mintRequests(string memory fromAddress, string memory uuId) public view returns (address, uint256) {
        return (mintInitReq[fromAddress][uuId].toAddress, mintInitReq[fromAddress][uuId].amount);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

     modifier onlyCreator() {
        require(msg.sender == _creator); 
        _;                              
    } 

    modifier checkPowerStatus() {
        require(_powerSwitch == false,"BRIDGE: is currently off"); 
        _;                              
    } 

    function powerSwitchStatus() public view returns (bool) {
        return _powerSwitch;
    }

    function platformFee() public view returns (uint256) {
        return _platformFee;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function initialSupply() public view returns (uint256) {
        return _initialSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function decreaseSupply(uint256 amount) public checkPowerStatus onlyCreator returns (bool) {
        require(amount != 0, "BRIDGE: invalid amount");
        _burn(_creator, amount);
        return true; 
    }

    function increaseSupply(uint256 amount) public checkPowerStatus onlyCreator returns (bool) {
        require(amount != 0, "BRIDGE: invalid amount");
        _mint(_creator, amount);
        return true; 
    }


    function transfer(address to, uint256 amount) public checkPowerStatus returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public checkPowerStatus view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public checkPowerStatus returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public checkPowerStatus returns (bool) {
        address spender = msg.sender;
        uint256 currentAllowance = allowance(from, spender);
        require(currentAllowance >= amount, "BRIDGE: insufficient allowance");

        uint256 subAmount = currentAllowance - amount;
        _approve(from, spender, subAmount);

        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public checkPowerStatus returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public checkPowerStatus returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "BRIDGE: Invalid request");
        require(to != address(0), "BRIDGE: Invalid request");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: insuficiant funds");
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal  {
        require(account != address(0), "BRIDGE: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BRIDGE: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BRIDGE: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BRIDGE: owner approve from the zero address");
        require(spender != address(0), "BRIDGE: spender approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}