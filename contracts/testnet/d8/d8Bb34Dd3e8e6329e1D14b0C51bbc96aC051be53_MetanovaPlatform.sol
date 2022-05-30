// SPDX-License-Identifier: GNU Affero General Public License v3.0 only
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

// access control
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

// utility
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

struct Fund {
  uint256 amount;
  bool isLocked;
}

enum FundActionEnum {
  ADD,
  SUB
}

enum ServiceStatusEnum {
  CLOSED,
  ACTIVE
}

enum ClientRequestMatchStatusEnum {
  CLOSED,
  ACTIVE,
  COMPLETED
}

enum ClientRequestStatusEnum {
  CLOSED,
  ACTIVE,
  IN_PROGRESS,
  COMPLETED
}

struct ClientRequest {
  uint256 id;
  bool valid;
  string metadataId;
  address client;
  ClientRequestStatusEnum status;
  uint256 reward;
}
struct ClientRequestMetadata {
  bool valid;
  uint256 clientRequestId;
}

struct ClientRequestMatch {
  bool valid;
  ClientRequestMatchStatusEnum status;
  uint256 clientRequestId;
  uint256 serviceId;
  address client;
  address serviceProvider;
  uint256 reward;
  uint256 tips;
  bool hasClientConfirmedCompletion;
  bool hasServiceProviderConfirmedCompletion;
  bool hasAllowedDisputeHandling;
  bool hasClientConfirmedCancellation;
  bool hasServiceProviderConfirmedCancellation;
  bool hasHandledDispute;
}

struct ServiceMatch {
  uint256 totalNumberOfActiveMatches;
  uint256[] matchedClientRequests;
}

struct ServiceMetadata {
  bool valid;
  uint256 serviceId;
}
struct Service {
  uint256 id;
  bool valid;
  string metadataId;
  address serviceProvider;
  ServiceStatusEnum status;
}

struct ServiceOwnership {
  uint256 totalNumberOfServices;
  uint256[] services;
  mapping(uint256 => bool) serviceOwnership;
  mapping(bytes32 => bool) serviceOwnershipByMetadataId;
}
struct ClientRequestOwnership {
  uint256 totalNumberOfClientRequests;
  uint256[] clientRequests;
  mapping(uint256 => bool) clientRequestOwnership;
  mapping(bytes32 => bool) clientRequestOwnershipByMetadataId;
}

