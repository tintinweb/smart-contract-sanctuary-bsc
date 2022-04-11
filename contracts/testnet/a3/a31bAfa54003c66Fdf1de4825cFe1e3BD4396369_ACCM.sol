/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

//Project: metadap.io
//Author: Viet Tran
//Version: 1.5

interface iACCM {

  /**
   * @dev Register a new account
   */
  function registerAccount(
    string calldata phoneNumber
    ) external returns (bool ok);

  /**
   * @dev Deactivate an account
   */
  function deactivateAccount( address walletAddr ) external returns (bool ok);

  /**
   * @dev Activate an account
   */
  function activateAccount( address walletAddr ) external returns (bool ok);

  /**
   * @dev Update account information
   */
  function updateAccountInfor( 
    address walletAddr,
    string calldata name, 
    string calldata phoneNumber,
    string calldata idNumberType,
    string calldata idNumber, 
    bool isKYC
    ) external returns (bool ok);

  /**
   * @dev Listing all account
   */
  function accountListing() external view returns ( uint256 counter, address[] memory);

  /**
   * @dev Exchangable condition
   */
  function isTradableAccount(address walletAddr) external view returns (bool);

  /**
   * @dev Emitted when an account is registered
   */
  event accountRegistered(
      address indexed walletAddr
      );

  /**
   * @dev Emitted when an account is deactived
   */
  event accountDeactivated(
      address indexed walletAddr
      );

  /**
   * @dev Emitted when an account is re-actived
   */
  event accountActivated(
      address indexed walletAddr
      );

  /**
   * @dev Emitted when an account information is updated
   */
  event accountInforUpdated(
      address indexed walletAddr
      );

  /**
   * @dev Emitted when an owner submit a multi-sign transaction
   */
  event SubmitMultiSignTransaction(
      address indexed owner,
      uint indexed txIndex,
      uint32 txCode
  );

  /**
   * @dev Emitted when an owner sign a multi-sign transaction
   */
  event SignMultiSignTx(address indexed owner, uint indexed txIndex);

  /**
   * @dev Emitted when ownerList revoke their sign from a multi-sign transaction
   */
  event RevokeSignature(address indexed owner, uint indexed txIndex);

  /**
   * @dev Emitted when an owner execute a multi-sign transaction
   */
  event ExecuteMultiSignTx(address indexed owner, uint indexed txIndex);

  /**
   * @dev Emitted when an transfer ownership occur
   */
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Emitted when a new owner added
   */
  event addOwner(address indexed newOwner);

  /**
   * @dev Emitted when an owner is revoked
   */
  event revokeOwner(address indexed theOwner);

}

