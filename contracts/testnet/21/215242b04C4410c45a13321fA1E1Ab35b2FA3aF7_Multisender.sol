/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IERC20
{
    function transfer(address to, uint256 amount) external returns (bool);
}
interface IERC721
{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract Multisender
{
    constructor(){}
    function sendERC20(IERC20 _token, address[] calldata _to, uint[] calldata _amount) public 
    {
        require(_to.length == _amount.length, "Not enough data");
        // danh sách không đủ dữ liệu
        for(uint i=0;i<_to.length;i++)
        {
            _token.transfer(_to[i],_amount[i]);
            // chuyển tiền tới to[i] với lượng amount[i]
        }
    }
    function sendETH(address payable[] calldata _to,uint[] calldata _amount) public
    {
        require(_to.length == _amount.length, "Not enough data");
        // danh sách không đủ dữ liệu
        for(uint i=0;i<_to.length;i++)
        {
            _to[i].transfer(_amount[i]);
            // chuyển tiền tới to[i] với lượng amount[i]
        }
    }
    function sendERC721(IERC721 _token, address[] calldata _to,uint[] calldata _tokenId) public
    {
        require(_to.length == _tokenId.length, "Not enough data");
        //không có đủ dữ liệu
        for (uint i=0;i<_to.length;i++)
        {
            _token.safeTransferFrom(msg.sender,_to[i],_tokenId[i]);
            // chuyển NFT có id[i] tới to[i] từ người gửi
        }
    }
    
}