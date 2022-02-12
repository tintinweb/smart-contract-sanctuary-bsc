/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: None
pragma solidity 0.7.6;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract User {
    address private _factory;
    modifier onlyOwner(){
        require(msg.sender == UserFactory(_factory).owner(), "not authorized");
        _;
    }
    constructor () {
        _factory = msg.sender;
    }
    function approve(address token, address spender, uint256 value) external onlyOwner returns(bool) {
        require(token != address(0));
        require(spender != address(0));
        return IERC20(token).approve(spender, value);
    }
    function transfer(address token, address to, uint256 value) external onlyOwner returns(bool) {
        require(token != address(0));
        return IERC20(token).transfer(to, value);
    }
    function getFactory() external view returns (address) {
        return _factory;
    }
}

contract UserFactory is Ownable {
    mapping(bytes32=>address) private userById;
    mapping(address=>bytes32) private userByAddress;

    event UserCreated(address user, bytes32 userId);
    event UserUpdated(address user, bytes32 userId);

    function createUser(bytes32 userId) external onlyOwner returns(address) {
        require(userId[0] != 0);
        User data = new User();
        userById[userId] = address(data);
        userByAddress[address(data)] = userId;
        return address(data);
    }

    function getUser(bytes32 userId) external view returns(address) {
        return userById[userId];
    }

    function getUserId(address user) external view returns(bytes32) {
        return userByAddress[user];
    }

    function updateUser(address user, bytes32 userId) external onlyOwner returns(bool) {
        require(user != address(0));
        require(userById[userId] == address(0), "userId already exists");
        require(userByAddress[user][0] != 0, "address doesn't exists");
        userById[userId] = user;
        userByAddress[user] = userId;
        emit UserUpdated(user, userId);
        return true;
    }
}