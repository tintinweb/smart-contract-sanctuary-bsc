/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

/******************************************************************************
Swapping Contract Where User Can Swap Their Old Golden Sparrow Token With New One In 1:1 Ratio No Deduction
Website Link : https://www.goldensparrow.info
Whitepaper Link : https://www.goldensparrow.info/assets/file/GST_Whitepaper.pdf
Facebbok : https://www.facebook.com/Golden-Sparrow-Token-104806088937264
Twitter : https://twitter.com/RealGSTArmy?t=KcwL2Acee3_ieRJb2wkQyg&s=09
Telegram : https://telegram.me/+kPIlcohyp6FmYmE1  
Telegram Channel : https://t.me/goldensparrowgsp
Linkdin :  https://www.linkedin.com/in/golden-sparrow-token-86b12b242
Instagram : https://www.instagram.com/goldensparrowtoken/
*********************************************************************************/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface BEP20GSP {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GoldenSparrowswap {
    address payable private primaryAdmin;
    BEP20GSP public toToken = BEP20GSP(0x498eD517B7f72717b47B1fD8A841877BD3DEb801);
    BEP20GSP public fromToken= BEP20GSP(0x0Ea01f670EdeC2c30f8E5f082C30C847359Df95E);
    constructor() {
        primaryAdmin = payable(0x73D89efA05F82CcCE29a10796C916D5282527D1A);
	}

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return primaryAdmin;
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