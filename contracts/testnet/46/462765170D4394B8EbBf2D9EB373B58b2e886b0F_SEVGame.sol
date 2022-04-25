// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface INFTCore {
    function exists(uint256 _id) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function evolve(uint256[] memory _nftIds, uint256 _newGene)
        external
        returns (uint256);

    function breed(
        address _toAddress,
        uint256 _nftId1,
        uint256 _nftId2,
        uint256 _gene
    ) external returns (uint256);
}

contract SEVGame is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UserActive {
        address user;
        uint256 time;
        bool isLockEvolve;
    }

    struct UserRequest {
        address user;
        bool isEvolve;
        // address nft;
        uint256[] nftIds;
    }

    struct Fee {
        IERC20 currency;
        uint256 amount;
    }

    struct NFT {
        mapping(uint256 => UserActive) idToNfts;
        mapping(uint256 => UserRequest) idToRequests;
        uint256 durationActive;
        Fee[] fees; // 0: active 1: deactive 2: breed 3: evolve
        bool valid;
    }

    mapping(address => NFT) nfts;

    uint256 public currentRequestId;

    mapping(address => bool) whilelists;

    address public vault;

    event Active(
        address nftAddress,
        uint256 nftId,
        address user,
        address feeContract,
        uint256 feeAmount,
        uint256 time
    );
    event Deactive(
        address nftAddress,
        uint256 nftId,
        address user,
        uint256 time
    );

    constructor(address _vault) {
        require(_vault != address(0), "Error: Vault invalid");

        vault = _vault;
    }

    modifier onlyWhilelist() {
        require(whilelists[_msgSender()], "Error: only whilelist");
        _;
    }

    function setWhilelists(
        address[] memory _whilelists,
        bool[] memory _isWhilelists
    ) external onlyOwner {
        require(
            _whilelists.length == _isWhilelists.length,
            "Error: invalid input"
        );
        for (uint8 i = 0; i < _whilelists.length; i++) {
            whilelists[_whilelists[i]] = _isWhilelists[i];
        }
    }

    event SetNFT(
        address nftAddress,
        uint256 durationActive,
        IERC20[]  currencies,
        uint256[]  amounts,
        bool valid
    );

    function setNFT(
        address _nftAddress,
        uint256 _durationActive,
        IERC20[] memory _currencies,
        uint256[] memory _amounts,
        bool _valid
    ) external onlyOwner {
        require(address(_nftAddress) != address(0), "Error: NFT address(0)");
        require(_currencies.length == 4, "Error: currencies invalid");
        require(
            _currencies.length == _amounts.length,
            "Error: currencies invalid"
        );

        nfts[_nftAddress].durationActive = _durationActive;
        for (uint8 i = 0; i < _currencies.length; i++) {
            nfts[_nftAddress].fees.push(Fee(_currencies[i], _amounts[i]));
        }
        nfts[_nftAddress].valid = _valid;

        emit SetNFT(_nftAddress, _durationActive, _currencies, _amounts, _valid);
    }

    function getNFTInfo(address _nftAddress)
        external
        view
        returns (
            uint256,
            address[] memory,
            uint256[] memory,
            bool
        )
    {
        uint256 feeLength = nfts[_nftAddress].fees.length;
        address[] memory currencies = new address[](feeLength);
        uint256[] memory amounts = new uint256[](feeLength);

        for (uint256 i = 0; i < feeLength; i++) {
            currencies[i] = address(nfts[_nftAddress].fees[i].currency);
            amounts[i] = nfts[_nftAddress].fees[i].amount;
        }

        return (
            nfts[_nftAddress].durationActive,
            currencies,
            amounts,
            nfts[_nftAddress].valid
        );
    }

    function setVault(address _vault) external onlyOwner {
        require(_vault != address(0), "Error: Vault address(0)");
        vault = _vault;
    }

    function active(address _nftAddress, uint256 _nftId)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        require(nfts[_nftAddress].valid, "Error: NFT contract invalid");

        require(INFTCore(_nftAddress).exists(_nftId), "Error: wrong nftId");
        require(
            INFTCore(_nftAddress).ownerOf(_nftId) == _msgSender(),
            "Error: you are not the owner"
        );

        //check active duration
        if (nfts[_nftAddress].idToNfts[_nftId].user != address(0)) {
            require(
                nfts[_nftAddress].idToNfts[_nftId].time - block.timestamp >=
                    nfts[_nftAddress].durationActive,
                "Error: wait to active"
            );
        }

        //transfer NFT for market contract
        INFTCore(_nftAddress).transferFrom(_msgSender(), address(this), _nftId);
        nfts[_nftAddress].idToNfts[_nftId].user = _msgSender();
        nfts[_nftAddress].idToNfts[_nftId].time = block.timestamp;

        //charge fee
        Fee memory fee = nfts[_nftAddress].fees[0];
        if (fee.amount > 0) {
            if (address(fee.currency) == address(0)) {
                payable(vault).transfer(fee.amount);
                //transfer BNB back to user if amount > fee
                if (msg.value > fee.amount) {
                    payable(_msgSender()).transfer(msg.value - fee.amount);
                }
            } else {
                fee.currency.safeTransferFrom(_msgSender(), vault, fee.amount);
                //transfer BNB back to user if currency is not address(0)
                if (msg.value != 0) {
                    payable(_msgSender()).transfer(msg.value);
                }
            }
        }

        emit Active(
            _nftAddress,
            _nftId,
            _msgSender(),
            address(fee.currency),
            fee.amount,
            block.timestamp
        );
    }

    function deactive(address _nftAddress, uint256 _nftId)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        require(nfts[_nftAddress].valid, "Error: NFT contract invalid");

        require(
            nfts[_nftAddress].idToNfts[_nftId].user == _msgSender(),
            "Error: you are not the owner"
        );
        require(
            !nfts[_nftAddress].idToNfts[_nftId].isLockEvolve,
            "Error: lock for evolve"
        );

        //transfer NFT for market contract
        INFTCore(_nftAddress).transferFrom(address(this), _msgSender(), _nftId);
        delete nfts[_nftAddress].idToNfts[_nftId];
        //charge fee
        Fee memory fee = nfts[_nftAddress].fees[1];
        if (fee.amount > 0) {
            if (address(fee.currency) == address(0)) {
                payable(vault).transfer(fee.amount);
                //transfer BNB back to user if amount > fee
                if (msg.value > fee.amount) {
                    payable(_msgSender()).transfer(msg.value - fee.amount);
                }
            } else {
                fee.currency.safeTransferFrom(_msgSender(), vault, fee.amount);
                //transfer BNB back to user if currency is not address(0)
                if (msg.value != 0) {
                    payable(_msgSender()).transfer(msg.value);
                }
            }
        }

        emit Deactive(_nftAddress, _nftId, _msgSender(), block.timestamp);
    }

    event BreedRequest(
        address user,
        uint256 id,
        address nft,
        uint256[] nftIds,
        uint256 time
    );

    function breedRequest(address _nftAddress, uint256[] memory _nftIds)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        require(nfts[_nftAddress].valid, "Error: NFT contract invalid");
        require(_nftIds.length == 2, "Error: NFT ids invalid");

        require(
            INFTCore(_nftAddress).ownerOf(_nftIds[0]) == _msgSender(),
            "Error: you are not the owner"
        );

        require(
            INFTCore(_nftAddress).ownerOf(_nftIds[1]) == _msgSender(),
            "Error: you are not the owner"
        );

        INFTCore(_nftAddress).transferFrom(
            _msgSender(),
            address(this),
            _nftIds[0]
        );
        INFTCore(_nftAddress).transferFrom(
            _msgSender(),
            address(this),
            _nftIds[1]
        );

        nfts[_nftAddress].idToRequests[currentRequestId] = UserRequest(
            _msgSender(),
            false,
            // _nftAddress,
            _nftIds
        );

        //charge fee
        Fee memory fee = nfts[_nftAddress].fees[3];
        if (fee.amount > 0) {
            if (address(fee.currency) == address(0)) {
                payable(vault).transfer(fee.amount);
                //transfer BNB back to user if amount > fee
                if (msg.value > fee.amount) {
                    payable(_msgSender()).transfer(msg.value - fee.amount);
                }
            } else {
                fee.currency.safeTransferFrom(_msgSender(), vault, fee.amount);
                //transfer BNB back to user if currency is not address(0)
                if (msg.value != 0) {
                    payable(_msgSender()).transfer(msg.value);
                }
            }
        }
        emit BreedRequest(
            _msgSender(),
            currentRequestId,
            _nftAddress,
            _nftIds,
            block.timestamp
        );

        currentRequestId += 1;
    }

    event BreedProcess(
        uint256 requestId,
        address user,
        address nft,
        uint256[] nftIds,
        uint256 newNftId,
        uint256 time
    );

    function breedProcess(
        address _nftAddress,
        uint256 _requestId,
        uint256 _newGene
    ) external payable onlyWhilelist {
        UserRequest memory request = nfts[_nftAddress].idToRequests[_requestId];
        require(request.user != address(0), "Error: request invalid");

        require(!request.isEvolve, "Error: request invalid");

        uint256 newNftId = INFTCore(_nftAddress).breed(
            request.user,
            request.nftIds[0],
            request.nftIds[1],
            _newGene
        );

        INFTCore(_nftAddress).transferFrom(
            address(this),
            request.user,
            request.nftIds[0]
        );
        INFTCore(_nftAddress).transferFrom(
            address(this),
            request.user,
            request.nftIds[1]
        );

        emit BreedProcess(
            _requestId,
            request.user,
            _nftAddress,
            request.nftIds,
            newNftId,
            block.timestamp
        );

        delete nfts[_nftAddress].idToRequests[_requestId];
    }

    event EvolveRequest(
        address user,
        uint256 requestId,
        address nft,
        uint256[] nftIds,
        uint256 time
    );

    function evolveRequest(address _nftAddress, uint256[] memory _nftIds)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        require(nfts[_nftAddress].valid, "Error: NFT contract invalid");

        for (uint256 i = 0; i < _nftIds.length; i++) {
            require(
                nfts[_nftAddress].idToNfts[_nftIds[i]].user == _msgSender(),
                "Error: you are not the owner"
            );
            require(
                !nfts[_nftAddress].idToNfts[_nftIds[i]].isLockEvolve,
                "Error: lock for evolve already"
            );
        }

        for (uint256 i = 0; i < _nftIds.length; i++) {
            nfts[_nftAddress].idToNfts[_nftIds[i]].isLockEvolve = true;
        }

        nfts[_nftAddress].idToRequests[currentRequestId] = UserRequest(
            _msgSender(),
            true,
            // _nftAddress,
            _nftIds
        );

        //charge fee
        Fee memory fee = nfts[_nftAddress].fees[4];
        if (fee.amount > 0) {
            if (address(fee.currency) == address(0)) {
                payable(vault).transfer(fee.amount);
                //transfer BNB back to user if amount > fee
                if (msg.value > fee.amount) {
                    payable(_msgSender()).transfer(msg.value - fee.amount);
                }
            } else {
                fee.currency.safeTransferFrom(_msgSender(), vault, fee.amount);
                //transfer BNB back to user if currency is not address(0)
                if (msg.value != 0) {
                    payable(_msgSender()).transfer(msg.value);
                }
            }
        }

        emit EvolveRequest(
            _msgSender(),
            currentRequestId,
            _nftAddress,
            _nftIds,
            block.timestamp
        );

        currentRequestId += 1;
    }

    event EvolveProcess(
        uint256 requestId,
        address user,
        address nft,
        uint256[] nftIds,
        uint256 newNftId,
        uint256 time
    );

    function evolveProcess(
        address _nftAddress,
        uint256 _requestId,
        uint256 _newGene
    ) external onlyWhilelist {
        UserRequest memory request = nfts[_nftAddress].idToRequests[_requestId];
        require(request.user != address(0), "Error: request invalid");

        require(request.isEvolve, "Error: request invalid");

        uint256 newId = INFTCore(_nftAddress).evolve(request.nftIds, _newGene);

        emit EvolveProcess(
            _requestId,
            request.user,
            _nftAddress,
            request.nftIds,
            newId,
            block.timestamp
        );

        delete nfts[_nftAddress].idToRequests[_requestId];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}