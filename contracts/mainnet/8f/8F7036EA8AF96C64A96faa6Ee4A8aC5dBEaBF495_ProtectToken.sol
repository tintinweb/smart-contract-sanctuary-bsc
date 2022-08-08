/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
contract Clones {

    /**
        @dev Deploys and returns the address of a clone of address(this
        Created by DeFi Mark To Allow Clone Contract To Easily Create Clones Of Itself
        Without redundancy
     */
    function clone() external returns(address) {
        return _clone(address(this));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function _clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
}

contract ProtectTokenData {

    // Token Being Protected
    address public token;

    // Token Stats
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    // total supply
    uint256 internal _totalSupply;

    struct LockInfo {
        uint256 numTokens;
        address unlocker;
        bytes32 password;
        address locker;
        uint256 index;
        bool hasUnlockerUnlocked;
    }
    mapping ( uint256 => LockInfo ) public lockInfo;
    uint256 public currentLockID;

    struct UserInfo {
        uint256 balance;
        uint256[] lockIds;
    }
    mapping ( address => UserInfo ) public userInfo;
}

contract ProtectToken is ProtectTokenData, Clones, IERC20 {

    function __init__(
        address _token
    ) external {
        require(
            token == address(0) && _token != address(0),
            'Already Initialized'
        );

        token = _token;
        _name = string.concat('Protected ', IERC20(_token).name());
        _symbol = string.concat('P', IERC20(_token).symbol());
        _decimals = IERC20(_token).decimals();
        emit Transfer(address(0), address(0), 0);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    
    function symbol() external view returns(string memory) {
        return _symbol;
    }
    
    function name() external view returns(string memory) {
        return _name;
    }

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256) {
        return userInfo[account].balance;
    }
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address, uint256) external returns (bool) {
        emit Transfer(address(0), address(0), 0);
        return false;
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address, address) external pure returns (uint256) {
        return 0;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address, uint256) external returns (bool) {
        emit Approval(address(0), address(0), 0);
        return false;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address, address, uint256) external returns (bool) {
        emit Transfer(address(0), address(0), 0);
        return false;
    }


    function lock(uint256 amount, address unlockAddress, bytes32 hashedPassword) external {
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            msg.sender != unlockAddress,
            'Cannot Lock For Yourself'
        );

        // transfer in tokens
        uint256 received = _transferIn(amount);

        // set lock data
        lockInfo[currentLockID] = LockInfo({
            numTokens: received,
            unlocker: unlockAddress,
            password: hashedPassword,
            locker: msg.sender,
            index: userInfo[msg.sender].lockIds.length,
            hasUnlockerUnlocked: false
        });

        // add lock to user list
        userInfo[msg.sender].lockIds.push(currentLockID);

        // mint locked tokens to sender
        _mint(msg.sender, received);

        // increment lock ID
        currentLockID++;
    }

    function unlock(uint256 lockId) external {
        require(
            lockInfo[lockId].unlocker == msg.sender,
            'Not Unlocker'
        );
        lockInfo[lockId].hasUnlockerUnlocked = true;
    }

    function unlockWithPassword(uint256 lockId, string calldata password, address recipient) external {
        require(
            lockInfo[lockId].unlocker == msg.sender,
            'Not Unlocker'
        );
        if (lockInfo[lockId].password != bytes32(0)) {
            require(
                lockInfo[lockId].password == hashString(password),
                'Password Mismatch'
            );
        }

        // tokens to get back
        uint256 tokensToUnlock = lockInfo[lockId].numTokens;
        address locker = lockInfo[lockId].locker;

        // remove from user array
        _removeLockFromUser(locker, lockInfo[lockId].index);

        // reset lock info
        delete lockInfo[lockId];

        // burn tokens
        _burn(locker, tokensToUnlock);

        // send tokens to recipient
        _send(recipient, tokensToUnlock);
    }

    function free(uint256 lockId, string calldata password, address recipient) external {
        require(
            lockInfo[lockId].locker == msg.sender,
            'Only Locker'
        );
        require(
            lockInfo[lockId].hasUnlockerUnlocked,
            'Unlocker Must Unlock'
        );
        if (lockInfo[lockId].password != bytes32(0)) {
            require(
                lockInfo[lockId].password == hashString(password),
                'Password Mismatch'
            );
        }

        // tokens to get back
        uint256 tokensToUnlock = lockInfo[lockId].numTokens;

        // remove from user array
        _removeLockFromUser(msg.sender, lockInfo[lockId].index);

        // reset lock info
        delete lockInfo[lockId];

        // burn tokens
        _burn(msg.sender, tokensToUnlock);

        // send tokens to recipient
        _send(recipient, tokensToUnlock);
    }

    function _send(address to, uint256 amount) internal {
        require(
            IERC20(token).transfer(
                to,
                amount
            ),
            'Failure Token Transfer'
        );
    }

    function _removeLockFromUser(address user, uint256 index) internal {

        // update the index of the last element of the array to the removal index
        lockInfo[
            userInfo[user].lockIds[userInfo[user].lockIds.length - 1]
        ].index = index;

        // set the last element of the array to the index to be removed
        userInfo[user].lockIds[
            index
        ] = userInfo[user].lockIds[userInfo[user].lockIds.length - 1];

        // pop the last element of the array off the list
        userInfo[user].lockIds.pop();
    }

    function _transferIn(uint256 amount) internal returns (uint256) {
        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        require(
            IERC20(token).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'Failure On Transfer From'
        );
        uint256 balanceAfter = IERC20(token).balanceOf(address(this));
        require(
            balanceAfter > balanceBefore,
            'Zero Received'
        );
        return balanceAfter - balanceBefore;
    }

    function _mint(address to, uint256 amount) internal {
        userInfo[to].balance += amount;
        _totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        userInfo[from].balance -= amount;
        _totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function viewAllLockIDs(address user) external view returns (uint256[] memory) {
        return userInfo[user].lockIds;
    }

    function hashString(string calldata str) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(str));
    }
}