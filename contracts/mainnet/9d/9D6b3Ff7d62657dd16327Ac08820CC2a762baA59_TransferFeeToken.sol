/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

//FilterSwap (V1): filterswap.exchange

pragma solidity ^0.8;

contract TransferFeeToken {
    uint public constant templateType = 1;
    uint public constant maxTransferFee = 2500;

    string public name;
    string public symbol;
    uint8 public decimals;
    address private owner;

    uint public totalSupply;
    uint public transferFee;

    bool private isInitialized;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    function initializeToken(string memory _name, string memory _symbol, address _owner, address _tokenDeployer, bytes32[] memory _tokenArgs) external {
        require(!isInitialized);
        require(_tokenArgs.length == 2, "FilterToken: INCORRECT_ARGUMENTS");

        transferFee = uint(bytes32(_tokenArgs[1]));
        require(transferFee <= maxTransferFee, "FilterToken: TRANSFER_FEE_TOO_HIGH");

        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = uint(bytes32(_tokenArgs[0])) * (10 ** decimals);

        owner = _owner;

        balanceOf[_tokenDeployer] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        isInitialized = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;

        uint valueWithFee = (_value * (10000 - transferFee)) / 10000;
        uint totalFee = (_value * transferFee) / 10000;

        balanceOf[_to] += valueWithFee;
        balanceOf[address(0)] += totalFee;

        emit Transfer(msg.sender, _to, valueWithFee);
        emit Transfer(msg.sender, address(0), totalFee);
        return true;
    }

    function approve(address _spender, uint _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        uint valueWithFee = (_value * (10000 - transferFee)) / 10000;
        uint totalFee = (_value * transferFee) / 10000;

        balanceOf[_from] -= _value;
        balanceOf[_to] += valueWithFee;
        balanceOf[address(0)] += totalFee;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, valueWithFee);
        emit Transfer(msg.sender, address(0), totalFee);
        return true;
    }

    function transferOwnership(address _owner) public {
        require(msg.sender == owner, "FilterToken: FORBIDDEN");
        owner = _owner;
    }

    function setTransferFee(uint _transferFee) public {
        require(msg.sender == owner, "FilterToken: FORBIDDEN");
        require(_transferFee <= maxTransferFee, "FilterToken: TRANSFER_FEE_TOO_HIGH");
        transferFee = _transferFee;
    }
}