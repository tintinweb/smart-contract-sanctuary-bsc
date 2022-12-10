// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract balahap {

    using Counters for Counters.Counter;
    Counters.Counter public offerIndex;
    Counters.Counter public disputeIndex;

    address public adminAddress;
    address public operatorAddress;
    address public BUSD; 
    uint256 public period  = 300 ; //5mins
    uint256 public betFeePercent = 2; //2%

    enum offerStatus{ OPEN, PAUSE, CLOSE}
    enum result{ NONE, HOSTWIN, BIDDERWIN, DRAW, DISPUTE}

    struct offer{
        address hostAddress;
        uint256 offerAmount;
        uint256 closeBetTime;
        string condition;
        bool isDispute;
        offerStatus status;
        result hostResult;
    }

    struct bidder{
        address bidderAddr;
        uint256 betAmt;
        uint256 sportmanshipFee;
        bool isHostClaimed;
        bool isBidderClaimed;
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
        BUSD = 0x32ed57673EC8a0c6e5c4cd0c53e2d0a5be1497f9; //busd testnet
    }

    function sportmanshipFeeCal(uint256 _amount) public pure returns(uint256){
        if(_amount < 1000 * 10 ** 18){
            return 10 * 10 ** 18;
        }else{
            return (_amount ) / 100;
        }
    }

    function betFeeCal(uint256 _amount) public view returns(uint256){
        return (_amount * betFeePercent) / 100;
    }

    function maxBet(uint256 _offerNo) public view returns(uint256){
        uint256 _num = bidderLength(_offerNo);
        uint256 _offerAmount = offerNo[_offerNo].offerAmount;
        uint256 totalBet = 0;
        for(uint256 i = 0 ; i < _num; i++){
            totalBet += biddersList[_offerNo][i].betAmt;
        }
        return _offerAmount - totalBet;
    }

    function isBidder(address _bidderAddr,uint256 _offerNo) public view returns(bool){
        uint256 _num = bidderLength(_offerNo);
        bool isFound = false;
        for(uint256 i = 0 ; i < _num; i++){
            if(_bidderAddr == biddersList[_offerNo][i].bidderAddr){
                isFound = true;
                break;
            }
        }
        return isFound;
    }

    function resultOfBidder(address _addr, uint256 _offerNo) public view returns(result){
        uint256 _num = bidderLength(_offerNo);
        result _result = result.NONE;
        for(uint256 i = 0 ; i < _num; i++){
            if(_addr == biddersList[_offerNo][_num].bidderAddr){
                _result = biddersList[_offerNo][_num].bidderResult;
                break;
            }
        }
        return _result;
    }

    function bidderNum(address _bidderAddr,uint256 _offerNo) public view returns(uint256 num){
        require (isBidder(_bidderAddr,_offerNo),"This address is not a bidder");
        uint256 _num = bidderLength(_offerNo);
        for(uint256 i = 0 ; i < _num; i++){
            if(_bidderAddr == biddersList[_offerNo][i].bidderAddr){
                num = i;
                return num;
            }
        }
    }

    function bidderLength(uint256 _offerNo) public view returns(uint256){
        return biddersList[_offerNo].length;
    }

    function makeOffer(uint256 _offerAmount,uint256 _closeBetTime,string memory _condition) external {
        uint256 _sportmanshipFee = sportmanshipFeeCal(_offerAmount);
        IERC20(BUSD).transferFrom(address(msg.sender) ,address(this),_offerAmount + _sportmanshipFee);
        offerIndex.increment();
        uint256 _id = offerIndex.current();
        offerNo[_id] = offer(msg.sender, _offerAmount, _closeBetTime, _condition, false, offerStatus.OPEN, result.NONE);
    }

    function bet(uint256 _offerNo, uint256 _betAmt) external {
 
        require(block.timestamp < offerNo[_offerNo].closeBetTime,"Bet time is over");
        require(offerNo[_offerNo].status == offerStatus.OPEN,"Bet is not open or exise");
        require(_betAmt <= maxBet(_offerNo),"Bet amount excess max bet");

        uint256 _sportmanshipFee = sportmanshipFeeCal(_betAmt);
        IERC20(BUSD).transferFrom(address(msg.sender),address(this),_betAmt + _sportmanshipFee);

        biddersList[_offerNo].push(bidder(msg.sender, _betAmt, _sportmanshipFee, false, false, result.NONE));
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
        require( block.timestamp > offerNo[_offerNo].closeBetTime +  period * 2,"Offer not ready for result yet");
        require( msg.sender == offerNo[_offerNo].hostAddress || isBidder(msg.sender,_offerNo), "Insufficient permission");

        if(msg.sender == offerNo[_offerNo].hostAddress && offerNo[_offerNo].hostResult == result.NONE){
           
            offerNo[_offerNo].hostResult = _result;
            
            uint256 _num = bidderLength(_offerNo);
            for(uint256 i = 0 ; i < _num; i++){
                if(_result != biddersList[_offerNo][i].bidderResult && biddersList[_offerNo][i].bidderResult != result.NONE){
                    /* Create Dispute */
                    offerNo[_offerNo].isDispute = true;
                    disputeIndex.increment();
                    uint256 _id = offerIndex.current();
                    disputeNo[_id] = dispute(_offerNo, offerNo[_offerNo].hostAddress, biddersList[_offerNo][i].bidderAddr , result.NONE );
                    emit CraeteDispute(_offerNo, address(msg.sender), _result, biddersList[_offerNo][i].bidderAddr, biddersList[_offerNo][i].bidderResult);
                }
            }

        }else if(isBidder(msg.sender,_offerNo)){
            require(biddersList[_offerNo][bidderNum(msg.sender,_offerNo)].bidderResult == result.NONE, "You already submit this bet result");
            biddersList[_offerNo][bidderNum(msg.sender,_offerNo)].bidderResult = _result;
            if(_result != offerNo[_offerNo].hostResult && offerNo[_offerNo].hostResult != result.NONE){
                /* Create Dispute */
                offerNo[_offerNo].isDispute = true;
                disputeIndex.increment();
                uint256 _id = offerIndex.current();
                disputeNo[_id] = dispute(_offerNo, offerNo[_offerNo].hostAddress, msg.sender , result.NONE );
                emit CraeteDispute(_offerNo, offerNo[_offerNo].hostAddress, offerNo[_offerNo].hostResult, address(msg.sender), _result);
            }
        }


       
    }

    function claimPrize(uint256 _offerNo) external {
        require( block.timestamp > offerNo[_offerNo].closeBetTime +  period * 4,"Offer not ready for Claim yet");

        if(msg.sender == offerNo[_offerNo].hostAddress){
            uint256 _num = bidderLength(_offerNo);
            uint256 _bet = offerNo[_offerNo].offerAmount;
            uint256 _smsFee = sportmanshipFeeCal(_bet);
            uint256 _prize = _bet;
            uint256 _fee = betFeeCal(_bet);
            uint256 _totalPrize = _prize - _fee;
            uint256 unBetAmount = maxBet(_offerNo);
            uint256 _totalClaim = 0;
            bool _isAllBidderAccept = true;

            if(offerNo[_offerNo].hostResult == result.HOSTWIN){
                /* Host Win */

                for(uint256 i = 0 ; i < _num; i++){
                    if(biddersList[_offerNo][i].bidderResult == result.NONE || biddersList[_offerNo][i].bidderResult == result.HOSTWIN){
                        /*Check Dispute*/
                        if(!biddersList[_offerNo][i].isHostClaimed){

                            _totalClaim += biddersList[_offerNo][i].betAmt;
                            biddersList[_offerNo][i].isHostClaimed = true;
                             
                        }                                  
                    } else {
                        _isAllBidderAccept = false;
                    }
                }
                if(_isAllBidderAccept){
                    offerNo[_offerNo].status = offerStatus.CLOSE;
                    IERC20(BUSD).transfer(address(msg.sender),_bet + _totalPrize + _smsFee);
                } else {
                    uint256 _partialBet = _totalClaim;
                    uint256 _partialPrizeWFee = betFeeCal(_totalClaim);
                    IERC20(BUSD).transfer(address(msg.sender),_partialBet + _partialPrizeWFee);
                    /* No manage smsFee yet for this condition*/
                }


            }else if(offerNo[_offerNo].hostResult == result.DRAW){
                /* Host Draw */

                for(uint256 i = 0 ; i < _num; i++){
                    if(biddersList[_offerNo][i].bidderResult == result.NONE || biddersList[_offerNo][i].bidderResult == result.DRAW){
                        /*Check Dispute*/
                        if(!biddersList[_offerNo][i].isHostClaimed){

                            _totalClaim += biddersList[_offerNo][i].betAmt;
                            biddersList[_offerNo][i].isHostClaimed = true;
                             
                        }                                  
                    } else {
                        _isAllBidderAccept = false;
                    }
                }
                if(_isAllBidderAccept){
                    offerNo[_offerNo].status = offerStatus.CLOSE;
                    IERC20(BUSD).transfer(address(msg.sender),_bet + _smsFee);
                } else {
                    IERC20(BUSD).transfer(address(msg.sender),_totalClaim + unBetAmount);
                    /* No manage smsFee yet for this condition*/
                }
                

            }

        /* No dispute claim yet*/
        }else if(isBidder(msg.sender,_offerNo) ){

            uint256 _bet = biddersList[_offerNo][bidderNum(msg.sender,_offerNo)].betAmt;
            uint256 _prize = _bet;
            uint256 _fee = betFeeCal(_bet);
            uint256 _totalPrize = _prize - _fee;
            uint256 _smsFee = sportmanshipFeeCal((biddersList[_offerNo][bidderNum(msg.sender,_offerNo)].betAmt));

            if(biddersList[_offerNo][bidderNum(msg.sender,_offerNo)].bidderResult == result.BIDDERWIN){
                /* Bidder Win */
                require(offerNo[_offerNo].hostResult == result.NONE || offerNo[_offerNo].hostResult == result.BIDDERWIN , "Host is not accept your win");
                
                biddersList[_offerNo][bidderNum(msg.sender,_offerNo)].isBidderClaimed = true;

                IERC20(BUSD).transfer(address(msg.sender), _bet + _totalPrize + _smsFee);

            }else if(biddersList[_offerNo][bidderNum(msg.sender,_offerNo)].bidderResult == result.DRAW){
                /* Bidder Draw */
                require(offerNo[_offerNo].hostResult == result.NONE || offerNo[_offerNo].hostResult == result.DRAW , "Host is not accept your Draw");
                //DRAW is no fee
                IERC20(BUSD).transfer(address(msg.sender), _bet + _smsFee);
            }
        }
    }

    

    function getBlockTimeStamp() external view returns (uint256){
        return block.timestamp;
    }

    /* onlyAdmin not add yet*/
    function setPeriod(uint256 _period) external {
       _setPeriod(_period);
    }

    function _setPeriod(uint256 _period) internal {
        period = _period;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not admin");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }
    
    modifier onlyAdminOrOperator() {
        require(msg.sender == adminAddress || msg.sender == operatorAddress, "Not operator/admin");
        _;
    }


    function setOperator(address _operatorAddress) external onlyAdmin {
        require(_operatorAddress != address(0), "Cannot be zero address");
        operatorAddress = _operatorAddress;
    }


    function setAdmin(address _adminAddress) external onlyAdmin {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;
    }

    function recoverToken(address _token, uint256 _amount) external onlyAdmin {
        IERC20(_token).transfer(address(msg.sender), _amount);
    }

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