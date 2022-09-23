// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "address.sol";
import "strings.sol";
import "IERC721Receiver.sol";
import "IERC721.sol";
import "IERC721Metadata.sol";
import "Ownable.sol";


interface ERC721 {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function approve(address _approved, uint256 _tokenId) external;


    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

contract SFTAlpha is Ownable, ERC165, ERC721
{
    using Address for address;
    using Strings for uint256;
    string private _name;
    string private _symbol;
    string private _baseURI;
    mapping(uint256 => address) private _owners;
    mapping(uint256 => uint256) private _rareness;
    mapping(uint256 => uint256) private _power;
    mapping(uint256 => uint256) private _durability;
    mapping(uint256 => uint256) private _luck;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => string) private _type;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor() {
        _name = 'SportFanTournament';
        _symbol = 'SFTAlpha';
        _baseURI = 'ipfs://';
    }
    function name() external view returns (string memory)
  {return _name;}

    function symbol() external view returns (string memory)
  {return _symbol;}
    
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }


    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
function tokenURI(uint256 _tokenId) public view returns (string memory) {
  return string(abi.encodePacked(
      _baseURI,
      _tokenURIs[_tokenId]
  ));
  }
function tokenINFO(uint256 _tokenId) public view returns (string memory, uint256 rareness, uint256 power,uint256 durability, uint256 luck, string memory nft_type ) {
  return (string(abi.encodePacked(
      _baseURI,
      _tokenURIs[_tokenId])), _rareness[_tokenId], _power[_tokenId], _durability[_tokenId], _luck[_tokenId], _type[_tokenId])
  ;
  }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }


    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }


    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public{
        _safeTransferFrom(from, to, tokenId, "");
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal{
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function safeMint(address to, uint256 tokenId, string memory uri, uint256 rareness, uint256 power,uint256 durability, uint256 luck, string memory nft_type) public onlyOwner {
        _safeMint(to, tokenId, "");
        _setTokenURI(tokenId,uri);
        _setRareness(tokenId,rareness);
        _setPower(tokenId,power);
        _setDurability(tokenId,durability);
        _setLuck(tokenId,luck);
        _setType(tokenId,nft_type);
    }
  function upgradeNft(uint256 tokenId, string memory uri, uint256 rareness, uint256 power,uint256 durability, uint256 luck, string memory nft_type) public onlyOwner {
        _setTokenURI(tokenId,uri);
        _setRareness(tokenId,rareness);
        _setPower(tokenId,power);
        _setDurability(tokenId,durability);
        _setLuck(tokenId,luck);
        _setType(tokenId,nft_type);
    }
      function _setTokenURI(uint256 tokenId,string memory uri) internal {
      _tokenURIs[tokenId] = uri;}
      function _setRareness(uint256 tokenId,uint256 rareness) internal {
      _rareness[tokenId] = rareness;}
      function _setPower(uint256 tokenId,uint256 power) internal {
      _power[tokenId] = power;}
      function _setDurability(uint256 tokenId,uint256 durability) internal {
      _durability[tokenId] = durability;}
      function _setLuck(uint256 tokenId,uint256 luck) internal {
      _luck[tokenId] = luck;}

      function _setType(uint256 tokenId,string memory nft_type) internal {
      _type[tokenId] = nft_type;}

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }


    function burn(uint256 tokenId, address delete_from) public onlyOwner {
        address owner = delete_from;

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _tokenURIs[tokenId];
        delete _type[tokenId];
        delete _power[tokenId];
        delete _durability[tokenId];
        delete _luck[tokenId];
        delete _rareness[tokenId];
        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

 
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}