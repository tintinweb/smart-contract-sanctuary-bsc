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

   // NFT token
   address public _tokenAddress;

   Lot[] public _lots;
   Bid[] public _bids;

   // lotId => BidId
   mapping(bytes32 => bytes32[]) public _lotBids;
   // userId => BidId
   mapping(address => bytes32[]) public _userBids;

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
      require(fee_ > 0, "Marketplace: wrong 'fee_' value");
      _fee = uint32(fee_);
   }

   function setTokenAddress(address address_) external onlyOwner
   {
      require(address_ != address(0), "Marketplace: wrong address_");
      _tokenAddress = address_;
   }

   function createLot(uint256 tokenId_, uint256 tokenAmount_, uint256 pricePerToken_) external whenNotPaused
   {
      require(_tokenAddress != address(0), "Marketplace: '_tokenAddress' is empty");
      require(tokenAmount_ > 0, "Marketplace: the value of the 'tokenAmount_' must be > 0");

      bool tokenExists = IRichmanHorseNFT(_tokenAddress).tokenExists(tokenId_);
      require(tokenExists, "Marketplace: token not exists");
      
      address sender = _msgSender();
      
      // reduce seller's token-balance in the Token-contract
      IRichmanHorseNFT(_tokenAddress).burnByMarketplace(sender, tokenId_, tokenAmount_);

      // create a Lot
      Lot memory lot = Lot(
      {
         id: getNextId()
         , owner: sender
         , tokenId: tokenId_
         , tokenAmount: tokenAmount_
         , pricePerToken: pricePerToken_
         , createDateTime: uint128(block.timestamp)
      });
      _lots.push(lot);
   }

   function removeLot(bytes32 lotId) external whenNotPaused
   {
      address sender = _msgSender();

      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");

      Lot memory lot = _lots[uint256(lotIdx)];
      require(lot.owner == sender, "Marketplace: you're not an owner of the Lot");

      // return tokens to the owner
      if (lot.tokenAmount > 0) {
         IRichmanHorseNFT(_tokenAddress).mintByMarketplace(lot.owner, lot.tokenId, lot.tokenAmount);
      }

      _removeLot(lotId);
   }

   function makeBid(bytes32 lotId, uint256 tokenAmount) external payable whenNotPaused
   {
      require(tokenAmount > 0, "Marketplace: tokenAmount must be > 0");
      require(msg.value > 0, "Marketplace: msg.value must be > 0");

      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");

      address sender = _msgSender();

      _lockedEtherBalance += msg.value;

      // statistics of the Lot's bids
      Bid memory bid = Bid(
      {
         id: getNextId()
         , lotId: lotId
         , owner: sender
         , tokenAmount: tokenAmount
         , etherAmount: msg.value
      });
      _bids.push(bid);
   }

   function removeBid(bytes32 bidId) external whenNotPaused
   {
      int256 bidIdx = _getBidIndex(bidId);
      require(bidIdx > -1, "Marketplace: there is no Bid with this ID");

      address sender = _msgSender();

      for (uint256 i = 0; i < _bids.length; ++i)
      {
         if (_bids[i].id == bidId)
         {
            Bid memory bid = _bids[i];
            require(bid.owner == sender, "Marketplace: you're not an owner of the Bid");

            // return Bid's etherAmount
            address payable to = payable(bid.owner);
            (bool sent, ) = to.call{value: bid.etherAmount}("");
            require(sent, "Marketplace: failed to send Ether");

            _lockedEtherBalance -= bid.etherAmount;
            break;
         }
      }
      _removeBid(bidId);
   }

   function purchaseLotAmount(bytes32 lotId, uint256 tokenAmount) external payable whenNotPaused
   {
      require(tokenAmount > 0, "Marketplace: tokenAmount must be > 0");

      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");

      address sender = _msgSender();
      Lot storage lot = _lots[uint256(lotIdx)];
      require(lot.tokenAmount >= tokenAmount, "Marketplace: not enough tokens in the Lot");

      uint256 etherNeeded = tokenAmount * lot.pricePerToken;
      require(msg.value >= etherNeeded, "Marketplace: not enough Ether");

      // increase buyer's token-balance on the Token-contract
      IRichmanHorseNFT(_tokenAddress).mintByMarketplace(sender, lot.tokenId, tokenAmount);
      lot.tokenAmount -= tokenAmount;

      // send Ether to the Lot's owner
      uint256 amount = etherNeeded - getAmountByPercent(etherNeeded);
      address payable to = payable(lot.owner);
      (bool sent, ) = to.call{value: amount}("");
      require(sent, "Marketplace: failed to send Ether");
   }

   function acceptBid(bytes32 bidId) external whenNotPaused
   {
      int256 bidIdx = _getBidIndex(bidId);
      require(bidIdx > -1, "Marketplace: there is no Bid with this ID");
      Bid storage bid = _bids[uint256(bidIdx)];

      address sender = _msgSender();      
      
      int256 lotIdx = _getLotIndex(bid.lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");
      Lot storage lot = _lots[uint256(lotIdx)];

      require(sender == lot.owner, "Marketplace: you're not an owner of the Lot");
      require(lot.tokenAmount >= bid.tokenAmount, "Marketplace: not enough tokens in the Lot");

      // increase buyer's token-balance in the Token-contract
      IRichmanHorseNFT(_tokenAddress).mintByMarketplace(bid.owner, lot.tokenId, bid.tokenAmount);      

      // send Ether to the Lot's owner
      uint256 amount = bid.etherAmount - getAmountByPercent(bid.etherAmount);
      address payable to = payable(lot.owner);
      (bool sent, ) = to.call{value: amount}("");
      require(sent, "Marketplace: failed to send Ether");

      lot.tokenAmount -= bid.tokenAmount;
      _lockedEtherBalance -= bid.etherAmount;
      bid.tokenAmount = 0;
      bid.etherAmount = 0;
   }

   function makePaymentOfFreeBalance(address payable to) external onlyOwner
   {
      uint256 amount = this.getContractFreeBalance();
      require(amount > 0, "Marketplace: not enough balance for payment");

      (bool sent, ) = to.call{value: amount}("");
      require(sent, "Marketplace: failed to send Ether");
   }

   /***********************************************************************/   

   function getLotById(bytes32 lotId) external view returns (Lot memory)
   {
      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");
      return _lots[uint256(lotIdx)];
   }

   function getLotsCount() external view returns (uint256) {
      return _lots.length;
   }

   function getBidsCount() external view returns (uint256) {
      return _bids.length;
   }

   function getLotBidCount(bytes32 lotId) external view returns (uint256) {
      return _lotBids[lotId].length;
   }

   function getUserBidCount(address user) external view returns (uint256) {
      return _userBids[user].length;
   }

   function _removeLot(bytes32 lotId) internal
   {
      for (uint256 i = 0; i < _lots.length; ++i)
      {
         if (_lots[i].id == lotId)
         {
            for (uint256 ii = i; ii < _lots.length - 1; ++ii) {
               _lots[ii] = _lots[ii + 1];
            }
            _lots.pop();

            break;
         }
      }
      delete _lotBids[lotId];
   }

   function _removeBid(bytes32 bidId) internal
   {
      for (uint256 i = 0; i < _bids.length; ++i)
      {
         if (_bids[i].id == bidId)
         {
            bytes32 lotId = _bids[i].lotId;
            address user = _bids[i].owner;

            for (uint256 ii = i; ii < _bids.length - 1; ++ii) {
               _bids[ii] = _bids[ii + 1];
            }
            _bids.pop();

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
   }

   function _getLotIndex(bytes32 lotId) internal view returns (int256)
   {
      require(lotId[0] != 0, "Marketplace: lotId must be not empty");

      int256 result = -1;
      for (uint256 i = 0; i < _lots.length; ++i)
      {
         if (_lots[i].id == lotId)
         {
            result = int256(i);
            break;
         }
      }
      return result;
   }

   function _getBidIndex(bytes32 bidId) internal view returns (int256)
   {
      require(bidId[0] != 0, "Marketplace: bidId must be not empty");

      int256 result = -1;
      for (uint256 i = 0; i < _bids.length; ++i)
      {
         if (_bids[i].id == bidId)
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

   function getCurrentTime() internal view returns(uint256) {
      return block.timestamp;
   }   

} // contract RichmanHorseMarketplace