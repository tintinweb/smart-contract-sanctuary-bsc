/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// SPDX-License-Identifier: MIT

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

pragma solidity 0.8.7;

interface RichRabbitNFT{
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function balanceOf(address account) external view returns (uint256);
}

interface GenesisPass{
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function balanceOf(address account) external view returns (uint256);
}

interface RichRabbitCheck{
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract RichRabbitDividend is Ownable{
    using Address for address;
    uint public totalSupply = 200;
    uint public genesisSupply = 600;
    mapping (uint => Tokens) public accounts;
    mapping (uint => Passes) public accountsGenesis;
    struct Tokens{
        uint256 amount;
    }
    struct Passes{
        uint256 amount;
        bool dead;
    }

    address private constant DEAD = address(0xdead);
    address private tokenAddress_ = address(0x20425306F9fd2b6E562Db863A72c723b1644E1Bc);
    address private nftAddress_ = address(0x17cb5121ACe81f39f2830B9B6ddc0EBABBf4354c);
    address private passAddress_ = address(0x5e365794D19A74d615Fb4b960d43eCaDDd78385e);
    address private constant _paymentAddress = address(0x6CB0ED7C8d911564e543EAcA9208D81642ec65f9);

    RichRabbitCheck public tokenAddress = RichRabbitCheck(tokenAddress_);
    RichRabbitNFT public nftCollection = RichRabbitNFT(nftAddress_);
    GenesisPass public genesisCollection = GenesisPass(passAddress_);

    constructor(){
    }

    function viewAccountTotal(address account_) external view returns(uint256){
        uint256 total=0;
        uint tokens=0;
        uint tokensGenesis=0;
        while(tokens<=totalSupply){
            if(nftCollection.ownerOf(tokens) == account_){
                total += accounts[tokens].amount;
            }
            ++tokens;
        }
        while(tokensGenesis<=genesisSupply){
            if(!accountsGenesis[tokensGenesis].dead){
                if(genesisCollection.ownerOf(tokensGenesis) == account_){
                    total += accountsGenesis[tokensGenesis].amount;
                }
            }
            ++tokensGenesis;
        }
        return total;
    }

    function viewAccountPass(address account_) external view returns(uint256){
        uint256 total=0;
        uint tokensGenesis=0;
        while(tokensGenesis<=genesisSupply){
            if(!accountsGenesis[tokensGenesis].dead){
                if(genesisCollection.ownerOf(tokensGenesis) == account_){
                    total += accountsGenesis[tokensGenesis].amount;
                }
            }
            ++tokensGenesis;
        }
        return total;
    }

    function viewAccountNFT(address account_) external view returns(uint256){
        uint256 total=0;
        uint tokens=0;
        while(tokens<=totalSupply){
            if(nftCollection.ownerOf(tokens) == account_){
                total += accounts[tokens].amount;
            }
            ++tokens;
        }
        return total;
    }

    function viewDividendTotal() external view returns(uint256){
        uint256 total=0;
        uint tokens=0;
        uint tokensGenesis=0;
        while(tokens<=totalSupply){
            total += accounts[tokens].amount;
            ++tokens;
        }
        while(tokensGenesis<=genesisSupply){
            total += accountsGenesis[tokensGenesis].amount;
            ++tokensGenesis;
        }
        return total;
    }
    //redeem Dividends
    function redeemSingleNFT(uint256 tokenId_) external returns(bool){
        require(msg.sender != DEAD);
        require(msg.sender != address(0));
        if(nftCollection.ownerOf(tokenId_) == msg.sender){
            if(accounts[tokenId_].amount > 0){
                tokenAddress.transfer(msg.sender, accounts[tokenId_].amount);
                accounts[tokenId_].amount = 0;
            }
        }
        return true;
    }
   //redeem Dividends
    function redeemSinglePass(uint256 tokensGenesis_) external returns(bool){
        require(msg.sender != DEAD);
        require(msg.sender != address(0));
        if(genesisCollection.ownerOf(tokensGenesis_) == msg.sender){
            if(accountsGenesis[tokensGenesis_].amount > 0){
                tokenAddress.transfer(msg.sender, accountsGenesis[tokensGenesis_].amount);
                accountsGenesis[tokensGenesis_].amount = 0;
            }
         }
        return true;
    }
    //redeem Dividends
    function superRedeem() external returns(bool){
        require(msg.sender != DEAD);
        require(msg.sender != address(0));
        uint256 total=0;
        uint tokens=0;
        uint tokensGenesis=0;
        while(tokens<=totalSupply){
            if(nftCollection.ownerOf(tokens) == msg.sender){
                total += accounts[tokens].amount;
                accounts[tokens].amount = 0;
            }
            ++tokens;
        }
        while(tokensGenesis<=genesisSupply){
            if(!accountsGenesis[tokensGenesis].dead){
                if(genesisCollection.ownerOf(tokensGenesis) == msg.sender){
                    total += accountsGenesis[tokensGenesis].amount;
                    accountsGenesis[tokensGenesis].amount = 0;
                }
            }
			++tokensGenesis;
        }
        if(total > 0){
            tokenAddress.transfer(msg.sender, total);
        }
        return true;
    }

    //redeem Dividends
    function redeem() external returns(bool){
        require(msg.sender != DEAD);
        require(msg.sender != address(0));
        uint256 total=0;
        uint tokens=0;
        while(tokens<=totalSupply){
            if(nftCollection.ownerOf(tokens) == msg.sender){
                total += accounts[tokens].amount;
                accounts[tokens].amount = 0;
            }
            ++tokens;
        }
        if(total > 0){
            tokenAddress.transfer(msg.sender, total);
        }
        return true;
    }

    //redeem Dividends
    function redeemGenesis() external returns(bool){
        require(msg.sender != DEAD);
        require(msg.sender != address(0));
        uint256 total=0;
		uint tokensGenesis=0;
        while(tokensGenesis<=genesisSupply){
            if(!accountsGenesis[tokensGenesis].dead){
                if(genesisCollection.ownerOf(tokensGenesis) == msg.sender){
                    total += accountsGenesis[tokensGenesis].amount;
                    accountsGenesis[tokensGenesis].amount = 0;
                }
            }
            ++tokensGenesis;
        }
        if(total > 0){
            tokenAddress.transfer(msg.sender, total);
        }
        return true;
    }

    function setGenesisSupply(uint genesisSupply_) external onlyOwner returns (bool) {
        genesisSupply = genesisSupply_;
        return true;
    }

    function setTotalSupply(uint totalSupply_) external onlyOwner returns (bool) {
        totalSupply = totalSupply_;
        return true;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficient balance");
        (bool success, ) = payable(_paymentAddress).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function withdrawRRR(uint256 withdrawRRR_) external onlyOwner returns (bool) {
        uint256 balance = tokenAddress.balanceOf(address(this));
        require(withdrawRRR_ <= balance, "Insufficient balance");
        tokenAddress.transfer(_paymentAddress, withdrawRRR_);
        return true;
    }

    function disqualifyGenesis(uint tokenId_) external onlyOwner returns(bool) {
        require(accountsGenesis[tokenId_].dead);
        accountsGenesis[tokenId_].dead = true;
        genesisSupply--;
        return true;
    }

    function qualifyGenesis(uint tokenId_) external onlyOwner returns(bool) {
        require(!accountsGenesis[tokenId_].dead);
        accountsGenesis[tokenId_].dead = false;
        genesisSupply++;
        return true;
    }

    function nftDividend(
        uint256[] memory nftdividend
        ) external onlyOwner returns(bool) {
            for (uint256 i = 0; i < nftdividend.length; i++) {
            accounts[i].amount += nftdividend[i];
        }
        return true;
    }

    function passDividend(
        uint256[] memory passdividend
        ) external onlyOwner returns(bool) {
            for (uint256 i = 0; i < passdividend.length; i++) {
            accountsGenesis[i].amount += passdividend[i];
        }
        return true;
    }

    function nftDividendover(
        uint256[] memory nftdividend
        ) external onlyOwner returns(bool) {
            for (uint256 i = 0; i < nftdividend.length; i++) {
            accounts[i].amount = nftdividend[i];
        }
        return true;
    }

    function passDividendover(
        uint256[] memory passdividend
        ) external onlyOwner returns(bool) {
            for (uint256 i = 0; i < passdividend.length; i++) {
            accountsGenesis[i].amount = passdividend[i];
        }
        return true;
    }

    //Payments made to the contract
    receive() external payable {
    }
}