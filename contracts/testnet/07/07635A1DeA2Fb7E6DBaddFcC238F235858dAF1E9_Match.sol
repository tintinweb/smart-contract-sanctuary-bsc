/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        //   require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        //   require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}


contract Match {
    using SafeMath for uint256;

    struct Bet{
        uint256 value;
        uint8 option;
    }

    // Important addresses
    address private admin;
    
    // Public vars
    address [] public bettors;        // holds all adresses
    mapping (address => Bet) public bets;    // maps adress to value and choice
    uint[] public bets_sum;
    uint32 public match_id;
    int8 public result;
    uint8 public options_num;
    bool public canceled;
    string public description;
    uint32 public dev_fee;
    uint public min_bet;
    bool matchStatus;
    IERC20 tokenAddress;
    
    // Consts
    uint32 constant hour = 60*60;

    // Match constructor - this contract contains all bets which belongs to certain match
    constructor(uint32 _match_id, address _admin, uint8 _options_num, 
    string memory _description, uint32 _dev_fee, uint _min_bet, bool _matchStatus, IERC20 _tokenAddress) public  {
        admin = _admin;             // set admin to prevent owning contract failure
        match_id = _match_id;
        canceled = false;
        result = -1;                // -1 unknown ... the rest corresponds to option
        options_num = _options_num; // possible match results
        bets_sum = new uint[](options_num);
        description = _description;
        dev_fee = _dev_fee;
        min_bet = _min_bet;
        matchStatus = _matchStatus;
        tokenAddress = _tokenAddress;
    }
    
    // ------------ USER FUNCTIONS -------------
    
    function bet(uint8 option, uint256 amount) external  {
        require(matchStatus == true, "bet cannot be made now");
        require(option >= 0 && option < options_num, "impossible option");
        require(amount >= min_bet, "too low bet");
        
        uint funds = amount*dev_fee/1000;
        if (bets[msg.sender].value == 0){
            tokenAddress.transferFrom(msg.sender, address(this), amount);
            bets[msg.sender].value = funds;
            bets[msg.sender].option = option;
            bets_sum[option] += funds;
            bettors.push(msg.sender);
        } else {
            bets_sum[bets[msg.sender].option] -= bets[msg.sender].value;
            bets[msg.sender].value += funds;
            bets[msg.sender].option = option;
            bets_sum[option] += bets[msg.sender].value;
        }
    }
    
    function refund() external {
        // you can withraw funds from match which did not start yet or has been canceled
        require(matchStatus == false || canceled, "funds cannot be withdrawn");
        
        uint return_value;
        if (canceled){
            return_value = bets[msg.sender].value*1000/dev_fee;  // return dev fee
        } else {
            return_value = bets[msg.sender].value;
        }
        bets_sum[bets[msg.sender].option] -= bets[msg.sender].value;
        bets[msg.sender].value = 0;
        tokenAddress.transfer(address(msg.sender), return_value);
    }
    
    function claim_win() external {
        require(result >= 0 && !canceled, "match is not finished");
        require(uint8(result) == bets[msg.sender].option, "you are not a winner");
        require(bets[msg.sender].value > 0, "your funds has been already withdrawn");
        
        uint winned_sum = 0;
        uint winner_bet = bets[msg.sender].value; 
        for (uint8 i = 0; i < options_num; i++){
            if (i != uint8(result)) {
                uint option_win = bets_sum[i]*winner_bet/bets_sum[uint(result)];
                winned_sum += option_win;
                bets_sum[i] -= option_win;
            }
        }
        winned_sum += bets[msg.sender].value;
        bets_sum[uint(result)] -= winner_bet;
        bets[msg.sender].value = 0;
        tokenAddress.transfer(address(msg.sender), winned_sum*(dev_fee+10)/dev_fee);
    }
    
    // ------------ ADMIN FUNCTIONS ------------
    
    // GETTERS
    
    function get_options_value() public view returns(uint[] memory) {
        return bets_sum;
    }
    
    function bets_sums() public view returns(uint) {
        uint sum;
        for (uint8 i = 0; i < options_num; i++) {
            sum += bets_sum[i];
        }
        return sum;
    }
    
    function get_address_option(address addr) external view returns(int16) {
        if (bets[addr].value > 0) {
            return bets[addr].option;
        } else {
            return -1;
        }
    }
    
    function get_unpaid_winners_in_nth_100(uint32 n) public view returns(address [] memory) {
        require(result >= 0, "no result - no unpaid winner");
        
        address [] memory ret = new address [](100);
        uint max_size = (n+1)*100;
        if (bettors.length < max_size){
            max_size = bettors.length;
        }
        for (uint32 i = n*100; i < max_size; i++){
            if (bets[bettors[i]].value > 0 && bets[bettors[i]].option == uint8(result)){
                ret[i] = bettors[i];
            }
        }
        return ret;
    }
    
    function get_bettors_num() public view returns(uint32) {
        return uint32(bettors.length);
    }
    
    // SETTERS
    
    function set_result(uint8 _result) external {
        require(msg.sender == admin, "only owner can call this");
        require(_result >= 0 && _result < options_num, "impossible result");
        require(matchStatus == false, "match is not finished yet");
        require(!canceled, "match was canceled");
        require(bets_sum[_result] > 0 && bets_sum[_result] < bets_sums());
        
        result = int8(_result);
    }
    
    function cancel_match() external  {
        require(msg.sender == admin, "only owner can call this");
        require(canceled == false, "the match is already canceled");
        require(result < 0, "match has already result");
        
        canceled = true;
    }

    function setMatchStatus(bool _matchStatus) external {
        matchStatus = _matchStatus;
    }
    
    // CROWD CONTROL

    function return_funds(address recipient) external {
        // in case of canceling the match, this method return funds of certain address
        require(msg.sender == admin, "only owner can call this"); 
        require(canceled, "match is not canceled, funds cannot be returned");
        
        uint return_value = bets[recipient].value*1000/dev_fee;   // return dev_fee
        bets_sum[bets[recipient].option] -= bets[recipient].value;
        bets[recipient].value = 0;

        tokenAddress.transfer(address(recipient), return_value);
    }
    
    function payout(address  winner) external  {
        require(msg.sender == admin, "only owner can call this");   
        require(result >= 0 && !canceled, "match is not finished");
        require(uint8(result) == bets[winner].option, "you are not a winner");
        require(bets[winner].value > 0, "your funds has been already withdrawn");
        require(matchStatus == false, "too soon to autopayout");
        
        uint winned_sum = 0;
        uint winner_bet = bets[msg.sender].value; 
        for (uint8 i = 0; i < options_num; i++){
            if (i != uint8(result)) {
                uint option_win = bets_sum[i]*winner_bet/bets_sum[uint(result)];
                winned_sum += option_win;
                bets_sum[i] -= option_win;
            }
        }
        winned_sum += bets[winner].value;
        bets_sum[uint8(result)] -= bets[winner].value;
        bets[winner].value = 0;
        tokenAddress.transfer(address(msg.sender), winned_sum);
    }

    function close_contract() external  {
        require(msg.sender == admin, "only owner can call this");    
        require(matchStatus == false || bets_sum[uint8(result)] == 0, "match cannot be closed yet");
        require(result >= 0 || canceled, "match was not resolved");
        
        selfdestruct(msg.sender);
    }
}

