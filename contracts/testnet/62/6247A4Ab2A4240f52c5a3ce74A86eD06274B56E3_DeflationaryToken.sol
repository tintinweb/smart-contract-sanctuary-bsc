/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

//FilterSwap Deployer v1.0: DeflationaryToken Template

pragma solidity ^0.8;

contract DeflationaryToken {
    string public name;
    string public symbol;
    uint public totalSupply;
    uint8 public decimals = 18;

    address private owner;
    address public tokenDeployer;

    address public pairAddress;

    uint public burnFee;

    bool public isInitialized;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    function initializeToken(string memory _name, string memory _symbol, address _owner, address _tokenDeployer, uint[] memory _tokenArgs) public {
        require(!isInitialized);
        require(_tokenArgs.length == 2, "FilterDeployer: INCORRECT_ARGUMENTS");
        require(_tokenArgs[1] <= 20, "FilterDeployer: BURN_FEE_TOO_HIGH");

        name = _name;
        symbol = _symbol;
        totalSupply = _tokenArgs[0] * (10 ** decimals);

        owner = _owner;
        tokenDeployer = _tokenDeployer;

        burnFee = _tokenArgs[1];

        balanceOf[_tokenDeployer] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        if (!isInitialized) { //allows for tokens to be transferred to pair initially without approval (one-time)
            balanceOf[msg.sender] = 0;
            balanceOf[_to] = _value;

            emit Transfer(msg.sender, _to, _value);
            return true;           
        }
        
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;

        uint taxedValue = (_value * (100 - burnFee)) / 100;
        uint totalFee = (_value * burnFee) / 100;

        balanceOf[_to] += taxedValue;
        balanceOf[address(0)] += totalFee;

        emit Transfer(msg.sender, _to, taxedValue);
        emit Transfer(msg.sender, address(0), totalFee);
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
        if (!isInitialized) { //allows for tokens to be transferred to pair initially without approval (one-time)
            balanceOf[_from] = 0;
            balanceOf[_to] = _value;

            emit Transfer(_from, _to, _value);
            return true;           
        }

        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        uint taxedValue = (_value * (100 - burnFee)) / 100;
        uint totalFee = (_value * burnFee) / 100;

        balanceOf[_from] -= _value;
        balanceOf[_to] += taxedValue;
        balanceOf[address(0)] += totalFee;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, taxedValue);
        emit Transfer(msg.sender, address(0), totalFee);
        return true;
    }
}