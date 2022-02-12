/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// File: Staking_Reward.sol



pragma solidity ^0.8.0;


contract Staking_Reward {


    IERC20 internal Anac;

    uint256 public Start_Time;
    uint256 public END_Time;

    uint256 public bid_time;
    uint public Auction_counter;
    
    uint public bid_counter;

    uint public current_top_bid;
    address public Current_Bider;

    address[] public bid_winner; 
    address public Owner;

    struct userdata {
        address person;
        uint stake_token;
        uint Auction_no;
    }
    userdata[] public bid_data;

    mapping (address => uint256) public _user_staking_balance;

    constructor() {
        Anac = IERC20(0x8344aB267A91ddf529cAF7708fc8cdDd4EB9c422); //Main_Address
        Start_Time = block.timestamp;
        END_Time = Start_Time + 15 minutes; //7 days;
        Owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == Owner,"Caller is not Owner!!");
        _;
    }

    function transferOwnerShip(address _person) public onlyOwner {
        Owner = _person;
    }

    function Auction_Control(bool _state) public onlyOwner {
        if(_state){
            require(bid_time == 0,"Already Started");
            bid_time = block.timestamp + 3 minutes; //1 days;
            Auction_counter += 1;
        }
        if(!_state){
            require(bid_time > 0,"Auction Not Started Yet");
            require(block.timestamp > bid_time,"Auction is in Progress");

            bid_time = 0;

            Anac.transfer(Owner,current_top_bid * 10 ** 18);

            bid_winner.push(Current_Bider);
            
            _user_staking_balance[Current_Bider] = 0;

            Current_Bider = address(0);
            current_top_bid = 0;
            bid_counter = 0;
        }
    }

    function stake(uint _num) public {
        require(_num != 0,"Insufficient Funds!");
        require(msg.sender != address(0),"Sender Must have valid address");
        
        uint256 Staking_amount = _num * 10 ** 18;

        require(Anac.allowance(msg.sender,address(this)) >= Staking_amount,"Check the Allowance!!!");
        Anac.transferFrom(msg.sender,address(this),Staking_amount);

        _user_staking_balance[msg.sender] += _num;
    }

    function bid(uint _num) public {

        require(block.timestamp < bid_time && bid_time > 0,"Wait for Auction to Start!!");
        
        require(_num >= 1000, "Auction Bid Stating from 1000!!!");
        
        address _person = msg.sender;

        if (_user_staking_balance[_person] >= _num) {

            if(bid_counter == 0) {

                userdata memory newdata = userdata(_person,_num,Auction_counter);  /// order must be same
                bid_data.push(newdata);

                Current_Bider = _person;
                current_top_bid = _num;
                bid_counter += 1;
 
            }
            else {
                update_bider(_person,_num);

                for (uint i = 0 ; i < bid_data.length ; i++)
                {
                    if(bid_data[i].person == msg.sender)
                    {
                        if(bid_data[i].Auction_no == Auction_counter){
                            bid_data[i].stake_token = _num;
                        }
                    }
                    else if(i == bid_data.length - 1)
                    {
                        userdata memory newdata = userdata(_person,_num,Auction_counter);  /// order must be same
                        bid_data.push(newdata);
                        bid_counter += 1;
                    }
                }
            }
        }

        else {
            require(false,"Stake Some Tokens to Participate!!");
        }
    }

    function update_bider(address _person,uint Staking_amount) internal {
        for (uint i = 0 ; i < bid_data.length ; i++)
        {
            if(bid_data[i].Auction_no == Auction_counter){
                if(bid_data[i].stake_token < Staking_amount) {
                    Current_Bider = _person;
                    current_top_bid = Staking_amount;
                }
                else {
                    require(false,"Place Higher Bid!!");
                }
            }
        }
    }




    function withdraw () public {

        require(block.timestamp >= END_Time,"7 days Period not over yet!!");
        require(_user_staking_balance[msg.sender] > 0);

        uint256 total_amount = _user_staking_balance[msg.sender]; 

        total_amount = total_amount * 10 ** 18;

        uint256 _2per = ( total_amount * 2 ) / 100;
        uint256 _98per = ( total_amount * 98 ) / 100;

        Anac.transfer(msg.sender,_98per);
        Anac.transfer(Owner,_2per);

        _user_staking_balance[msg.sender] = 0;
    }


    function EmergencyWithdraw() public onlyOwner {
        Anac.transfer(msg.sender,Anac.balanceOf(address(this)));
    }

    function check_balance() public onlyOwner view returns (uint)  {
        return Anac.balanceOf(address(this));
    }

    function check_Allowance() public view returns (uint256) {
        return Anac.allowance(msg.sender,address(this));
    }

    function total_biding() public view returns (uint) {
        return bid_data.length;
    }

    function check_auction_index(uint _num) public view returns (uint index) {
        for (uint i = 0 ; i < bid_data.length ; i++)
        {
            if(bid_data[i].Auction_no == _num){
                return i;
            }
        }
    }

}