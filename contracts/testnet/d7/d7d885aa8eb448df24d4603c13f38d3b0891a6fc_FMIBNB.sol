/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

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


    struct genVars {
        uint256 _platformFee;
        bool _powerSwitch;
        uint8 _decimals;
        uint256 _initialSupply;
        string _name;
        string _symbol;
    }

    genVars private _genVars;

    struct burnInit {
        string toAddress;
        uint256 amount;
    }

    struct mintInit {
        address toAddress;
        uint256 amount;
    }

    mapping(address => mapping(string => burnInit)) private burnReq;
    mapping(string => mapping(string => mintInit)) private mintReq;

    event Burn(string uuId, address fromAddress, string toAddress, uint256 amount);
    event Mint(string uuId, string fromAddress, address toAddress, uint256 amount);
    event PowerSwitch(bool powerSwitchStatus);
    event PlatformFee(uint256 platformFee);
    event IncreaseSupply(uint256 amount);
    event DecreaseSupply(uint256 amount);
    event DeleteBurnRequest(string uuId, address fromAddress);
    event DeleteMintRequest(string uuId, string fromAddress);

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 platformFee_, uint256 totalSupply_) {
        _genVars._name = name_;
        _genVars._symbol = symbol_;
        _totalSupply = totalSupply_;
        _genVars._platformFee = platformFee_;
        _creator = msg.sender;
        _genVars._decimals = decimals_;
        _balances[msg.sender] = _totalSupply;
        _genVars._initialSupply = _totalSupply;
    }


    function burn(string memory uuId, address fromAddress, string memory toAddress, uint256 amount) public checkPowerStatus returns (bool) {
        require(fromAddress != address(0), "BRIDGE: burn from the zero address");
        require(bytes(uuId).length != 0, "BRIDGE: uuId is empty");
        require(bytes(burnReq[fromAddress][uuId].toAddress).length == 0 && burnReq[fromAddress][uuId].amount == 0, "BRIDGE: request already exist");
        require(bytes(toAddress).length != 0, "BRIDGE: toAddress is empty");
        require(amount != 0, "BRIDGE: invalid amount");
        require(balanceOf(fromAddress) >= amount, "BRIDGE: insuficiant token balance");

        burnReq[fromAddress][uuId].toAddress = toAddress;
        burnReq[fromAddress][uuId].amount = amount;
        _burn(fromAddress, amount);
        emit Burn(uuId,fromAddress,toAddress,amount);
        return true; 
    }

    function mint(string memory uuId, string memory fromAddress, address toAddress, uint256 amount) public checkPowerStatus onlyCreator returns (bool) {
        require(bytes(uuId).length != 0, "BRIDGE: uuId is empty");
        require(bytes(fromAddress).length != 0, "BRIDGE: fromAddress is empty");
        require(amount != 0, "BRIDGE: invalid amount");
        require(balanceOf(_creator) >= amount, "BRIDGE: insuficiant funds creator"); 
        require(mintReq[fromAddress][uuId].toAddress != toAddress && mintReq[fromAddress][uuId].amount == 0, "BRIDGE: request already exist");

        mintReq[fromAddress][uuId].toAddress = toAddress;
        mintReq[fromAddress][uuId].amount = amount;
        _mint(toAddress, amount);
        emit Mint(uuId,fromAddress,toAddress,amount);
        return true; 
    }

    function deleteBurnRequest(string memory uuId, address fromAddress) public checkPowerStatus onlyCreator returns (bool) {
        delete burnReq[fromAddress][uuId];
        emit DeleteBurnRequest(uuId,fromAddress);
        return true;
    }

    function deleteMintRequest(string memory uuId, string memory  fromAddress) public checkPowerStatus onlyCreator returns (bool) {
        delete mintReq[fromAddress][uuId];
        emit DeleteMintRequest(uuId,fromAddress);
        return true;
    }

    function setPowerSwitch(bool switchStatus) public onlyCreator returns (bool) {
        _genVars._powerSwitch = switchStatus;
        emit PowerSwitch(switchStatus);
        return _genVars._powerSwitch;
    }

    function setPlatformFee(uint256 platformFees) public onlyCreator returns (bool) {
        require(platformFees <= (20*(10**_genVars._decimals)), "BRIDGE: fee could not be more then 20%");
        _genVars._platformFee = platformFees;
        emit PlatformFee(platformFees);
        return true;
    }

    function burnRequestsFull(address fromAddress, string memory uuId) public view returns (burnInit memory) {
        return burnReq[fromAddress][uuId];
    }

    function mintRequestsFull(string memory fromAddress, string memory uuId) public view returns (mintInit memory) {
        return mintReq[fromAddress][uuId];
    }

    function burnRequests(address fromAddress, string memory uuId) public view returns (string memory, uint256) {
        return (burnReq[fromAddress][uuId].toAddress, burnReq[fromAddress][uuId].amount);
    }

    function mintRequests(string memory fromAddress, string memory uuId) public view returns (address, uint256) {
        return (mintReq[fromAddress][uuId].toAddress, mintReq[fromAddress][uuId].amount);
    }

    function name() public view returns (string memory) {
        return _genVars._name;
    }

    function symbol() public view returns (string memory) {
        return _genVars._symbol;
    }

     modifier onlyCreator() {
        require(msg.sender == _creator); 
        _;                              
    } 

    modifier checkPowerStatus() {
        require(_genVars._powerSwitch == false,"BRIDGE: is currently off"); 
        _;                              
    } 

    function powerSwitchStatus() public view returns (bool) {
        return _genVars._powerSwitch;
    }

    function platformFee() public view returns (uint256) {
        return _genVars._platformFee;
    }

    function decimals() public view returns (uint8) {
        return _genVars._decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function initialSupply() public view returns (uint256) {
        return _genVars._initialSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function decreaseSupply(uint256 amount) public checkPowerStatus onlyCreator returns (bool) {
        require(amount != 0, "BRIDGE: invalid amount");
        _burn(_creator, amount);
        emit DecreaseSupply(amount);
        return true; 
    }

    function increaseSupply(uint256 amount) public checkPowerStatus onlyCreator returns (bool) {
        require(amount != 0, "BRIDGE: invalid amount");
        _mint(_creator, amount);
        emit IncreaseSupply(amount);
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