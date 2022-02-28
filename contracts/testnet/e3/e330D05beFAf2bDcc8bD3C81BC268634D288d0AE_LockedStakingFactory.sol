// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/*
The MIT License (MIT)
Copyright (c) 2018 Murray Software, LLC.
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//solhint-disable max-line-length
//solhint-disable no-inline-assembly

contract CloneFactory {

  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CloneFactory.sol";
import "./Staking.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LockedStakingFactory is Ownable, CloneFactory {
    Staking[] s_stakings;
    IBEP20 s_nekoin;
    address private s_masterContract;
    uint private s_fee;

    mapping(uint => address) s_stakingToOwner;
    mapping(address => uint) private s_ownerStakingCount;

    constructor(address _masterContract, IBEP20 _nekoin, uint _fee) {
        s_masterContract = _masterContract;
        s_nekoin = _nekoin;
        s_fee = _fee;
    }

    function getFee() external view returns(uint) {
        return s_fee;
    }

    function getAllStaking() external view returns(Staking[] memory){
        return s_stakings;
    }

    function setFee(uint _newFee) external onlyOwner {
        s_fee = _newFee;
    }

    function createLockedStaking(
        IBEP20 _rewardToken,
        IBEP20 _stakingToken,
        uint _duration,
        uint _rewardPercentage,
        address _nftAddress,
        uint _minimumStaking,
        uint _maximumStaking
    ) external {
        require(s_nekoin.transferFrom(msg.sender, address(this), s_fee), "Fee is required");
        _deployLockedStaking(
            _rewardToken, 
            _stakingToken, 
            _duration, 
            _rewardPercentage, 
            _nftAddress, 
            _minimumStaking, 
            _maximumStaking
        );
    }

    function _deployLockedStaking(
        IBEP20 _rewardToken,
        IBEP20 _stakingToken,
        uint _duration,
        uint _rewardPercentage,
        address _nftAddress,
        uint _minimumStaking,
        uint _maximumStaking
    ) internal {
        Staking staking = Staking(createClone(s_masterContract));
        staking.init(
            msg.sender,
            _rewardToken,
            _stakingToken,
            _duration,
            _rewardPercentage,
            _nftAddress,
            _minimumStaking,
            _maximumStaking
        );
        s_stakings.push(staking);
        
        uint stakeIndex = s_stakings.length - 1;
        s_stakingToOwner[stakeIndex] = msg.sender;
        s_ownerStakingCount[msg.sender]++;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './token/BEP20/IBEP20.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {

    // State Variables
    IBEP20 s_rewardToken;
    IBEP20 s_stakingToken;
    address s_creator;
    uint s_duration; // in seconds
    uint s_rewardPercentage;
    address s_nftAddress;
    uint s_minimumStaking;
    uint s_maximumStaking;
    bool s_isSoldOut;

    uint s_totalSupply;
    mapping(address => uint) private s_balances;

    enum Status {
        LOCKED,
        REDEEMABLE,
        REDEEMED
    }

    struct Stake {
        uint amount;
        uint dateStaked;
        uint dateRedeemed;
        Status status;
    }

    Stake[] s_stakes;
    mapping(uint => address) s_stakeToOwner;
    mapping(address => uint) private s_ownerStakeCount;


    function init(
        address _creator,
        IBEP20 _rewardToken,
        IBEP20 _stakingToken,
        uint _duration,
        uint _rewardPercentage,
        address _nftAddress,
        uint _minimumStaking,
        uint _maximumStaking
    ) external {
        require(_duration >= 8 days, 'Duration must be greater than or equal to 8 days');
        require(_duration <= 365 days, 'Duration must be less than or equal to 365 days');
        s_creator = _creator;
        s_rewardToken = _rewardToken;
        s_stakingToken= _stakingToken;
        s_duration = _duration;
        s_rewardPercentage = _rewardPercentage;
        s_nftAddress = _nftAddress;
        s_minimumStaking = _minimumStaking;
        s_maximumStaking = _maximumStaking;
        s_isSoldOut = false;
    }
    // Views
    function balanceOf(address account) external view returns (uint256) {
        return s_balances[account];
    }

    function getStakingInfo() external view returns (
        address creator,
        IBEP20 rewardToken,
        IBEP20 stakingToken,
        uint duration,
        uint rewardPercentage,
        address nftAddress,
        uint minimumStaking,
        uint maximumStaking,
        bool isSoldOut
    ) {
        return (
            s_creator,
            s_rewardToken,
            s_stakingToken,
            s_duration,
            s_rewardPercentage,
            s_nftAddress,
            s_minimumStaking,
            s_maximumStaking,
            s_isSoldOut
        );
    }

    function stakeByOwner(address _owner) external view returns (uint[] memory) {
        uint[] memory result = new uint[](s_ownerStakeCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < s_stakes.length; i++) {
            if (s_stakeToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function stakeByIndex(uint _index) public view returns (
        uint amount,
        uint dateStaked,
        uint dateRedeemed,
        Status status
    ) 
    {
        Stake storage stake = s_stakes[_index];
        return(
            stake.amount,
            stake.dateStaked,
            stake.dateRedeemed,
            stake.status
        );
    }



    function createStake(uint256 _amount) public {
        require(s_balances[msg.sender] >= s_minimumStaking, 'Staking must be greater than or equal to minimum staking');
        require(s_balances[msg.sender] <= s_maximumStaking, 'Staking must be less than or equal to maximum staking');
        require(_amount >= s_minimumStaking, 'Amount must be greater than or equal to minimum staking');
        require(_amount <= s_maximumStaking, 'Amount must be less than or equal to maximum staking');
        s_totalSupply += _amount;
        s_balances[msg.sender] += _amount;

        Stake memory newStake;
        newStake.amount = _amount;
        newStake.dateStaked = block.timestamp;
        newStake.status = Status.LOCKED;
        s_stakes.push(newStake);
        uint stakeIndex = s_stakes.length - 1;

        s_stakeToOwner[stakeIndex] = msg.sender;
        s_ownerStakeCount[msg.sender]++;
        s_stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function _calculateReward() internal view returns (uint256 reward) {
        reward = (s_rewardPercentage / 365) / s_totalSupply;
        // s_rewardToken.transfer(msg.sender, reward);
    }

    function redeem(uint _stakeIndex) public nonReentrant {
        require(s_stakeToOwner[_stakeIndex] == msg.sender);
        Stake storage stake = s_stakes[_stakeIndex];
        require(block.timestamp >= stake.dateStaked + s_duration);
        uint amount = s_balances[msg.sender];
        s_totalSupply -= amount;
        s_balances[msg.sender] -= amount;
        s_stakingToken.transfer(msg.sender, amount);
        stake.dateRedeemed = block.timestamp;
    }

    function endStake() external nonReentrant {
        require(msg.sender == s_creator, 'Caller is not a creator');
        s_isSoldOut = true;
        uint rewardBalance = s_rewardToken.balanceOf(address(this));
        s_rewardToken.transfer(s_creator, rewardBalance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

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

    constructor () {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}