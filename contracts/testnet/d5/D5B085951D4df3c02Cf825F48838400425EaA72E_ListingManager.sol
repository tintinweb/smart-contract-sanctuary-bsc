//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";

contract ListingManager is Ownable {

    /**
        Constants
     */
    uint256 public constant FEE_DENOMINATOR = 10**5;

    /**
        OTC Platform
     */
    address public OTC;

    /**
        Token Structure
     */
    struct TokenInfo {
        bool isBlacklisted;
        bool isAvailableToTrade;
        uint256 transactionFee;
        address transactionFeeRecipient;
        uint256 valuePutTowardListing;
        uint256 amountTransacted;
        uint256[] allOrders;
        uint256 indexInAllTokenArray;
    }
    
    /**
        Mapping From Tokens => TokenInfo
     */
    mapping ( address => TokenInfo ) public tokenInfo;

    /**
        List Of All Available Tokens
     */
    address[] public allAvailableTokens;

    /**
        Fee For Token To Get Listed
     */
    uint256 public listingFee;

    /**
        Fee Recipients
     */
    address public listingFeeRecipient;


    constructor(
        address OTC_, 
        uint256 listingFee_,
        address listingFeeRecipient_,
        address[] memory initialTokensToListWithoutFees
        ) {

        OTC = OTC_;
        listingFee = listingFee_;
        listingFeeRecipient = listingFeeRecipient_;

        uint len = initialTokensToListWithoutFees.length;
        for (uint i = 0; i < len;) {
            _listToken(initialTokensToListWithoutFees[i]);
            unchecked{ ++i; }
        }
    }


    function ownerRegisterToken(address token, uint256 transactionFee, address feeRecipient) external onlyOwner {
        require(
            tokenInfo[token].isAvailableToTrade == false,
            'Token Already Listed'
        );
        require(
            transactionFee <= FEE_DENOMINATOR / 3,
            'Transaction Fee Too High'
        );
        
        _listToken(token);
        tokenInfo[token].transactionFee = transactionFee;
        tokenInfo[token].transactionFeeRecipient = feeRecipient;
    }


    function ownerRemoveToken(address token) external onlyOwner {
        require(
            tokenInfo[token].isAvailableToTrade,
            'Token Not Listed'
        );

        // save state to make it easier
        address lastListing = allAvailableTokens[allAvailableTokens.length - 1];
        uint256 rmIndex = tokenInfo[token].indexInAllTokenArray;

        // disable ability to trade
        delete tokenInfo[token].valuePutTowardListing;
        delete tokenInfo[token].indexInAllTokenArray;
        delete tokenInfo[token].isAvailableToTrade;

        // move element in token array
        allAvailableTokens[rmIndex] = lastListing;
        tokenInfo[lastListing].indexInAllTokenArray = rmIndex;
        allAvailableTokens.pop();
    }

    function setListingFee(uint256 newListingFee) external onlyOwner {
        listingFee = newListingFee;
    }

    function setListingFeeRecipient(address newRecipient) external onlyOwner {
        require(
            newRecipient != address(0),
            'Zero Address'
        );
        listingFeeRecipient = newRecipient;
    }

    function blackListToken(address token) external onlyOwner {
        tokenInfo[token].isBlacklisted = true;
    }

    function unBlackListToken(address token) external onlyOwner {
        tokenInfo[token].isBlacklisted = false;
    }

    function setTokenTransactionFee(address token, uint256 newFee, address feeRecipient) external onlyOwner {
        require(
            newFee <= FEE_DENOMINATOR / 3,
            'Transaction Fee Too High'
        );
        tokenInfo[token].transactionFee = newFee;
        tokenInfo[token].transactionFeeRecipient = feeRecipient;
    }

    function setOTC(address OTC_) external onlyOwner {
        OTC = OTC_;
    }

    function addOrder(uint256 orderID, address token) external {
        require(
            msg.sender == OTC,
            'Only OTC'
        );
        
        // push to all order list
        tokenInfo[token].allOrders.push(orderID);
    }

    function fulfilledOrder(address token, uint256 amount) external {
        require(
            msg.sender == OTC,
            'Only OTC'
        );

        tokenInfo[token].amountTransacted += amount;
    }

    function listToken(address token) external payable {
        require(
            msg.value > 0,
            'Zero Value'
        );
        require(
            tokenInfo[token].isAvailableToTrade == false,
            'Token Already Listed'
        );
        require(
            tokenInfo[token].isBlacklisted == false,
            'Token Is Blacklisted'
        );

        tokenInfo[token].valuePutTowardListing += msg.value;

        if (tokenInfo[token].valuePutTowardListing >= listingFee) {
            _listToken(token);
        }

        _send(listingFeeRecipient, address(this).balance);
    }


    function getFeeAndRecipient(address token) external view returns (uint256, address) {
        return (tokenInfo[token].transactionFee, tokenInfo[token].transactionFeeRecipient);
    }

    function valueLeftToGetListed(address token) external view returns (uint256) {
        if (tokenInfo[token].isAvailableToTrade || tokenInfo[token].isBlacklisted) {
            return 0;
        }
        return tokenInfo[token].valuePutTowardListing >= listingFee ? 0 : listingFee - tokenInfo[token].valuePutTowardListing;
    }

    function canTrade(address token) external view returns (bool) {
        return tokenInfo[token].isAvailableToTrade;
    }

    function fetchAllAvailableTokens() external view returns (address[] memory) {
        return allAvailableTokens;
    }

    function fetchAllOrdersForToken(address token) external view returns (uint256[] memory) {
        return tokenInfo[token].allOrders;
    }

    function fetchTokenDetails(address token) public view returns (string memory symbol, uint8 decimals) {
        symbol = IERC20(token).symbol();
        decimals = IERC20(token).decimals();
    }

    function numOrdersForToken(address token) external view returns (uint256) {
        return tokenInfo[token].allOrders.length;
    }

    function batchFetchTokenDetails(address[] calldata tokens) public view returns (string[] memory, uint8[] memory) {

        uint len = tokens.length;
        string[] memory symbols = new string[](len);
        uint8[] memory decimals = new uint8[](len);

        for (uint i = 0; i < len;) {
            ( symbols[i], decimals[i] ) = fetchTokenDetails(tokens[i]);
            unchecked { ++i; }
        }
        return (symbols, decimals);
    }

    function fetchAvailableTokenDetails() external view returns (address[] memory, string[] memory, uint8[] memory) {

        uint len = allAvailableTokens.length;
        string[] memory symbols = new string[](len);
        uint8[] memory decimals = new uint8[](len);

        for (uint i = 0; i < len;) {
            ( symbols[i], decimals[i] ) = fetchTokenDetails(allAvailableTokens[i]);
            unchecked { ++i; }
        }

        return ( allAvailableTokens, symbols, decimals );
    }



    function _listToken(address token) internal {
        tokenInfo[token].isAvailableToTrade = true;
        tokenInfo[token].indexInAllTokenArray = allAvailableTokens.length;
        allAvailableTokens.push(token);
    }

    function _send(address to, uint256 amount) internal {
        if (to == address(this) || to == address(0)) {
            return;
        }
        (bool s,) = payable(to).call{value: amount, gas: 2300}("");
        require(s, 'ETH Transfer Failure');
    }

    
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}