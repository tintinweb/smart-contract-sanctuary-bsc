/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

//FilterSwap Deployer v1.0: BasicToken Template

pragma solidity ^0.8;

contract BasicToken {
    string public name;
    string public symbol;
    uint public totalSupply;
    uint8 public decimals = 18;

    address public owner;
    address public tokenDeployer;

    address public pairAddress;

    bool public isInitialized;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    function initializeToken(string memory _name, string memory _symbol, address _owner, address _tokenDeployer, uint[] memory _tokenArgs) public {
        require(!isInitialized);

        require(_tokenArgs.length == 1, "FilterDeployer: INCORRECT_ARGUMENTS");

        name = _name;
        symbol = _symbol;
        totalSupply = _tokenArgs[0] * (10 ** decimals);

        owner = _owner;
        tokenDeployer = _tokenDeployer;

        balanceOf[_tokenDeployer] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
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
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}