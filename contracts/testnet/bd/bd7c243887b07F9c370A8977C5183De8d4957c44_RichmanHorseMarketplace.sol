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
      uint256 tokenCount;
      uint256 price;
      uint256 lastBidAmount;
      address lastBidAccount;
      uint256 feeAmount;
      uint128 createDateTime;
   }

   struct Bid
   {
      bytes32 id;
      address owner;
      uint256 amount;
   }

   // NFT token
   address public _tokenAddress;

   Lot[] public _lots;
   // lot ID => bid
   mapping(bytes32 => Bid[]) public _bids;
   
   // locked ethers, for Lot-payments
   uint256 public _lockedAmount;

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

   function createLot(uint256 tokenId_, uint256 tokenCount_, uint256 price_) external whenNotPaused
   {
      require(_tokenAddress != address(0), "Marketplace: '_tokenAddress' is empty");
      require( (tokenCount_ > 0) && (tokenCount_ <= 5000), "Marketplace: the value of the 'tokenCount_' must be between 0 and 5000");
      require(price_ > 0, "Marketplace: 'price_' must be greater than 0");

      bool tokenExists = IRichmanHorseNFT(_tokenAddress).tokenExists(tokenId_);
      require(tokenExists, "Marketplace: token not exists");
      
      address sender = _msgSender();
      
      // reduce seller's token-balance in the Token-contract
      IRichmanHorseNFT(_tokenAddress).burnByMarketplace(sender, tokenId_, tokenCount_);

      // create a Lot
      Lot memory lot = Lot(
      {
         id: getNextId()
         , owner: sender
         , tokenId: tokenId_
         , tokenCount: tokenCount_
         , price: price_
         , lastBidAmount: 0
         , lastBidAccount: address(0)
         , feeAmount: getAmountByPercent(price_)
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

      // increase seller's token-balance in the Token-contract
      IRichmanHorseNFT(_tokenAddress).mintByMarketplace(lot.owner, lot.tokenId, lot.tokenCount);

      _removeLot(lotId);
   }

   function _removeLot(bytes32 lotId) internal
   {
      for (uint256 i = 0; i < _lots.length; ++i)
      {
         if (_lots[i].id == lotId)
         {
            // clear all Lot's Bids
            _removeAllBids(lotId);

            for (uint256 ii = i; ii < _lots.length - 1; ++ii) {
               _lots[ii] = _lots[ii + 1];
            }
            _lots.pop();

            break;
         }
      }
   }

   function makeBid(bytes32 lotId, uint256 amount) external payable whenNotPaused
   {
      require(amount > 0, "Marketplace: amount must be > 0");

      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");

      address sender = _msgSender();
      Lot storage lot = _lots[uint256(lotIdx)];

      // first Bid. User can make Bid even if it is less than price of the Lot
      if (lot.lastBidAccount == address(0))
      {
         lot.lastBidAmount = amount;
         lot.lastBidAccount = sender;
      }
      else
      {
         require(amount > lot.lastBidAmount, "Marketplace: your Bid must be greater than the current Bid");

         lot.lastBidAmount = amount;
         lot.lastBidAccount = sender;
      }

      _lockedAmount += amount;

      // statistics of the Lot's bids
      Bid memory bid = Bid(
      {
         id: getNextId()
         , owner: sender
         , amount: amount
      });
      _bids[lotId].push(bid);
   }

   function removeBid(bytes32 lotId, bytes32 bidId) external whenNotPaused
   {
      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");

      address sender = _msgSender();

      for (uint256 i = 0; i < _bids[lotId].length; ++i)
      {
         if (_bids[lotId][i].id == bidId)
         {
            Bid memory bid = _bids[lotId][i];
            require(bid.owner == sender, "Marketplace: you're not an owner of the Bid");

            // return Bid's amount
            address payable to = payable(bid.owner);
            (bool sent, ) = to.call{value: bid.amount}("");
            require(sent, "Marketplace: failed to send Ether");

            _lockedAmount -= bid.amount;

            for (uint256 ii = i; ii < _bids[lotId].length - 1; ++ii) {
               _bids[lotId][ii] = _bids[lotId][ii + 1];
            }
            _bids[lotId].pop();
            break;
         }
      }

      Lot storage lot = _lots[uint256(lotIdx)];

      // set last Bid as actual
      if (_bids[lotId].length > 0)
      {
         uint256 bidIdx = _bids[lotId].length - 1;
         Bid memory bid = _bids[lotId][bidIdx];
         
         lot.lastBidAmount = bid.amount;
         lot.lastBidAccount = bid.owner;
      }
      // if there is no Bids
      else
      {
         lot.lastBidAmount = 0;
         lot.lastBidAccount = address(0);
      }
   }

   function _removeAllBids(bytes32 lotId) internal
   {
      if (_bids[lotId].length == 0) { return; }

      for (uint256 i = 0; i < _bids[lotId].length; ++i)
      {
         Bid memory bid = _bids[lotId][i];
         
         // return bid's amount
         address payable to = payable(bid.owner);
         (bool sent, ) = to.call{value: bid.amount}("");
         require(sent, "Marketplace: failed to send Ether");

         _lockedAmount -= bid.amount;
      }
      delete _bids[lotId];
   }

   function buyLot(bytes32 lotId) external payable whenNotPaused
   {
      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");
      require(_bids[lotId].length == 0, "Marketplace: you can buy the Lot only if it hasn't any Bids");

      address sender = _msgSender();
      Lot storage lot = _lots[uint256(lotIdx)];
      require(msg.value == lot.price, "Marketplace: wrong Ether amount for purchasing");

      // increase buyer's token-balance in the Token-contract
      IRichmanHorseNFT(_tokenAddress).mintByMarketplace(sender, lot.tokenId, lot.tokenCount);      

      // send Ether to the Lot's owner
      uint256 amount = lot.price - lot.feeAmount;
      address payable to = payable(lot.owner);
      (bool sent, ) = to.call{value: amount}("");
      require(sent, "Marketplace: failed to send Ether");

      // remove the Lot
      _removeLot(lotId);
   }

   function approveLotPurchasing(bytes32 lotId) external whenNotPaused
   {
      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");

      address sender = _msgSender();
      Lot storage lot = _lots[uint256(lotIdx)];
      require(sender == lot.owner, "Marketplace: you're not an owner of the Lot");
      require((lot.lastBidAmount > 0) && (lot.lastBidAccount != address(0)), "Marketplace: wrong Lot parameters for approving");

      // increase buyer's token-balance in the Token-contract
      IRichmanHorseNFT(_tokenAddress).mintByMarketplace(sender, lot.tokenId, lot.tokenCount);      

      // send Ether to the Lot's owner
      uint256 amount = lot.lastBidAmount - lot.feeAmount;
      address payable to = payable(lot.owner);
      (bool sent, ) = to.call{value: amount}("");
      require(sent, "Marketplace: failed to send Ether");

      _lockedAmount -= lot.lastBidAmount;

      // remove the Lot
      _removeLot(lotId);
   }

   function makePaymentOfFreeBalance(address payable to) external onlyOwner
   {
      uint256 amount = getContractFreeBalance();
      require(amount > 0, "Marketplace: not enough balance for payment");

      (bool sent, ) = to.call{value: amount}("");
      require(sent, "Marketplace: failed to send Ether");
   }

   /***********************************************************************/

   function getAmountByPercent(uint256 amount) internal view returns (uint256) {
      return (amount * uint256(_fee) / uint256(10000));
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

   function getLotById(bytes32 lotId) external view returns (Lot memory)
   {
      int256 lotIdx = _getLotIndex(lotId);
      require(lotIdx > -1, "Marketplace: there is no Lot with this ID");
      return _lots[uint256(lotIdx)];
   }

   function getNextId() internal view returns(bytes32)
   {
      // bytes32
      return keccak256(abi.encodePacked(msg.sender, block.number));
   }  

   function getContractFreeBalance() public view returns(uint256) {
      return address(this).balance - _lockedAmount;
   }

   function getCurrentTime() internal view returns(uint256) {
      return block.timestamp;
   }

   function getLotsCount() public view returns (uint256) {
      return _lots.length;
   }

} // contract RichmanHorseMarketplace