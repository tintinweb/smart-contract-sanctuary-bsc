/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: None
// File: ReentrancyGuard.sol



pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: PeccalaUser.sol




pragma solidity 0.8.4;

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

contract UserFactory is Ownable, ReentrancyGuard {
    mapping(bytes32=>address) private userById;
    mapping(address=>bytes32) private userByAddress;

    event UserCreated(address user, bytes32 userId);
    event UserUpdated(address user, bytes32 userId);

    function createUser(bytes32 userId) external onlyOwner nonReentrant returns(address) {
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

    function updateUser(address user, bytes32 userId) external onlyOwner nonReentrant returns(bool) {
        require(user != address(0));
        require(userById[userId] == address(0), "userId already exists");
        require(userByAddress[user][0] != 0, "address doesn't exists");
        userById[userId] = user;
        userByAddress[user] = userId;
        emit UserUpdated(user, userId);
        return true;
    }
}