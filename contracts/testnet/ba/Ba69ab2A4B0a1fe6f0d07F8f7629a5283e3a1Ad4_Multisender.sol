/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IERC721
{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract Multisender
{
    address  public id;
    constructor()
    {
        // cài đặt id của owner
        id=msg.sender;
    }
    function sendERC20(IERC20 _token, address[] calldata _to, uint[] calldata _amount) public 
    {
        require(msg.sender == id,"You are not the owner");
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
        require(msg.sender == id,"You are not the owner");
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
        require(msg.sender == id,"You are not the owner");
        require(_to.length == _tokenId.length, "Not enough data");
        //không có đủ dữ liệu
        for (uint i=0;i<_to.length;i++)
        {
            _token.safeTransferFrom(msg.sender,_to[i],_tokenId[i]);
            // chuyển NFT có id[i] tới to[i] từ người gửi
        }
    }
    
}