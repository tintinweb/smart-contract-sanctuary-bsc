// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./Strings.sol";
import "./SafeMath.sol";
import "./MerkleProof.sol";
import "./ERC721A.sol";

contract TheParrotBossAzMerk1 is ERC721A, Ownable {

    // Declaring variables

    using Strings for uint256;
    using SafeMath for uint256;

    bool public isSale = false;
    bool public isWhitelist = true;
    bool public isGiveaway = true;
    uint256 public supply = 6969;
    uint256 public price = 0.17 ether;
    uint256 public max = 20;
    string public metaUri = "https://theparrotboss.io/tokens/";
    mapping(address => uint256) public glist;

    // The Merkle Root
	bytes32 public root = 0x21a69ae93781ffea397668022e64c09ba2760422692a9d74a8fd2e87deb26f71;

    constructor() ERC721A("TheParrotBossAzMerk1", "TPBAzM1") {}

    // Mint Functions - Public
    
    function mint(uint256 quantity, bytes32[] calldata proof) external payable {
        require(MerkleProof.verify(proof, root, bytes32(abi.encode(msg.sender))), "You are not whitelisted");
        require(isSale, "The Parrot Boss sale is not active");
        require(quantity <= max, "Requested quantity exceeds maximum allowed" );
        require(totalSupply().add(quantity) <= supply, "The quantity of tokens requested is not available");
        require(price.mul(quantity) == msg.value, "Ether amount sent is incorrect");
        _mint(msg.sender, quantity);
    }

    function publicMint(uint256 quantity) external payable {
        require(isSale, "The Parrot Boss sale is not active");
        require((!isWhitelist), "Public sale is not active yet");
        require(quantity <= max, "Requested quantity exceeds maximum allowed" );
        require(totalSupply().add(quantity) <= supply, "The quantity of tokens requested is not available");
        require(price.mul(quantity) == msg.value, "Ether amount sent is incorrect");
        _mint(msg.sender, quantity);
    }

    function gMint(uint256 quantity) external {
        require(glist[(msg.sender)] >= quantity, "You are not allowed to mint the requested quantity of tokens.");
        require(isGiveaway, "The Parrot Boss giveaway is not active");
        require(totalSupply().add(quantity) <= supply, "The quantity of tokens requested is not available");
        glist[(msg.sender)] = glist[(msg.sender)].sub(quantity);
        _mint(msg.sender, quantity);
    }

    // Mint Functions for Owner

    function ownerMint(uint256 quantity) external onlyOwner {
        require(totalSupply().add(quantity) <= supply, "The quantity of tokens requested is not available");
        _mint(msg.sender, quantity);
    }

    function airdrop(address to, uint256 quantity) external onlyOwner {
        require(totalSupply().add(quantity) <= supply, "The quantity of tokens requested is not available");
        _mint(to, quantity);
    }

    // Token URL Function - Public

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        return string(abi.encodePacked(_baseURI(), uint256(tokenId).toString(), ".json"));
    }

    function _baseURI() override internal view returns (string memory) {
        return metaUri;
    }

    // Setter Functions - onlyOwner

    function triggerSale() external onlyOwner {
        isSale = !isSale;
    }

    function triggerWhitelist() external onlyOwner {
        isWhitelist = !isWhitelist;
    }

    function triggerGiveaway() external onlyOwner {
        isGiveaway = !isGiveaway;
    }
    
    function setSupply(uint256 newSupply) external onlyOwner {
        supply = newSupply;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }

    function setMax(uint256 newMax) external onlyOwner {
        max = newMax;
    }

    function setMetaURI(string memory newURI) external onlyOwner {
        metaUri = newURI;
    }

    function setRoot(bytes32 newRoot) external onlyOwner {
        root = newRoot;
    }

    // Whitelist and Glist Functions - onlyOwner
    
    function addToGlist(address[] memory addresses, uint256[] memory quantities) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++){
            glist[addresses[i]] = quantities[i];
        }
    }
    
    function removeFromGlist(address[] memory addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length ; i++){
            glist[addresses[i]] = 0;
        }
    }

    // Withdraw Function - onlyOwner

    function withdraw() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

}