// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "ERC721A.sol";
import "Ownable.sol";
import "Strings.sol";

contract FantasyShoujo is ERC721A, Ownable {
    uint256 private _maxSupply = 6000;
    uint256 private _maxOnChainMint = 1000;
    uint256 private _maxOffChainMint = _maxSupply - _maxOnChainMint;

    bool private _onChainMintStarted = false;
    uint256 private _onChainMintCount = 0;
    uint256 private _mintPrice = 0.02 ether;
    uint256 private _mintQuotaPerAddress = 1;

    address private _hotWallet;

    mapping(address => bool) private _minted;

    string private _baseUrl;

    constructor(address hot_wallet, string memory base_url) ERC721A("Fantasy Shoujo by i.ls", "SHOUJO") {
        _hotWallet = hot_wallet;
        _baseUrl = base_url;
    }

    function offchainMint(uint256 limit) public onlyOwner {
        uint256 minted = _totalMinted();
        require(minted + limit <= _maxOffChainMint, "Max supply exceeded");
        if (limit >= _maxSupply - minted) {
            _mint(_hotWallet, _maxSupply - minted);
        } else {
            _mint(_hotWallet, limit);
        }
    }

    function startMint() public onlyOwner {
        require(!_onChainMintStarted, "Mint already started");
        _onChainMintStarted = true;
    }

    function mint() public payable {
        require(_onChainMintStarted, "Minting not started");
        uint256 minted = _totalMinted();
        require(minted < _maxOnChainMint, "Max supply exceeded");
        require(msg.value == _mintPrice, "Incorrect amount");
        require(checkQuota(msg.sender), "Exceed quota");

        // send ethers to owner
        payable(owner()).transfer(msg.value);

        _mint(msg.sender, 1);
        _minted[msg.sender] = true;
        _onChainMintCount++;
    }

    function getMintedCount() public view returns (uint256) {
        return _onChainMintCount;
    }

    function checkQuota(address wallet) internal view returns (bool) {
        if (_minted[wallet]) {
            return false;
        }

        if (this.balanceOf(wallet) >= _mintQuotaPerAddress) {
            return false;
        }

        return true;
    }

    function setPrice(uint256 price) public onlyOwner {
        _mintPrice = price;
    }

    function setQuota(uint256 quota) public onlyOwner {
        _mintQuotaPerAddress = quota;
    }

    function setBaseUrl(string memory baseUrl) public onlyOwner {
        _baseUrl = baseUrl;
    }

    function getImageUrl(uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked(_baseUrl, Strings.toString(tokenId), ".png"));
    }
}