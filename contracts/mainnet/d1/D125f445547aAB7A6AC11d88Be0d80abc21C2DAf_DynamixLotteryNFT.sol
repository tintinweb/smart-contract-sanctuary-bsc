// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ILotteryNFT.sol";

contract DynamixLotteryNFT is IDynamixLotteryNFT, Ownable {
	
	struct NFT {
        bool minusOnePlusOne;
        bool jokerX1;
        bool jokerX2;
        bool discount50;
    }
	
	struct NFTPlayer {
        address player;
		NFT nft;
        uint256[] nftIds;
    }
	
	mapping(address => NFT) private _nftOwner;
	mapping(uint256 => address) private _nft;

	constructor() {
		
    }
	
	// Reset all NFT Owner
	function resetNFTOwner(uint256[] memory nftIds) onlyOwner public {
		for (uint256 i = 0; i < nftIds.length; i++) {
            address owner = _nft[nftIds[i]];
			_nftOwner[owner] = NFT({minusOnePlusOne: false, jokerX1: false, jokerX2: false, discount50: false});
        }
	}
	
	// Add NFT Owner
	function addNFTOwner(NFTPlayer[] memory nftPlayers) onlyOwner public {
		for (uint256 i = 0; i < nftPlayers.length; i++) {
			_nftOwner[nftPlayers[i].player] = nftPlayers[i].nft;
			
           for (uint256 j = 0; j < nftPlayers[i].nftIds.length; j++) {
			   _nft[nftPlayers[i].nftIds[j]] = nftPlayers[i].player;
		   }
        }
	}
	
	// View Player Powers
	function viewPowers(address player) external view returns(NFT memory) {
		return _nftOwner[player];
	}
	
	// Player has discount 50%
	function hasDiscount(address player) override external view returns(bool) {
		return _nftOwner[player].discount50;
	}

	// How many match between playerNumber and winnerNumber for a player
	function countMatch(uint32 playerNumber, uint32 winnerNumber, address player) override external view returns(uint8) {
		NFT memory nft = _nftOwner[player];
		
		uint8 jokerNFT = 0;
		jokerNFT = nft.jokerX1 ? 1 : jokerNFT;
		jokerNFT = nft.jokerX2 ? 2 : jokerNFT;
		
		return countMatchNFT(playerNumber, winnerNumber, nft.minusOnePlusOne, jokerNFT);
	}
	
	// How many match between playerNumber and winnerNumber
	function countMatchNFT(uint32 playerNumber, uint32 winnerNumber, bool minusOnePlusOneNFT, uint8 jokerNFT) public view returns(uint8) {
		uint32 encodedPlayerNumber = 1000000 + playerNumber;
		uint32 encodedWinnerNumber = 1000000 + winnerNumber;
		uint8 matchNumber = 0;
		
		for (uint8 i = 0; i < 6; i++) {
			uint32 div = uint32(10) ** (5 - i);
			uint32 partPlayerNumber = encodedPlayerNumber / div;
			uint32 partWinnerNumber = encodedWinnerNumber / div;
			
			// NFT -1+1
			if(minusOnePlusOneNFT && partPlayerNumber != partWinnerNumber) {
				bool playerNumberGreater = partPlayerNumber > partWinnerNumber;
				uint32 diff = playerNumberGreater ? partPlayerNumber - partWinnerNumber : partWinnerNumber - partPlayerNumber;
				
				if(diff == 1) {
					partPlayerNumber = partWinnerNumber;
					encodedPlayerNumber = playerNumberGreater ? encodedPlayerNumber - div : encodedPlayerNumber + div;
					minusOnePlusOneNFT = false;
				}
			}
			
			// NFT Joker x1/x2
			if(jokerNFT > 0 && partPlayerNumber != partWinnerNumber) {
				bool playerNumberGreater = partPlayerNumber > partWinnerNumber;
				uint32 diff = playerNumberGreater ? partPlayerNumber - partWinnerNumber : partWinnerNumber - partPlayerNumber;
				
				partPlayerNumber = partWinnerNumber;
				encodedPlayerNumber = playerNumberGreater ? encodedPlayerNumber - (diff * div) : encodedPlayerNumber + (diff * div);
				jokerNFT--;
			}
			
			if(partPlayerNumber == partWinnerNumber)
				matchNumber++;
        }
		
		return matchNumber;
	}
}