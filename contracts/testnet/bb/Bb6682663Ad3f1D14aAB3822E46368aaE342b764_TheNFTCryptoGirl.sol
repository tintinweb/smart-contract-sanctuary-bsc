pragma solidity 0.6.12;

import "./TheNFTCryptoGirlHelper.sol";

contract TheNFTCryptoGirl is TheNFTCryptoGirlHelper {

    using SafeMath for uint256;

    /*
    function balanceOf(address _owner) public view virtual override returns (uint256) {
        return _balances[_owner];
    }
    */

    /*
    function ownerOf(uint256 _tokenId) public view virtual override returns (address) {
        return _owners[_tokenId];
    }
    */

    /*
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        _approve(address(0), tokenId);

        _balances[from] = _balances[from].sub(1);
        _balances[to] = _balances[to].add(1);
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    */

    /*
    function transferFrom(address _from, address _to, uint256 _tokenId) public virtual override {
        require (_owners[_tokenId] == msg.sender || _tokenApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }
    */

    /*
    function approve(address _approved, uint256 _tokenId) public virtual override onlyOwnerOf(_tokenId) {
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
    */

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked("https://nft.cryptogirl.finance/nft/", tokenId));
    }
}