// pragma solidity >=0.5.16;

// import "./interface/IDB.sol";
// import "./interface/IUSDT.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "hardhat/console.sol";


// contract Database is Ownable, IDB {
//     uint256 private ownerFee;
//     uint256 private polkaLokrFee;
//     uint256 public bridgeFee;
//     uint256 private bridgeCount;
//     address private recepient;
//     address private adminWallet;
//     IERC20 public usdtToken;


//     mapping(address => mapping(address => bool)) public isFeePaid;

//     event FeePaid(address depositor, uint256 amount);

//     constructor(address _feeToken, address _adminWallet) {
//         ownerFee = 5000000000000000000;
//         polkaLokrFee = 70000000000000000000;
//         bridgeFee = 3000000000;
//         recepient = msg.sender;
//         usdtToken = IERC20(_feeToken);
//         adminWallet = _adminWallet;
//     }

//     function setOwnerFee(uint256 _ownerFee) public onlyOwner {
//         ownerFee = _ownerFee;
//         //x = _ownerFee;
//     }

//     function getOwnerFee() external view override returns (uint256) {
//         return ownerFee;
//     }

//     function setPolkaLokrFee(uint256 _polkaFee) public onlyOwner {
//         polkaLokrFee = _polkaFee;
//     }

//     function getPolkaLokrFee() external view override returns (uint256) {
//         return polkaLokrFee;
//     }

//     function setRecepient(address _recepient) public onlyOwner {
//         recepient = _recepient;
//     }

//     function getRecepient() external view override returns (address) {
//         return recepient;
//     }

//     function getFeeStatus(address _tokenAddress) external view returns (bool){
//         return isFeePaid[msg.sender][_tokenAddress];
//     }

//     function resetBridgeCount() public onlyOwner{
//         bridgeCount = 0;
//     }

//     function getBridgeCount() external view returns (uint256){
//         return bridgeCount;
//     }

//     function payBridgeFee(address _tokenAddress) external {
//         if(bridgeCount >= 5)
//         {
//             usdtToken.transferFrom(msg.sender, adminWallet, bridgeFee);
//             isFeePaid[msg.sender][_tokenAddress] = true; 
//             emit FeePaid(msg.sender, bridgeFee);
//         }
//         else
//         {
//             isFeePaid[msg.sender][_tokenAddress] = true; 
//             bridgeCount++;
//             emit FeePaid(msg.sender, bridgeFee);    
//         }
//     }

//     function setBridgeFee(uint256 _bridgeFee ) public onlyOwner {
        
//         bridgeFee = _bridgeFee;
//     }

//     function setAdminWallet(address _newAdminWallet) public onlyOwner{
//         adminWallet = _newAdminWallet;
//     }

//     function addBridge(address bridgeContract, address bridgeOwner) external override {
//         // if (bridgeID >= 5) {
//         //     require(isFeePaid[bridgeID], "pay bridge fee first");
//         // }
//         // bridgeID++;
//         emit BridgEdit(bridgeContract, bridgeOwner);
//     }
// }


//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;
import "./interface/IDB.sol";
import "./interface/IUSDT.sol";

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract Database is Ownable, IDB {
    IERC20 public paymentFeeToken;
    address private recepient;
    address public adminWallet;
    uint256 private ownerFee;
    uint256 private polkaLokrFee;
    uint256 public bridgeFee;
    // uint256 private bridgeCount;
    mapping(address => bool) public isFeePaid;
    event FeePaid(address depositor, uint256 amount);
    constructor(IERC20 _feeToken, address _adminWallet) {
        paymentFeeToken = _feeToken;
        ownerFee = 5 ether;
        polkaLokrFee = 70 ether;
        bridgeFee = 0.000000003 ether;
        recepient = _msgSender();
        adminWallet = _adminWallet;
    }
    modifier zeroAddress(address _addr) {
        require(_addr != address(0), "ZERO_ADDRESS");
        _;
    }
    // Getter functions
    function getOwnerFee() external view override returns (uint256) {
        return ownerFee;
    }
    function getPolkaLokrFee() external view override returns (uint256) {
        return polkaLokrFee;
    }
    function getRecepient() external view override returns (address) {
        return recepient;
    }
    function getFeeStatus(address _tokenAddress) external view returns (bool) {
        return isFeePaid[_tokenAddress];
    }
    // function getBridgeCount() external view returns (uint256) {
    //     return bridgeCount;
    // }
    function getPaymentFeeToken() external view returns(IERC20)
    {
        return paymentFeeToken;
    }
    // Setter functions
    function setOwnerFee(uint256 _ownerFee) external onlyOwner {
        ownerFee = _ownerFee;
    }
    function setPolkaLokrFee(uint256 _polkaFee) external onlyOwner {
        polkaLokrFee = _polkaFee;
    }
    function setBridgeFee(uint256 _bridgeFee) external onlyOwner {
        bridgeFee = _bridgeFee;
    }
    function setRecepient(address _recepient)
        external
        zeroAddress(_recepient)
        onlyOwner
    {
        recepient = _recepient;
    }
    function setAdminWallet(address _newAdminWallet)
        external
        zeroAddress(_newAdminWallet)
        onlyOwner
    {
        adminWallet = _newAdminWallet;
     }
    // function resetBridgeCount() external onlyOwner {
    //     bridgeCount = 0;
    // }

    function setPaymentFeeToken (IERC20 _newPaymentToken) external onlyOwner {
        paymentFeeToken = _newPaymentToken;
    }
    function payBridgeFee(address _tokenAddress) external {
        // require(!isFeePaid[_tokenAddress], "FEES_ALREADY_PAID");
        // if (bridgeCount > 4) {
        //     usdtToken.transferFrom(msg.sender, adminWallet, bridgeFee);
        // } else {
        //     bridgeCount++;
        // }
        // isFeePaid[_tokenAddress] = true;
        // emit FeePaid(msg.sender, bridgeFee);
        require(!isFeePaid[_tokenAddress], "FEES_ALREADY_PAID");
        paymentFeeToken.transferFrom(_msgSender(), adminWallet, bridgeFee);
        isFeePaid[_tokenAddress] = true;
        emit FeePaid(_msgSender(), bridgeFee);
    }
    function addBridge(address bridgeContract, address bridgeOwner)
        external
        override
    {
        emit BridgEdit(bridgeContract, bridgeOwner);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.16;
interface IDB
{
    function getOwnerFee() external view returns(uint);
    
    function getPolkaLokrFee() external view returns(uint);
    
    function getRecepient() external view returns (address);
    
    event BridgEdit(address bridgeContract  , address bridgeOwner);
    
    function addBridge(address bridgeContract  , address bridgeOwner) external ;
}

//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.11;


interface  IERC20 {    
    function transferFrom(address sender,address recipient,uint256 amount) external;   
   
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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