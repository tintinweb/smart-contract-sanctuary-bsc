// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "ERC721A.sol";
import "Ownable.sol";

contract FantasyShoujo is ERC721A, Ownable {
    uint256 private _maxSupply = 6000;
    uint256 private _maxOnChainMint = 1000;
    uint256 private _maxOffChainMint = _maxSupply - _maxOnChainMint;

    bool private _onChainMintEnabled = false;
    uint256 private _onChainMintCount = 0;
    uint256 private _mintPrice = 0.02 ether;
    uint256 private _mintQuotaPerAddress = 1;

    address private _hotWallet;

    mapping(address => bool) private _minted;

    string private baseURI;

    constructor(address hot_wallet, string memory base_uri) ERC721A("Fantasy Shoujo by i.ls", "SHOUJO") {
        _hotWallet = hot_wallet;
        baseURI = base_uri;
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

    function setMintStatus(bool enabled) public onlyOwner {
        _onChainMintEnabled = enabled;
    }

    function mint() public payable {
        require(_onChainMintEnabled, "Minting not started");
        require(_onChainMintCount < _maxOnChainMint, "Max supply exceeded");
        require(msg.value >= _mintPrice, "Insufficient funds");
        require(checkQuota(msg.sender), "Exceed quota");

        // send ethers to owner
        payable(owner()).transfer(msg.value);

        _mint(msg.sender, 1);
        _minted[msg.sender] = true;
        _onChainMintCount++;

        // refund if overpaid
        if (msg.value > _mintPrice) {
            payable(msg.sender).transfer(msg.value - _mintPrice);
        }
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

    function setBaseUri(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}