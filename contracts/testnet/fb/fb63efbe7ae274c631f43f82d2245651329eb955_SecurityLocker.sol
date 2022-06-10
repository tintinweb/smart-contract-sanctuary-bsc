//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Utils.sol";

//bsc testnet NFT:0xb6e4De442636f368250436A65f07769DdAFAfc5e
//bsc main NFT:0x75A85C230258D93B7F717FE8F6633499c03EDA43
//https://ipfs.io/

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
  struct WithdrawFeeRateStruct {
    uint256 tierd1FeeRate;
    uint256 tierd2FeeRate;
    uint256 tierd3FeeRate;
  }

  uint256 public feeRate; // 100 = 1%
  uint256 public standardization = 10000;
  address public feeWallet;
  DurationFeeStruct public DurationFee;
  // WithdrawFeeRateStruct public WithdrawFeeRate;

  mapping(address => mapping(address => mapping(uint256 => PersonalLocker))) public personallockers; //wallet-NFT-Id =>locker
  mapping(address => PersonalLocker[]) public mainAccount; //wallet acccount -> multi-PersonalLocker
  mapping(address => PersonalLocker[]) public backupAccount; //wallet acccount -> multi-PersonalLocker
  mapping(address => PersonalLocker) public lockers;

  mapping(address => uint256) public depositFeelist;
  mapping(address => uint8) public withdrawFeeRatelist; //tokenAddr -> FeeRateArr :FeeRateArr[0] is default
  mapping(address => bool) public noFeelist;

  uint16[] public FeeRateArr;
  // address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;//main
  address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //test
  uint256 public ERC721Fee;

  // modifier isAuth(address key_address, uint256 key_Id) {
  modifier isAuth(address lockerAddr) {
    // IPersonalLocker locker = IPersonalLocker(lockerAddr);
    // require(address(personallockers[msg.sender][key_address][key_Id]) != address(0), "no locker");
    require(checkSender(lockerAddr) == 1, "sender is not owner");
    _;
  }

  event CreatePersonalLocker(address lockerAddress, address wallet1, address NFT1, uint256 NFT1_Id, address wallet2, address NFT2, uint256 NFT2_Id, uint256 verifiedDuration);
  event feeSet(uint16 newVal);
  event ERC721feeSet(uint256 newVal);
  event feeArrSet(uint8 index, uint16 newVal);
  event setDurationFee(uint8 mounths, uint256 fee);
  event feeWalletSet(address newAddress);
  event UserUpdateDuration(address lockerAddr, address userAddr, uint256 duration, uint256 fee);
  event DepositToLocker(address lockerAddr, address userAddr, address token, uint256 depositAmt);
  event DepositERC721ToLocker(address lockerAddr, address userAddr, address token, uint256 tokenId);
  event WithdrawFromLocker(address lockerAddr, address userAddr, address token, uint256 receiveAmt, uint256 fee);
  event WithdrawERC721FromLocker(address lockerAddr, address userAddr, address token, uint256 tokenId, uint256 fee);

  constructor(address _feeWallet) {
    feeWallet = _feeWallet;
    feeRate = 50; //0.5%
    noFeelist[0x0cAE6c43fe2f43757a767Df90cf5054280110F3e] = true; //AFFINITY
    noFeelist[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] = true; //WBNB
    noFeelist[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = true; //BUSD
    noFeelist[0x55d398326f99059fF775485246999027B3197955] = true; //USDT
    noFeelist[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = true; //USDC
    noFeelist[0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47] = true; //ADA

    //withdraw Init
    FeeRateArr.push(100); // default: 1%
    FeeRateArr.push(50);
    FeeRateArr.push(75);
    ERC721Fee = 10000000000000000; //0.01BNB
  }

  receive() external payable {}

  function createLocker(
    address key1_address,
    uint256 key1_Id,
    address _wallet2,
    address key2_address,
    uint256 key2_Id,
    uint256 verifiedDuration
  ) external nonReentrant {
    require(address(personallockers[msg.sender][key1_address][key1_Id]) == address(0), "already created locker");
    PersonalLocker locker;
    locker = new PersonalLocker(msg.sender, key1_address, key1_Id, _wallet2, key2_address, key2_Id, verifiedDuration);
    personallockers[msg.sender][key1_address][key1_Id] = locker;
    mainAccount[msg.sender].push(locker);
    backupAccount[_wallet2].push(locker);
    lockers[address(locker)] = locker;
    emit CreatePersonalLocker(address(locker), msg.sender, key1_address, key1_Id, _wallet2, key2_address, key2_Id, verifiedDuration);
  }

  function depositERC20(
    address lockerAddr,
    address tokenAddr,
    uint256 amounts
  ) external nonReentrant isAuth(lockerAddr) {
    IERC20 token = IERC20(tokenAddr);
    token.safeTransferFrom(msg.sender, lockerAddr, amounts);
    emit DepositToLocker(lockerAddr, msg.sender, tokenAddr, amounts);
  }

  function depositUitility(address lockerAddr) external payable nonReentrant isAuth(lockerAddr) {
    payable(lockerAddr).transfer(msg.value);
    emit DepositToLocker(lockerAddr, msg.sender, WBNB, msg.value);
  }

  function depositERC721(
    address lockerAddr,
    address tokenAddr,
    uint256[] calldata tokenIds
  ) external payable nonReentrant isAuth(lockerAddr) {
    IERC721 token = IERC721(tokenAddr);
    uint256 tokenId;
    for (uint256 i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      require(tokenAddr != lockers[lockerAddr].showInfo().verifiedToken || tokenId != lockers[lockerAddr].showInfo().verifiedId, "this NFT is locker's key");
      require(tokenAddr != lockers[lockerAddr].showInfo().backupVerifiedToken || tokenId != lockers[lockerAddr].showInfo().backupVerifiedId, "this NFT is locker's key");
      require(token.ownerOf(tokenId) == msg.sender, "not your token");
      token.transferFrom(msg.sender, lockerAddr, tokenId);
      emit DepositERC721ToLocker(lockerAddr, msg.sender, tokenAddr, tokenId);
    }
    emit DepositToLocker(lockerAddr, msg.sender, WBNB, msg.value);
  }

  // function withdraw(address key_address, uint256 key_Id) external nonReentrant isAuth(key_address, key_Id) {}
  function withdrawERC20(
    address lockerAddr,
    address tokenAddr,
    uint256 amounts,
    address receiver
  ) external nonReentrant isAuth(lockerAddr) {
    IERC20 token = IERC20(tokenAddr);
    require(amounts <= token.balanceOf(lockerAddr), "amt over");
    uint256 _feeRate = getWithdrawFee(tokenAddr);
    uint256 _fee = amounts.mul(_feeRate).div(standardization);
    PersonalLocker locker = lockers[lockerAddr];
    locker.withdrawERC20(tokenAddr, receiver, amounts.sub(_fee));
    // locker.withdrawERC20(tokenAddr, feeWallet, _fee);
    locker.withdrawERC20(tokenAddr, address(this), _fee);
    token.safeTransfer(feeWallet, _fee);
    emit WithdrawFromLocker(lockerAddr, receiver, tokenAddr, amounts.sub(_fee), _fee);
  }

  function withdrawUitility(
    address lockerAddr,
    uint256 amounts,
    address receiver
  ) external nonReentrant isAuth(lockerAddr) {
    require(amounts <= payable(lockerAddr).balance, "amt over");
    uint256 _feeRate = getWithdrawFee(WBNB);
    uint256 _fee = amounts.mul(_feeRate).div(standardization);
    PersonalLocker locker = lockers[lockerAddr];
    // locker.withdrawUitility(msg.sender, amounts.sub(_fee));
    locker.withdrawUitility(receiver, amounts.sub(_fee));
    // locker.withdrawUitility{ value: _fee }(payable(feeWallet));
    locker.withdrawUitility(address(this), _fee);
    payable(feeWallet).transfer(_fee);
    emit WithdrawFromLocker(lockerAddr, receiver, WBNB, amounts.sub(_fee), _fee);
  }

  function withdeawERC721(
    address lockerAddr,
    address _tokenAddr,
    uint256[] calldata tokenIds,
    address receiver
  ) external payable nonReentrant isAuth(lockerAddr) {
    require(msg.value >= ERC721Fee, "please send correct fee");
    PersonalLocker locker = lockers[lockerAddr];
    uint256 tokenId;
    for (uint256 i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      locker.withdeawERC721(_tokenAddr, tokenId, receiver);
      emit WithdrawERC721FromLocker(lockerAddr, receiver, _tokenAddr, tokenId, msg.value);
    }
    payable(feeWallet).transfer(msg.value);
  }

  function resetTimer(address lockerAddr) external isAuth(lockerAddr) {
    PersonalLocker locker = lockers[lockerAddr];
    locker.restartVerifiedTimer();
  }

  function updateDuration(address lockerAddr, uint256 duration) external payable isAuth(lockerAddr) {
    require(msg.value >= getDurationFee(duration), "please send correct fee");
    PersonalLocker locker = lockers[lockerAddr];
    locker.setupVerifiedDuration(duration);
    payable(feeWallet).transfer(msg.value);
    emit UserUpdateDuration(address(locker), msg.sender, duration, msg.value);
  }

  /*
   ** Owner functions
   */
  function setFeeWallet(address _newVal) external onlyOwner {
    feeWallet = _newVal;
    emit feeWalletSet(_newVal);
  }

  function setFee(uint16 _newVal) external onlyOwner {
    require(_newVal < 10000, "Fee cannot be set >= 100%");
    feeRate = _newVal;
    emit feeSet(_newVal);
  }

  function setFeeArr(uint8 index, uint16 _newVal) external onlyOwner {
    require(_newVal < 10000, "Fee cannot be set >= 100%");
    if (index > FeeRateArr.length) FeeRateArr.push(index);
    FeeRateArr[index] = _newVal;
    emit feeArrSet(index, _newVal);
  }

  function setERC20Fee(address tokenAddr, uint8 index) external onlyOwner {
    withdrawFeeRatelist[tokenAddr] = index;
  }

  function serERC721Fee(uint256 _newVal) external onlyOwner {
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
  ) external payable onlyOwner {
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

  // function checkSender(address key_address, uint256 key_Id) internal view returns (uint8) {
  function checkSender(address lockerAddr) internal view returns (uint8) {
    //0: false 1:success
    // PersonalLocker locker = personallockers[msg.sender][key_address][key_Id];
    PersonalLocker locker = lockers[lockerAddr];
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

  function getWithdrawFee(address tokenAddr) internal view returns (uint256) {
    if (noFeelist[tokenAddr]) return 0;
    if (withdrawFeeRatelist[tokenAddr] > FeeRateArr.length - 1) return feeRate;
    return FeeRateArr[withdrawFeeRatelist[tokenAddr]];
  }

  /*
  View Function
   */
  function lockerInfo(address lockerAddr) external view returns (VerifyProps memory) {
    return lockers[lockerAddr].showInfo();
  }

  function mainLockerCounts() external view returns (uint256) {
    return mainAccount[msg.sender].length;
  }

  function backupLockerCounts() external view returns (uint256) {
    return backupAccount[msg.sender].length;
  }
}

contract PersonalLocker is ReentrancyGuard {
  using SafeERC20 for IERC20;

  // struct VerifyProps {
  //   address lockerAddress;
  //   address lockerManager;
  //   address ownAddress;
  //   address verifiedToken; //ERC721
  //   uint256 verifiedId; //ERC721 tokenId
  //   address backupAddress;
  //   address backupVerifiedToken; //ERC721 backup
  //   uint256 backupVerifiedId; //ERC721 tokenId backup
  //   uint256 verifiedDuration;
  //   uint256 lastVerifiedTime;
  // }

  VerifyProps public LockerInfo;
  mapping(address => bool) public isWhiteList;

  modifier isVerified() {
    require(msg.sender == LockerInfo.lockerManager, "not call from Manager");
    require(tx.origin == LockerInfo.ownAddress || tx.origin == LockerInfo.backupAddress || msg.sender == address(this), "not owner");
    //require(LockerInfo.lastVerifiedTime + LockerInfo.verifiedDuration > block.timestamp, "can not do anything");
    require(verifiedERC721Account() == 1, "can not do anything");
    _;
  }
  modifier isVerified2() {
    // require(msg.sender == LockerInfo.lockerManager, "not call from Manager");
    require(msg.sender == LockerInfo.ownAddress || msg.sender == LockerInfo.backupAddress || msg.sender == address(this), "not owner");
    //require(LockerInfo.lastVerifiedTime + LockerInfo.verifiedDuration > block.timestamp, "can not do anything");
    require(verifiedERC721Account() == 1, "can not do anything");
    _;
  }
  modifier initialSuccess(
    address _wallet1,
    address key1_address,
    uint256 key1_Id,
    address _wallet2,
    address key2_address,
    uint256 key2_Id
  ) {
    require(_wallet1 != _wallet2, "wallet1 must different from wallet2");
    // require(_wallet2 != address(0), "wallet2 is empty");
    require(IERC721(key1_address).ownerOf(key1_Id) == _wallet1, "the address1 of NTF is not correct");
    // if (key2_address != address(0)) require(IERC721(key2_address).ownerOf(key2_Id) == _wallet2, "the address2 of NTF is not correct");
    require(IERC721(key2_address).ownerOf(key2_Id) == _wallet2, "the address2 of NTF is not correct");
    _;
  }

  constructor(
    address _wallet1,
    address key1_address,
    uint256 key1_Id,
    address _wallet2,
    address key2_address,
    uint256 key2_Id,
    uint256 verifiedDuration
  ) initialSuccess(_wallet1, key1_address, key1_Id, _wallet2, key2_address, key2_Id) {
    LockerInfo.lockerManager = msg.sender;
    LockerInfo.ownAddress = _wallet1;
    LockerInfo.verifiedToken = key1_address;
    LockerInfo.verifiedId = key1_Id;
    LockerInfo.backupAddress = _wallet2;
    LockerInfo.backupVerifiedToken = key2_address;
    LockerInfo.backupVerifiedId = key2_Id;
    LockerInfo.verifiedDuration = verifiedDuration;
    LockerInfo.lastVerifiedTime = block.timestamp;
    LockerInfo.lockerAddress = address(this);
    isWhiteList[_wallet1] = true;
    isWhiteList[_wallet2] = true;
    isWhiteList[msg.sender] = true;
  }

  receive() external payable {}

  //deposite function
  // function depositERC20(address _tokenAddr) external isVerified nonReentrant {}

  //withdraw function
  function withdrawUitility(address receiver, uint256 amounts) external payable isVerified nonReentrant {
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

  function withdeawERC721(
    address _tokenAddr,
    uint256 _tokenID,
    address receiver
  ) external isVerified nonReentrant {
    require(isWhiteList[receiver] == true, "not allow");
    IERC721 token = IERC721(_tokenAddr);
    token.transferFrom(address(this), receiver, _tokenID);
  }

  // function withdrawAllFunds(address receiver, address[] memory tokenArr) external isVerified {
  //   require(isWhiteList[receiver] == true, "not allow");
  //   //withdraw BNB
  //   if (address(this).balance > 0) payable(receiver).transfer(address(this).balance);
  //   // withdraw ERC20
  //   if (tokenArr.length > 0) {
  //     for (uint256 i = 0; i < tokenArr.length; i++) {
  //       IERC20 token = IERC20(address(tokenArr[i]));
  //       uint256 balance = token.balanceOf(address(this));
  //       if (balance > 0) token.safeTransfer(receiver, balance);
  //       balance = 0;
  //     }
  //   }
  // }

  function addWhiteList(address receiver) external isVerified2 {
    isWhiteList[receiver] = true;
  }

  function removeWhiteList(address receiver) external isVerified2 {
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

  // function setupAuth(address key_address, uint256 key_Id) external isVerified {
  //   require(IERC721(key_address).ownerOf(key_Id) == LockerInfo.ownAddress);
  //   LockerInfo.verifiedToken = key_address;
  //   LockerInfo.verifiedId = key_Id;
  // }

  // function setupAuth2(
  //   address key_address,
  //   uint256 key_Id,
  //   address wallet_addr
  // ) external isVerified {
  //   require(IERC721(key_address).ownerOf(key_Id) == wallet_addr);
  //   LockerInfo.backupVerifiedToken = key_address;
  //   LockerInfo.verifiedId = key_Id;
  // }

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
    if (LockerInfo.lastVerifiedTime + LockerInfo.verifiedDuration > block.timestamp) return 1;
    if (IERC721(LockerInfo.verifiedToken).ownerOf(LockerInfo.verifiedId) == tx.origin) return 1;
    if (IERC721(LockerInfo.backupVerifiedToken).ownerOf(LockerInfo.backupVerifiedId) == tx.origin) return 1;
    return 0;
  }
}