contract MatchFactory is Ownable {
    mapping (uint32 => Match) public matches;
    uint32 public dev_fee;
    uint public min_bet;
    
    // Parent contract constructor
    constructor() public {
        dev_fee = 975;
        min_bet = 10000000000000000;
    }
    
    // method for initialisation of match, match_time is in UTC unix time in sec
    function init_match(uint8 options_num, 
    string calldata description, 
    uint32 _id,
    address admin, 
    bool matchStatus,
    IERC20 tokenAddress) external onlyOwner {
        require(options_num > 1, "every match must have at least two stacks");
        require(matches[_id] == Match(0), "match with this id already exists");
        
        matches[_id] = new Match(_id, admin, options_num, description, dev_fee, min_bet, 
        matchStatus, tokenAddress);
    }

    // SETTERS
    function set_dev_fee(uint32 _dev_fee) external onlyOwner {
        require(_dev_fee > 500 && dev_fee < 1000, "should be in mille");

        dev_fee = _dev_fee;
    }

    function set_min_bet(uint _min_bet) external onlyOwner {
        require(_min_bet > min_bet, "this would be very small bet");
        
        min_bet = _min_bet;
    }
    
    
    // DESTROY CONTRACTS
    function close_match(uint32 _id) external onlyOwner {
        matches[_id].close_contract();
        delete matches[_id];
    }
    
}