contract MetanovaPlatform is Ownable, AccessControl {
  using SafeMath for uint256;

  bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

  function calculatePortion(uint256 value, uint256 portion) private pure returns (uint256) {
    require(portion <= 1000000000000000000, 'Invalid portion');
    return (value * portion) / 1000000000000000000;
  }

  uint256 MINIMUM_SERVICE_REWARD;
  // PLATFORM_FEE_PORTION: e.g. 250000000000000000 for 25% in uint256 basis points (parts per 1,000,000,000,000,000,000)
  uint256 PLATFORM_FEE_PORTION;
  uint256 DISPUTE_HANDLING_FEE_PORTION;
  uint256 TIPS_PLATFORM_FEE_PORTION;
  address private PLATFORM_FEE_POOL;
  address private DISPUTE_HANDLING_FEE_POOL;

  constructor(
    address basePool,
    uint256 minimumServiceReward,
    uint256 platformFeePortion,
    uint256 disputeHandlingFeePortion,
    uint256 tipsPlatformFeePortion
  ) {
    require(platformFeePortion <= 1000000000000000000 || disputeHandlingFeePortion <= 1000000000000000000, 'Invalid portion');
    // Grant the contract deployer the default admin role: it will be able
    // to grant and revoke any roles
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

    PLATFORM_FEE_POOL = basePool;
    DISPUTE_HANDLING_FEE_POOL = basePool;
    MINIMUM_SERVICE_REWARD = minimumServiceReward;
    PLATFORM_FEE_PORTION = platformFeePortion;
    DISPUTE_HANDLING_FEE_PORTION = disputeHandlingFeePortion;
    TIPS_PLATFORM_FEE_PORTION = tipsPlatformFeePortion;
  }

  // Events
  event HandleMatchDispute(address admin, uint256 _clientRequestId, uint256 refundPotion);
  event WithdrawFund(address user, uint256 amount);
  event CreateClientRequest(address user, string _clientRequestMetadataId, uint256 reward, bool _applyForService, uint256 _serviceId);
  event RaiseClientRequestReward(address user, uint256 _clientRequestId, uint256 amount);
  event CloseClientRequest(address user, uint256 _clientRequestId);
  event CreateService(address user, string _serviceMetadataId, bool _applyForClientRequest, uint256 _clientRequestId);
  event CloseService(address user, uint256 _serviceId);
  event ApplyForService(address user, uint256 _serviceId, uint256 _clientRequestId, bool _hasMatchCreated);
  event ApplyForClientRequest(address user, uint256 _clientRequestId, uint256 _serviceId, bool _hasMatchCreated);
  event CancelServiceApplication(address user, uint256 _serviceId, uint256 _clientRequestId);
  event CancelClientRequestApplication(address user, uint256 _clientRequestId, uint256 _serviceId);
  event AcceptServiceApplication(address user, uint256 _serviceId, uint256 _clientRequestId);
  event AcceptClientRequestApplication(address user, uint256 _clientRequestId, uint256 _serviceId);
  event ConfirmMatchCompletion(address user, uint256 _clientRequestId, bool _hasMatchCompleted);
  event ConfirmMatchCancellation(address user, uint256 _clientRequestId, bool _hasMatchCancelled);
  event RequestForMatchDisputeHandling(address user, uint256 _clientRequestId);
  event GiveTipsToMatch(address user, uint256 _clientRequestId, uint256 amount);

  //
  // -- role related functions: Owner --
  //
  function grantAdminRole(address newAdmin) public onlyOwner {
    _setupRole(ADMIN_ROLE, newAdmin);
  }

  function revokeAdminRole(address user) public onlyOwner {
    revokeRole(ADMIN_ROLE, user);
  }

  function getPlatformFeePool() public view onlyOwner returns (address) {
    return PLATFORM_FEE_POOL;
  }

  function getDisputeHandlingFeePool() public view onlyOwner returns (address) {
    return DISPUTE_HANDLING_FEE_POOL;
  }

  function setPlatformFeePool(address pool) public onlyOwner {
    PLATFORM_FEE_POOL = pool;
  }

  function setDisputeHandlingFeePool(address pool) public onlyOwner {
    DISPUTE_HANDLING_FEE_POOL = pool;
  }

  function setPlatformFeePortion(uint256 platformFeePortion) public onlyOwner {
    require(platformFeePortion <= 1000000000000000000, 'Invalid portion');
    PLATFORM_FEE_PORTION = platformFeePortion;
  }

  function setDisputeHandlingFeePortion(uint256 disputeHandlingFeePortion) public onlyOwner {
    require(disputeHandlingFeePortion <= 1000000000000000000, 'Invalid portion');
    DISPUTE_HANDLING_FEE_PORTION = disputeHandlingFeePortion;
  }

  //
  // -- role related functions: Admin --
  //

  // refundPortion in uint256 basis points (parts per 1,000,000,000,000,000,000)
  function handleMatchDispute(uint256 _clientRequestId, uint256 refundPotion) public onlyRole(ADMIN_ROLE) {
    // params: clientRequestId
    require(clientRequestMatchRecords[_clientRequestId].valid, 'Invalid match');
    require(clientRequestMatchRecords[_clientRequestId].status == ClientRequestMatchStatusEnum.ACTIVE, 'Unauthorized action');
    require(clientRequestMatchRecords[_clientRequestId].hasAllowedDisputeHandling, 'Unauthorized action');
    ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[_clientRequestId];
    // based on refundPotion to proceed certain action

    // retrieve platform fee
    uint256 platformFee = calculatePortion(clientRequestMatch.reward, DISPUTE_HANDLING_FEE_PORTION);
    Fund storage freezedFundRecord = freezedFunds[clientRequestMatch.client];
    (bool success, ) = DISPUTE_HANDLING_FEE_POOL.call{value: platformFee}('');
    require(success, 'Transfer failed');
    safeFundModifier(freezedFundRecord, platformFee, FundActionEnum.SUB);
    // handle post-platformFee funds
    uint256 postPlatformFee = clientRequestMatch.reward.sub(platformFee);
    uint256 refundValue = calculatePortion(postPlatformFee, refundPotion);
    uint256 remainingReward = postPlatformFee.sub(refundValue);
    // refund to client
    safeTransferFundsFromFreezedToWithdrawable(clientRequestMatch.client, clientRequestMatch.client, refundValue);
    // forward to service provider
    safeTransferFundsFromFreezedToWithdrawable(clientRequestMatch.client, clientRequestMatch.serviceProvider, remainingReward);
    // update client request match record
    clientRequestMatch.status = ClientRequestMatchStatusEnum.COMPLETED;
    clientRequestMatch.hasHandledDispute = true;
    clientRequestRecords[clientRequestMatch.clientRequestId].status = ClientRequestStatusEnum.COMPLETED;
    // update service match record
    serviceMatchRecords[clientRequestMatch.serviceId].totalNumberOfActiveMatches--;

    emit HandleMatchDispute(msg.sender, _clientRequestId, refundPotion);
  }

  // ----- Core Platform Interactions -----

  //
  // @@Fund Management
  //
  mapping(address => Fund) freezedFunds;
  mapping(address => Fund) withdrawableFunds;

  function getMinimumServiceReward() public view returns (uint256) {
    return MINIMUM_SERVICE_REWARD;
  }

  function getTipsPlatformFeePortion() public view returns (uint256) {
    return TIPS_PLATFORM_FEE_PORTION;
  }

  function getPlatformFeePortion() public view returns (uint256) {
    return PLATFORM_FEE_PORTION;
  }

  function getDisputeHandlingFeePortion() public view returns (uint256) {
    return DISPUTE_HANDLING_FEE_PORTION;
  }

  function getFreezedBalance() public view returns (uint256) {
    return freezedFunds[msg.sender].amount;
  }

  function getWithdrawableBalance() public view returns (uint256) {
    return withdrawableFunds[msg.sender].amount;
  }

  function safeFundModifier(
    Fund storage fund,
    uint256 value,
    FundActionEnum action
  ) private {
    // prohibit any action when fund is locked
    require(!fund.isLocked, 'Unauthorized action');

    // lock fund before action
    fund.isLocked = true;
    if (action == FundActionEnum.ADD) {
      fund.amount = fund.amount.add(value);
    } else if (action == FundActionEnum.SUB) {
      fund.amount = fund.amount.sub(value, 'Insufficient balance');
    }
    // unlock fund after action
    fund.isLocked = false;
  }

  function safeTransferFundsFromFreezedToWithdrawable(
    address from,
    address to,
    uint256 transferValue
  ) private {
    Fund storage freezedFundRecord = freezedFunds[from];
    Fund storage withdrawableFundRecord = withdrawableFunds[to];
    require(freezedFundRecord.amount >= transferValue, 'Unauthorized action');
    require(!freezedFundRecord.isLocked, 'Unauthorized action');
    require(!withdrawableFundRecord.isLocked, 'Unauthorized action');

    // lock fund before action
    freezedFundRecord.isLocked = true;
    withdrawableFundRecord.isLocked = true;

    freezedFundRecord.amount = freezedFundRecord.amount.sub(transferValue, 'Insufficient balance');
    withdrawableFundRecord.amount = withdrawableFundRecord.amount.add(transferValue);

    // unlock fund after action
    freezedFundRecord.isLocked = false;
    withdrawableFundRecord.isLocked = false;
  }

  function withdrawFund(uint256 amount) public payable {
    require(withdrawableFunds[msg.sender].amount >= amount, 'Insufficient balance');
    safeFundModifier(withdrawableFunds[msg.sender], amount, FundActionEnum.SUB);
    (bool success, ) = msg.sender.call{value: amount}('');
    require(success, 'Transfer failed');
    emit WithdrawFund(msg.sender, amount);
  }

  //
  // @@Ownership
  //
  mapping(address => ServiceOwnership) serviceOwnershipRecords;
  mapping(address => ClientRequestOwnership) clientRequestOwnershipRecords;

  function getUserServices(address user) public view returns (uint256[] memory) {
    return serviceOwnershipRecords[user].services;
  }

  function validateUserServiceOwnership(address user, uint256 _serviceId) public view returns (bool) {
    return serviceOwnershipRecords[user].serviceOwnership[_serviceId];
  }

  function validateUserServiceOwnershipByMetadataId(address user, string memory _serviceMetadataId) public view returns (bool) {
    return serviceOwnershipRecords[user].serviceOwnershipByMetadataId[keccak256(bytes(_serviceMetadataId))];
  }

  function getUserClientRequests(address user) public view returns (uint256[] memory) {
    return clientRequestOwnershipRecords[user].clientRequests;
  }

  function validateUserClientRequestOwnership(address user, uint256 _clientRequestId) public view returns (bool) {
    return clientRequestOwnershipRecords[user].clientRequestOwnership[_clientRequestId];
  }

  function validateUserClientRequestOwnershipByMetadataId(address user, string memory _clientRequestMetadataId) public view returns (bool) {
    return clientRequestOwnershipRecords[user].clientRequestOwnershipByMetadataId[keccak256(bytes(_clientRequestMetadataId))];
  }

  //
  // @@ClientRequests
  //
  uint256 totalNumberOfClientRequests;
  uint256 totalNumberOfClientRequestApplications;
  mapping(uint256 => ClientRequest) clientRequestRecords;
  // ensure clientRequestMetadataId is unique
  mapping(bytes32 => ClientRequestMetadata) clientRequestMetadataRecords;

  function createClientRequest(
    string memory _clientRequestMetadataId,
    bool _applyForService,
    uint256 _serviceId
  ) public payable {
    // params: clientRequestMetadataId
    bytes32 clientRequestMetadataIdBytes32 = keccak256(bytes(_clientRequestMetadataId));
    require(!clientRequestMetadataRecords[clientRequestMetadataIdBytes32].valid, 'Invalid input');
    require(msg.value > 0, 'Invalid reward amount');
    require(msg.value >= MINIMUM_SERVICE_REWARD, 'Invalid reward amount');

    // Update user freezedFund
    Fund storage freezedFundRecord = freezedFunds[msg.sender];
    safeFundModifier(freezedFundRecord, msg.value, FundActionEnum.ADD);

    // create client request record
    // client request record stores: metadata id, client address, reward amount
    uint256 newClientRequestId = totalNumberOfClientRequests++;
    ClientRequest storage newClientRequest = clientRequestRecords[newClientRequestId];
    newClientRequest.id = newClientRequestId;
    newClientRequest.valid = true;
    newClientRequest.metadataId = _clientRequestMetadataId;
    newClientRequest.client = msg.sender;
    newClientRequest.status = ClientRequestStatusEnum.ACTIVE;
    newClientRequest.reward = msg.value;

    // update clientRequestMetadata
    ClientRequestMetadata storage newClientRequestMetadata = clientRequestMetadataRecords[clientRequestMetadataIdBytes32];
    newClientRequestMetadata.valid = true;
    newClientRequestMetadata.clientRequestId = newClientRequestId;

    // update clientRequest ownership
    ClientRequestOwnership storage userClientRequestOwnershipRecord = clientRequestOwnershipRecords[msg.sender];
    userClientRequestOwnershipRecord.totalNumberOfClientRequests++;
    userClientRequestOwnershipRecord.clientRequests.push(newClientRequestId);
    userClientRequestOwnershipRecord.clientRequestOwnership[newClientRequestId] = true;
    userClientRequestOwnershipRecord.clientRequestOwnershipByMetadataId[clientRequestMetadataIdBytes32] = true;

    if (_applyForService) {
      applyForService(_serviceId, newClientRequestId);
    }
    emit CreateClientRequest(msg.sender, _clientRequestMetadataId, msg.value, _applyForService, _serviceId);
  }

  function raiseClientRequestReward(uint256 _clientRequestId) public payable {
    // params: clientRequestId
    require(msg.value > 0, 'Invalid reward amount');
    require(clientRequestRecords[_clientRequestId].valid, 'Invalid input');
    // user can only raise its own client request
    require(validateUserClientRequestOwnership(msg.sender, _clientRequestId), 'Unauthorized action');
    ClientRequest storage clientRequest = clientRequestRecords[_clientRequestId];
    // can increase reward amount by sending more ether when status is ACTIVE or IN_PROGRESS through this function
    require(
      clientRequest.status == ClientRequestStatusEnum.ACTIVE || clientRequest.status == ClientRequestStatusEnum.IN_PROGRESS,
      'Unauthorized action'
    );

    // Update user freezedFund
    Fund storage freezedFundRecord = freezedFunds[msg.sender];
    safeFundModifier(freezedFundRecord, msg.value, FundActionEnum.ADD);

    // update client request reward field
    clientRequest.reward += msg.value;

    // update client request match reward if matched
    if (clientRequestMatchRecords[clientRequest.id].valid) {
      clientRequestMatchRecords[clientRequest.id].reward += msg.value;
    }
    emit RaiseClientRequestReward(msg.sender, _clientRequestId, msg.value);
  }

  function getClientRequest(uint256 _clientRequestId) public view returns (ClientRequest memory) {
    // params: clientRequestId
    require(clientRequestRecords[_clientRequestId].valid, 'Invalid input');
    // get a specific client request record through id
    return clientRequestRecords[_clientRequestId];
  }

  function getClientRequestByMetadataId(string memory _clientRequestMetadataId) public view returns (ClientRequest memory) {
    // params: clientRequestMetadataId
    require(clientRequestMetadataRecords[keccak256(bytes(_clientRequestMetadataId))].valid, 'Invalid input');
    // get a specific client request record through metadataId
    return clientRequestRecords[clientRequestMetadataRecords[keccak256(bytes(_clientRequestMetadataId))].clientRequestId];
  }

  function closeClientRequest(uint256 _clientRequestId) public {
    // params: clientRequestId
    require(clientRequestRecords[_clientRequestId].valid, 'Invalid input');
    require(validateUserClientRequestOwnership(msg.sender, _clientRequestId), 'Unauthorized action');
    ClientRequest storage clientRequest = clientRequestRecords[_clientRequestId];
    // close client request if its status is ACTIVE
    require(clientRequest.status == ClientRequestStatusEnum.ACTIVE, 'Unauthorized action');

    // transfer fund from freezed to withdrawable
    safeTransferFundsFromFreezedToWithdrawable(msg.sender, msg.sender, clientRequest.reward);
    // update status
    clientRequest.status = ClientRequestStatusEnum.CLOSED;
    emit CloseClientRequest(msg.sender, _clientRequestId);
  }

  //
  // @@Service
  //
  uint256 totalNumberOfServices;
  uint256 totalNumOfServiceApplications;
  mapping(uint256 => Service) serviceRecords;
  mapping(bytes32 => ServiceMetadata) serviceMetadataRecords;

  function createService(
    string memory _serviceMetadataId,
    bool _applyForClientRequest,
    uint256 _clientRequestId
  ) public {
    // params: serviceMetadataId
    bytes32 serviceMetadataIdBytes32 = keccak256(bytes(_serviceMetadataId));
    require(!serviceMetadataRecords[serviceMetadataIdBytes32].valid, 'Invalid input');
    // create service record: metadata id, service provider address, status
    uint256 newServiceId = totalNumberOfServices++;
    Service storage newService = serviceRecords[newServiceId];
    newService.id = newServiceId;
    newService.valid = true;
    newService.metadataId = _serviceMetadataId;
    newService.serviceProvider = msg.sender;
    newService.status = ServiceStatusEnum.ACTIVE;

    // update serviceMetadata
    ServiceMetadata storage newServiceMetadata = serviceMetadataRecords[serviceMetadataIdBytes32];
    newServiceMetadata.valid = true;
    newServiceMetadata.serviceId = newServiceId;

    // update service ownership
    ServiceOwnership storage userServiceOwnershipRecord = serviceOwnershipRecords[msg.sender];
    userServiceOwnershipRecord.totalNumberOfServices++;
    userServiceOwnershipRecord.services.push(newServiceId);
    userServiceOwnershipRecord.serviceOwnership[newServiceId] = true;
    userServiceOwnershipRecord.serviceOwnershipByMetadataId[serviceMetadataIdBytes32] = true;

    if (_applyForClientRequest) {
      applyForClientRequest(_clientRequestId, newServiceId);
    }

    emit CreateService(msg.sender, _serviceMetadataId, _applyForClientRequest, _clientRequestId);
  }

  function getService(uint256 _serviceId) public view returns (Service memory) {
    // params: serviceId
    require(serviceRecords[_serviceId].valid, 'Invalid input');
    // get a specific service through id
    return serviceRecords[_serviceId];
  }

  function getServiceByMetadataId(string memory _serviceMetadataId) public view returns (Service memory) {
    // params: serviceMetadataId
    require(serviceMetadataRecords[keccak256(bytes(_serviceMetadataId))].valid, 'Invalid input');
    // get a specific service through id
    return serviceRecords[serviceMetadataRecords[keccak256(bytes(_serviceMetadataId))].serviceId];
  }

  function closeService(uint256 _serviceId) public {
    // params: serviceId
    require(serviceRecords[_serviceId].valid, 'Invalid input');
    require(validateUserServiceOwnership(msg.sender, _serviceId), 'Unauthorized action');

    Service storage service = serviceRecords[_serviceId];
    require(serviceRecords[_serviceId].status == ServiceStatusEnum.ACTIVE, 'Unauthorized action');

    require(serviceMatchRecords[_serviceId].totalNumberOfActiveMatches == 0, 'Unauthorized action');

    service.status = ServiceStatusEnum.CLOSED;

    emit CloseService(msg.sender, _serviceId);
  }

  //
  // @@Application
  //
  // serviceId -> map clientRequestId -> valid?
  mapping(uint256 => mapping(uint256 => bool)) serviceApplicationRecords;
  // clientRequestId -> map serviceId -> valid?
  mapping(uint256 => mapping(uint256 => bool)) clientRequestApplicationRecords;

  function validateServiceApplication(uint256 _serviceId, uint256 _clientRequestId) public view returns (bool) {
    return serviceApplicationRecords[_serviceId][_clientRequestId];
  }

  function validateClientRequestApplication(uint256 _clientRequestId, uint256 _serviceId) public view returns (bool) {
    return clientRequestApplicationRecords[_clientRequestId][_serviceId];
  }

  function applyForService(uint256 _serviceId, uint256 _clientRequestId) public {
    // params: serviceId, clientRequestId
    // service must be active
    Service storage service = serviceRecords[_serviceId];
    require(service.valid, 'Invalid input');
    require(service.status == ServiceStatusEnum.ACTIVE, 'Invalid service');
    // user cannot apply its own service
    require(!validateUserServiceOwnership(msg.sender, _serviceId), 'Unauthorized action');
    // clientRequest must be active
    ClientRequest storage clientRequest = clientRequestRecords[_clientRequestId];
    require(clientRequest.valid, 'Invalid input');
    require(clientRequest.status == ClientRequestStatusEnum.ACTIVE, 'Invalid client request');
    // user must apply service using its own clientRequest
    require(validateUserClientRequestOwnership(msg.sender, _clientRequestId), 'Unauthorized action');
    // not allow duplicated application
    require(!validateServiceApplication(_serviceId, _clientRequestId), 'Unauthorized action');

    // if target service already applied to user's client request, create match directly
    if (validateClientRequestApplication(_clientRequestId, _serviceId)) {
      // create ClientRequestMatch record
      ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[clientRequest.id];
      clientRequestMatch.valid = true;
      clientRequestMatch.status = ClientRequestMatchStatusEnum.ACTIVE;
      clientRequestMatch.clientRequestId = clientRequest.id;
      clientRequestMatch.client = clientRequest.client;
      clientRequestMatch.serviceId = service.id;
      clientRequestMatch.serviceProvider = service.serviceProvider;
      clientRequestMatch.reward = clientRequest.reward;
      clientRequestMatch.hasHandledDispute = false;
      // update ServiceMatch record
      ServiceMatch storage serviceMatch = serviceMatchRecords[_serviceId];
      serviceMatch.totalNumberOfActiveMatches++;
      serviceMatch.matchedClientRequests.push(_clientRequestId);
      // update client request status
      clientRequest.status = ClientRequestStatusEnum.IN_PROGRESS;
    } else {
      serviceApplicationRecords[_serviceId][_clientRequestId] = true;
    }
    emit ApplyForService(msg.sender, _serviceId, _clientRequestId, validateClientRequestApplication(_clientRequestId, _serviceId));
  }

  function applyForClientRequest(uint256 _clientRequestId, uint256 _serviceId) public {
    // params: clientRequestId, serviceId
    // clientRequest must be active
    ClientRequest storage clientRequest = clientRequestRecords[_clientRequestId];
    require(clientRequest.valid, 'Invalid input');
    require(clientRequest.status == ClientRequestStatusEnum.ACTIVE, 'Invalid client request');
    // user cannot apply its own client request
    require(!validateUserClientRequestOwnership(msg.sender, _clientRequestId), 'Unauthorized action');
    // service must be active
    Service storage service = serviceRecords[_serviceId];
    require(service.valid, 'Invalid input');
    require(service.status == ServiceStatusEnum.ACTIVE, 'Invalid service');
    // user must apply clientRequest using its own service
    require(validateUserServiceOwnership(msg.sender, _serviceId), 'Unauthorized action');
    // not allow duplicated application
    require(!clientRequestApplicationRecords[_clientRequestId][_serviceId], 'Unauthorized action');

    // if target client request already applied to user's service, create match directly
    // TODO: test cases
    if (validateServiceApplication(_serviceId, _clientRequestId)) {
      // create ClientRequestMatch record
      ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[clientRequest.id];
      clientRequestMatch.valid = true;
      clientRequestMatch.status = ClientRequestMatchStatusEnum.ACTIVE;
      clientRequestMatch.clientRequestId = clientRequest.id;
      clientRequestMatch.client = clientRequest.client;
      clientRequestMatch.serviceId = service.id;
      clientRequestMatch.serviceProvider = service.serviceProvider;
      clientRequestMatch.reward = clientRequest.reward;
      // update ServiceMatch record
      ServiceMatch storage serviceMatch = serviceMatchRecords[_serviceId];
      serviceMatch.totalNumberOfActiveMatches++;
      serviceMatch.matchedClientRequests.push(_clientRequestId);
      // update client request status
      clientRequest.status = ClientRequestStatusEnum.IN_PROGRESS;
    } else {
      // create client request application if its status is ACTIVE
      clientRequestApplicationRecords[_clientRequestId][_serviceId] = true;
    }

    emit ApplyForClientRequest(msg.sender, _clientRequestId, _serviceId, validateServiceApplication(_serviceId, _clientRequestId));
  }

  function cancelServiceApplication(uint256 _serviceId, uint256 _clientRequestId) public {
    // params: serviceId, clientRequestId
    // service must be active
    Service storage service = serviceRecords[_serviceId];
    require(service.valid, 'Invalid input');
    require(service.status == ServiceStatusEnum.ACTIVE, 'Invalid service');
    // user cannot apply its own service
    require(!validateUserServiceOwnership(msg.sender, _serviceId), 'Unauthorized action');
    // clientRequest must be active
    ClientRequest storage clientRequest = clientRequestRecords[_clientRequestId];
    require(clientRequest.valid, 'Invalid input');
    require(clientRequest.status == ClientRequestStatusEnum.ACTIVE, 'Invalid client request');
    // user must apply service using its own clientRequest
    require(validateUserClientRequestOwnership(msg.sender, _clientRequestId), 'Unauthorized action');
    // must applied before
    require(serviceApplicationRecords[_serviceId][_clientRequestId], 'Unauthorized action');
    // update to false
    serviceApplicationRecords[_serviceId][_clientRequestId] = false;
    emit CancelServiceApplication(msg.sender, _serviceId, _clientRequestId);
  }

  function cancelClientRequestApplication(uint256 _clientRequestId, uint256 _serviceId) public {
    // params: clientRequestId, serviceId
    // clientRequest must be active
    require(clientRequestRecords[_clientRequestId].valid, 'Invalid input');
    require(clientRequestRecords[_clientRequestId].status == ClientRequestStatusEnum.ACTIVE, 'Invalid client request');
    // user cannot apply its own client request
    require(!validateUserClientRequestOwnership(msg.sender, _clientRequestId), 'Unauthorized action');
    // service must be active
    require(serviceRecords[_serviceId].valid, 'Invalid input');
    require(serviceRecords[_serviceId].status == ServiceStatusEnum.ACTIVE, 'Invalid service');
    // user must apply clientRequest using its own service
    require(validateUserServiceOwnership(msg.sender, _serviceId), 'Unauthorized action');
    // must applied before
    require(clientRequestApplicationRecords[_clientRequestId][_serviceId], 'Unauthorized action');
    // update to false
    clientRequestApplicationRecords[_clientRequestId][_serviceId] = false;
    emit CancelClientRequestApplication(msg.sender, _clientRequestId, _serviceId);
  }

  // @@Match
  mapping(uint256 => ClientRequestMatch) clientRequestMatchRecords;
  mapping(uint256 => ServiceMatch) serviceMatchRecords;

  function getClientRequestMatch(uint256 _clientRequestId) public view returns (ClientRequestMatch memory) {
    // params: clientRequestId
    return clientRequestMatchRecords[_clientRequestId];
  }

  function getServiceMatch(uint256 _serviceId) public view returns (ServiceMatch memory) {
    // params: matchId
    return serviceMatchRecords[_serviceId];
  }

  function acceptServiceApplication(uint256 _serviceId, uint256 _clientRequestId) public {
    // params: serviceId, clientRequestId
    // client request must not have any match
    require(!clientRequestMatchRecords[_clientRequestId].valid, 'Unauthorized action');
    // service must be active
    Service storage service = serviceRecords[_serviceId];
    require(service.valid, 'Invalid input');
    require(service.status == ServiceStatusEnum.ACTIVE, 'Invalid service');
    // user can only accept application of its own service
    require(validateUserServiceOwnership(msg.sender, _serviceId), 'Unauthorized action');

    // check if there are service application of this client request
    require(validateServiceApplication(_serviceId, _clientRequestId), 'Unauthorized action');
    // clientRequest must be active
    ClientRequest storage clientRequest = clientRequestRecords[_clientRequestId];
    require(clientRequest.valid, 'Invalid input');
    require(clientRequest.status == ClientRequestStatusEnum.ACTIVE, 'Invalid client request');
    // create ClientRequestMatch record
    ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[clientRequest.id];
    clientRequestMatch.valid = true;
    clientRequestMatch.status = ClientRequestMatchStatusEnum.ACTIVE;
    clientRequestMatch.clientRequestId = clientRequest.id;
    clientRequestMatch.client = clientRequest.client;
    clientRequestMatch.serviceId = service.id;
    clientRequestMatch.serviceProvider = service.serviceProvider;
    clientRequestMatch.reward = clientRequest.reward;
    // update ServiceMatch record
    ServiceMatch storage serviceMatch = serviceMatchRecords[_serviceId];
    serviceMatch.totalNumberOfActiveMatches++;
    serviceMatch.matchedClientRequests.push(_clientRequestId);
    // update client request status
    clientRequest.status = ClientRequestStatusEnum.IN_PROGRESS;
    emit AcceptServiceApplication(msg.sender, _serviceId, _clientRequestId);
  }

  function acceptClientRequestApplication(uint256 _clientRequestId, uint256 _serviceId) public {
    // params: clientRequestId, serviceId
    require(serviceRecords[_serviceId].valid, 'Invalid input');
    require(clientRequestRecords[_clientRequestId].valid, 'Invalid input');
    // client request must not have any match
    require(!clientRequestMatchRecords[_clientRequestId].valid, 'Unauthorized action');
    // clientRequest must be active currently
    ClientRequest storage clientRequest = clientRequestRecords[_clientRequestId];
    require(clientRequest.status == ClientRequestStatusEnum.ACTIVE, 'Invalid client request');

    // user can only accept application of its own client request
    require(validateUserClientRequestOwnership(msg.sender, _clientRequestId), 'Unauthorized action');

    // check if there are client requst application of this service
    require(validateClientRequestApplication(_clientRequestId, _serviceId), 'Unauthorized action');
    // service must be active
    Service storage service = serviceRecords[_serviceId];
    require(service.status == ServiceStatusEnum.ACTIVE, 'Invalid service');

    // create ClientRequestMatch record
    ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[clientRequest.id];
    clientRequestMatch.valid = true;
    clientRequestMatch.status = ClientRequestMatchStatusEnum.ACTIVE;
    clientRequestMatch.clientRequestId = clientRequest.id;
    clientRequestMatch.client = clientRequest.client;
    clientRequestMatch.serviceId = service.id;
    clientRequestMatch.serviceProvider = service.serviceProvider;
    clientRequestMatch.reward = clientRequest.reward;
    clientRequestMatch.hasHandledDispute = false;
    // update ServiceMatch record
    ServiceMatch storage serviceMatch = serviceMatchRecords[_serviceId];
    serviceMatch.totalNumberOfActiveMatches++;
    serviceMatch.matchedClientRequests.push(_clientRequestId);
    // update client request status
    clientRequest.status = ClientRequestStatusEnum.IN_PROGRESS;
    emit AcceptClientRequestApplication(msg.sender, _clientRequestId, _serviceId);
  }

  function confirmMatchCompletion(uint256 _clientRequestId) public {
    // params: clientRequestId
    require(clientRequestMatchRecords[_clientRequestId].valid, 'Invalid match');
    require(clientRequestMatchRecords[_clientRequestId].status == ClientRequestMatchStatusEnum.ACTIVE, 'Unauthorized action');

    ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[_clientRequestId];
    require(clientRequestMatch.client == msg.sender || clientRequestMatch.serviceProvider == msg.sender, 'Unauthorized action');
    require(!clientRequestMatch.hasClientConfirmedCompletion || !clientRequestMatch.hasServiceProviderConfirmedCompletion, 'Unauthorized action');

    // if client is calling this function -> money withdraw
    if (clientRequestMatch.client == msg.sender) {
      require(!clientRequestMatch.hasClientConfirmedCompletion, 'Duplicated function call');
      clientRequestMatch.hasClientConfirmedCompletion = true;

      // retrieve platform fee
      uint256 platformFee = calculatePortion(clientRequestMatch.reward, PLATFORM_FEE_PORTION);
      (bool success, ) = PLATFORM_FEE_POOL.call{value: platformFee}('');
      require(success, 'Transfer failed');
      safeFundModifier(freezedFunds[clientRequestMatch.client], platformFee, FundActionEnum.SUB);

      safeTransferFundsFromFreezedToWithdrawable(
        clientRequestMatch.client,
        clientRequestMatch.serviceProvider,
        clientRequestMatch.reward.sub(platformFee)
      );
      // update client request match record status
      clientRequestMatch.status = ClientRequestMatchStatusEnum.COMPLETED;
      // update client request status
      ClientRequest storage clientRequest = clientRequestRecords[clientRequestMatch.clientRequestId];
      clientRequest.status = ClientRequestStatusEnum.COMPLETED;
      // update service match record status
      serviceMatchRecords[clientRequestMatch.serviceId].totalNumberOfActiveMatches--;
    }

    if (clientRequestMatch.serviceProvider == msg.sender) {
      require(!clientRequestMatch.hasServiceProviderConfirmedCompletion, 'Duplicated function call');
      clientRequestMatch.hasServiceProviderConfirmedCompletion = true;
    }

    emit ConfirmMatchCompletion(msg.sender, _clientRequestId, clientRequestMatch.status == ClientRequestMatchStatusEnum.COMPLETED);
  }

  function confirmMatchCancellation(uint256 _clientRequestId) public {
    // params: clientRequestId
    require(clientRequestMatchRecords[_clientRequestId].valid, 'Invalid match');
    require(clientRequestMatchRecords[_clientRequestId].status == ClientRequestMatchStatusEnum.ACTIVE, 'Unauthorized action');

    ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[_clientRequestId];
    require(clientRequestMatch.client == msg.sender || clientRequestMatch.serviceProvider == msg.sender, 'Unauthorized action');
    require(!clientRequestMatch.hasClientConfirmedCancellation || !clientRequestMatch.hasServiceProviderConfirmedCancellation, 'Unauthorized action');

    // if client is calling this function
    if (clientRequestMatch.client == msg.sender) {
      require(!clientRequestMatch.hasClientConfirmedCancellation, 'Duplicated function call');
      clientRequestMatch.hasClientConfirmedCancellation = true;
    }
    if (clientRequestMatch.serviceProvider == msg.sender) {
      require(!clientRequestMatch.hasServiceProviderConfirmedCancellation, 'Duplicated function call');
      clientRequestMatch.hasServiceProviderConfirmedCancellation = true;
    }

    // if both confirmed, transfer fund to service provider, update match & clientRequest status
    if (clientRequestMatch.hasServiceProviderConfirmedCancellation && clientRequestMatch.hasClientConfirmedCancellation) {
      // retrieve one third of the platform fee
      uint256 platformFee = calculatePortion(clientRequestMatch.reward, PLATFORM_FEE_PORTION.div(3));
      (bool success, ) = PLATFORM_FEE_POOL.call{value: platformFee}('');
      require(success, 'Transfer failed');
      safeFundModifier(freezedFunds[clientRequestMatch.client], platformFee, FundActionEnum.SUB);

      safeTransferFundsFromFreezedToWithdrawable(clientRequestMatch.client, clientRequestMatch.client, clientRequestMatch.reward.sub(platformFee));
      // update client request match record status
      clientRequestMatch.status = ClientRequestMatchStatusEnum.CLOSED;
      // update client request status
      ClientRequest storage clientRequest = clientRequestRecords[clientRequestMatch.clientRequestId];
      clientRequest.status = ClientRequestStatusEnum.CLOSED;
      // update service match record status
      serviceMatchRecords[clientRequestMatch.serviceId].totalNumberOfActiveMatches--;
    }
    emit ConfirmMatchCancellation(
      msg.sender,
      _clientRequestId,
      clientRequestMatch.hasServiceProviderConfirmedCancellation && clientRequestMatch.hasClientConfirmedCancellation
    );
  }

  function requestForMatchDisputeHandling(uint256 _clientRequestId) public {
    // params: clientRequestId
    require(clientRequestMatchRecords[_clientRequestId].valid, 'Invalid match');
    require(clientRequestMatchRecords[_clientRequestId].status == ClientRequestMatchStatusEnum.ACTIVE, 'Unauthorized action');

    ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[_clientRequestId];
    require(clientRequestMatch.client == msg.sender || clientRequestMatch.serviceProvider == msg.sender, 'Unauthorized action');
    require(!clientRequestMatch.hasAllowedDisputeHandling, 'Unauthorized action');

    clientRequestMatch.hasAllowedDisputeHandling = true;
    emit RequestForMatchDisputeHandling(msg.sender, _clientRequestId);
  }

  function giveTipsToMatch(uint256 _clientRequestId) public payable {
    // params: clientRequestId
    require(msg.value > 0, 'Invalid tips amount');
    ClientRequestMatch storage clientRequestMatch = clientRequestMatchRecords[_clientRequestId];
    require(clientRequestMatch.valid, 'Invalid match');
    // must call after complete
    require(clientRequestMatch.status == ClientRequestMatchStatusEnum.COMPLETED, 'Unauthorized action');
    // must be client,
    require(clientRequestMatch.client == msg.sender, 'Unauthorized action');
    // update the tips amount, retrieve platform fee, redirect to service provider
    uint256 platformFee = calculatePortion(msg.value, TIPS_PLATFORM_FEE_PORTION);
    (bool success, ) = PLATFORM_FEE_POOL.call{value: platformFee}('');
    require(success, 'Transfer failed');
    clientRequestMatch.tips += msg.value;
    uint256 tips = msg.value.sub(platformFee);
    safeFundModifier(withdrawableFunds[clientRequestMatch.serviceProvider], tips, FundActionEnum.ADD);
    emit GiveTipsToMatch(msg.sender, _clientRequestId, msg.value);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
interface IERC165 {
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