// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./IERC721.sol";
import "./IERC1155.sol";
import "./ReentrancyGuard.sol";
contract Vault is ReentrancyGuard {

    event Rented(
        address renter,
        address nft,
        uint tokenId,
        uint amount
    );

    event Extract(
        address extracter,
        address nft,
        uint tokenId,
        uint amount
    );

    mapping(address => mapping(address => mapping(uint => uint))) public Relation;

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function rent(
        uint[] memory _type,
        address[] memory _nft,
        uint[] memory _id,
        uint[] memory _amount,
        bytes[] memory _data
    ) external {
        require(_type.length == _nft.length,"NFT length llg");
        require(_type.length == _id.length,"ID length llg");
        require(_type.length == _amount.length,"AMOUNT length llg");
        require(_type.length == _data.length,"DATA length llg");

        for(uint i = 0; i < _nft.length; i++){
             _nftSend(_type[i],_nft[i],_id[i],_amount[i],_data[i],address(this),msg.sender);
        }
    }

    function extract(
        uint _type,
        address _nft,
        uint _id,
        uint _amount,
        bytes memory _data
    ) public {
        require(Relation[msg.sender][_nft][_id] >= _amount,"Insufficient amount");
        _nftSend(_type,_nft,_id,_amount,_data,msg.sender,address(this));
        Relation[msg.sender][_nft][_id] -= _amount;
        emit Extract(msg.sender,_nft,_id,_amount);
    }

    function extractBatch(
        uint[] memory _type,
        address[] memory _nft,
        uint[] memory _id,
        uint[] memory _amount,
        bytes[] memory _data
    ) public {
        for(uint i = 0; i < _nft.length; i++){
             extract(_type[i],_nft[i],_id[i],_amount[i],_data[i]);
        }
    }

    function _nftSend(
        uint _type,
        address _nft,
        uint _id,
        uint _amount,
        bytes memory _data,
        address _to,
        address _from
    ) private {
        if(_type == 721){
            IERC721 nft721 = IERC721(_nft);
            nft721.transferFrom(_from,_to,_id);
        }else if(_type == 1155){
            IERC1155 nft1155 = IERC1155(_nft);
            nft1155.safeTransferFrom(_from,_to,_id,_amount,_data);
        }else{
            revert("I won't support it");
        }

        Relation[_from][_nft][_id] += _amount;
        emit Rented(_from,_nft,_id,Relation[_from][_nft][_id]);
    }
}