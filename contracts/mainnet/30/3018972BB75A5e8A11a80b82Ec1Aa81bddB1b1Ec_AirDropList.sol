/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;
 
 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    } 
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
} 
abstract contract Ownable is Context {
    address public _owner; 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 
    constructor() {
        _transferOwnership(_msgSender()); 
    } 
    function owner() public view virtual returns (address) {
        return _owner;
    } 
    modifier onlyOwner() {
       require(owner() == _msgSender(), "Ownable: caller is not the owner"); 
        _;
    } 
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    } 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner); 
    } 
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}  
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}
contract AirDropList is Ownable{  

    address  owner_; 
    constructor(){
        owner_=msg.sender;
    }

    receive() external payable{    
        
    } 

    fallback() external payable{ 
    } 
    uint256 sendTotal;
    uint256 tokenbalance; 

    function AirDropToList(address[] memory _tolist,uint256 amount,address tokenaddr)public onlyOwner returns(bool){ 
        IERC20 token=IERC20(tokenaddr);  
        amount=amount*10**18; 
        tokenbalance=token.balanceOf(address(this));
        sendTotal=amount*_tolist.length;
        require(tokenbalance>sendTotal,"Insufficient balance");
        require(_tolist.length>0,"toList is zero");

            for(uint256 j=0;j<_tolist.length;j++){
                token.transfer(_tolist[j],amount);  
            } 
            return true;    
    } 

    function airDrop(address to,uint256 amount,address tokenaddr) public onlyOwner returns(bool){
        IERC20 token=IERC20(tokenaddr);
        amount=amount*amount*10**18; 
        tokenbalance=token.balanceOf(address(this));
        require(tokenbalance>amount,"Insufficient balance"); 
         token.transfer(to,amount);  
         return true;
    } 

    function withdrawalToken(address  _tokenAddr)public onlyOwner{
        IERC20 token=IERC20(_tokenAddr);
        token.transfer(_owner,token.balanceOf(address(this)));

    }

     
    
}