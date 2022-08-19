//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Utils.sol";

contract SecurityLocker is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  struct DurationFeeStruct {
    uint256 durationFee_3M;
    uint256 durationFee_6M;
    uint256 durationFee_9M;
    uint256 durationFee_12M;
    uint256 durationFee_24M;
  }

  address payable public feeWallet;
  DurationFeeStruct public DurationFee;

  mapping(address => mapping(address => mapping(uint256 => PersonalLocker))) public personallockers; //wallet-NFT-Id =>locker
  mapping(address => PersonalLocker[]) public mainAccount; //wallet acccount -> multi-PersonalLocker
  mapping(address => PersonalLocker[]) public backupAccount; //wallet acccount -> multi-PersonalLocker

  uint256 public ERC721Fee;

  // modifier isAuth(address key_address, uint256 key_Id) {
  modifier isAuth(address lockerAddr) {
    // IPersonalLocker locker = IPersonalLocker(lockerAddr);
    // require(address(personallockers[msg.sender][key_address][key_Id]) != address(0), "no locker");
    require(checkSender(lockerAddr) == 1, "sender is not owner");
    _;
  }

  // event CreatePersonalLocker(address lockerAddr, string lockerName, address wallet1, address NFT1, uint256 NFT1_Id, address wallet2, address NFT2, uint256 NFT2_Id);
  //to save gas fee, can fetch info with using View Function ,just need timestamp and locker address
  event CreatePErsonalLocker(address lockerAddr);

  event ERC721feeSet(uint256 newVal);
  event setDurationFee(uint8 mounths, uint256 fee);
  event feeWalletSet(address newAddress);

  event UserResetDuration(address lockerAddr, address userAddr, uint256 duration, uint256 fee);
  event UserUpdateDuration(address lockerAddr, address userAddr, uint256 duration, uint256 fee);
  event AddBackupAccount(address lockerAddr, address wallet2, address NFT2, uint256 NFT2_Id);
  event AddPersonalLockerWhiteList(address lockerAddr, address receiver, address editor);
  event RemovePersonalLockerWhiteList(address lockerAddr, address receiver, address editor);

  event DepositERC20ToLocker(address lockerAddr, address userAddr, address token, uint256 amt, uint256 lockerAmt);
  event DepositUtilityToLocker(address lockerAddr, address userAddr, uint256 amt, uint256 lockerAmt);
  event DepositERC721ToLocker(address lockerAddr, address userAddr, address token, uint256 tokenId);

  event WithdrawERC20FromLocker(address lockerAddr, address userAddr, address token, uint256 amt, uint256 lockerAmt);
  event WithdrawUtilityFromLocker(address lockerAddr, address userAddr, uint256 amt, uint256 lockerAmt);
  event WithdrawERC721FromLocker(address lockerAddr, address userAddr, address token, uint256 tokenId, uint256 fee);

  constructor() {
    // feeWallet = payable(_feeWallet);
    feeWallet = payable(0xcc4A1aD4a623d5D4a6fCB1b1A581FFFeb8727Dc5);

    DurationFee.durationFee_3M = 0.001 * 10**18;
    DurationFee.durationFee_6M = 0.002 * 10**18;
    DurationFee.durationFee_9M = 0.003 * 10**18;
    DurationFee.durationFee_12M = 0.005 * 10**18;
    DurationFee.durationFee_24M = 0.01 * 10**18;
  }

  receive() external payable {}

  function createLocker(
    string memory lockerName,
    address key1_address,
    address wallet2,
    address key2_address,
    uint256 key1_Id,
    uint256 key2_Id,
    uint256 verifiedDuration,
    bool hasAccountBackup
  ) external payable nonReentrant {
    require(msg.value >= getDurationFee(verifiedDuration), "please send correct fee");
    require(msg.sender != wallet2, "wallet1 must different from wallet2");
    require(IERC721(key1_address).ownerOf(key1_Id) == msg.sender, "the address1 of NTF is not correct");
    require(address(personallockers[msg.sender][key1_address][key1_Id]) == address(0), "already created locker");
    require(!hasAccountBackup || IERC721(key2_address).ownerOf(key2_Id) == wallet2, "the address2 of NTF is not correct");
    PersonalLocker locker;

    locker = new PersonalLocker(lockerName, msg.sender, key1_address, key1_Id, verifiedDuration);
    personallockers[msg.sender][key1_address][key1_Id] = locker;
    mainAccount[msg.sender].push(locker);
    if (hasAccountBackup) {
      locker.addBackupInfo(wallet2, key2_address, key2_Id);
      backupAccount[wallet2].push(locker);
    }
    payable(feeWallet).transfer(msg.value);
    emit CreatePErsonalLocker(address(locker));
    // emitCreateLocker(locker.showInfo());
  }

  function addBackupInfo(
    address lockerAddr,
    address wallet2,
    address key2_address,
    uint256 key2_Id
  ) external nonReentrant isAuth(lockerAddr) {
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    require(msg.sender != wallet2, "wallet1 must different from wallet2");
    require(IERC721(key2_address).ownerOf(key2_Id) == wallet2, "the address2 of NTF is not correct");
    locker.addBackupInfo(wallet2, key2_address, key2_Id);
    backupAccount[wallet2].push(locker);
  }

  function depositERC20(
    address lockerAddr,
    address tokenAddr,
    uint256 amt
  ) external nonReentrant isAuth(lockerAddr) {
    IERC20 token = IERC20(tokenAddr);
    token.safeTransferFrom(msg.sender, lockerAddr, amt);
    emit DepositERC20ToLocker(lockerAddr, msg.sender, tokenAddr, amt, token.balanceOf(lockerAddr));
  }

  function depositUtility(address lockerAddr) external payable nonReentrant isAuth(lockerAddr) {
    payable(lockerAddr).transfer(msg.value);
    emit DepositUtilityToLocker(lockerAddr, msg.sender, msg.value, payable(lockerAddr).balance);
  }

  function depositERC721(
    address lockerAddr,
    address tokenAddr,
    uint256[] calldata tokenIds
  ) external payable nonReentrant isAuth(lockerAddr) {
    IERC721 token = IERC721(tokenAddr);
    uint256 tokenId;
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    for (uint256 i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      require(tokenAddr != locker.showInfo().verifiedToken || tokenId != locker.showInfo().verifiedId, "this NFT is locker's key");
      require(tokenAddr != locker.showInfo().backupVerifiedToken || tokenId != locker.showInfo().backupVerifiedId, "this NFT is locker's key");
      require(token.ownerOf(tokenId) == msg.sender, "not your token");
      token.transferFrom(msg.sender, lockerAddr, tokenId);
      emit DepositERC721ToLocker(lockerAddr, msg.sender, tokenAddr, tokenId);
    }
    // emit DepositToLocker(lockerAddr, msg.sender, WBNB, msg.value);
  }

  function withdrawERC20(
    address receiver,
    address lockerAddr,
    address tokenAddr,
    uint256 amt
  ) external nonReentrant isAuth(lockerAddr) {
    IERC20 token = IERC20(tokenAddr);
    uint256 balance = token.balanceOf(lockerAddr);
    require(amt <= balance, "amt over");
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    locker.withdrawERC20(tokenAddr, receiver, amt);
    emit WithdrawERC20FromLocker(lockerAddr, receiver, tokenAddr, amt, token.balanceOf(lockerAddr));
  }

  function withdrawUtility(
    address receiver,
    address lockerAddr,
    uint256 amt
  ) external nonReentrant isAuth(lockerAddr) {
    uint256 balance = payable(lockerAddr).balance;
    require(amt <= balance, "amt over");
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    locker.withdrawUtility(receiver, amt);
    emit WithdrawUtilityFromLocker(lockerAddr, receiver, amt, payable(lockerAddr).balance);
  }

  function withdrawERC721(
    address receiver,
    address lockerAddr,
    address _tokenAddr,
    uint256[] calldata tokenIds
  ) external payable nonReentrant isAuth(lockerAddr) {
    require(msg.value >= ERC721Fee, "please send correct fee");
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    uint256 tokenId;
    for (uint256 i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      locker.withdrawERC721(receiver, _tokenAddr, tokenId);
      emit WithdrawERC721FromLocker(lockerAddr, receiver, _tokenAddr, tokenId, msg.value);
    }
    payable(feeWallet).transfer(msg.value);
  }

  function resetTimer(address lockerAddr) external payable isAuth(lockerAddr) {
    VerifyProps memory info = lockerInfoByLocker(lockerAddr);
    require(msg.value >= getDurationFee(info.verifiedDuration), "please send correct fee");
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    locker.restartVerifiedTimer();
    payable(feeWallet).transfer(msg.value);
    emit UserResetDuration(address(locker), msg.sender, info.verifiedDuration, msg.value);
  }

  function updateDuration(address lockerAddr, uint256 duration) external payable isAuth(lockerAddr) {
    require(msg.value >= getDurationFee(duration), "please send correct fee");
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    locker.setupVerifiedDuration(duration);
    payable(feeWallet).transfer(msg.value);
    emit UserUpdateDuration(address(locker), msg.sender, duration, msg.value);
  }

  function addPersonalLockerWhiteList(address lockerAddr, address receiver) external isAuth(lockerAddr) {
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    locker.addWhiteList(receiver);
    emit AddPersonalLockerWhiteList(lockerAddr, receiver, msg.sender);
  }

  function removePersonalWhiteList(address lockerAddr, address receiver) external isAuth(lockerAddr) {
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    locker.removeWhiteList(receiver);
    emit RemovePersonalLockerWhiteList(lockerAddr, receiver, msg.sender);
  }

  /*
   ** Owner functions
   */
  function setFeeWallet(address _newVal) external onlyOwner {
    feeWallet = payable(_newVal);
    emit feeWalletSet(_newVal);
  }

  function setERC721Fee(uint256 _newVal) external onlyOwner {
    ERC721Fee = _newVal;
    emit ERC721feeSet(_newVal);
  }

  function setDuration_3M_Fee(uint256 _newVal) external onlyOwner {
    DurationFee.durationFee_3M = _newVal;
    emit setDurationFee(3, _newVal);
  }

  function setDuration_6M_Fee(uint256 _newVal) external onlyOwner {
    DurationFee.durationFee_6M = _newVal;
    emit setDurationFee(6, _newVal);
  }

  function setDuration_9M_Fee(uint256 _newVal) external onlyOwner {
    DurationFee.durationFee_9M = _newVal;
    emit setDurationFee(9, _newVal);
  }

  function setDuration_12M_Fee(uint256 _newVal) external onlyOwner {
    DurationFee.durationFee_12M = _newVal;
    emit setDurationFee(12, _newVal);
  }

  function setDuration_24M_Fee(uint256 _newVal) external onlyOwner {
    DurationFee.durationFee_24M = _newVal;
    emit setDurationFee(24, _newVal);
  }

  function withdrawBalance(
    address _token,
    address recipient,
    uint256 amt
  ) external onlyOwner {
    require(amt > 0, "amt is 0");
    if (_token == address(0)) {
      require(amt <= payable(address(this)).balance, "over amt");
      payable(recipient).transfer(amt);
    } else {
      IERC20 token = IERC20(_token);
      require(amt <= token.balanceOf(address(this)), "over amt");
      token.safeTransfer(recipient, amt);
    }
  }

  /*
   ** internal function
   */
  function checkSender(address lockerAddr) internal view returns (uint8) {
    //0: false 1:success
    // PersonalLocker locker = personallockers[msg.sender][key_address][key_Id];
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    if (locker.showInfo().ownAddress == msg.sender) return 1;
    if (locker.showInfo().backupAddress == msg.sender) return 1;
    return 0;
  }

  function getDurationFee(uint256 duration) internal view returns (uint256) {
    if (duration <= 90 days) return DurationFee.durationFee_3M;
    if (duration > 90 days && duration <= 180 days) return DurationFee.durationFee_6M;
    if (duration > 180 days && duration <= 270 days) return DurationFee.durationFee_9M;
    if (duration > 270 days && duration <= 365 days) return DurationFee.durationFee_12M;
    return DurationFee.durationFee_24M;
  }

  /*
  View Function
   */
  function lockerInfoByLocker(address lockerAddr) public view returns (VerifyProps memory) {
    PersonalLocker locker = PersonalLocker(payable(lockerAddr));
    return locker.showInfo();
  }

  function lockersInfoByWallet(address account, uint8 isMain) public view returns (VerifyProps[] memory) {
    //0:backup 1:main
    uint256 counts = isMain == 1 ? mainAccount[account].length : backupAccount[account].length;
    VerifyProps[] memory info = new VerifyProps[](counts);
    for (uint256 i = 0; i < counts; i++) {
      PersonalLocker locker = isMain == 1 ? mainAccount[account][i] : backupAccount[account][i];
      info[i] = locker.showInfo();
    }
    return info;
  }

  function mainLockerCounts(address account) public view returns (uint256) {
    return mainAccount[account].length;
  }

  function backupLockerCounts(address account) public view returns (uint256) {
    return backupAccount[account].length;
  }
}

