// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC1155.sol";
import "./Ownable.sol";
import "./ERC1155Burnable.sol";
import "./EnumerableSet.sol";
import "./ERC1155Supply.sol";

contract ESNFT_1155 is ERC1155, ERC1155Burnable, ERC1155Supply{
    using EnumerableSet for EnumerableSet.AddressSet;
    using Strings for uint256;
    
    EnumerableSet.AddressSet private admins;
    uint256 public nextTokenIdToMint;
    string public baseURI;
    string public baseExtension = ".json";

    modifier onlyAdmin() {
        require(admins.contains(_msgSender()), "NOT ADMIN");
        _;
    }

    constructor(string memory _initBaseURI, string memory _name, string memory _symbol) ERC1155(_name, _symbol) {
        admins.add(msg.sender);
        setBaseURI(_initBaseURI);
    }

    function mintTo(
        address account, 
        uint256 id, 
        uint256 amount, 
        bytes memory data
    ) public{
        require(
            _msgSender().code.length > 0 || admins.contains(_msgSender()), 
            "Address can't mint NFT"
        );
        require(id <= nextTokenIdToMint, "Invalid for id token ERC1155");
        if(id == nextTokenIdToMint) {
            nextTokenIdToMint += 1;
        }
        _mint(account, id, amount, data);
    }

    function mintBatch(address account, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external
        onlyAdmin
    {
        require(ids.length == amounts.length, "Invalid input data");
        for(uint256 i = 0; i < ids.length; i++) {
            mintTo(account, ids[i], amounts[i], data);
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public  {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public {
        baseExtension = _newBaseExtension;
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function updateAdmin(address _adminAddr, bool _flag) external onlyAdmin {
        require(_adminAddr != address(0), "INVALID ADDRESS");
        if (_flag) {
            admins.add(_adminAddr);
        } else {
            admins.remove(_adminAddr);
        }
    }

    function getAdmins() external view returns (address[] memory) {
        return admins.values();
    }

    function setSizeContract(uint256 _sizeContract) external onlyAdmin {
        _setSizeContract(_sizeContract);
    }
}