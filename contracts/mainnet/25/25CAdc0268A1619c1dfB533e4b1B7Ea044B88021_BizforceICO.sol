/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

interface IERC20 { 
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);
    function decimals() external returns (uint8);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract BizforceICO  {

    address payable private primaryAdmin;
    IERC20 private swapToken;
    IERC20 private nativeToken;
    uint private swapTokenDecimals;
    uint private nativeTokenDecimals;

    mapping(uint => uint) public phaseParticipant;
    mapping(uint => uint256) public phaseTargetSale;
    mapping(uint => uint256) public phaseSold;
    mapping(uint => bool) private phaseStatus;
    mapping(uint => uint) private phaseFromTimeStamp;
    mapping(uint => uint) private phaseToTimeStamp;
    mapping(uint => uint256) private phaseBuyRate;
    mapping(uint => uint256) private phaseMinimumBuyCappings;
    mapping(uint => uint256) private phaseMaximumBuyCappings;

    struct UserPurchaseDetails {
        mapping(uint => uint256) amountSwapToken;
        mapping(uint => uint256) amountNativeToken;
        mapping(uint => uint) lastUpdatedUTCDateTime;
	}

    mapping (address => UserPurchaseDetails) private userpurchasedetails;

    event Participated(address _buyer, uint256 _nativeTokensQty,uint256 _swapTokensQty);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address payable msgSender = payable(msg.sender);
        primaryAdmin = msgSender;
	}

    /**
     * Owner Can Update Phase Status
     */
    function _updateICOPhaseDetails(uint _phase,bool _status,uint _fromTimeStamp,uint _toTimeStamp,uint256 _buyRate,uint256 _minimumBuyCappings,uint256 _maximumBuyCappings,uint256 _targetSale) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        phaseStatus[_phase]=_status;
        phaseFromTimeStamp[_phase]=_fromTimeStamp;
        phaseToTimeStamp[_phase]=_toTimeStamp;
        phaseBuyRate[_phase]=_buyRate;
        phaseMinimumBuyCappings[_phase]=_minimumBuyCappings;
        phaseMaximumBuyCappings[_phase]=_maximumBuyCappings;
        phaseTargetSale[_phase]=_targetSale;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return primaryAdmin;
    }

    /**
     * Get Phase Details
     */
    function _getICOPhaseDetails(uint _phase) public view returns (bool,uint,uint,uint256,uint256,uint256) {
        return (phaseStatus[_phase],phaseFromTimeStamp[_phase],phaseToTimeStamp[_phase],phaseBuyRate[_phase],phaseMinimumBuyCappings[_phase],phaseMaximumBuyCappings[_phase]);
    }

    /**
     * Get User Phase Details
     */
    function _getUserPurchaseDetails(uint _phase,address _wallet) public view returns (uint256,uint256,uint) {
        UserPurchaseDetails storage userpurchasedetail = userpurchasedetails[_wallet];
        return (userpurchasedetail.amountSwapToken[_phase],userpurchasedetail.amountNativeToken[_phase],userpurchasedetail.lastUpdatedUTCDateTime[_phase]);
    }

    /**
     * @dev Returns the swap token contract address.
     */
    function swapTokenContractAddress() public view returns (IERC20) {
        return swapToken;
    }

    /**
     * @dev Returns the native token contract address.
     */
    function nativeTokenContractAddress() public view returns (IERC20) {
        return nativeToken;
    }

    /**
     * @dev Returns the Estimated Swap Token For Buy Native Token
     */
    function getEstimatedSwapTokenForBuy(uint _phase,uint256 _NativeToken)public view returns(uint256 _tokenPrice){
        uint256 _tokenprice=phaseBuyRate[_phase];
        if (_NativeToken == 0) {
            return 0;
        } else {
            uint256 SwapTokenWorth = _NativeToken * _tokenprice;
            assert(SwapTokenWorth / _NativeToken == _tokenprice);
            return SwapTokenWorth;
        }
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(primaryAdmin == payable(msg.sender), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(primaryAdmin, address(0));
        primaryAdmin = payable(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(primaryAdmin, newOwner);
        primaryAdmin = newOwner;
    }

    function updateNativeTokenContractAddress(IERC20 _NativeTokenContract,uint _NativeTokenDecimals) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        nativeToken=_NativeTokenContract;
        nativeTokenDecimals=_NativeTokenDecimals;
    }

    function updateSwapTokenContractAddress(IERC20 _SwapTokenContract,uint _SwapTokenDecimals) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');   
        swapToken=_SwapTokenContract;
        swapTokenDecimals=_SwapTokenDecimals;
    }

    function divide(uint256 x, uint256 y) internal pure returns (uint256) {
        if (y == tofixed()) return x;
        assert(y != 0);
        assert(y <= maxFixedDivisor());
        return multiply(x, reciprocal(y));
    }

    function tofixed() internal pure returns(uint256) {
        return 1000000000000000000;
    }

    function maxFixedDivisor() internal pure returns(uint256) {
        return 1000000000000000000000000000000000000000000000000;
    }

    function reciprocal(uint256 x) internal pure returns (uint256) {
        assert(x != 0);
        return (tofixed()*tofixed()) / x; // Can't overflow
    }
    function integer(uint256 x) internal pure returns (uint256) {
        return (x / tofixed()) * tofixed(); // Can't overflow
    }
    function fractional(uint256 x) internal pure returns (uint256) {
        return x - (x / tofixed()) * tofixed(); // Can't overflow
    }
    function multiply(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0 || y == 0) return 0;
        if (y == tofixed()) return x;
        if (x == tofixed()) return y;

        // Separate into integer and fractional parts
        // x = x1 + x2, y = y1 + y2
        uint256 x1 = integer(x) / tofixed();
        uint256 x2 = fractional(x);
        uint256 y1 = integer(y) / tofixed();
        uint256 y2 = fractional(y);
        
        // (x1 + x2) * (y1 + y2) = (x1 * y1) + (x1 * y2) + (x2 * y1) + (x2 * y2)
        uint256 x1y1 = x1 * y1;
        if (x1 != 0) assert(x1y1 / x1 == y1); // Overflow x1y1
        
        // x1y1 needs to be multiplied back by fixed1
        // solium-disable-next-line mixedcase
        uint256 fixed_x1y1 = x1y1 * tofixed();
        if (x1y1 != 0) assert(fixed_x1y1 / x1y1 == tofixed()); // Overflow x1y1 * fixed1
        x1y1 = fixed_x1y1;

        uint256 x2y1 = x2 * y1;
        if (x2 != 0) assert(x2y1 / x2 == y1); // Overflow x2y1

        uint256 x1y2 = x1 * y2;
        if (x1 != 0) assert(x1y2 / x1 == y2); // Overflow x1y2

        x2 = x2 / mulPrecision();
        y2 = y2 / mulPrecision();
        uint256 x2y2 = x2 * y2;
        if (x2 != 0) assert(x2y2 / x2 == y2); // Overflow x2y2

        // result = tofixed() * x1 * y1 + x1 * y2 + x2 * y1 + x2 * y2 / tofixed();
        uint256 result = x1y1;
        result = add(result, x2y1); // Add checks for overflow
        result = add(result, x1y2); // Add checks for overflow
        result = add(result, x2y2); // Add checks for overflow
        return result;
    }
    function mulPrecision() internal pure returns(uint256) {
        return 1000000000000000000;
    }
    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        if (x > 0 && y > 0) assert(z > x && z > y);
        if (x < 0 && y < 0) assert(z < x && z < y);
        return z;
    }
    //Participate In ICO
    function ParticipateICO(uint256 _swapToken,uint _phase) public returns (bool) {
        require(phaseStatus[_phase], 'Phase Is Not Active Now ?');
        uint256 tokenprice=phaseBuyRate[_phase];
        uint256 _NativeToken=divide(_swapToken,tokenprice);
        UserPurchaseDetails storage userpurchasedetail = userpurchasedetails[msg.sender];
        require(view_GetCurrentTimeStamp()>=phaseFromTimeStamp[_phase], 'ICO Phase Not Started Yet ?');
        require(view_GetCurrentTimeStamp()<=phaseToTimeStamp[_phase], 'ICO Phase Already Closed ?');
        require((userpurchasedetail.amountSwapToken[_phase]+_swapToken)>=phaseMinimumBuyCappings[_phase], 'Participation Does Not Meet Minimum Amount ?');
        require((userpurchasedetail.amountSwapToken[_phase]+_swapToken)<=phaseMaximumBuyCappings[_phase], 'Participation Does Not Meet Maximum Amount ?');
        require((phaseSold[_phase]+_NativeToken)<=phaseTargetSale[_phase], 'Targeted Sale Completed ?');
        if(userpurchasedetail.amountSwapToken[_phase]==0){
           phaseParticipant[_phase]+=1;
        }
        phaseSold[_phase]+=_NativeToken;
        userpurchasedetail.amountSwapToken[_phase] += _swapToken;
        userpurchasedetail.amountNativeToken[_phase] += _NativeToken;
        userpurchasedetail.lastUpdatedUTCDateTime[_phase] = view_GetCurrentTimeStamp();
        swapToken.transferFrom(msg.sender, address(this), _swapToken);
        nativeToken.transfer(msg.sender, _NativeToken);
        emit Participated(msg.sender, _NativeToken,_swapToken);
        return true;
    }

    //Revese Token That Admin Puten on Smart Contract
    function _reverseSwapToken(uint256 _SwapToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        swapToken.transfer(primaryAdmin, _SwapToken);
    }

    //Revese Token That Admin Puten on Smart Contract
    function _reverseNativeToken(uint256 _NativeToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        nativeToken.transfer(primaryAdmin, _NativeToken);
    }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }

   //View No Second Between Two Date & Time
    function view_GetNoofSecondBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _second){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate);
        return (datediff);
    }

    //View No Of Hour Between Two Date & Time
    function view_GetNoofHourBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60;
        return (datediff);
    }

    //View No Of Days Between Two Date & Time
    function view_GetNoofDaysBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60 / 24;
        return (datediff);
    }

    //View No Of Week Between Two Date & Time
    function view_GetNoofWeekBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _weeks){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint weekdiff = (datediff) / 7 ;
        return (weekdiff);
    }

    //View No Of Month Between Two Date & Time
    function view_GetNoofMonthBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _months){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint monthdiff = (datediff) / 30 ;
        return (monthdiff);
    }

    //View No Of Year Between Two Date & Time
    function view_GetNoofYearBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _years){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint yeardiff = (datediff) / 365 ;
        return yeardiff;
    }
}