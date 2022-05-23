// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../libs/dgg/Auth.sol";
import "../libs/zeppelin/token/BEP20/IBEP20.sol";
import "../interfaces/IDGGToken.sol";

contract SeedSale is Auth {

  struct Buyer {
    uint allocated;
    uint price; // decimal 3
    uint boughtAtBlock;
    uint lastClaimed;
    uint totalClaimed;
  }
  enum USDCurrency {
    busd,
    usdt
  }

  address public fundAdmin;
  IDGGToken public dggToken;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
  uint public constant seedSaleAllocation = 25e24;
  uint public startVestingBlock;
//  uint public constant blockInOneMonth = 864000; // 30 * 24 * 60 * 20
  uint public blockInOneMonth; // 30 * 24 * 60 * 20

  uint constant decimal3 = 1000;
  uint public tgeRatio;
  uint public vestingTime;
  bool public adminCanUpdateAllocation;
  uint totalAllocated;
  mapping(address => Buyer) buyers;

  event UserAllocated(address indexed buyer, uint amount, uint price, uint timestamp);
  event Bought(address indexed buyer, uint amount, uint price, uint timestamp);
  event BuyerUpdated(address oldAddress, address newAddress);
  event Claimed(address indexed buyer, uint amount, uint timestamp);
  event VestingStated(uint timestamp);

  function initialize(address _mainAdmin, address _fundAdmin, address _dggToken) public initializer {
    Auth.initialize(_mainAdmin);
    fundAdmin = _fundAdmin;
    dggToken = IDGGToken(_dggToken);
    vestingTime = 12;
    tgeRatio = 20;
    adminCanUpdateAllocation = true;
    busdToken = IBEP20(0xD8aD05ff852ae4EB264089c377501494EA1D03C9);
    usdtToken = IBEP20(0xF5ed09f4b0E89Dff27fe48AaDf559463505fbac4);

    // TODO remove
    blockInOneMonth = 200;
  }

  function startVesting() onlyMainAdmin external {
    require(startVestingBlock == 0, "SeedSale: vesting had started");
    startVestingBlock = block.number;
    emit VestingStated(startVestingBlock);
  }

  function updateVestingTime(uint _month) onlyMainAdmin external {
    require(adminCanUpdateAllocation, "SeedSale: user had bought");
    vestingTime = _month;
  }

  function updateTGERatio(uint _ratio) onlyMainAdmin external {
    require(adminCanUpdateAllocation, "SeedSale: user had bought");
    require(_ratio < 100, "SeedSale: invalid ratio");
    tgeRatio = _ratio;
  }

  function updateFundAdmin(address _address) onlyMainAdmin external {
    require(_address != address(0), "SeedSale: invalid address");
    fundAdmin = _address;
  }

  function setUserAllocations(address[] calldata _buyers, uint[] calldata _amounts, uint[] calldata _prices) external onlyMainAdmin {
    require(_buyers.length == _amounts.length && _amounts.length == _prices.length, "SeedSale: invalid data input");
    address buyer;
    uint amount;
    uint price;
    for(uint i = 0; i < _buyers.length; i++) {
      buyer = _buyers[i];
      amount = _amounts[i];
      price = _prices[i];
      if (_buyers[i] != address(0) && buyers[_buyers[i]].boughtAtBlock == 0) {
        if (buyers[buyer].allocated == 0) {
          totalAllocated += amount;
        } else {
          totalAllocated = totalAllocated - buyers[buyer].allocated + amount;
        }
        buyers[buyer] = Buyer(amount, price, 0, 0, 0);
        emit UserAllocated(buyer, amount, price, block.timestamp);
      }
    }
    require(totalAllocated <= seedSaleAllocation, "SeedSale: amount invalid");
  }

  function removeBuyerAllocation(address _buyer) external onlyMainAdmin {
    require(buyers[_buyer].allocated > 0, "SeedSale: User have no allocation");
    require(buyers[_buyer].boughtAtBlock == 0, "SeedSale: User have bought already");
    delete buyers[_buyer];
  }

  function changeBuyer(address _oldAddress, address _newAddress) external onlyMainAdmin {
    require(buyers[_oldAddress].allocated > 0, "PrivateSale: User have no allocation");
    buyers[_newAddress].allocated = buyers[_oldAddress].allocated;
    buyers[_newAddress].price = buyers[_oldAddress].price;
    buyers[_newAddress].boughtAtBlock = buyers[_oldAddress].boughtAtBlock;
    buyers[_newAddress].lastClaimed = buyers[_oldAddress].lastClaimed;
    buyers[_newAddress].totalClaimed = buyers[_oldAddress].totalClaimed;
    delete buyers[_oldAddress];
    emit BuyerUpdated(_oldAddress, _newAddress);
  }

  function drainToken(address _usdToken) external onlyMainAdmin {
    IBEP20 token = IBEP20(_usdToken);
    token.transfer(msg.sender, token.balanceOf(address(this)));
  }

  function buy(USDCurrency _usdCurrency) external {
    Buyer storage buyer = buyers[msg.sender];
    require(buyer.allocated > 0, "SeedSale: You have no allocation");
    require(buyer.boughtAtBlock == 0, "SeedSale: You had bought");
    if (adminCanUpdateAllocation) {
      adminCanUpdateAllocation = false;
    }
    _takeFund(_usdCurrency, buyer.allocated * buyer.price / decimal3);
    buyer.boughtAtBlock = block.number;
    emit Bought(msg.sender, buyer.allocated, buyer.price, block.timestamp);
  }

  function claim() external {
    require(startVestingBlock > 0, "SeedSale: please wait more time");
    Buyer storage buyer = buyers[msg.sender];
    require(buyer.boughtAtBlock > 0, "SeedSale: You have no allocation");
    uint maxBlockNumber = startVestingBlock + blockInOneMonth * vestingTime;
    require(maxBlockNumber > buyer.lastClaimed, "SeedSale: your allocation had released");
    uint blockPass;
    uint releaseAmount;
    if (buyer.lastClaimed == 0) {
      buyer.lastClaimed = startVestingBlock;
      releaseAmount = buyer.allocated * tgeRatio / 100;
    } else {
      if (block.number < maxBlockNumber) {
        blockPass = block.number - buyer.lastClaimed;
        buyer.lastClaimed = block.number;
      } else {
        blockPass = maxBlockNumber - buyer.lastClaimed;
        buyer.lastClaimed = maxBlockNumber;
      }
      releaseAmount = buyer.allocated * (100 - tgeRatio) / 100 * blockPass / (blockInOneMonth * vestingTime);
    }
    buyer.totalClaimed = buyer.totalClaimed + releaseAmount;
    require(dggToken.releaseSeedSaleAllocation(msg.sender, releaseAmount), "SeedSale: transfer token failed");
    emit Claimed(msg.sender, releaseAmount, block.timestamp);
  }

  function getBuyer(address _address) external view returns (uint, uint, uint, uint, uint) {
    Buyer storage buyer = buyers[_address];
    return(
      buyer.allocated,
      buyer.price,
      buyer.boughtAtBlock,
      buyer.lastClaimed,
      buyer.totalClaimed
    );
  }

  function _takeFund(USDCurrency _usdCurrency, uint _amount) private {
    IBEP20 usdToken = _usdCurrency == USDCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "SeedSale: please approve usd token first");
    require(usdToken.balanceOf(msg.sender) >= _amount, "StrategicSale: please fund your account");
    require(usdToken.transferFrom(msg.sender, address(this), _amount), "SeedSale: transfer usd token failed");
    require(usdToken.transfer(fundAdmin, _amount), "SeedSale: transfer usd token failed");
  }

  // TODO test only
  function updateBlockInOneMonth(uint _amount) external onlyMainAdmin {
    blockInOneMonth = _amount;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Auth is Initializable {

  address public mainAdmin;
  address public contractAdmin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
  event ContractAdminUpdated(address indexed _newOwner);

  function initialize(address _mainAdmin) virtual public initializer {
    mainAdmin = _mainAdmin;
    contractAdmin = _mainAdmin;
  }

  modifier onlyMainAdmin() {
    require(_isMainAdmin(), "onlyMainAdmin");
    _;
  }

  modifier onlyContractAdmin() {
    require(_isContractAdmin() || _isMainAdmin(), "onlyContractAdmin");
    _;
  }

  function transferOwnership(address _newOwner) onlyMainAdmin external {
    require(_newOwner != address(0x0));
    mainAdmin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }

  function updateContractAdmin(address _newAdmin) onlyMainAdmin external {
    require(_newAdmin != address(0x0));
    contractAdmin = _newAdmin;
    emit ContractAdminUpdated(_newAdmin);
  }

  function _isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }

  function _isContractAdmin() public view returns (bool) {
    return msg.sender == contractAdmin;
  }
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../libs/zeppelin/token/BEP20/IBEP20.sol";

interface IDGGToken is IBEP20 {
  function releaseGameAllocation(address _gamerAddress, uint _amount) external returns (bool);
  function releasePrivateSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseSeedSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseStrategicSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function burn(uint _amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}