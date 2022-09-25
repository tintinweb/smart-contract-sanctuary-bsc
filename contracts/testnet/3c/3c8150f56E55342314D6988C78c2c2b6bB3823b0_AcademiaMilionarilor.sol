/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

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

// File: AM.sol


pragma solidity 0.8.17;


contract AcademiaMilionarilor {
    address public owner = 0x9E4e16151f9fB31f9943eEAbF02C3d41Bf4aBe55; // to change
    address public autoPayer = 0x9E4e16151f9fB31f9943eEAbF02C3d41Bf4aBe55; // to change
    address payable public paymentSplitter =
        payable(0x9E4e16151f9fB31f9943eEAbF02C3d41Bf4aBe55); // to change
    address public BUSD = 0xa7A999eeB966ec0391AAfd95225c07e1c5470899;
    IERC20 public BUSDContract = IERC20(BUSD);
    uint256 public totalSubscribers;
    uint256 public planCost = 2997e16; // $29.97
    uint256 public frequency = 30 days;
    uint256 public index;

    struct Subscription {
        address subscriber;
        uint256 start;
        uint256 nextPayment;
        bool isActive;
        bytes32 userIdHash;
    }

    mapping(address => Subscription) public subscriptions;
    mapping(bytes32 => address) public userIds;
    mapping(uint256 => address) public numberToAddress;
    mapping(address => bytes32) public addressToID;

    // subscribe
    function subscribe(bytes32 userIdHash, address referral) public {
        require(
            BUSDContract.allowance(msg.sender, address(this)) >= planCost,
            "Nu ai suficient BUSD permis!"
        );
        require(
            BUSDContract.balanceOf(msg.sender) >= planCost,
            "Nu ai suficient BUSD pentru a te abona!"
        );
        require(
            subscriptions[msg.sender].isActive == false,
            "Esti deja abonat!"
        );

        BUSDContract.transferFrom(msg.sender, address(this), planCost);

        if (referral != address(0) && referral != msg.sender) {
            BUSDContract.transferFrom(address(this), referral, 14985e15);
        }

        subscriptions[msg.sender] = Subscription(
            msg.sender,
            block.timestamp,
            block.timestamp + frequency,
            true,
            userIdHash
        );
        userIds[userIdHash] = msg.sender;
        addressToID[msg.sender] = userIdHash;
        numberToAddress[index] = msg.sender;
        index++;
        totalSubscribers++;
    }

    // cancel
    function cancel() public {
        require(subscriptions[msg.sender].subscriber != address(0));
        require(subscriptions[msg.sender].subscriber == msg.sender);
        require(subscriptions[msg.sender].isActive == true);
        subscriptions[msg.sender].isActive = false;
        totalSubscribers--;
    }

    // pay
    function pay(address _subscriber) internal {
        Subscription storage subscription = subscriptions[_subscriber];
        require(
            subscription.subscriber != address(0),
            "This subscription does not exist"
        );
        require(
            subscription.subscriber == msg.sender,
            "You are not the subscriber"
        );
        require(
            subscription.nextPayment <= block.timestamp,
            "You can't pay yet"
        );
        BUSDContract.transferFrom(msg.sender, address(this), planCost);
        subscription.nextPayment = block.timestamp + frequency;
    }

    // changeUserId
    function changeUserId(bytes32 userIdHash) public {
        require(subscriptions[msg.sender].subscriber != address(0));
        require(subscriptions[msg.sender].subscriber == msg.sender);
        require(userIds[userIdHash] == address(0));
        userIds[subscriptions[msg.sender].userIdHash] = address(0);
        subscriptions[msg.sender].userIdHash = userIdHash;
        userIds[userIdHash] = msg.sender;
    }

    // changePlanCost
    function changePlanCost(uint256 newPlanCost) public {
        require(msg.sender == owner, "You are not the owner");
        planCost = newPlanCost;
    }

    // changeFrequency
    function changeFrequency(uint256 newFrequency) public {
        require(msg.sender == owner, "You are not the owner");
        frequency = newFrequency;
    }

    // changeOwner
    function changeOwner(address newOwner) public {
        require(msg.sender == owner, "You are not the owner");
        owner = newOwner;
    }

    // checkDue
    function checkDue(address _subscriber) public view returns (bool) {
        Subscription storage subscription = subscriptions[_subscriber];
        require(_subscriber!=address(0));
        return block.timestamp < subscription.nextPayment ? true: false;
    }

    // autoPay
    function autoPay(address _subscriber) external {
        require(msg.sender == autoPayer);
        require(
            subscriptions[_subscriber].subscriber != address(0),
            "This subscription does not exist"
        );
        require(!checkDue(_subscriber));
        pay(_subscriber);
    }

    // withdraw
    function withdraw() public {
        require(msg.sender == owner, "You are not the owner");
        paymentSplitter.transfer(IERC20(BUSD).balanceOf(address(this)));
    }
}