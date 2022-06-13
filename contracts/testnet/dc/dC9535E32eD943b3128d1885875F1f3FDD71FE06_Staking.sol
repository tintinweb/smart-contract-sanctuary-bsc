// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./Approve.sol";
import "./Context.sol";
import "./IBEP20.sol";
import "./IStaking.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./ILolliMoon.sol";
 
/**
 * @dev Read Docs/Staking.md
 */
contract Staking is Context, IBEP20, IStaking, Approve {

    using SafeMath for uint256;
    using Address for address;

    struct Funds {
        uint256 tAmount;
        uint256 rAmount;
        uint256 timestamp;
    }

    struct Entry {
        uint256 invest;
        uint256 rewards;
        uint256 remainingTime;
    }


    // Token name and symbol
    string private constant TOKEN_NAME = "LM*STAKING*";
    string private constant TOKEN_SYMBOL = "LM*STAKING*";

    uint256 private constant T_TOTAL = 10000 * 10**6 * 10**9;
    uint256 private constant MAX = ~uint256(0);
    uint256 public _rTotal = (MAX - (MAX % T_TOTAL));

    uint256 private _Timelock = 180 days;

    bool private ContractsLinked;

    // Balances
    uint256 _rOwnedContract;
    uint256 _tOwnedContract;
    mapping(address => Funds[]) _tOwnedFunds;

    ILolliMoon public LolliMoonToken;

    // Events

    /**
     * @dev Emitted when an account staked stokens
     */
    event Staked(address, uint256);

    /**
     * @dev Emitted when an account unstaked stokens
     */
    event Unstaked(address, uint256);

     /**
     * @dev Emitted when an account pays out rewards
     */
    event RewardsPayout(address, uint256);

     /**
     * @dev Emitted when the minimum staking duration has been modified
     */
    event MinimumStakingDurationChanged(uint256 newTimeLock);


    /**
     * @dev 
     */
    modifier onlyMoonityContract() {
        require(_msgSender() == address(LolliMoonToken), 'No permission');
        _;
    }
    
     /**
     * @dev Initializes the contract
     */
    constructor() {
        _rOwnedContract = _rTotal;
        _tOwnedContract = T_TOTAL;

        emit Transfer(address(0), address(0), T_TOTAL);
    }

     /**
     * @dev IBEP20 interface: Returns the token name
     */
    function name() public pure override returns (string memory) {
        return TOKEN_NAME;
    }
      
    /**
     * @dev IBEP20 interface: Returns the smart-contract owner
     */
    function getOwner() external override view returns (address) {
        return owner();
    }
    
    /**
     * @dev IBEP20 interface: Returns the token symbol
     */
    function symbol() public pure override returns (string memory) {
        return TOKEN_SYMBOL;
    }

    /**
     * @dev IBEP20 interface: Returns the token decimals
     */
    function decimals() public pure override returns (uint8) {
        return 9;
    }

    /**
     * @dev IBEP20 interface: Returns the amount of tokens in existence
     */
    function totalSupply() public pure override returns (uint256) {
        return T_TOTAL;
    }

    /**
     * @dev IBEP20 interface: Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) public view override(IBEP20, IStaking) returns (uint256) {
        if (account == address(0)) return _tOwnedContract;
        if(_tOwnedFunds[account].length == 0) return 0;

        uint256 tAmountIncludingReward;

        for (uint256 position = 0; position <  _tOwnedFunds[account].length; position++) {
           uint256 rAmount = _tOwnedFunds[account][position].rAmount;
           uint256 tAmount = tokenFromReflection(rAmount);
           tAmountIncludingReward = tAmountIncludingReward.add(tAmount); // Tokens including rewards from reflection 
        }

        return tAmountIncludingReward;
    }

    function transfer(address /*receiver*/, uint256 /*numTokens*/) public override pure returns (bool) {
        return false;
    }

    function approve(address /*delegate*/, uint256 /*numTokens*/) public override pure returns (bool) {
        return false;
    }

    function allowance(address /*owner*/, address /*delegate*/) public override pure returns (uint) {
        return 0;
    }

    function transferFrom(address /*owner*/, address /*buyer*/, uint256 /*numTokens*/) public override pure returns (bool) {
        return false;
    }

    
    function InStaking() public view returns (uint256) {
        return T_TOTAL.sub(_tOwnedContract);
    }

     /**
     * @dev Returns all staked tokens and timestamps of a given account. Max array size is 15 elements
     */
     function ListStakedTokens(address account) public view returns(Entry[] memory) {

        // Return empty array if account has no investments in staking
        if(_tOwnedFunds[account].length == 0) 
        {
            Entry[] memory NoFunds = new Entry[](0); // empty array
            return NoFunds;
        }
        
        // create a new array with length of account's investments
        uint256 fundsEntries = _tOwnedFunds[account].length;
        Entry[] memory CurrentInvest = new Entry[](fundsEntries);

        for(uint256 position; position < fundsEntries; position++)
        {
            // Initial investment
            uint256 initialInvest = _tOwnedFunds[account][position].tAmount;
            CurrentInvest[position].invest = initialInvest;

            // Payable rewards
            uint256 rewards = 0;
            uint256 tokenIncludingRewards = tokenFromReflection(_tOwnedFunds[account][position].rAmount);
            if(tokenIncludingRewards > initialInvest) 
            {
                rewards = tokenIncludingRewards.sub(initialInvest);
                CurrentInvest[position].rewards = rewards;
            }

            // Remaining time lock
            uint256 remainingTime = 0;
            uint256 lockedUntil = _tOwnedFunds[account][position].timestamp.add(_Timelock);

            if(block.timestamp < lockedUntil)
            {
                remainingTime = lockedUntil.sub(block.timestamp);
            }

            CurrentInvest[position].remainingTime = remainingTime;

        }
         
        return CurrentInvest;
     }
   
     /**
     * @dev Links this contract with the token contract
     * Can only be used by the owner of this contract
     * TRUSTED
     */
    function linkMoonityContract(address ContractAddress) public onlyOwner {
        require(!ContractsLinked, "Already linked");
        LolliMoonToken = ILolliMoon(ContractAddress);  // TRUSTED CONTRACT
        ContractsLinked = true;
    }

     /**
     * @dev 
     * Can only be used by the owner of this contract
     */
    function ChangeMinimumStakingDuration(uint256 nDays) public onlyOwnerWithApproval {
        require(nDays <= 180, "can only be up to 180 days"); 
        _Timelock = nDays * 1 days;
        emit MinimumStakingDurationChanged(_Timelock);
    }

     /**
     * @dev Returns the reflection value from a given token amount
     */
    function reflectionFromToken(uint256 tAmount) public view returns(uint256) {
        require(tAmount <= T_TOTAL, "Must be less than total amount");
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        return rAmount;
    }

    /**
     * @dev Returns the token amount from a given reflection value
     */
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Must be less than total amount");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }



     /**
     * @dev Updates reflection
     * Removes fees from the total reflection amount
     * Adds fees to the total fee amount
     */
     // NOTE Interface IStaking function
    function reflectRewards(uint256 tAmount) public override onlyMoonityContract() returns(bool) {   
        if(tAmount == 0 || _tOwnedContract < tAmount) return true;

        uint256 currentRate = _getRate();
        uint256 rFee = tAmount.mul(currentRate);
  
        _tOwnedContract = _tOwnedContract.sub(tAmount);
        _rOwnedContract = _rOwnedContract.sub(rFee);

        _rTotal = _rTotal.sub(rFee);

        return true;        
    }


      /**
     * @dev Return the current rate
     * The rate is the quotient of the reflection value of the token supply and the token supply amount
     */
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    /**
     * @dev 
     */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = T_TOTAL;      
     
        if (_rOwnedContract > rSupply || _tOwnedContract > tSupply) return (_rTotal, T_TOTAL);

        rSupply = rSupply.sub(_rOwnedContract);
        tSupply = tSupply.sub(_tOwnedContract);
        
        if (rSupply < _rTotal.div(T_TOTAL)) return (_rTotal, T_TOTAL);
        return (rSupply, tSupply);
    }

   


     /**
     * TRUSTED FUNCTION
     * @dev 
     */
        function StakeTokens(uint256 tAmount) public {
        require(ContractsLinked, "Contracts not linked");
        require(tAmount > 0, "Must be more than zero");
        address sender = _msgSender();
        require(_tOwnedFunds[sender].length < 15, "Maximum staking slots of 15 reached");
        require(LolliMoonToken.balanceOf(sender) >= tAmount, "Insufficient balance");
        bool transferred = LolliMoonToken.stakeTokens(sender, tAmount); // TRUSTED EXTERNAL CALL (move Tokens from account to staking pool)
        require(transferred, "Staking failed");  

        uint256 rTransferAmount = tAmount.mul(_getRate());

        _tOwnedContract = _tOwnedContract.sub(tAmount);
        _rOwnedContract = _rOwnedContract.sub(rTransferAmount);
               
        _tOwnedFunds[sender].push(Funds(tAmount, rTransferAmount, block.timestamp)); // stake amount of tokens with current timestamp
        emit Staked(sender, tAmount);
    }




     /**
    * TRUSTED FUNCTION
     * @dev 
     */
    function PayoutStakingReward(uint256 position) public {
        require(ContractsLinked, "Contracts not linked");
        require(position > 0, "No Position given");
        address sender = _msgSender();
        uint256 arrayCount = _tOwnedFunds[sender].length;
        require(arrayCount >= position, "Position does not exist");
        // Amount of tokens staked. Stored in array element at "position -1
        uint256 tAmount = _tOwnedFunds[sender][position - 1].tAmount;
        uint256 rAmount = _tOwnedFunds[sender][position - 1].rAmount;
        uint256 tAmountIncludingReward = tokenFromReflection(rAmount); // Tokens including rewards from reflection
        require(tAmountIncludingReward > tAmount, "No rewards yet");

        uint256 tPayoutTokens = tAmountIncludingReward.sub(tAmount);

        // 
        _rOwnedContract = _rOwnedContract.add(reflectionFromToken(tPayoutTokens));
        _tOwnedContract = _tOwnedContract.add(tPayoutTokens);

        uint256 rAmountNew = reflectionFromToken(tAmount); // Reflection based of current rate. This will zero out rewards
        _tOwnedFunds[sender][position - 1].rAmount = rAmountNew;

        bool transferred = LolliMoonToken.unstakeTokens(sender, tPayoutTokens); // TRUSTED EXTERNAL CALL (transfer staking rewards to account)
        require(transferred, "Rewards transfer failed");  
        
        emit RewardsPayout(sender, tPayoutTokens);
    }

    /**
    * TRUSTED FUNCTION
     * @dev 
     */
    
      function UnstakeTokens(uint256 position) public {
        require(ContractsLinked, "Contracts not linked");
        require(position > 0, "No Position given");
        address sender = _msgSender();
        uint256 arrayCount = _tOwnedFunds[sender].length;
        require(arrayCount >= position, "Position does not exist");
        require(block.timestamp >= _tOwnedFunds[sender][position - 1].timestamp.add(_Timelock), "Time lock still active");

        // Amount of tokens staked. Stored in array element at "position -1"
        uint256 rAmount = _tOwnedFunds[sender][position - 1].rAmount;
        uint256 tAmountIncludingReward = tokenFromReflection(rAmount); // Tokens including rewards from reflection

        // check if there's more than 1 element in array
        // check if position is not last element
        if(arrayCount > 1 && position != arrayCount){
           _tOwnedFunds[sender][position - 1] = _tOwnedFunds[sender][arrayCount - 1]; // Copy last element to position index
        } 

        _tOwnedFunds[sender].pop(); // delete last element

        _tOwnedContract = _tOwnedContract.add(tAmountIncludingReward);
        _rOwnedContract = _rOwnedContract.add(rAmount);  

        bool transferred = LolliMoonToken.unstakeTokens(sender, tAmountIncludingReward); // TRUSTED EXTERNAL CALL (move Tokens from staking pool back to account)
        require(transferred, "Unstaking failed");  

        emit Unstaked(sender, tAmountIncludingReward);
    }
     
}