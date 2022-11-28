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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "/home/karolsudol/flywallet/TravelSaver/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Travel Saving Vault with Recurring Payments Scheduler
 */
contract TravelSaver {
    // ***** ***** EVENTS ***** *****

    /**
     * @notice Emitted when a TravelPlan is created
     *
     * @param ID uniqe plan's ID
     * @param owner user who created it
     * @param travelPlan a plan's details
     */
    event CreatedTravelPlan(
        uint256 indexed ID,
        address indexed owner,
        TravelPlan travelPlan
    );

    /**
     * @notice Emitted when a token transfer is made to each TravelPlan
     *
     * @param ID uniqe plan's ID
     * @param contributor address that made a transfer
     * @param amount an ERC20 unit as per its decimals
     */
    event ContributeToTravelPlan(
        uint256 indexed ID,
        address indexed contributor,
        uint256 amount
    );

    /**
     * @notice Emitted when a user makes a withdrawl towards a booking
     *
     * @param ID uniqe plan's ID
     * @param owner address that received a transfer
     * @param amount an ERC20 unit as per its decimals
     */
    event ClaimTravelPlan(uint256 indexed ID, address owner, uint256 amount);

    /**
     * @notice Emitted when a user makes a withdrawl towards a booking
     *
     * @param from address that made a transfer
     * @param to address that received a transfer
     * @param amount an ERC20 unit as per its decimals
     */
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /**
     * @notice Emitted when a PaymentPlan is created
     *
     * @param ID uniqe plan's ID
     * @param owner user who created it
     * @param paymentPlan a plan's details
     */
    event CreatedPaymentPlan(
        uint256 indexed ID,
        address indexed owner,
        PaymentPlan paymentPlan
    );

    /**
     * @notice Emitted when a PaymentPlan is cancelled before scheduled payments are made
     *
     * @param ID uniqe plan's ID
     * @param owner user who created it
     * @param paymentPlan a plan's details
     */
    event CancelPaymentPlan(
        uint256 indexed ID,
        address indexed owner,
        PaymentPlan paymentPlan
    );

    /**
     * @notice Emitted when a PaymentPlan scheduled payment has been sucessfully made
     *
     * @param ID uniqe plan's ID
     * @param callableOn unix TS of next scheduled payment
     * @param amount an ERC20 unit as per its decimals
     * @param intervalNo sequential scheduled payment count
     */
    event StartPaymentPlanInterval(
        uint256 indexed ID,
        uint256 indexed callableOn,
        uint256 indexed amount,
        uint256 intervalNo
    );

    /**
     * @notice Emitted when a PaymentPlan scheduled payment has been sucessfully made
     *
     * @param ID uniqe plan's ID
     * @param intervalNo sequential scheduled payment count
     */
    event PaymentPlanIntervalEnded(
        uint256 indexed ID,
        uint256 indexed intervalNo
    );

    /**
     * @notice Emitted when a PaymentPlan has ended as scheduled, after last payment
     *
     * @param ID uniqe plan's ID
     * @param owner user who created it
     * @param paymentPlan a plan's details
     */
    event EndPaymentPlan(
        uint256 indexed ID,
        address indexed owner,
        PaymentPlan paymentPlan
    );
    // ***** ***** STRUCTS ***** *****

    /**
     * @notice TravelPlan is a vault where users funds are retained until the booking
     *
     * @param owner user's wallet address, plan creator, who can transfer money out to operators wallet -> make a booking
     * @param ID unique identifier within the contract generated sequencially
     * @param operatorPlanID operator's reference booking identifier
     * @param operatorUserID operator's reference user identifier
     * @param contributedAmount current ammount available for a whithdrawal
     * @param createdAt the creation date
     * @param claimedAt last clamied date
     * @param claimed true if it has been clamimed in the past
     */
    struct TravelPlan {
        address owner;
        uint256 ID;
        uint256 operatorPlanID;
        uint256 operatorUserID;
        uint256 contributedAmount;
        uint256 createdAt;
        uint256 claimedAt;
        bool claimed;
    }

    /**
     * @notice PaymentPlan is a recurring payments scheduler that must target specific TravelPlan
     *
     * @param travelPlanID id reference to a vault id where funds will be sent to
     * @param ID unique identifier within the contract generated sequencially
     * @param totalAmount the planned value of a total savings to be scheduled
     * @param amountSent the current state of all payments made
     * @param amountPerInterval unit value of a specific ERC-20 token to be sent per each scheduled payment
     * @param totalIntervals total number of scheduled payments
     * @param intervalsProcessed cuurent number of processed payments
     * @param nextTransferOn unix secs TS of a next scheduled payment due at
     * @param interval current interval count
     * @param sender the owner of the plan - might be different to the TravelPlan
     * @param alive determined whether plan is active or cancelled
     */
    struct PaymentPlan {
        uint256 travelPlanID;
        uint256 ID;
        uint256 totalAmount;
        uint256 amountSent;
        uint256 amountPerInterval;
        uint256 totalIntervals;
        uint256 intervalsProcessed;
        uint256 nextTransferOn;
        uint256 interval;
        address sender;
        bool alive;
    }

    // ***** ***** STATE-VARIABLES ***** *****

    address public immutable operatorWallet; // hardcoded address of the operator wallet where funds are send from teh travel-plan
    IERC20 public immutable token; // hardcoded address of the ERC20 stable token that serves a currency of the contract

    uint256 travelPlanCount; // current number of contract's created travel-plans
    uint256 paymentPlanCount; // current number of contract's created payment-plans

    mapping(uint256 => TravelPlan) public travelPlans; // TravelPlan reference by ID
    mapping(uint256 => PaymentPlan) public paymentPlans; // PaymentPlan referenced by ID

    // mapping(uint256 => mapping(address => uint256)) public contributedAmount; // ID

    constructor(address ERC20_, address operatorWallet_) {
        token = IERC20(ERC20_);
        operatorWallet = operatorWallet_;
    }

    /**
     ***** ***** VIEW-FUNCTIONS ***** *****
     */

    /**
     * @notice receive Plans state
     *
     * @param ID uniqe plan's ID
     */
    function getTravelPlanDetails(uint256 ID)
        external
        view
        returns (TravelPlan memory)
    {
        return travelPlans[ID];
    }

    /**
     * @notice receive plans state
     *
     * @param ID uniqe plan's ID
     */
    function getPaymentPlanDetails(uint256 ID)
        external
        view
        returns (PaymentPlan memory)
    {
        return paymentPlans[ID];
    }

    /**
     ***** ***** STATE-CHANGING-EXTERNAL-FUNCTIONS ***** *****
     */

    /**
     * @dev create Travel Plan and New Payment Plan attached to it in one go
     *
     * @param operatorPlanID_ The plan id provided by the operator.
     * @param operatorUserID_ The user id provided by the operator.
     * @param amountPerInterval unit value of a specific ERC-20 token to be sent per each scheduled payment
     * @param totalIntervals total number of payments to be scheduled
     * @param intervalLength time distance between each payments in seconds
     *
     * @return travelPlanID paymentPlanID new sequential count based UUIDs
     *
     * Emits a {CreatedTravelPlan, CreatedPaymentPlan} event.
     */
    function createTravelPaymentPlan(
        uint256 operatorPlanID_,
        uint256 operatorUserID_,
        uint256 amountPerInterval,
        uint256 totalIntervals,
        uint256 intervalLength
    ) external returns (uint256 travelPlanID, uint256 paymentPlanID) {
        travelPlanID = createTravelPlan(operatorPlanID_, operatorUserID_);
        paymentPlanID = createPaymentPlan(
            travelPlanID,
            amountPerInterval,
            totalIntervals,
            intervalLength
        );
        return (travelPlanID, paymentPlanID);
    }

    /**
     * @dev create Travel Plan where user will store his/hers savings until the booking date
     *
     * @param operatorPlanID_ The plan id provided by the operator.
     * @param operatorUserID_ The user id provided by the operator.
     *
     * @return travelPlanCount  a new sequential count based UUID
     *
     * Emits a {CreatedTravelPlan} event.
     */
    function createTravelPlan(uint256 operatorPlanID_, uint256 operatorUserID_)
        public
        returns (uint256)
    {
        travelPlanCount += 1;

        travelPlans[travelPlanCount] = TravelPlan({
            owner: msg.sender,
            ID: travelPlanCount,
            operatorPlanID: operatorPlanID_,
            operatorUserID: operatorUserID_,
            contributedAmount: 0,
            createdAt: block.timestamp,
            claimedAt: 0,
            claimed: false
        });

        emit CreatedTravelPlan(
            travelPlanCount,
            msg.sender,
            travelPlans[travelPlanCount]
        );
        return travelPlanCount;
    }

    /**
     * @dev allows to transfer ERC20 token to specific TravelPlan by anyone
     *
     * @param ID TravelPlan existing UUID
     * @param amount ERC20 token value defined by its decimals
     *
     * Emits a {ContributeToTravelPlan, Transfer} event.
     */
    function contributeToTravelPlan(uint256 ID, uint256 amount) external {
        TravelPlan storage plan = travelPlans[ID];
        require(plan.ID == ID, "doesn't exist");

        plan.contributedAmount += amount;

        token.transferFrom(msg.sender, address(this), amount);

        emit ContributeToTravelPlan(ID, msg.sender, amount);
        emit Transfer(msg.sender, address(this), amount);
    }

    /**
     * @dev allows to transfer ERC20 token from specific TravelPlan to operators wallet to make a booking only by the user/owner
     *
     * @param ID TravelPlan existing UUID
     * @param value ERC20 token value defined by its decimals
     *
     * Emits a {ClaimTravelPlan, Transfer} event.
     */
    function claimTravelPlan(uint256 ID, uint256 value) external {
        TravelPlan storage plan = travelPlans[ID];
        require(plan.ID == ID, "doesn't exist");
        require(plan.owner == msg.sender, "not owner");
        require(plan.contributedAmount >= value, "insufficient funds");
        plan.contributedAmount -= value;
        token.transfer(operatorWallet, value);
        plan.claimed = true;
        plan.claimedAt = block.timestamp;
        emit ClaimTravelPlan(ID, msg.sender, value);
        emit Transfer(address(this), operatorWallet, value);
    }

    /**
     * @dev creates a new payment plan targeting existing travel-plan along with its sheduled payments details
     *
     * @param _travelPlanID The plan id provided by the operator.
     * @param amountPerInterval unit value of a specific ERC-20 token to be sent per each scheduled payment
     * @param totalIntervals total number of payments to be scheduled
     * @param intervalLength time distance between each payments in seconds
     *
     * @return id  a new sequential count based UUID
     *
     * Emits a {CreatedPaymentPlan} event.
     */
    function createPaymentPlan(
        uint256 _travelPlanID,
        uint256 amountPerInterval,
        uint256 totalIntervals,
        uint256 intervalLength
    ) public returns (uint256) {
        uint256 totalToTransfer = amountPerInterval * totalIntervals;
        require(
            IERC20(token).allowance(msg.sender, address(this)) >=
                totalToTransfer,
            "ERC20: insufficient allowance"
        );
        TravelPlan memory plan = travelPlans[_travelPlanID];
        require(plan.ID == _travelPlanID, "doesn't exist");
        uint256 id = ++paymentPlanCount;

        paymentPlans[id] = PaymentPlan({
            travelPlanID: _travelPlanID,
            ID: id,
            totalAmount: totalIntervals * amountPerInterval,
            amountSent: 0,
            amountPerInterval: amountPerInterval,
            totalIntervals: totalIntervals,
            intervalsProcessed: 0,
            nextTransferOn: 0,
            interval: intervalLength,
            sender: msg.sender,
            alive: true
        });
        _startInterval(id);

        emit CreatedPaymentPlan(id, msg.sender, paymentPlans[id]);

        return id;
    }

    /**
     * @dev cancelPaymentPlan cancels existing payment schedule before its plannned due date
     *
     * @param ID TravelPlan existing UUID
     *
     * Emits a {CancelPaymentPlan} event.
     */
    function cancelPaymentPlan(uint256 ID) external {
        require(msg.sender == paymentPlans[ID].sender, "only plan owner");
        _endPaymentPlan(ID);

        emit CancelPaymentPlan(ID, msg.sender, paymentPlans[ID]);
    }

    /**
     * @dev runInterval executes scheduled payment
     *
     * @param ID PaymentPlan existing UUID
     */
    function runInterval(uint256 ID) external {
        _fulfillPaymentPlanInterval(ID);
    }

    /**
     * @dev runIntervals executes scheduled payment as a batch
     *
     * @param IDs PaymentPlan existing UUIDs
     */
    function runIntervals(uint256[] memory IDs) external {
        for (uint256 i = 0; i < IDs.length; i++) {
            _fulfillPaymentPlanInterval(IDs[i]);
        }
    }

    /**
     ***** ***** STATE-CHANGING-PRIVATE-FUNCTIONS ***** *****
     */

    /**
     * @dev _startInterval sets new payment schedule
     *
     * @param ID PaymentPlan existing UUIDs
     *
     * Emits a {StartPaymentPlanInterval} event.
     */
    function _startInterval(uint256 ID) internal {
        PaymentPlan memory plan = paymentPlans[ID];
        uint256 callableOn = paymentPlans[ID].interval + block.timestamp;
        uint256 intervalNumber = plan.intervalsProcessed + 1;
        paymentPlans[ID].nextTransferOn = callableOn;

        emit StartPaymentPlanInterval(
            ID,
            callableOn,
            plan.amountPerInterval,
            intervalNumber
        );
    }

    /**
     * @dev _endPaymentPlan ends payment plan
     *
     * @param ID PaymentPlan existing UUIDs
     *
     * Emits a {EndPaymentPlan} event.
     */
    function _endPaymentPlan(uint256 ID) internal {
        PaymentPlan memory plan = paymentPlans[ID];
        paymentPlans[ID].alive = false;
        emit EndPaymentPlan(ID, plan.sender, plan);
    }

    /**
     * @dev _contributeToTravelPlan executes scheduled payments internaly by transfering tokens from user to the vault - used by a off chain worker
     *
     * @param ID PaymentPlan existing UUIDs
     * @param amount ERC20 token value defined by its decimals
     * @param caller address of a contract that executes transaction on behalf of the user
     *
     * Emits a {ContributeToTravelPlan, Transfer} event.
     */
    function _contributeToTravelPlan(
        uint256 ID,
        uint256 amount,
        address caller
    ) internal {
        TravelPlan storage plan = travelPlans[ID];
        // require(block.timestamp >= plan.createdAt, "doesn't exist");
        require(plan.ID == ID, "doesn't exist");

        plan.contributedAmount += amount;

        // contributedAmount[ID][caller] += amount;
        token.transferFrom(caller, address(this), amount);

        emit ContributeToTravelPlan(ID, caller, amount);
        emit Transfer(caller, address(this), amount);
    }

    /**
     * @dev _fulfillPaymentPlanInterval executes scheduled payments internaly
     *
     * @param ID PaymentPlan existing UUIDs
     *
     * Emits a {PaymentPlanIntervalEnded} event.
     */
    function _fulfillPaymentPlanInterval(uint256 ID) internal {
        PaymentPlan memory plan = paymentPlans[ID];

        uint256 amountToTransfer = plan.amountPerInterval;
        address sender = plan.sender;
        uint256 interval = plan.intervalsProcessed + 1;
        require(plan.nextTransferOn <= block.timestamp, "too early");
        require(plan.alive, "plan ended");

        // Check conditions here with an if clause instead of require, so that integrators dont have to keep track of balances
        if (
            token.balanceOf(sender) >= amountToTransfer &&
            token.allowance(sender, address(this)) >= amountToTransfer
        ) {
            _contributeToTravelPlan(
                plan.travelPlanID,
                amountToTransfer,
                sender
            );

            paymentPlans[ID].amountSent += amountToTransfer;
            paymentPlans[ID].intervalsProcessed = interval;

            emit PaymentPlanIntervalEnded(ID, interval);

            if (interval < plan.totalIntervals) {
                _startInterval(ID);
            } else {
                _endPaymentPlan(ID);
            }
        }
    }
}