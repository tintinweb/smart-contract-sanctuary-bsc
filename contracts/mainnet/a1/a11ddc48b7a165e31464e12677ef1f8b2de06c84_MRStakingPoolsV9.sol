/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^ 0.8.7;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function claim() external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount, uint poolNo) external;

    function deposit(uint256 amount) external;

    function process(uint256 gas, uint poolNo) external;

    function purge(address receiver, uint256 amount) external;
}

contract DDStakingPool is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 public REWARD;

    address[] shareholders;
    mapping(address => mapping(uint => uint256)) shareholderIndexes;
    mapping(address => mapping(uint => uint256)) shareholderClaims;

    mapping(address => mapping(uint => Share)) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;
    mapping(uint => uint256) private totalPoolDistributed;

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10**9);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address rewardToken) {
        _token = msg.sender;
        REWARD = IERC20(rewardToken);
    }

    receive() external payable {}

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function purge(address receiver, uint256 amount) external override onlyToken {
        REWARD.transfer(receiver, amount);
    }

    function setShare(address shareholder, uint256 amount, uint poolNo)
        external
        override
        onlyToken
    {
        if (shares[shareholder][poolNo].amount > 0) {
            distributeDividend(shareholder, poolNo);
        }

        if (amount > 0 && shares[shareholder][poolNo].amount == 0) {
            addShareholder(shareholder, poolNo);
        } else if (amount == 0 && shares[shareholder][poolNo].amount > 0) {
            removeShareholder(shareholder, poolNo);
        }

        totalShares = totalShares.sub(shares[shareholder][poolNo].amount).add(amount);
        shares[shareholder][poolNo].amount = amount;
        shares[shareholder][poolNo].totalExcluded = getCumulativeDividends(
            shares[shareholder][poolNo].amount
        );
    }

    function deposit(uint256 amount) external override onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas, uint poolNo) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex], poolNo)) {
                distributeDividend(shareholders[currentIndex], poolNo);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder, uint poolNo)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder][poolNo] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder, poolNo) > minDistribution;
    }

    function distributeDividend(address shareholder, uint poolNo) internal {
        if (shares[shareholder][poolNo].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder, poolNo);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            totalPoolDistributed[poolNo] = totalPoolDistributed[poolNo].add(amount);
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder][poolNo] = block.timestamp;
            shares[shareholder][poolNo].totalRealised = shares[shareholder][poolNo]
                .totalRealised
                .add(amount);
            shares[shareholder][poolNo].totalExcluded = getCumulativeDividends(
                shares[shareholder][poolNo].amount
            );
        }
    }

    function claimDividend(uint poolNo) external {
        distributeDividend(msg.sender, poolNo);
    }

    function getUnpaidEarnings(address shareholder, uint poolNo)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder][poolNo].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder][poolNo].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder][poolNo].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getHolderDetails(address holder, uint poolNo)
        public
        view
        returns (
            uint256 lastClaim,
            uint256 unpaidEarning,
            uint256 totalReward,
            uint256 holderIndex
        )
    {
        lastClaim = shareholderClaims[holder][poolNo];
        unpaidEarning = getUnpaidEarnings(holder, poolNo);
        totalReward = shares[holder][poolNo].totalRealised;
        holderIndex = shareholderIndexes[holder][poolNo];
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return currentIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return shareholders.length;
    }
    
    function getShareHoldersList() external view returns (address[] memory) {
        return shareholders;
    }
    
    function totalDistributedRewards() external view returns (uint256) {
        return totalDistributed;
    }

    function totalDistributedPools(uint poolNo) external view returns(uint256){
        return totalPoolDistributed[poolNo];
    }


    function addShareholder(address shareholder, uint poolNo) internal {
        shareholderIndexes[shareholder][poolNo] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder, uint poolNo) internal {
        shareholders[shareholderIndexes[shareholder][poolNo]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]][poolNo] = shareholderIndexes[shareholder][poolNo];
        shareholders.pop();
    }
}

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

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

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


library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}


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

