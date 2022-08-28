//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Counters.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC721Enumerable.sol";

contract MSCyNFTCollectible is ERC721Enumerable, Ownable {
	using SafeMath for uint256;
	using Counters for Counters.Counter;

	Counters.Counter private _tokenIds;

	uint public MAX_SUPPLY = 500;
	uint public PRICE = 10 ether;
	uint public MAX_PER_MINT = 1;
	address public ctoAdd = 0xD729F35301aa11EE1B523156fC5470e36B845AC3; 
	address private ceoAdd;

	mapping(address => uint256) private ReserveNFTnum;
	mapping(address => uint256) private isReserve;

	string public baseTokenURI;

	constructor() ERC721("Yellow Diamond", "MSCYD") {
		ceoAdd = 0x2c48fe1877F8785de63D3368492032AebFC7a461;
	}

	function _baseURI() internal view virtual override returns (string memory) {
		return baseTokenURI;
	}

	function isReserveView(address _NftAdd) public view returns (uint256) {
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
		ReserveNFTnum[msg.sender] = ReserveNFTnum[msg.sender].sub(1);
		isReserve[msg.sender] = isReserve[msg.sender].add(1);
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