// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../../interface/IERC20.sol";
import "../../interface/IERC721.sol";
import "../../interface/IERC721Metadata.sol";
import "../../interface/IVe.sol";
import "../../interface/IERC721Receiver.sol";
import "../../interface/IController.sol";
import "../Reentrancy.sol";
import "../../lib/SafeERC20.sol";
import "../../lib/Math.sol";
import "./VeLogo.sol";

contract Ve is IERC721, IERC721Metadata, IVe, Reentrancy {
  using SafeERC20 for IERC20;

  uint internal constant WEEK = 1 weeks;
  uint internal constant MAX_TIME = 4 * 365 * 86400;
  int128 internal constant I_MAX_TIME = 4 * 365 * 86400;
  uint internal constant MULTIPLIER = 1 ether;

  address immutable public override token;
  mapping(uint => LockedBalance) public locked;

  mapping(uint => uint) public ownershipChange;

  uint public override epoch;
  /// @dev epoch -> unsigned point
  mapping(uint => Point) internal _pointHistory;
  /// @dev user -> Point[userEpoch]
  mapping(uint => Point[1000000000]) internal _userPointHistory;

  mapping(uint => uint) public override userPointEpoch;
  mapping(uint => int128) public slopeChanges; // time -> signed slope change

  mapping(uint => uint) public attachments;
  mapping(uint => bool) public voted;
  address public controller;

  string constant public override name = "veCONE";
  string constant public override symbol = "veCONE";
  string constant public version = "1.0.0";
  uint8 constant public decimals = 18;

  /// @dev Current count of token
  uint internal tokenId;

  /// @dev Mapping from NFT ID to the address that owns it.
  mapping(uint => address) internal idToOwner;

  /// @dev Mapping from NFT ID to approved address.
  mapping(uint => address) internal idToApprovals;

  /// @dev Mapping from owner address to count of his tokens.
  mapping(address => uint) internal ownerToNFTokenCount;

  /// @dev Mapping from owner address to mapping of index to tokenIds
  mapping(address => mapping(uint => uint)) internal ownerToNFTokenIdList;

  /// @dev Mapping from NFT ID to index of owner
  mapping(uint => uint) internal tokenToOwnerIndex;

  /// @dev Mapping from owner address to mapping of operator addresses.
  mapping(address => mapping(address => bool)) internal ownerToOperators;

  /// @dev Mapping of interface id to bool about whether or not it's supported
  mapping(bytes4 => bool) internal supportedInterfaces;

  /// @dev ERC165 interface ID of ERC165
  bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;

  /// @dev ERC165 interface ID of ERC721
  bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;

  /// @dev ERC165 interface ID of ERC721Metadata
  bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;

  event Deposit(
    address indexed provider,
    uint tokenId,
    uint value,
    uint indexed locktime,
    DepositType depositType,
    uint ts
  );
  event Withdraw(address indexed provider, uint tokenId, uint value, uint ts);

  /// @notice Contract constructor
  /// @param token_ `ERC20CRV` token address
  constructor(address token_, address controller_) {
    token = token_;
    controller = controller_;
    _pointHistory[0].blk = block.number;
    _pointHistory[0].ts = block.timestamp;

    supportedInterfaces[ERC165_INTERFACE_ID] = true;
    supportedInterfaces[ERC721_INTERFACE_ID] = true;
    supportedInterfaces[ERC721_METADATA_INTERFACE_ID] = true;

    // mint-ish
    emit Transfer(address(0), address(this), tokenId);
    // burn-ish
    emit Transfer(address(this), address(0), tokenId);
  }

  function _voter() internal view returns (address) {
    return IController(controller).voter();
  }

  /// @dev Interface identification is specified in ERC-165.
  /// @param _interfaceID Id of the interface
  function supportsInterface(bytes4 _interfaceID) external view override returns (bool) {
    return supportedInterfaces[_interfaceID];
  }

  /// @notice Get the most recently recorded rate of voting power decrease for `_tokenId`
  /// @param _tokenId token of the NFT
  /// @return Value of the slope
  function getLastUserSlope(uint _tokenId) external view returns (int128) {
    uint uEpoch = userPointEpoch[_tokenId];
    return _userPointHistory[_tokenId][uEpoch].slope;
  }

  /// @notice Get the timestamp for checkpoint `_idx` for `_tokenId`
  /// @param _tokenId token of the NFT
  /// @param _idx User epoch number
  /// @return Epoch time of the checkpoint
  function userPointHistoryTs(uint _tokenId, uint _idx) external view returns (uint) {
    return _userPointHistory[_tokenId][_idx].ts;
  }

  /// @notice Get timestamp when `_tokenId`'s lock finishes
  /// @param _tokenId User NFT
  /// @return Epoch time of the lock end
  function lockedEnd(uint _tokenId) external view returns (uint) {
    return locked[_tokenId].end;
  }

  /// @dev Returns the number of NFTs owned by `_owner`.
  ///      Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
  /// @param _owner Address for whom to query the balance.
  function _balance(address _owner) internal view returns (uint) {
    return ownerToNFTokenCount[_owner];
  }

  /// @dev Returns the number of NFTs owned by `_owner`.
  ///      Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
  /// @param _owner Address for whom to query the balance.
  function balanceOf(address _owner) external view override returns (uint) {
    return _balance(_owner);
  }

  /// @dev Returns the address of the owner of the NFT.
  /// @param _tokenId The identifier for an NFT.
  function ownerOf(uint _tokenId) public view override returns (address) {
    return idToOwner[_tokenId];
  }

  /// @dev Get the approved address for a single NFT.
  /// @param _tokenId ID of the NFT to query the approval of.
  function getApproved(uint _tokenId) external view override returns (address) {
    return idToApprovals[_tokenId];
  }

  /// @dev Checks if `_operator` is an approved operator for `_owner`.
  /// @param _owner The address that owns the NFTs.
  /// @param _operator The address that acts on behalf of the owner.
  function isApprovedForAll(address _owner, address _operator) external view override returns (bool) {
    return (ownerToOperators[_owner])[_operator];
  }

  /// @dev  Get token by index
  function tokenOfOwnerByIndex(address _owner, uint _tokenIndex) external view returns (uint) {
    return ownerToNFTokenIdList[_owner][_tokenIndex];
  }

  /// @dev Returns whether the given spender can transfer a given token ID
  /// @param _spender address of the spender to query
  /// @param _tokenId uint ID of the token to be transferred
  /// @return bool whether the msg.sender is approved for the given token ID, is an operator of the owner, or is the owner of the token
  function _isApprovedOrOwner(address _spender, uint _tokenId) internal view returns (bool) {
    address owner = idToOwner[_tokenId];
    bool spenderIsOwner = owner == _spender;
    bool spenderIsApproved = _spender == idToApprovals[_tokenId];
    bool spenderIsApprovedForAll = (ownerToOperators[owner])[_spender];
    return spenderIsOwner || spenderIsApproved || spenderIsApprovedForAll;
  }

  function isApprovedOrOwner(address _spender, uint _tokenId) external view override returns (bool) {
    return _isApprovedOrOwner(_spender, _tokenId);
  }

  /// @dev Add a NFT to an index mapping to a given address
  /// @param _to address of the receiver
  /// @param _tokenId uint ID Of the token to be added
  function _addTokenToOwnerList(address _to, uint _tokenId) internal {
    uint currentCount = _balance(_to);

    ownerToNFTokenIdList[_to][currentCount] = _tokenId;
    tokenToOwnerIndex[_tokenId] = currentCount;
  }

  /// @dev Remove a NFT from an index mapping to a given address
  /// @param _from address of the sender
  /// @param _tokenId uint ID Of the token to be removed
  function _removeTokenFromOwnerList(address _from, uint _tokenId) internal {
    // Delete
    uint currentCount = _balance(_from) - 1;
    uint currentIndex = tokenToOwnerIndex[_tokenId];

    if (currentCount == currentIndex) {
      // update ownerToNFTokenIdList
      ownerToNFTokenIdList[_from][currentCount] = 0;
      // update tokenToOwnerIndex
      tokenToOwnerIndex[_tokenId] = 0;
    } else {
      uint lastTokenId = ownerToNFTokenIdList[_from][currentCount];

      // Add
      // update ownerToNFTokenIdList
      ownerToNFTokenIdList[_from][currentIndex] = lastTokenId;
      // update tokenToOwnerIndex
      tokenToOwnerIndex[lastTokenId] = currentIndex;

      // Delete
      // update ownerToNFTokenIdList
      ownerToNFTokenIdList[_from][currentCount] = 0;
      // update tokenToOwnerIndex
      tokenToOwnerIndex[_tokenId] = 0;
    }
  }

  /// @dev Add a NFT to a given address
  ///      Throws if `_tokenId` is owned by someone.
  function _addTokenTo(address _to, uint _tokenId) internal {
    // assume always call on new tokenId or after _removeTokenFrom() call
    // Change the owner
    idToOwner[_tokenId] = _to;
    // Update owner token index tracking
    _addTokenToOwnerList(_to, _tokenId);
    // Change count tracking
    ownerToNFTokenCount[_to] += 1;
  }

  /// @dev Remove a NFT from a given address
  ///      Throws if `_from` is not the current owner.
  function _removeTokenFrom(address _from, uint _tokenId) internal {
    require(idToOwner[_tokenId] == _from, "!owner remove");
    // Change the owner
    idToOwner[_tokenId] = address(0);
    // Update owner token index tracking
    _removeTokenFromOwnerList(_from, _tokenId);
    // Change count tracking
    ownerToNFTokenCount[_from] -= 1;
  }

  /// @dev Execute transfer of a NFT.
  ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
  ///      address for this NFT. (NOTE: `msg.sender` not allowed in internal function so pass `_sender`.)
  ///      Throws if `_to` is the zero address.
  ///      Throws if `_from` is not the current owner.
  ///      Throws if `_tokenId` is not a valid NFT.
  function _transferFrom(
    address _from,
    address _to,
    uint _tokenId,
    address _sender
  ) internal {
    require(attachments[_tokenId] == 0 && !voted[_tokenId], "attached");
    require(_isApprovedOrOwner(_sender, _tokenId), "!owner sender");
    require(_to != address(0), "dst is zero");
    // from address will be checked in _removeTokenFrom()

    if (idToApprovals[_tokenId] != address(0)) {
      // Reset approvals
      idToApprovals[_tokenId] = address(0);
    }
    _removeTokenFrom(_from, _tokenId);
    _addTokenTo(_to, _tokenId);
    // Set the block of ownership transfer (for Flash NFT protection)
    ownershipChange[_tokenId] = block.number;
    // Log the transfer
    emit Transfer(_from, _to, _tokenId);
  }

  /* TRANSFER FUNCTIONS */
  /// @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT.
  ///      Throws if `_from` is not the current owner.
  ///      Throws if `_to` is the zero address.
  ///      Throws if `_tokenId` is not a valid NFT.
  /// @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
  ///        they maybe be permanently lost.
  /// @param _from The current owner of the NFT.
  /// @param _to The new owner.
  /// @param _tokenId The NFT to transfer.
  function transferFrom(
    address _from,
    address _to,
    uint _tokenId
  ) external override {
    _transferFrom(_from, _to, _tokenId, msg.sender);
  }

  function _isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.
    uint size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  /// @dev Transfers the ownership of an NFT from one address to another address.
  ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the
  ///      approved address for this NFT.
  ///      Throws if `_from` is not the current owner.
  ///      Throws if `_to` is the zero address.
  ///      Throws if `_tokenId` is not a valid NFT.
  ///      If `_to` is a smart contract, it calls `onERC721Received` on `_to` and throws if
  ///      the return value is not `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`.
  /// @param _from The current owner of the NFT.
  /// @param _to The new owner.
  /// @param _tokenId The NFT to transfer.
  /// @param _data Additional data with no specified format, sent in call to `_to`.
  function safeTransferFrom(
    address _from,
    address _to,
    uint _tokenId,
    bytes memory _data
  ) public override {
    _transferFrom(_from, _to, _tokenId, msg.sender);

    if (_isContract(_to)) {
      // Throws if transfer destination is a contract which does not implement 'onERC721Received'
      try IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) returns (bytes4) {} catch (
        bytes memory reason
      ) {
        if (reason.length == 0) {
          revert('ERC721: transfer to non ERC721Receiver implementer');
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    }
  }

  /// @dev Transfers the ownership of an NFT from one address to another address.
  ///      Throws unless `msg.sender` is the current owner, an authorized operator, or the
  ///      approved address for this NFT.
  ///      Throws if `_from` is not the current owner.
  ///      Throws if `_to` is the zero address.
  ///      Throws if `_tokenId` is not a valid NFT.
  ///      If `_to` is a smart contract, it calls `onERC721Received` on `_to` and throws if
  ///      the return value is not `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`.
  /// @param _from The current owner of the NFT.
  /// @param _to The new owner.
  /// @param _tokenId The NFT to transfer.
  function safeTransferFrom(
    address _from,
    address _to,
    uint _tokenId
  ) external override {
    safeTransferFrom(_from, _to, _tokenId, '');
  }

  /// @dev Set or reaffirm the approved address for an NFT. The zero address indicates there is no approved address.
  ///      Throws unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.
  ///      Throws if `_tokenId` is not a valid NFT. (NOTE: This is not written the EIP)
  ///      Throws if `_approved` is the current owner. (NOTE: This is not written the EIP)
  /// @param _approved Address to be approved for the given NFT ID.
  /// @param _tokenId ID of the token to be approved.
  function approve(address _approved, uint _tokenId) public override {
    address owner = idToOwner[_tokenId];
    // Throws if `_tokenId` is not a valid NFT
    require(owner != address(0), "invalid id");
    // Throws if `_approved` is the current owner
    require(_approved != owner, "self approve");
    // Check requirements
    bool senderIsOwner = (idToOwner[_tokenId] == msg.sender);
    bool senderIsApprovedForAll = (ownerToOperators[owner])[msg.sender];
    require(senderIsOwner || senderIsApprovedForAll, "!owner");
    // Set the approval
    idToApprovals[_tokenId] = _approved;
    emit Approval(owner, _approved, _tokenId);
  }

  /// @dev Enables or disables approval for a third party ("operator") to manage all of
  ///      `msg.sender`'s assets. It also emits the ApprovalForAll event.
  ///      Throws if `_operator` is the `msg.sender`. (NOTE: This is not written the EIP)
  /// @notice This works even if sender doesn't own any tokens at the time.
  /// @param _operator Address to add to the set of authorized operators.
  /// @param _approved True if the operators is approved, false to revoke approval.
  function setApprovalForAll(address _operator, bool _approved) external override {
    // Throws if `_operator` is the `msg.sender`
    require(_operator != msg.sender, "operator is sender");
    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /// @dev Function to mint tokens
  ///      Throws if `_to` is zero address.
  ///      Throws if `_tokenId` is owned by someone.
  /// @param _to The address that will receive the minted tokens.
  /// @param _tokenId The token id to mint.
  /// @return A boolean that indicates if the operation was successful.
  function _mint(address _to, uint _tokenId) internal returns (bool) {
    // Throws if `_to` is zero address
    require(_to != address(0), "zero dst");
    // Add NFT. Throws if `_tokenId` is owned by someone
    _addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
    return true;
  }

  /// @notice Record global and per-user data to checkpoint
  /// @param _tokenId NFT token ID. No user checkpoint if 0
  /// @param oldLocked Pevious locked amount / end lock time for the user
  /// @param newLocked New locked amount / end lock time for the user
  function _checkpoint(
    uint _tokenId,
    LockedBalance memory oldLocked,
    LockedBalance memory newLocked
  ) internal {
    Point memory uOld;
    Point memory uNew;
    int128 oldDSlope = 0;
    int128 newDSlope = 0;
    uint _epoch = epoch;

    if (_tokenId != 0) {
      // Calculate slopes and biases
      // Kept at zero when they have to
      if (oldLocked.end > block.timestamp && oldLocked.amount > 0) {
        uOld.slope = oldLocked.amount / I_MAX_TIME;
        uOld.bias = uOld.slope * int128(int256(oldLocked.end - block.timestamp));
      }
      if (newLocked.end > block.timestamp && newLocked.amount > 0) {
        uNew.slope = newLocked.amount / I_MAX_TIME;
        uNew.bias = uNew.slope * int128(int256(newLocked.end - block.timestamp));
      }

      // Read values of scheduled changes in the slope
      // oldLocked.end can be in the past and in the future
      // newLocked.end can ONLY by in the FUTURE unless everything expired: than zeros
      oldDSlope = slopeChanges[oldLocked.end];
      if (newLocked.end != 0) {
        if (newLocked.end == oldLocked.end) {
          newDSlope = oldDSlope;
        } else {
          newDSlope = slopeChanges[newLocked.end];
        }
      }
    }

    Point memory lastPoint = Point({bias : 0, slope : 0, ts : block.timestamp, blk : block.number});
    if (_epoch > 0) {
      lastPoint = _pointHistory[_epoch];
    }
    uint lastCheckpoint = lastPoint.ts;
    // initialLastPoint is used for extrapolation to calculate block number
    // (approximately, for *At methods) and save them
    // as we cannot figure that out exactly from inside the contract
    Point memory initialLastPoint = lastPoint;
    uint blockSlope = 0;
    // dblock/dt
    if (block.timestamp > lastPoint.ts) {
      blockSlope = (MULTIPLIER * (block.number - lastPoint.blk)) / (block.timestamp - lastPoint.ts);
    }
    // If last point is already recorded in this block, slope=0
    // But that's ok b/c we know the block in such case

    // Go over weeks to fill history and calculate what the current point is
    {
      uint ti = (lastCheckpoint / WEEK) * WEEK;
      // Hopefully it won't happen that this won't get used in 5 years!
      // If it does, users will be able to withdraw but vote weight will be broken
      for (uint i = 0; i < 255; ++i) {
        ti += WEEK;
        int128 dSlope = 0;
        if (ti > block.timestamp) {
          ti = block.timestamp;
        } else {
          dSlope = slopeChanges[ti];
        }
        lastPoint.bias = Math.positiveInt128(lastPoint.bias - lastPoint.slope * int128(int256(ti - lastCheckpoint)));
        lastPoint.slope = Math.positiveInt128(lastPoint.slope + dSlope);
        lastCheckpoint = ti;
        lastPoint.ts = ti;
        lastPoint.blk = initialLastPoint.blk + (blockSlope * (ti - initialLastPoint.ts)) / MULTIPLIER;
        _epoch += 1;
        if (ti == block.timestamp) {
          lastPoint.blk = block.number;
          break;
        } else {
          _pointHistory[_epoch] = lastPoint;
        }
      }
    }

    epoch = _epoch;
    // Now pointHistory is filled until t=now

    if (_tokenId != 0) {
      // If last point was in this block, the slope change has been applied already
      // But in such case we have 0 slope(s)
      lastPoint.slope = Math.positiveInt128(lastPoint.slope + (uNew.slope - uOld.slope));
      lastPoint.bias = Math.positiveInt128(lastPoint.bias + (uNew.bias - uOld.bias));
    }

    // Record the changed point into history
    _pointHistory[_epoch] = lastPoint;

    if (_tokenId != 0) {
      // Schedule the slope changes (slope is going down)
      // We subtract newUserSlope from [newLocked.end]
      // and add old_user_slope to [old_locked.end]
      if (oldLocked.end > block.timestamp) {
        // old_dslope was <something> - u_old.slope, so we cancel that
        oldDSlope += uOld.slope;
        if (newLocked.end == oldLocked.end) {
          oldDSlope -= uNew.slope;
          // It was a new deposit, not extension
        }
        slopeChanges[oldLocked.end] = oldDSlope;
      }

      if (newLocked.end > block.timestamp) {
        if (newLocked.end > oldLocked.end) {
          newDSlope -= uNew.slope;
          // old slope disappeared at this point
          slopeChanges[newLocked.end] = newDSlope;
        }
        // else: we recorded it already in oldDSlope
      }
      // Now handle user history
      uint userEpoch = userPointEpoch[_tokenId] + 1;

      userPointEpoch[_tokenId] = userEpoch;
      uNew.ts = block.timestamp;
      uNew.blk = block.number;
      _userPointHistory[_tokenId][userEpoch] = uNew;
    }
  }

  /// @notice Deposit and lock tokens for a user
  /// @param _tokenId NFT that holds lock
  /// @param _value Amount to deposit
  /// @param unlockTime New time when to unlock the tokens, or 0 if unchanged
  /// @param lockedBalance Previous locked amount / timestamp
  /// @param depositType The type of deposit
  function _depositFor(
    uint _tokenId,
    uint _value,
    uint unlockTime,
    LockedBalance memory lockedBalance,
    DepositType depositType
  ) internal {
    LockedBalance memory _locked = lockedBalance;

    LockedBalance memory oldLocked;
    (oldLocked.amount, oldLocked.end) = (_locked.amount, _locked.end);
    // Adding to existing lock, or if a lock is expired - creating a new one
    _locked.amount += int128(int256(_value));
    if (unlockTime != 0) {
      _locked.end = unlockTime;
    }
    locked[_tokenId] = _locked;

    // Possibilities:
    // Both old_locked.end could be current or expired (>/< block.timestamp)
    // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
    // _locked.end > block.timestamp (always)
    _checkpoint(_tokenId, oldLocked, _locked);

    address from = msg.sender;
    if (_value != 0 && depositType != DepositType.MERGE_TYPE) {
      IERC20(token).safeTransferFrom(from, address(this), _value);
    }

    emit Deposit(from, _tokenId, _value, _locked.end, depositType, block.timestamp);
  }

  function voting(uint _tokenId) external override {
    require(msg.sender == _voter(), "!voter");
    voted[_tokenId] = true;
  }

  function abstain(uint _tokenId) external override {
    require(msg.sender == _voter(), "!voter");
    voted[_tokenId] = false;
  }

  function attachToken(uint _tokenId) external override {
    require(msg.sender == _voter(), "!voter");
    attachments[_tokenId] = attachments[_tokenId] + 1;
  }

  function detachToken(uint _tokenId) external override {
    require(msg.sender == _voter(), "!voter");
    attachments[_tokenId] = attachments[_tokenId] - 1;
  }

  function merge(uint _from, uint _to) external {
    require(attachments[_from] == 0 && !voted[_from], "attached");
    require(_from != _to, "the same");
    require(_isApprovedOrOwner(msg.sender, _from), "!owner from");
    require(_isApprovedOrOwner(msg.sender, _to), "!owner to");

    LockedBalance memory _locked0 = locked[_from];
    LockedBalance memory _locked1 = locked[_to];
    uint value0 = uint(int256(_locked0.amount));
    uint end = _locked0.end >= _locked1.end ? _locked0.end : _locked1.end;

    locked[_from] = LockedBalance(0, 0);
    _checkpoint(_from, _locked0, LockedBalance(0, 0));
    _burn(_from);
    _depositFor(_to, value0, end, _locked1, DepositType.MERGE_TYPE);
  }

  function block_number() external view returns (uint) {
    return block.number;
  }

  /// @notice Record global data to checkpoint
  function checkpoint() external override {
    _checkpoint(0, LockedBalance(0, 0), LockedBalance(0, 0));
  }

  /// @notice Deposit `_value` tokens for `_tokenId` and add to the lock
  /// @dev Anyone (even a smart contract) can deposit for someone else, but
  ///      cannot extend their locktime and deposit for a brand new user
  /// @param _tokenId lock NFT
  /// @param _value Amount to add to user's lock
  function depositFor(uint _tokenId, uint _value) external lock override {
    require(_value > 0, "zero value");
    LockedBalance memory _locked = locked[_tokenId];
    require(_locked.amount > 0, 'No existing lock found');
    require(_locked.end > block.timestamp, 'Cannot add to expired lock. Withdraw');
    _depositFor(_tokenId, _value, 0, _locked, DepositType.DEPOSIT_FOR_TYPE);
  }

  /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
  /// @param _value Amount to deposit
  /// @param _lockDuration Number of seconds to lock tokens for (rounded down to nearest week)
  /// @param _to Address to deposit
  function _createLock(uint _value, uint _lockDuration, address _to) internal returns (uint) {
    require(_value > 0, "zero value");
    // Lock time is rounded down to weeks
    uint unlockTime = (block.timestamp + _lockDuration) / WEEK * WEEK;
    require(unlockTime > block.timestamp, 'Can only lock until time in the future');
    require(unlockTime <= block.timestamp + MAX_TIME, 'Voting lock can be 4 years max');

    ++tokenId;
    uint _tokenId = tokenId;
    _mint(_to, _tokenId);

    _depositFor(_tokenId, _value, unlockTime, locked[_tokenId], DepositType.CREATE_LOCK_TYPE);
    return _tokenId;
  }

  /// @notice Deposit `_value` tokens for `_to` and lock for `_lock_duration`
  /// @param _value Amount to deposit
  /// @param _lockDuration Number of seconds to lock tokens for (rounded down to nearest week)
  /// @param _to Address to deposit
  function createLockFor(uint _value, uint _lockDuration, address _to)
  external lock override returns (uint) {
    return _createLock(_value, _lockDuration, _to);
  }

  /// @notice Deposit `_value` tokens for `msg.sender` and lock for `_lock_duration`
  /// @param _value Amount to deposit
  /// @param _lockDuration Number of seconds to lock tokens for (rounded down to nearest week)
  function createLock(uint _value, uint _lockDuration) external lock returns (uint) {
    return _createLock(_value, _lockDuration, msg.sender);
  }

  /// @notice Deposit `_value` additional tokens for `_tokenId` without modifying the unlock time
  /// @param _value Amount of tokens to deposit and add to the lock
  function increaseAmount(uint _tokenId, uint _value) external lock {
    LockedBalance memory _locked = locked[_tokenId];
    require(_locked.amount > 0, 'No existing lock found');
    require(_locked.end > block.timestamp, 'Cannot add to expired lock. Withdraw');
    require(_isApprovedOrOwner(msg.sender, _tokenId), "!owner");
    require(_value > 0, "zero value");

    _depositFor(_tokenId, _value, 0, _locked, DepositType.INCREASE_LOCK_AMOUNT);
  }

  /// @notice Extend the unlock time for `_tokenId`
  /// @param _lockDuration New number of seconds until tokens unlock
  function increaseUnlockTime(uint _tokenId, uint _lockDuration) external lock {
    LockedBalance memory _locked = locked[_tokenId];
    // Lock time is rounded down to weeks
    uint unlockTime = (block.timestamp + _lockDuration) / WEEK * WEEK;
    require(_locked.amount > 0, 'Nothing is locked');
    require(_locked.end > block.timestamp, 'Lock expired');
    require(unlockTime > _locked.end, 'Can only increase lock duration');
    require(unlockTime <= block.timestamp + MAX_TIME, 'Voting lock can be 4 years max');
    require(_isApprovedOrOwner(msg.sender, _tokenId), "!owner");

    _depositFor(_tokenId, 0, unlockTime, _locked, DepositType.INCREASE_UNLOCK_TIME);
  }

  /// @notice Withdraw all tokens for `_tokenId`
  /// @dev Only possible if the lock has expired
  function withdraw(uint _tokenId) external lock {
    require(_isApprovedOrOwner(msg.sender, _tokenId), "!owner");
    require(attachments[_tokenId] == 0 && !voted[_tokenId], "attached");
    LockedBalance memory _locked = locked[_tokenId];
    require(block.timestamp >= _locked.end, "The lock did not expire");

    uint value = uint(int256(_locked.amount));
    locked[_tokenId] = LockedBalance(0, 0);

    // old_locked can have either expired <= timestamp or zero end
    // _locked has only 0 end
    // Both can have >= 0 amount
    _checkpoint(_tokenId, _locked, LockedBalance(0, 0));

    IERC20(token).safeTransfer(msg.sender, value);

    // Burn the NFT
    _burn(_tokenId);

    emit Withdraw(msg.sender, _tokenId, value, block.timestamp);
  }

  // The following ERC20/minime-compatible methods are not real balanceOf and supply!
  // They measure the weights for the purpose of voting, so they don't represent
  // real coins.

  /// @notice Binary search to estimate timestamp for block number
  /// @param _block Block to find
  /// @param maxEpoch Don't go beyond this epoch
  /// @return Approximate timestamp for block
  function _findBlockEpoch(uint _block, uint maxEpoch) internal view returns (uint) {
    // Binary search
    uint _min = 0;
    uint _max = maxEpoch;
    for (uint i = 0; i < 128; ++i) {
      // Will be always enough for 128-bit numbers
      if (_min >= _max) {
        break;
      }
      uint _mid = (_min + _max + 1) / 2;
      if (_pointHistory[_mid].blk <= _block) {
        _min = _mid;
      } else {
        _max = _mid - 1;
      }
    }
    return _min;
  }

  /// @notice Get the current voting power for `_tokenId`
  /// @dev Adheres to the ERC20 `balanceOf` interface for Aragon compatibility
  /// @param _tokenId NFT for lock
  /// @param _t Epoch time to return voting power at
  /// @return User voting power
  function _balanceOfNFT(uint _tokenId, uint _t) internal view returns (uint) {
    uint _epoch = userPointEpoch[_tokenId];
    if (_epoch == 0) {
      return 0;
    } else {
      Point memory lastPoint = _userPointHistory[_tokenId][_epoch];
      lastPoint.bias -= lastPoint.slope * int128(int256(_t) - int256(lastPoint.ts));
      if (lastPoint.bias < 0) {
        lastPoint.bias = 0;
      }
      return uint(int256(lastPoint.bias));
    }
  }

  /// @dev Returns current token URI metadata
  /// @param _tokenId Token ID to fetch URI for.
  function tokenURI(uint _tokenId) external view override returns (string memory) {
    require(idToOwner[_tokenId] != address(0), "Query for nonexistent token");
    LockedBalance memory _locked = locked[_tokenId];
    return
    _tokenURI(
      _tokenId,
      _balanceOfNFT(_tokenId, block.timestamp),
      _locked.end,
      uint(int256(_locked.amount))
    );
  }

  function balanceOfNFT(uint _tokenId) external view override returns (uint) {
    // flash NFT protection
    if (ownershipChange[_tokenId] == block.number) {
      return 0;
    }
    return _balanceOfNFT(_tokenId, block.timestamp);
  }

  function balanceOfNFTAt(uint _tokenId, uint _t) external view returns (uint) {
    return _balanceOfNFT(_tokenId, _t);
  }

  /// @notice Measure voting power of `_tokenId` at block height `_block`
  /// @dev Adheres to MiniMe `balanceOfAt` interface: https://github.com/Giveth/minime
  /// @param _tokenId User's wallet NFT
  /// @param _block Block to calculate the voting power at
  /// @return Voting power
  function _balanceOfAtNFT(uint _tokenId, uint _block) internal view returns (uint) {
    // Copying and pasting totalSupply code because Vyper cannot pass by
    // reference yet
    require(_block <= block.number, "only old block");

    // Binary search
    uint _min = 0;
    uint _max = userPointEpoch[_tokenId];
    for (uint i = 0; i < 128; ++i) {
      // Will be always enough for 128-bit numbers
      if (_min >= _max) {
        break;
      }
      uint _mid = (_min + _max + 1) / 2;
      if (_userPointHistory[_tokenId][_mid].blk <= _block) {
        _min = _mid;
      } else {
        _max = _mid - 1;
      }
    }

    Point memory uPoint = _userPointHistory[_tokenId][_min];

    uint maxEpoch = epoch;
    uint _epoch = _findBlockEpoch(_block, maxEpoch);
    Point memory point0 = _pointHistory[_epoch];
    uint dBlock = 0;
    uint dt = 0;
    if (_epoch < maxEpoch) {
      Point memory point1 = _pointHistory[_epoch + 1];
      dBlock = point1.blk - point0.blk;
      dt = point1.ts - point0.ts;
    } else {
      dBlock = block.number - point0.blk;
      dt = block.timestamp - point0.ts;
    }
    uint blockTime = point0.ts;
    if (dBlock != 0 && _block > point0.blk) {
      blockTime += (dt * (_block - point0.blk)) / dBlock;
    }

    uPoint.bias -= uPoint.slope * int128(int256(blockTime - uPoint.ts));
    return uint(uint128(Math.positiveInt128(uPoint.bias)));
  }

  function balanceOfAtNFT(uint _tokenId, uint _block) external view returns (uint) {
    return _balanceOfAtNFT(_tokenId, _block);
  }

  /// @notice Calculate total voting power at some point in the past
  /// @param point The point (bias/slope) to start search from
  /// @param t Time to calculate the total voting power at
  /// @return Total voting power at that time
  function _supplyAt(Point memory point, uint t) internal view returns (uint) {
    Point memory lastPoint = point;
    uint ti = (lastPoint.ts / WEEK) * WEEK;
    for (uint i = 0; i < 255; ++i) {
      ti += WEEK;
      int128 dSlope = 0;
      if (ti > t) {
        ti = t;
      } else {
        dSlope = slopeChanges[ti];
      }
      lastPoint.bias -= lastPoint.slope * int128(int256(ti - lastPoint.ts));
      if (ti == t) {
        break;
      }
      lastPoint.slope += dSlope;
      lastPoint.ts = ti;
    }
    return uint(uint128(Math.positiveInt128(lastPoint.bias)));
  }

  /// @notice Calculate total voting power
  /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
  /// @return Total voting power
  function totalSupplyAtT(uint t) public view returns (uint) {
    uint _epoch = epoch;
    Point memory lastPoint = _pointHistory[_epoch];
    return _supplyAt(lastPoint, t);
  }

  function totalSupply() external view returns (uint) {
    return totalSupplyAtT(block.timestamp);
  }

  /// @notice Calculate total voting power at some point in the past
  /// @param _block Block to calculate the total voting power at
  /// @return Total voting power at `_block`
  function totalSupplyAt(uint _block) external view returns (uint) {
    require(_block <= block.number, "only old blocks");
    uint _epoch = epoch;
    uint targetEpoch = _findBlockEpoch(_block, _epoch);

    Point memory point = _pointHistory[targetEpoch];
    // it is possible only for a block before the launch
    // return 0 as more clear answer than revert
    if (point.blk > _block) {
      return 0;
    }
    uint dt = 0;
    if (targetEpoch < _epoch) {
      Point memory point_next = _pointHistory[targetEpoch + 1];
      // next point block can not be the same or lower
      dt = ((_block - point.blk) * (point_next.ts - point.ts)) / (point_next.blk - point.blk);
    } else {
      if (point.blk != block.number) {
        dt = ((_block - point.blk) * (block.timestamp - point.ts)) / (block.number - point.blk);
      }
    }
    // Now dt contains info on how far are we beyond point
    return _supplyAt(point, point.ts + dt);
  }

  function _tokenURI(uint _tokenId, uint _balanceOf, uint _lockedEnd, uint _value) internal view returns (string memory output) {
    uint untilEnd = (block.timestamp < _lockedEnd) ? _lockedEnd - block.timestamp : 0;
    return VeLogo.tokenURI(_tokenId, _balanceOf, untilEnd, _value);
  }

  function _burn(uint _tokenId) internal {
    address owner = ownerOf(_tokenId);
    // Clear approval
    approve(address(0), _tokenId);
    // Remove token
    _removeTokenFrom(msg.sender, _tokenId);
    emit Transfer(owner, address(0), _tokenId);
  }

  function userPointHistory(uint _tokenId, uint _loc) external view override returns (Point memory) {
    return _userPointHistory[_tokenId][_loc];
  }

  function pointHistory(uint _loc) external view override returns (Point memory) {
    return _pointHistory[_loc];
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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

pragma solidity 0.8.15;

import "./IERC721.sol";

/**
* @title ERC-721 Non-Fungible Token Standard, optional metadata extension
* @dev See https://eips.ethereum.org/EIPS/eip-721
*/
interface IERC721Metadata is IERC721 {
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
  function tokenURI(uint tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IVe {

  enum DepositType {
    DEPOSIT_FOR_TYPE,
    CREATE_LOCK_TYPE,
    INCREASE_LOCK_AMOUNT,
    INCREASE_UNLOCK_TIME,
    MERGE_TYPE
  }

  struct Point {
    int128 bias;
    int128 slope; // # -dweight / dt
    uint ts;
    uint blk; // block
  }
  /* We cannot really do block numbers per se b/c slope is per time, not per block
  * and per block could be fairly bad b/c Ethereum changes blocktimes.
  * What we can do is to extrapolate ***At functions */

  struct LockedBalance {
    int128 amount;
    uint end;
  }

  function token() external view returns (address);

  function balanceOfNFT(uint) external view returns (uint);

  function isApprovedOrOwner(address, uint) external view returns (bool);

  function createLockFor(uint, uint, address) external returns (uint);

  function userPointEpoch(uint tokenId) external view returns (uint);

  function epoch() external view returns (uint);

  function userPointHistory(uint tokenId, uint loc) external view returns (Point memory);

  function pointHistory(uint loc) external view returns (Point memory);

  function checkpoint() external;

  function depositFor(uint tokenId, uint value) external;

  function attachToken(uint tokenId) external;

  function detachToken(uint tokenId) external;

  function voting(uint tokenId) external;

  function abstain(uint tokenId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
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

pragma solidity 0.8.15;

interface IController {

  function governance() external view returns (address);

  function veDist() external view returns (address);

  function voter() external view returns (address);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

abstract contract Reentrancy {

  /// @dev simple re-entrancy check
  uint internal _unlocked = 1;

  modifier lock() {
    require(_unlocked == 1, "Reentrant call");
    _unlocked = 2;
    _;
    _unlocked = 1;
  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity 0.8.15;

import "../interface/IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint value
  ) internal {
    uint newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  /**
   * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
    // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
    // the target address contains contract code and also asserts for success in the low-level call.

    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      // Return data is optional
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

library Math {

  function max(uint a, uint b) internal pure returns (uint) {
    return a >= b ? a : b;
  }

  function min(uint a, uint b) internal pure returns (uint) {
    return a < b ? a : b;
  }

  function positiveInt128(int128 value) internal pure returns (int128) {
    return value < 0 ? int128(0) : value;
  }

  function closeTo(uint a, uint b, uint target) internal pure returns (bool) {
    if (a > b) {
      if (a - b <= target) {
        return true;
      }
    } else {
      if (b - a <= target) {
        return true;
      }
    }
    return false;
  }

  function sqrt(uint y) internal pure returns (uint z) {
    if (y > 3) {
      z = y;
      uint x = y / 2 + 1;
      while (x < z) {
        z = x;
        x = (y / x + x) / 2;
      }
    } else if (y != 0) {
      z = 1;
    }
  }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./../../lib/Base64.sol";



/// @title Library for storing SVG image of veNFT.
/// @author belbix
library VeLogo {

  /// @dev Return SVG logo of veNFT.
  function tokenURI(uint _tokenId, uint _balanceOf, uint untilEnd, uint _value) public pure returns (string memory output) {
    output = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 900"><style>.b{fill:#4F6295;}.g{fill:#D3F85A;}.f{fill:#D0DA55;}.w{fill:#FFFFFF;}.s{font-size:37px;}</style><rect fill="#2B3A5B" width="600" height="900"/><rect class="b" x="55" y="424" width="544" height="98"/><rect class="b" x="0" y="544" width="517" height="98"/><rect class="b" x="0" y="772" width="516" height="98"/><rect class="b" x="55" y="658" width="544" height="98"/><path class="g" d="M317.3,348.9h-0.4c-1,0-2-0.3-2.7-1c-0.9-0.8-1.5-1.9-1.5-3.1l-1.8-51.4c-0.1-2.2,1.4-4,3.6-4.3c40.9-6.6,70.6-42.8,69.1-84.3c-0.5-13.3-4.2-26.5-10.8-38c-1.1-1.9-0.5-4.4,1.3-5.6l42.5-28.2c0.9-0.7,2.1-1,3.3-0.7c1.1,0.2,2.2,0.9,2.8,1.9c0.1,0.1,0.1,0.3,0.1,0.4c21.7,36.1,26.2,79.7,12.5,119.5c-8.9,25.8-24.8,48.3-46.2,65.1C368.5,335.7,343.6,345.9,317.3,348.9C317.4,348.9,317.4,348.9,317.3,348.9z M419.2,134c-0.5,0-1,0.2-1.4,0.5l-0.4,0.3l-42.2,28c-1.1,0.7-1.4,2.2-0.8,3.3c6.7,11.7,10.5,25.1,11,38.8c1.5,42.3-28.8,79.4-70.6,86.1c-1.2,0.2-2.1,1.3-2.1,2.6l1.8,51.4c0,0.7,0.3,1.3,0.8,1.8c0.4,0.4,1,0.6,1.6,0.6h0.3c25.9-3,50.4-13.1,70.9-29.3c21.1-16.6,36.9-38.8,45.6-64.3c13.6-39.5,9.1-82.6-12.5-118.4c-0.1-0.1-0.1-0.2-0.1-0.3c-0.4-0.4-0.9-0.7-1.4-0.8C419.5,134,419.4,134,419.2,134z M340.1,337.3c-0.1,0-0.3,0-0.4-0.1c-0.2-0.1-0.4-0.3-0.4-0.5l-12.8-42.6c-0.1-0.3,0-0.6,0.1-0.8c0.1-0.2,0.4-0.3,0.6-0.3c4.4-1.4,8.7-3,12.6-4.9c0.2-0.1,0.4-0.1,0.7,0c0.2,0.1,0.4,0.2,0.5,0.4l19.1,40.1c0.2,0.4,0,1-0.4,1.2c-6.3,3-12.8,5.5-19.3,7.5C340.3,337.3,340.2,337.3,340.1,337.3z M328.4,294.5l12.3,40.9c5.9-1.9,11.8-4.1,17.4-6.8L339.9,290C336.2,291.7,332.4,293.2,328.4,294.5z M376.5,320c-0.1,0-0.1,0-0.2,0c-0.2,0-0.4-0.2-0.6-0.4l-24.7-36.9c-0.3-0.4-0.2-0.9,0.2-1.2c3.7-2.5,7.3-5.4,10.7-8.6c0.2-0.2,0.4-0.2,0.6-0.2c0.2,0,0.5,0.1,0.6,0.3l29.9,32.7c0.3,0.4,0.3,0.9,0,1.2c-4.9,4.5-10.3,8.9-16.2,12.9C376.8,319.9,376.6,320,376.5,320z M353,282.4l23.7,35.4c5.3-3.6,10.2-7.5,14.6-11.6l-28.8-31.4C359.5,277.6,356.3,280.2,353,282.4z M406.1,292.7c-0.2,0-0.4-0.1-0.6-0.2l-34.4-28c-0.4-0.3-0.4-0.8-0.1-1.2c2.8-3.5,5.3-7.2,7.6-11.3c0.1-0.2,0.3-0.4,0.5-0.4c0.2-0.1,0.5,0,0.7,0.1l38.4,22.4c0.4,0.2,0.6,0.8,0.3,1.2c-3.3,5.8-7.3,11.5-11.7,17C406.6,292.6,406.4,292.7,406.1,292.7C406.1,292.7,406.1,292.7,406.1,292.7z M372.8,263.7l33.1,26.9c4-5,7.5-10.2,10.6-15.4l-36.9-21.6C377.6,257.2,375.3,260.6,372.8,263.7z M426.3,258.1c-0.2,0-0.4-0.1-0.5-0.2l-41.1-16.5c-0.4-0.2-0.7-0.7-0.5-1.1c1.6-4.1,3-8.4,4-13c0.1-0.2,0.2-0.4,0.4-0.5c0.2-0.1,0.4-0.2,0.7-0.1l43.3,10.1c0.5,0.1,0.8,0.6,0.7,1c-1.1,4.9-2.4,9.5-4,14.2c-0.7,1.8-1.3,3.7-2,5.5c-0.1,0.3-0.3,0.5-0.6,0.5C426.5,258.1,426.4,258.1,426.3,258.1z M386.2,240.1l39.7,15.9c0.6-1.6,1.2-3.1,1.7-4.6c1.5-4.3,2.7-8.7,3.8-13.2l-41.6-9.7C388.8,232.6,387.6,236.5,386.2,240.1z M435.3,218.8C435.3,218.8,435.3,218.8,435.3,218.8l-44.4-3.7c-0.5,0-0.8-0.5-0.8-0.9c0.2-3.4,0.3-6.6,0.2-9.6c0-1.3-0.1-2.7-0.2-4c0-0.5,0.3-0.9,0.8-0.9l44.4-3.1c0.5,0,0.9,0.3,0.9,0.8c0.5,6.8,0.5,13.8,0,20.6c0,0.2-0.1,0.4-0.3,0.6C435.8,218.7,435.6,218.8,435.3,218.8z M392,213.4l42.6,3.6c0.4-6.2,0.4-12.5,0-18.6l-42.6,3c0.1,1.1,0.1,2.1,0.2,3.2C392.2,207.3,392.1,210.2,392,213.4z M388.9,188.4c-0.4,0-0.8-0.3-0.9-0.7c-1-4.3-2.3-8.7-4-12.9c-0.1-0.2-0.1-0.5,0-0.7c0.1-0.2,0.3-0.4,0.5-0.5l41.4-16.1c0.4-0.2,1,0.1,1.2,0.5c2.5,6.5,4.6,13.1,6.1,19.7c0.1,0.2,0,0.5-0.1,0.7c-0.1,0.2-0.3,0.3-0.5,0.4l-43.4,9.6C389.1,188.4,389,188.4,388.9,188.4zM386,175c1.5,3.8,2.7,7.7,3.6,11.5l41.7-9.2c-1.4-5.9-3.2-11.9-5.5-17.8L386,175z"/><path class="g" d="M186,133.1l45.7,24.1c0.5,0.3,1,0.4,1.5,0.4c1,0,2-0.4,2.6-1.3c15.2-19.3,38-30.9,62.5-31.8c23.8-0.8,46.9,8.6,63.3,25.9c1.1,1.2,2.9,1.4,4.3,0.5l43.1-28.5c0.8-0.5,1.3-1.4,1.5-2.3c0.1-0.9-0.1-1.9-0.7-2.6c-16.4-19.8-38-34.7-62.4-43.1c-60.1-20.8-127,1.4-162.7,53.9c-0.5,0.8-0.7,1.8-0.5,2.7C184.5,131.8,185.1,132.6,186,133.1z M345.2,80.6c22.1,7.6,41.7,20.8,57,38.2l-37.6,24.9c-17.6-17.4-41.7-26.9-66.5-26c-25.6,0.9-49.4,12.6-65.8,32.1l-40-21C227,81.1,289.2,61.3,345.2,80.6z"/><path class="g" d="M233.2,158.5c-0.7,0-1.4-0.2-2-0.5l-45.7-24.1c-1.1-0.6-1.8-1.6-2.1-2.7c-0.3-1.2-0.1-2.4,0.6-3.4c36-52.8,103.3-75.1,163.7-54.2C372.3,82,394,97,410.5,116.9c0.8,0.9,1.1,2.1,0.9,3.3c-0.2,1.2-0.8,2.2-1.8,2.9l-43.1,28.5c-1.8,1.1-4,0.9-5.4-0.6c-16.2-17.1-39-26.5-62.7-25.7c-24.3,0.9-46.8,12.3-61.9,31.5C235.8,157.9,234.5,158.5,233.2,158.5z M301.5,67.5c-45.5,0-89.4,22.2-116,61.2c-0.4,0.6-0.5,1.3-0.4,2c0.2,0.7,0.6,1.3,1.2,1.6c0,0,0,0,0,0l45.7,24.1c1.1,0.6,2.4,0.3,3.1-0.7c15.4-19.5,38.4-31.2,63.2-32.1c24.1-0.9,47.4,8.7,64,26.2c0.8,0.9,2.1,1,3.2,0.4l43.1-28.5c0.6-0.4,1-1,1.1-1.7c0.1-0.7-0.1-1.4-0.6-2c-16.3-19.6-37.7-34.4-62-42.9C332.2,70,316.8,67.5,301.5,67.5z M232.4,150.8c-0.1,0-0.3,0-0.4-0.1l-40-21c-0.2-0.1-0.4-0.3-0.4-0.6c-0.1-0.2,0-0.5,0.1-0.7c17.1-23.6,40.9-40.8,68.8-49.7c28-8.9,57.4-8.5,85,1l0,0c22.1,7.7,42,21,57.3,38.5c0.2,0.2,0.2,0.4,0.2,0.7s-0.2,0.5-0.4,0.6l-37.6,24.9c-0.3,0.2-0.8,0.2-1.1-0.1c-17.4-17.2-41.4-26.6-65.8-25.7c-25.2,0.9-49,12.5-65.1,31.8C232.9,150.7,232.6,150.8,232.4,150.8z M193.7,128.6l38.4,20.2c16.4-19.4,40.4-31,65.9-31.9c24.7-0.9,48.9,8.5,66.6,25.7l36.2-24c-15.1-16.9-34.4-29.8-55.9-37.2l0,0C290.1,62.5,228.1,81.9,193.7,128.6z"/><path class="g" d="M294.8,290.8c-42.2-3.3-75.1-37.7-76.6-80.1c-0.4-13,2-25.6,7.4-37.4c0.7-1.6,0.1-3.5-1.5-4.3l-45.3-23.9c-0.8-0.4-1.8-0.5-2.6-0.2c-0.8,0.3-1.6,0.9-2,1.7c-2.3,4.9-4.4,10-6.2,15c-12.3,35.6-10,73.9,6.5,107.8c16.5,33.9,45.2,59.4,80.8,71.7c13.2,4.6,27,7.1,40.9,7.7h0.1c0.9,0,1.7-0.4,2.4-1c0.7-0.7,1-1.5,1-2.5l-1.8-51.4C297.8,292.3,296.5,290.9,294.8,290.8L294.8,290.8z"/><path class="g" d="M296.3,349.7h-0.1c-14.1-0.5-28-3.1-41.2-7.7c-35.8-12.4-64.7-38-81.3-72.1c-16.6-34.1-18.9-72.6-6.6-108.4c1.8-5.2,3.9-10.3,6.2-15.1c0.5-1,1.5-1.8,2.5-2.2c1.1-0.4,2.3-0.2,3.3,0.3l45.3,23.8c2,1,2.8,3.4,1.9,5.5c-5.3,11.6-7.7,24.1-7.3,37c1.5,41.8,33.9,75.8,75.6,79.2c0.1,0,0.2,0,0.3,0c2.2,0.2,3.8,1.9,3.9,4.1l1.8,51.4c0.1,1.2-0.4,2.3-1.2,3.1C298.5,349.2,297.4,349.7,296.3,349.7z M177.2,145.7c-0.3,0-0.5,0-0.8,0.1c-0.6,0.2-1.2,0.7-1.5,1.3c-2.3,4.7-4.3,9.8-6.1,14.9c-12.2,35.4-9.9,73.5,6.5,107.1c16.4,33.7,44.9,59,80.3,71.2c13.1,4.5,26.8,7.1,40.7,7.6l0.1,0c0.6,0,1.3-0.3,1.8-0.7c0.5-0.5,0.7-1.1,0.7-1.8L297,294c0-1.2-0.9-2.2-2.1-2.4c-0.1,0-0.2,0-0.2,0c-42.6-3.3-75.9-38.1-77.4-80.9c-0.4-13.2,2.1-25.9,7.4-37.7c0.6-1.2,0.1-2.6-1.1-3.2L178.3,146C178,145.8,177.6,145.7,177.2,145.7z"/><path class="g" d="M367.3,205.3c-1.3-36.4-31.9-64.9-68.2-63.6c-36.3,1.3-64.8,31.9-63.6,68.3c1.3,35.6,30.5,63.6,65.8,63.6c0.8,0,1.6,0,2.4,0C340,272.3,368.5,241.7,367.3,205.3L367.3,205.3z M303.5,267.6c-0.7,0-1.5,0-2.2,0c-32.1,0-58.8-25.5-59.9-57.9c-1.2-33.1,24.7-60.9,57.8-62.1c16-0.6,31.3,5.1,43,16.1c11.7,10.9,18.5,25.7,19.1,41.8C362.5,238.5,336.5,266.4,303.5,267.6L303.5,267.6z"/><path class="g" d="M301.3,274.5c-17.3,0-33.8-6.7-46.3-18.7c-12.6-12.1-19.8-28.4-20.4-45.8c-1.3-36.8,27.6-67.9,64.4-69.2c17.8-0.6,34.8,5.7,47.9,17.9c13.1,12.2,20.6,28.7,21.2,46.5c0,0,0,0,0,0v0c1.3,36.8-27.6,67.8-64.4,69.1L301.3,274.5z M301.4,142.5c-0.8,0-1.6,0-2.3,0c-35.8,1.3-64,31.5-62.7,67.4c1.3,35.2,29.8,62.8,65,62.8h2.4c35.8-1.3,63.9-31.5,62.7-67.4l0.9-0.1l-0.9,0c-0.6-17.4-8-33.4-20.7-45.3C333.6,148.7,317.9,142.5,301.4,142.5z M303.5,268.4h-2.2c-15.8,0-30.7-6.1-42.2-17.1c-11.4-11-18.1-25.8-18.6-41.7c-0.6-16.2,5.2-31.7,16.3-43.6c11.1-11.9,26.1-18.8,42.3-19.3c16.2-0.6,31.7,5.2,43.6,16.3c11.9,11.1,18.8,26.1,19.3,42.4c0.6,16.2-5.2,31.7-16.3,43.6c-11,11.8-26,18.7-42.1,19.3C303.7,268.4,303.6,268.4,303.5,268.4z M303.5,267.5L303.5,267.5L303.5,267.5z M301.4,148.5c-0.7,0-1.4,0-2.1,0c-15.7,0.5-30.3,7.2-41.1,18.8c-10.8,11.6-16.4,26.6-15.8,42.4c1.1,32,27.1,57,59,57h1.9c0.1,0,0.2,0,0.2,0c15.7-0.5,30.3-7.2,41.1-18.8c10.8-11.6,16.4-26.6,15.8-42.4c-0.6-15.8-7.2-30.4-18.8-41.2C330.6,154.1,316.3,148.5,301.4,148.5z"/><path class="g" d="M62.2,419.7v97.8c0,0.5,0.4,0.9,0.9,0.9H600v-1.8H64v-96h536v-1.8H63.1C62.6,418.8,62.2,419.2,62.2,419.7z"/><path class="g" d="M62.2,651.8v97.8c0,0.5,0.4,0.9,0.9,0.9H600v-1.8H64v-96h536v-1.8H63.1C62.6,650.9,62.2,651.3,62.2,651.8z"/><path class="g" d="M512.3,636.3v-97.8c0-0.5-0.4-0.9-0.9-0.9H0v1.8h510.5v96H0v1.8h511.4C511.9,637.2,512.3,636.8,512.3,636.3z"/><path class="g" d="M512.3,863.8V766c0-0.5-0.4-0.9-0.9-0.9H0v1.8h510.5v96H0v1.8h511.4C511.9,864.7,512.3,864.3,512.3,863.8z"/>';
    output = string(abi.encodePacked(output, '<text transform="matrix(1 0 0 1 88 463)" class="f s">ID:</text><text transform="matrix(1 0 0 1 88 502)" class="w s">', _toString(_tokenId), '</text>'));
    output = string(abi.encodePacked(output, '<text transform="matrix(1 0 0 1 88 579)" class="f s">Balance:</text><text transform="matrix(1 0 0 1 88 618)" class="w s">', _toString(_balanceOf / 1e18), '</text>'));
    output = string(abi.encodePacked(output, '<text transform="matrix(1 0 0 1 88 694)" class="f s">Until unlock:</text><text transform="matrix(1 0 0 1 88 733)" class="w s">', _toString(untilEnd / 60 / 60 / 24), ' days</text>'));
    output = string(abi.encodePacked(output, '<text transform="matrix(1 0 0 1 88 804)" class="f s">Power:</text><text transform="matrix(1 0 0 1 88 843)" class="w s">', _toString(_value / 1e18), '</text></svg>'));

    string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "veCONE #', _toString(_tokenId), '", "description": "Locked CONE tokens", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
    output = string(abi.encodePacked('data:application/json;base64,', json));
  }

  /// @dev Inspired by OraclizeAPI's implementation - MIT license
  ///      https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
  function _toString(uint value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }
    uint temp = value;
    uint digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity 0.8.15;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) = target.call(data);
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

pragma solidity 0.8.15;

/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <[email protected]>
library Base64 {
  bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  /// @notice Encodes some bytes to the base64 representation
  function encode(bytes memory data) internal pure returns (string memory) {
    uint len = data.length;
    if (len == 0) return "";

    // multiply by 4/3 rounded up
    uint encodedLen = 4 * ((len + 2) / 3);

    // Add some extra buffer at the end
    bytes memory result = new bytes(encodedLen + 32);

    bytes memory table = TABLE;

    assembly {
      let tablePtr := add(table, 1)
      let resultPtr := add(result, 32)

      for {
        let i := 0
      } lt(i, len) {

      } {
        i := add(i, 3)
        let input := and(mload(add(data, i)), 0xffffff)

        let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
        out := shl(224, out)

        mstore(resultPtr, out)

        resultPtr := add(resultPtr, 4)
      }

      switch mod(len, 3)
      case 1 {
        mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
      }
      case 2 {
        mstore(sub(resultPtr, 1), shl(248, 0x3d))
      }

      mstore(result, encodedLen)
    }

    return string(result);
  }
}