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


	function setReserveNFTnum(address _NftAdd) public {
		require(msg.sender==ctoAdd, "Err: error cto address");
		ReserveNFTnum[_NftAdd] = 1;
	}
	function setCtoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		ctoAdd = _ctoAdd;
	}

	function mintNFTs() public {
		require(ReserveNFTnum[msg.sender]>0, "Can't purchase NFT");
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
}