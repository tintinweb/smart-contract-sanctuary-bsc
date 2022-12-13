/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// File: StakeV2_flat.sol


// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: StakeV2.sol


pragma solidity ^0.8.0;




// import "hardhat/console.sol";

interface mintToken {
    function mint(address _to, uint256 _amount) external returns (bool);
}

contract StakingV2 is Ownable, ReentrancyGuard {
    //test
    address public sgtAddress =
        address(0xd7c8c78245C0b5fEde797f899C77CD6A18d4dd40); //busd 0xD6055D2543BB3A5e60ca7b40c7c369B55e337098
    address public eneAddress =
        address(0x4a71a0DE094b2afbFe88FdB6b2a3825B25B2dbCC);
    address public lpAddress =
        address(0xd7c8c78245C0b5fEde797f899C77CD6A18d4dd40);
    //test net
    // address private constant uniswapRouterAddress = address(0x07d090e7FcBC6AFaA507A3441C7c5eE507C457e6);
    //main net

    struct plan {
        bool isOpen;
        uint256 rate;
        uint256 rateBase;
        uint256 lockDays;
        address tokenAddress; //reward
    }
    mapping(uint256 => plan) plans;
    struct order {
        bool isExist;
        uint256 lpNumber;
        uint256 buyTime;
        uint256 endTime;
        uint256 unlockTime;
        uint256 received;
        uint256 reward;
        uint256 rate;
        uint256 rateBase;
        address tokenAddress; //reward
    }
    mapping(address => mapping(uint256 => mapping(uint256 => order))) userOrders;
    mapping(address => mapping(uint256 => uint256)) public orderIds;

    struct userInfo {
        uint256 lp;
        uint256 receivedSgt;
        uint256 receivedEne;
    }

    mapping(address => userInfo) public userInfos;
    uint256 public totalLp = 0;

    constructor() {
        plans[1] = plan(true, 15, 100, 100, sgtAddress);
        plans[2] = plan(true, 36, 100, 200, sgtAddress);
        plans[3] = plan(true, 60, 100, 300, sgtAddress);

        plans[4] = plan(true, 150, 100, 100, eneAddress);
    }

    function setPlan(
        uint256 id,
        bool _isOpen,
        uint256 _rate,
        uint256 _rateBase,
        uint256 _lockDays,
        address _tokenAddress
    ) external onlyOwner {
        plans[id] = plan(_isOpen, _rate, _rateBase, _lockDays, _tokenAddress);
    }

    function setSgtAddress(address _sgtAddress) external onlyOwner {
        sgtAddress = _sgtAddress;
    }

    function setEneAddress(address _eneAddress) external onlyOwner {
        eneAddress = _eneAddress;
    }

    function setLpAddress(address _lpAddress) external onlyOwner {
        lpAddress = _lpAddress;
    }

    function getPlan(uint256 id) public view returns (plan memory) {
        return plans[id];
    }

    function getOrder(
        address userAddress,
        uint256 planId,
        uint256 id
    ) public view returns (order memory) {
        return userOrders[userAddress][planId][id];
    }

    // the next order id
    function getOrderNum(address userAddress, uint256 planId)
        public
        view
        returns (uint256)
    {
        return orderIds[userAddress][planId];
    }

    event PledgeLp(
        address user,
        uint256 planId,
        uint256 amount,
        uint256 time,
        uint256 unlockTime
    );

    function pledgeLp(uint256 planId, uint256 amount) public nonReentrant {
        require(msg.sender == tx.origin, "no contract");
        require(plans[planId].isOpen, "plan not open");
        require(amount > 0, "amount less");
        require(
            IERC20(lpAddress).transferFrom(
                address(msg.sender),
                address(this),
                amount
            ),
            "transfer pledgeLP failed"
        );

        //create order

        uint256 unlockTime = block.timestamp + plans[planId].lockDays * 86400;
        userOrders[msg.sender][planId][orderIds[msg.sender][planId]] = order(
            true,
            amount,
            block.timestamp,
            0,
            unlockTime,
            0,
            0,
            plans[planId].rate,
            plans[planId].rateBase,
            plans[planId].tokenAddress
        );
        orderIds[msg.sender][planId]++;

        //total
        userInfos[msg.sender].lp += amount;
        totalLp += amount;

        emit PledgeLp(msg.sender, planId, amount, block.timestamp, unlockTime);
    }

    event UnpledgeLp(address user, uint256 orderId, uint256 time);

    function unpledgeLp(uint256 planId, uint256 orderId) public nonReentrant {
        require(msg.sender == tx.origin, "no contract");
        order storage order_info = userOrders[msg.sender][planId][orderId];
        require(order_info.isExist, "order not exist");
        require(order_info.endTime == 0, "order is end");
        require(block.timestamp >= order_info.unlockTime, "order is lock");

        require(
            IERC20(lpAddress).transfer(
                address(msg.sender),
                order_info.lpNumber
            ),
            "transfer pledgeLP failed"
        );

        order_info.endTime = block.timestamp;

        //total
        userInfos[msg.sender].lp -= order_info.lpNumber;
        totalLp -= order_info.lpNumber;

        emit UnpledgeLp(msg.sender, orderId, block.timestamp);
    }

    function earn(
        address userAddress,
        uint256 planId,
        uint256 orderId
    ) public view returns (uint256) {
        order storage order_info = userOrders[userAddress][planId][orderId];
        if (order_info.isExist == false) {
            return 0;
        }
        if (block.timestamp < order_info.unlockTime) {
            return 0;
        }
        return (order_info.lpNumber * order_info.rate) / order_info.rateBase;
    }

    event GetReward(
        address user,
        uint256 orderId,
        uint256 amount,
        uint256 time
    );

    function getReward(uint256 planId, uint256 orderId) public nonReentrant {
        require(msg.sender == tx.origin, "no contract");
        order storage order_info = userOrders[msg.sender][planId][orderId];
        require(order_info.isExist, "order not exist");
        require(block.timestamp > order_info.unlockTime, "locktime");

        uint256 reward = earn(msg.sender, planId, orderId);
        require(reward > 0, "no reward");
        address rewardToken = order_info.tokenAddress;
        if (rewardToken == sgtAddress) {
            require(
                IERC20(order_info.tokenAddress).transfer(
                    address(msg.sender),
                    reward
                ),
                "transfer reward token failed"
            );
            userInfos[msg.sender].receivedSgt += reward;
        } else {
            require(
                mintToken(order_info.tokenAddress).mint(
                    address(msg.sender),
                    reward
                ),
                "mint failed"
            );
            userInfos[msg.sender].receivedEne += reward;
        }

        order_info.received += reward;

        emit GetReward(msg.sender, orderId, reward, block.timestamp);
    }

    function gettoken(address tokenAddress) public onlyOwner {
        require(
            IERC20(tokenAddress).transfer(
                msg.sender,
                IERC20(tokenAddress).balanceOf(address(this))
            ),
            "transfer token failed"
        );
    }

    event Relock(address user, uint256 planId, uint256 orderId, uint256 amount,uint256 time);

    function relock(uint256 planId, uint256 orderId) external nonReentrant {
        require(msg.sender == tx.origin, "no contract");
        order storage order_info = userOrders[msg.sender][planId][orderId];
        require(order_info.isExist, "order not exist");
        require(order_info.endTime == 0, "order is end");
        require(block.timestamp >= order_info.unlockTime, "order is lock");
        require(plans[planId].isOpen, "plan not open");

        // end order
        order_info.endTime = block.timestamp;

        //create order
        uint256 amount = order_info.lpNumber;
        uint256 unlockTime = block.timestamp + plans[planId].lockDays * 86400;
        userOrders[msg.sender][planId][orderIds[msg.sender][planId]] = order(
            true,
            amount,
            block.timestamp,
            0,
            unlockTime,
            0,
            0,
            plans[planId].rate,
            plans[planId].rateBase,
            plans[planId].tokenAddress
        );
        orderIds[msg.sender][planId]++;
        emit Relock(msg.sender, planId, orderId,amount, block.timestamp);
    }
}