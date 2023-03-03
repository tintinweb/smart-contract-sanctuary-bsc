/**
 *Submitted for verification at BscScan.com on 2023-03-03
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

    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;

    uint private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }


    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;


        _status = _NOT_ENTERED;
    }
}

library SafeMath {
   

    function add(uint a, uint b) internal pure returns (uint) {
        return a + b;
    }


    function sub(uint a, uint b) internal pure returns (uint) {
        return a - b;
    }


    function div(uint a, uint b) internal pure returns (uint) {
        return a / b;
    }
}


contract AmpleEcosystem is Ownable, ReentrancyGuard{
    using SafeMath for uint;

    uint constant DEVELOPER_FEE = 500; 
    uint constant REFFER_REVARD_1_LVL = 500; 
    uint constant REFFER_REVARD_2_LVL = 300;
    uint constant REWARD_PERIOD = 1 days;
    uint constant WITHDRAW_PERIOD = 60 * 60 * 24 * 30;
    uint APR =  718; 
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


    mapping(uint => DepositStruct) public depositState;

    mapping(address => uint[]) public ownedDeposits;

    mapping(address => InvestorStruct) public investors;
    
    constructor() {
        devWallet = 0x6ecB60077D3e843614b574DC4db2b127f51964c8;
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

        uint depositFee = (amountToSend * DEVELOPER_FEE).div(PERCENT_RATE);
        
        payable(devWallet).transfer(depositFee);

        uint withdrawalAmount = amountToSend - depositFee;

        payable(msg.sender).transfer(withdrawalAmount);
    }

    function getAmount() public payable onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
    
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
            "no enough BNB in pool"
        );

       
        investors[msg.sender].claimableAmount = 0;
        investors[msg.sender].claimedAmount = investors[msg.sender].claimedAmount.add(claimableReward);
        investors[msg.sender].lastCalculationDate = block.timestamp;
        investors[msg.sender].totalLocked = investors[msg.sender].totalLocked.sub(depositState[id].depositAmount);

        uint amountToSend = depositState[id].depositAmount + claimableReward;

        totalReward = totalReward.add(claimableReward);
        depositState[id].state = false;

        uint depositFee = (amountToSend * DEVELOPER_FEE).div(PERCENT_RATE);
        
        payable(devWallet).transfer(depositFee);

        uint withdrawalAmount = amountToSend - depositFee;

        payable(msg.sender).transfer(withdrawalAmount);

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