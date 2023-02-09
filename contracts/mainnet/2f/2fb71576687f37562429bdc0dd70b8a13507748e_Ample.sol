/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {
        _transferOwnership(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;

    uint private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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
    function add(uint a, uint b) internal pure returns (uint) {
        return a + b;
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
    function sub(uint a, uint b) internal pure returns (uint) {
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint a, uint b) internal pure returns (uint) {
        return a / b;
    }
}


contract Ample is Ownable, ReentrancyGuard{
    using SafeMath for uint;

    uint constant DEVELOPER_FEE = 200; // 200 : 2 %. 10000 : 100 %
    uint constant REFFER_REVARD_1_LVL = 500; // 500 : 5%. 10000 : 100%
    uint constant REFFER_REVARD_2_LVL = 200; // 200 : 2%. 10000 : 100%
    uint constant REWARD_PERIOD = 1 days;
    uint constant WITHDRAW_PERIOD = 60 * 60 * 24 * 30;	// 30 days
    uint APR =  760; // 760 : 7,6 %. 10000 : 100 %
    uint constant PERCENT_RATE = 10000;
    address devWallet;
    uint public _currentDepositID = 0;

    uint totalInvestors = 0;
    uint totalReward = 0;
    uint totalInvested = 0;

    struct DepositStruct{
        address investor;
        uint depositAmount;
        uint depositAt; 
        uint claimedAmount; 
        bool state; 
    }

    struct InvestorStruct{
        address investor;
        address referrer;
        uint totalLocked;
        uint startTime;
        uint lastCalculationDate;
        uint claimableAmount;
        uint claimedAmount;
        uint referAmount;
    }

    event Deposit(
        uint id,
        address investor
    );

    // mapping from depost Id to DepositStruct
    mapping(uint => DepositStruct) public depositState;

    // mapping form investor to deposit IDs
    mapping(address => uint[]) public ownedDeposits;
    // mapping from address to investor
    mapping(address => InvestorStruct) public investors;
    
    constructor() {
        devWallet = 0x6DD248A8D7F02D4F166651027f069094AB22F076;
    }

    function resetContract(address _devWallet) public onlyOwner {
        require(_devWallet != address(0),"Please provide a valid address");
        devWallet = _devWallet;
    }

    function _getNextDepositID() private view returns (uint) {
        return _currentDepositID + 1;
    }

    function _incrementDepositID() private {
        _currentDepositID++;
    }

    function deposit(address _referrer) public payable {
        uint _amount = msg.value;
        require(_amount > 0, "you can deposit more than 0");

        if(_referrer == msg.sender){
            _referrer = address(0);
        }

        uint _id = _getNextDepositID();
        _incrementDepositID();

        uint depositFee = (_amount * DEVELOPER_FEE).div(PERCENT_RATE);
        
        // transfer fee to dev wallet
        //(bool success, ) = devWallet.call{value : depositFee}("");
        //require(success, "Transfer failed.");
        payable(devWallet).transfer(depositFee);


        uint _depositAmount = _amount - depositFee;

        depositState[_id].investor = msg.sender;
        depositState[_id].depositAmount = _depositAmount;
        depositState[_id].depositAt = block.timestamp;
        depositState[_id].state = true;

        if(investors[msg.sender].investor == address(0)){
            totalInvestors = totalInvestors.add(1);
            investors[msg.sender].investor = msg.sender;
            investors[msg.sender].startTime = block.timestamp;
            investors[msg.sender].lastCalculationDate = block.timestamp;
        }

        if(address(0) != _referrer && investors[msg.sender].referrer == address(0)) {
            investors[msg.sender].referrer = _referrer;
        }

        if(investors[msg.sender].referrer != address(0)){
            uint referrerAmountlvl1 = (_amount * REFFER_REVARD_1_LVL).div(PERCENT_RATE);
            uint referrerAmountlvl2 = (_amount * REFFER_REVARD_2_LVL).div(PERCENT_RATE);
            

            investors[investors[msg.sender].referrer].referAmount = investors[investors[msg.sender].referrer].referAmount.add(referrerAmountlvl1);

            payable(investors[msg.sender].referrer).transfer(referrerAmountlvl1);

            if(investors[_referrer].referrer != address(0)) {
                investors[investors[_referrer].referrer].referAmount = investors[investors[_referrer].referrer].referAmount.add(referrerAmountlvl2);

                payable(investors[_referrer].referrer).transfer(referrerAmountlvl2);
            }

        }

        uint lastRoiTime = block.timestamp - investors[msg.sender].lastCalculationDate;
        uint allClaimableAmount = (lastRoiTime *
            investors[msg.sender].totalLocked *
            APR).div(PERCENT_RATE * REWARD_PERIOD);

        investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.add(allClaimableAmount);
        investors[msg.sender].totalLocked = investors[msg.sender].totalLocked.add(_depositAmount);
        investors[msg.sender].lastCalculationDate = block.timestamp;

        totalInvested = totalInvested.add(_amount);

        ownedDeposits[msg.sender].push(_id);
        emit Deposit(_id, msg.sender);
    }

    // claim all rewards of user
    function claimAllReward() public nonReentrant {
        require(ownedDeposits[msg.sender].length > 0, "you can deposit once at least");
        
        uint lastRoiTime = block.timestamp - investors[msg.sender].lastCalculationDate;
        uint allClaimableAmount = (lastRoiTime *
            investors[msg.sender].totalLocked *
            APR).div(PERCENT_RATE * REWARD_PERIOD);
         investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.add(allClaimableAmount);

        uint amountToSend = investors[msg.sender].claimableAmount;
        
        if(getBalance() < amountToSend){
            amountToSend = getBalance();
        }
        
        investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.sub(amountToSend);
        investors[msg.sender].claimedAmount = investors[msg.sender].claimedAmount.add(amountToSend);
        investors[msg.sender].lastCalculationDate = block.timestamp;
        totalReward = totalReward.add(amountToSend);

        payable(msg.sender).transfer(amountToSend);
    }

    function getAmount() public payable onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
    
    // withdraw capital by deposit id
    function withdrawCapital(uint id) public nonReentrant {
        require(
            depositState[id].investor == msg.sender,
            "only investor of this id can claim reward"
        );
        require(
            block.timestamp - depositState[id].depositAt > WITHDRAW_PERIOD,
            "withdraw lock time is not finished yet"
        );
        require(depositState[id].state, "you already withdrawed capital");
        
        uint claimableReward = getAllClaimableReward(msg.sender);

        require(
            depositState[id].depositAmount + claimableReward <= getBalance(),
            "no enough usdt in pool"
        );

       
        investors[msg.sender].claimableAmount = 0;
        investors[msg.sender].claimedAmount = investors[msg.sender].claimedAmount.add(claimableReward);
        investors[msg.sender].lastCalculationDate = block.timestamp;
        investors[msg.sender].totalLocked = investors[msg.sender].totalLocked.sub(depositState[id].depositAmount);

        uint amountToSend = depositState[id].depositAmount + claimableReward;

        totalReward = totalReward.add(claimableReward);
        depositState[id].state = false;

        payable(msg.sender).transfer(amountToSend);

    }

    function getOwnedDeposits(address investor) public view returns (uint[] memory) {
        return ownedDeposits[investor];
    }

    function getAllClaimableReward(address _investor) public view returns (uint) {
        uint lastRoiTime = block.timestamp - investors[_investor].lastCalculationDate;
        uint _apr = getApr();
        uint allClaimableAmount = (lastRoiTime *
            investors[_investor].totalLocked *
            _apr).div(PERCENT_RATE * REWARD_PERIOD);

         return investors[_investor].claimableAmount.add(allClaimableAmount);
    }

    function getApr() public view returns (uint) {
        return APR;
    }

    function getBalance() public view returns(uint) {
       
        return address(this).balance;
    }

    function getTotalRewards() public view returns (uint) {
        return totalReward;
    }

    function getTotalInvests() public view returns (uint) {
        return totalInvested;
    }


    receive() external payable{
        deposit(msg.sender);
    }
}