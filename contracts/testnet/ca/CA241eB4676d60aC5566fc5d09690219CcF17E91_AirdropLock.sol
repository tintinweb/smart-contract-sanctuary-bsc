// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AirdropLock is Ownable {
    struct AirdropUser {
        uint256 lockedAmount;
        uint256 claimedOut;
    }
    struct Stage {
        uint256 startTime;
        uint256 endTime;
        uint256 rewardAmount; // 阶段可领取数量
        uint256 rewardOut; //本阶段已支出数量
    }
    Stage[] public stages;
    uint public stageIndex;

    constructor(address _tokenAddress) {
        stages.push(Stage(0, 0, 10_0000 ether, 0));
        stages.push(Stage(0, 0, 10_0000 ether, 0));
        stages.push(Stage(0, 0, 10_0000 ether, 0));
        stages.push(Stage(0, 0, 10_0000 ether, 0));
        stages.push(Stage(0, 0, 10_0000 ether, 0));
        setAirdropTokenAddress(_tokenAddress);
    }

    mapping(address => AirdropUser) public airdropUsers;
    address public airdropTokenAddress;

    receive() external payable {
        claimAirdropLock();
    }

    function setAirdropTokenAddress(address addr) public onlyOwner {
        airdropTokenAddress = addr;
    }

    function claimAirdropLock() public {
        address userAddress = msg.sender;
        // //限制一个地址只能领取一次
        // if (airdropUsers[userAddress].lockedAmount > 0) {
        //     revert("you have claimed");
        // }
        //五个阶段
        if (stages[0].rewardOut < 10_0000 ether) {
            airdropUsers[userAddress].lockedAmount += 100 ether;
            stages[0].rewardOut += 100 ether;
            stageIndex = 1;
        }else if(stages[1].rewardOut < 10_0000 ether) {
            airdropUsers[userAddress].lockedAmount += 80 ether;
            stages[1].rewardOut += 80 ether;
            stageIndex = 2;
        }else if(stages[2].rewardOut < 10_0000 ether) {
            airdropUsers[userAddress].lockedAmount += 50 ether;
            stages[2].rewardOut += 50 ether;
            stageIndex = 3;
        }else if(stages[3].rewardOut < 10_0000 ether) {
            airdropUsers[userAddress].lockedAmount += 20 ether;
            stages[3].rewardOut += 20 ether;
            stageIndex = 4;
        }else if(stages[4].rewardOut < 10_0000 ether) {
            airdropUsers[userAddress].lockedAmount += 10 ether;
            stages[4].rewardOut += 10 ether;
            stageIndex =5;
        }else{
            revert("no more airdrop");
        }
    }

    function claimReward(uint256 amount) public returns(bool){
        address user = msg.sender;
        require(airdropTokenAddress != address(0));
        require(airdropUsers[user].lockedAmount > 0);
        require(amount <= airdropUsers[user].lockedAmount);
        require(airdropUsers[user].claimedOut + amount <= airdropUsers[user].lockedAmount);

        airdropUsers[msg.sender].lockedAmount -= amount;
        airdropUsers[msg.sender].claimedOut += amount;

        IERC20(airdropTokenAddress).transfer(
            user,
            amount
        );
        return true;
    }
    function getStageInfo(uint stageId) public view returns(uint256, uint256, uint256, uint256) {
        return (
            stages[stageId].startTime,
            stages[stageId].endTime,
            stages[stageId].rewardAmount,
            stages[stageId].rewardOut
        );
    }
    //返回当前阶段的剩余
    function getStageRemain() public view returns(uint256) {
        return stages[stageIndex-1].rewardAmount - stages[stageIndex-1].rewardOut;
    }

    function getCurLockedAmount(address addr) public view returns(uint256){
        return airdropUsers[addr].lockedAmount;
    }
    function getCurClaimedOut(address addr) public view returns(uint256){
        return airdropUsers[addr].claimedOut;
    }
    function withdraw(address payable addr) public onlyOwner {
        addr.transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}