/*
    SPDX-License-Identifier: MIT
    SideKick Finance
    High Net Worth
    Copyright 2022
*/

pragma solidity ^0.8.4;

import "./Whitelist.sol";
import "./Token.sol";
import "./IERC20.sol";


contract TokenMint is Whitelist {

//    using Address for address;

    event Mint(address indexed source, address indexed to, uint256 amount);

    address public tokenAddress;
    Token private token;
    address public exchangeableToken;
    //TODO maybe add function that can disable exchangeable token/exchange mint

    
    constructor(address _tokenAddress) Ownable() public {

        tokenAddress = _tokenAddress;

        //Only the mint should own its paired token
        token = Token(tokenAddress);
    }

    
    function mint(address beneficiary, uint256 tokenAmount) onlyWhitelisted public returns (uint256){
        require(tokenAmount > 0, "can't mint 0");

        if (token.mint(beneficiary, tokenAmount)) {
            emit Mint(msg.sender, beneficiary, tokenAmount);
            return tokenAmount;
        }

        return 0;

    }
    function mintForExchange(address beneficiary, uint256 tokenAmount) internal {
        if (token.mint(beneficiary, tokenAmount)) {
            emit Mint(msg.sender, beneficiary, tokenAmount);
            //return tokenAmount;
        }
    }
    function setExchangeableToken(address _exchangeableToken) public onlyOwner() {
        exchangeableToken = _exchangeableToken;
    }

    function exchangeTokens(uint amount) public {
        require(amount > 0, "can't exchange 0 tokens");
        address beneficiary = msg.sender;
        IERC20(exchangeableToken).transferFrom(beneficiary, address(this), amount);

        mintForExchange(beneficiary, amount);
    }
    
    function remainingMintableSupply() public view returns (uint256) {
        return token.remainingMintableSupply();
    }

}

/*
    SPDX-License-Identifier: MIT
    SideKick Finance
    High Net Worth
    Copyright 2022
*/

pragma solidity ^0.8.4;

import "./Ownable.sol";
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted');
        _;
    }

    /**
     * @dev add an address to the whitelist
     * @param addr address
     * @return success true if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     * @return success true if at least one address was added to the whitelist,
     * false if all addresses were already in the whitelist
     */
    function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    /**
     * @dev remove an address from the whitelist
     * @param addr address
     * @return success true if the address was removed from the whitelist,
     * false if the address wasn't in the whitelist in the first place
     */
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     * @return success successtrue if at least one address was removed from the whitelist,
     * false if all addresses weren't in the whitelist in the first place
     */
    function removeAddressesFromWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

}

/*
    SPDX-License-Identifier: MIT
    SideKick Finance
    High Net Worth
    Copyright 2022
*/

pragma solidity ^0.8.4;

abstract contract Token {
    function mint(address _to, uint256 _amount) public virtual returns (bool);
    function mintedSupply() public virtual view returns (uint256);
    function mintedBy(address player) public virtual view returns (uint256);
    function remainingMintableSupply() public virtual view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

/*
    SPDX-License-Identifier: MIT
    SideKick Finance
    High Net Worth
    Copyright 2022
*/

pragma solidity ^0.8.4;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}