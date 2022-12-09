// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract balahap {

    using Counters for Counters.Counter;
    Counters.Counter public offerIndex;
    Counters.Counter public disputeIndex;

    address adminAddress;
    address public BUSD = 0x32ed57673EC8a0c6e5c4cd0c53e2d0a5be1497f9; //busd testnet
    uint256 public bufferPeriod  = 3600 ; //1hrs

    enum offerStatus{ OPEN, PAUSE, CLOSE}
    enum result{ NONE, DRAW, HOSTWIN, BIDDERWIN, DISPUTE}

    struct offer{
        address hostAddress;
        uint256 offerAmount;
        uint256 closeBetTime;
        uint256 allowClaimTime;
        string condition;
        bool isDispute;
        offerStatus status;
        result hostResult;
    }

    struct bidder{
        address bidderAddr;
        uint256 betAmt;
        uint256 sportmanshipFee;
        bool isClaimed;
        result bidderResult;
    }

    struct dispute{
        uint256 offerNo;
        address host;
        address bidder;
        result disputeResult;
    }


    mapping(uint256 => offer) public offerNo;
    mapping(uint256 => bidder[]) public biddersList;
    mapping(uint256 => dispute) public disputeNo;

    event CraeteDispute(uint256 _offerNo, address _hostAddr, result _hostResult, address _bidder, result _bidderResult);
    event ResolveDispute(uint256 _offerNo, address _hostAddr, address _bidder, address _adminAddr, result _adminResult);

    constructor (){
        adminAddress = msg.sender;
    }

    function sportmanshipFeeCal(uint256 _amount) public pure returns(uint256){
        if(_amount < 1000 * 10 ** 18){
            return 10 * 10 ** 18;
        }else{
            return (_amount ) / 100;
        }
    }

    function maxBet(uint256 _offerNo) public view returns(uint256){
        uint256 num = biddersList[_offerNo].length;
        uint256 _offerAmount = offerNo[_offerNo].offerAmount;
        uint256 totalBet = 0;
        for(uint256 i = 0 ; i < num; i++){
            totalBet += biddersList[_offerNo][num].betAmt;
        }
        return _offerAmount - totalBet;
    }

    function isBidder(address _bidderAddr,uint256 _offerNo) public view returns(bool){
        uint256 num = biddersList[_offerNo].length;
        bool isFound = false;
        for(uint256 i = 0 ; i < num; i++){
            if(_bidderAddr == biddersList[_offerNo][num].bidderAddr){
                isFound = true;
                break;
            }
        }
        return isFound;
    }

    function resultOfBidder(address _addr, uint256 _offerNo) public view returns(result){
        uint256 num = biddersList[_offerNo].length;
        result _result = result.NONE;
        for(uint256 i = 0 ; i < num; i++){
            if(_addr == biddersList[_offerNo][num].bidderAddr){
                _result = biddersList[_offerNo][num].bidderResult;
                break;
            }
        }
        return _result;
    }

    function bidderNum(address _bidderAddr,uint256 _offerNo) public view returns(uint256 num){
        require (isBidder(_bidderAddr,_offerNo),"This address is not a bidder");
        uint256 _num = biddersList[_offerNo].length;
        for(uint256 i = 0 ; i < _num; i++){
            if(_bidderAddr == biddersList[_offerNo][num].bidderAddr){
                num = _num;
                return num;
            }
        }
    }

    function makeOffer(uint256 _offerAmount,uint256 _closeBetTime,uint256 _endBetTIme,string memory _condition) external {
        uint256 _sportmanshipFee = sportmanshipFeeCal(_offerAmount);
        IERC20(BUSD).transferFrom(address(msg.sender) ,address(this),_offerAmount + _sportmanshipFee);
        offerIndex.increment();
        uint256 _id = offerIndex.current();
        offerNo[_id] = offer(msg.sender, _offerAmount, _closeBetTime, _endBetTIme, _condition, false, offerStatus.OPEN, result.NONE);
    }

    function bet(uint256 _offerNo, uint256 _betAmt) external {
        require(block.timestamp < offerNo[_offerNo].closeBetTime,"Bet time is over");
        require(offerNo[_offerNo].status == offerStatus.OPEN,"Bet is not open");
        require(_betAmt <= maxBet(_offerNo),"Bet amount excess max bet");

        uint256 _sportmanshipFee = sportmanshipFeeCal(_betAmt);
        IERC20(BUSD).transferFrom(address(msg.sender),address(this),_betAmt + _sportmanshipFee);

        biddersList[_offerNo].push(bidder(msg.sender, _betAmt, _sportmanshipFee, false, result.NONE));
    }


    function pauseOffer(uint256 _offerNo) external {
        require(msg.sender == offerNo[_offerNo].hostAddress,"Insufficient permission");
        require(offerNo[_offerNo].status == offerStatus.OPEN,"Offer is not in OPEN status");
        offerNo[_offerNo].status = offerStatus.PAUSE;
    }

    function resumeOffer(uint256 _offerNo) external {
        require(msg.sender == offerNo[_offerNo].hostAddress,"Insufficient permission");
        require(offerNo[_offerNo].status == offerStatus.PAUSE ,"Offer is not in PAUSE status");
        offerNo[_offerNo].status = offerStatus.OPEN;
    }

    function submitResult(uint256 _offerNo, result _result) external {
        require( block.timestamp > offerNo[_offerNo].closeBetTime +  bufferPeriod * 2,"Offer not ready for result yet");
        require( msg.sender == offerNo[_offerNo].hostAddress || isBidder(msg.sender,_offerNo), "Insufficient permission");

        if(msg.sender == offerNo[_offerNo].hostAddress){
            offerNo[_offerNo].hostResult = _result;
            uint256 _num = biddersList[_offerNo].length;
            for(uint256 i = 0 ; i < _num; i++){
                if(_result != biddersList[_offerNo][i].bidderResult && biddersList[_offerNo][i].bidderResult != result.NONE){
                    /* Create Dispute */
                    emit CraeteDispute(_offerNo, address(msg.sender), _result, biddersList[_offerNo][i].bidderAddr, biddersList[_offerNo][i].bidderResult);
                }
            }

        }else if(isBidder(msg.sender,_offerNo)){
            bidderNum(msg.sender,_offerNo);
            biddersList[_offerNo][bidderNum(msg.sender,_offerNo)].bidderResult = _result;
            if(_result != offerNo[_offerNo].hostResult && offerNo[_offerNo].hostResult != result.NONE){
                /* Create Dispute */
                emit CraeteDispute(_offerNo, offerNo[_offerNo].hostAddress, offerNo[_offerNo].hostResult, address(msg.sender), _result);
            }
        }


       
    }

    function claimPrize(uint256 _offerNo) external {

    }

    

    function getBlockTimeStamp() external view returns (uint256){
        return block.timestamp;
    }

}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}