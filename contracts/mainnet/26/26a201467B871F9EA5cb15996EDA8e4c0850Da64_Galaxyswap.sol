/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

/**

Website Link : https://swap.galaxyskyverse.io

Publish Date : 30th June 2022

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

contract Galaxyswap is SafeMath {

    address payable private primaryAdmin;
    IERC20 private SwapToken;
    IERC20 private NativeToken;
    uint private SwapTokenDecimals;
    uint private NativeTokenDecimals;
    uint256 private buyRate;
    uint256 private buyCappings;
    uint256 private sellRate;
    uint256 private sellCappings;

    constructor() {
        address payable msgSender = payable(msg.sender);
        primaryAdmin = msgSender;
        SwapToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        SwapTokenDecimals=18;
        NativeToken = IERC20(0x06F9Aa9E8D5De6783C194C3bf32977Dd75e29F4F);
        NativeTokenDecimals=18;
	}

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return primaryAdmin;
    }

    /**
     * @dev Returns the buyPrice of Token.
     */
    function buyPrice() public view returns (uint256) {
        return buyRate;
    }

    /**
     * @dev Returns the sellPrice of token.
     */
    function sellPrice() public view returns (uint256) {
        return sellRate;
    }

    /**
     * @dev Returns the Buy Cappings of token.
     */
    function buyCapping() public view returns (uint256) {
        return buyCappings;
    }

    /**
     * @dev Returns the Sell Cappings of token.
     */
    function sellCapping() public view returns (uint256) {
        return sellCappings;
    }

    /**
     * @dev Returns the swap token contract address.
     */
    function swapTokenContractAddress() public view returns (IERC20) {
        return SwapToken;
    }

    /**
     * @dev Returns the native token contract address.
     */
    function nativeTokenContractAddress() public view returns (IERC20) {
        return NativeToken;
    }

    /**
     * @dev Returns the Estimated Swap Token For Buy Native Token
     */
    function getEstimatedSwapTokenForBuy(uint256 _NativeToken)public view returns(uint256 _tokenPrice){
        uint256 _tokenprice=buyPrice();
        if (_NativeToken == 0) {
            return 0;
        } else {
            uint256 SwapTokenWorth = _NativeToken * _tokenprice;
            assert(SwapTokenWorth / _NativeToken == _tokenprice);
            return SwapTokenWorth;
        }
    }

    /**
     * @dev Returns the Estimated Swap Token For Buy Native Token
     */
    function getEstimatedSwapTokenForSell(uint256 _NativeToken)public view returns(uint256 _tokenPrice){
        uint256 _tokenprice=sellPrice();
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

    struct UserSaleDetails {
        uint256 amountSwapToken;
        uint256 amountNativeToken;
        uint lastUpdatedUTCDateTime;
	}

    struct UserPurchaseDetails {
        uint256 amountSwapToken;
        uint256 amountNativeToken;
        uint lastUpdatedUTCDateTime;
	}

	mapping (address => UserSaleDetails) public usersaledetails;
    mapping (address => UserPurchaseDetails) public userpurchasedetails;

    event Sold(address _seller, uint256 _nativeTokensQty,uint256 _swapTokensQty);
    event Bought(address _buyer, uint256 _nativeTokensQty,uint256 _swapTokensQty);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function updateSellCappings(uint256 _sellCappings) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        sellCappings=_sellCappings;
    }

    function updateBuyCappings(uint256 _buyCappings) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        buyCappings=_buyCappings;
    }

    function updateSellRate(uint256 _sellRate) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        sellRate=_sellRate;
    }

    function updateBuyRate(uint256 _buyRate) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        buyRate=_buyRate;
    }

    function updateNativeTokenContractAddress(IERC20 _NativeTokenContract,uint _NativeTokenDecimals) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        NativeToken=_NativeTokenContract;
        NativeTokenDecimals=_NativeTokenDecimals;
    }

    function updateSwapTokenContractAddress(IERC20 _SwapTokenContract,uint _SwapTokenDecimals) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');   
        SwapToken=_SwapTokenContract;
        SwapTokenDecimals=_SwapTokenDecimals;
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

    function BuyNativeToken(uint256 _SwapToken) public returns (bool) {
       uint256 tokenprice=buyPrice();
       uint256 _NativeToken=div(_SwapToken,tokenprice);  
       _NativeToken = safeMultiply(_NativeToken,uint256(10) ** NativeTokenDecimals);
       require(buyCappings >= _NativeToken ,'Capping Limits Exceed !');
       UserPurchaseDetails storage userpurchasedetail = userpurchasedetails[msg.sender];
       userpurchasedetail.amountSwapToken += _SwapToken;
       userpurchasedetail.amountNativeToken += _NativeToken;
       userpurchasedetail.lastUpdatedUTCDateTime = view_GetCurrentTimeStamp();
       buyCappings -= _NativeToken;
       SwapToken.transferFrom(msg.sender, address(this), _SwapToken);
       NativeToken.transfer(msg.sender, _NativeToken);
       emit Bought(msg.sender, _NativeToken,_SwapToken);
       return true;
    }

    function SellNativeToken(uint256 _NativeToken) public returns (bool) {
       uint256 _SwapToken=getEstimatedSwapTokenForSell(_NativeToken) / (uint256(10) ** SwapTokenDecimals);
       require(sellCappings >= _NativeToken ,'Capping Limits Completed !');  
	   UserSaleDetails storage usersaledetail = usersaledetails[msg.sender];
       usersaledetail.amountSwapToken += _SwapToken;
       usersaledetail.amountNativeToken += _NativeToken;
       usersaledetail.lastUpdatedUTCDateTime=view_GetCurrentTimeStamp();
       sellCappings -= _NativeToken;
       NativeToken.transferFrom(msg.sender, address(this), _NativeToken);
       SwapToken.transfer(msg.sender, _SwapToken);
       emit Sold(msg.sender, _NativeToken,_SwapToken);
       return true;
    }

    //Once Claim Need From Smart Contract Admin Need To Update Token on Smart Contract
    function _setupSwapToken(uint256 _SwapToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        SwapToken.transferFrom(msg.sender, address(this), _SwapToken);
    }

    //Revese Token That Admin Puten on Smart Contract
    function _reverseSwapToken(uint256 _SwapToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        SwapToken.transfer(primaryAdmin, _SwapToken);
    }

    //Once Claim Need From Smart Contract Admin Need To Update Token on Smart Contract
    function _setupNativeToken(uint256 _NativeToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        NativeToken.transferFrom(msg.sender, address(this), _NativeToken);
    }

    //Revese Token That Admin Puten on Smart Contract
    function _reverseNativeToken(uint256 _NativeToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        NativeToken.transfer(primaryAdmin, _NativeToken);
    }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }

   //View No Second Between Two Date & Time
    function view_GetNoofSecondBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _second){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate);
        return (datediff);
    }

    //View No Of Hour Between Two Date & Time
    function view_GetNoofHourBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60;
        return (datediff);
    }

    //View No Of Days Between Two Date & Time
    function view_GetNoofDaysBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60 / 24;
        return (datediff);
    }

    //View No Of Week Between Two Date & Time
    function view_GetNoofWeekBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _weeks){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint weekdiff = (datediff) / 7 ;
        return (weekdiff);
    }

    //View No Of Month Between Two Date & Time
    function view_GetNoofMonthBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _months){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint monthdiff = (datediff) / 30 ;
        return (monthdiff);
    }

    //View No Of Year Between Two Date & Time
    function view_GetNoofYearBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _years){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint yeardiff = (datediff) / 365 ;
        return yeardiff;
    }
}