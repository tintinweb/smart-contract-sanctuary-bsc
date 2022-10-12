/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT

//Developer : FazelPejmanfar , Twitter :@Pejmanfarfazel
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

pragma solidity >=0.7.0 <0.9.0;

contract Escrow {

    enum State { 
        AWAITING_PAYMENT, 
        AWAITING_DELIVERY, 
        COMPLETE 
        }
    
    State public CurrentState;
    
    address public Owner;
    address public Client;
    address payable public Seller;
    
  modifier onlyOwner() {
        require(msg.sender == Owner, "Only Owner can call this method");
        _;
    }

    modifier onlyClient() {
        require(msg.sender == Client, "Only Client can call this method");
        _;
    }

        modifier onlySeller() {
        require(msg.sender == Seller, "Only seller can call this method");
        _;
    }

    function ContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    constructor(address _Owner, address _Client, address payable _Seller)
    {
        Owner = _Owner;
        Client = _Client;
        Seller = _Seller;
    }

    function ChangeClient(address _newClient) external onlySeller {
        require(CurrentState == State.COMPLETE, "Previous Payment Need to Be Made");
        Client = _newClient;
        CurrentState = State.AWAITING_PAYMENT;
    }

        function renewCurrentClient() external onlySeller {
        require(CurrentState == State.COMPLETE, "Previous Payment Need to Be Made");
        CurrentState = State.AWAITING_PAYMENT;
    }
    
    function deposit() onlyClient external payable {
        require(CurrentState == State.AWAITING_PAYMENT, "Already paid");
        CurrentState = State.AWAITING_DELIVERY;
    }
    
    function confirmDelivery() onlyClient external {
        require(CurrentState == State.AWAITING_DELIVERY, "Cannot confirm delivery");
        Seller.transfer(address(this).balance * 50/100);
        CurrentState = State.COMPLETE;
    }
 function withdrawErc20(IERC20 token) onlyOwner external{
  require(token.transfer(msg.sender, token.balanceOf(address(this))), "Transfer failed");
}

}