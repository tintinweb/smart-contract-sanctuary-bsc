// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IERC20.sol";
import "./IERC721.sol";
import "./IERC1155.sol";
import "./Address.sol";
import "./ReentrancyGuard.sol";

contract Batch is ReentrancyGuard {

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
    }

    function nftBatch(
        uint[] memory _types,
        address[] memory _nfts,
        uint[] memory _ids,
        uint[] memory _amounts,
        bytes[] memory _datas,
        address[] memory _tos
    ) external nonReentrant {
        require(_types.length == _nfts.length,"NFT length llg");
        require(_types.length == _ids.length,"ID length llg");
        require(_types.length == _amounts.length,"AMOUNT length llg");
        require(_types.length == _datas.length,"DATA length llg");
        require(_types.length == _tos.length,"TO length llg");

        for(uint i = 0; i < _nfts.length; i++){
             _nftSend(_types[i],_nfts[i],_ids[i],_amounts[i],_datas[i],_tos[i],msg.sender);
        }
     
    }

    function tokenBatch(
        address[] memory recipients,
        address[] memory tokens,
        uint256[] memory amounts
    ) external payable nonReentrant {
        require(recipients.length == tokens.length,"TOKEN length llg");
        require(recipients.length == amounts.length,"AMOUNT length llg");

        for(uint256 i = 0;i < tokens.length;i++){
            require(_tokenSend(recipients[i],tokens[i],amounts[i]),"Token tranfer fail");
        }
    }

    function _tokenSend(
        address _to,
        address _token,
        uint _amount
    ) private returns (bool result) {
        if(_token == address(0)){
            Address.sendValue(payable(_to),_amount);
            result = true;
        }else{
            IERC20 token = IERC20(_token);
            result = token.transferFrom(msg.sender,_to,_amount);
        }
    }
}