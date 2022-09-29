// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./Pausable.sol";
import "./Ownable.sol";

interface IRichmanHorseNFT
{
   function tokenExists(uint256 tokenId) external view returns(bool);
   function burnByMarketplace(address account, uint256 id, uint256 amount) external;
   function mintByMarketplace(address to, uint256 id, uint256 amount) external;
}

contract RichmanHorseMarketplace is Context, Ownable, Pausable
{
   struct Lot
   {
      bytes32 id;
      address owner;
      uint256 tokenId;
      uint256 tokenAmount;
      uint256 pricePerToken;
      uint128 createDateTime;
   }

   struct Bid
   {
      bytes32 id;
      bytes32 lotId;
      address owner;
      uint256 tokenAmount;
      uint256 etherAmount;
   }

   struct BidStat
   {
      bytes32 id;
      address bidOwner;
      uint128 createdDateTime;
      uint128 saledDateTime;
      uint256 etherPrice;
   }

   // NFT token
   address public _tokenAddress;

   // all bids (bidId -> bid object)
   mapping(bytes32 => Bid) public _bids;

   // all lots  (lotId -> lot object)
   mapping(bytes32 => Lot) public _lots;

   // lotId => BidId[] (all Lot's bids)
   mapping(bytes32 => bytes32[]) public _lotBids;

   // userId => BidId[] (all user's bids)
   mapping(address => bytes32[]) public _userBids;

   // lotId => BidStat[] (Lot's statistics)
   mapping(bytes32 => BidStat[]) public _lotBidsStat;

   bytes32[] public _allLots;
   bytes32[] public _allBids;

   uint256 public _lockedEtherBalance;

   /**
    * 1.50% in basis points (parts per 10000).
    * See getAmountByPercent()
    */    
   uint32 public _fee = 150;   

   constructor() { }

   receive() external payable { }
   fallback() external payable { }

   /***********************************************************************/
   
   function pause() external onlyOwner whenNotPaused {
      _pause();
   }

   function unpause() external onlyOwner whenPaused {
      _unpause();
   }

   function setFee(uint256 fee_) external onlyOwner
   {
      require(fee_ > 0, "wrong 'fee_' value");
      _fee = uint32(fee_);
   }

   function setTokenAddress(address address_) external onlyOwner
   {
      require(address_ != address(0), "wrong address_");
      _tokenAddress = address_;
   }

   function createLot(uint256 tokenId_, uint256 tokenAmount_, uint256 pricePerToken_) external whenNotPaused
   {
      require(_tokenAddress != address(0), "'_tokenAddress' is empty");
      require(tokenAmount_ > 0, "the value of the 'tokenAmount_' must be > 0");

      bool tokenExists = IRichmanHorseNFT(_tokenAddress).tokenExists(tokenId_);
      require(tokenExists, "token not exists");
      
      address sender = _msgSender();
      
      // reduce seller's token-balance in the Token-contract
      IRichmanHorseNFT(_tokenAddress).burnByMarketplace(sender, tokenId_, tokenAmount_);

      bytes32 lotId = getNextId();

      // create a Lot
      Lot memory lot = Lot(
      {
         id: lotId
         , owner: sender
         , tokenId: tokenId_
         , tokenAmount: tokenAmount_
         , pricePerToken: pricePerToken_
         , createDateTime: getCurrentTime()
      });
      _lots[lotId] = lot;
      _allLots.push(lotId);
   }

   function removeLot(bytes32 lotId) external whenNotPaused
   {
      address sender = _msgSender();

      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "there is no Lot with this ID");

      Lot memory lot = _lots[lotId];
      require(lot.owner == sender, "you're not an owner of the Lot");

      // return tokens to the owner
      if (lot.tokenAmount > 0) {
         IRichmanHorseNFT(_tokenAddress).mintByMarketplace(lot.owner, lot.tokenId, lot.tokenAmount);
      }

      _removeLot(lotId);
   }

   function makeBid(bytes32 lotId, uint256 tokenAmount) external payable whenNotPaused
   {
      require(tokenAmount > 0, "tokenAmount must be > 0");
      require(msg.value > 0, "msg.value must be > 0");

      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "there is no Lot with this ID");

      address sender = _msgSender();

      _lockedEtherBalance += msg.value;

      bytes32 bidId = getNextId();

      Bid memory bid = Bid(
      {
         id: bidId
         , lotId: lotId
         , owner: sender
         , tokenAmount: tokenAmount
         , etherAmount: msg.value
      });

      _bids[bidId] = bid;

      _lotBids[lotId].push(bidId);
      _userBids[sender].push(bidId);
      _allBids.push(bidId);

      // statistics of the Lot's bids
      BidStat memory bStat = BidStat(
      {
         id: bidId
         , bidOwner: sender
         , createdDateTime: getCurrentTime()
         , saledDateTime: 0
         , etherPrice: msg.value
      });
      _lotBidsStat[lotId].push(bStat);
   }

   function removeBid(bytes32 bidId) external whenNotPaused
   {
      address sender = _msgSender();

      bool found = false;
      for (uint256 i = 0; i < _userBids[sender].length; ++i)
      {
         if (_userBids[sender][i] == bidId)
         {
            Bid memory bid = _bids[bidId];

            // return Bid's etherAmount
            address payable to = payable(bid.owner);
            (bool sent, ) = to.call{value: bid.etherAmount}("");
            require(sent, "failed to send Ether");
  
            found = true;
            _lockedEtherBalance -= bid.etherAmount;
            _removeBid(bidId);
            break;
         }
      }
      require(found, "you don't have a Bid with this ID");
   }

   function purchaseLotAmount(bytes32 lotId, uint256 tokenAmount) external payable whenNotPaused
   {
      require(tokenAmount > 0, "tokenAmount must be > 0");

      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "there is no Lot with this ID");

      address sender = _msgSender();
      Lot storage lot = _lots[lotId];
      require(lot.tokenAmount >= tokenAmount, "not enough tokens in the Lot");

      uint256 etherNeeded = tokenAmount * lot.pricePerToken;
      require(msg.value >= etherNeeded, "not enough Ether");

      // increase buyer's token-balance on the Token-contract
      IRichmanHorseNFT(_tokenAddress).mintByMarketplace(sender, lot.tokenId, tokenAmount);
      lot.tokenAmount -= tokenAmount;

      // send Ether to the Lot's owner
      uint256 amount = etherNeeded - getAmountByPercent(etherNeeded);
      address payable to = payable(lot.owner);
      (bool sent, ) = to.call{value: amount}("");
      require(sent, "failed to send Ether");
   }

   function acceptBid(bytes32 bidId) external whenNotPaused
   {
      int256 bidIdx = _getBidIndex(bidId);
      require(bidIdx > -1, "bidIdx: there is no Bid with this ID");
      Bid storage bid = _bids[bidId];

      address sender = _msgSender();      
      
      int256 lotIdx = _getLotIndex(bid.lotId);
      require(lotIdx > -1, "there is no Lot with this ID");
      Lot storage lot = _lots[bid.lotId];

      require(sender == lot.owner, "you're not an owner of the Lot");
      require(lot.tokenAmount >= bid.tokenAmount, "not enough tokens in the Lot");

      // increase buyer's token-balance in the Token-contract
      IRichmanHorseNFT(_tokenAddress).mintByMarketplace(bid.owner, lot.tokenId, bid.tokenAmount);      

      // send Ether to the Lot's owner
      uint256 amount = bid.etherAmount - getAmountByPercent(bid.etherAmount);
      address payable to = payable(lot.owner);
      (bool sent, ) = to.call{value: amount}("");
      require(sent, "failed to send Ether");

      lot.tokenAmount -= bid.tokenAmount;
      _lockedEtherBalance -= bid.etherAmount;
      bid.tokenAmount = 0;
      bid.etherAmount = 0;

      // statistics
      int256 bidStatIdx = _getLotStatBidIndex(lot.id, bidId);
      if (bidStatIdx > -1)
      {
         BidStat storage bStat = _lotBidsStat[lot.id][uint256(bidStatIdx)];
         bStat.saledDateTime = getCurrentTime();
      }
   }

   function makePaymentOfFreeBalance(address payable to) external onlyOwner
   {
      uint256 amount = this.getContractFreeBalance();
      require(amount > 0, "not enough balance for payment");

      (bool sent, ) = to.call{value: amount}("");
      require(sent, "failed to send Ether");
   }

   /***********************************************************************/   

   function getLotsCount() external view returns (uint256) {
      return _allLots.length;
   }

   function getBidsCount() external view returns (uint256) {
      return _allBids.length;
   }

   function getLotBidCount(bytes32 lotId) external view returns (uint256) {
      return _lotBids[lotId].length;
   }

   function getUserBidCount(address user) external view returns (uint256) {
      return _userBids[user].length;
   }

   function getLotBidsStatCount(bytes32 lotId) external view returns (uint256) {
      return _lotBidsStat[lotId].length;
   }

   function _removeLot(bytes32 lotId) internal
   {
      for (uint256 i = 0; i < _allLots.length; ++i)
      {
         if (_allLots[i] == lotId)
         {
            for (uint256 ii = i; ii < _allLots.length - 1; ++ii) {
                  _allLots[ii] = _allLots[ii + 1];
            }
            _allLots.pop();
            break;
         }
      }

      delete _lots[lotId];
      delete _lotBids[lotId];
   }

   function _removeBid(bytes32 bidId) internal
   {
      for (uint256 i = 0; i < _allBids.length; ++i)
      {
         if (_allBids[i] == bidId)
         {
            bytes32 lotId = _bids[bidId].lotId;
            address user = _bids[bidId].owner;

            for (uint256 ii = i; ii < _allBids.length - 1; ++ii) {
               _allBids[ii] = _allBids[ii + 1];
            }
            _allBids.pop();

            // delete in _lotBids
            bytes32[] storage lotBids = _lotBids[lotId];
            if (lotBids.length > 0)
            {
               for (uint256 i_lot = 0; i_lot < lotBids.length; ++i_lot)
               {
                  if (lotBids[i_lot] == bidId)
                  {
                     for (uint256 ii = i_lot; ii < lotBids.length - 1; ++ii) {
                        lotBids[ii] = lotBids[ii + 1];
                     }
                     lotBids.pop();
                     break;
                  }
               }
            }

            // delete in _userBids
            bytes32[] storage userBids = _userBids[user];
            if (userBids.length > 0)
            {
               for (uint256 i_usr = 0; i_usr < userBids.length; ++i_usr)
               {
                  if (userBids[i_usr] == bidId)
                  {
                     for (uint256 ii = i_usr; ii < userBids.length - 1; ++ii) {
                        userBids[ii] = userBids[ii + 1];
                     }
                     userBids.pop();
                     break;
                  }
               }
            }

            break;
         }
      }

      delete _bids[bidId];
   }

   function _getLotIndex(bytes32 lotId) internal view returns (int256)
   {
      require(lotId[0] != 0, "lotId must be not empty");

      int256 result = -1;
      for (uint256 i = 0; i < _allLots.length; ++i)
      {
         if (_allLots[i] == lotId)
         {
            result = int256(i);
            break;
         }
      }
      return result;
   }

   function _getBidIndex(bytes32 bidId) internal view returns (int256)
   {
      require(bidId[0] != 0, "bidId must be not empty");

      int256 result = -1;
      for (uint256 i = 0; i < _allBids.length; ++i)
      {
         if (_allBids[i] == bidId)
         {
            result = int256(i);
            break;
         }
      }
      return result;
   }

   function _getLotStatBidIndex(bytes32 lotId, bytes32 bidId) internal view returns (int256)
   {
      require(lotId[0] != 0, "lotId must be not empty");
      require(bidId[0] != 0, "bidId must be not empty");

      int256 result = -1;
      for (uint256 i = 0; i < _lotBidsStat[lotId].length; ++i)
      {
         if (_lotBidsStat[lotId][i].id == bidId)
         {
            result = int256(i);
            break;
         }
      }
      return result;
   }

   function getAmountByPercent(uint256 amount) internal view returns (uint256) {
      return (amount * uint256(_fee) / uint256(10000));
   }

   function getNextId() internal view returns(bytes32)
   {
      // bytes32
      return keccak256(abi.encodePacked(msg.sender, block.number));
   }  

   function getContractFreeBalance() external view returns(uint256) {
      return address(this).balance - _lockedEtherBalance;
   }

   function getCurrentTime() internal view returns(uint128) {
      return uint128(block.timestamp);
   }   

} // contract RichmanHorseMarketplace