contract PersonalLocker is ReentrancyGuard {
  using SafeERC20 for IERC20;

  VerifyProps public LockerInfo;
  bool hasBackupAccount; //default: false
  mapping(address => bool) public isWhiteList;

  modifier isVerified() {
    require(verifiedCaller() == 1, "not owner");
    require(verifiedERC721Account() == 1, "can not do anything");
    _;
  }

  constructor(
    string memory lockerName,
    address _wallet1,
    address key1_address,
    uint256 key1_Id,
    uint256 verifiedDuration
  ) {
    LockerInfo.lockerName = lockerName;
    LockerInfo.lockerAddress = address(this);
    LockerInfo.lockerManager = msg.sender;
    LockerInfo.ownAddress = _wallet1;
    LockerInfo.verifiedToken = key1_address;
    LockerInfo.verifiedId = key1_Id;
    LockerInfo.verifiedDuration = verifiedDuration;
    LockerInfo.lastVerifiedTime = block.timestamp;
    isWhiteList[_wallet1] = true;
    isWhiteList[msg.sender] = true;
  }

  receive() external payable {}

  // Add backup Account
  function addBackupInfo(
    address wallet2,
    address key2_address,
    uint256 key2_Id
  ) external isVerified nonReentrant {
    require(!hasBackupAccount, "already create a backup account");
    LockerInfo.backupAddress = wallet2;
    LockerInfo.backupVerifiedToken = key2_address;
    LockerInfo.backupVerifiedId = key2_Id;
    isWhiteList[wallet2] = true;
    hasBackupAccount = true;
  }

  //withdraw function
  function withdrawUtility(address receiver, uint256 amounts) external payable isVerified nonReentrant {
    require(isWhiteList[receiver] == true, "not allow");
    require(amounts <= address(this).balance, "not enough");
    payable(receiver).transfer(amounts);
  }

  function withdrawERC20(
    address _tokenAddr,
    address receiver,
    uint256 amounts
  ) external isVerified nonReentrant {
    require(isWhiteList[receiver] == true, "not allow");
    IERC20 token = IERC20(_tokenAddr);
    uint256 balance = token.balanceOf(address(this));
    require(balance - amounts >= 0, "no funds");
    token.safeTransfer(receiver, amounts);
  }

  function withdrawERC721(
    address receiver,
    address _tokenAddr,
    uint256 _tokenID
  ) external isVerified nonReentrant {
    require(isWhiteList[receiver] == true, "not allow");
    IERC721 token = IERC721(_tokenAddr);
    token.transferFrom(address(this), receiver, _tokenID);
  }

  function addWhiteList(address receiver) external isVerified {
    isWhiteList[receiver] = true;
  }

  function removeWhiteList(address receiver) external isVerified {
    require(receiver != LockerInfo.lockerManager, "can not remove Manager address");
    isWhiteList[receiver] = false;
  }

  function restartVerifiedTimer() external isVerified {
    LockerInfo.lastVerifiedTime = block.timestamp;
  }

  function setupVerifiedDuration(uint256 duration) external isVerified {
    LockerInfo.verifiedDuration = duration;
    LockerInfo.lastVerifiedTime = block.timestamp;
  }

  function onERC721Received(
    address,
    address from,
    uint256,
    bytes calldata
  ) external pure returns (bytes4) {
    require(from == address(0x0), "Cannot send nfts to Vault directly");
    return IERC721Receiver.onERC721Received.selector;
  }

  function showInfo() external view returns (VerifyProps memory) {
    return LockerInfo;
  }

  function verifiedERC721Account() internal view returns (uint8) {
    //0: false 1:success
    if (LockerInfo.lastVerifiedTime + LockerInfo.verifiedDuration < block.timestamp) return 1;
    if (IERC721(LockerInfo.verifiedToken).ownerOf(LockerInfo.verifiedId) == tx.origin) return 1;
    if (IERC721(LockerInfo.backupVerifiedToken).ownerOf(LockerInfo.backupVerifiedId) == tx.origin) return 1;
    return 0;
  }

  function verifiedCaller() internal view returns (uint8) {
    //0: false 1:success
    if ((msg.sender == LockerInfo.lockerManager) && (tx.origin == LockerInfo.ownAddress || tx.origin == LockerInfo.backupAddress || msg.sender == address(this))) return 1;
    if (msg.sender == LockerInfo.ownAddress || msg.sender == LockerInfo.backupAddress || msg.sender == address(this)) return 1;
    return 0;
  }
}