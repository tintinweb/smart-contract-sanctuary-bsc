/**
 *Submitted for verification at BscScan.com on 2022-07-15
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
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
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
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
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
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
interface IIncomeisland {
    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    /**
     * @notice set tansfer contract address
     * @param _address tansfer contract address
     */
    function checkTransferPermission(address _address)
        external
        view
        returns (bool);

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function getNftType(uint256 _nftType)
        external
        view
        returns (
            uint256,
            string memory,
            string memory,
            uint256,
            uint256
        );

    /**
     * @notice get NFT totalNumber.
     */
    function getNftTotalNumber() external view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}

/**
 * @title ITransfer interface
 */
interface ITransfer {
    /**
     * @notice sale NFT function
     * @param _from nft owner address
     * @param _to nft buyer addresse
     * @param _nftType nftType
     * @param _nftNum nft unique number from 1.
     */
    function freeTransfer(
        address _from,
        address _to,
        uint256 _nftType,
        uint256 _nftNum
    ) external;
}

/**
 * @title Utility interface
 */
interface IUtility {
    /**
     * @notice get number of income token vs wbnb
     */
    function getIncomeTokenFromBNB(uint256 bnbNumber)
        external
        view
        returns (uint256);

    /**
     * @notice get number of income token vs wbnb
     */
    function getBnbTokenFromDollar(uint256 dollarAmount)
        external
        view
        returns (uint256);

    /**
     * @notice get usd price from bnb
     */
    function getDollarFromBnb(uint256 bnbAmount)
        external
        view
        returns (uint256);
}

