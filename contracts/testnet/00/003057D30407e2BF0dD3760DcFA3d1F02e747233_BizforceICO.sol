/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

abstract contract SafeMath {
    /*Addition*/
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /*Subtraction*/
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /*Multiplication*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* Modulus */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

contract BizforceICO is SafeMath {

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
        uint256[] amountSwapToken;
        uint256[] amountNativeToken;
        uint[] lastUpdatedUTCDateTime;
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

    //Guards Against Integer Overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    //Participate In ICO
    function ParticipateICO(uint256 _swapToken,uint _phase) public returns (bool) {
        require(phaseStatus[_phase], 'Phase Is Not Active Now ?');
        uint256 tokenprice=phaseBuyRate[_phase];
        uint256 _NativeToken=div(_swapToken,tokenprice);  
        _NativeToken = safeMultiply(_NativeToken,uint256(10) ** nativeTokenDecimals);
        UserPurchaseDetails storage userpurchasedetail = userpurchasedetails[msg.sender];
        require(view_GetCurrentTimeStamp()>=phaseFromTimeStamp[_phase], 'ICO Phase Not Started Yet ?');
        require(view_GetCurrentTimeStamp()<=phaseToTimeStamp[_phase], 'ICO Phase Already Closed ?');
        require((userpurchasedetail.amountSwapToken[_phase]+_swapToken)>=phaseMinimumBuyCappings[_phase], 'Participation Does Not Meet Minimum Amount ?');
        require((userpurchasedetail.amountSwapToken[_phase]+_swapToken)<=phaseMaximumBuyCappings[_phase], 'Participation Does Not Meet Maximum Amount ?');
        require((phaseSold[_phase]+_NativeToken)<=phaseTargetSale[_phase], 'Targeted Sale Completed ?');
        // if(userpurchasedetail.amountSwapToken[_phase]==0){
        //    phaseParticipant[_phase]+=1;
        // }
        // phaseSold[_phase]+=_NativeToken;
        //  userpurchasedetail.amountSwapToken[_phase] += _swapToken;
        // userpurchasedetail.amountNativeToken[_phase] += _NativeToken;
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