/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

contract SendAsset {

    function tokenSafeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function tokenSafeTransfer(
        IBEP20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

}

contract TokenLocker is Ownable,SendAsset {

    bool public lockStatus;

    struct UserDetails {
        IBEP20 token;
        bool vesting;
        uint256 lockedAmount;
        uint256 depositTime;
        uint256 duration;
        bool claimed;
        uint256 claimAmount;
        uint256 initialClaimDuration;
        uint256 initialPercent;
        uint256 nextClaimDuration;
        uint256 nextClaimPercent;
    }

    mapping (uint8 => mapping (address => UserDetails)) public users;
    mapping (address => uint8) public userCount;

    event AddLock (address indexed user,uint8 _id,bool Vesting,uint256 lockAmount,uint256 timestamp);
    event Withdraw (address indexed user, uint8 id,uint256 amount,uint256 time);
    event Vest (address indexed user,uint8 id,uint256 reward,uint256 time);

    modifier isLock() {
        require(lockStatus == false, "NftStake: Contract Locked");
        _;
    }

    function addLock (UserDetails memory user) external isLock {
         require(!user.claimed,'Initially it should be false');
         require(address(user.token) != address(0),'invalid token address');

         address userAddr = _msgSender();
         uint8 _id = userCount[userAddr]++;

         tokenSafeTransferFrom(user.token,userAddr,address(this),user.lockedAmount);
        
         if (user.vesting) updateVestDetails(_id, userAddr,user);
         else updateTokenDetails(_id, userAddr,user);

         emit AddLock(userAddr,_id, user.vesting, user.lockedAmount, block.timestamp);
    }

    function updateVestDetails (uint8 _id,address _user,UserDetails memory _users) internal {
         UserDetails storage user = users[_id][_user];
         user.vesting = _users.vesting;
         user.lockedAmount = _users.lockedAmount;
         user.token = _users.token;
         user.initialClaimDuration = _users.initialClaimDuration;
         user.initialPercent = _users.initialPercent;
         user.nextClaimDuration = _users.nextClaimDuration;
         user.nextClaimPercent = _users.nextClaimPercent;
         user.depositTime = block.timestamp;
    }

    function updateTokenDetails (uint8 _id,address _user,UserDetails memory _users) internal {
         UserDetails storage user = users[_id][_user];
         user.lockedAmount = _users.lockedAmount;
         user.token = _users.token;
         user.duration = _users.duration;
         user.depositTime = block.timestamp;
    }

    function withdraw (uint8 _id) external isLock {
         UserDetails storage user = users[_id][_msgSender()];
         require(user.lockedAmount > 0 && !user.claimed,'invalid user');
         require(block.timestamp > user.depositTime + user.duration,'Time not reach');
         require(!user.vesting,'Not for vest');
         uint256 amount = user.lockedAmount;
         user.lockedAmount = 0;
         user.claimed = true;
         tokenSafeTransfer(user.token, _msgSender(), amount);

         emit Withdraw(_msgSender(),_id,amount,block.timestamp);
    }

    function claimVest (uint8 _id) external isLock {
          address userAddr = _msgSender();
          UserDetails storage user = users[_id][userAddr];
          require(!user.claimed,'User claimed');
          uint256 reward = this.vestCalc(_id,userAddr);
          require(reward > 0,'No reward');
          user.claimAmount += reward;
          tokenSafeTransfer(user.token, userAddr, reward);

          if (user.claimAmount >= user.lockedAmount) user.claimed = true;

          emit Vest (_msgSender(),_id,reward,block.timestamp);
    }

    function vestCalc (uint8 _id,address _user) external view returns (uint256 reward) {
         UserDetails storage user = users[_id][_user];
         require(user.lockedAmount > 0 && user.vesting,'Invalid call');
         uint256 amount = user.lockedAmount;

         if (block.timestamp < user.initialClaimDuration) return 0;
         else reward += amount*user.initialPercent/100e18;

         if (block.timestamp >  user.initialClaimDuration + user.nextClaimDuration) {
             uint256 calc = (block.timestamp - user.initialClaimDuration) / user.nextClaimDuration;
             reward += (amount*user.nextClaimPercent/100e18) * calc;
             reward -=  user.claimAmount;
              
              if (reward + user.claimAmount > amount) reward = amount - user.claimAmount;
         }
    }

    function emergencyWithdraw (IBEP20 _token,address _to,uint256 _amount) external onlyOwner {
         tokenSafeTransfer(_token, _to, _amount);
    }

    function enableLock(bool _Status) external onlyOwner {
         lockStatus = _Status;
    }
}