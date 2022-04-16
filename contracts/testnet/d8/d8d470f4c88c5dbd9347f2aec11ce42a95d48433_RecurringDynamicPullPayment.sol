// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '../common/RegistryHelper.sol';

import './interfaces/IRecurringDynamicPP.sol';
import '../common/interfaces/IPullPaymentRegistry.sol';
import '../common/interfaces/IVersionedContract.sol';
import '../common/interfaces/IExecutor.sol';

/// @title RecurringDynamicPullPayment
contract RecurringDynamicPullPayment is
	ReentrancyGuardUpgradeable,
	RegistryHelper,
	IRecurringDynamicPullPayment,
	IVersionedContract
{
	using CountersUpgradeable for CountersUpgradeable.Counter;
	/*
   	=======================================================================
   	======================== Structures ===================================
   	=======================================================================
 	*/
	struct PullPayment {
		uint256 paymentAmount;
		uint256 executionTimestamp;
	}

	struct Subscription {
		SubscriptionData data;
		//PullPayment ID => pullPayment
		mapping(uint256 => PullPayment) pullPayments;
	}

	struct FreeTrial {
		//subscription Id => Subscription
		mapping(uint256 => Subscription) subscription;
		uint256 trialPeriod;
	}

	struct PaidTrial {
		//subscription Id => Subscription
		mapping(uint256 => Subscription) subscription;
		uint256 trialPeriod;
		uint256 initialAmount;
	}

	struct BillingModel {
		address payee;
		uint8 recurringPPType; //1-normal recurringPP, 2-free trial recurringPP, 3-Paid trial recurringPP
		uint256[] subscriptionIDs;
	}
	/*
   	=======================================================================
   	======================== Private Variables ============================
   	=======================================================================
 	*/
	// IDs
	CountersUpgradeable.Counter private _billingModelIDs;
	CountersUpgradeable.Counter private _subscriptionIDs;
	CountersUpgradeable.Counter private _pullPaymentIDs;

	//Subscription ID => subscription details for normal recurringPP
	mapping(uint256 => Subscription) private subscriptions;
	//Subscription ID => subscription details for free recurringPP
	mapping(uint256 => FreeTrial) private freeTrialSubscriptions;
	//Subscription ID => subscription details for paid recurringPP
	mapping(uint256 => PaidTrial) private paidTrialSubscriptions;

	// billing model ID => billing model details
	mapping(uint256 => BillingModel) private _billingModels;
	// subscription ID => billing model ID
	mapping(uint256 => uint256) private _subscriptionToBillingModel;
	// pull payment ID => subscription ID
	mapping(uint256 => uint256) private _pullPaymentToSubscription;

	// Mappings by address
	// Billing Model Creator => billing model IDs
	mapping(address => uint256[]) private _billingModelIdsByAddress;
	// Customer address => subscription IDs
	mapping(address => uint256[]) private _subscriptionIdsByAddress;
	// Customer address => pull payment IDs
	mapping(address => uint256[]) private _pullPaymentIdsByAddress;
	// TODO: sort this out on cancellation
	mapping(address => uint256[]) private _inactiveSubscriptionsByAddress;

	/*
   	=======================================================================
   	======================== Constructor/Initializer ======================
   	=======================================================================
 	*/
	/**
	 * @notice Used in place of the constructor to allow the contract to be upgradable via proxy.
	 */
	function initialize(address registryAddress) external initializer {
		__ReentrancyGuard_init();
		_init_registryHelper(registryAddress);
	}

	/*
   	=======================================================================
   	======================== Events =======================================
    =======================================================================
 	*/
	// TODO: Need to emit more data on each of the events below.
	event BillingModelCreated(
		uint256 indexed billingModelID,
		address indexed payee,
		uint8 indexed recurringPPType
	);
	event NewSubscription(
		uint256 indexed billingModelID,
		uint256 indexed subscriptionID,
		address indexed payer
	);
	event PullPaymentExecuted(
		uint256 indexed subscriptionID,
		uint256 indexed pullPaymentID,
		uint256 indexed billingModelID,
		address payer
	);

	event SubscriptionCancelled(uint256 indexed billingModelID, uint256 indexed subscriptionID);

	event BillingModelEdited(
		uint256 indexed billingModelID,
		address indexed newPayee,
		address indexed oldPayee
	);

	/*
   	=======================================================================
   	======================== Modifiers ====================================
    =======================================================================
 	*/
	modifier onlyValidSubscriptionId(uint256 _subscriptionID) {
		require(
			_subscriptionID > 0 && _subscriptionID <= _subscriptionIDs.current(),
			'RecurringDynamicPullPayment: INVALID_SUBSCRIPTION_ID'
		);
		_;
	}

	modifier onlyValidBillingModelId(uint256 _billingModelID) {
		require(
			_billingModelID > 0 && _billingModelID <= _billingModelIDs.current(),
			'RecurringDynamicPullPayment: INVALID_BILLING_MODEL_ID'
		);
		_;
	}

	/*
   	=======================================================================
   	======================== Public Methods ===============================
   	=======================================================================
 	*/
	/**
	 * @dev Creates a new billing model
	 *
	 * @param _payee             - payee (receiver) address for pull payment
	 * @param _recurringPPType   - indicates the type of Recurring PullPayment, 1- Normal RecurringPP, 2- Free trial RecurringPP, 3- Paid trial RecurringPP
	 */
	function createBillingModel(address _payee, uint8 _recurringPPType)
		external
		override
		returns (uint256 billingModelID)
	{
		require(_payee != address(0), 'RecurringDynamicPullPayment: INVALID_PAYEE_ADDRESS');
		require(
			_recurringPPType > 0 && _recurringPPType <= 3,
			'RecurringDynamicPullPayment: INVALID_RECURRING_PP_TYPE'
		);

		_billingModelIDs.increment();
		uint256 newBillingModelID = _billingModelIDs.current();

		// Billing Model Details
		_billingModels[newBillingModelID].payee = _payee;
		_billingModels[newBillingModelID].recurringPPType = _recurringPPType;

		// Owner/Creator of the billing model
		_billingModelIdsByAddress[msg.sender].push(newBillingModelID);

		// emit event for new billing model
		emit BillingModelCreated(newBillingModelID, _payee, _recurringPPType);

		return newBillingModelID;
	}

	/**
	 * @dev Subscribes to a new billing model
	 *
	 * @param _billingModelID    - the ID of the billing model
	 * @param _bmName,           - indicates the billing model name
	 * @param _settlementToken,  - indicates the token address that payee wants to get paid in
	 * @param _paymentToken      - indicates the token address the customer wants to pay in
	 * @param _paymentAmount     - indicates the amount that customer would pay for subscription,
	 * @param _frequency         - indicates the interval at which pull payment will get executed
	 * @param _totalPayments     - indicates the total no. of payments to be executed
	 * @param _trialPeriod       - indicates the trial period for pullPayment, should be zero in case of recurringType=1 i.e normal recurringPP
	 * @param _initialAMount     - indicates the Amount to pay for paid trial, should be zero in case of recurrngType =2 i.e normal recurringPP
	 */
	function subscribeToBillingModel(
		uint256 _billingModelID,
		string memory _bmName,
		address _settlementToken,
		address _paymentToken,
		uint256 _paymentAmount,
		uint256 _frequency,
		uint256 _totalPayments,
		uint256 _trialPeriod,
		uint256 _initialAMount
	) external override onlyValidBillingModelId(_billingModelID) returns (uint256 subscriptionID) {
		require(_paymentAmount > 0, 'RecurringDynamicPullPayment: INVALID_PAYMENT_AMOUNT');
		require(_frequency > 0, 'RecurringDynamicPullPayment: INVALID_FREQUENCY');
		require(_totalPayments > 0, 'RecurringDynamicPullPayment: INVALID_TOTAL_NO_OF_PAYMENTS');
		require(
			registry.isSupportedToken(_settlementToken),
			'RecurringDynamicPullPayment: UNSUPPORTED_TOKEN'
		);
		
		_subscriptionIDs.increment();
		uint256 newSubscriptionID = _subscriptionIDs.current();

		BillingModel storage bm = _billingModels[_billingModelID];

		//initialize the subscription
		SubscriptionData storage newSubscription = subscriptions[newSubscriptionID].data;

		newSubscription.subscriber = msg.sender;
		newSubscription.bmName = _bmName;
		newSubscription.settlementToken = _settlementToken;
		newSubscription.paymentToken = _paymentToken;
		newSubscription.paymentAmount = _paymentAmount;
		newSubscription.frequency = _frequency;
		newSubscription.totalPayments = _totalPayments;
		newSubscription.remainingPayments = _totalPayments;
		newSubscription.startTimestamp = block.timestamp;

		if (bm.recurringPPType != 1) {
			require(_trialPeriod > 0, 'RecurringDynamicPullPayment: INVALID_TRIAL_PERIOD');

			//payment will be executed after the trial period
			newSubscription.nextPaymentTimestamp = newSubscription.startTimestamp + _trialPeriod;
		}

		//Normal Recurring PullPayment
		if (bm.recurringPPType == 1) {
			subscriptions[newSubscriptionID].data = newSubscription;
		} else if (bm.recurringPPType == 2) {
			//Free Trial Recurring PullPayment
			freeTrialSubscriptions[newSubscriptionID]
				.subscription[newSubscriptionID]
				.data = newSubscription;
			freeTrialSubscriptions[newSubscriptionID].trialPeriod = _trialPeriod;
		} else if (bm.recurringPPType == 3) {
			//Paid Trial Recurring PullPayment
			require(_initialAMount > 0, 'RecurringDynamicPullPayment: INVALID_INITIAL_AMOUNT');
			newSubscription.lastPaymentTimestamp = block.timestamp;

			paidTrialSubscriptions[newSubscriptionID]
				.subscription[newSubscriptionID]
				.data = newSubscription;
			paidTrialSubscriptions[newSubscriptionID].trialPeriod = _trialPeriod;
			paidTrialSubscriptions[newSubscriptionID].initialAmount = _initialAMount;
		}

		bm.subscriptionIDs.push(newSubscriptionID);

		_subscriptionToBillingModel[newSubscriptionID] = _billingModelID;
		_subscriptionIdsByAddress[msg.sender].push(newSubscriptionID);

		emit NewSubscription(_billingModelID, newSubscriptionID, msg.sender);

		if (bm.recurringPPType == 1) {
			_executePullPayment(newSubscriptionID);
		} else if (bm.recurringPPType == 3) {
			//execute the payment for paid trial
			require(
				IExecutor(registry.getExecutor()).execute(
					_settlementToken,
					_paymentToken,
					msg.sender,
					bm.payee,
					_initialAMount
				)
			);
		}

		return newSubscriptionID;
	}

	/**
	 * @notice This method executes the pullPayment for given subscription Id.
	 * @param _subscriptionID    - Indicates the subscription ID
	 */
	function executePullPayment(uint256 _subscriptionID)
		public
		override
		nonReentrant
		onlyValidSubscriptionId(_subscriptionID)
		returns (uint256 pullPaymentID)
	{
		return _executePullPayment(_subscriptionID);
	}

	function _executePullPayment(uint256 _subscriptionID) private returns (uint256 pullPaymentID) {
		BillingModel storage bm = _billingModels[_subscriptionToBillingModel[_subscriptionID]];

		//intialize the subscription
		SubscriptionData storage _subscription = subscriptions[_subscriptionID].data;

		_initilizeSubscription(_subscription, bm.recurringPPType, _subscriptionID);

		uint256 billingModelID = _subscriptionToBillingModel[_subscriptionID];

		require(
			block.timestamp >= _subscription.startTimestamp &&
				block.timestamp >= _subscription.nextPaymentTimestamp,
			'RecurringDynamicPullPayment: INVALID_EXECUTION_TIME'
		);
		require(
			_subscription.cancelTimestamp == 0 || block.timestamp < _subscription.cancelTimestamp,
			'RecurringDynamicPullPayment: SUBSCRIPTION_CANCELED'
		);
		require(
			_subscription.remainingPayments > 0,
			'RecurringDynamicPullPayment: NO_OF_PAYMENTS_EXCEEDED'
		);

		_pullPaymentIDs.increment();
		uint256 newPullPaymentID = _pullPaymentIDs.current();

		// update subscription
		_subscription.remainingPayments = _subscription.remainingPayments - 1;
		_subscription.lastPaymentTimestamp = block.timestamp;
		_subscription.nextPaymentTimestamp = _subscription.nextPaymentTimestamp + _subscription.frequency;
		_subscription.pullPaymentIDs.push(newPullPaymentID);

		// update pull payment
		if (bm.recurringPPType == 1) {
			subscriptions[_subscriptionID].pullPayments[newPullPaymentID].paymentAmount = _subscription
				.paymentAmount;

			subscriptions[_subscriptionID].pullPayments[newPullPaymentID].executionTimestamp = block
				.timestamp;
		} else if (bm.recurringPPType == 2) {
			freeTrialSubscriptions[_subscriptionID]
				.subscription[_subscriptionID]
				.pullPayments[newPullPaymentID]
				.paymentAmount = _subscription.paymentAmount;
			freeTrialSubscriptions[_subscriptionID]
				.subscription[_subscriptionID]
				.pullPayments[newPullPaymentID]
				.executionTimestamp = block.timestamp;
		} else if (bm.recurringPPType == 3) {
			paidTrialSubscriptions[_subscriptionID]
				.subscription[_subscriptionID]
				.pullPayments[newPullPaymentID]
				.paymentAmount = _subscription.paymentAmount;
			paidTrialSubscriptions[_subscriptionID]
				.subscription[_subscriptionID]
				.pullPayments[newPullPaymentID]
				.executionTimestamp = block.timestamp;
		}

		// link pull payment with subscription
		_pullPaymentToSubscription[newPullPaymentID] = _subscriptionID;
		// link pull payment with "payer"
		_pullPaymentIdsByAddress[_subscription.subscriber].push(newPullPaymentID);

		// TODO: Need to get the correct amount based on the conversion rate...
		// The following scenarios need to be taken into consideration:
		// Scenario 1: PMA to PMA
		// ======================
		// In this case, both the customer and the merchant want to use PMA token for the payment.
		// The merchant wants to receive in PMA and the customer wants to pay in PMA.
		// This is the simplest scenario. There are no conversions/swaps involved and the execution
		// will proceed by simply moving (transferFrom) tokens from the customer to the merchant.
		// Scenario 2: non-PMA to PMA
		// ==========================
		// In this case, the merchant wants to receive PMA, but  the customer wants to pay using a
		// different token, for example DAI. For this to happen, then we will need to convert DAI
		// to PMA through the PumaSwap and then move the PMA to the merchant. The above operation
		// will need to happen through the executor smart contract, since that's the one that the
		// users will be approving (ERC20 allowance) for moving their tokens around.
		// Scenario 3: non-PMA to non-PMA (different)
		// Example: DAI to USDT
		// ==========================================
		// This is the most complex scenario, where we have the merchant wanting to receive DAI and
		// the customer wanting to pay in ETH. Here, we will need to convert ETH (from customer) to PMA
		// through the PumaSwap,then convert the PMA to DAI and then transfer the DAI to the merchant.
		// Scenario 3: non-PMA to non-PMA (same)
		// Example: DAI to DAI
		// =====================================
		// This scenario is the same as above, with the only difference that the merchant and the customer
		// want to receive and pay, respectively, using the same token. For example,  we have the merchant
		// wanting to receive DAI and the customer wanting to pay in DAI as well. Even though the token is
		// the same, we will still need to convert the customer's DAI to PMA, then convert the PMA back to
		// DAI and then transfer the DAI to the merchant. The main reason for this is that the PMA token to
		// be the sole means of value transfer through the protocol, which is one of the white-paper constrains.
		require(
			IExecutor(registry.getExecutor()).execute(
				_subscription.settlementToken,
				_subscription.paymentToken,
				_subscription.subscriber,
				bm.payee,
				_subscription.paymentAmount
			)
		);

		emit PullPaymentExecuted(
			_subscriptionID,
			newPullPaymentID,
			billingModelID,
			_subscription.subscriber
		);

		return newPullPaymentID;
	}

	/**
	 * @notice This method cancels the cancels the subscription for given subscription id
	 * @param _subscriptionID - indicates the subscription id
	 */
	function cancelSubscription(uint256 _subscriptionID)
		external
		override
		onlyValidSubscriptionId(_subscriptionID)
		returns (uint256 subscriptionID)
	{
		BillingModel storage bm = _billingModels[_subscriptionToBillingModel[_subscriptionID]];

		//intialize the subscription
		SubscriptionData storage subscription = subscriptions[_subscriptionID].data;

		_initilizeSubscription(subscription, bm.recurringPPType, _subscriptionID);

		require(
			msg.sender == subscription.subscriber,
			'RecurringDynamicPullPayment: INVALID_SUBSCRIBER'
		);
		subscription.cancelTimestamp = block.timestamp;

		_inactiveSubscriptionsByAddress[msg.sender].push(_subscriptionID);
		// TODO: can we delete from _customerSubscriptions mapping ??
		// This will allow us to have 2 mappings, one with active and another one with
		// inactive subscriptions - that's something that we will need to show in the UI

		emit SubscriptionCancelled(_subscriptionToBillingModel[_subscriptionID], _subscriptionID);

		return _subscriptionID;
	}

	/**
	 * @dev Edit a billing model
	 * Editing a billing model allows the creator of the billing model to update only attributes
	 * that does not affect the billing cycle of the customer, i.e. the name and the payee address.
	 * Any other changes are not allowed.
	 *
	 * @param _billingModelID - the ID of the billing model
	 * @param _newPayee - the address of new payee
	 */
	function editBillingModel(uint256 _billingModelID, address _newPayee)
		external
		override
		onlyValidBillingModelId(_billingModelID)
		returns (uint256 billingModelID)
	{
		require(
			msg.sender == _billingModels[_billingModelID].payee,
			'RecurringDynamicPullPayment: INVALID_EDITOR'
		);
		require(
			_newPayee != _billingModels[_billingModelID].payee,
			'RecurringDynamicPullPayment: ALREADY_PAYEE'
		);
		require(_newPayee != address(0), 'RecurringDynamicPullPayment: INVALID_PAYEE_ADDRESS');

		_billingModels[_billingModelID].payee = _newPayee;

		emit BillingModelEdited(_billingModelID, _newPayee, msg.sender);
		return _billingModelID;
	}

	/*
   	=======================================================================
   	======================== Getter Methods ===============================
   	=======================================================================
 	*/

	// **************************************************************** //
	// ************************ GETTERS - WEB3 ************************ //
	// **************************************************************** //

	/**
	 * @dev Retrieves a billing model
	 *
	 * @param _billingModelID - the ID of the billing model
	 */
	function getBillingModel(uint256 _billingModelID)
		external
		view
		override
		onlyValidBillingModelId(_billingModelID)
		returns (BillingModelData memory bm)
	{
		// If the caller is the address owning this billing model, then return the array with the
		// subscription IDs as well
		bm.payee = _billingModels[_billingModelID].payee;
		bm.recurringPPType = _billingModels[_billingModelID].recurringPPType;

		if (msg.sender == _billingModels[_billingModelID].payee) {
			bm.subscriptionIDs = _billingModels[_billingModelID].subscriptionIDs;
		} else {
			// Otherwise, return an empty array for `_bmSubscriptionIDs`
			uint256[] memory emptyArray;
			bm.subscriptionIDs = emptyArray;
		}
	}

	/**
	 * @dev Retrieves subscription details
	 *
	 * @param _subscriptionID - the ID of the subscription
	 */
	function getSubscription(uint256 _subscriptionID)
		external
		view
		override
		onlyValidSubscriptionId(_subscriptionID)
		returns (Data memory sb)
	{
		uint256 bmID = _subscriptionToBillingModel[_subscriptionID];
		BillingModel storage bm = _billingModels[bmID];

		//intialize the subscription
		SubscriptionData storage subscription = subscriptions[_subscriptionID].data;

		_initilizeSubscription(subscription, bm.recurringPPType, _subscriptionID);

		sb.subscription.subscriber = subscription.subscriber;
		sb.subscription.bmName = subscription.bmName;
		sb.subscription.paymentAmount = subscription.paymentAmount;
		sb.subscription.settlementToken = subscription.settlementToken;
		sb.subscription.paymentToken = subscription.paymentToken;
		sb.subscription.frequency = subscription.frequency;
		sb.subscription.totalPayments = subscription.totalPayments;
		sb.subscription.remainingPayments = subscription.remainingPayments;
		sb.subscription.startTimestamp = subscription.startTimestamp;
		sb.subscription.cancelTimestamp = subscription.cancelTimestamp;
		sb.subscription.nextPaymentTimestamp = subscription.nextPaymentTimestamp;
		sb.subscription.lastPaymentTimestamp = subscription.lastPaymentTimestamp;

		if (bm.recurringPPType == 2) {
			sb.trialPeriod = freeTrialSubscriptions[_subscriptionID].trialPeriod;
		} else if (bm.recurringPPType == 3) {
			sb.trialPeriod = paidTrialSubscriptions[_subscriptionID].trialPeriod;
			sb.initialAmount = paidTrialSubscriptions[_subscriptionID].initialAmount;
		}

		if (msg.sender == bm.payee || msg.sender == subscription.subscriber) {
			sb.subscription.pullPaymentIDs = subscription.pullPaymentIDs;
		} else {
			// Return an empty array for `_subscriptionPullPaymentIDs`in case the caller is not
			// the payee or the subscriber
			uint256[] memory emptyArray;
			sb.subscription.pullPaymentIDs = emptyArray;
		}
	}

	/**
	 * @dev Returns the details of a pull payment
	 *
	 * @param _pullPaymentID - Id of the pull payment
	 */
	function getPullPayment(uint256 _pullPaymentID)
		external
		view
		returns (PullPayment memory pullPayment)
	{
		require(
			_pullPaymentID > 0 && _pullPaymentID <= _pullPaymentIDs.current(),
			'RecurringDynamicPullPayment: INVALID_PULLPAYMENT_ID'
		);

		uint256 bmID = _subscriptionToBillingModel[_pullPaymentToSubscription[_pullPaymentID]];
		BillingModel storage bm = _billingModels[bmID];

		//intialize the subscription
		SubscriptionData storage subscription = subscriptions[
			_pullPaymentToSubscription[_pullPaymentID]
		].data;

		_initilizeSubscription(
			subscription,
			bm.recurringPPType,
			_pullPaymentToSubscription[_pullPaymentID]
		);

		if (msg.sender != bm.payee && msg.sender != subscription.subscriber &&
		IPullPaymentRegistry(registry.getPullPaymentRegistry()).isExecutorGranted(msg.sender) == false) {
			return pullPayment;
		} else {
			if (bm.recurringPPType == 1) {
				pullPayment.paymentAmount = subscriptions[_pullPaymentToSubscription[_pullPaymentID]]
					.pullPayments[_pullPaymentID]
					.paymentAmount;
				pullPayment.executionTimestamp = subscriptions[_pullPaymentToSubscription[_pullPaymentID]]
					.pullPayments[_pullPaymentID]
					.executionTimestamp;
			} else if (bm.recurringPPType == 2) {
				pullPayment.paymentAmount = freeTrialSubscriptions[
					_pullPaymentToSubscription[_pullPaymentID]
				]
					.subscription[_pullPaymentToSubscription[_pullPaymentID]]
					.pullPayments[_pullPaymentID]
					.paymentAmount;
				pullPayment.executionTimestamp = freeTrialSubscriptions[
					_pullPaymentToSubscription[_pullPaymentID]
				]
					.subscription[_pullPaymentToSubscription[_pullPaymentID]]
					.pullPayments[_pullPaymentID]
					.executionTimestamp;
			} else if (bm.recurringPPType == 3) {
				pullPayment.paymentAmount = paidTrialSubscriptions[
					_pullPaymentToSubscription[_pullPaymentID]
				]
					.subscription[_pullPaymentToSubscription[_pullPaymentID]]
					.pullPayments[_pullPaymentID]
					.paymentAmount;
				pullPayment.executionTimestamp = paidTrialSubscriptions[
					_pullPaymentToSubscription[_pullPaymentID]
				]
					.subscription[_pullPaymentToSubscription[_pullPaymentID]]
					.pullPayments[_pullPaymentID]
					.executionTimestamp;
			}
		}
	}

	/**
     @notice This method gets the subscription details of given subscripton Id for particular reucurring pullPayment
     @param subscription       - indicates the subscription struct which contains subscription data
     @param recurringPPType    - indicates the recurring pullPayment type
     @param subscriptionId     - indicates the subscription Id
     */
	function _initilizeSubscription(
		SubscriptionData storage subscription,
		uint256 recurringPPType,
		uint256 subscriptionId
	) internal view {
		if (recurringPPType == 1) {
			subscription = subscriptions[subscriptionId].data;
		} else if (recurringPPType == 2) {
			subscription = freeTrialSubscriptions[subscriptionId].subscription[subscriptionId].data;
		} else if (recurringPPType == 3) {
			subscription = paidTrialSubscriptions[subscriptionId].subscription[subscriptionId].data;
		}
	}

	/**
	 * @dev Retrieves billing model IDs for an address
	 * Returns an array with the billing model IDs related with that address
	 *
	 * @param _creator - address the created the billing model
	 */
	function getBillingModelIdsByAddress(address _creator)
		external
		view
		returns (uint256[] memory billingModelIDs)
	{
		return _billingModelIdsByAddress[_creator];
	}

	/**
	 * @dev Retrieves subscription ids for an address
	 * Returns an array with the subscription IDs related with that address
	 *
	 * @param _subscriber - address the pull payment relates to
	 */
	function getSubscriptionIdsByAddress(address _subscriber)
		external
		view
		returns (uint256[] memory subscriptionIDs)
	{
		return _subscriptionIdsByAddress[_subscriber];
	}

	/**
	 * @dev Retrieves canceled subscription ids for an address
	 * Returns an array with the subscription IDs related with that address
	 *
	 * @param _subscriber - address the pull payment relates to
	 */
	function getCanceledSubscriptionIdsByAddress(address _subscriber)
		external
		view
		returns (uint256[] memory subscriptionIDs)
	{
		return _inactiveSubscriptionsByAddress[_subscriber];
	}

	/**
	 * @dev Retrieves pull payment ids for an address
	 * Returns an array with the pull payment IDs related with that address
	 *
	 * @param _subscriber - address the pull payment relates to
	 */
	function getPullPaymentsIdsByAddress(address _subscriber)
		external
		view
		returns (uint256[] memory pullPaymentIDs)
	{
		return _pullPaymentIdsByAddress[_subscriber];
	}

	function getCurrentBillingModelId() external view virtual returns (uint256) {
		return _billingModelIDs.current();
	}

	function getCurrentSubscriptionId() external view virtual returns (uint256) {
		return _subscriptionIDs.current();
	}

	function getCurrentPullPaymentId() external view virtual returns (uint256) {
		return _pullPaymentIDs.current();
	}

	/**
	 * @notice Returns the storage, major, minor, and patch version of the contract.
	 * @return The storage, major, minor, and patch version of the contract.
	 */
	function getVersionNumber()
		external
		pure
		override
		returns (
			uint256,
			uint256,
			uint256,
			uint256
		)
	{
		return (1, 0, 0, 0);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRecurringDynamicPullPayment {
	struct BillingModelData {
		address payee;
		uint8 recurringPPType;
		uint256[] subscriptionIDs;
	}

	struct SubscriptionData {
		address subscriber;
		string bmName;
		uint256 paymentAmount;
		address settlementToken;
		address paymentToken;
		uint256 totalPayments;
		uint256 remainingPayments;
		uint256 frequency;
		uint256 startTimestamp;
		uint256 cancelTimestamp;
		uint256 nextPaymentTimestamp;
		uint256 lastPaymentTimestamp;
		uint256[] pullPaymentIDs;
	}

	struct Data {
		SubscriptionData subscription;
		uint256 trialPeriod;
		uint256 initialAmount;
	}

	function createBillingModel(address _payee, uint8 _recurringPPType)
		external
		returns (uint256 billingModelID);

	function subscribeToBillingModel(
		uint256 _billingModelID,
		string memory _bmName,
		address _settlementToken,
		address _paymentToken,
		uint256 _paymentAmount,
		uint256 _frequency,
		uint256 _totalPayments,
		uint256 _trialPeriod,
		uint256 _initialAMount
	) external returns (uint256 subscriptionID);

	function executePullPayment(uint256 _subscriptionID) external returns (uint256);

	function cancelSubscription(uint256 _subscriptionID) external returns (uint256);

	function editBillingModel(uint256 _billingModelID, address _newPayee) external returns (uint256);

	function getBillingModel(uint256 _billingModelID) external view returns (BillingModelData memory);

	function getSubscription(uint256 _subscriptionID) external view returns (Data memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVersionedContract {
	/**
	 * @notice Returns the storage, major, minor, and patch version of the contract.
	 * @return The storage, major, minor, and patch version of the contract.
	 */
	function getVersionNumber()
		external
		pure
		returns (
			uint256,
			uint256,
			uint256,
			uint256
		);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ICoreRegistry.sol';
import './IPullPaymentConfig.sol';

interface IRegistry is ICoreRegistry, IPullPaymentConfig {
	function getPMAToken() external view returns (address);

	function getWBNBToken() external view returns (address);

	function getFreezer() external view returns (address);

	function getExecutor() external view returns (address);

	function getUniswapFactory() external view returns (address);

	function getUniswapPair() external view returns (address);

	function getUniswapRouter() external view returns (address);

	function getPullPaymentRegistry() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPullPaymentRegistry {
	function grantExecutor(address _executor) external;

	function revokeExecutor(address _executor) external;

	function addPullPaymentContract(string calldata _identifier, address _addr) external;

	function getPPAddressForOrDie(bytes32 _identifierHash) external view returns (address);

	function getPPAddressFor(bytes32 _identifierHash) external view returns (address);

	function getPPAddressForStringOrDie(string calldata _identifier) external view returns (address);

	function getPPAddressForString(string calldata _identifier) external view returns (address);

	function isExecutorGranted(address _executor) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPullPaymentConfig {
	function getSupportedTokens() external view returns (address[] memory);

	function isSupportedToken(address _tokenAddress) external view returns (bool isExists);

	function executionFeeReceiver() external view returns (address);

	function executionFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExecutor {
	function execute(
		address,
		address,
		address,
		address,
		uint256
	) external returns (bool);

	function execute(string calldata _bmType, uint256 _subscriptionId) external returns (uint256);
	//    function executePullPayment(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoreRegistry {
	function setAddressFor(string calldata, address) external;

	function getAddressForOrDie(bytes32) external view returns (address);

	function getAddressFor(bytes32) external view returns (address);

	function isOneOf(bytes32[] calldata, address) external view returns (bool);

	}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import './interfaces/IRegistry.sol';

contract RegistryHelper is OwnableUpgradeable {
	/*
   	=======================================================================
   	======================== Public variatibles ===========================
   	=======================================================================
 	*/
	IRegistry public registry;

	/*
   	=======================================================================
   	======================== Constructor/Initializer ======================
   	=======================================================================
 	*/
	/**
	 * @notice Used in place of the constructor to allow the contract to be upgradable via proxy.
	 */
	function _init_registryHelper(address _registryAddress) internal virtual onlyInitializing {
		__Ownable_init();
		setRegistry(_registryAddress);
	}

	/*
   	=======================================================================
   	======================== Events =======================================
 	=======================================================================
 	*/
	event RegistrySet(address indexed registryAddress);

	/*
   	=======================================================================
   	======================== Public Methods ===============================
   	=======================================================================
 	*/

	/**
	 * @notice Updates the address pointing to a Registry contract.
	 * @param registryAddress The address of a registry contract for routing to other contracts.
	 */
	function setRegistry(address registryAddress) public virtual onlyOwner {
		require(registryAddress != address(0), 'RegistryHelper: CANNOT_REGISTER_ZERO_ADDRESS');
		registry = IRegistry(registryAddress);
		emit RegistrySet(registryAddress);
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}