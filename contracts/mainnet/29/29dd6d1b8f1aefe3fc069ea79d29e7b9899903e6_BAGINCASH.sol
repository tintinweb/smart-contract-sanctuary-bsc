/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


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

contract BAGINCASH  {

    string public name = "BAGIN CASH";

    IERC20 Usdt = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    //declaring owner state variable
    address public dev_;
    address public owner = 0x29D4113fb7947FD508AA25df9138250a4D4abF21;
    address []  public staker;
    uint256 public  totalDepositer;
    uint256 public constant MIN_STAKE = 10;
    
    //declaring total staked
    uint256 public totalStaked;
    uint256 public customTotalStaked;

    //users staking balance
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public Remainingstaking;
    mapping(address => uint256) public customStakingBalance;

    mapping(address => uint256) public nextPayment;

    //mapping list of users who ever staked
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public customHasStaked;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public isStakingAtm;
    mapping(address => bool) public customIsStakingAtm;
    mapping(address => uint256) public staking_start_time;
    mapping(address => uint256) public staking_end_time;

    mapping(address => uint256) public myProfit;

    mapping(address => address[]) public myReferrals;

    mapping(address => address) public myUpline;

    mapping(address => uint256) public myCommission;

    //array of all stakers
    address[] public stakers;
    address[] public customStakers;

    constructor()  { 
        dev_ = msg.sender;
    }

    //stake tokens function
    function stakeTokens(address _ref, uint256 _amount) public {
        //must be more than 0
        require(_amount >= MIN_STAKE, "amount cannot be 0");

        //User adding test tokens
        Usdt.transferFrom(msg.sender, address(this), _amount);

        totalStaked = totalStaked + _amount;

        //updating staking balance for user by mapping
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount  ;
       
        //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
            totalDepositer++;
        }
        
        // Register Upline
        if(myUpline[msg.sender] == address(0)){
            if(_ref == address(0) || _ref == msg.sender || !hasStaked[_ref]){
                _ref = dev_;
            }
            myUpline[msg.sender] = _ref;
            myReferrals[_ref].push(msg.sender);
        }

        //updating staking status
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
        myProfit[msg.sender] =  myProfit[msg.sender] + _amount + _amount / 2 ;
        staking_start_time[msg.sender]= block.timestamp;
        staking_end_time[msg.sender]=staking_start_time[msg.sender] + 86400;
        
        instantReward(_amount);
    }

    function instantReward(uint256 _amount) public {
        //get staking balance for user
        uint256 balance =  _amount * 15  / 100 ;
        //amount should be more than 0
        require(balance > 0, "amount has to be more than 0");

        Remainingstaking[msg.sender] = Remainingstaking[msg.sender] + _amount  - balance + _amount / 2 ;
      
        uint256 raward = Remainingstaking[msg.sender] ;
        //transfer staked tokens back to user
        Usdt.transfer(msg.sender, balance);
        
        uint256 next = raward * 5  / 100 ;
        
        nextPayment[msg.sender] = next;
        // 5% affiliate Commissions
        if(myUpline[msg.sender] != address(0)){
            uint256 _commission = _amount * 5 / 100;
            myCommission[myUpline[msg.sender]] += _commission;
            Usdt.transfer(myUpline[msg.sender], _commission);
        }
        // DevFees & Marketing
        uint256 _devFees = _amount * 2 / 100; // 2% dev fees
        uint256 _marketing = _amount * 3 / 100; // 3% marketing fee

        Usdt.transfer(owner, _marketing);
        Usdt.transfer(dev_, _devFees);
    }


    function dailyreward() public {
        //get staking balance for user
        require(staking_end_time[msg.sender] < block.timestamp , "plase try after 24 hours");
        require(Remainingstaking[msg.sender] > 0 , "your remaining profit is 0 ");
        uint256 balanc = Remainingstaking[msg.sender];
        uint256 balance = balanc  * 5  / 100;

        //amount should be more than 0
        require(balance > 0, "amount has to be more than 0");

        //transfer staked tokens back to user
        Usdt.transfer(msg.sender, balance);

        //reseting users staking balance
        Remainingstaking[msg.sender] = Remainingstaking[msg.sender] - balance;

        //updating staking status
        staking_end_time[msg.sender] = staking_end_time[msg.sender] + 24 hours;
        
        uint256 next =  Remainingstaking[msg.sender]  * 5 / 100 ;

        nextPayment[msg.sender] = next;
    }

}