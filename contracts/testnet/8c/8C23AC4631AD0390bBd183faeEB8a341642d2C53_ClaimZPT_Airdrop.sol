/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
// ZombiePets.io Team
pragma solidity ^0.8.14;

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

contract ClaimZPT_Airdrop{

    IERC20 public tokenZPT = IERC20(0x461a00691f27214A7007B4e6C2b2067892682A8C);
    address private owner; 
    address[] public users_Claimed;
    uint public amountZPT = 40000*10**18;
    bool public claimStatus=true;
    
    constructor(){
        owner = msg.sender;
    }

    modifier checkOwner(){
        require(msg.sender==owner, "You are not allowed.");
        _;
    }

    function claim_ZPT() public{
        require(checkUserClaimed()==false, "Sorry, you have claimed already");
        require(claimStatus==true, "Sorry, you can not claim at this time");
        require(tokenZPT.balanceOf(address(this))>amountZPT, "Sorry, we dont have token enough");
        tokenZPT.transfer(msg.sender, amountZPT);
        users_Claimed.push(msg.sender);
    }

    function checkUserClaimed() public view returns(bool){
        bool check = false;
        for(uint i=0; i<users_Claimed.length; i++){
            if(users_Claimed[i]==msg.sender){
                check = true;
                break;
            }
        }
        return check;
    }

    function updateZPTAddress(address _newAddress) public checkOwner{
        require(_newAddress!=address(0));
        tokenZPT = IERC20(_newAddress);
    }

    function updateAmountZPT(uint _newAmount) public checkOwner{
        amountZPT = _newAmount;
    }

    function updateClaimStatus(bool _claimStatus) public checkOwner{
        claimStatus = _claimStatus;
    }

    function getTotalUsersClaimed() public view returns(uint){
        return users_Claimed.length;
    }

    function getAddressUserClaim(uint ordering) public view returns(address){
        require(ordering<users_Claimed.length, "Wrong ordering.");
        return users_Claimed[ordering];
    }

}