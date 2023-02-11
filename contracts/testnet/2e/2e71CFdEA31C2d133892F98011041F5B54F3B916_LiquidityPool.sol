/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

contract Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() public {
        name = "MyToken2";
        symbol = "MTK2";
        decimals = 18;
        uint256 _initialSupply = 1000000000;
        owner = address(msg.sender);
        balanceOf[owner] = _initialSupply;
        totalSupply = _initialSupply;
        emit Transfer(address(0), owner, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(balanceOf[msg.sender] > _value, "Not enough balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(
            balanceOf[_from] >= _value,
            "Not enough balance in from address"
        );
        require(allowance[_from][msg.sender] >= _value, "Not enough allowance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true;
    }

    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    function burn(uint256 _amount) public returns (bool success) {
        require(msg.sender == address(0), "Invalid burn recipient");
        require(_amount > 0, "Amount to burn must be grater than 0");
        uint256 senderBalance = balanceOf[msg.sender];
        require(senderBalance >= _amount, "Burn amount exceeds balance");

        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;

        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }
}

contract LiquidityPool {
    Token public token;
    mapping(address => uint256) public balanceOfByAddress;

    constructor(address _tokenAddress) public {
        token = Token(_tokenAddress);
    }

    function addLiquidity(uint256 _amount) public returns (bool) {
        require(_amount > 0, "The amount must be greater than zero");
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient funds");
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        balanceOfByAddress[msg.sender] += _amount;
        return true;
    }

    function removeLiquidity(uint256 _amount) public returns (bool) {
        require(_amount > 0, "The amount must be greater than zero");
        require(
            balanceOfByAddress[msg.sender] >= _amount,
            "Insufficient funds"
        );
        require(
            token.transferFrom(address(this), msg.sender, _amount),
            "Transfer failed"
        );
        balanceOfByAddress[msg.sender] -= _amount;
        return true;
    }
}

contract TokenExchange {
    Token public token;
    LiquidityPool public pool;
    mapping(address => uint256) public balanceOf;

    event Burn(address indexed burner, uint256 burnedAmount);
    event AddLiquidity(address indexed sender, uint256 addedAmount);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _tokenAddress, address _poolAddress) public {
        require(_tokenAddress != address(0), "Invalid token contract address");
        require(_poolAddress != address(0), "Invalid pool contract address");
        token = Token(_tokenAddress);
        pool = LiquidityPool(_poolAddress);
    }

    function exchange(address _to, uint256 _value) public {
        require(_to != address(0), "Invalid recipient address");
        require(_value > 0, "Value must be greater than 0");
        require(balanceOf[msg.sender] >= _value, "Insufficient funds");
        uint256 burnedAmount = (_value * 25) / 1000;
        uint256 addedToPoolAmount = _value - burnedAmount;
        // Check if the transfer of burned amount from the sender to itself succeeds before proceeding
        bool transferSuccess = token.transferFrom(
            msg.sender,
            msg.sender,
            burnedAmount
        );
        require(transferSuccess, "Failed to transfer tokens");
        // Check if adding liquidity to the pool succeeds before proceeding
        bool addSuccess = pool.addLiquidity(addedToPoolAmount);
        require(addSuccess, "Failed to add liquidity to pool");
        // Check if the transfer of remaining amount from the sender to the recipient succeeds
        transferSuccess = token.transferFrom(
            msg.sender,
            _to,
            _value - burnedAmount
        );
        require(transferSuccess, "Failed to transfer tokens");
        emit Burn(msg.sender, burnedAmount);
        emit AddLiquidity(msg.sender, burnedAmount);
        emit Transfer(msg.sender, _to, _value - burnedAmount);
    }
}