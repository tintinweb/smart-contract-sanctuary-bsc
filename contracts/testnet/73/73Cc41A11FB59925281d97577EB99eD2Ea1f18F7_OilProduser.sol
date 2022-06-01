/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

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


// File contracts/OilPump.sol

pragma solidity ^0.8.0;

contract OilProduser is ReentrancyGuard{
    // settings
    uint256 public developersPercent;
    uint256 public marketingPercent;
    uint256 public lotteryPercent;
    uint256 public ownerPercent;
    uint256 public refPercent;

    uint256 public pumpCost;
    uint256 public pumpProfitPerDay;

    uint256 public scStartDay;

    uint256 public lotteryPrizePool;

    address public owner;
    address public refDefault;
    address public marketingWallet;



    //tools
    uint256 lastDaylyIncomeTime;
    uint256 lastIndexOfTopTableInitialized;
    address pointerForLinking;
    uint256 lastLotterSpinTime;


    /*struct of user. It helps to track pumps, balance, refs amount. */
    struct User{
        uint256 obtainedPumps;              //Pumps that in game 
        uint256 pumpToAddDuringNextIncome;  //Pumps would be in game after next claim
        address nextOne;                    //Link to next user
        address ref;                        //Ref of this person
        uint256 freeBalance;                //Balance, that could be spend on pumps or withdrawed
        uint256 amountOfRefs;               //amount of refs to participate in lottery
    }

    
    mapping(address => User) addrToUser;    // main mapping


    
    //onchain implementation of lottery spin
    address[10] lotteryTableTop10;          //Lottery top 10 table
    uint[10] lotteryTablePercents = [1,2,3,4,5,6,7,18,24,30];
    //off-chain implementation of lottery spin
    //event test (address Player, uint256 refs); 

    constructor(address _owner, address _refDefault, address _marketingWallet, uint _developersPercent, uint _marketingPercent, uint _ownerPercent, uint _lotteryPercent,
    uint _refPercent, uint _pumpCost, uint _pumpProfitPerDay, uint256 _scStartDay) {
       developersPercent = _developersPercent;
       marketingPercent = _marketingPercent;
       lotteryPercent = _lotteryPercent;
       refPercent = _refPercent;
       pumpCost = _pumpCost;
       pumpProfitPerDay = _pumpProfitPerDay;
       scStartDay = _scStartDay;
       owner = _owner;
       ownerPercent = _ownerPercent;
       refDefault = _refDefault;
       marketingWallet = _marketingWallet;

       lastDaylyIncomeTime = _scStartDay;
       lastLotterSpinTime = _scStartDay;
       pointerForLinking = _owner;          //storing init account to initiate linking. Base for _daylyIncome()
       lastIndexOfTopTableInitialized = 9;
    }
    /*Buying pump you need to transfer amount of ether that devide without lasting part.
    -ref set
    -Lottery table recounted after changes in refs
    -percent count and transfer
     */
    function BuyPump(address _ref) public payable nonReentrant {
        require(block.timestamp > scStartDay, "Not time yet");
        require(msg.value % pumpCost == 0, "Wrong amount of money");
        if(addrToUser[msg.sender].ref == address(0)){
            if(_ref == address(0) || _ref == msg.sender){
                addrToUser[msg.sender].ref = refDefault;
                
            }else{
                addrToUser[msg.sender].ref = _ref;
                addrToUser[_ref].amountOfRefs += 1;
                //recount
                _refArrayRecount(_ref);
            }
            
            addrToUser[pointerForLinking].nextOne = msg.sender;
            pointerForLinking = msg.sender;
        }

        uint256 pumpsToBuy = msg.value / pumpCost;

        //do i need to update msg.value after each transaction?
        payable(owner).transfer(msg.value * ownerPercent / 100);
        payable(marketingWallet).transfer(msg.value * marketingPercent / 100);
        payable(addrToUser[msg.sender].ref).transfer(msg.value * refPercent / 100);
        lotteryPrizePool += (msg.value * lotteryPercent / 100);
        addrToUser[msg.sender].pumpToAddDuringNextIncome += pumpsToBuy;

    }

    /*While checking balance function _daylyIncome() is calling */
    function CheckBalance() public returns(uint256, uint256) {
        _daylyIncome();
        return (addrToUser[msg.sender].obtainedPumps, addrToUser[msg.sender].pumpToAddDuringNextIncome);
        
    }
    /* it:
    -check if enough time passed
    -iterate through all addresses
    -start new pumps if available in account
    */
    function _daylyIncome() private{
        require(lastDaylyIncomeTime + 1 days > block.timestamp, "Not time yet");
        address user = addrToUser[owner].nextOne;
        while(user != address(0)){
            addrToUser[user].freeBalance += addrToUser[user].obtainedPumps * pumpProfitPerDay;
            addrToUser[user].obtainedPumps += addrToUser[user].pumpToAddDuringNextIncome;
            addrToUser[user].pumpToAddDuringNextIncome = 0;
            user = addrToUser[user].nextOne;
        }
    }

    /* Reinvesting = buying new pumps using "crafted" money 
    -by task u can reinvest only whole balance
    */
    function Reinvest() public {
        require(addrToUser[msg.sender].freeBalance > pumpCost);
        uint256 pumpsToBuy = addrToUser[msg.sender].freeBalance % pumpCost;
        addrToUser[msg.sender].freeBalance -= pumpCost * pumpsToBuy;
        addrToUser[msg.sender].pumpToAddDuringNextIncome += pumpsToBuy;
    }

    /* Simple withdraw func */
    function Withdraw(uint256 _amount) public nonReentrant{
        require(_amount <= addrToUser[msg.sender].freeBalance, "Not enough money to withdraw");
        payable(msg.sender).transfer(_amount);
    }
    //for ref pay refs into inner account or transfer to addr

    function LotterySpin() public nonReentrant{
        require(lastLotterSpinTime + 30 days > block.timestamp, "Not time yet");
        for (uint256 index = 0; index < 10; index++) {
            payable(lotteryTableTop10[index]).transfer(lotteryTablePercents[index] * lotteryPrizePool / 100);
        }
        //set amount of refs of each user to zero; 
        address user = addrToUser[owner].nextOne;
        while(user != address(0)){
            addrToUser[user].amountOfRefs = 0;
            user = addrToUser[user].nextOne;
        }
        lotteryPrizePool = 0;
    }

    /**
    need this func to find apropriate place to insert new value
     */
    function _refArrayRecount(address addr) private{
        uint index = lastIndexOfTopTableInitialized > 0 ? lastIndexOfTopTableInitialized : 0;
        if (index == 0){
        require(addrToUser[lotteryTableTop10[0]].amountOfRefs < addrToUser[addr].amountOfRefs, "Not enough refs to take a place into table");
        }
        uint i = 9;
        while(addrToUser[addr].amountOfRefs > addrToUser[lotteryTableTop10[i]].amountOfRefs){
            if(lotteryTableTop10[i] == address(0)){
                lotteryTableTop10[i] = addr;
                _arrayMove(i, addr);
                lastIndexOfTopTableInitialized--;
                return;
            }else{
            
                i--;
            }
        }
        _arrayMove(i, addr);
        
    }

    /**
    -inserting new value in table and move all addresses down from the apropriate number passed in args
     */
    function _arrayMove(uint _positionToInsert, address _toInsert) private{
        address addrTmp;
        for (uint256 index = _positionToInsert; index > lastIndexOfTopTableInitialized; index--) {
            addrTmp = lotteryTableTop10[index];
            lotteryTableTop10[index] = _toInsert;
            _toInsert = addrTmp;
        }
    }



    function getUser() public view returns(User memory){
        return addrToUser[msg.sender];
    }

    function getLotteryTable() public view returns(address[10] memory){
        return lotteryTableTop10;
    }

    
    
}

//do i need to transfer amount of money to ref through reinvest()


// File contracts/flattened.sol