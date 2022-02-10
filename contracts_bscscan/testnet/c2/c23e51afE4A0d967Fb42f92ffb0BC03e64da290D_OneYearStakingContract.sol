/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;









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
        return msg.data;
    }
}


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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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


contract OneYearStakingContract is Ownable, ReentrancyGuard {

    struct Stake {
        address user;
        uint amount;
        uint untilBlock;
        uint unclaimed;
    }

    Stake[] public stakes;
    mapping(address => uint[]) private ownerStakIds;

    uint public totalSupply;
    bool public stakingAllowed;
    uint public lastUpdate;

    uint public constant MAX_SUPPLY = 80 * 1e6 * 1e18;
    uint public constant MINIMUM_AMOUNT = 500 * 1e18;
    uint public constant REWARD_PER_BLOCK = 0.6808 * 1e18;

    // address public constant STAKING_TOKEN_ADDRESS = 0x1d0Ac23F03870f768ca005c84cBb6FB82aa884fD; // galeon address
    address public constant STAKING_TOKEN_ADDRESS = 0xDecB06cCa15031927Adb8B2e8773145646CFB564; // testnet address
    IERC20 private constant STAKING_TOKEN = IERC20(STAKING_TOKEN_ADDRESS);
    
    constructor() {
        lastUpdate = block.timestamp;
        totalSupply = 0;
        stakingAllowed = true;
    }

    event Stacked(uint _amount,uint _totalSupply);
    event Unstaked(uint _amount);
    event Claimed(uint _claimed);
    event Allowed(bool _allow);
    event Updated(uint _lastupdate);

    function allowStaking(bool _allow) external onlyOwner returns (bool allowed) {
        return stakingAllowed = _allow;
    }
    function forceUpdatePool() external updatePool nonReentrant returns (bool updated) {
        return true;
    }

    function stake(uint _amount) external updatePool nonReentrant returns (bool staked) {
        require(stakingAllowed, "Staking is not enabled");
        require(_amount >= MINIMUM_AMOUNT, "Insuficient amount");
        require(totalSupply + _amount <= MAX_SUPPLY, "Pool capacity exceeded");
        require(_amount < STAKING_TOKEN.balanceOf(msg.sender), "Insuficient balance");
        require(STAKING_TOKEN.transferFrom(msg.sender, address(this), _amount), "TransferFrom failed");
        stakes.push(Stake(msg.sender, _amount, block.timestamp + 10 minutes,0));
        ownerStakIds[msg.sender].push(stakes.length-1);
        totalSupply += _amount;
        emit Stacked(_amount,totalSupply);
        return true;
    }

    function claim() external updatePool nonReentrant returns(uint amount) {
        uint claimed = 0;
        uint j;
        for(uint i = 0; i < ownerStakIds[msg.sender].length; i++) {
            j = ownerStakIds[msg.sender][i];
            if (stakes[j].unclaimed > 0) {
                require(STAKING_TOKEN.balanceOf(address(this)) > stakes[j].unclaimed, "Insuficient contract balance");
                require(STAKING_TOKEN.transfer(msg.sender,stakes[j].unclaimed), "Transfer failed");
            }
            claimed += stakes[j].unclaimed;
            stakes[j].unclaimed = 0;
        }
        emit Claimed(claimed);
        return claimed;
    }

    function unstake() external updatePool nonReentrant returns(uint unstaked) {
        uint amount = 0;
        uint i = 0;
        uint stakeId;
        while(i < ownerStakIds[msg.sender].length) {
            stakeId = ownerStakIds[msg.sender][i];
            if (stakes[stakeId].untilBlock < block.timestamp) {
                amount = stakes[stakeId].amount + stakes[i].unclaimed;
                require(STAKING_TOKEN.balanceOf(address(this)) > amount, "Insuficient contract balance");
                require(STAKING_TOKEN.transfer(msg.sender,amount), "Transfer failed");
                stakes[stakeId] = stakes[stakes.length -1];
                for(uint k = 0; k < ownerStakIds[stakes[stakeId].user].length; k++) {
                    if (ownerStakIds[stakes[stakeId].user][k] == stakes.length -1) {
                        ownerStakIds[stakes[stakeId].user][k] = stakeId;
                    }
                }
                stakes.pop();
                ownerStakIds[msg.sender][i] = ownerStakIds[msg.sender][ownerStakIds[msg.sender].length -1];
                ownerStakIds[msg.sender].pop();
            } else {
                i++;
            }
        }
        require(amount > 0, "Nothing to unstake");
        emit Unstaked(amount);
        return amount;
    }

    function getUserStaksIds(address _user) external view returns (uint[] memory) {
        uint j = 0;
        for(uint i = 0; i < stakes.length; i++) {
            if (stakes[i].user == _user) {
                j++;
            }
        }
        uint[] memory ids = new uint[](j);
        j = 0;
        for(uint i = 0; i < stakes.length; i++) {
            if (stakes[i].user == _user) {
                ids[j] = i;
                j++;
            }
        }
        return ids;
    }

    modifier updatePool() {
        for(uint i = 0; i < stakes.length; i++) {
            if(stakes[i].untilBlock >= block.timestamp) {
                stakes[i].unclaimed += stakes[i].amount * (block.timestamp - lastUpdate) * REWARD_PER_BLOCK / totalSupply;
            } else if (lastUpdate < stakes[i].untilBlock) {
                stakes[i].unclaimed += stakes[i].amount * (stakes[i].untilBlock - lastUpdate) * REWARD_PER_BLOCK / totalSupply;
            }
        }
        lastUpdate = block.timestamp;
        emit Updated(lastUpdate);
        _;
    }
}