/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address owner) external view returns (uint balance);
    function approve(address to, uint tokenId) external;
}

interface IERC721 {
  function ownerOf(uint256 tokenId) external view returns (address owner);
  function safeTransferFrom(
    address from,
    address to,
    uint tokenId
  ) external;
}

struct LockedBalance {
    int128 amount;
    uint end;
}

interface IVE is IERC721 {
    function withdraw(uint _tokenId) external returns (bool);
    function locked(uint _tokenId) external view returns (LockedBalance memory);
}

interface IReward {
  function rewardToken() external view returns (address);
  function claimReward(uint tokenId, uint startEpoch, uint endEpoch) external returns (uint reward);
  function getEpochIdByTime(uint _time) view external returns (uint);
  function getEpochInfo(uint epochId) view external returns (uint, uint, uint);
  function getPendingRewardSingle(uint tokenId, uint epochId) view external returns (uint reward, bool finished);
}

contract Administrable {
    address public admin;
    address public pendingAdmin;
    event LogSetAdmin(address admin);
    event LogTransferAdmin(address oldadmin, address newadmin);
    event LogAcceptAdmin(address admin);

    function setAdmin(address admin_) internal {
        admin = admin_;
        emit LogSetAdmin(admin_);
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        address oldAdmin = pendingAdmin;
        pendingAdmin = newAdmin;
        emit LogTransferAdmin(oldAdmin, newAdmin);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit LogAcceptAdmin(admin);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract RewardShare is Administrable, IERC721Receiver {
    address public ve;
    uint256 public ve_tokenId;
    address public vereward;
    address public multi;
    uint256 public totalLocked;
    uint256 constant totalShare = 10000;
    string public name;
    address public nft;
    mapping (uint256 => uint256) public totalAmount; // day => total multi amount
    mapping (uint256 => uint256) public rewardCollected; // epochId => reward

    event LogInitSharedVE(uint256 tokenId, uint256 amount, uint256 lockEnd);
    event LogWithdrawVE(uint256 tokenId);
    event LogWithdrawMulti(uint256 amount);
    event LogWithdrawReward(uint256 amount);
    event LogClaim(uint256 tokenId, uint256 endTime, uint256 amount);
    event LogMint(uint256 tokenId, uint256 amount, uint256 startTime, uint256 endTime);
    event LogMintBatch(uint256[] tokenIds, uint256 amount, uint256 startTime, uint256 endTime);

    constructor (address multi_, address ve_, address vereward_, string memory name_, address nft_) {
        ve = ve_;
        vereward = vereward_;
        multi = multi_;
        name = name_;
        nft = nft_;
        setAdmin(msg.sender);
    }

    function setNFT(address nft_) onlyAdmin external {
      nft = nft_;
    }

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4) {
      if (ve_tokenId != 0) {
        return "";
      }
      if (IVE(ve).ownerOf(tokenId) != address(this)) {
        return "";
      }
      if (from != admin) {
        return "";
      }
      ve_tokenId = tokenId;
      LockedBalance memory locked = IVE(ve).locked(tokenId);
      uint amount = uint128(locked.amount);
      uint256 lockEnd = locked.end;
      totalLocked = amount;
      emit LogInitSharedVE(ve_tokenId, amount, lockEnd);
      return IERC721Receiver.onERC721Received.selector;
    }

    // withdraw multi after expired
    function withdrawMulti(address to) onlyAdmin external {
        IVE(ve).withdraw(ve_tokenId);
        IVE(ve).withdraw(ve_tokenId);
        uint256 amount = IERC20(multi).balanceOf(address(this));
        IERC20(multi).transfer(to, amount);
        ve_tokenId = 0;
        emit LogWithdrawMulti(amount);
    }

    function withdrawReward(address to, uint256 amount) onlyAdmin external {
        IERC20(IReward(vereward).rewardToken()).transfer(to, amount);
        emit LogWithdrawReward(amount);
    }

    function withdrawVe(uint256 tokenId, address to) onlyAdmin external {
        IVE(ve).safeTransferFrom(address(this), to, tokenId);
        emit LogWithdrawVE(ve_tokenId);
        ve_tokenId = 0;
    }

    function withdrawVe(address to) onlyAdmin external {
        IVE(ve).safeTransferFrom(address(this), to, ve_tokenId);
        emit LogWithdrawVE(ve_tokenId);
        ve_tokenId = 0;
    }

    function collectUnderlyingReward(uint256 startEpochId, uint256 endEpochId) internal {
      for (uint i = startEpochId; i <= endEpochId; i++) {
        rewardCollected[i] += IReward(vereward).claimReward(ve_tokenId, i, i);
      }
    }

    mapping (uint256 => uint256) public lastHarvestUntil; // tokenId => time

    mapping (uint256 => TokenInfo) public tokenInfo;

    uint256 public day = 1 days;

    struct TokenInfo {
        uint256 share;
        uint256 startTime;
        uint256 endTime;
    }

    function claimable(uint256 tokenId) external view returns(uint256) {
      uint256 startTime = lastHarvestUntil[tokenId] > tokenInfo[tokenId].startTime ? lastHarvestUntil[tokenId] : tokenInfo[tokenId].startTime;
      uint256 endTime = block.timestamp < tokenInfo[tokenId].endTime ? block.timestamp : tokenInfo[tokenId].endTime;
      return _claimable(tokenId, startTime, endTime);
    }

    function claimable(uint256 tokenId, uint256 endTime) external view returns(uint256) {
      uint256 startTime = lastHarvestUntil[tokenId] > tokenInfo[tokenId].startTime ? lastHarvestUntil[tokenId] : tokenInfo[tokenId].startTime;
      require(endTime <= block.timestamp && endTime <= tokenInfo[tokenId].endTime);
      return _claimable(tokenId, startTime, endTime);
    }
  
    function _claimable(uint256 tokenId, uint256 startTime, uint256 endTime) internal view returns(uint256) {
      uint256 startEpochId = IReward(vereward).getEpochIdByTime(startTime);
      uint256 endEpochId = IReward(vereward).getEpochIdByTime(endTime);

      uint256 reward = 0;
      uint256 userLockStart;
      uint256 userLockEnd;
      uint256 collectedTime;
      uint256 uncollected;
      for (uint i = startEpochId; i <= endEpochId; i++) {
        (uncollected,) = IReward(vereward).getPendingRewardSingle(ve_tokenId, i);
        uint256 reward_i = rewardCollected[i] + uncollected;
        (uint epochStartTime, uint epochEndTime, ) = IReward(vereward).getEpochInfo(i);
        // user's unclaimed time span in an epoch
        userLockStart = epochStartTime;
        userLockEnd = epochEndTime;
        collectedTime = epochEndTime - epochStartTime;
        if (i == startEpochId) {
          userLockStart = startTime;
        }
        if (i == endEpochId) {
          userLockEnd = endTime; // assuming endTime <= block.timestamp
          collectedTime = block.timestamp - epochStartTime;
        }
        reward_i = reward_i * (userLockEnd - userLockStart) / collectedTime;
        reward += reward_i;
      }
      uint256 userReward = reward * tokenInfo[tokenId].share / totalLocked;
      return userReward;
    }

    function claimReward(uint256 tokenId) external {
      require(msg.sender == IERC721(nft).ownerOf(tokenId));
      // user's unclaimed timespan
      uint256 startTime = lastHarvestUntil[tokenId] > tokenInfo[tokenId].startTime ? lastHarvestUntil[tokenId] : tokenInfo[tokenId].startTime;
      uint256 endTime = block.timestamp < tokenInfo[tokenId].endTime ? block.timestamp : tokenInfo[tokenId].endTime;
      uint256 amount = _claimReward(tokenId, startTime, endTime);
      emit LogClaim(tokenId, endTime, amount);
    }

    function claimReward(uint256 tokenId, uint256 endTime) external {
      require(msg.sender == IERC721(nft).ownerOf(tokenId));
      // user's unclaimed timespan
      uint256 startTime = lastHarvestUntil[tokenId] > tokenInfo[tokenId].startTime ? lastHarvestUntil[tokenId] : tokenInfo[tokenId].startTime;
      require(endTime <= block.timestamp && endTime <= tokenInfo[tokenId].endTime);
      uint256 amount = _claimReward(tokenId, startTime, endTime);
      emit LogClaim(tokenId, endTime, amount);
    }

    function _claimReward(uint256 tokenId, uint256 startTime, uint256 endTime) internal returns (uint256) {
      uint256 startEpochId = IReward(vereward).getEpochIdByTime(startTime);
      uint256 endEpochId = IReward(vereward).getEpochIdByTime(endTime);
      collectUnderlyingReward(startEpochId, endEpochId);
      uint256 reward = 0;
      uint256 userLockStart;
      uint256 userLockEnd;
      uint256 collectedTime;
      for (uint i = startEpochId; i <= endEpochId; i++) {
        uint256 reward_i = rewardCollected[i];
        (uint epochStartTime, uint epochEndTime, ) = IReward(vereward).getEpochInfo(i);
        // user's unclaimed time span in an epoch
        userLockStart = epochStartTime;
        userLockEnd = epochEndTime;
        collectedTime = epochEndTime - epochStartTime;
        if (i == startEpochId) {
          userLockStart = startTime;
        }
        if (i == endEpochId) {
          userLockEnd = endTime; // assuming endTime <= block.timestamp
          collectedTime = block.timestamp - epochStartTime;
        }
        reward_i = reward_i * (userLockEnd - userLockStart) / collectedTime;
        reward += reward_i;
      }
      // update last harvest time
      lastHarvestUntil[tokenId] = endTime;
      uint256 userReward = reward * tokenInfo[tokenId].share / totalLocked;
      require(userReward > 0);
      IERC20(IReward(vereward).rewardToken()).transfer(msg.sender, userReward);
      return userReward;
    }

    function _createLock(uint256 tokenId, uint256 amount, uint256 startTime, uint256 endTime) internal onlyAdmin returns (bool success) {
      uint startDay = startTime / day;
      uint endDay = endTime / day + 1;
      require(endDay - startDay <= 360, "duration is too long");
      for (uint i = startDay; i < endDay; i++) {
        totalAmount[i] = totalAmount[i] + amount;
        if (totalAmount[i] > totalLocked) {
          return (false);
        }
      }
      tokenInfo[tokenId] = TokenInfo(amount, startTime, endTime);
      return (true);
    }

    function setTokenInfo(uint256 tokenId, uint256 amount, uint256 startTime, uint256 endTime) external onlyAdmin {
      bool success = _createLock(tokenId, amount, startTime, endTime);
      require(success);
      emit LogMint(tokenId, amount, startTime, endTime);
    }

    function setTokenInfoBatch(uint256[] calldata tokenIds, uint256 amount, uint256 startTime, uint256 endTime) external onlyAdmin {
      uint len = tokenIds.length;
      for (uint i = 0; i < len; i++) {
        bool success = _createLock(tokenIds[i], amount, startTime, endTime);
        require(success);
      }
      emit LogMintBatch(tokenIds, amount, startTime, endTime);
    }

    function setTokenInfoByShare(uint256 tokenId, uint256 share, uint256 startTime, uint256 endTime) public onlyAdmin {
      uint256 amount = share * totalLocked / totalShare;
      bool success = _createLock(tokenId, amount, startTime, endTime);
      require(success);
      emit LogMint(tokenId, amount, startTime, endTime);
    }

    function setTokenInfoBatchByShare(uint256[] calldata tokenIds, uint256 share, uint256 startTime, uint256 endTime) external onlyAdmin {
      uint len = tokenIds.length;
      uint256 amount = share * totalLocked / totalShare;
      for (uint i = 0; i < len; i++) {
        bool success = _createLock(tokenIds[i], amount, startTime, endTime);
        require(success);
      }
      emit LogMintBatch(tokenIds, amount, startTime, endTime);
    }
}