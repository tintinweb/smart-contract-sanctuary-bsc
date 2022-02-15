// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract Test is Context, Ownable{

    mapping(address => bool) public whitelist;
    address[] public users;
    mapping(address => string) public descriptions;

    constructor(){}

    function setWhiteList(address account) external onlyOwner{
        require(account != address(0), 'address can not be zero');
        if(whitelist[account] == false)
            users.push(account);
        whitelist[account] = true;
    }

    function getWhiteListUsers() external view onlyOwner returns (address[] memory){
        return users;
    }

    function setDescriptions(string memory _description) public{
        require(whitelist[msg.sender], 'Not whitelisted account');
        descriptions[msg.sender] = _description;
    }
}