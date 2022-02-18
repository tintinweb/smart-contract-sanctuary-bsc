/*

███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗███████╗██╗  ██╗ ██████╗ ████████╗
████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██╔════╝██║  ██║██╔═══██╗╚══██╔══╝
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║███████╗███████║██║   ██║   ██║   
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║╚════██║██╔══██║██║   ██║   ██║   
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║███████║██║  ██║╚██████╔╝   ██║   
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝  

Moonshot is a deflationary, frictionless yield and liquidity protocol.

For every transaction, a fee of max. 10% is decucted and shared between holders, the liqduity pool and the dev/marketing wallet.
As the burn address participates as a holder, the supply is forever decreasing.

Started out at DEFI meme token, moonshot features MoonBoxes and MoonSea.

*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract MiniOwnable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}


contract DropMoonshot is Context, MiniOwnable {
    
    address public fromContract = 0x000000000000000000000000000000000000dEaD;
    address public toContract = 0x000000000000000000000000000000000000dEaD;

    mapping (address => bool) private _claimed;

    uint256 public _totalClaimed = 0;
 
    event SetFromTokenAddress(address newTokenContract);
    event SetToTokenAddress(address newTokenContract);
    event Claimed(address account, uint256 amount);
    event Withdraw(address tokenContract, uint256 amount);
    event RescueBNB(uint256 amount);

    constructor () public {
       
    }
 
    function setFromTokenAddress(address newTokenContract) external onlyOwner() {
        fromContract = newTokenContract;

        emit SetFromTokenAddress(fromContract);
    }

    function setToTokenAddress(address newTokenContract) external onlyOwner() {
        toContract = newTokenContract;

        emit SetToTokenAddress(toContract);
    }


    function claim() external {

        require( !_claimed[ msg.sender ], "Already claimed" );

        uint256 amount = IERC20(fromContract).balanceOf(msg.sender);

        require( amount > 0, "Your balance must be greater than 0");

        uint256 contractAmount = IERC20(toContract).balanceOf( address(this) );
        require( contractAmount > 0 , "Out of tokens");

        IERC20(toContract).transfer( msg.sender , amount);

        _claimed[ msg.sender ] = true;
        _totalClaimed += amount;

        emit Claimed(msg.sender, amount);
    }

    function withdraw(address tokenAddress) external onlyOwner {
        uint256 amount = IERC20(tokenAddress).balanceOf(msg.sender);
        IERC20(tokenAddress).transfer( msg.sender , amount);

        emit Withdraw(tokenAddress, amount);
    }

    function rescueBNB(uint256 amount) external onlyOwner {
        payable( msg.sender ).transfer(amount);
        emit RescueBNB(amount);
    }
  
    receive() external payable {}

}