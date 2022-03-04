// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.12;

import './BitMaps.sol';
import './IERC721Receiver.sol';
import './IERC721.sol';
import './IERC20.sol';
import './ERC165.sol';
import './Ownable.sol';
import './Math.sol';

contract BoxNFT is ERC165, IERC721, Ownable {

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    uint256 public burnAmount = 0;

    uint256 public maxId = 0;

    using BitMaps for BitMaps.BitMap;
    BitMaps.BitMap private _isMinted;

    function name() public pure returns (string memory) {
        return "Nom Box NFTs";
    }

    function symbol() public pure returns (string memory) {
        return "Nom Box NFT";
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function decimals() public pure returns (uint8) {
        return 0;
    }


    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");
        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function transfer(address to, uint256 tokenId) public {
        transferFrom(msg.sender, to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) private {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);
        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) private view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _exists(uint256 tokenId) private view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function isMinted(uint256 tokenId) public view returns (bool) {
        return _isMinted.get(tokenId);
    }

    function mint(address to, uint256 startId, uint256 num) public onlyOwner {
        for (uint256 i = 0; i < num; i++) {
            _mint(to, startId + i);
        }
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        _mint(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) private {
        require(!isMinted(tokenId), "tokenId already minted");
        _isMinted.set(tokenId);
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        if (tokenId > maxId) {
            maxId = tokenId;
        }
        emit Transfer(address(0), to, tokenId);
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = _owners[tokenId];

        _beforeTokenTransfer(owner, address(0), tokenId);
        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        burnAmount++;

        emit Transfer(owner, address(0), tokenId);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (!isContract(to)) {
            return true;
        }

        try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            } else {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    function tokenOfOwner(address owner, uint256 pageNum, uint256 pageSize) external view returns (uint256[] memory tokens, uint256 total) {
        total = balanceOf(owner);
        uint256 from = pageNum * pageSize;
        if (total <= from) {
            return (new uint256[](0), total);
        }

        uint256 minNum = Math.min(total - from, pageSize);
        tokens = new uint256[](minNum);

        for (uint256 i = 0; i < minNum; i++) {
            tokens[i] = _ownedTokens[owner][from++];
        }
    }

    function tokenOfAll(uint256 pageNum, uint256 pageSize) external view returns (uint256[] memory tokens, address[] memory owners, uint256 total) {
        total = totalSupply();
        uint256 from = pageNum * pageSize;
        if (total <= from) {
            return (new uint256[](0), new address[](0), total);
        }

        uint256 minNum = Math.min(total - from, pageSize);
        tokens = new uint256[](minNum);
        owners = new address[](minNum);

        uint256 tokenId;

        for (uint256 i = 0; i < minNum; i++) {
            tokenId = _allTokens[from++];
            tokens[i] = tokenId;
            owners[i] = _owners[tokenId];
        }
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId;
        _allTokensIndex[lastTokenId] = tokenIndex;

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function retrieveToken(address tokenAddress, uint256 amount, address receiveAddress) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(receiveAddress, amount);
    }

    function retrieveMainBalance(address receiveAddress) external onlyOwner {
        payable(receiveAddress).transfer(address(this).balance);
    }

    function withdrawNft(address nftAddress, uint256 tokenId, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "recipient is zero address");
        IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenId);
    }

    function batchWithdrawNft(address nftAddress, uint256[] memory tokenIds, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "Receive address is zero address");
        require(tokenIds.length > 0, "tokenIds is empty");
        for (uint256 index = 0; index < tokenIds.length; index++) {
            IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenIds[index]);
        }
    }

    function batchTransfer(address[] memory receiveAddress, uint256[] memory tokenIds) public {
        require(receiveAddress.length == tokenIds.length, "Invalid parameter length");
        for (uint256 index = 0; index < receiveAddress.length; index++) {
            _transfer(msg.sender, receiveAddress[index], tokenIds[index]);
        }
    }
}