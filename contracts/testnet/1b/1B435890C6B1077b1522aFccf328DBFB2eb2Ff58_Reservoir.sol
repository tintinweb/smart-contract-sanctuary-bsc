// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

/**
 * @title Reservoir Contract
 * @notice Distributes a token to different contracts at a defined rate.
 * @dev This contract must be poked via the `drip()` function every so often.
 * @author Planet Finance
 */

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
}

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

/**
 * @dev Interface of the Farm to call massUpdatePools before updating drip rate
 */
interface IFarm{
    function massUpdatePools() external;
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
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


contract Reservoir is Ownable {

  using SafeERC20 for IERC20;
  
    /*
   * Distribution Logic:
   * we set only gammaDrippedPerBlock value
   *
   * 1. gammaTrollerDripRate% of 86.5% of this gammaDrippedPerBlock goes to gammatroller and
   *    farmDripRate% of 86.5% of this gammaDrippedPerBlock goes to farm and farmV2DripRate%
   *    of 86.5% of this gammaDrippedPerBlock goes to farmV2
   * 2. foundationDripRate% of 10% of this gammaDrippedPerBlock goes to foundation
   * 3. treasuryDripRate% of 3.5% of this gammaDrippedPerBlock goes to treasury
   */

  /// @notice The block number when the Reservoir started (immutable)
  uint public dripStart;
  
  /// @notice number of GAMMA tokens that will drip per block
  uint public gammaDrippedPerBlock;


  /// @notice Reference to token to drip (immutable) i.e GAMMA
  IERC20 public token;

  /// @notice Target Addresses to drip GAMMA
  address public foundation = 0xB47577d78c081cBb8F664ce7362034999d97e972;     
  address public treasury = 0x464f751E2a86F686201D26B189B8109e6d910948;       
  address public gammaTroller = 0xF54f9e7070A1584532572A6F640F09c606bb9A83;     
  address public farmAddress = 0xB87F7016585510505478D1d160BDf76c1f41b53d; 
  address public farmV2 = 0xFd525F21C17f2469B730a118E0568B4b459d61B9; //dallas address
  
  /// @notice Percentage drip to targets
  uint public foundationPercentage;
  uint public treasuryPercentage; //changable 
  uint public gammaTrollerPercentage; //changable
  uint public farmPercentage; //changable
  uint public farmV2Percentage; //changable
  
  uint public maxPercentage; //10000
  uint public percentageWithoutTreasuryAndFoundation;
  uint public percentageWithoutTreasuryAndFoundationMax = 9000; //at one time we will change treasury distribution to 0% foundation percentage remains same
  
  uint public constant maxGammaDrippedPerDay = 100000; // amount of gamma transferred from reservoir can never exceed 100,000 GAMMA
  
  
  /// @notice Tokens per block that has to drip to targets
  uint public foundationDripRate;
  uint public treasuryDripRate;
  uint public gammaTrollerDripRate;
  uint public farmDripRate; 
  uint public farmV2DripRate;
   
  
  /// @notice Amount that has already been dripped
  uint public foundationDripped;
  uint public treasuryDripped;
  uint public gammaTrollerDripped;
  uint public farmDripped;
  uint public farmV2Dripped;
  
  uint public lastDripBlock;
  uint public lastDripRateChangeBlock;
    

  event TreasuryPercentageChange(uint oldPercentage,uint newPercentage);
  event GammaTrollerPercentageChange(uint oldPercentage,uint newPercentage);
  event FarmPercentageChange(uint oldPercentage,uint newPercentage);
  event FarmV2PercentageChange(uint oldPercentage,uint newPercentage);

  
  event NewFoundation(address oldFoundation,address newFoundation);
  event NewTreasury(address oldTreasury,address newTreasury);
  event NewGammaTroller(address oldGammaTroller,address newGammaTroller);
  event NewFarm(address oldFarm,address newFarm);
  event NewFarmV2(address oldFarmV2,address newFarmV2);

  event Dripped(uint totalAmount, uint timestamp);
  event FarmDripped(uint amount, uint timestamp);

  
  event FoundationDripRateChange(uint oldDripRate,uint newDripRate);
  event TreasuryDripRateChange(uint oldDripRate,uint newDripRate);
  event GammaTrollerDripRateChange(uint oldDripRate,uint newDripRate);
  event FarmDripRateChange(uint oldDripRate,uint newDripRate);
  event FarmV2DripRateChange(uint oldDripRate,uint newDripRate);
  event DripRateChange(uint lastDripRateChangeBlock);

  modifier onlyFarm() {
      require(msg.sender == farmAddress, "sender is not farm");
      _;
  }

  constructor(IERC20 token_) {
    
    dripStart = block.number;
    lastDripBlock = block.number;
    token = token_;
    
    //initial distribution percentages
    foundationPercentage = 1000;
    treasuryPercentage = 350;
    gammaTrollerPercentage = 4500;
    farmPercentage = 4150;
    maxPercentage = 10000;
    percentageWithoutTreasuryAndFoundation = 8650;
    
    gammaDrippedPerBlock = 3472222222222222000;
    
    _updateGammaDrippedPerBlockInternal();
  }

  /**
    * @notice Drips the maximum amount of tokens to match the drip rate since inception
    * @dev Note: this will only drip up to the amount of tokens available.
    * @return The amount of tokens dripped in this call
    */
  function drip() public returns (uint) {
    // First, read storage into memory
    IERC20 token_ = token;

    uint blockNumber_ = block.number;

    // drip Calculations
    uint deltaDripFoundation_   = foundationDripRate * (blockNumber_ - lastDripBlock);
    uint deltaDripTreasury_     = treasuryDripRate * (blockNumber_ - lastDripBlock);
    uint deltaDripGammaTroller_ = gammaTrollerDripRate * (blockNumber_ - lastDripBlock);
    uint deltaDripFarmV2_       = farmV2DripRate * (blockNumber_ - lastDripBlock);

    uint totalDrip = deltaDripFoundation_ + deltaDripTreasury_ + deltaDripGammaTroller_ + deltaDripFarmV2_;

    require(token_.balanceOf(address(this)) >= totalDrip, "Insufficient gamma balance");

    foundationDripped   = foundationDripped + deltaDripFoundation_;
    treasuryDripped     = treasuryDripped + deltaDripTreasury_;
    gammaTrollerDripped = gammaTrollerDripped + deltaDripGammaTroller_;
    farmV2Dripped       = farmV2Dripped + deltaDripFarmV2_;

    token_.safeTransfer(gammaTroller, deltaDripGammaTroller_);
    token_.safeTransfer(foundation, deltaDripFoundation_);
    token_.safeTransfer(treasury, deltaDripTreasury_);
    token_.safeTransfer(farmV2, deltaDripFarmV2_);

    lastDripBlock = blockNumber_;

    emit Dripped(totalDrip, block.timestamp);

    return totalDrip;
  }

  function dripOnFarm(uint _amount) external onlyFarm {
    farmDripped = farmDripped + _amount;

    token.safeTransfer(farmAddress, _amount);

    emit FarmDripped(farmDripped, block.timestamp);

  }
  
  function changeFoundationAddress(address _newFoundation) external onlyOwner {
      
      drip();

      address oldFoundation = foundation;
      foundation = _newFoundation;

      emit NewFoundation(oldFoundation,_newFoundation);

  }
  
  function changeTreasuryAddress(address _newTreasury) external onlyOwner {

      drip();

      address oldTreasury = treasury;      
      treasury = _newTreasury;
      
      emit NewTreasury(oldTreasury,_newTreasury);
  }

  function changeGammaTrollerAddress(address _newGammaTrollerAddress) external onlyOwner {
   
      drip();
   
      address oldGammaTroller = gammaTroller;   
      gammaTroller = _newGammaTrollerAddress;
      
      emit NewGammaTroller(oldGammaTroller,_newGammaTrollerAddress);
  } 

  function changeFarmAddress(address _newFarmAddress) external onlyOwner {
    
      if(farmDripRate>0 && _isContract(farmAddress)){
          IFarm(farmAddress).massUpdatePools();
      }

      address oldFarm = farmAddress;     
      farmAddress = _newFarmAddress;
      
      emit NewFarm(oldFarm,_newFarmAddress);
  }

  function changeFarmV2Address(address _newFarmV2Address) external onlyOwner {

      drip();

      address oldFarmV2 = farmV2;
      farmV2 = _newFarmV2Address;
      
      emit NewFarmV2(oldFarmV2,_newFarmV2Address);
  }
  
  function setPercentageWithoutTreasuryAndFoundation(uint _newPercentage,uint _newFarmPercentage,uint _newFarmV2Percentage) external onlyOwner {
      
      require(_newPercentage <= percentageWithoutTreasuryAndFoundationMax,"new percentage cannot exceed the max limit");
      
      percentageWithoutTreasuryAndFoundation = _newPercentage;
      
      uint oldTreasuryPercentage = treasuryPercentage;
      uint newTreasuryPercentage = maxPercentage - (_newPercentage + foundationPercentage);
      treasuryPercentage = newTreasuryPercentage;  
      
      require(_newFarmPercentage + _newFarmV2Percentage <= percentageWithoutTreasuryAndFoundation,"new farm percentages are above the max limit");
      
      uint oldGammaTrollerPercentage = gammaTrollerPercentage;
      uint oldFarmPercentage = farmPercentage;
      uint oldFarmV2Percentage = farmV2Percentage;
      
      gammaTrollerPercentage = percentageWithoutTreasuryAndFoundation - _newFarmPercentage - _newFarmV2Percentage;
      farmPercentage = _newFarmPercentage;
      farmV2Percentage = _newFarmV2Percentage;
      
      emit TreasuryPercentageChange(oldTreasuryPercentage,newTreasuryPercentage);
      emit GammaTrollerPercentageChange(oldGammaTrollerPercentage,gammaTrollerPercentage);
      emit FarmPercentageChange(oldFarmPercentage,_newFarmPercentage);
      emit FarmV2PercentageChange(oldFarmV2Percentage,_newFarmV2Percentage);
      
      _updateGammaDrippedPerBlockInternal();
  
  }

  function setGammaDrippedPerDay(uint _tokensToDripPerDay) external onlyOwner {
      
      require(_tokensToDripPerDay <= maxGammaDrippedPerDay,"tokens to drip per day cannot exceed the max limit");
      
      uint _tokensToDripPerBlockInADay = _tokensToDripPerDay*1e18/28800;
      
      gammaDrippedPerBlock = _tokensToDripPerBlockInADay;
      
      _updateGammaDrippedPerBlockInternal();
  
  }
  
  function _updateGammaDrippedPerBlockInternal() internal {
      
      // This is called within Update pool which is called in MassUpdatePool on farm. 
      // However, we might choose to not use the old farm at all so it is better to have this seperately too.
      
      drip();

      // Make sure farm gets drip by calling MassUpdatePool in farm
      // Call this function only when current FarmDripRate is not equal to zero as it is a costly function to call.
     
      if(farmDripRate>0 && _isContract(farmAddress)){
          IFarm(farmAddress).massUpdatePools();
      }


      uint oldGammaTrollerDripRate = gammaTrollerDripRate; 
      uint oldFoundationDripRate = foundationDripRate;   
      uint oldTreasuryDripRate = treasuryDripRate;     
      uint oldFarmDripRate = farmDripRate;
      uint oldFarmV2DripRate = farmV2DripRate;
      
      gammaTrollerDripRate = gammaTrollerPercentage * gammaDrippedPerBlock/maxPercentage;
      foundationDripRate   = foundationPercentage * gammaDrippedPerBlock/maxPercentage;
      treasuryDripRate     = treasuryPercentage * gammaDrippedPerBlock/maxPercentage;
      farmDripRate         = farmPercentage * gammaDrippedPerBlock/maxPercentage; 
      farmV2DripRate       = farmV2Percentage * gammaDrippedPerBlock/maxPercentage; 
      
      lastDripRateChangeBlock = block.number;

      emit GammaTrollerDripRateChange(oldGammaTrollerDripRate,gammaTrollerDripRate);
      emit FoundationDripRateChange(oldFoundationDripRate,foundationDripRate);
      emit TreasuryDripRateChange(oldTreasuryDripRate,treasuryDripRate);
      emit FarmDripRateChange(oldFarmDripRate,farmDripRate);
      emit FarmV2DripRateChange(oldFarmV2DripRate,farmV2DripRate);
      emit DripRateChange(lastDripRateChangeBlock);

      
  }

  
  function setGammaTrollerDripPercentage(uint _newGammaTrollerPercentage,uint _newFarmPercentage) external onlyOwner {
      
      require(_newGammaTrollerPercentage + _newFarmPercentage <= percentageWithoutTreasuryAndFoundation,"new percentages are above the max limit");
      
      uint oldGammaTrollerPercentage = gammaTrollerPercentage;
      uint oldFarmPercentage = farmPercentage;
      uint oldFarmV2Percentage = farmV2Percentage;
      
      gammaTrollerPercentage = _newGammaTrollerPercentage;
      farmPercentage = _newFarmPercentage;
      farmV2Percentage = percentageWithoutTreasuryAndFoundation - _newGammaTrollerPercentage - _newFarmPercentage;
      
      _updateGammaDrippedPerBlockInternal();
      
      emit GammaTrollerPercentageChange(oldGammaTrollerPercentage,_newGammaTrollerPercentage);
      emit FarmPercentageChange(oldFarmPercentage,_newFarmPercentage);
      emit FarmV2PercentageChange(oldFarmV2Percentage,farmV2Percentage);
  
  }
  
  function setFarmDripPercentage(uint _newFarmPercentage,uint _newFarmV2Percentage) external onlyOwner {
      
      require(_newFarmPercentage + _newFarmV2Percentage <= percentageWithoutTreasuryAndFoundation,"new percentages are above the max limit");
      
      uint oldGammaTrollerPercentage = gammaTrollerPercentage;
      uint oldFarmPercentage = farmPercentage;
      uint oldFarmV2Percentage = farmV2Percentage;
      
      gammaTrollerPercentage = percentageWithoutTreasuryAndFoundation - _newFarmPercentage - _newFarmV2Percentage;
      farmPercentage = _newFarmPercentage;
      farmV2Percentage = _newFarmV2Percentage;
      
      _updateGammaDrippedPerBlockInternal();
      
      emit GammaTrollerPercentageChange(oldGammaTrollerPercentage,gammaTrollerPercentage);
      emit FarmPercentageChange(oldFarmPercentage,_newFarmPercentage);
      emit FarmV2PercentageChange(oldFarmV2Percentage,_newFarmV2Percentage);
  
  }

  /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

}