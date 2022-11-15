/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
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


pragma solidity ^0.8.4;


contract StarkSport_Banker{

    address public owner;
    IERC20 public token;
    uint public minAmount = 1*10**18;       // token
    uint public minAmountBNB = 1*10**15;    // bnb
    address public bankerAddress;
    bool public deposit_BNB_Status=false;
    bool public deposit_Token_Status=true;
    bool public claim_token_Status=true;

    function updateDepositStatus(bool tokenStatus, bool bnbStatus, bool claimTokenStatus) public checkOwner{
        deposit_BNB_Status = bnbStatus;
        deposit_Token_Status = tokenStatus;
        claim_token_Status = claimTokenStatus;
    }   

    constructor(address tokenAdddress){
        owner = msg.sender;
        bankerAddress = msg.sender;
        token = IERC20(tokenAdddress);
    }

    modifier checkOwner{
        require(msg.sender==owner, "Sorry, you're not allowed");
        _;
    }

    modifier checkBanker{
        require(msg.sender==bankerAddress, "Sorry, you're not allowed");
        _;
    }

    // typeCurrency:1 BNB, 0 Token
    event new_deposit(string idPlayer, uint amountToken, uint256 timeDeposit, uint typeCurrency);

    function depositBalance(string memory idPlayer, uint amountToken) public{
        require(deposit_Token_Status==true, "Can not deposit at this moment");
        require(amountToken>= minAmount, "Wrong amount");
        require(token.allowance(msg.sender, address(this))>=amountToken, "Not approval enought");
        require(token.balanceOf(msg.sender)>=amountToken, "You don't have token enought");
        token.transferFrom(msg.sender, address(this), amountToken);
        emit new_deposit(idPlayer, amountToken, block.timestamp, 0);
    }

    function depositBalanceBNB(string memory idPlayer) public payable{
        require(deposit_BNB_Status==true, "Can not deposit at this moment");
        require(msg.value>= minAmountBNB, "Minimum BNB is invalid");
        emit new_deposit(idPlayer, msg.value, block.timestamp, 1);
    }

    function changeOwner(address newOwnerAddress) public checkOwner{
        require(newOwnerAddress!=address(0), "Wrong address");
        owner = newOwnerAddress;
    }

    function changeTokenAddress(address newTokenAddress) public checkOwner{
        require(newTokenAddress!=address(0), "Wrong address");
        token = IERC20(newTokenAddress);
    }

    function withdrawToken(address receiverAddress) public checkOwner{
        require(receiverAddress!=address(0), "Wrong address");
        require(token.balanceOf(address(this))>0, "Token balance is 0");
        token.transfer(receiverAddress, token.balanceOf(address(this)));
    }

    function claimToken(address receiverAddress) public checkBanker{
        require(claim_token_Status==true, "Can not claim token");
        require(receiverAddress!=address(0), "Wrong address");
        require(token.balanceOf(address(this))>0, "Token balance is 0");
        token.transfer(receiverAddress, token.balanceOf(address(this)));
    }

    function withdrawBNB(address receiverAddress) public checkOwner{
        require(receiverAddress!=address(0), "Wrong address");
        require(address(this).balance>0, "BNB balance is 0");
        payable(receiverAddress).transfer(address(this).balance);
    }

    function updateMinAmount(uint newAmount) public checkOwner{
        require(newAmount>0, "Wrong amount");
        minAmount = newAmount;
    }

    function updateMinAmountBNB(uint newAmount) public checkOwner{
        require(newAmount>0, "Wrong amount");
        minAmountBNB = newAmount;
    }

    function updateBanker(address newBanker) public checkOwner{
        require(newBanker!=address(0), "Wrong address");
        bankerAddress = newBanker;
    }    

}