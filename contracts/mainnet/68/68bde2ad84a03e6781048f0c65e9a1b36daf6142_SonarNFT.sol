// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./Strings.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract SonarNFT is ERC721, ERC721Enumerable, Ownable {
    using Strings for uint256;

    bool feeEnabled;
    bool transferEnabled;
    bool public mintEnabled;
    bool stakingRewardsSet;
    bool mintLimitEnabled;
    address neededToken;
    uint256 balanceNeeded;
    uint256 mintFee;
    string _baseURIVar;

    mapping(address => bool) private mintedOnce;
    mapping(uint256 => uint256) public mintingTimes;
    mapping(uint256 => uint256) public stakingRewards;
   
    constructor() ERC721("Sonar Genesis Collection", "SGEN") {
        feeEnabled = true;
        mintEnabled = false;
        neededToken = address(0x5546600f77EdA1DCF2e8817eF4D617382E7f71F5);
        balanceNeeded = 50000000000000;
        mintLimitEnabled = true;
        mintFee = 600000000000000000;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory) {
        _requireMinted(tokenId);
        string memory suffix = ".json";

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), suffix)) : "";
    }

    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return _baseURIVar;
    }

    function setFeeEnabled(bool enabled) external onlyOwner {
        feeEnabled = enabled;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _baseURIVar = uri;
    }

    function setMintEnabled(bool enabled) external onlyOwner {
        mintEnabled = enabled;
    }

    function setMintLimitEnabled(bool enabled) external onlyOwner {
        mintLimitEnabled = enabled;
    }

    function setNeededToken(address token) external onlyOwner {
        require(token != address(0), "Needed cannot be the 0 address");
        neededToken = token;
    }

    function setBalanceNeeded(uint256 balance) external onlyOwner {
        balanceNeeded = balance;
    }

    function setMintFee(uint256 fee) external onlyOwner {
        mintFee = fee;
    }

    function random() internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 250;
    }

    function checkReq() internal view returns(bool) {
        require(mintEnabled, "Minting is not yet enabled");
        require(neededToken != address(0), "Required token for minting not set");
        require(stakingRewardsSet, "Staking rewards have not been uploaded");
        require(totalSupply() < 250, "All NFTs have been minted.");
        if (mintLimitEnabled) {
            require(mintedOnce[msg.sender] == false, "You can only mint 1 token");
        }

        if (IERC20(neededToken).balanceOf(msg.sender) < balanceNeeded) {
            return false;
        }

        return true;
    }

    function getMintingTime(uint256 tokenid) public view returns(uint256) {
        return mintingTimes[tokenid];
    }

    function getStakingRewards(uint256 tokenid) public view returns(uint256) {
        return stakingRewards[tokenid];
    }

    function setStakingRewards(uint8[] memory rewards) public onlyOwner {
        require(stakingRewardsSet == false, "Rewards have already been set");
        for (uint8 i = 1; i <= 250; i++) {
            stakingRewards[i] = rewards[i-1];
        }
        stakingRewardsSet = true;
    }

    function withdraw(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }

    function mintNFT() public payable returns (uint256) {
        require(checkReq(), "You dont meet the criteria to be able to mint this NFT.");

        if (feeEnabled) {
            require(msg.value == mintFee, "You have not paid the minting fee.");
        }        

        uint256 id = random() + 1;
        while (_exists(id)) {
            if (id == 1) {
                id = 250;
            } else {
                id = id - 1;
            }
        }
        _mint(msg.sender, id);
        mintingTimes[id] = block.timestamp;
        mintedOnce[msg.sender] = true;

        return id;
    }
}