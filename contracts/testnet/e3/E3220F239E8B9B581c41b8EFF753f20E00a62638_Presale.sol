/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: Presale.sol


pragma solidity ^0.8.0;


contract Presale{
    address public immutable admin;
    IERC20Upgradeable public token;

    event AdminWithdrawal(uint bnbAmount, uint tokenAmount);

    //Presale
    uint256 public bnbunit;
    uint256 public hardCap;
    uint256 public raisedBNB;

    mapping(address => uint) public spentBNB;
    mapping(address => uint) public boughtTokens;

    bool public presaleStart;
    bool public presaleEnd;

    event presaleStarted(uint starttime, uint _hardcap, uint tokenAmount);
    event Bought(address indexed buyer, uint tokenAmouunt, uint bnbAmount);
    event Withdraw(address indexed withdrawer, uint tokenAmount, uint bnbAmount);
    event PresaleEnded(uint endTime, uint _raisedBNB, uint tokenLeft);

    //Vesting
     
    struct VestingPriod{
        uint percent;
        uint startTime;
        uint vestingCount;
       uint MaxClaim;   
    }
    
    uint public maxPercent;
    bool public Vesting;
    uint public VestingCount;

    VestingPriod _vestingPeriod;

    mapping(uint => VestingPriod ) public PeriodtoPercent;
    mapping(address => uint) private TotalBalance;
    mapping(address => uint) private claimCount;
    mapping(address => uint) private claimedAmount;
    mapping(address => uint) private claimmable;

    event VestingSet(uint startTime, uint Percent, uint TotalPercent);
    event Claimed(address indexed claimer, uint Precent, uint tokenAmount);




    constructor(uint buyUnit, uint hardcap) {
        admin = payable(msg.sender);
        token = IERC20Upgradeable(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
        hardCap = hardcap;
        bnbunit = buyUnit;       
    } 

    //Presale
    function startPresale() external {
        require(msg.sender == admin);
        uint tokenBalance = hardCap * bnbunit;

        require(tokenBalance <= token.balanceOf(address(this)));

        presaleStart = true; 

       emit  presaleStarted(block.timestamp, hardCap, token.balanceOf(address(this)));
    }

    receive() external payable{
        buy();
    }

    function buy() public payable{
        require(presaleStart, "PO"); //Presale Off
        require(raisedBNB + msg.value <= hardCap, "TM");//Too much, gone over hard cap

        uint256 tokenAmount = msg.value * bnbunit;

        spentBNB[msg.sender]+=msg.value;
        boughtTokens[msg.sender]+=tokenAmount;
        TotalBalance[msg.sender] +=tokenAmount;
        raisedBNB+=msg.value;

        emit Bought(msg.sender, msg.value, tokenAmount);


    }

    function emergencyWithdrawal(uint amount) external{
        require(presaleStart, "PO");
        require(spentBNB[msg.sender] >= amount);

        uint tokenDebit = amount * bnbunit;

        boughtTokens[msg.sender] -= tokenDebit;
        spentBNB[msg.sender] -= amount;

       (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Fail");

        emit Withdraw(msg.sender, amount, tokenDebit);

    }

    function endPresale() external{
        require(msg.sender == admin, "NA");//Not admin
        require(presaleStart, "PO");//Presale Off

        presaleStart = false;
        presaleEnd = true;

        emit PresaleEnded(block.timestamp, raisedBNB, token.balanceOf(address(this)));
    }
    
    //Vesting 
 

    function setVesting(uint StartTime, uint Percentage) external {
        require(presaleEnd,"PA"); //Presale Active
      
           VestingCount++;
           maxPercent += Percentage;
        if(maxPercent > 100){
            maxPercent -=Percentage;
            revert ();
        }
        else {
            require(StartTime > PeriodtoPercent[VestingCount-1].startTime);
        PeriodtoPercent[VestingCount] = VestingPriod({
            percent : Percentage,
            startTime : StartTime,
            vestingCount : VestingCount,
              MaxClaim : maxPercent
        });

        }

        emit VestingSet(StartTime, Percentage, maxPercent);
    }

  
    function claim() external {
        require(presaleEnd, "PA");
        require(claimCount[msg.sender] <= VestingCount,"CC");//Claiming Complete
        

        for(uint i = claimCount[msg.sender]; i<= VestingCount; i++){
            if(PeriodtoPercent[i].startTime <= block.timestamp){
                claimmable[msg.sender] +=PeriodtoPercent[i].percent;
                claimCount[msg.sender] ++;
            }
            else 
            break;
        }
        
    
        require(claimmable[msg.sender] <= 100);
        

        uint _amount = (claimmable[msg.sender] *100) * TotalBalance[msg.sender]/10000;

        boughtTokens[msg.sender] -= _amount;
        claimedAmount[msg.sender] += claimmable[msg.sender]; 

        uint _Percent = claimmable[msg.sender];
  
        delete claimmable[msg.sender];

        token.transfer(msg.sender, _amount);

        emit Claimed(msg.sender, _Percent, _amount);

    }
    //Admin Withdrawal

    function WithdrawRemainingFunds() external{
        require(msg.sender==admin, "NA");
        uint tokenBalance = token.balanceOf(address(this));

        if(raisedBNB < hardCap || tokenBalance > 0){
            token.transfer(admin, token.balanceOf(address(this)));
        }

         (bool sent,) = admin.call{value: raisedBNB}("");
        require(sent, "Fail");

        emit AdminWithdrawal(raisedBNB, tokenBalance);
    }

    
}