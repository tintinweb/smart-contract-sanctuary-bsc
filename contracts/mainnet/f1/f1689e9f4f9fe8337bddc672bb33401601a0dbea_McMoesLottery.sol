/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

// File: contracts/Lottery.sol


 pragma solidity ^0.8.0;

 //import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

 
 contract McMoesLottery{
     
     IERC20 token;
     address public manager;
     address[] public players;
     uint amount;

     event TransferSent(address _from, address _destAddr, uint _amount);
     
     constructor() {
        manager = msg.sender;
        // define your token used token smart contract address here
        token = IERC20(0xf209CE1960Fb7E750ff30Ba7794ea11C6Acdc1f3);
        amount = 60000000000000000000;
     }
     
   
     function random() private view returns(uint){
         return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
     }
     
     modifier restricted(){
         require(msg.sender == manager);
         _;
     }
     
     function getPlayers() public view returns(address[] memory){
         return players;
     } 

    function getCurrentTicketPrice() public view returns (uint256) {
        return amount;
    }

    function setNewTicketPrice(uint256 _newAmount) public restricted{
        amount = _newAmount;
    }

    function getCurrentPoolAmount() public view returns (uint256) {
        uint256 erc20balance = token.balanceOf(address(this));
        return erc20balance;
    }
   
   function getAllowance() public view returns(uint256){
       return token.allowance(msg.sender, address(this));
   }
   
   function acceptPayment() public returns(bool) {
       require(amount <= getAllowance(), "Please approve tokens before transferring");
       token.transferFrom(msg.sender, address(this), amount);
       players.push(msg.sender);
       return true;
   }

//    function withdrawToken(address to, uint256 amount) public {
//        require(msg.sender == manager, "Only manager can withdraw funds"); 
//        uint256 erc20balance = token.balanceOf(address(this));
//        require(amount <= erc20balance, "balance is low");
//        token.transfer(to, amount);
//        emit TransferSent(msg.sender, to, amount);
//    }   

    function pickWinner() public restricted{
        //pick a random winner out of players list
        uint index = random() % players.length;

        //pay the winner
        require(msg.sender == manager, "Only manager can withdraw funds"); 
        uint256 erc20balance = token.balanceOf(address(this));
        token.transfer(players[index], erc20balance);
        emit TransferSent(msg.sender, players[index], erc20balance);

        //reset players list
        players = new address[](0);
    }   

 }