/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AuTokenSingle {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _daddy, address indexed _spender, uint256 _value);
    event UpdateOwner(address indexed _address);
    event AddAdmin(address indexed _address);
    event DiscardAdmin(address indexed _address);
    event AddClient(address indexed _address);
    event RemoveClient(address indexed _address);
    event ContractPausedState(bool _value);

    address private owner;

    uint8 private tokenDecimals = 18;
    string private tokenName = "AuToken";
    string private tokenSymbol = "AUT";

    bool private contractPaused;
    uint256 private tokenTotalSupply;
    mapping (address => uint256) private balances;
    mapping (address => mapping(address => uint256)) private allowances;
    mapping (address => bool) private admins;
    mapping (address => bool) private clients;
    
    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true;
        clients[msg.sender] = true;
    }

    function updateOwner(address _address) external {
        require(_address != address(0), "AuTokenSingle: new owner address is zero");
        require(msg.sender == owner, "AuTokenSingle: You are not contract owner");
        owner = _address;
    }

    function addAdmin(address _address) external {
        require(_address != address(0), "AuTokenSingle: new admin address is zero");
        require(msg.sender == owner || admins[msg.sender], "AuthCenter: You are not admin");
        admins[_address] = true;
        emit AddAdmin(_address);
    }

    function discardAdmin(address _address) external {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        admins[_address] = false;
        emit DiscardAdmin(_address);
    }

    function addClient(address _address) external {
        require(_address != address(0), "AuTokenSingle: new client address is zero");
        require(admins[msg.sender], "AuthCenter: You are not admin");
        clients[_address] = true;
        emit AddClient(_address);
    }

    function removeClient(address _address) external {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        clients[_address] = false;
        emit RemoveClient(_address);
    }

    function setContractPaused() external {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        contractPaused = true;
        emit ContractPausedState(true);
    }
    
    function setContractUnpaused() external {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        contractPaused = false;
        emit ContractPausedState(false);
    }

    function isPaused() external view returns (bool)
    { return contractPaused; }

    function isAdmin(address _address) external view returns (bool)
    { return admins[_address]; }

    function isClient(address _address) external view returns (bool)
    { return clients[_address]; }

    function name() external view returns (string memory)
    {return tokenName;}

    function symbol() external view returns (string memory)
    {return tokenSymbol;}

    function decimals() external view returns (uint8)
    {return tokenDecimals;}

    function totalSupply() external view returns (uint256)
    {return tokenTotalSupply;}

    function balanceOf(address account) external view returns (uint256)
    {return balances[account];}

    function setTokenInfo(string memory _name, string memory _symbol) external {
        require(admins[msg.sender], "AuTokenSingle: You are not admin");
        tokenName = _name;
        tokenSymbol = _symbol;
    }

    function setTokenDecimals(uint8 _decimals) external {
        require(admins[msg.sender], "AuTokenSingle: You are not admin");
        tokenDecimals = _decimals;
    }

    function transfer(address _to, uint256 _amount) external {
        require(!contractPaused, "AuTokenSingle: contract paused");
        require(_to != address(0), "AuTokenSingle: 'to' account is zero");
        _transfer(msg.sender, _to, _amount);
    }

    function allowance(address _daddy, address _spender) external view returns (uint256) 
    {return allowances[_daddy][_spender];}

    function approve(address _spender, uint256 _amount) external {
        require(!contractPaused, "AuTokenSingle: contract paused");
        require(_spender != address(0), "AuTokenSingle: spender address is zero");
        require(clients[msg.sender],"AuTokenSingle: You are not our client");
        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) external {
        require(_from != address(0), "AuTokenSingle: 'from' account is zero");
        require(_to != address(0), "AuTokenSingle: 'to' account is zero");
        if (!admins[msg.sender]) {
            require(!contractPaused, "AuTokenSingle: contract paused");
            uint256 currentAllowance = allowances[_from][msg.sender];
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= _amount, "AuTokenSingle: insufficient allowance");
                allowances[_from][msg.sender] = currentAllowance - _amount;
                emit Approval(_from, msg.sender, currentAllowance - _amount);
            } else {emit Approval(_from, msg.sender, currentAllowance);}
        }
        _transfer(_from, _to, _amount);
        emit Transfer(_from, _to, _amount);
    }

    function mint(address _account, uint256 _amount) external {
        require(_account != address(0), "AuTokenSingle: mint account is zero");
        require(admins[msg.sender], "AuTokenSingle: You are not admin");
        tokenTotalSupply += _amount;
        balances[_account] += _amount;
        emit Transfer(address(0), _account, _amount);
    }

    function burn(address _account, uint256 _amount) external {
        require(_account != address(0), "AuTokenSingle: burn account is zero");
        require(msg.sender == _account || admins[msg.sender], "AuTokenSingle: You are not admin");
        uint256 accountBalance = balances[_account];
        require(accountBalance >= _amount, "AuTokenSingle: burn amount exceeds balance");
        balances[_account] = accountBalance - _amount;
        tokenTotalSupply -= _amount;
        emit Transfer(_account, address(0), _amount);
    }

    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(clients[_from],"AuTokenSingle: 'from' are not our client");
        require(clients[_to],"AuTokenSingle: 'to' not our client");
        uint256 fromBalance = balances[_from];
        require(fromBalance >= _amount, "AuTokenSingle: transfer amount exceeds balance");
        balances[_from] = fromBalance - _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }

    //some gas ethers may be need for a normal work of this contract.
    //Only owner can put ethers to contract.
    receive() external payable {
        require(msg.sender == owner, "AuTokenSingle: You are not contract owner");
    }

    //Only owner can return to himself gas ethers before closing contract
    function withDrawAll() external {
        require(msg.sender == owner, "AuTokenSingle: You are not contract owner");
        payable(owner).transfer(address(this).balance);
    }
}