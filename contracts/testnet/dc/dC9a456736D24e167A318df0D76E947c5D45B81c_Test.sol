// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {WillLib} from "./WillLib.sol";

contract Test is Ownable {
    using Address for address;
    using WillLib for WillLib.Will;

    uint256 private _registerHold;
    uint256 private _withdrawHold;

    address private DMTTOken = 0x138DAee736115D03a2d4540D2ce137b03D7fA439;
    event Withdraw(address indexed _from, address indexed _to, uint256 _value);
    event WithdrawNFT(address indexed _from, address indexed _to, address _nftAddress,uint256 _tokenId);
    event SetWill(address indexed _from);
    constructor(
        uint256 registerHold,
        uint256 withdrawHold,
        address token
    ) {
        transferOwnership(msg.sender);
        _registerHold = registerHold;
        _withdrawHold = withdrawHold;
        DMTTOken = token;
    }

    mapping(address => WillLib.Will) private _will;
    mapping(address => WillLib.Beneficiary[]) private _benDetails; // reverse of testament address is bens beneficiary is owner

    //get will
    function getWill(address wallet)
        public
        view
        returns (
            WillLib.Beneficiary[] memory beneficiaries,
            WillLib.Token[] memory tokens,
            WillLib.NFT[] memory nfts,
            uint256 signRecheck,
            uint256 signDate,
            uint256 withdrawCount
        )
    {
        //require(msg.sender == wallet ,"IP1: Not your Wallet!");
        return (
            _will[wallet].beneficiaries,
            _will[wallet].tokens,
            _will[wallet].nfts,
            _will[wallet].signRecheck,
            _will[wallet].signDate,
            _will[wallet].withdrawCount
        );
    }

    //set will
    function setWill(
        WillLib.Beneficiary[] calldata beneficiaries,
        address[] calldata tokens,
        WillLib.NFT[] calldata nfts,
        uint256 signRecheck
    ) public {
        require(
            IERC20(DMTTOken).balanceOf(msg.sender) > _registerHold,
            "IP1: Your DMT token holding amount is not enough for register"
        );

        _will[msg.sender].setBeneficiaries(beneficiaries);
        _setBenDetails(beneficiaries,msg.sender);
        _will[msg.sender].setTokens(tokens);
        _will[msg.sender].setNfts(nfts);
        _will[msg.sender].signDate = block.timestamp;
        _will[msg.sender].signRecheck = signRecheck * 1 minutes; //will.signRecheck = 3 , 6 or 12
        _will[msg.sender].withdrawCount = 0;
        emit SetWill(msg.sender);
    }

    function _setBenDetails(WillLib.Beneficiary[] calldata beneficiaries,address sender) private {
        for (uint256 index = 0; index < beneficiaries.length; index++) {
            WillLib.Beneficiary memory t;
            t.wallet = sender; //will address
            t.share = beneficiaries[index].share;
            t.title = beneficiaries[index].title;
            t.nftCount = beneficiaries[index].nftCount;
            t.tokenCount = beneficiaries[index].tokenCount;
            _benDetails[beneficiaries[index].wallet].push(t);
        }
    }

    //end of set testament

    function withdrawToken(address wallet, address tokenAddress) public {
        
        require(
            _will[wallet].signDate + _will[wallet].signRecheck <
                block.timestamp,
            "IP1: NOT DEAD"
        );
        require(
            IERC20(DMTTOken).balanceOf(msg.sender) > _withdrawHold,
            "IP1: Your DMT token Hold amount is not enough for withdraw"
        );
        //require msg seder in beneficiaries of wallet 

        //IERC20 token = IERC20(tokenAddress);
        uint256 amountToTransfer;
        uint256 initBalance; //initial balance of token where wants to transfer

        if (_will[wallet].withdrawCount == 0) {
            //first withdraw

            //set all token initial balances
            for (
                uint256 index = 0;
                index < _will[wallet].tokens.length;
                index++
            ) {
                _will[wallet].tokens[index].initialBalance = IERC20(
                    _will[wallet].tokens[index].tokenAddress
                ).balanceOf(wallet);
                if (_will[wallet].tokens[index].tokenAddress == tokenAddress) {
                    initBalance = _will[wallet].tokens[index].initialBalance;
                }
            }
        }
        else{
            for (
                uint256 index = 0;
                index < _will[wallet].tokens.length;
                index++
            ) {
                if (_will[wallet].tokens[index].tokenAddress == tokenAddress) {
                    initBalance = _will[wallet].tokens[index].initialBalance;
                }
            }
        }

        (uint256 share,,, ) = _will[wallet].getBeneficiary(msg.sender);
        amountToTransfer = share * (initBalance / 100);
        _will[wallet].withdrawCount += 1;
        IERC20(tokenAddress).transferFrom(wallet, msg.sender, amountToTransfer);
        //emit amount to transfer sent to msg.sender
        emit Withdraw(wallet, msg.sender, amountToTransfer);
    }

    // function withdrawNFT
    function withdrawNFT(
        address wallet,
        address nftAddress,
        uint256 tokenId
    ) public {
        require(
            _will[wallet].signDate + _will[wallet].signRecheck <
                block.timestamp,
            "IP1: NOT DEAD"
        );
        require(
            IERC20(DMTTOken).balanceOf(msg.sender) > _withdrawHold,
            "IP1: Your DMT token Hold amount is not enough for withdraw"
        );
        IERC721 token = IERC721(nftAddress);
        WillLib.NFT memory nft;
        for (uint256 index = 0; index <  _will[wallet].nfts.length; index++) {
          if(_will[wallet].nfts[index].tokenAddress == nftAddress){
            if(_will[wallet].nfts[index].tokenId == tokenId)
            {
                nft = _will[wallet].nfts[index];
            }
          }
        }
        require(nft.beneficiary.wallet == msg.sender, "You are not the Beneficiary!");

        _will[wallet].withdrawCount += 1;
        token.safeTransferFrom(wallet, msg.sender, tokenId);
        //emit NFT with ID : tokenId transfered to msg.sender
        emit WithdrawNFT(wallet, msg.sender, nftAddress,tokenId);
    }

    function checkIn() public {
        _will[msg.sender].signDate = block.timestamp;
        _will[msg.sender].withdrawCount = 0;
    }

    function GetBeneficiaryDetails(address benAddress)
        public
        view
        returns (WillLib.Beneficiary[] memory)
    {
        return _benDetails[benAddress];
    }

    function setRegisterHold(uint256 amount) public onlyOwner {
        _registerHold = amount;
    }

    function getRegisterHold() public view returns (uint256) {
        return _registerHold;
    }

    function setWithdrawHold(uint256 amount) public onlyOwner {
        //set number of DMT token to hold to get eligible for withdraw
        _withdrawHold = amount;
    }

    function getWithdrawHold() public view returns (uint256) {
        return _withdrawHold;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library WillLib {
    struct Beneficiary {
        address wallet;
        uint256 share;
        string title;
        uint256 nftCount;
        uint256 tokenCount;
    }

    struct NFT {
        address tokenAddress;
        uint256 tokenId;
        string url;
        Beneficiary beneficiary;
    }

    struct Token {
        address tokenAddress;
        uint256 initialBalance;
    }

    struct Will {
        Beneficiary[] beneficiaries;
        NFT[] nfts;
        Token[] tokens;
        uint256 signRecheck; //3 or 6 or 12
        uint256 signDate; //02/01/2022
        uint256 withdrawCount;
    }

    function getBeneficiary(Will storage self, address beneficiary)
        public
        view
        returns (uint256 share, string memory title,uint256 nftCount,uint256 tokenCount)
    {
        for (uint256 index = 0; index < self.beneficiaries.length; index++) {
            if (self.beneficiaries[index].wallet == beneficiary) {
                return (
                    self.beneficiaries[index].share,
                    self.beneficiaries[index].title,
                    self.beneficiaries[index].nftCount,
                    self.beneficiaries[index].tokenCount
                );
            }
        }
    }

    function setBeneficiaries(
        Will storage self,
        Beneficiary[] memory beneficiaries
    ) public {
        delete self.beneficiaries;
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            Beneficiary memory b = Beneficiary({
                    wallet: beneficiaries[i].wallet,
                    share: beneficiaries[i].share,
                    title: beneficiaries[i].title,
                    nftCount : beneficiaries[i].nftCount,
                    tokenCount : self.tokens.length
                });

                self.beneficiaries.push(b);
        }
    }

    function setTokens(Will storage self, address[] memory tokens) public {
        delete self.tokens;
        for (uint256 i = 0; i < tokens.length; i++) {
           Token memory t = Token({
                    tokenAddress: tokens[i],
                    initialBalance: 0
                });

                self.tokens.push(t);
        }
    }

    function setNfts(Will storage self, NFT[] memory nfts) internal {

        delete self.nfts;
        for (uint256 i = 0; i < nfts.length; i++) {
          NFT memory n = NFT({
              tokenAddress : nfts[i].tokenAddress,
              tokenId : nfts[i].tokenId,
              url:nfts[i].url,
              beneficiary: Beneficiary({
                wallet:nfts[i].beneficiary.wallet,
                share :nfts[i].beneficiary.share,
                title:nfts[i].beneficiary.title,
                nftCount : nfts[i].beneficiary.nftCount,
                tokenCount : self.tokens.length
              })
            });
            self.nfts.push(n);
        }
        
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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