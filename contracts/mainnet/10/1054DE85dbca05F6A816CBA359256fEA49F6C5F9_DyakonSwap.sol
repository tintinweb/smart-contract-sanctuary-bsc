/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

/******************************************************************************
Token Name : Dyakon
Short Name/Ticker : DYN
Total Supply : 10000000000
Decimal : 18
Platform : BEP20 
Project Name : Dyakon
Website Link : https://dyakon.eu/
Swapping Platform Link : https://swap.dyakon.eu/
Whitepaper Link : https://www.dyakon.eu/whitepaper.pdf
Facebbok : https://www.facebook.com/DyakonOfficial/
Twitter : https://twitter.com/dyakon_official
Telegram : https://t.me/dyakon_official
********************************************************************************/
//SPDX-License-Identifier: Unlicensed
/* Interface Declaration */
pragma solidity ^0.8;
abstract contract SafeMath {
        /* Addition of Two Number */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* Subscription of Two Number */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /* Multiplication of Two Number */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* Divison of Two Number */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* Modulus of Two Number */
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

contract DyakonSwap is SafeMath {
    address payable private primaryAdmin;
    IERC20 private fromToken;
    IERC20 private toToken;
    constructor() {
        address payable msgSender = payable(msg.sender);
        primaryAdmin = msgSender;
	}

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return primaryAdmin;
    }

    /**
     * @dev Returns the swap token contract address.
     */
    function fromTokenContractAddress() public view returns (IERC20) {
        return fromToken;
    }

    /**
     * @dev Returns the native token contract address.
     */
    function toTokenContractAddress() public view returns (IERC20) {
        return toToken;
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

    struct UserSwapDetails {
        uint256 totalFromToken;
        uint256 totalToToken;
        uint lastUpdatedUTCDateTime;
	}

	mapping (address => UserSwapDetails) public userswapdetails;

    event Swap(address _user, uint256 _nativeTokensQty,uint256 _swapTokensQty);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function updateFromTokenContractAddress(IERC20 _fromToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        fromToken=_fromToken;
    }

    function updateToTokenContractAddress(IERC20 _toToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');   
        toToken=_toToken;
    }

    function SwapToken(uint256 _TokenQty) public returns (bool) {
       UserSwapDetails storage _UserSwapDetails = userswapdetails[msg.sender];
       _UserSwapDetails.totalFromToken += _TokenQty;
       _UserSwapDetails.totalToToken += _TokenQty;
       _UserSwapDetails.lastUpdatedUTCDateTime = view_GetCurrentTimeStamp();
       fromToken.transferFrom(msg.sender, address(this), _TokenQty);
       toToken.transfer(msg.sender, _TokenQty);
       emit Swap(msg.sender, _TokenQty,_TokenQty);
       return true;
    }

    //Contarct Owner Can Sent From Token on Smart Contract
    function _setupFromToken(uint256 _SwapToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        fromToken.transferFrom(msg.sender, address(this), _SwapToken);
    }

    //Contarct Owner Can Take Back From Token from Smart Contract
    function _reverseFromToken(uint256 _SwapToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        fromToken.transfer(primaryAdmin, _SwapToken);
    }

    //Contarct Owner Can Sent To Token on Smart Contract
    function _setupToToken(uint256 _NativeToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        toToken.transferFrom(msg.sender, address(this), _NativeToken);
    }

    //Contarct Owner Can Take Back To Token from Smart Contract
    function _reverseToToken(uint256 _NativeToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        toToken.transfer(primaryAdmin, _NativeToken);
    }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }
}