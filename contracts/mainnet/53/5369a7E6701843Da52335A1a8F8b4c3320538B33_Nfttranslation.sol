/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed

    interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;





    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function mintBatch2(
        address[] memory accounts,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;



}



interface ERC721 {
    event Transfer(address indexed _from,address indexed _to,uint256 indexed _tokenId);
    event Approval(address indexed _owner,address indexed _approved,uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner,address indexed _operator,bool _approved);
    function safeTransferFrom(address _from,address _to,uint256 _tokenId,bytes calldata _data) external;   
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;   
    function transferFrom(address _from,address _to,uint256 _tokenId) external;
    function approve(address _approved,uint256 _tokenId) external;
    function setApprovalForAll(address _operator,bool _approved) external;
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function getApproved(uint256 _tokenId) external view returns (address);
    function mint(address _to,uint256 _tokenId,string calldata _uri) external;
    function tokenURI(uint256 _tokenId) external view returns(string calldata  _uri);
    function isApprovedForAll(address _owner,address _operator) external view returns (bool);
}

    

 

// 基类合约

    contract Base {

      
    ERC721      public NFT721    = ERC721(0xAC46E2255379c7065084D80B8b005AAAeaa9688e);
    IERC1155     public NFT     = IERC1155  (0xe8e1d14F445923688F3D4ED96d499E39191a8880);
    address public _owner;
    address USDTaddress; 
    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }
    function transfeUSDTship(address newadd) public onlyOwner {
        require(newadd != address(0));
        USDTaddress = newadd;
    }
    receive() external payable {}  
}

contract Nfttranslation is Base{
    function translation(uint256 Num) public {
        NFT721.transferFrom(  msg.sender,  USDTaddress,  Num);
        NFT.mintBatch2( _asArray(msg.sender),_asSingletonArray(8),_asSingletonArray(1));
    }
    function _asArray(address add) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = add;
        return array;
    }
    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        require(element != 0, "0"); 
        array[0] = element;
        return array;
    }
    constructor()public {
        _owner = msg.sender; 
        USDTaddress = msg.sender;
 
    }

}