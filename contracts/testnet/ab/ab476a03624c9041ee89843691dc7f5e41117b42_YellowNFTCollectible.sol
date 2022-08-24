//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Counters.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC721Enumerable.sol";

contract YellowNFTCollectible is ERC721Enumerable, Ownable {
	using SafeMath for uint256;
	using Counters for Counters.Counter;

	Counters.Counter private _tokenIds;

	uint public MAX_SUPPLY = 500;
	uint public PRICE = 10 ether;
	uint public MAX_PER_MINT = 1;
	address public ctoAdd = 0x813D35c87f931DC18a3F6C6be405485AD34149f4; 
	address private ceoAdd;

	mapping(address => uint256) private ReserveNFTnum;
	mapping(address => bool) private isReserve;

	string public baseTokenURI;

	constructor() ERC721("NFT Collectible", "NFTC") {
		ceoAdd = 0x01A675a27c87a2151da84ca6741fE7631800d8DB;
	}

	function _baseURI() internal view virtual override returns (string memory) {
		return baseTokenURI;
	}

	function isReserveView(address _NftAdd) public view returns (bool) {
		return isReserve[_NftAdd];
	}

	function balanceAll(address _NftAdd) public view returns (uint256) {
		return ReserveNFTnum[_NftAdd].add(balanceOf(_NftAdd));
	}

	function setBaseURI(string memory _baseTokenURI) public {
		require(msg.sender==ctoAdd, "Err: error cto address");
		baseTokenURI = _baseTokenURI;
	}

	function setPRICE(uint _PRICE) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		PRICE = _PRICE;
	}

	function setReserveNFTnum(address _NftAdd) public {
		require(!isReserve[_NftAdd], "Err: isReserve");
		require(msg.sender==ctoAdd, "Err: error cto address");
		ReserveNFTnum[_NftAdd] = 1;
	}
	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		ctoAdd = _ctoAdd;
	}

	function mintNFTs() public payable {
		uint totalMinted = _tokenIds.current();
		require(totalMinted.add(1) <= MAX_SUPPLY, "Not enough NFTs left!");
		require(msg.value >= PRICE, "Not enough ether to purchase NFT");
		_mintSingleNFT();
	}
	function mintNFTsFree() public {
		require(ReserveNFTnum[msg.sender]>0, "Can't free to purchase NFT");
		uint totalMinted = _tokenIds.current();		
		require(totalMinted.add(1) <= MAX_SUPPLY, "Not enough NFTs left!");
		ReserveNFTnum[msg.sender] = 0;
		isReserve[msg.sender] = true;
		_mintSingleNFT();
	}

	function _mintSingleNFT() private {
		uint newTokenID = _tokenIds.current();
		_safeMint(msg.sender, newTokenID);
		_tokenIds.increment();
	}

	function tokensOfOwner(address _owner) external view returns (uint[] memory) {
		uint tokenCount = balanceOf(_owner);
		uint[] memory tokensId = new uint256[](tokenCount);
		for (uint i = 0; i < tokenCount; i++) {
			tokensId[i] = tokenOfOwnerByIndex(_owner, i);
		}
		return tokensId;
	}
	function withdraw() public payable {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		uint balance = address(this).balance;
		require(balance > 0, "No ether left to withdraw");

		(bool success, ) = (ceoAdd).call{value: balance}("");
		require(success, "Transfer failed.");
	}
}