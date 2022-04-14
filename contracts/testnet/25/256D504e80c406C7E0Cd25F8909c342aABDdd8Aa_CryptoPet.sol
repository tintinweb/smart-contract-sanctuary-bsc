// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import '@openzeppelin/contracts/security/Pausable.sol';
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CryptoPet {
	// constructor() ERC721("CryptoPet", "CRP") {
	// }

	// function mint(address _to, string _tokenURI) public returns (uint256) {
	// 	_mint(player, newItemId);
	// }

	struct Pet {
        string name;
        uint id;
        uint age;
    }

	Pet[] public pets;
}