contract MiningCenter is ERC1155Holder {
    using Address for address;

    /// @notice Information about the NFT as the property
    struct NftHistory {
        uint256 originUSDT;
        uint256 earnedUSDT;
        uint256 nftNum;
        bool staked;
    }

    struct NFTStakedInfo {
        address ownerAddress;
        uint256 stakedTime;
        uint256 nftNum;
        uint256 nftType;
        uint256 stakedType;
    }

    address private _ownerAddress;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyPermit() {
        require(
            owner() == msg.sender ||
                msg.sender == address(this) ||
                msg.sender == address(incomeIsland),
            "Ownable: caller is not the owner"
        );
        _;
    }

    // @notice ERC20 income token
    IIncomeisland public incomeIsland;

    // @notice utility contract interface
    IUtility public utility;

    // @notice transfer contract interface
    ITransfer public transfer;

    IERC20 public incomeToken;

    // @notice NftHistory
    // owner address => nft type => No => nft num
    mapping(address => mapping(uint256 => mapping(uint256 => NftHistory)))
        public nftHistory;

    // @notice NftHistoryLength
    mapping(address => mapping(uint256 => uint256)) public nftHistoryLength;

    // @notice StakingHistory
    // owner No => NFTStakedInfo
    mapping(uint256 => NFTStakedInfo) public stakingHistory;

    // @notice stakingHistoryLength
    uint256 public stakingHistoryLength;

    // @notice Staking Type
    // owner No => staking keep minutes
    mapping(uint256 => uint256) public stakingType;

    // @notice stakingTypeLength
    uint256 public stakingTypeLength;

    address public marketingWallet;

    uint256 public marketingPros;

    /**
     * @notice add nftHistory variable.
     * @param _owner the nft owner address
     * @param _nftType the nft type
     * @param _nftNum the nft unique number
     * @param _mode 0: remove 1: add
     */
    function updateNFTHistory(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum,
        uint16 _mode
    ) external onlyPermit {
        if (_mode == 0) {
            for (
                uint256 i = getHistoryIndex(_owner, _nftType, _nftNum);
                i < nftHistoryLength[_owner][_nftType] - 1;
                i++
            ) {
                nftHistory[_owner][_nftType][i] = nftHistory[_owner][_nftType][
                    i + 1
                ];
            }
            nftHistory[_owner][_nftType][
                nftHistoryLength[_owner][_nftType] - 1
            ] = NftHistory(0, 0, 0, false);
            nftHistoryLength[_owner][_nftType]--;
        } else if (_mode == 1) {
            (uint256 priceBNB, , , , ) = incomeIsland.getNftType(_nftType);
            nftHistory[_owner][_nftType][
                nftHistoryLength[_owner][_nftType]
            ] = NftHistory(
                priceBNB * utility.getDollarFromBnb(1),
                0,
                _nftNum,
                false
            );
            nftHistoryLength[_owner][_nftType]++;
        }
    }

    /**
     * @notice update nftHistory variable.
     * @param _owner the nft owner address
     * @param _nftType the nft type
     * @param _priceUSDT the nft bnb price
     * @param _nftNum the nft unique number
     * @param _mode 0: update 1: add
     */
    function manageNFTHistory(
        address _owner,
        uint256 _nftType,
        uint256 _priceUSDT,
        uint256 _earnedUSDT,
        uint256 _nftNum,
        bool _staked,
        uint16 _mode
    ) external onlyOwner {
        manageNFTHistoryIntern(
            _owner,
            _nftType,
            _priceUSDT,
            _earnedUSDT,
            _nftNum,
            _staked,
            _mode
        );
    }

    /**
     * @notice update nftHistory variable.
     * @param _owner the nft owner address
     * @param _nftType the nft type
     * @param _priceUSDT the nft bnb price
     * @param _nftNum the nft unique number
     * @param _mode 0: update 1: add
     */
    function manageNFTHistoryIntern(
        address _owner,
        uint256 _nftType,
        uint256 _priceUSDT,
        uint256 _earnedUSDT,
        uint256 _nftNum,
        bool _staked,
        uint16 _mode
    ) private {
        if (_mode == 0) {
            uint256 i = getHistoryIndex(_owner, _nftType, _nftNum);
            nftHistory[_owner][_nftType][i] = NftHistory(
                _priceUSDT,
                _earnedUSDT,
                _nftNum,
                _staked
            );
        } else if (_mode == 1) {
            nftHistory[_owner][_nftType][
                nftHistoryLength[_owner][_nftType]
            ] = NftHistory(_priceUSDT, 0, _nftNum, false);
            nftHistoryLength[_owner][_nftType]++;
        }
    }

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function getHistoryIndex(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) public view returns (uint256) {
        for (uint256 i = 0; i < nftHistoryLength[_owner][_nftType]; i++) {
            if (nftHistory[_owner][_nftType][i].nftNum == _nftNum) {
                return i;
            }
        }
        return 9999;
    }

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function getStakingIndex(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) public view returns (uint256) {
        for (uint256 i = 0; i < stakingHistoryLength; i++) {
            if (
                stakingHistory[i].nftNum == _nftNum &&
                stakingHistory[i].nftType == _nftType &&
                stakingHistory[i].ownerAddress == _owner
            ) {
                return i;
            }
        }
        return 9999;
    }

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function checkNftOwner(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) public view returns (uint256) {
        for (uint256 i = 0; i < nftHistoryLength[_owner][_nftType]; i++) {
            if (nftHistory[_owner][_nftType][i].nftNum == _nftNum) {
                return 1;
            }
        }
        return 0;
    }

    /**
     * @notice update nftHistory variable.
     * @param _stakeminutes staking keeping day
     * @param _index the order number which will operate
     * @param _mode 0: update 1: add 2: remove
     */
    function manageStakingType(
        uint256 _stakeminutes,
        uint256 _index,
        uint16 _mode
    ) external onlyOwner {
        if (_mode == 0) {
            require(stakingType[_index] != 0, "_index is not valid");
            stakingType[_index] = _stakeminutes;
        } else if (_mode == 1) {
            stakingType[stakingTypeLength++] = _stakeminutes;
        } else if (_mode == 2) {
            require(stakingType[_index] != 0, "_index is not valid");
            for (uint256 i = _index; i < stakingTypeLength - 1; i++) {
                stakingType[i] = stakingType[i + 1];
            }
            stakingType[stakingTypeLength - 1] = 0;
            stakingTypeLength--;
        }
    }

    /**
     * @notice update stakingHistory variable.
     * @param _stakedTime staked timestamp
     * @param _index the order number which will operate
     * @param _mode 0: update 1: add 2: remove
     */
    function manageStakingHistory(
        address _owner,
        uint256 _stakedTime,
        uint256 _nftNum,
        uint256 _nftType,
        uint256 _stakedType,
        uint256 _index,
        uint16 _mode
    ) external onlyOwner {
        if (_mode == 0) {
            require(
                _index >= 0 && _index < stakingHistoryLength,
                "_index is not valid"
            );

            stakingHistory[_index] = NFTStakedInfo(
                _owner,
                _stakedTime,
                _nftNum,
                _nftType,
                _stakedType
            );
        } else if (_mode == 1) {
            stakingHistory[stakingHistoryLength++] = NFTStakedInfo(
                _owner,
                _stakedTime,
                _nftNum,
                _nftType,
                _stakedType
            );
        } else if (_mode == 2) {
            require(
                _index >= 0 && _index < stakingHistoryLength,
                "_index is not valid"
            );
            for (uint256 i = _index; i < stakingHistoryLength - 1; i++) {
                stakingHistory[i] = stakingHistory[i + 1];
            }
            stakingHistory[stakingHistoryLength - 1] = NFTStakedInfo(
                address(0),
                0,
                0,
                0,
                0
            );
            stakingHistoryLength--;
        }
    }

    /**
     * @notice update nftHistory variable.
     * @param _stakingType 0: 7 minutes 1: 30 minutes 2: 180 minutes
     * @param _nftNum the property unique number
     * @param _nftType the property type
     */
    function stakingProperty(
        uint256 _stakingType,
        uint256 _nftNum,
        uint256 _nftType
    ) external {
        require(
            incomeIsland.balanceOf(msg.sender, _nftType) > 0,
            "You have no nft."
        );
        require(stakingType[_stakingType] != 0, "staking type err");
        uint256 index = getHistoryIndex(msg.sender, _nftType, _nftNum);
        require(index != 9999, "_nftType, _nftNum err");
        require(
            nftHistory[msg.sender][_nftType][index].nftNum == _nftNum,
            "nftType or _nftNum err"
        );
        require(
            nftHistory[msg.sender][_nftType][index].staked == false,
            "This nft is not staking status."
        );
        incomeIsland.safeTransferFrom(
            msg.sender,
            address(this),
            _nftType,
            1,
            ""
        );
        manageNFTHistoryIntern(
            msg.sender,
            _nftType,
            nftHistory[msg.sender][_nftType][index].originUSDT,
            nftHistory[msg.sender][_nftType][index].earnedUSDT,
            _nftNum,
            true,
            0
        );

        stakingHistory[stakingHistoryLength++] = NFTStakedInfo(
            msg.sender,
            block.timestamp,
            _nftNum,
            _nftType,
            _stakingType
        );
    }

    function transferNFT(
        address _to,
        uint256 _nftType,
        uint256 _nftNum
    ) external {
        require(_to != address(0), "cann't burn");
        uint256 index = getHistoryIndex(msg.sender, _nftType, _nftNum);
        NftHistory memory _nftHistory = nftHistory[msg.sender][_nftType][index];
        require(index != 9999, "_nftType, _nftNum err");
        require(_nftHistory.nftNum == _nftNum, "nftType or _nftNum err");
        require(_nftHistory.staked == false, "This nft is staking status.");

        nftHistory[msg.sender][_nftType][index] = NftHistory(0, 0, 0, false);
        nftHistoryLength[msg.sender][_nftType]--;
        nftHistory[_to][_nftType][nftHistoryLength[_to][_nftType]] = NftHistory(
            _nftHistory.originUSDT,
            0,
            _nftHistory.nftNum,
            false
        );
        nftHistoryLength[_to][_nftType]++;

        incomeIsland.safeTransferFrom(msg.sender, _to, _nftType, 1, "");
    }

    /**
     * @notice update nftHistory variable.
     * @param _nftNum the property unique number
     * @param _nftType the property type
     */
    function unStakingProperty(uint256 _nftNum, uint256 _nftType) external {
        uint256 index = getHistoryIndex(msg.sender, _nftType, _nftNum);
        NftHistory memory _nftHistory = nftHistory[msg.sender][_nftType][index];
        require(index != 9999, "_nftType, _nftNum err");
        require(_nftHistory.nftNum == _nftNum, "nftType or _nftNum err");
        require(_nftHistory.staked == true, "This nft is staking status.");

        uint256 stakingIndex = getStakingIndex(msg.sender, _nftType, _nftNum);
        require(stakingIndex != 9999, "There is no staking history");

        uint256 different = (block.timestamp -
            stakingHistory[stakingIndex].stakedTime) / 1 minutes;

        uint256 _earnedUSDT = (_nftHistory.originUSDT / 547) * different;
        if (_nftHistory.originUSDT >= _nftHistory.earnedUSDT + _earnedUSDT) {
            // Normal Logic
        } else if (_nftHistory.originUSDT >= _nftHistory.earnedUSDT) {
            _earnedUSDT =
                (_earnedUSDT -
                    _nftHistory.earnedUSDT +
                    _nftHistory.originUSDT) /
                2;
        } else {
            _earnedUSDT = _earnedUSDT / 2;
        }

        if (different >= stakingHistory[stakingIndex].stakedType) {
            incomeToken.transfer(
                msg.sender,
                utility.getIncomeTokenFromBNB(
                    utility.getBnbTokenFromDollar((_earnedUSDT * 11) / 10)
                )
            );
        } else {
            incomeToken.transfer(
                msg.sender,
                utility.getIncomeTokenFromBNB(
                    utility.getBnbTokenFromDollar(
                        (((_earnedUSDT * 11) / 10) * (100 - marketingPros)) /
                            100
                    )
                )
            );

            incomeToken.transfer(
                marketingWallet,
                utility.getIncomeTokenFromBNB(
                    utility.getBnbTokenFromDollar(
                        (_earnedUSDT * marketingPros) / 100
                    )
                )
            );
        }

        incomeIsland.safeTransferFrom(
            address(this),
            msg.sender,
            _nftType,
            1,
            ""
        );

        nftHistory[msg.sender][_nftType][index] = NftHistory(
            _nftHistory.originUSDT,
            _nftHistory.earnedUSDT + (_nftHistory.originUSDT / 547) * different,
            _nftHistory.nftNum,
            false
        );

        for (
            uint256 i = getStakingIndex(msg.sender, _nftType, _nftNum);
            i < stakingHistoryLength - 1;
            i++
        ) {
            stakingHistory[i] = stakingHistory[i + 1];
        }
        stakingHistory[stakingHistoryLength - 1] = NFTStakedInfo(
            address(0),
            0,
            0,
            0,
            0
        );
        stakingHistoryLength--;
    }

    function getRemainTimeBySeconds(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 stakingIndex = getStakingIndex(_owner, _nftType, _nftNum);
        require(stakingIndex != 9999, "There is no staking history");
        if (
            (stakingHistory[stakingIndex].stakedTime +
                1 minutes *
                stakingType[stakingHistory[stakingIndex].stakedType] >=
                block.timestamp)
        ) {
            return (
                ((block.timestamp - stakingHistory[stakingIndex].stakedTime) /
                    1 seconds),
                ((stakingHistory[stakingIndex].stakedTime +
                    1 minutes *
                    stakingType[stakingHistory[stakingIndex].stakedType] -
                    block.timestamp) / 1 seconds),
                1
            );
        } else {
            return (
                ((block.timestamp - stakingHistory[stakingIndex].stakedTime) /
                    1 seconds),
                ((block.timestamp -
                    stakingHistory[stakingIndex].stakedTime -
                    1 minutes *
                    stakingType[stakingHistory[stakingIndex].stakedType]) /
                    1 seconds),
                0
            );
        }
    }

    function getStakedminutes(
        address _owner,
        uint256 _nftNum,
        uint256 _nftType
    ) public view returns (uint256, uint256) {
        uint256 stakingIndex = getStakingIndex(_owner, _nftType, _nftNum);
        require(stakingIndex != 9999, "There is no staking history");

        uint256 different = (block.timestamp -
            stakingHistory[stakingIndex].stakedTime) / 1 minutes;
        return (
            different,
            stakingType[stakingHistory[stakingIndex].stakedType]
        );
    }

    /**
     * @notice update nftHistory variable.
     * @param _nftNum the property unique number
     * @param _nftType the property type
     */
    function getExpectedEarn(
        address _owner,
        uint256 _nftNum,
        uint256 _nftType
    ) external view returns (uint256, uint256) {
        uint256 index = getHistoryIndex(_owner, _nftType, _nftNum);
        NftHistory memory _nftHistory = nftHistory[_owner][_nftType][index];
        require(index != 9999, "_nftType, _nftNum err");
        require(_nftHistory.nftNum == _nftNum, "nftType or _nftNum err");
        require(_nftHistory.staked == true, "This nft is staking status.");

        uint256 stakingIndex = getStakingIndex(_owner, _nftType, _nftNum);
        require(stakingIndex != 9999, "There is no staking history");

        uint256 different = (block.timestamp -
            stakingHistory[stakingIndex].stakedTime) / 1 minutes;

        uint256 _earnedUSDT = (_nftHistory.originUSDT / 547) * different;
        if (_nftHistory.originUSDT >= _nftHistory.earnedUSDT + _earnedUSDT) {
            // Normal Logic
        } else if (_nftHistory.originUSDT >= _nftHistory.earnedUSDT) {
            _earnedUSDT =
                (_earnedUSDT -
                    _nftHistory.earnedUSDT +
                    _nftHistory.originUSDT) /
                2;
        } else {
            _earnedUSDT = _earnedUSDT / 2;
        }
        return (
            _earnedUSDT,
            stakingType[stakingHistory[stakingIndex].stakedType]
        );
    }

    /**
     * @notice Set incomeIsland interface address
     * @param _incomeIsland IIncomeisland address
     */
    function setIIncomeIsland(IIncomeisland _incomeIsland) external onlyOwner {
        incomeIsland = _incomeIsland;
    }

    /**
     * @notice Set income token address
     * @param _incomeToken IIncome token address
     */
    function setIncomeToken(IERC20 _incomeToken) external onlyOwner {
        incomeToken = _incomeToken;
    }

    /**
     * @notice set transfer address
     * @param _transfer transfer address
     */
    function setMarketplaceAddress(ITransfer _transfer) external onlyOwner {
        transfer = _transfer;
    }

    /**
     * @notice set utility address
     * @param _utility utility address
     */
    function setUtilityAddress(IUtility _utility) external onlyOwner {
        utility = _utility;
    }

    /**
     * @notice set marketing address
     * @param _marketingWallet marketing address
     */
    function setMarketingAddress(address _marketingWallet) external onlyOwner {
        marketingWallet = _marketingWallet;
    }

    /**
     * @notice set marketing percent
     * @param _marketingPros marketing percent
     */
    function setMarketingPros(uint256 _marketingPros) external onlyOwner {
        marketingPros = _marketingPros;
    }

    /**
     * @notice init the proxy storage
     */
    function Init() external {
        require(
            address(incomeIsland) == address(0) &&
                address(utility) == address(0) &&
                address(transfer) == address(0) &&
                address(incomeToken) == address(0) &&
                _ownerAddress == address(0),
            "Permission err"
        );

        incomeIsland = IIncomeisland(
            0x662C50E0fE75Bd5Bf19dc3591Ab54526fF327422
        );
        utility = IUtility(0xF874b7702A73A064f12D00CD3124f15AB552f1Fa);
        transfer = ITransfer(0x66C9B437bA4C4a308bB64dedaA065a24096269F0);
        _ownerAddress = 0x775Dd9d922B48C42C34b88811C97863Ad894eCf9;
        incomeToken = IERC20(0x3a91A88Ef4bB813BB99EF5a745bcb56e3A3b403b);

        stakingHistoryLength = 0;
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