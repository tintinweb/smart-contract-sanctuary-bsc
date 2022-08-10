/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }


    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


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


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor (address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address account, uint256[] calldata ids) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}


/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


interface IAVOERC20 is IERC20 {
    function addReward (uint256 amount) external returns (bool);
}


interface IAVONFT is IERC1155 {
    function exists(uint256 _id) external view returns(bool);
    function isTokenAuthor(address _account, uint256 _id) external view returns(bool);
    function isBanned(address _account) external view returns(bool);
    function getPlatformRoyalty(uint256 _id) external view returns(uint256);
    function getTokenPrice(uint256 _id) external view returns(uint256);
    function getTokenBroker(uint256 _id) external view returns(address);
    function getAuthorRoyalty(uint256 _id) external view returns(uint256);
    function getBrokerRoyalty(uint256 _id) external view returns(uint256);
    function getAuthorByTokenId(uint256 _id) external view returns (address);
}


contract AVOSales is ERC165, Ownable, ERC1155Receiver {
    using Address for address;
    using SafeERC20 for IAVOERC20;
    using SafeERC20 for IERC20;

    struct Bid {
        address bidder;
        uint256 amount;
    }

    struct Lot {
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        uint256 deadline;
        uint256 status;
        address seller;
        Bid[] bids;
    }

    mapping (uint256 => Lot) public _lots;

    mapping (uint256 => uint256) public _auctionedTokens;


    mapping (address => address) public _referrals;

    mapping (address => uint256) private _refBonusReceived;

    address public _platformWallet;

    uint256 private _primarySalesAmount;
    uint256 private _primarySalesVolume;

    uint256 private _secondarySalesAmount;
    uint256 private _secondarySalesVolume;

    uint256 private _auctionSalesAmount;
    uint256 private _auctionSalesVolume;


    uint256 private _referralPercent;

    uint256 private _communityDistributionPercent;

    address public avoERC20Contract;
    address public avoNFTContract;

    uint256 private lastLotId;

    event NewLot(uint256 _lotId, address _account, uint256 _id, uint256 _amount, uint256 _price, uint256 _deadline);

    event NewBid(uint256 _lotId, address _account, uint256 _amount);

    event Cancelled(uint256 _lotId);

    event Confirmed(address indexed _winner, uint256 _lotId, uint256 _amount);

    event InvalidBid(uint256 _lotId, address indexed _bidder, uint256 _amount);

    constructor (address initialOwner) Ownable(initialOwner) {}

    modifier contractsAreSet() {
        require(avoNFTContract != address(0), "NFT contract is not set");
        require(avoERC20Contract != address(0), "AVO ERC20 contract is not set");
        require(_platformWallet != address(0), "Platform wallet is not set");
        _;
    }


    function getSales() public view returns (uint256,uint256,uint256,uint256,uint256,uint256) {
        return (_primarySalesAmount,
                _primarySalesVolume,
                _secondarySalesAmount,
                _secondarySalesVolume,
                _auctionSalesAmount,
                _auctionSalesVolume
                );
    }

    function getRefBonus(address[] memory _accounts) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_accounts.length);
        for (uint i = 0; i < _accounts.length; i++ ) {
            result[i] = _refBonusReceived[_accounts[i]];
       }
       return result;
    }


    function getReferralPercent() public view returns(uint256) {
        return _referralPercent;
    }


    function getCommunityDistribution() public view returns(uint256) {
        return _communityDistributionPercent;
    }

    function setReferralPercent(uint256 _percent) external onlyOwner {
        require(_percent < 100, "Percentage cannot exceed 100%");
        _referralPercent = _percent;
    }

    function setCommunityDistribution(uint256 _percent) external onlyOwner {
        require(_percent < 100, "Percentage cannot exceed 100%");
        _communityDistributionPercent = _percent;
    }


    function setERC20Contract(address _account) external onlyOwner {
        require((_account != address(0) && _account.isContract()), "Invalid contract address");
        avoERC20Contract = _account;
    }

    function setNFTContract(address _account) external onlyOwner {
        require((_account != address(0) && _account.isContract()), "Invalid contract address");
        avoNFTContract = _account;
    }


    function setPlatformWallet(address _account) external onlyOwner {
        require(_account != address(0), "Zero address not allowed");
        _platformWallet = _account;
    }


    function recoverERC20(address _token, address _to) external onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance > 0, "No tokens to transfer");
        IERC20(_token).safeTransfer(_to, balance);
    }

    function recoverBNB(address payable _to) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No BNB to transfer");
        (bool sent, ) = _to.call{value: balance, gas: 50000}("");
        require(sent, "Failed to send BNB payment to owner");
    }


    function giveMeMyNFT(uint256 _id) external {
        require(avoNFTContract != address(0), "NFT contract is not set");
        require(IAVONFT(avoNFTContract).exists(_id), "Token doesn't exist");
        require(IAVONFT(avoNFTContract).isTokenAuthor(_msgSender(), _id), "Caller is not an authoor of a token");
        uint256 balance = IAVONFT(avoNFTContract).balanceOf(address(this), _id) - _auctionedTokens[_id];
        require( balance > 0, "Insufficient token amount on contract balance");
        IAVONFT(avoNFTContract).safeTransferFrom(address(this), _msgSender(), _id, balance, "");
    }


    function takeRefRoyalty(uint256 _amount, address _ref) internal returns(uint256) {
        if (_ref == address(0)) return 0;
        uint256 refRoyalty = _amount * _referralPercent / 100;
        IAVOERC20(avoERC20Contract).safeTransfer(_ref, refRoyalty);
        _refBonusReceived[_ref] += refRoyalty;
        return refRoyalty;
    }

    function takeBrokerRoyalty(uint256 _amount, uint256 _id) internal returns(uint256) {
        address broker = IAVONFT(avoNFTContract).getTokenBroker(_id);
        uint256 royalty = IAVONFT(avoNFTContract).getBrokerRoyalty(_id);
        if ( broker != address(0) || royalty == 0) return 0;
        uint256 bRoyalty = _amount * royalty / 100;
        IAVOERC20(avoERC20Contract).safeTransfer(broker, bRoyalty);
        return bRoyalty;
    }

    function takeAuthorRoyalty(uint256 _amount, uint256 _id) internal returns(uint256) {
        uint256 royalty = IAVONFT(avoNFTContract).getAuthorRoyalty(_id);
        if (royalty == 0) return 0;
        address author = IAVONFT(avoNFTContract).getAuthorByTokenId(_id);
        uint256 aRoyalty = _amount * royalty / 100;
        IAVOERC20(avoERC20Contract).safeTransfer(author, aRoyalty);
        return aRoyalty;
    }

    function takePlatformRoyalty(uint256 _amount, uint256 _id) internal returns(uint256) {
        uint256 royalty = IAVONFT(avoNFTContract).getPlatformRoyalty(_id);
        if (royalty == 0) return 0;
        uint256 pRoyalty = _amount * royalty / 100;
        uint distribution = pRoyalty * _communityDistributionPercent / 100;
        if (distribution > 0) {
            IAVOERC20(avoERC20Contract).safeApprove(avoERC20Contract, distribution);
            IAVOERC20(avoERC20Contract).addReward(distribution);
        }

        IAVOERC20(avoERC20Contract).safeTransfer(_platformWallet, pRoyalty - distribution);
        return pRoyalty;
    }

    function primaryBuyNFT(uint256 _id, uint256 _amount, address _ref) public contractsAreSet {
        primaryBuyNFT(_msgSender(), _id, _amount, _ref);
    }


    function primaryBuyNFT(address _account, uint256 _id, uint256 _amount, address _ref) internal {
        require(IAVONFT(avoNFTContract).exists(_id), "Token doesn't exist");
        require(!IAVONFT(avoNFTContract).isBanned(_account), "User is banned");
        require(IAVONFT(avoNFTContract).balanceOf(address(this), _id) - _auctionedTokens[_id] >= _amount, "Insufficient NFT token amount to buy");
        if (_referrals[_account] != address(0)) {
            _ref = _referrals[_account];
        } else if (_ref != address(0)) {
            _referrals[_account] = _ref;
        }
        uint256 totalAmount = _amount * IAVONFT(avoNFTContract).getTokenPrice(_id);
        IAVOERC20(avoERC20Contract).safeTransferFrom(_account, address(this), totalAmount);
        IAVONFT(avoNFTContract).safeTransferFrom(address(this), _account, _id, _amount, "");
        uint256 refRoyalty = takeRefRoyalty(totalAmount, _ref);
        uint256 bRoyalty = takeBrokerRoyalty(totalAmount, _id);
        uint256 pRoyalty  = takePlatformRoyalty(totalAmount, _id);
        IAVOERC20(avoERC20Contract).safeTransfer(IAVONFT(avoNFTContract).getAuthorByTokenId(_id), totalAmount - refRoyalty - pRoyalty - bRoyalty);
        _primarySalesAmount += _amount;
        _primarySalesVolume += totalAmount;
    }

    function secondaryBuyNFT(address _tokenOwner, uint256 _id, uint256 _amount, address _ref) public contractsAreSet {
        require(_tokenOwner != _msgSender(), "Caller is the owner of token.");
        secondaryBuyNFT(_msgSender(), _tokenOwner, _id, _amount, _ref);
    }


    function secondaryBuyNFT(address _account, address _owner, uint256 _id, uint256 _amount, address _ref) internal {
        require(IAVONFT(avoNFTContract).exists(_id), "Token doesn't exist");
        require(!IAVONFT(avoNFTContract).isBanned(_account), "User is banned");
        require(IAVONFT(avoNFTContract).balanceOf(_owner, _id) >= _amount, "Insufficient NFT token amount to buy");
        if (_referrals[_account] != address(0)) {
            _ref = _referrals[_account];
        } else if (_ref != address(0)) {
            _referrals[_account] = _ref;
        }
        uint256 totalAmount = _amount * IAVONFT(avoNFTContract).getTokenPrice(_id);
        IAVOERC20(avoERC20Contract).safeTransferFrom(_account, address(this), totalAmount);
        IAVONFT(avoNFTContract).safeTransferFrom(_owner, _account, _id, _amount, "");
        uint256 refRoyalty = takeRefRoyalty(totalAmount, _ref);
        uint256 bRoyalty = takeBrokerRoyalty(totalAmount, _id);
        uint256 pRoyalty = takePlatformRoyalty(totalAmount, _id);
        uint256 aRoyalty = takeAuthorRoyalty(totalAmount, _id);
        IAVOERC20(avoERC20Contract).safeTransfer(_owner, totalAmount - refRoyalty - pRoyalty - bRoyalty - aRoyalty);
        _secondarySalesAmount += _amount;
        _secondarySalesVolume += totalAmount;
    }


    function sellNFT(uint256 _id, uint256 _amount, uint256 _price, uint256 _period) public contractsAreSet {
        require(IAVONFT(avoNFTContract).exists(_id), "Token doesn't exist");
        require(IAVONFT(avoNFTContract).balanceOf(_msgSender(), _id) >= _amount,"Insufficient NFT amount");
        require(_price > 0, "Zero price not allowed");
        IAVONFT(avoNFTContract).safeTransferFrom(_msgSender(), address(this), _id, _amount, "");
        lastLotId++;
        Lot storage l = _lots[lastLotId];
        l.tokenId = _id;
        l.amount = _amount;
        l.price = _price;
        if (_period > 0) {
            l.deadline = block.timestamp + _period;
        } else {
            l.deadline = 0;
        }
        l.status = 1;
        l.seller = _msgSender();
        _auctionedTokens[_id] += _amount;
        emit NewLot(lastLotId, _msgSender(), _id, _amount, _price, l.deadline);
    }


    function placeBid(uint256 _id, uint256 _amount, address _ref) public contractsAreSet {
        require((lotIsActive(_id) && !lotIsExpired(_id)), "Bids for this lot are not allowed");
        require(IERC20(avoERC20Contract).allowance(_msgSender(), address(this)) >= _amount,"Insufficient allowance");
        require(IERC20(avoERC20Contract).balanceOf(_msgSender()) >= _amount,"Insufficient balance");
        require(_amount > _lots[_id].price, "Bid amount is lower than lot price");
        require(_amount > getMaxBid(_id), "Bid amount is lower than last bid");
        require(!hasBid(_id, _msgSender()), "You have already placed bid");
        if (_referrals[_msgSender()] == address(0) && _ref != address(0)) {
            _referrals[_msgSender()] = _ref;
        }
        Bid memory b = Bid({
                                bidder: _msgSender(),
                                amount: _amount
                            });
        _lots[_id].bids.push(b);
        emit NewBid(_id, _msgSender(), _amount);
    }

    function cancelSale(uint256 _id) public {
        require(lotIsActive(_id), "Lot is not active");
        require(_lots[_id].seller == _msgSender(), "This is not your lot");
        IAVONFT(avoNFTContract).safeTransferFrom(address(this), _msgSender(), _lots[_id].tokenId, _lots[_id].amount, "");
        _auctionedTokens[_id] -= _lots[_id].amount;
        _lots[_id].status = 2;
        emit Cancelled(_id);
    }


    function cancelBid(uint256 _id) public contractsAreSet {
        require(lotIsActive(_id), "Lot is not active");
        require(hasBid(_id, _msgSender()), "You don't have bids for this lot");
        uint256 idx = getBidIdx(_id, _msgSender());
        _lots[_id].bids[idx] = _lots[_id].bids[_lots[_id].bids.length-1];
        _lots[_id].bids.pop();
    }

    function checkERC20(address _account, uint256 _amount) internal view returns(bool) {
        if (IERC20(avoERC20Contract).allowance(_account, address(this)) < _amount ||
            IERC20(avoERC20Contract).balanceOf(_account) < _amount)
        {
            return false;
        }
        return true;
    }


    function confirmSale(uint256 _id) public contractsAreSet {
        require(lotIsActive(_id), "Lot is not active");
        require(_lots[_id].bids.length > 0, "No bids were made for this lot");
        address winner = getWinner(_id);
        uint256 amount = getMaxBid(_id);
        if (_lots[_id].deadline == 0) {
            require((_msgSender() == _lots[_id].seller || _msgSender() == owner()), "Unathorized");
        } else {
            require((_msgSender() == _lots[_id].seller || _msgSender() == winner || _msgSender() == owner()), "Unathorized");
        }
        if (!checkERC20(winner, amount)) {
            emit InvalidBid(_id, _lots[_id].bids[_lots[_id].bids.length-1].bidder, _lots[_id].bids[_lots[_id].bids.length-1].amount);
            _lots[_id].bids.pop();
            return;
        }
        IERC20(avoERC20Contract).safeTransferFrom(winner, address(this), amount);
        IAVONFT(avoNFTContract).safeTransferFrom(address(this), winner, _lots[_id].tokenId, _lots[_id].amount, "");
        _auctionedTokens[_id] -= _lots[_id].amount;
        _lots[_id].status = 3;
        emit Confirmed(winner, _id, amount);
        uint256 refRoyalty = takeRefRoyalty(amount, _referrals[winner]);
        uint256 bRoyalty = takeBrokerRoyalty(amount, _id);
        uint256 pRoyalty = takePlatformRoyalty(amount, _id);
        uint256 aRoyalty = takeAuthorRoyalty(amount, _id);
        IERC20(avoERC20Contract).safeTransfer(_lots[_id].seller, amount - refRoyalty - pRoyalty - bRoyalty - aRoyalty);
        _auctionSalesAmount += _lots[_id].amount;
        _auctionSalesVolume += amount;
    }

    function lotIsActive(uint256 _id) internal view returns(bool) {
        return _lots[_id].status == 1;
    }

    function lotIsExpired(uint256 _id) internal view returns(bool) {
        return _lots[_id].deadline < block.timestamp;
    }

    function getActiveBids(uint256 _id) public view returns(Bid[] memory) {
      Bid[] memory id = new Bid[](_lots[_id].bids.length);
      for (uint i = 0; i < _lots[_id].bids.length; i++) {
          Bid storage b = _lots[_id].bids[i];
          id[i] = b;
      }
      return id;
    }


    function hasBid(uint256 _id, address _account) internal view returns(bool) {
        for (uint i = 0; i < _lots[_id].bids.length; i++) {
            if (_lots[_id].bids[i].bidder == _account) return true;
        }
        return false;
    }


    function getMaxBid(uint256 _id) public view returns(uint256) {
        if (_lots[_id].bids.length == 0) return 0;
        return _lots[_id].bids[_lots[_id].bids.length-1].amount;
    }

    function getWinner(uint256 _id) public view returns(address) {
        return _lots[_id].bids[_lots[_id].bids.length-1].bidder;
    }

    function getBidIdx(uint256 _id, address _account) internal view returns(uint256) {
        uint i;
        for (i = 0; i < _lots[_id].bids.length; i++) {
            if (_lots[_id].bids[i].bidder == _account) return i;
        }
        return i;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, ERC1155Receiver) returns (bool) {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

}