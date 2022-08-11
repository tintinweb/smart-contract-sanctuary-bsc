/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

//FilterSwap Deployer v1.0: BuySellTaxedToken Template

pragma solidity ^0.8;

contract BuySellTaxedToken {
    string public name;
    string public symbol;
    uint public totalSupply;
    uint8 public decimals;

    address private owner;
    address public tokenDeployer;
    address public pairAddress;

    uint public buyFee;
    uint public sellFee;

    bool private isInitialized;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    function initializeToken(string memory _name, string memory _symbol, address _owner, address _tokenDeployer, uint[] memory _tokenArgs) public {
        require(!isInitialized);
        require(_tokenArgs.length == 3, "FilterDeployer: INCORRECT_ARGUMENTS");
        require(_tokenArgs[1] <= 25, "FilterDeployer: BUY_FEE_TOO_HIGH");
        require(_tokenArgs[2] <= 25, "FilterDeployer: SELL_FEE_TOO_HIGH");

        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _tokenArgs[0] * (10 ** decimals);

        owner = _owner;
        tokenDeployer = _tokenDeployer;

        buyFee = _tokenArgs[1];
        sellFee = _tokenArgs[2];

        balanceOf[_tokenDeployer] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        if (!isInitialized) {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;

            emit Transfer(msg.sender, _to, _value);
            return true;
        }

        // user buys tokens, apply buy fee
        if (msg.sender == pairAddress) {
            require(balanceOf[msg.sender] >= _value);
            balanceOf[msg.sender] -= _value;

            uint taxedValue = (_value * (100 - buyFee)) / 100;
            uint totalFee = (_value * buyFee) / 100;

            balanceOf[_to] += taxedValue;
            balanceOf[address(0)] += totalFee;

            emit Transfer(msg.sender, _to, taxedValue);
            emit Transfer(msg.sender, address(0), totalFee);
        }

        //user sells tokens, apply sell fee
        else if (_to == pairAddress) {
            require(balanceOf[msg.sender] >= _value);
            balanceOf[msg.sender] -= _value;

            uint taxedValue = (_value * (100 - sellFee)) / 100;
            uint totalFee = (_value * sellFee) / 100;

            balanceOf[_to] += taxedValue;
            balanceOf[address(0)] += totalFee;

            emit Transfer(msg.sender, _to, taxedValue);
            emit Transfer(msg.sender, address(0), totalFee);
        }

        //regular transfer, don't apply fee
        else {
            require(balanceOf[msg.sender] >= _value);
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;

            emit Transfer(msg.sender, _to, _value);
        }

        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function initializePair(address _pairAddress) public {
        require(!isInitialized);
        pairAddress = _pairAddress;
        isInitialized = true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (!isInitialized) {
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;

            emit Transfer(_from, _to, _value);
            return true;           
        }

        //user buys tokens, apply buy fee
        if (msg.sender == pairAddress) {
            require(_value <= balanceOf[_from]);
            require(_value <= allowance[_from][msg.sender]);

            uint taxedValue = (_value * (100 - buyFee)) / 100;
            uint totalFee = (_value * buyFee) / 100;

            balanceOf[_from] -= _value;
            balanceOf[_to] += taxedValue;
            balanceOf[address(0)] += totalFee;
            allowance[_from][msg.sender] -= _value;

            emit Transfer(_from, _to, taxedValue);
            emit Transfer(msg.sender, address(0), totalFee);
        }

        //user sells tokens, apply sell fee
        else if (_to == pairAddress) {
            require(_value <= balanceOf[_from]);
            require(_value <= allowance[_from][msg.sender]);

            uint taxedValue = (_value * (100 - sellFee)) / 100;
            uint totalFee = (_value * sellFee) / 100;

            balanceOf[_from] -= _value;
            balanceOf[_to] += taxedValue;
            balanceOf[address(0)] += totalFee;
            allowance[_from][msg.sender] -= _value;

            emit Transfer(_from, _to, taxedValue);
            emit Transfer(msg.sender, address(0), totalFee);
        }

        //regular transfer, don't apply fee
        else {
            require(_value <= balanceOf[_from]);
            require(_value <= allowance[_from][msg.sender]);

            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            allowance[_from][msg.sender] -= _value;

            emit Transfer(_from, _to, _value);
        }

        return true;
    }

    // **** ADMIN FUNCTIONS ****

    function changeBuyFee(uint _buyFee) public {
        require(msg.sender == owner, "FilterToken: FORBIDDEN");
        require(buyFee <= 25, "FilterToken: BUY_FEE_TOO_HIGH");
        buyFee = _buyFee;
    }

    function changeSellFee(uint _sellFee) public {
        require(msg.sender == owner, "FilterToken: FORBIDDEN");
        require(sellFee <= 25, "FilterToken: SELL_FEE_TOO_HIGH");
        sellFee = _sellFee;
    }

    function transferOwnership(address _owner) public {
        require(msg.sender == owner); 
        owner = _owner;
    }
}