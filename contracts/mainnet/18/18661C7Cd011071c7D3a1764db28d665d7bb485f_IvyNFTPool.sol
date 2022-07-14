/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.7;


pragma abicoder v2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    constructor () {
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
        _previousOwner = _owner;
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
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

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function tokensOfOwner(address _owner) external view returns (uint256[] memory);

}
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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


interface IERC20 {

    function decimals() external view returns(uint8);

    function symbol() external view returns(string memory);

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

contract IvyNFTPool is Context, Ownable, IERC721Receiver {
    using SafeMath for uint256;
    IERC20 public token;
    IERC721 public nftAddress;

    address public feeReceiver = 0x38EFA142eB5c9a84B58F3967ab946D67E7513371;

    uint256 public baseRate;
    uint256 public calculationBlock = 365 days;
    uint256 public stakeFee = 0.004 ether;
    uint256 public unstakeFee = 0.004 ether;

    struct NFT {
        address owner;
        uint256 tokenId;
        uint256 endBlock;
        uint256 startBlock;
    }

    mapping(uint256 => NFT) public nftInfos;
    mapping(address => uint256[]) public nftsOfWallet;

    uint256 public totalClaimed;
    bool public enablestaking = false;
    uint256 public tranferFee = 10;

    event Staked(address indexed from, uint256 tokenId, uint256 endBlock);
    event ClaimedReturn(address indexed by, uint256 claimAmount, uint256 tokenId);
    event ClaimedTotalReturn(address indexed by, uint256 amount);
    event UnStaked(address indexed by, uint256 tokenId);


    constructor(IERC721 nftAddress_) {
        nftAddress = nftAddress_;
        baseRate = 3650 * 10 ** 18;
    }

    modifier stakingenabled() {
        require(enablestaking, "staking is not started yet!");
        _;
    }

    function unstakeAllNft() external payable {
        uint256[] memory tokenIds = nftsOfWallet[_msgSender()];
        require(tokenIds.length > 0, "wallet has no staking");
        require(msg.value >= unstakeFee.mul(tokenIds.length), "Unstake fee amount is not enough");
        payable(feeReceiver).transfer(msg.value);
        for(uint256 i; i < tokenIds.length; i++) {
            _claimTokenReturn(tokenIds[i], _msgSender());
            _removeNft(tokenIds[i], _msgSender());
            nftAddress.safeTransferFrom(address(this), _msgSender(), tokenIds[i]);
            emit UnStaked(_msgSender(), tokenIds[i]);
        }
    }

    function unstakeNft(uint256 tokenId) external payable {
        require(msg.value >= unstakeFee, "Unstake fee amount is not enough");
        payable(feeReceiver).transfer(msg.value);
        _claimTokenReturn(tokenId, _msgSender());
        _removeNft(tokenId, _msgSender());
        nftAddress.safeTransferFrom(address(this), _msgSender(), tokenId);
        emit UnStaked(_msgSender(), tokenId);
    }

    function _removeNft(uint256 tokenId, address account)  internal {
        delete nftInfos[tokenId];
        uint256[] memory tokenIds = nftsOfWallet[account];
        for(uint256 i; i < tokenIds.length; i++) {
            if(tokenId == tokenIds[i]) {
                tokenIds[i] = tokenIds[tokenIds.length - 1];
                nftsOfWallet[account] = tokenIds;
                nftsOfWallet[account].pop();
            }
        }
    }
    
    function stakeAll() external payable stakingenabled{
        require(nftAddress.isApprovedForAll(_msgSender(), address(this)), "please approve all NFT to spend.");
        uint256[] memory tokenIds = nftAddress.tokensOfOwner(_msgSender());
        require(msg.value >= stakeFee.mul(tokenIds.length), "Stake fee amount is not enough");
        payable(feeReceiver).transfer(msg.value);
        for(uint256 i; i < tokenIds.length; i++) {
            nftAddress.safeTransferFrom(_msgSender(), address(this), tokenIds[i]);
            nftsOfWallet[_msgSender()].push(tokenIds[i]);
            _setNftInfo(tokenIds[i], _msgSender());
        }
    }

    function stakeToken(uint256 tokenId) external payable stakingenabled{
        require(nftAddress.isApprovedForAll(_msgSender(), address(this)), "please approve all NFT to spend.");
        require(msg.value >= stakeFee, "Stake fee amount is not enough");
        payable(feeReceiver).transfer(msg.value);
        nftAddress.safeTransferFrom(_msgSender(), address(this), tokenId);
        nftsOfWallet[_msgSender()].push(tokenId);
        _setNftInfo(tokenId, _msgSender());
    }

    function claimTokenReturn(uint256 tokenId) external {
       _claimTokenReturn(tokenId, _msgSender());
    }

    function _claimTokenReturn(uint256 tokenId, address account) internal {
         NFT memory nftInfo = nftInfos[tokenId];
        require(nftInfo.owner == account, "wallet is not the owner of nft");
        require(calculateTokenReturn(tokenId) > 0, "nothing is claimable");
        uint256 tReturn = calculateTokenReturn(tokenId);

        if(tranferFee > 0) {
            uint256 fee = tReturn.mul(tranferFee).div(10**2);
            tReturn = tReturn.sub(fee);
        }
        
        _setNftInfo(tokenId, account);
        token.transfer(account, tReturn);
        emit ClaimedReturn(account, tReturn, tokenId);
    }

    function claimTotalReturn() external {
        uint256[] memory tokenIds = nftsOfWallet[_msgSender()];
        require(tokenIds.length > 0, "wallet has no staking");
        uint256 tReturn = calculateWalletReturn(_msgSender());
        require(tReturn != 0, "wallet has no return yet");
        for(uint256 i; i < tokenIds.length; i++){
            _setNftInfo(tokenIds[i], _msgSender());
        }
        if(tranferFee > 0) {
            uint256 fee = tReturn.mul(tranferFee).div(10**2);
            tReturn = tReturn.sub(fee);
        }
        token.transfer(_msgSender(), tReturn);
        emit ClaimedTotalReturn(_msgSender(), tReturn);
    }

    function _setNftInfo(uint256 tokenId, address account) internal {
        NFT memory nftInfo = nftInfos[tokenId];
        nftInfo.owner = account;
        nftInfo.tokenId = tokenId;
        nftInfo.endBlock = block.timestamp;
        nftInfo.startBlock = block.timestamp;
        nftInfos[tokenId] = nftInfo;
        emit Staked(_msgSender(), tokenId, nftInfo.endBlock);
    }

    function calculateWalletReturn(address account) public view returns(uint256) {
        uint256[] memory tokenIds = nftsOfWallet[account];
        uint256 tReturn = 0;
        if(tokenIds.length == 0) return tReturn;
        for(uint256 i; i < tokenIds.length; i++) {
            uint256 tokenReturn = calculateTokenReturn(tokenIds[i]);
            tReturn = tReturn.add(tokenReturn);
        }
        return tReturn;
    }


    function calculateTokenReturn(uint256 tokenId) public view returns(uint256) {
        NFT memory nftInfo = nftInfos[tokenId];
        if(nftInfo.startBlock == 0) return 0;
        uint256 timePassed = block.timestamp.sub(nftInfo.startBlock);
        return baseRate.mul(timePassed).div(calculationBlock);
    }

    event UpdateTokens(address indexed token_, address indexed nftToken_);
    function updateTokens(IERC20 token_, IERC721 nftToken_) external onlyOwner {
        require(address(token_) != address(0), "Supplied address is zero address");
        require(address(nftToken_) != address(0), "Supplied address is zero address");
        token = token_;
        nftAddress = nftToken_;
        emit UpdateTokens(address(token_), address(nftToken_));
    }

    event UpdateBaserate(uint256 newrate);
    function updateBaseRate(uint256 newBaseRate) external onlyOwner {
        baseRate = newBaseRate;
        emit UpdateBaserate(newBaseRate);
    }

    event WithdrawTokens(uint256 amount);
    function withdrawToken(uint256 amount) external onlyOwner {
        token.transfer(_msgSender(), amount);
        emit WithdrawTokens(amount);
    }

    function nftIdsOfWallet(address account) external view returns(uint256[] memory){
        return nftsOfWallet[account];
    }

    event StakingEnabled(bool _enable);
    function updateEnablestaking(bool _enable) external onlyOwner {
        enablestaking = _enable;
        emit StakingEnabled(_enable);
    }

    event UpdateTranferFee(uint256 newFeePercent);
    function udpateTranferFeePercent(uint256 newFeePercent) external onlyOwner {
        tranferFee = newFeePercent;
        emit UpdateTranferFee(newFeePercent);
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    event UpdateStakeFees(uint256 stakeFee_, uint256 unstakeFee_);
    function updateStakeFees(uint256 stakeFee_, uint256 unstakeFee_) external onlyOwner {
        stakeFee = stakeFee_;
        unstakeFee = unstakeFee_;
        emit UpdateStakeFees(stakeFee_, unstakeFee_);
    }

    event UpdateFeeReceiver(address indexed newFeeReceiver);
    function updateFeeReceiver(address newFeeReceiver) external onlyOwner {
        feeReceiver = newFeeReceiver;
        emit UpdateFeeReceiver(newFeeReceiver);
    }

    event ClaimedBNB(address indexed by, uint256 balance);
    function claimBNB() external onlyOwner {
        uint256 balance = address(this).balance;
        if(balance > 0) {
            payable(feeReceiver).transfer(balance);
            emit ClaimedBNB(feeReceiver, balance);
        }
    }
    
}