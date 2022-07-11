/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// File: contracts/interfaces/IFractionalSale.sol


pragma solidity ^0.8.0;

interface IFractionalSale {
    function getFractionInfo(uint256 itemId) external returns (address frToken, uint256 lastSoldPrice, uint256 lastSoldTimestamp);
    function setSharesClaimedTimestamp(uint256 itemId, uint256 claimTime, address shareHolder) external;
    function getSharesClaimedTimestamp(uint256 itemId, address shareHolder) external view returns (uint256);
    function setLastSoldPrice(uint256 itemId, uint256 lastPrice) external;
    function setLastSoldTimestamp(uint256 itemId, uint256 saleTime) external;
}
// File: contracts/interfaces/IMarketplace.sol


pragma solidity ^0.8.0;

interface IMarketplace {
    function addTrade(uint256 itemId, address _from, address _to, uint256 _amount, uint256 _price) external;
    function getItemInfo(uint256 itemId) external view returns (uint256 tokenId, uint256 royaltyPercentage, address nftContract, address currentOwner, address royaltyRecipient, bool saleOngoing);
    function getItemForSale(uint256 itemId) external returns (bool);
    function setItemForSale(uint256 itemId, bool saleState) external;
    function setFractionalToken(uint256 itemId, address fToken) external;
    function isPublic() external view returns (bool);
    function isWhitelisted(address user) external view returns (bool);
    function getItemOwner(uint256 itemId) external returns (address);
    function setItemOwner(uint256 itemId, address newOwner) external;
    function isRegisteredCaller(address caller) external view returns (bool);
    function getMarketplaceFee() external view returns (uint256);
    function getBlacklisted(address user) external returns (bool);
    function isAcceptedToken(address token) external view returns (bool);
    function owner() external view returns (address);
}
// File: @openzeppelin/contracts/utils/Counters.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/FractionalTokenSale.sol



pragma solidity 0.8.7;





contract FractionalTokenSale {
    using Counters for Counters.Counter;
    Counters.Counter private _fSaleIds;

    IMarketplace private _market = IMarketplace(0xe04F9f7599e713A20dCFdB7AC316301911C4A8B1); 
    IFractionalSale private _fSale = IFractionalSale(0x6aE014560C9f2b4c469DC7516BB1F9986Efe6131);

    struct FSale {
        uint256 itemId;
        address seller;
        uint256 totalTokensForSale;
        uint256 price;
    }

    mapping(uint256 => FSale) _fSaleInfo;

    event FSaleCreated(uint256 saleId, address seller, uint256 tokenAmt, uint256 ts);
    event FrBought(uint256 saleId, address buyer, uint256 amountBought, uint256 ts);

    function createFractionSale(uint256 _itemId, uint256 tokensToSell, uint256 pricePerToken) external returns (uint256) {
        require(tokensToSell > 0 && pricePerToken > 0, "inv");

        (address frToken, , ) = _fSale.getFractionInfo(_itemId);
        require(IERC20(frToken).balanceOf(msg.sender) >= tokensToSell, "insufficient balance");
        require(IERC20(frToken).allowance(msg.sender, address(this)) >= tokensToSell, "insufficient allowance");

        _fSaleIds.increment();
        uint256 currentId = _fSaleIds.current();

        _fSaleInfo[currentId] = FSale({
            itemId: _itemId,
            seller: msg.sender,
            totalTokensForSale: tokensToSell,
            price: pricePerToken
        });

        emit FSaleCreated(currentId, msg.sender, tokensToSell, block.timestamp);

        return currentId;
    }

    function setContracts(address marketplaceAddr, address fractionalSaleAddr) external {
        require(msg.sender == _market.owner(), "mp owner only");
        _market = IMarketplace(marketplaceAddr);
        _fSale = IFractionalSale(fractionalSaleAddr);
    }

    function getFracTokenSaleInfo(uint256 saleId) external view returns (FSale memory) {
        return _fSaleInfo[saleId];
    }

    function updateSalePrice(uint256 saleId, uint256 newPricePerToken) external {
        require(_fSaleInfo[saleId].seller == msg.sender, "seller only");
        _fSaleInfo[saleId].price = newPricePerToken;
    }

    function totalSales() external view returns (uint256) {
        return _fSaleIds.current();
    }

    function buyFractions(uint256 saleId) external payable {
        require(msg.value >= _fSaleInfo[saleId].price, "insufficient bnb");
        (address frToken, , ) = _fSale.getFractionInfo(_fSaleInfo[saleId].itemId);
        uint tokensBought = msg.value / _fSaleInfo[saleId].price;
        require(tokensBought <= _fSaleInfo[saleId].totalTokensForSale, "insufficient tokens left");
        _fSaleInfo[saleId].totalTokensForSale -= tokensBought;

        ( , uint256 royaltyPercentage, , , address royaltyRecipient, ) = _market.getItemInfo(_fSaleInfo[saleId].itemId);

        uint256 feeAmt = msg.value * _market.getMarketplaceFee() / 1000;
        uint256 royaltyAmt = msg.value * royaltyPercentage / 1000;
        uint256 sellerAmt = msg.value - (feeAmt + royaltyAmt);

        (bool success1, ) = payable(_market.owner()).call{value: feeAmt}("");
        require(success1);

        if(royaltyAmt > 0) {
            (bool success2, ) = payable(royaltyRecipient).call{value: royaltyAmt}("");
            require(success2);
        }
        
        (bool success3, ) = payable(_fSaleInfo[saleId].seller).call{value: sellerAmt}("");
        require(success3);

        IERC20(frToken).transferFrom(_fSaleInfo[saleId].seller, msg.sender, tokensBought);

        emit FrBought(saleId, msg.sender, tokensBought, block.timestamp);
    }
}