/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)
/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)
/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)
/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Holder.sol)
/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
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

/**
 * @title Incomeisland interface
 */
interface IMiningCenter {
    /**
     * @notice transfer NFT to other user. The config also transfer.
     * @param _from nft owner address
     * @param _to nft receiver address
     * @param _type nft _type
     */
    function transferNFTByUser(
        address _from,
        uint256 _type,
        address _to
    ) external;

    /**
     * @notice transfer NFT to other user. The config also transfer.
     * @param _from nft owner address
     * @param _to nft receiver address
     * @param _type nft type
     * @param _nftId nft id
     */
    function updateNFTHistoryExternal(
        address _from,
        uint256 _type,
        uint256 _nftId,
        address _to
    ) external;

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function getHistoryIndex(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) external view returns (uint256);
}

/**
 * @title Incomeisland interface
 */
interface IIncomeisland {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function setApprovalForAll(address operator, bool approved) external;
}

contract TradingCenter is ERC1155Holder {
    using Address for address;

    IMiningCenter public miningCenter;

    IIncomeisland public incomeisland;

    struct NftOffer {
        uint256 nftType;
        uint256 nftNum;
        uint256 offerAmountWithBNB;
        address owner;
    }

    // @notice NftHistory
    // owner address => No => nft offer
    mapping(address => mapping(uint256 => NftOffer)) public tradingOfferList;

    // @notice NftHistory
    // owner address => length
    mapping(address => uint256) public tradingOfferListLength;

    uint256 public tradingFee;

    address private _ownerAddress;

    function init() external {
        require(
            miningCenter == IMiningCenter(address(0)) ||
                incomeisland == IIncomeisland(address(0)) ||
                _ownerAddress == address(0),
            "no permission"
        );
        miningCenter = IMiningCenter(
            0xd79cC53Fe8235Ee1fAC1F83fE8302b778Db8Ba5C
        );
        incomeisland = IIncomeisland(
            0xC1aF4CA423412A930becd138B9727e1C5bEc2837
        );
        _ownerAddress = 0x5747a7f258Bd38908A551CE6d76b8C2A428D7586;
        tradingFee = 10;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @notice set Miningcenter interface
     * @param _miningCenter Miningcenter address
     */
    function setIMiningCenter(IMiningCenter _miningCenter) external onlyOwner {
        miningCenter = _miningCenter;
    }

    /**
     * @notice set _tradingFee
     * @param _tradingFee trading address
     */
    function setTradingFee(uint256 _tradingFee) external onlyOwner {
        tradingFee = _tradingFee;
    }

    function createOffer(
        uint256 _nftType,
        uint256 _nftNum,
        uint256 _offerAmountWithBNB
    ) external {
        require(
            miningCenter.getHistoryIndex(msg.sender, _nftType, _nftNum) != 9999,
            "param err"
        );
        tradingOfferList[msg.sender][
            tradingOfferListLength[msg.sender]
        ] = NftOffer(_nftType, _nftNum, _offerAmountWithBNB, msg.sender);

        tradingOfferListLength[msg.sender] =
            tradingOfferListLength[msg.sender] +
            1;

        miningCenter.transferNFTByUser(msg.sender, _nftType, address(this));
    }

    function cancelOffer(uint256 _nftType, uint256 _nftNum) external {
        require(
            miningCenter.getHistoryIndex(msg.sender, _nftType, _nftNum) != 9999,
            "param err"
        );
        uint256 index = 9999;
        for (uint256 i = 0; i < tradingOfferListLength[msg.sender]; i++) {
            if (
                tradingOfferList[msg.sender][i].nftNum == _nftNum &&
                tradingOfferList[msg.sender][i].nftType == _nftType &&
                tradingOfferList[msg.sender][i].owner == msg.sender
            ) {
                index = i;
            }
        }

        require(index != 9999, "not matched params");
        tradingOfferList[msg.sender][index] = NftOffer(0, 0, 0, address(0));

        tradingOfferListLength[msg.sender] =
            tradingOfferListLength[msg.sender] -
            1;

        incomeisland.setApprovalForAll(address(this), true);
        miningCenter.transferNFTByUser(address(this), _nftType, msg.sender);
    }

    function test(uint256 _nftType) external {
        incomeisland.setApprovalForAll(address(this), true);
        incomeisland.safeTransferFrom(
            address(this),
            msg.sender,
            _nftType,
            1,
            ""
        );
    }

    function trade(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) external payable {
        require(
            miningCenter.getHistoryIndex(_owner, _nftType, _nftNum) != 9999,
            "param err"
        );
        uint256 index = 9999;
        for (uint256 i = 0; i < tradingOfferListLength[_owner]; i++) {
            if (
                tradingOfferList[_owner][i].nftNum == _nftNum &&
                tradingOfferList[_owner][i].nftType == _nftType &&
                tradingOfferList[_owner][i].owner == _owner
            ) {
                index = i;
            }
        }

        require(index != 9999, "not matched params");
        require(
            msg.value >= tradingOfferList[_owner][index].offerAmountWithBNB,
            "no enough bnb"
        );
        tradingOfferList[_owner][index] = NftOffer(0, 0, 0, address(0));

        tradingOfferListLength[_owner] = tradingOfferListLength[_owner] - 1;

        miningCenter.transferNFTByUser(address(this), _nftType, msg.sender);
        miningCenter.updateNFTHistoryExternal(
            _owner,
            _nftType,
            _nftNum,
            msg.sender
        );

        payable(address(uint160(owner()))).transfer(
            (msg.value / 100) * tradingFee
        );

        payable(address(uint160(_owner))).transfer(
            (msg.value / 100) * (100 - tradingFee)
        );
    }

    /**
     * @notice manage trading history.
     * @param _owner trading owner
     * @param _index the order number which will operate
     * @param _mode 0: update 1: add 2: remove
     */
    function manageTradingHistory(
        address _owner,
        uint256 _nftNum,
        uint256 _nftType,
        uint256 _tradingOfferAmount,
        uint256 _index,
        uint16 _mode
    ) external onlyOwner {
        if (_mode == 0) {
            require(
                _index >= 0 && _index < tradingOfferListLength[_owner],
                "_index is not valid"
            );

            tradingOfferList[_owner][_index] = NftOffer(
                _nftType,
                _nftNum,
                _tradingOfferAmount,
                _owner
            );
        } else if (_mode == 1) {
            tradingOfferList[_owner][
                tradingOfferListLength[_owner]++
            ] = NftOffer(_nftType, _nftNum, _tradingOfferAmount, _owner);
        } else if (_mode == 2) {
            require(
                _index >= 0 && _index < tradingOfferListLength[_owner],
                "_index is not valid"
            );
            for (
                uint256 i = _index;
                i < tradingOfferListLength[_owner] - 1;
                i++
            ) {
                tradingOfferList[_owner][i] = tradingOfferList[_owner][i + 1];
            }
            tradingOfferList[_owner][
                tradingOfferListLength[_owner] - 1
            ] = NftOffer(0, 0, 0, address(0));
            tradingOfferListLength[_owner]--;
        }
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _ownerAddress;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        _ownerAddress = newOwner;
    }
}