contract ACCM is iACCM {

  struct identity {
      string name;                /* Identity name */
      string phoneNumber;         /* Phone number of the user. */
      string idNumberType;        /* Type of identity card number: ID, Driven license, CCCD, ...*/
      string idNumber;            /* Identity card number or others. */
      bool isRegisted;            /* True if this identity is existence. prevent an address is registed two times*/
      bool isKYC;                 /* True if this identity is successful completed KYC process*/
      bool isActive;              /* True if this identity is active*/
      address grantor;            /* The persion who active/deactive/updateInfo this identity */
      uint256 updatedTime;        /* Time of the update, in days since the UNIX epoch (start of day). */
      uint256 regisTime;          /* Time of the registration, in days since the UNIX epoch (start of day). */
  }
  
  address [] private _accList;
  mapping(address => identity) private _identity;

  // multi-sign transaction structure
  struct multiSignTransaction {
      /*
      txCode = 0: add owner
      txCode = 1: transfer ownership
      txCode = 2: revoked owner
      */
      uint32 txCode;
      address from;
      address to;

      uint256 creationTime;
      uint256 executionTime;
      bool executed;
      uint numSignatures;
  }

  // 30 minutes = 1800 seconds
  uint32 private constant MULTISIGN_TX_TIMEOUT = 1800;
  uint32 private constant MINIMUM_NUM_OWNERS = 3;                   
  // list of ownerList & the minimum number of signatures required for multi-sign transaction 
  address[] private ownerList;
  uint private numSignaturesRequired;

  // owner status
  mapping(address => bool) public isActiveOwner;
  // to check if an address has sign a multi-sign transaction
  mapping(uint => mapping(address => bool)) public isSigned;

  modifier onlyOwner() {
      require(isActiveOwner[msg.sender], "You are not owner");
      _;
  }

  // multi-sign transaction array
  multiSignTransaction[] private multiSignTxs;

  modifier multiSignTx_exists(uint _txIndex) {
      require(_txIndex < multiSignTxs.length, "Transaction does not exist");
      _;
  }

  modifier multiSignTx_have_not_executed(uint _txIndex) {
      require(!multiSignTxs[_txIndex].executed, "Transaction have already executed");
      _;
  }

  modifier i_have_not_signed(uint _txIndex) {
      require(!isSigned[_txIndex][msg.sender], "You have already signed");
      _;
  }

  modifier i_have_signed(uint _txIndex) {
      require(isSigned[_txIndex][msg.sender], "You have not signed");
      _;
  }

  modifier is_time_out(uint _txIndex) {
      require(
        (timeNow() - multiSignTxs[_txIndex].creationTime) <= MULTISIGN_TX_TIMEOUT,
        "Timeout, execution is only valid for less than 30 minutes from the creation time"
      );
      _;
  }

  constructor(address[] memory _owners) public {

    require(_owners.length >= MINIMUM_NUM_OWNERS, "At least 3 ownerList required");

    for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isActiveOwner[owner], "The owner already exists");

            ownerList.push(owner);
            isActiveOwner[owner] = true;

            emit OwnershipTransferred(address(0), owner);
        }

    numSignaturesRequired = _owners.length/2 + 1;
  }

    /**
   * @dev Submit multi-sign transaction 
   */
  function submitMulSigTx(
      uint32 _txCode,
      address _from,
      address _to
  ) public onlyOwner returns (bool){
      require(_txCode <= 2, "Transaction code does not exist");
      uint txIndex = multiSignTxs.length;

      // Audit add tx
      if(_txCode == 0){
          _from = address(0);
      }

      // Audit revoked tx
      if(_txCode == 2){
          _to = address(0);
      }

      multiSignTxs.push(
          multiSignTransaction({
              txCode: _txCode,
              from: _from,
              to: _to,            
              creationTime: timeNow(),
              executionTime: 0,
              executed: false,
              numSignatures: 0
          })
      );

      emit SubmitMultiSignTransaction(msg.sender, txIndex, _txCode);

      return true;
  }

  /**
   * @dev Sign a submitted transaction
   */
  function signMulSigTx(uint _txIndex)
      public
      onlyOwner
      multiSignTx_exists(_txIndex)
      multiSignTx_have_not_executed(_txIndex)
      i_have_not_signed(_txIndex)
      is_time_out(_txIndex)
      returns (bool)
  {
      multiSignTransaction storage multiSignTx = multiSignTxs[_txIndex];
      multiSignTx.numSignatures += 1;
      isSigned[_txIndex][msg.sender] = true;
      emit SignMultiSignTx(msg.sender, _txIndex);
      return true;
  }

  /**
   * @dev Revoke a signature
   */
  function revokeSignature(uint _txIndex)
      public
      onlyOwner
      multiSignTx_exists(_txIndex)
      multiSignTx_have_not_executed(_txIndex)
      i_have_signed(_txIndex)
      is_time_out(_txIndex)
      returns (bool)
  {
      multiSignTransaction storage multiSignTx = multiSignTxs[_txIndex];
      multiSignTx.numSignatures -= 1;
      isSigned[_txIndex][msg.sender] = false;
      emit RevokeSignature(msg.sender, _txIndex);
      return true;
  }

  /**
   * @dev Return total existing multi-sign transactions
   */
  function getMulSigTxCnt() public view returns (uint totalMulSigTxs) {
      return (multiSignTxs.length);
  }

  /**
   * @dev Return number of signature required
   */
  function getNumOfSignatureRequired() public view returns (uint256) {
      return numSignaturesRequired;
  }

  /**
   * @dev Return detail of a multi-sign transaction
   */
  function getMulSigTxByIndex(uint _txIndex)
      public
      view
      returns (
          uint32 txCode,
          address from,
          address to,

          uint256 creationTime,
          uint256 executionTime,
          bool executed,
          uint256 numSignatures
      )
  {
      require(_txIndex < multiSignTxs.length, "Transaction does not exist");
      multiSignTransaction memory multiSignTx = multiSignTxs[_txIndex];
      
      return (
          multiSignTx.txCode,
          multiSignTx.from,
          multiSignTx.to,

          multiSignTx.creationTime,
          multiSignTx.executionTime,
          multiSignTx.executed,
          multiSignTx.numSignatures
      );
  }

  /**
   * @dev Execute a multi-sign transaction
   */
  function executeMulSigTx(uint _txIndex)
      public
      onlyOwner
      multiSignTx_exists(_txIndex)
      multiSignTx_have_not_executed(_txIndex)
      is_time_out(_txIndex)
      returns (bool)
  {
      multiSignTransaction storage multiSignTx = multiSignTxs[_txIndex];

      require(
        multiSignTx.numSignatures >= numSignaturesRequired,
        "The number of signatures is not enough to execute this transaction"
      );

      multiSignTx.executed = true;

      // Execute add transaction
      if(multiSignTx.txCode == 0){
        _addOwner(multiSignTx.to);
      }

      // Execute transfer ownership transaction
      else if(multiSignTx.txCode == 1){
        _transferOwnership(multiSignTx.from, multiSignTx.to);
      }

      // Execute revoked transaction
      else if(multiSignTx.txCode == 2){
        _revokeOwner(multiSignTx.from);
      }

      // default case
      else{
        return false;
      }

      emit ExecuteMultiSignTx(msg.sender, _txIndex);
      return true;
  }

  /**
   * @dev Add owner to the contract
   */
  function _addOwner(address newOwner) internal returns (bool){
    require(newOwner != address(0), "Invalid owner");

    // Check if destination address is an owner/revoked owner
    for(uint i = 0; i < ownerList.length; i++) {
        // Check if address is unique
        require(ownerList[i] != newOwner, "Destination address is already an owner/revoked owner");
    }

    // Update ownership
    isActiveOwner[newOwner] = true;
    ownerList.push(newOwner);
    numSignaturesRequired = numSignaturesRequired/2 + 1;

    emit addOwner(newOwner);
    return true;
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address oldOwner, address newOwner) internal returns (bool){
    require(newOwner != address(0), "Invalid owner");

    // Check if source address is not an owner
    require(isActiveOwner[oldOwner], "Source address is not an Owner");

    // Check if destination address is an owner/revoked owner
    for(uint i = 0; i < ownerList.length; i++) {
        // Check if address is unique
        require(ownerList[i] != newOwner, "Destination address is already an owner/revoked owner");
    }

    // Revoking the signatures of the revoked owner on valid transaction
    for(uint j = 0; j < multiSignTxs.length; j++) {
        // Check if valid transaction which the revoked owner has signed
        if(
          (multiSignTxs[j].executed == false) 
          && ((block.timestamp - multiSignTxs[j].creationTime) <= MULTISIGN_TX_TIMEOUT)
          && (isSigned[j][oldOwner] == true)
          ){
              // Revoke signature of revoked owner
              multiSignTxs[j].numSignatures -= 1;
              isSigned[j][oldOwner] = false;
              emit RevokeSignature(oldOwner, j);
        }
    }

    // Update ownership
    isActiveOwner[oldOwner] = false;
    isActiveOwner[newOwner] = true;

    ownerList.push(newOwner);
    emit OwnershipTransferred(oldOwner, newOwner);

    return true;
  }

    /**
   * @dev REvoke owner to the contract
   */
  function _revokeOwner(address theOwner) internal returns (bool){
    // Check if the address is not an owner
    require(isActiveOwner[theOwner], "The address is not an Owner/active Owner");
    // Check if there are more than 3 ownerList
    require(ownerList.length > MINIMUM_NUM_OWNERS, "Require at least 3 ownerList to manage this contract");

    // Update ownership
    isActiveOwner[theOwner] = false;
    numSignaturesRequired = numSignaturesRequired/2 + 1;

    emit revokeOwner(theOwner);
    return true;
  }

  /**
   * @dev Returns the active bep token ownerList.
   * isActive = true: return active ownerList
   * isActive = false: return revoked ownerList
   */
  function getOwners(bool isActive) public view returns (uint32 owners_cnt, address[] memory list_owners) {
    owners_cnt = 0;
    list_owners = new address[](ownerList.length);

    for (uint i = 0; i < ownerList.length; i++) {
            address owner = ownerList[i];
            if(isActiveOwner[owner]==isActive){
                list_owners[owners_cnt] = owner;
                owners_cnt += 1;
        }
    }

    return (owners_cnt, list_owners);
  }

  /**
   * @dev Returns the current time in seconds
   */
  function timeNow() public view returns (uint256 timeNumber) {
    return block.timestamp;
  }

  /**
   * @dev Register a new account
   */
  function registerAccount(
    string memory phoneNumber 
    ) public returns (bool ok) {    

    require(!_identity[msg.sender].isRegisted, "Account already exists");    

    // Create and populate an identity
    _identity[msg.sender] = identity(
      "",
      phoneNumber,
      "",
      "",
      true/*isExisting*/,
      false,
      false,
      address(0),
      0,
      timeNow()
    );

    // updatre account list
    _accList.push(msg.sender);

    emit accountRegistered(msg.sender);
    return true;
  }

  /**
   * @dev Deactivate an account
   */
  function deactivateAccount( address walletAddr ) public onlyOwner returns (bool ok) {   

    require(_identity[walletAddr].isRegisted, "The account does not exist");
    require(_identity[walletAddr].isActive, "The account has been deactivated already");

    _identity[walletAddr].isActive = false;

    _identity[walletAddr].updatedTime = timeNow();
    _identity[walletAddr].grantor = msg.sender;
    emit accountDeactivated(walletAddr);

    return true;
  }

  /**
   * @dev Activate an account
   */
  function activateAccount( address walletAddr ) public onlyOwner returns (bool ok) {

    require(_identity[walletAddr].isRegisted, "The account does not exist");
    require(_identity[walletAddr].isKYC, "The account need to be KYC first");
    require(!_identity[walletAddr].isActive, "The account has been activated already");

    _identity[walletAddr].isActive = true;

    _identity[walletAddr].updatedTime = timeNow();
    _identity[walletAddr].grantor = msg.sender;
    emit accountActivated(walletAddr);

    return true;
  }

  /**
   * @dev Update account information
   */
  function updateAccountInfor( 
    address walletAddr,
    string memory name, 
    string memory phoneNumber,
    string memory idNumberType,
    string memory idNumber, 
    bool isKYC
    ) public onlyOwner returns (bool ok) {   
        
    identity storage acc = _identity[walletAddr];
    require(acc.isRegisted, "The account does not exist");

    acc.name = name;
    acc.phoneNumber = phoneNumber;
    acc.idNumberType = idNumberType;
    acc.idNumber = idNumber;
    acc.isKYC = isKYC;

    acc.updatedTime = timeNow();
    acc.grantor = msg.sender;
    emit accountInforUpdated(walletAddr);

    return true;
  }

  /**
   * @dev Get account information, owner only
   */
  function getAccountInfor(address walletAddr) public onlyOwner view returns (
    string memory name,
    string memory phoneNumber,
    string memory idNumberType,
    string memory idNumber,
    address grantor,
    uint256 updatedTime,
    uint256 regisTime,
    bool isActive,
    bool isKYC) {
      
    identity memory acc = _identity[walletAddr];
    require(acc.isRegisted, "The account does not exist");

    return (
      acc.name,
      acc.phoneNumber,
      acc.idNumberType,
      acc.idNumber,
      acc.grantor,
      acc.updatedTime,
      acc.regisTime,
      acc.isActive,
      acc.isKYC
      );
  }

  /**
   * @dev Get my account information
   */
  function getMyInfor() public view returns (
    string memory name,
    string memory phoneNumber,
    string memory idNumberType,
    string memory idNumber,
    address grantor,
    uint256 updatedTime,
    uint256 regisTime,
    bool isActive,
    bool isKYC) {
      
    identity memory acc = _identity[msg.sender];
    require(acc.isRegisted, "The account does not exist");

    return (
      acc.name,
      acc.phoneNumber,
      acc.idNumberType,
      acc.idNumber,
      acc.grantor,
      acc.updatedTime,
      acc.regisTime,
      acc.isActive,
      acc.isKYC
      );
  }

  /**
   * @dev Listing all account
   */
  function accountListing() external view returns ( uint256 counter, address[] memory) {
    return ( _accList.length, _accList);
  }

  /**
   * @dev Exchangable condition
   */
  function isTradableAccount(address walletAddr) external view returns (bool) {

      if(_identity[walletAddr].isRegisted && 
          _identity[walletAddr].isActive && 
          _identity[walletAddr].isKYC){
            return true;
          }else{
            return false;
          }
  }
}