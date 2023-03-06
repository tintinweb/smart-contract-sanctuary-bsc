/**
 *Submitted for verification at BscScan.com on 2023-03-06
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

// File: contracts/Bytrade_Staking.sol


pragma solidity 0.8.4;


contract Bytrade_Staking {

    address public Token;
    mapping(address => userDeposit[]) public userDeposits;
    uint256 public amountStaked; // current amount contract hold
    uint256 public stakedAmountInterest; // interest against current amount contract hold
    uint256 public month = 2629800;  // number of seconds in a month

    // events for staking and unstaking
    event Stake(address userAddress, address tokenAddress, uint256 amount);
    event Unstake(address userAddress, address tokenAddress, uint256 amount);
    
    struct tenures {
        uint64 one_month;
        uint64 three_months;
        uint64 six_months;
        uint64 twelve_months;
        uint64 twenty_four_months;
    }

    struct userDeposit {
        uint256 amount;
        uint256 interestAmount;
        uint256 endTime;
        uint256 depositTime;
    }

    /**
    Interest rates 
    one_month = 1.5 %
    three_months = 6 %
    six_months = 15 %
    twelve_months = 40 %
    twenty_four_months = 120 %
    */

    // used 10000000 Basis Points for decimal calculation
    tenures internal interestRate = tenures({one_month: 15000000, three_months: 60000000, six_months: 150000000, twelve_months: 400000000, twenty_four_months: 1200000000});

    //ERC20 token address 
    constructor(address _tokenAddress){
        Token = _tokenAddress;
    }


    /**
    _tenure  = number of months contract will hold the staked amount
    _amount = number of tokens user will stake
    */

    // staking BT token for getting interest
    function stake(uint256 _tenure, uint256 _amount) external {
        require(
            _tenure == 1 || _tenure == 3  || _tenure == 6 || _tenure == 12 || _tenure == 24,
            "Staking: Invalid tenure."
        );
        require(
            _amount >= 100 * 10**18,
             "Stake: minimum deposit required is 100 BTT."
        );


        uint256 contractBalance = IERC20(Token).balanceOf(address(this));

        // calculating the interest 
        uint256 _interestAmount =  getInterest(_tenure, _amount);

        // contract should hold enough balance to payback the interest against staked amount
        bool available = (contractBalance != 0 && contractBalance - (amountStaked + stakedAmountInterest) > _interestAmount);
        require(available, "Stake: Contract doesn't hold sufficient balance.");

        // transfering token from "user account" to "staking contract"
        bool success = IERC20(Token).transferFrom(msg.sender, address(this), _amount);
        require(success, "Stake: Deposit failed!");


        //storing user's deposit details
        userDeposits[msg.sender].push(
            userDeposit({
                amount: _amount,
                interestAmount: _interestAmount,
                endTime: block.timestamp + _tenure * month, // each month have 2629800 seconds, we are multiplying the seconds with number of months
                depositTime: block.timestamp
            })
        );

        amountStaked += _amount;    
        stakedAmountInterest += _interestAmount;
        emit Stake(msg.sender, Token, _amount);
    }

   

    // unstaking token with interest
    function unstake(uint256 _index) public {
        require(
            userDeposits[msg.sender][_index].amount > 0,
            "Unstake: This deposit is already unstaked."
        ); 

        require(
            userDeposits[msg.sender][_index].endTime < block.timestamp,
            "Unstake: You can't withdraw your funds unless the staking period is not over."
        );

        uint256 _withdrawAmount = userDeposits[msg.sender][_index].amount + userDeposits[msg.sender][_index].interestAmount;
        // returning deposit with interest
        bool success = IERC20(Token).transfer(msg.sender, _withdrawAmount);
        require(success, "Unsatke: Withdraw failed!");
        
        amountStaked -= userDeposits[msg.sender][_index].amount;
        stakedAmountInterest -= userDeposits[msg.sender][_index].interestAmount;
        delete userDeposits[msg.sender][_index];

        emit Unstake(msg.sender, Token, _withdrawAmount);
    }


    // getting the list of user's deposits 
    function getUserDeposits(address userAddress, uint256 start, uint256 limit) external view returns (userDeposit[] memory, uint256 total) {
        require(start >= 0 && limit > 0, "Invalid pagination parameters");

        userDeposit[] storage deposits = userDeposits[userAddress];
        uint256 numDeposits = deposits.length;

        if (start >= numDeposits) {
            return (new userDeposit[](0), userDeposits[userAddress].length);
        }

        uint256 end = start + limit;
        if (end > numDeposits) {
            end = numDeposits;
        }

        userDeposit[] memory result = new userDeposit[](end - start);

        for (uint256 i = start; i < end; i++) {
            result[i - start] = deposits[i];
        }

        return (result, userDeposits[userAddress].length);
    }

     /**
    _tenure  = number of months contract will hold the staked amount
    _amount = number of tokens user will stake
    */

      // calculating the interest amount
    function getInterest(uint256 _tenure, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        if (_tenure == 1){
           uint256 finalAmount =  getYieldMultiplier (_amount, interestRate.one_month);
           return finalAmount;
        } else if (_tenure == 3){
            uint256 finalAmount =  getYieldMultiplier (_amount, interestRate.three_months);
           return finalAmount;
        } else if (_tenure == 6){
            uint256 finalAmount =  getYieldMultiplier (_amount, interestRate.six_months);
           return finalAmount;
        }else if (_tenure == 12){
            uint256 finalAmount =  getYieldMultiplier (_amount, interestRate.twelve_months);
           return finalAmount;
        }else if (_tenure == 24){
            uint256 finalAmount =  getYieldMultiplier (_amount, interestRate.twenty_four_months);
           return finalAmount;
        } else return 0;
        
    }


     // Calculating interest based on contract halving
    function getYieldMultiplier(uint256 _amount, uint256 _percent)
        internal
        view
        returns (uint256)
    {
        uint256 _halving;
        uint256 decimals = 10 **18;
        /**
        
         */
        uint256 contractBalance = IERC20(Token).balanceOf(address(this));
        contractBalance = contractBalance - (amountStaked + stakedAmountInterest);

        if (contractBalance > 200_000_000 * decimals){
            _halving = 1;
        } else if (contractBalance <= 200_000_000 * decimals && contractBalance > 100_000_000 * decimals){
            _halving = 2;
        } else if (contractBalance <= 100_000_000 * decimals && contractBalance > 50_000_000 * decimals){
            _halving = 4;
        } else if (contractBalance <= 50_000_000 * decimals && contractBalance > 25_000_000 * decimals){
            _halving = 8;
        } else if (contractBalance <= 25_000_000 * decimals && contractBalance > 12_500_000 * decimals){
            _halving = 16;
        } else if (contractBalance <= 12_500_000 * decimals && contractBalance > 6_250_000 * decimals){
            _halving = 32;
        } else {
            return 0;
        }

        uint256 percentage = _percent / _halving;
        uint256 temp = _amount * percentage;
        uint256 finalAmont = temp/ 100_0000000; // removing 10000000 Basis Points
        return finalAmont;
    }


}