contract MRLandSale is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    IERC20 public token;
    address public landSaleWallet = 0xb226f30904CE65730aD4A586d6a9171710D35583;

    uint256 public MAX_SUPPLY = 150000;
    uint256 public finalMintAmount = 1000;
    uint256 public PRICE = 1 * 10**6 * 10**18;
   

    bool public openPrivatesale = false;
    bool public openPresale = false;
    bool public openPublicsale = false;
    

    uint256 public constant MAX_PER_MINT = 20;
    mapping(address => bool) public whitelists;
    mapping(address => uint256) public privateMintAmount;
    mapping(address => uint256) public presaleMintAmount;
    string public baseTokenURI;
    string public mdata;

    constructor(string memory baseURI, IERC20 token_, string memory mdata_) ERC721("Meta Ruffy Mystery Land", "MRML") {
        setBaseURI(baseURI);
        token = token_;
        mdata = mdata_;
        whitelists[msg.sender] = true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, mdata, ".json"))
                : "";
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function mint(uint256 _count) public payable {
        uint256 totalMinted = _tokenIdTracker.current();
        require(totalMinted.add(_count) <= finalMintAmount, "Landsale: Not enough NFTs!");
        require(openPrivatesale || openPresale || openPublicsale, "Landsale: minting is either paused or not yet opened.");

        if(openPrivatesale && msg.sender != owner()){
            require(whitelists[_msgSender()], "Landsale: wallet is not whitelisted.");
            require(privateMintAmount[_msgSender()].add(_count) <= MAX_PER_MINT, "Landsale: maximum wallet mint amount");
            privateMintAmount[_msgSender()] = privateMintAmount[_msgSender()].add(_count);
        }

        if(openPresale && msg.sender != owner()){
            presaleMintAmount[_msgSender()] = presaleMintAmount[_msgSender()].add(_count);
        }

        if(msg.sender != owner()){
            uint256 totalPrice = PRICE.mul(_count);
            require(_count > 0 && _count <= MAX_PER_MINT,"Landsale: Cannot mint specified number of NFTs.");
            require(token.allowance(_msgSender(), address(this)) >= totalPrice, "Landsale: plase approve us to spend you MR tokens");
            token.transferFrom(_msgSender(), landSaleWallet, totalPrice);
        }
        
        for (uint256 i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function _mintSingleNFT() private {
        _tokenIdTracker.increment();
        uint256 newTokenID = _tokenIdTracker.current();
        _safeMint(msg.sender, newTokenID);
    }

    function tokensOfOwner(address _owner) external view returns (uint256[] memory){
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    function claimTokens() public onlyOwner {
        token.transfer(_msgSender(), token.balanceOf(address(this)));
    }

    function updateToken(IERC20 newToken_) public onlyOwner {
        token = newToken_;
    }

    function transferNFT(uint256 tokenId, address to) public {
        safeTransferFrom(msg.sender, to, tokenId);
    }

    function updatePrices(uint256 newPrice) public onlyOwner {
        PRICE = newPrice;
    }

    function updateWhitelist(address[] memory addresses) public onlyOwner{
        for(uint256 i; i < addresses.length; i++) {
            require(addresses[i] !=  address(0), "Landsale: array has a zero address.");
            whitelists[addresses[i]] = true;
        }
    }

    function addWhitelist(address newAddress) public onlyOwner {
        require(newAddress != address(0), "Landsale: whitelist address is zero.");
        whitelists[newAddress] = true; 
    }

    function removeWhitelist(address newAddress) public onlyOwner {
        whitelists[newAddress] = false;
    }

    function updateOpenstatus(bool privateSaleStatus, bool preSaleStatus, bool publicSaleStatus) public onlyOwner {
        openPrivatesale = privateSaleStatus;
        openPresale = preSaleStatus;
        openPublicsale = publicSaleStatus;
    }

    function updateMintUpto(uint256 newMintUpto) public onlyOwner {
        require(newMintUpto <= MAX_SUPPLY, "Landsale: Can not be more than max supply");
        finalMintAmount = newMintUpto;
    }

    function updateMDataName(string memory mdata_) public onlyOwner {
        mdata = mdata_;
    }
}


contract MRStakingPoolsV9 is Context, Ownable, IERC721Receiver {
    using SafeMath for uint256;

    struct Pool {
        uint8 pool;
        string rarity;
        uint256 stakeSize;
        uint256 minStake;
        uint256 apyNoLock;
        uint256 apyHalfLock;
        uint256 apyFullLock;
        uint256 apyTotalLock;
    }

    struct Staker {
        address wallet;
        uint poolNo;
        uint256 amount;
        uint256 apyTime;
        uint256 timeStakedFor;
        uint256 stakeTime; 
    }

    struct LockCount {
        uint256 noLockCount;
        uint256 halfLockCount;
        uint256 fullLockCount;
        uint256 totalLockCount;
        uint256 noLockTotal;
        uint256 halfLockTotal;
        uint256 fullLockTotal;
        uint256 totalLockTotal;
        uint256 totalInPool;
    }

    uint256 public noLock = 0;
    uint256 public halfLock = 30 days;
    uint256 public fullLock = 90 days;
    uint256 public totalLock = 180 days;

    bool public enableMultipool = false;

    IERC20 private _token;
    IERC20 private _rewardToken;
    DDStakingPool public dividendDistributor;
    uint256 distributorGas = 500000;

    mapping(uint => uint256) public poolShare;
    mapping(address => mapping(uint => uint256)) private walletClaimed;
    mapping(address => mapping(uint => uint256)) private walletClaimedRewardToken;
    mapping(uint => uint256) public totalTokenClaimed;
    mapping(uint => uint256) public totalRewardTokenClaimed;
    mapping(uint => uint256) public totalReinvested;
    mapping(address => mapping(uint => bool)) public hasMigrated;

    mapping(address => bool) public isExcludedFromTax;

    mapping(uint => LockCount) lockCounts;



    uint256 public calculationTime = 365 days;
    uint256 public taxPayable = 10;
    bool public isTaxPayable = true;
    uint256 public minThreshold = 100 * 10**18; // 6k token


    mapping(address => mapping(uint => Staker)) public stakers;
    mapping(address => mapping(uint => bool)) private isStaker;
    mapping(uint => Pool) public pools;
    mapping(uint => uint256) public stakingSize;

    mapping(uint => uint256) public tPoolStakedSize;

    uint[] public activePoolsArray;
    event Deposit(address indexed wallet, uint pool, uint256 amount);
    event WithdrawStaking(address indexed wallet, uint pool, uint256 amount);
    event WithdrawReturn(address indexed wallet, uint pool, uint256 amount);
    event ReinvestReturn(address indexed wallet, uint pool, uint256 amount);
    event PoolUpdated(uint poolNo, uint256 time);
    event RewardTokenWithdraw(address indexed to, uint256 amount);
    address public migrator;
    bool public openStaking = false;
    bool public canReinvest = false;

    uint256 public mintPriceAdjust = 1 * 10**6 * 10**18;



    MRLandSale public landSaleContract = MRLandSale(0xf97199f79cA6677C3bAa20a48320029bA9264b08);

    modifier onlyStakingIsOpen() {
        require(openStaking, "MRStaking: staking is not open yet.");
        _;
    }

    modifier onlyMigrator() {
        require(_msgSender() == migrator, "Migrator: caller is not the migrator.");
        _;
    }

    constructor(IERC20 token_, IERC20 rewardToken_) {
        _token = token_;
        _rewardToken = rewardToken_;
        dividendDistributor = new DDStakingPool(address(rewardToken_));
        isExcludedFromTax[_msgSender()] = true;      
    }

    function deployNewPool(uint8 poolNo_, string memory name,  uint256 minStake_, uint256 apyNoLock, uint256 apyHalfLock, uint256 apyFullLock, uint256 apyTotalLock, uint256 maxStakers) public onlyOwner {
        require(pools[poolNo_].pool == 0, "Pool already present.");
        pools[poolNo_] = Pool(poolNo_, name, maxStakers, minStake_, apyNoLock, apyHalfLock, apyFullLock, apyTotalLock );
        if(!checkIfPoolInArray(poolNo_)) {
            activePoolsArray.push(poolNo_);
        }
    }

    

    function checkIfPoolInArray(uint poolNo) internal view returns(bool){
        bool isPoolInArray;
        for(uint i; i < activePoolsArray.length; i++){
            if(activePoolsArray[i] == poolNo) {
                isPoolInArray = true;
                break;
            }
        }

        return isPoolInArray;
    }

    function getTokenInfo() public view returns(address, address){
        return (address(_token), address(_rewardToken));
    }

    function updateTokens(IERC20 token_, IERC20 rewardToken_) public onlyOwner {
        _token = token_;
        _rewardToken = rewardToken_;
    }

    function claimDividend() public onlyOwner {
        _token.claim();
    }

    function random() internal returns (uint) {
        uint randomness = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.timestamp))) % 100000;
        uint randomnumber = randomness % activePoolsArray.length;
        
        if(stakingSize[activePoolsArray[randomnumber]] >= pools[activePoolsArray[randomnumber]].stakeSize){
            activePoolsArray[randomnumber] = activePoolsArray[activePoolsArray.length - 1];
            activePoolsArray.pop();
            randomnumber = random();
        }

        return randomnumber;
    }

    function deposit(uint256 amount, uint256 apyTime, uint type_) external onlyStakingIsOpen{
        uint poolNo = enableMultipool ? type_: 1;
        uint ran = 0;
        uint256 initialApy = 0;
        uint256 initialAmount = 0;
        uint256 rAmount = 0;
        bool hasStaked = false;
        
        if(_msgSender() != owner()) {
            if(enableMultipool) {
                require(activePoolsArray.length > 0, "Sorry! All the pools are filled.");
                ran = random();
                poolNo = activePoolsArray[ran]; 
            }
        }

        require(pools[poolNo].pool != 0,"Sorry pool is not set yet.");

        if(pools[poolNo].stakeSize != 0 && _msgSender() != owner()) {
            require(stakingSize[poolNo] < pools[poolNo].stakeSize, "Pool size reached.");
        }

        require(amount >= pools[poolNo].minStake, "Can not be less than minimum staking size.");
        require(_token.allowance(_msgSender(), address(this)) >= amount, "Please approve the amount to spend us.");
        
        _token.transferFrom(_msgSender(), address(this), amount);


        if(!isExcludedFromTax[_msgSender()]) {
            uint256 depositTax = amount.mul(taxPayable).div(10**2);
            amount = amount.sub(depositTax);
        }

        Staker memory staker = stakers[_msgSender()][poolNo];

        hasStaked = isStaker[_msgSender()][poolNo];

        if(staker.amount != 0 && hasStaked) {
            rAmount = calculateReturn(_msgSender(), poolNo);
            initialApy = staker.apyTime;
            initialAmount = staker.amount;
        }

        poolShare[poolNo] += amount;
        amount = amount.add(rAmount);
        staker.wallet = _msgSender();
        staker.poolNo = poolNo;
        staker.amount = staker.amount.add(amount);
        staker.apyTime = staker.apyTime > apyTime ? staker.apyTime : apyTime;
        staker.timeStakedFor = staker.timeStakedFor > block.timestamp ? staker.timeStakedFor : _stakeTimes(apyTime);
        staker.stakeTime = block.timestamp;

        stakers[_msgSender()][poolNo] = staker;

        uint256 rBalance = _rewardToken.balanceOf(address(this));

        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance); 
        }
        
        dividendDistributor.setShare(_msgSender(), staker.amount, poolNo);
        
        if(!hasStaked){
            addLockCount(poolNo, apyTime, amount);
            stakingSize[poolNo] += 1; 
        } else {
            uint256 tAmount = amount.add(initialAmount).sub(rAmount);
            if(initialApy > apyTime) {
                apyTime = initialApy;
            }
            subLockCount(poolNo, initialApy, initialAmount);
            addLockCount(poolNo, apyTime, tAmount);
        }

        isStaker[_msgSender()][poolNo] = true;

        if(stakingSize[poolNo] >= pools[poolNo].stakeSize){
            activePoolsArray[ran] = activePoolsArray[activePoolsArray.length - 1];
            activePoolsArray.pop();
        }

        emit Deposit(_msgSender(), poolNo, amount);
    }

    function refillPool(uint poolNo_, uint256 amount) external {
        poolNo_ = enableMultipool ? poolNo_ : 1;
        Staker memory staker = stakers[_msgSender()][poolNo_];
        require(staker.amount != 0, "User has no staking");
        require(_token.allowance(_msgSender(), address(this)) >= amount, "Please approve the amount to spend us.");
        
        _token.transferFrom(_msgSender(), address(this), amount);

        if(!isExcludedFromTax[_msgSender()]) {
            uint256 depositTax = amount.mul(taxPayable).div(10**2);
            amount = amount.sub(depositTax);
        }
        subLockCount(poolNo_, staker.apyTime, staker.amount);
        poolShare[poolNo_] += amount;
        staker.amount = staker.amount.add(amount);
        staker.stakeTime = block.timestamp;
        stakers[_msgSender()][poolNo_] = staker;

        addLockCount(poolNo_, staker.apyTime, staker.amount);
        uint256 rBalance = _rewardToken.balanceOf(address(this));
        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance); 
        }
        
        dividendDistributor.setShare(_msgSender(), staker.amount, poolNo_);
    }

    function _stakeTimes(uint256 apyTime) internal view returns(uint256){
        uint256 stakeTimes;
        if(apyTime == 0) {stakeTimes = block.timestamp;}
        if(apyTime == 1) {stakeTimes = block.timestamp.add(halfLock);}
        if(apyTime == 2) {stakeTimes = block.timestamp.add(fullLock);}
        if(apyTime == 3) {stakeTimes = block.timestamp.add(totalLock);}
        return stakeTimes;
    }

    function _getLockPeriod(uint256 apyTime_) internal view returns(uint256){
        if(apyTime_ == 1) return halfLock;
        if(apyTime_ == 2) return fullLock;
        if(apyTime_ == 3) return totalLock;
        return noLock;
    }

    function getUserLockPeriod(address account, uint256 poolNo) external view returns(uint256){
        poolNo = enableMultipool ? poolNo : 1;
        Staker memory staker = stakers[account][poolNo];
        uint256 lockTime_ = _getLockPeriod(staker.apyTime);
        return staker.stakeTime.add(lockTime_);
    }

    function calculateReturn(address account, uint poolNo) public view returns(uint256 amount){
        poolNo = enableMultipool ? poolNo : 1;

        Staker memory staker = stakers[account][poolNo];
        
        Pool memory pool = pools[poolNo];

        if(staker.amount == 0) return 0;
                
        uint256 apy;
        
        uint256 timeSpan = block.timestamp.sub(staker.stakeTime);

        if(staker.apyTime == 0) {apy = pool.apyNoLock;}
        if(staker.apyTime == 1) {apy = pool.apyHalfLock;}
        if(staker.apyTime == 2) {apy = pool.apyFullLock;}
        if(staker.apyTime == 3) {apy = pool.apyTotalLock;}

        amount = staker.amount.mul(apy).mul(timeSpan).div(calculationTime).div(10**2);
    }

    function claimStaking(uint poolNo) external {
        poolNo = enableMultipool ? poolNo : 1;
        Staker memory staker = stakers[_msgSender()][poolNo];
        require(staker.amount != 0, "Sorry! you have not staked anything.");
        require(block.timestamp >= staker.stakeTime.add(_getLockPeriod(staker.apyTime)), "Sorry!, staking period not finished.");
        require(isStaker[_msgSender()][poolNo], "Caller is not a staker.");
        uint256 amountToWithdraw = staker.amount;

        if(poolShare[poolNo] >= amountToWithdraw) {
            poolShare[poolNo] = poolShare[poolNo].sub(amountToWithdraw);
        } else {
            poolShare[poolNo] = 0;
        }
    
        _token.transfer(_msgSender(), amountToWithdraw);
        
        _claimReturn(_msgSender(), poolNo);

        dividendDistributor.setShare(_msgSender(), 0, poolNo);

        _updateStakingSize(poolNo);
        isStaker[_msgSender()][poolNo] = false;
        delete(stakers[_msgSender()][poolNo]);
        if(!checkIfPoolInArray(poolNo)){
            activePoolsArray.push(poolNo);
        }
        subLockCount(poolNo, staker.apyTime, amountToWithdraw);
        emit WithdrawStaking(_msgSender(), poolNo, amountToWithdraw);
    }

    function claimReturn(uint poolNo) public {
        poolNo = enableMultipool ? poolNo : 1;
        _claimReturn(_msgSender(), poolNo);
    }

    function _claimReturn(address account, uint poolNo) internal {
        poolNo = enableMultipool ? poolNo : 1;
        Staker memory staker = stakers[account][poolNo];

        require(block.timestamp >= staker.stakeTime.add(_getLockPeriod(staker.apyTime)), "Staking: staking period is not over yet.");
        
        uint256 returnAmount = calculateReturn(account, poolNo);
        staker.apyTime = 0;
        staker.stakeTime = block.timestamp;

        walletClaimed[account][poolNo] += returnAmount;
        _token.transfer(account, returnAmount);
        poolShare[poolNo] = (poolShare[poolNo] >= returnAmount) ? poolShare[poolNo].sub(returnAmount) : 0;

        totalTokenClaimed[poolNo] = totalTokenClaimed[poolNo].add(returnAmount);

        uint256 rBalance = _rewardToken.balanceOf(address(this));
        
        stakers[account][poolNo] = staker;
        
        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance);
        }

        emit WithdrawReturn(account, poolNo, returnAmount);
    }

    function reinvestReturn(uint poolNo) public  {
        poolNo = enableMultipool ? poolNo : 1;
        require(canReinvest, "MRStaking: Reinvesting is disabled.");
        Staker memory staker = stakers[_msgSender()][poolNo];
        require(staker.amount > 0, "Sorry! you have not staked anything.");
        require(block.timestamp >= staker.stakeTime.add(_getLockPeriod(staker.apyTime)), "Staking: staking period is not over yet.");
        uint256 returnAmount = calculateReturn(_msgSender(), poolNo);

        subLockCount(poolNo, staker.apyTime, staker.amount);
        staker.amount += returnAmount;
        staker.stakeTime = block.timestamp;
        staker.apyTime = 0;
        stakers[_msgSender()][poolNo] = staker;

        poolShare[poolNo] += returnAmount;
        
        addLockCount(poolNo, staker.apyTime, staker.amount);

        uint256 rBalance = _rewardToken.balanceOf(address(this));
        
        dividendDistributor.setShare(_msgSender(), staker.amount, poolNo);
        
        if(rBalance >= minThreshold) {
            _rewardToken.transfer(address(dividendDistributor), rBalance);
            dividendDistributor.deposit(rBalance); 
        }


        totalReinvested[poolNo] = totalReinvested[poolNo].add(returnAmount);
        emit ReinvestReturn(_msgSender(), poolNo, returnAmount);
    }

    function updatePool(uint8 poolNo_, string memory rarity_, uint256 stakeSize_, uint256 minStake_, uint256 apyNoLock_, uint256 apyHalfLock, uint256 apyFullLock, uint256 apyTotalLock) public onlyOwner {
        poolNo_ = enableMultipool ? poolNo_ : 1;

        Pool memory pool = pools[poolNo_];
        
        pool.pool = poolNo_;
        pool.rarity = rarity_;
        pool.stakeSize = stakeSize_;
        pool.minStake = minStake_;
        pool.apyNoLock = apyNoLock_;
        pool.apyHalfLock = apyHalfLock;
        pool.apyFullLock = apyFullLock;
        pool.apyTotalLock = apyTotalLock;

        if(stakeSize_ > pools[poolNo_].stakeSize) {
            if(!checkIfPoolInArray(poolNo_)){
                activePoolsArray.push(poolNo_);
            }
        }
        
        pools[poolNo_] = pool;
        emit PoolUpdated(poolNo_, block.timestamp);
    }

    function totalStakers(uint poolNo) public view returns(uint256){
        return stakingSize[poolNo];
    }

    function isWalletStaker(address account, uint poolNo) external view returns(bool) {
        return isStaker[account][poolNo];
    }

    function _updateStakingSize(uint poolNo) internal {
        poolNo = enableMultipool ? poolNo : 1;
        if(stakingSize[poolNo] >=1 ) {
            stakingSize[poolNo] = stakingSize[poolNo] - 1;
        }
    }
    
    function sendToken(address recipient, uint256 amount) public onlyOwner {
        _token.transfer(recipient, amount);
    }

    function claimTokens(address recipient, uint256 amount) public onlyOwner {
        _rewardToken.transfer(recipient, amount);
    }

    function claimBNB(address payable account) public onlyOwner {
        account.transfer(address(this).balance);
    }

    function totalPoolStakers(uint poolNo) public view returns(uint256){
        return stakingSize[poolNo];
    }

    function totalTokenClaimedByWallet(address account, uint poolNo) public view returns(uint256){
        return walletClaimed[account][poolNo];
    }

    function getStakerInfo(address account, uint poolNo) public view returns(Staker memory) {
        return stakers[account][poolNo];
    }

    function isReturnClaimable(address account, uint poolNo) public view returns(bool isTokenClaimable) {
        isTokenClaimable = _token.balanceOf(address(this)) >= calculateReturn(account, poolNo);
    }

    function updateTaxPayable(uint256 newTax) public onlyOwner {
        taxPayable = newTax;
    }

    function updateIsTaxPayable(bool payable_) public onlyOwner {
        isTaxPayable = payable_;
    }

    function updateMinThreshold(uint256 newThreshold) public onlyOwner {
        minThreshold = newThreshold;
    }

    function distributeDividends() public onlyOwner {
        uint256 rBalance = _rewardToken.balanceOf(address(this));
        _rewardToken.transfer(address(dividendDistributor), rBalance);
        dividendDistributor.deposit(rBalance); 
    }

    function purgeRewardToken(address recipient, uint256 amount) public onlyOwner {
        dividendDistributor.purge(recipient, amount);
    }

    function updateStakingPeriods(uint256 halfLock_, uint256 fullLock_, uint256 totalLock_) external onlyOwner {
        require(halfLock_ <= 30 days, "MRStaking: should be less than 30 days");
        require(fullLock_ <= 90 days, "MRStaking: should be less than 90 days");
        require(totalLock_ <= 180 days, "MRStaking: should be less than 120 days");
        halfLock = halfLock_;
        fullLock = fullLock_;
        totalLock = totalLock_;
    }

    function activePoolsCount() public view returns(uint256){
        return activePoolsArray.length;
    }

    function addLockCount(uint poolNo, uint256 apy, uint256 amount) internal {
        LockCount memory lockCount = lockCounts[poolNo];
        if(apy == 0) { lockCount.noLockCount += 1; lockCount.noLockTotal += amount; }
        if(apy == 1) { lockCount.halfLockCount += 1; lockCount.halfLockTotal += amount;}
        if(apy == 2) { lockCount.fullLockCount += 1; lockCount.fullLockTotal += amount;}
        if(apy == 3) { lockCount.totalLockCount += 1; lockCount.totalLockTotal += amount;}
        lockCount.totalInPool += amount;
        lockCounts[poolNo] = lockCount;
    }

    function updateLockCount(uint poolNo, uint256 initialApy, uint256 apy, uint256 initialAmount, uint256 amount) internal {
        if(initialApy > apy) {
            apy = initialApy;
        }
        subLockCount(poolNo, initialApy, initialAmount);
        addLockCount(poolNo, apy, amount.add(initialAmount));
    }

    function subLockCount(uint poolNo, uint256 apy, uint256 amount) internal {
        LockCount memory lockCount = lockCounts[poolNo];
        if(apy == 0) { lockCount.noLockCount = (lockCount.noLockCount != 0) ? lockCount.noLockCount.sub(1): 0; lockCount.noLockTotal = (lockCount.noLockTotal >= amount) ? lockCount.noLockTotal.sub(amount) : 0; }
        if(apy == 1) { lockCount.halfLockCount = (lockCount.halfLockCount != 0) ? lockCount.halfLockCount.sub(1): 0; lockCount.halfLockTotal = (lockCount.halfLockTotal >= amount) ? lockCount.halfLockTotal.sub(amount): 0; }
        if(apy == 2) { lockCount.fullLockCount = (lockCount.fullLockCount != 0) ? lockCount.fullLockCount.sub(1) : 0; lockCount.fullLockTotal = (lockCount.fullLockTotal >= amount) ? lockCount.fullLockTotal.sub(amount): 0; }
        if(apy == 3) { lockCount.totalLockCount = (lockCount.totalLockCount != 0) ? lockCount.totalLockCount.sub(1) : 0; lockCount.totalLockTotal = (lockCount.totalLockTotal >= amount) ? lockCount.totalLockTotal.sub(amount): 0; }
        lockCount.totalInPool = (lockCount.totalInPool >= amount) ? lockCount.totalInPool.sub(amount) : 0;
        lockCounts[poolNo] = lockCount;
    }

    function getTotalLockCount() public view returns(LockCount memory lockCountTotal) {
        
        for(uint i = 1; i <= 5; i++) {
            LockCount memory lockCount = lockCounts[i];
            lockCountTotal.noLockCount += lockCount.noLockCount;
            lockCountTotal.halfLockCount += lockCount.halfLockCount;
            lockCountTotal.fullLockCount += lockCount.fullLockCount;
            lockCountTotal.totalLockCount += lockCount.totalLockCount;
            lockCountTotal.noLockTotal += lockCount.noLockTotal;
            lockCountTotal.halfLockTotal += lockCount.halfLockTotal;
            lockCountTotal.fullLockTotal += lockCount.fullLockTotal;
            lockCountTotal.totalLockTotal += lockCount.totalLockTotal;
            lockCountTotal.totalInPool += lockCount.totalInPool;
        }
    }

    function getLockCounts(uint poolNo) public view returns(LockCount memory) {
        return lockCounts[poolNo];
    }

    function excludeFromTax(address account, bool takeTax) public onlyOwner {
        isExcludedFromTax[account] = takeTax;
    }

    function updateMigrator(address newMigrator) public onlyOwner {
        migrator = newMigrator;
    }

    function migrate(address toStaker, uint256 amount, uint256 apyTime, uint type_, uint256 timeStakedFor, uint256 stakeTime) external onlyMigrator {
        uint256 initialApy = 0;
        uint256 initialAmount = 0;
        uint256 rAmount = 0;
        bool hasStaked = false;

        uint poolNo = enableMultipool ? type_: 1 ;

        require(pools[type_].pool != 0,"Migration: Sorry pool is not set yet.");

        Staker memory staker = stakers[toStaker][poolNo];

        hasStaked = isStaker[toStaker][poolNo];

       if(staker.amount != 0 && hasStaked) {
            rAmount = calculateReturn(toStaker, poolNo);
            initialApy = staker.apyTime;
            initialAmount = staker.amount;
        }

        poolShare[poolNo] += amount;
        amount = amount.add(rAmount);

        staker.wallet = toStaker;
        staker.poolNo = poolNo;
        staker.amount = staker.amount.add(amount);
        staker.apyTime = apyTime;
        staker.timeStakedFor = timeStakedFor;
        staker.stakeTime = stakeTime;

        stakers[toStaker][poolNo] = staker;

        
        dividendDistributor.setShare(toStaker, staker.amount, poolNo);
        
        
        if(!hasStaked){
            addLockCount(poolNo, apyTime, amount);
            stakingSize[poolNo] += 1;
        } else {
            uint256 tAmount = amount.add(initialAmount).sub(rAmount);
            if(initialApy > apyTime) {
                apyTime = initialApy;
            }
            subLockCount(poolNo, initialApy, initialAmount);
            addLockCount(poolNo, apyTime, tAmount);
        }
        isStaker[toStaker][poolNo] = true;
        emit Deposit(toStaker, poolNo, amount);

    }

    function updateStakingOpenStatus(bool status_) external onlyOwner {
        openStaking = status_;
    }

    function enableReinvest(bool canReinvest_) external onlyOwner {
        canReinvest = canReinvest_;
    }

    function relock(uint256 apyTime_, uint poolNo_) external {
        Staker memory staker = stakers[_msgSender()][poolNo_];
        require(staker.amount != 0, "MRStaking: caller has no staking in this pool");
        require(apyTime_ != 0, "MRStaking: no lock apy passed");
        require(block.timestamp >= staker.stakeTime.add(_getLockPeriod(staker.apyTime)), "MRStaking: lock time is not over yet.");
        uint256 returnAmount = calculateReturn(_msgSender(), poolNo_);
        subLockCount(poolNo_, staker.apyTime, staker.amount);
        staker.apyTime = apyTime_;
        staker.timeStakedFor = _stakeTimes(apyTime_);
        staker.stakeTime = block.timestamp;
        staker.amount = staker.amount.add(returnAmount);
        stakers[_msgSender()][poolNo_] = staker;
        addLockCount(poolNo_, apyTime_, staker.amount);
        
    }

    function approveMR(address spender, uint256 amount) external onlyOwner {
        _token.approve(spender, amount);
    }

    function mintLand(uint poolNo_) public {

        poolNo_ = enableMultipool ? poolNo_ : 1;

        Staker memory staker = stakers[_msgSender()][poolNo_];

        require(staker.amount != 0, "MRStaking: wallet has no staking.");
        uint256 returnAmount = calculateReturn(_msgSender(), poolNo_);
        require(returnAmount != 0, "MRStaking: No apy to mint land.");
        _token.approve(address(landSaleContract), _token.balanceOf(address(this)));
        uint256 price = landSaleContract.PRICE();
        uint256 amountToMint = returnAmount.div(price);
        require(amountToMint >= 1, "MRStaking: not enough apy to mint a land.");
        if(amountToMint > 20) {
            amountToMint = 20;
        }
        
        uint256 finalMintAmount = amountToMint.mul(price);


        totalTokenClaimed[poolNo_] = totalTokenClaimed[poolNo_].add(finalMintAmount);

        uint256 remainingAmount = returnAmount.sub(finalMintAmount);
        uint256 totalDiscount = mintPriceAdjust.mul(amountToMint);
        subLockCount(poolNo_, staker.apyTime, staker.amount);
        staker.amount = staker.amount.add(remainingAmount).add(totalDiscount);
        staker.stakeTime = block.timestamp;
        stakers[_msgSender()][poolNo_] = staker;
        addLockCount(poolNo_, staker.apyTime, staker.amount);
        landSaleContract.mint(amountToMint);
        uint256[] memory tokenIds = landSaleContract.tokensOfOwner(address(this));

        for(uint256 i; i < tokenIds.length; i++) {
            ERC721(address(landSaleContract)).safeTransferFrom(address(this), _msgSender(), tokenIds[i]);
        }

        dividendDistributor.setShare(_msgSender(), staker.amount, poolNo_);
    }

    function updateMintPriceAdjust(uint256 newPrice) external onlyOwner {
        mintPriceAdjust = newPrice;
    }

    function updateLandSaleAddress(MRLandSale newAddress) external onlyOwner {
        landSaleContract = newAddress;
    }

    function landMintPrice() external view returns(uint256) {
        return landSaleContract.PRICE();
    }

    function setEnableMultiPool(bool enable_) external onlyOwner {
        enableMultipool = enable_;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable{}
}