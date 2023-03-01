// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "@opengsn/contracts/src/BaseRelayRecipient.sol";


import "../interfaces/ICaskSubscriptionManager.sol";
import "../interfaces/ICaskSubscriptions.sol";
import "../interfaces/ICaskSubscriptionPlans.sol";

contract CaskSubscriptions is
ICaskSubscriptions,
BaseRelayRecipient,
ERC721Upgradeable,
OwnableUpgradeable,
PausableUpgradeable,
ReentrancyGuardUpgradeable
{

    /************************** PARAMETERS **************************/

    /** @dev contract to manage subscription plan definitions. */
    ICaskSubscriptionManager public subscriptionManager;

    /** @dev contract to manage subscription plan definitions. */
    ICaskSubscriptionPlans public subscriptionPlans;


    /************************** STATE **************************/

    /** @dev Maps for consumer to list of subscriptions. */
    mapping(address => uint256[]) private consumerSubscriptions; // consumer => subscriptionId[]
    mapping(uint256 => Subscription) private subscriptions; // subscriptionId => Subscription
    mapping(uint256 => bytes32) private pendingPlanChanges; // subscriptionId => planData

    /** @dev Maps for provider to list of subscriptions and plans. */
    mapping(address => uint256[]) private providerSubscriptions; // provider => subscriptionId[]
    mapping(address => uint256) private providerActiveSubscriptionCount; // provider => count
    mapping(address => mapping(uint32 => uint256)) private planActiveSubscriptionCount; // provider => planId => count
    mapping(address => mapping(address => mapping(uint32 => uint256))) private consumerProviderPlanActiveCount;

    modifier onlyManager() {
        require(_msgSender() == address(subscriptionManager), "!AUTH");
        _;
    }

    modifier onlySubscriber(uint256 _subscriptionId) {
        require(_msgSender() == ownerOf(_subscriptionId), "!AUTH");
        _;
    }

    modifier onlySubscriberOrProvider(uint256 _subscriptionId) {
        require(
            _msgSender() == ownerOf(_subscriptionId) ||
            _msgSender() == subscriptions[_subscriptionId].provider,
            "!AUTH"
        );
        _;
    }

    function initialize(
        address _subscriptionPlans
    ) public initializer {
        __Ownable_init();
        __Pausable_init();
        __ERC721_init("Cask Subscriptions","CASKSUBS");

        subscriptionPlans = ICaskSubscriptionPlans(_subscriptionPlans);
    }
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function versionRecipient() public pure override returns(string memory) { return "2.2.0"; }

    function _msgSender() internal view override(ContextUpgradeable, BaseRelayRecipient)
    returns (address sender) {
        sender = BaseRelayRecipient._msgSender();
    }

    function _msgData() internal view override(ContextUpgradeable, BaseRelayRecipient)
    returns (bytes calldata) {
        return BaseRelayRecipient._msgData();
    }


    function tokenURI(uint256 _subscriptionId) public view override returns (string memory) {
        require(_exists(_subscriptionId), "ERC721Metadata: URI query for nonexistent token");

        Subscription memory subscription = subscriptions[_subscriptionId];

        return string(abi.encodePacked("ipfs://", subscription.cid));
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _subscriptionId
    ) internal override {
        if (_from != address(0) && _to != address(0)) { // only non-mint/burn transfers
            Subscription storage subscription = subscriptions[_subscriptionId];

            PlanInfo memory planInfo = _parsePlanData(subscription.planData);
            require(planInfo.canTransfer, "!NOT_TRANSFERRABLE");

            require(subscription.minTermAt == 0 || uint32(block.timestamp) >= subscription.minTermAt, "!MIN_TERM");

            // on transfer, set subscription to cancel at next renewal until new owner accepts subscription
            subscription.cancelAt = subscription.renewAt;
            consumerSubscriptions[_to].push(_subscriptionId);
        }
    }

    /************************** SUBSCRIPTION METHODS **************************/

    function createNetworkSubscription(
        uint256 _nonce,
        bytes32[] calldata _planProof,  // [provider, ref, planData, merkleRoot, merkleProof...]
        bytes32[] calldata _discountProof, // [discountCodeProof, discountData, merkleRoot, merkleProof...]
        bytes32 _networkData,
        uint32 _cancelAt,
        bytes memory _providerSignature,
        bytes memory _networkSignature,
        string calldata _cid
    ) external override nonReentrant whenNotPaused {
        uint256 subscriptionId = _createSubscription(_nonce, _planProof, _discountProof, _cancelAt,
            _providerSignature, _cid);

        _verifyNetworkData(_networkData, _networkSignature);

        Subscription storage subscription = subscriptions[subscriptionId];
        subscription.networkData = _networkData;
    }

    function createSubscription(
        uint256 _nonce,
        bytes32[] calldata _planProof, // [provider, ref, planData, merkleRoot, merkleProof...]
        bytes32[] calldata _discountProof, // [discountCodeProof, discountData, merkleRoot, merkleProof...]
        uint32 _cancelAt,
        bytes memory _providerSignature,
        string calldata _cid
    ) external override nonReentrant whenNotPaused {
        _createSubscription(_nonce, _planProof, _discountProof, _cancelAt, _providerSignature, _cid);
    }

    function attachData(
        uint256 _subscriptionId,
        string calldata _dataCid
    ) external override onlySubscriberOrProvider(_subscriptionId) whenNotPaused {
        Subscription storage subscription = subscriptions[_subscriptionId];
        require(subscription.status != SubscriptionStatus.Canceled, "!CANCELED");
        subscription.dataCid = _dataCid;
    }

    function changeSubscriptionPlan(
        uint256 _subscriptionId,
        uint256 _nonce,
        bytes32[] calldata _planProof,  // [provider, ref, planData, merkleRoot, merkleProof...]
        bytes32[] calldata _discountProof, // [discountCodeProof, discountData, merkleRoot, merkleProof...]
        bytes memory _providerSignature,
        string calldata _cid
    ) external override onlySubscriber(_subscriptionId) whenNotPaused {
        _changeSubscriptionPlan(_subscriptionId, _nonce, _planProof, _discountProof, _providerSignature, _cid);
    }

    function pauseSubscription(
        uint256 _subscriptionId
    ) external override onlySubscriberOrProvider(_subscriptionId) whenNotPaused {

        Subscription storage subscription = subscriptions[_subscriptionId];

        require(subscription.status != SubscriptionStatus.Paused &&
                subscription.status != SubscriptionStatus.PastDue &&
                subscription.status != SubscriptionStatus.Canceled &&
                subscription.status != SubscriptionStatus.Trialing, "!INVALID(status)");

        require(subscription.minTermAt == 0 || uint32(block.timestamp) >= subscription.minTermAt, "!MIN_TERM");

        PlanInfo memory planInfo = _parsePlanData(subscription.planData);
        require(planInfo.canPause, "!NOT_PAUSABLE");

        subscription.status = SubscriptionStatus.PendingPause;

        emit SubscriptionPendingPause(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
            subscription.ref, subscription.planId);
    }

    function resumeSubscription(
        uint256 _subscriptionId
    ) external override onlySubscriber(_subscriptionId) whenNotPaused {

        Subscription storage subscription = subscriptions[_subscriptionId];

        require(subscription.status == SubscriptionStatus.Paused ||
                subscription.status == SubscriptionStatus.PendingPause, "!NOT_PAUSED");

        emit SubscriptionResumed(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
            subscription.ref, subscription.planId);

        if (subscription.status == SubscriptionStatus.PendingPause) {
            subscription.status = SubscriptionStatus.Active;
            return;
        }

        PlanInfo memory planInfo = _parsePlanData(subscription.planData);

        require(planInfo.maxActive == 0 ||
            planActiveSubscriptionCount[subscription.provider][planInfo.planId] < planInfo.maxActive, "!MAX_ACTIVE");

        subscription.status = SubscriptionStatus.Active;

        providerActiveSubscriptionCount[subscription.provider] += 1;
        planActiveSubscriptionCount[subscription.provider][subscription.planId] += 1;
        consumerProviderPlanActiveCount[ownerOf(_subscriptionId)][subscription.provider][subscription.planId] += 1;

        // if renewal date has already passed, set it to now so consumer is not charged for the time it was paused
        if (subscription.renewAt < uint32(block.timestamp)) {
            subscription.renewAt = uint32(block.timestamp);
        }

        // re-register subscription with manager
        subscriptionManager.renewSubscription(_subscriptionId);

        // make sure still active if payment was required to resume
        require(subscription.status == SubscriptionStatus.Active, "!INSUFFICIENT_FUNDS");
    }

    function cancelSubscription(
        uint256 _subscriptionId,
        uint32 _cancelAt
    ) external override onlySubscriberOrProvider(_subscriptionId) whenNotPaused {

        Subscription storage subscription = subscriptions[_subscriptionId];

        require(subscription.status != SubscriptionStatus.Canceled, "!INVALID(status)");

        uint32 timestamp = uint32(block.timestamp);

        if(_cancelAt == 0) {
            require(_msgSender() == ownerOf(_subscriptionId), "!AUTH"); // clearing cancel only allowed by subscriber
            subscription.cancelAt = _cancelAt;

            emit SubscriptionPendingCancel(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
                subscription.ref, subscription.planId, _cancelAt);
        } else if(_cancelAt <= timestamp) {
            require(subscription.minTermAt == 0 || timestamp >= subscription.minTermAt, "!MIN_TERM");
            subscription.renewAt = timestamp;
            subscription.cancelAt = timestamp;
            subscriptionManager.renewSubscription(_subscriptionId); // force manager to process cancel
        } else {
            require(subscription.minTermAt == 0 || _cancelAt >= subscription.minTermAt, "!MIN_TERM");
            subscription.cancelAt = _cancelAt;

            emit SubscriptionPendingCancel(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
                subscription.ref, subscription.planId, _cancelAt);
        }
    }

    function managerCommand(
        uint256 _subscriptionId,
        ManagerCommand _command
    ) external override onlyManager whenNotPaused {

        Subscription storage subscription = subscriptions[_subscriptionId];

        uint32 timestamp = uint32(block.timestamp);

        if (_command == ManagerCommand.PlanChange) {
            bytes32 pendingPlanData = pendingPlanChanges[_subscriptionId];
            require(pendingPlanData > 0, "!INVALID(pendingPlanData)");

            PlanInfo memory newPlanInfo = _parsePlanData(pendingPlanData);

            emit SubscriptionChangedPlan(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
                subscription.ref, subscription.planId, newPlanInfo.planId, subscription.discountId);

            subscription.planId = newPlanInfo.planId;
            subscription.planData = pendingPlanData;

            if (newPlanInfo.minPeriods > 0) {
                subscription.minTermAt = timestamp + (newPlanInfo.period * newPlanInfo.minPeriods);
            }

            delete pendingPlanChanges[_subscriptionId]; // free up memory

        } else if (_command == ManagerCommand.Cancel) {
            subscription.status = SubscriptionStatus.Canceled;

            providerActiveSubscriptionCount[subscription.provider] -= 1;
            planActiveSubscriptionCount[subscription.provider][subscription.planId] -= 1;
            if (consumerProviderPlanActiveCount[ownerOf(_subscriptionId)][subscription.provider][subscription.planId] > 0) {
                consumerProviderPlanActiveCount[ownerOf(_subscriptionId)][subscription.provider][subscription.planId] -= 1;
            }

            emit SubscriptionCanceled(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
                subscription.ref, subscription.planId);

            _burn(_subscriptionId);

        } else if (_command == ManagerCommand.Pause) {
            subscription.status = SubscriptionStatus.Paused;

            providerActiveSubscriptionCount[subscription.provider] -= 1;
            planActiveSubscriptionCount[subscription.provider][subscription.planId] -= 1;
            if (consumerProviderPlanActiveCount[ownerOf(_subscriptionId)][subscription.provider][subscription.planId] > 0) {
                consumerProviderPlanActiveCount[ownerOf(_subscriptionId)][subscription.provider][subscription.planId] -= 1;
            }

            emit SubscriptionPaused(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
                subscription.ref, subscription.planId);

        } else if (_command == ManagerCommand.PastDue) {
            subscription.status = SubscriptionStatus.PastDue;

            emit SubscriptionPastDue(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
                subscription.ref, subscription.planId);

        } else if (_command == ManagerCommand.Renew) {
            PlanInfo memory planInfo = _parsePlanData(subscription.planData);

            if (subscription.status == SubscriptionStatus.Trialing) {
                emit SubscriptionTrialEnded(ownerOf(_subscriptionId), subscription.provider,
                    _subscriptionId, subscription.ref, subscription.planId);
            }

            subscription.renewAt = subscription.renewAt + planInfo.period;

            if (subscription.renewAt > timestamp) {
                // leave in current status unless subscription is current
                subscription.status = SubscriptionStatus.Active;
            }

            emit SubscriptionRenewed(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
                subscription.ref, subscription.planId);

        } else if (_command == ManagerCommand.ClearDiscount) {
                    subscription.discountId = 0;
                    subscription.discountData = 0;
        }

    }

    function getSubscription(
        uint256 _subscriptionId
    ) external override view returns (Subscription memory subscription, address currentOwner) {
        subscription = subscriptions[_subscriptionId];
        if (_exists(_subscriptionId)) {
            currentOwner = ownerOf(_subscriptionId);
        } else {
            currentOwner = address(0);
        }
    }

    function getConsumerSubscription(
        address _consumer,
        uint256 _idx
    ) external override view returns(uint256) {
        return consumerSubscriptions[_consumer][_idx];
    }

    function getActiveSubscriptionCount(
        address _consumer,
        address _provider,
        uint32 _planId
    ) external override view returns(uint256) {
        return consumerProviderPlanActiveCount[_consumer][_provider][_planId];
    }

    function getConsumerSubscriptionCount(
        address _consumer
    ) external override view returns (uint256) {
        return consumerSubscriptions[_consumer].length;
    }

    function getProviderSubscription(
        address _provider,
        uint256 _idx
    ) external override view returns(uint256) {
        return providerSubscriptions[_provider][_idx];
    }

    function getProviderSubscriptionCount(
        address _provider,
        bool _includeCanceled,
        uint32 _planId
    ) external override view returns (uint256) {
        if (_includeCanceled) {
            return providerSubscriptions[_provider].length;
        } else {
            if (_planId > 0) {
                return planActiveSubscriptionCount[_provider][_planId];
            } else {
                return providerActiveSubscriptionCount[_provider];
            }
        }
    }

    function getPendingPlanChange(
        uint256 _subscriptionId
    ) external override view returns (bytes32) {
        return pendingPlanChanges[_subscriptionId];
    }

    function _createSubscription(
        uint256 _nonce,
        bytes32[] calldata _planProof,  // [provider, ref, planData, merkleRoot, merkleProof...]
        bytes32[] calldata _discountProof, // [discountCodeProof, discountData, merkleRoot, merkleProof...]
        uint32 _cancelAt,
        bytes memory _providerSignature,
        string calldata _cid
    ) internal returns(uint256) {
        require(_planProof.length >= 4, "!INVALID(planProofLen)");

        // confirms merkleroots are in fact the ones provider committed to
        address provider;
        if (_discountProof.length >= 3) {
            provider = _verifyMerkleRoots(_planProof[0], _nonce, _planProof[3], _discountProof[2], _providerSignature);
        } else {
            provider = _verifyMerkleRoots(_planProof[0], _nonce, _planProof[3], 0, _providerSignature);
        }

        // confirms plan data is included in merkle root
        require(_verifyPlanProof(_planProof), "!INVALID(planProof)");

        // decode planData bytes32 into PlanInfo
        PlanInfo memory planInfo = _parsePlanData(_planProof[2]);

        // generate subscriptionId from plan info and ref
        uint256 subscriptionId = _generateSubscriptionId(_planProof[0], _planProof[1], _planProof[2]);

        require(planInfo.maxActive == 0 ||
            planActiveSubscriptionCount[provider][planInfo.planId] < planInfo.maxActive, "!MAX_ACTIVE");
        require(subscriptionPlans.getPlanStatus(provider, planInfo.planId) ==
            ICaskSubscriptionPlans.PlanStatus.Enabled, "!NOT_ENABLED");

        _safeMint(_msgSender(), subscriptionId);

        Subscription storage subscription = subscriptions[subscriptionId];

        uint32 timestamp = uint32(block.timestamp);

        subscription.provider = provider;
        subscription.planId = planInfo.planId;
        subscription.ref = _planProof[1];
        subscription.planData = _planProof[2];
        subscription.cancelAt = _cancelAt;
        subscription.cid = _cid;
        subscription.createdAt = timestamp;

        if (planInfo.minPeriods > 0) {
            subscription.minTermAt = timestamp + (planInfo.period * planInfo.minPeriods);
        }

        if (planInfo.price == 0) {
            // free plan, never renew to save gas
            subscription.status = SubscriptionStatus.Active;
            subscription.renewAt = 0;
        } else if (planInfo.freeTrial > 0) {
            // if trial period, charge will happen after trial is over
            subscription.status = SubscriptionStatus.Trialing;
            subscription.renewAt = timestamp + planInfo.freeTrial;
        } else {
            // if no trial period, charge now
            subscription.status = SubscriptionStatus.Active;
            subscription.renewAt = timestamp;
        }

        consumerSubscriptions[_msgSender()].push(subscriptionId);
        providerSubscriptions[provider].push(subscriptionId);
        providerActiveSubscriptionCount[provider] += 1;
        planActiveSubscriptionCount[provider][planInfo.planId] += 1;
        consumerProviderPlanActiveCount[_msgSender()][provider][planInfo.planId] += 1;

        (
        subscription.discountId,
        subscription.discountData
        ) = _verifyDiscountProof(ownerOf(subscriptionId), subscription.provider, planInfo.planId, _discountProof);

        subscriptionManager.renewSubscription(subscriptionId); // registers subscription with manager

        require(subscription.status == SubscriptionStatus.Active ||
                subscription.status == SubscriptionStatus.Trialing, "!UNPROCESSABLE");

        emit SubscriptionCreated(ownerOf(subscriptionId), subscription.provider, subscriptionId,
            subscription.ref, subscription.planId, subscription.discountId);

        return subscriptionId;
    }

    function _changeSubscriptionPlan(
        uint256 _subscriptionId,
        uint256 _nonce,
        bytes32[] calldata _planProof,  // [provider, ref, planData, merkleRoot, merkleProof...]
        bytes32[] calldata _discountProof, // [discountCodeProof, discountData, merkleRoot, merkleProof...]
        bytes memory _providerSignature,
        string calldata _cid
    ) internal {
        require(_planProof.length >= 4, "!INVALID(planProof)");

        Subscription storage subscription = subscriptions[_subscriptionId];

        require(subscription.renewAt == 0 || subscription.renewAt > uint32(block.timestamp), "!NEED_RENEWAL");
        require(subscription.status == SubscriptionStatus.Active ||
            subscription.status == SubscriptionStatus.Trialing, "!INVALID(status)");

        // confirms merkleroots are in fact the ones provider committed to
        address provider;
        if (_discountProof.length >= 3) {
            provider = _verifyMerkleRoots(_planProof[0], _nonce, _planProof[3], _discountProof[2], _providerSignature);
        } else {
            provider = _verifyMerkleRoots(_planProof[0], _nonce, _planProof[3], 0, _providerSignature);
        }

        // confirms plan data is included in merkle root
        require(_verifyPlanProof(_planProof), "!INVALID(planProof)");

        // decode planData bytes32 into PlanInfo
        PlanInfo memory newPlanInfo = _parsePlanData(_planProof[2]);

        require(subscription.provider == provider, "!INVALID(provider)");

        subscription.cid = _cid;

        if (subscription.discountId == 0 && _discountProof.length >= 3 && _discountProof[0] > 0) {
            (
            subscription.discountId,
            subscription.discountData
            ) = _verifyDiscountProof(ownerOf(_subscriptionId), subscription.provider,
                newPlanInfo.planId, _discountProof);
        }

        if (subscription.planId != newPlanInfo.planId) {
            require(subscriptionPlans.getPlanStatus(provider, newPlanInfo.planId) ==
                ICaskSubscriptionPlans.PlanStatus.Enabled, "!NOT_ENABLED");
            _performPlanChange(_subscriptionId, newPlanInfo, _planProof[2]);
        }
    }

    function _performPlanChange(
        uint256 _subscriptionId,
        PlanInfo memory _newPlanInfo,
        bytes32 _planData
    ) internal {
        Subscription storage subscription = subscriptions[_subscriptionId];

        PlanInfo memory currentPlanInfo = _parsePlanData(subscription.planData);

        if (subscription.status == SubscriptionStatus.Trialing) { // still in trial, just change now

            // adjust renewal based on new plan trial length
            subscription.renewAt = subscription.renewAt - currentPlanInfo.freeTrial + _newPlanInfo.freeTrial;

            // if new plan trial length would have caused trial to already be over, end trial as of now
            // subscription will be charged and converted to active during next keeper run
            if (subscription.renewAt <= uint32(block.timestamp)) {
                subscription.renewAt = uint32(block.timestamp);
            }

            _swapPlan(_subscriptionId, _newPlanInfo, _planData);

        } else if (_newPlanInfo.price / _newPlanInfo.period ==
            currentPlanInfo.price / currentPlanInfo.period)
        { // straight swap

            _swapPlan(_subscriptionId, _newPlanInfo, _planData);

        } else if (_newPlanInfo.price / _newPlanInfo.period >
            currentPlanInfo.price / currentPlanInfo.period)
        { // upgrade

            _upgradePlan(_subscriptionId, currentPlanInfo, _newPlanInfo, _planData);

        } else { // downgrade - to take affect at next renewal

            _scheduleSwapPlan(_subscriptionId, _newPlanInfo.planId, _planData);
        }
    }

    function _verifyDiscountProof(
        address _consumer,
        address _provider,
        uint32 _planId,
        bytes32[] calldata _discountProof // [discountValidator, discountData, merkleRoot, merkleProof...]
    ) internal returns(bytes32, bytes32) {
        if (_discountProof[0] > 0) {
            bytes32 discountId = subscriptionPlans.verifyAndConsumeDiscount(_consumer, _provider,
                _planId, _discountProof);
            if (discountId > 0)
            {
                return (discountId, _discountProof[1]);
            }
        }
        return (0,0);
    }

    function _verifyPlanProof(
        bytes32[] calldata _planProof // [provider, ref, planData, merkleRoot, merkleProof...]
    ) internal view returns(bool) {
        return subscriptionPlans.verifyPlan(_planProof[2], _planProof[3], _planProof[4:]);
    }

    function _generateSubscriptionId(
        bytes32 _providerAddr,
        bytes32 _ref,
        bytes32 _planData
    ) internal view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(_msgSender(), _providerAddr,
            _planData, _ref, block.number, block.timestamp)));
    }

    function _parsePlanData(
        bytes32 _planData
    ) internal pure returns(PlanInfo memory) {
        bytes1 options = bytes1(_planData << 248);
        return PlanInfo({
            price: uint256(_planData >> 160),
            planId: uint32(bytes4(_planData << 96)),
            period: uint32(bytes4(_planData << 128)),
            freeTrial: uint32(bytes4(_planData << 160)),
            maxActive: uint32(bytes4(_planData << 192)),
            minPeriods: uint16(bytes2(_planData << 224)),
            gracePeriod: uint8(bytes1(_planData << 240)),
            canPause: options & 0x01 == 0x01,
            canTransfer: options & 0x02 == 0x02
        });
    }

    function _parseNetworkData(
        bytes32 _networkData
    ) internal pure returns(NetworkInfo memory) {
        return NetworkInfo({
            network: address(bytes20(_networkData)),
            feeBps: uint16(bytes2(_networkData << 160))
        });
    }

    function _scheduleSwapPlan(
        uint256 _subscriptionId,
        uint32 newPlanId,
        bytes32 _newPlanData
    ) internal {
        Subscription storage subscription = subscriptions[_subscriptionId];

        pendingPlanChanges[_subscriptionId] = _newPlanData;

        emit SubscriptionPendingChangePlan(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
            subscription.ref, subscription.planId, newPlanId);
    }

    function _swapPlan(
        uint256 _subscriptionId,
        PlanInfo memory _newPlanInfo,
        bytes32 _newPlanData
    ) internal {
        Subscription storage subscription = subscriptions[_subscriptionId];

        emit SubscriptionChangedPlan(ownerOf(_subscriptionId), subscription.provider, _subscriptionId,
            subscription.ref, subscription.planId, _newPlanInfo.planId, subscription.discountId);

        if (_newPlanInfo.minPeriods > 0) {
            subscription.minTermAt = uint32(block.timestamp + (_newPlanInfo.period * _newPlanInfo.minPeriods));
        }

        subscription.planId = _newPlanInfo.planId;
        subscription.planData = _newPlanData;
    }

    function _upgradePlan(
        uint256 _subscriptionId,
        PlanInfo memory _currentPlanInfo,
        PlanInfo memory _newPlanInfo,
        bytes32 _newPlanData
    ) internal {
        Subscription storage subscription = subscriptions[_subscriptionId];

        _swapPlan(_subscriptionId, _newPlanInfo, _newPlanData);

        if (_currentPlanInfo.price == 0 && _newPlanInfo.price != 0) {
            // coming from free plan, no prorate
            subscription.renewAt = uint32(block.timestamp);
            subscriptionManager.renewSubscription(_subscriptionId); // register paid plan with manager
            require(subscription.status == SubscriptionStatus.Active, "!UNPROCESSABLE"); // make sure payment processed
        } else {
            // prorated payment now - next renewal will charge new price
            uint256 newAmount = ((_newPlanInfo.price / _newPlanInfo.period) -
                (_currentPlanInfo.price / _currentPlanInfo.period)) *
                (subscription.renewAt - uint32(block.timestamp));
            require(subscriptionManager.processSinglePayment(ownerOf(_subscriptionId), subscription.provider,
                _subscriptionId, newAmount), "!UNPROCESSABLE");
        }

    }


    /************************** ADMIN FUNCTIONS **************************/

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setManager(
        address _subscriptionManager
    ) external onlyOwner {
        subscriptionManager = ICaskSubscriptionManager(_subscriptionManager);
    }

    function setTrustedForwarder(
        address _forwarder
    ) external onlyOwner {
        _setTrustedForwarder(_forwarder);
    }

    function _verifyMerkleRoots(
        bytes32 providerAddr,
        uint256 _nonce,
        bytes32 _planMerkleRoot,
        bytes32 _discountMerkleRoot,
        bytes memory _providerSignature
    ) internal view returns (address) {
        address provider = address(bytes20(providerAddr << 96));
        require(subscriptionPlans.verifyProviderSignature(
                provider,
                _nonce,
                _planMerkleRoot,
                _discountMerkleRoot,
                _providerSignature
        ), "!INVALID(signature)");
        return provider;
    }

    function _verifyNetworkData(
        bytes32 _networkData,
        bytes memory _networkSignature
    ) internal view returns (address) {
        NetworkInfo memory networkInfo = _parseNetworkData(_networkData);
        require(subscriptionPlans.verifyNetworkData(networkInfo.network, _networkData, _networkSignature),
            "!INVALID(networkSignature)");
        return networkInfo.network;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    uint256[44] private __gap;
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
        __Context_init_unchained();
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// solhint-disable no-inline-assembly
pragma solidity >=0.6.9;

import "./interfaces/IRelayRecipient.sol";

/**
 * A base contract to be inherited by any contract that want to receive relayed transactions
 * A subclass must use "_msgSender()" instead of "msg.sender"
 */
abstract contract BaseRelayRecipient is IRelayRecipient {

    /*
     * Forwarder singleton we accept calls from
     */
    address private _trustedForwarder;

    function trustedForwarder() public virtual view returns (address){
        return _trustedForwarder;
    }

    function _setTrustedForwarder(address _forwarder) internal {
        _trustedForwarder = _forwarder;
    }

    function isTrustedForwarder(address forwarder) public virtual override view returns(bool) {
        return forwarder == _trustedForwarder;
    }

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, return the original sender.
     * otherwise, return `msg.sender`.
     * should be used in the contract anywhere instead of msg.sender
     */
    function _msgSender() internal override virtual view returns (address ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            // At this point we know that the sender is a trusted forwarder,
            // so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            assembly {
                ret := shr(96,calldataload(sub(calldatasize(),20)))
            }
        } else {
            ret = msg.sender;
        }
    }

    /**
     * return the msg.data of this call.
     * if the call came through our trusted forwarder, then the real sender was appended as the last 20 bytes
     * of the msg.data - so this method will strip those 20 bytes off.
     * otherwise (if the call was made directly and not through the forwarder), return `msg.data`
     * should be used in the contract instead of msg.data, where this difference matters.
     */
    function _msgData() internal override virtual view returns (bytes calldata ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return msg.data[0:msg.data.length-20];
        } else {
            return msg.data;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaskSubscriptionManager {

    enum CheckType {
        None,
        Active,
        PastDue
    }

    function queueItem(CheckType _checkType, uint32 _bucket, uint256 _idx) external view returns(uint256);

    function queueSize(CheckType _checkType, uint32 _bucket) external view returns(uint256);

    function queuePosition(CheckType _checkType) external view returns(uint32);

    function processSinglePayment(address _consumer, address _provider,
        uint256 _subscriptionId, uint256 _value) external returns(bool);

    function renewSubscription(uint256 _subscriptionId) external;

    /** @dev Emitted when the keeper job performs renewals. */
    event SubscriptionManagerReport(uint256 limit, uint256 renewals, uint256 depth, CheckType checkType,
        uint256 queueRemaining, uint32 currentBucket);

    /** @dev Emitted when manager parameters are changed. */
    event SetParameters();
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./ICaskSubscriptionManager.sol";

interface ICaskSubscriptions is IERC721Upgradeable {

    enum SubscriptionStatus {
        None,
        Trialing,
        Active,
        Paused,
        Canceled,
        PastDue,
        PendingPause
    }

    enum ManagerCommand {
        None,
        PlanChange,
        Cancel,
        PastDue,
        Renew,
        ClearDiscount,
        Pause
    }

    struct Subscription {
        bytes32 planData;
        bytes32 networkData;
        bytes32 discountId;
        bytes32 discountData;
        bytes32 ref;
        address provider;
        SubscriptionStatus status;
        uint32 planId;
        uint32 createdAt;
        uint32 renewAt;
        uint32 minTermAt;
        uint32 cancelAt;
        string cid;
        string dataCid;
    }

    struct PlanInfo {
        uint256 price;
        uint32 planId;
        uint32 period;
        uint32 freeTrial;
        uint32 maxActive;
        uint16 minPeriods;
        uint8 gracePeriod;
        bool canPause;
        bool canTransfer;
    }

    struct NetworkInfo {
        address network;
        uint16 feeBps;
    }

    /************************** SUBSCRIPTION INSTANCE METHODS **************************/

    function createSubscription(
        uint256 _nonce,
        bytes32[] calldata _planProof,
        bytes32[] calldata _discountProof,
        uint32 _cancelAt,
        bytes memory _providerSignature,
        string calldata _cid
    ) external;

    function createNetworkSubscription(
        uint256 _nonce,
        bytes32[] calldata _planProof,
        bytes32[] calldata _discountProof,
        bytes32 _networkData,
        uint32 _cancelAt,
        bytes memory _providerSignature,
        bytes memory _networkSignature,
        string calldata _cid
    ) external;

    function changeSubscriptionPlan(
        uint256 _subscriptionId,
        uint256 _nonce,
        bytes32[] calldata _planProof,
        bytes32[] calldata _discountProof,
        bytes memory _providerSignature,
        string calldata _cid
    ) external;

    function attachData(uint256 _subscriptionId, string calldata _dataCid) external;

    function pauseSubscription(uint256 _subscriptionId) external;

    function resumeSubscription(uint256 _subscriptionId) external;

    function cancelSubscription(uint256 _subscriptionId, uint32 _cancelAt) external;

    function managerCommand(uint256 _subscriptionId, ManagerCommand _command) external;

    function getSubscription(uint256 _subscriptionId) external view returns
        (Subscription memory subscription, address currentOwner);

    function getConsumerSubscription(address _consumer, uint256 _idx) external view returns(uint256);

    function getConsumerSubscriptionCount(address _consumer) external view returns (uint256);

    function getProviderSubscription(address _provider, uint256 _idx) external view returns(uint256);

    function getProviderSubscriptionCount(address _provider, bool _includeCanceled, uint32 _planId) external view returns (uint256);

    function getActiveSubscriptionCount(address _consumer, address _provider, uint32 _planId) external view returns(uint256);

    function getPendingPlanChange(uint256 _subscriptionId) external view returns (bytes32);


    /************************** SUBSCRIPTION EVENTS **************************/

    /** @dev Emitted when `consumer` subscribes to `provider` plan `planId` */
    event SubscriptionCreated(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId, bytes32 discountId);

    /** @dev Emitted when `consumer` changes the plan to `provider` on subscription `subscriptionId` */
    event SubscriptionChangedPlan(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 prevPlanId, uint32 planId, bytes32 discountId);

    /** @dev Emitted when `consumer` changes the plan to `provider` on subscription `subscriptionId` */
    event SubscriptionPendingChangePlan(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 prevPlanId, uint32 planId);

    /** @dev Emitted when `consumer` initiates a pause of the subscription to `provider` on subscription `subscriptionId` */
    event SubscriptionPendingPause(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId);

    /** @dev Emitted when a pending pause subscription attempts to renew but is paused */
    event SubscriptionPaused(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId);

    /** @dev Emitted when `consumer` resumes the subscription to `provider` on subscription `subscriptionId` */
    event SubscriptionResumed(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId);

    /** @dev Emitted when `consumer` unsubscribes to `provider` on subscription `subscriptionId` */
    event SubscriptionPendingCancel(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId, uint32 cancelAt);

    /** @dev Emitted when `consumer` has canceled and the current period is over on subscription `subscriptionId` */
    event SubscriptionCanceled(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId);

    /** @dev Emitted when `consumer` successfully renews to `provider` on subscription `subscriptionId` */
    event SubscriptionRenewed(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId);

    /** @dev Emitted when `consumer` subscription trial ends and goes active to `provider`
     * on subscription `subscriptionId`
     */
    event SubscriptionTrialEnded(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId);

    /** @dev Emitted when `consumer` renewal fails to `provider` on subscription `subscriptionId` */
    event SubscriptionPastDue(address indexed consumer, address indexed provider,
        uint256 indexed subscriptionId, bytes32 ref, uint32 planId);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaskSubscriptionPlans {

    enum PlanStatus {
        Enabled,
        Disabled,
        EndOfLife
    }

    enum DiscountType {
        None,
        Code,
        ERC20
    }

    struct Discount {
        uint256 value;
        uint32 validAfter;
        uint32 expiresAt;
        uint32 maxRedemptions;
        uint32 planId;
        uint16 applyPeriods;
        DiscountType discountType;
        bool isFixed;
    }

    struct Provider {
        address paymentAddress;
        uint256 nonce;
        string cid;
    }

    function setProviderProfile(address _paymentAddress, string calldata _cid, uint256 _nonce) external;

    function getProviderProfile(address _provider) external view returns(Provider memory);

    function getPlanStatus(address _provider, uint32 _planId) external view returns (PlanStatus);

    function getPlanEOL(address _provider, uint32 _planId) external view returns (uint32);

    function disablePlan(uint32 _planId) external;

    function enablePlan(uint32 _planId) external;

    function retirePlan(uint32 _planId, uint32 _retireAt) external;

    function verifyPlan(bytes32 _planData, bytes32 _merkleRoot,
        bytes32[] calldata _merkleProof) external view returns(bool);

    function getDiscountRedemptions(address _provider, uint32 _planId,
        bytes32 _discountId) external view returns(uint256);

    function verifyAndConsumeDiscount(address _consumer, address _provider, uint32 _planId,
        bytes32[] calldata _discountProof) external returns(bytes32);

    function verifyDiscount(address _consumer, address _provider, uint32 _planId,
        bytes32[] calldata _discountProof) external returns(bytes32);

    function erc20DiscountCurrentlyApplies(address _consumer, bytes32 _discountValidator) external returns(bool);

    function verifyProviderSignature(address _provider, uint256 _nonce, bytes32 _planMerkleRoot,
        bytes32 _discountMerkleRoot, bytes memory _providerSignature) external view returns (bool);

    function verifyNetworkData(address _network, bytes32 _networkData,
        bytes memory _networkSignature) external view returns (bool);


    /** @dev Emitted when `provider` sets their profile info */
    event ProviderSetProfile(address indexed provider, address indexed paymentAddress, uint256 nonce, string cid);

    /** @dev Emitted when `provider` disables a subscription plan */
    event PlanDisabled(address indexed provider, uint32 indexed planId);

    /** @dev Emitted when `provider` enables a subscription plan */
    event PlanEnabled(address indexed provider, uint32 indexed planId);

    /** @dev Emitted when `provider` end-of-lifes a subscription plan */
    event PlanRetired(address indexed provider, uint32 indexed planId, uint32 retireAt);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

/**
 * a contract must implement this interface in order to support relayed transaction.
 * It is better to inherit the BaseRelayRecipient as its implementation.
 */
abstract contract IRelayRecipient {

    /**
     * return if the forwarder is trusted to forward relayed transactions to us.
     * the forwarder is required to verify the sender's signature, and verify
     * the call is not a replay.
     */
    function isTrustedForwarder(address forwarder) public virtual view returns(bool);

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, then the real sender is appended as the last 20 bytes
     * of the msg.data.
     * otherwise, return `msg.sender`
     * should be used in the contract anywhere instead of msg.sender
     */
    function _msgSender() internal virtual view returns (address);

    /**
     * return the msg.data of this call.
     * if the call came through our trusted forwarder, then the real sender was appended as the last 20 bytes
     * of the msg.data - so this method will strip those 20 bytes off.
     * otherwise (if the call was made directly and not through the forwarder), return `msg.data`
     * should be used in the contract instead of msg.data, where this difference matters.
     */
    function _msgData() internal virtual view returns (bytes calldata);

    function versionRecipient() external virtual view returns (string memory);
}