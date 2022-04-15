// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../common/Address.sol";
import "../common/SafeMath.sol";
import "../common/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
struct Tier {
  uint8 id;
  string name;
  uint256 price;
  uint32 sgryBR;
}

struct Assets {
  uint32 id;
  uint8 tI;
  string title;
  address owner;
  uint32 crdT;
  uint32 limT;
  uint32 sgryR;
}

struct PackTier {
  uint8 id;
  string name;
  uint256 price;
  uint32 qtt;
  uint8 pre;
}

struct Pack {
  uint32 id;
  uint8 pTI;
  address owner;
  uint32 crT;
  bool cld;
}

contract MarketPlace is Initializable {
  using SafeMath for uint256;
  address public tokenAddress;
  address public liquidityAddress;
  address public operationsPoolAddress;

  Tier[] private tierArr;
  PackTier[] private packTierArr;
  mapping(string => uint8) public tierMap;
  mapping(string => uint8) public packTierMap;
  uint8 public tierTotal;
  uint8 public packTierTotal;
  //change to private
  Assets[] public assetsTotal;
  Pack[] public packsTotal;
  //change to private
  mapping(address => uint256[]) public assetsOfUser;
  mapping(address => uint256[]) public packsOfUser;
  uint32 public countAssetTotal;
  uint32 public countPackTotal;
  mapping(address => uint32) public countOfAssetUser;
  mapping(address => uint32) public countOfPackUser;
  mapping(string => uint32) public countOfTier;
  mapping(string => uint32) public countOfPacks;
  mapping(string => bool) public availableFunctions;
  mapping(address => bool) public _isBlacklisted;
  mapping(address => bool) public _isWhitelisted;

  uint32 public transferFee; // 10%
  uint32 public rewardsPoolFee; // 60%
  uint32 public operationsPoolFee; // 40%
  uint32 public sgryBRUpt; // 0-Infinite

  uint32 public sellPricePercentage;

  address public owner;
  
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  event AssetMinted(address, string, uint32, uint32, uint32, uint32);
  event PackMinted(address, string, uint32, uint32, uint32, uint32);
  event AssetUpdated(address, string, string, uint32);
  event PackUpdated(address, string, string, uint32);
  event AssetTransfered(address, address, uint32);

  function initialize(address[] memory addresses) public initializer {
    tokenAddress = addresses[0];
    liquidityAddress = addresses[1];
    operationsPoolAddress = addresses[2];
    owner = msg.sender;

    addTier("chicken", 10 ether, 2);
    addTier("rabbit", 50 ether, 3);
    addTier("sheep", 50 ether, 4);
    addTier("goat", 50 ether, 5);
    addTier("pig", 50 ether, 6);
    addTier("cow", 100 ether, 10);

    addPackTier("Pack 1", 50 ether, 20,1);
    addPackTier("Pack 2", 200 ether, 15,1);
    addPackTier("Pack 3", 250 ether, 10,1);
    addPackTier("Pack 4", 360 ether, 5,1);

    addPackTier("Pack Comun", 45 ether, 0,2);
    addPackTier("Pack Raro", 75 ether, 1000,2);
    addPackTier("Pack Esp", 140 ether, 500,2);
    addPackTier("Pack Leg", 300 ether, 100,2);

    transferFee = 1000; // 10%
    rewardsPoolFee = 2000; // 20%
    operationsPoolFee = 8000; // 80%
    sellPricePercentage = 25; // 25%
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(
        newOwner != address(0),
        "Ownable: new owner is the zero address"
    );
    owner = newOwner;
  }

  /**
    * @dev Update available functions.
    * Can only be called by the current owner.
    */
  function setFunctionAvailable(string memory functionName, bool value) public onlyOwner() {
      require(keccak256(abi.encodePacked(functionName)) != keccak256(abi.encodePacked("setFunctionAvailable")), "Cant disabled this function.");
      require(availableFunctions[functionName] == value, "Same value!");
      availableFunctions[functionName] = value;
  }

  function setAddressInBlacklist(address walletAddress, bool value) public onlyOwner() {
      _isBlacklisted[walletAddress] = value;
  }

  function setAddressInWhitelist(address walletAddress, bool value) public onlyOwner() {
      _isWhitelisted[walletAddress] = value;
  }

  function setAddressesInWhitelist(address[] memory walletAddresses) public onlyOwner() {
      for (uint i=0;i<walletAddresses.length;i++){
      _isWhitelisted[walletAddresses[i]] = true;
    }
  }

  function setSellPricePercentage(uint32 value) public onlyOwner {
    sellPricePercentage = value;
  }

  function setRewardsPoolFee(uint32 value) public onlyOwner {
    require(operationsPoolFee + value == 10000, "Total fee must be 100%");
    rewardsPoolFee = value;
  }

  function setLiquidityAddress(address account) public onlyOwner {
    liquidityAddress = account;
  }

  function setOperationsPoolFee(uint32 value) public onlyOwner {
    operationsPoolFee = value;
  }

  function setOperationsPoolAddress(address account) public onlyOwner {
    operationsPoolAddress = account;
  }
  
  function setTransferFee(uint32 value) public onlyOwner {
    //require(transferFee != value,"Same value!");
    transferFee = value;
  }

  function setTokenAddress(address token) public onlyOwner {
    tokenAddress = token;
  }

  function setCountOfPacks(string memory pTN, uint32 qtt) public onlyOwner {
    countOfPacks[pTN] = qtt;
  }

  function getTierByName(string memory tierName) public view returns (Tier memory) {
    //require(!availableFunctions["getTierByName"], "Disabled");
    Tier memory tierSearched;
    for (uint8 i = 0; i < tierArr.length; i++) {
      Tier storage tier = tierArr[i];
      if (keccak256(abi.encodePacked(tier.name)) == keccak256(abi.encodePacked(tierName))) tierSearched = tier;
    }
    return tierSearched;
  }

  function getPackTierByName(string memory packTierName) public view returns (PackTier memory) {
    //require(!availableFunctions["getTierByName"], "Disabled");
    PackTier memory tierSearched;
    for (uint8 i = 0; i < packTierArr.length; i++) {
      PackTier storage pT = packTierArr[i];
      if (keccak256(abi.encodePacked(pT.name)) == keccak256(abi.encodePacked(packTierName))) tierSearched = pT;
    }
    return tierSearched;
  }

  function addTier(
    string memory name,
    uint256 price,
    uint32 sgryBR
  ) public onlyOwner {
    require(price > 0, "Tier's price has to be positive.");
    tierArr.push(
      Tier({
	      id: uint8(tierArr.length),
        name: name,
        price: price,
        sgryBR: sgryBR
      })
    );
    tierMap[name] = uint8(tierArr.length);
    tierTotal++;
  }

  function addPackTier(
    string memory name,
    uint256 price,
    uint32 qtt,
    uint8 pre
  ) public onlyOwner {
    require(price > 0, "Pack's price has to be positive.");
    packTierArr.push(
      PackTier({
	      id: uint8(packTierArr.length),
        name: name,
        price: price,
        qtt: qtt,
        pre: pre
      })
    );
    packTierMap[name] = uint8(packTierArr.length);
    packTierTotal++;
  }

  function removeTier(string memory tierName) public onlyOwner {
    require(tierMap[tierName] > 0, "Tier was already removed.");
    tierMap[tierName] = 0;
    tierTotal--;
  }

  function removePackTier(string memory pTN) public onlyOwner {
    require(packTierMap[pTN] > 0, "Tier was already removed.");
    packTierMap[pTN] = 0;
    packTierTotal--;
  }

  function assets(address account) public view returns (Assets[] memory) {
    require(!availableFunctions["assets"], "Disabled");
    Assets[] memory assetsActive = new Assets[](countOfAssetUser[account]);
    uint256[] storage assetIndice = assetsOfUser[account];
    uint32 j = 0;
    for (uint32 i = 0; i < assetIndice.length; i++) {
      uint256 assetIndex = assetIndice[i];
      if (assetIndex > 0) {
        Assets storage asset = assetsTotal[assetIndex - 1];
        if (asset.owner == account) {
          assetsActive[j] = asset;
        }
      }
    }
    return assetsActive;
  }

  function packs(address account) public view returns (Pack[] memory) {
    require(!availableFunctions["packs"], "Disabled");
    Pack[] memory pckAct = new Pack[](countOfPackUser[account]);
    uint256[] storage pckId = packsOfUser[account];
    uint32 j = 0;
    for (uint32 i = 0; i < pckId.length; i++) {
      uint256 pckIdx = pckId[i];
      if (pckIdx > 0) {
        Pack storage pck = packsTotal[pckIdx - 1];
        if (pck.owner == account) {
          pckAct[j] = pck;
        }
      }
    }
    return pckAct;
  }

  function _create(
    address account,
    string memory tierName,
    string memory title,
    uint32 count
  ) private returns (uint256) {
    require(!_isBlacklisted[msg.sender],"Blacklisted");
    uint8 tierId = tierMap[tierName];
    Tier storage tier = tierArr[tierId - 1];
    for (uint32 i = 0; i < count; i++) {
      assetsTotal.push(
        Assets({
          id: uint32(assetsTotal.length),
          tI: tierId - 1,
          title: title,
          owner: account,
          crdT: uint32(block.timestamp),
          limT: uint32(block.timestamp)+ 30 days,
          sgryR: tier.sgryBR
        })
      );
      uint256[] storage assetsIndice = assetsOfUser[account];
      assetsIndice.push(assetsTotal.length);
    }
    countOfAssetUser[account] += count;
    countOfTier[tierName] += count;
    countAssetTotal += count;
    uint256 amount = tier.price.mul(count);
    return amount;
  }

  function _transferFee(uint256 amount) private {
    require(amount != 0,"Transfer token amount can't zero!");
    require(liquidityAddress != address(0),"Rewards pool can't Zero!");

    uint256 feeRewardPool = amount.mul(rewardsPoolFee).div(10000);
    IERC20(tokenAddress).transferFrom(address(msg.sender), address(liquidityAddress), feeRewardPool);
    uint256 feeOperationsPool = amount.mul(operationsPoolFee).div(10000);
    IERC20(tokenAddress).transferFrom(address(msg.sender), address(operationsPoolAddress), feeOperationsPool);
  }

  function mint(
    address[] memory accounts,
    string memory tierName,
    string memory title,
    uint32 count
  ) public onlyOwner {
    require(!availableFunctions["mint"], "Disabled");
    require(accounts.length>0, "Empty account list.");
    for(uint256 i = 0;i<accounts.length;i++) {
      _create(accounts[i], tierName, title, count);
    }
  }

  function buyPack(
    string memory pTN,
    uint32 count
  ) public {
    require(!_isBlacklisted[msg.sender],"Blacklisted");
    require(!availableFunctions["buyPack"], "Disabled");
    uint8 packTierId = packTierMap[pTN];
    PackTier storage packTier = packTierArr[packTierId - 1];
    // if(packTier.qtt > 0) {
    //   require((countOfPacks[pTN] + count) <= packTier.qtt, "This pack has sold out");
    // }
    for (uint32 i = 0; i < count; i++) {
      packsTotal.push(
        Pack({
          id: uint32(packsTotal.length),
          pTI: packTier.id,
          owner: msg.sender,
          crT: uint32(block.timestamp),
          cld: false
        })
      );
      uint256[] storage packIndice = packsOfUser[msg.sender];
      packIndice.push(packsTotal.length);
    }
    countOfPackUser[msg.sender] += count;
    countOfPacks[pTN] += count;
    countPackTotal += count;
    uint256 amount = packTier.price.mul(count);
    _transferFee(amount);
    emit PackMinted(
      msg.sender,
      pTN,
      count,
      countPackTotal,
      countOfPackUser[msg.sender],
      countOfPacks[pTN]
    );
  }

  function transfer(
    string memory tierName,
    uint32 count,
    address recipient
  ) public {
    require(!availableFunctions["transfer"], "Disabled");
    require(!_isBlacklisted[msg.sender],"Blacklisted");
    require(!_isBlacklisted[recipient],"Blacklisted recipient");
    uint8 tierIndex = tierMap[tierName];
    require(tierIndex > 0, "Invalid tier to transfer.");
    uint256[] storage assetIndiceFrom = assetsOfUser[msg.sender];
    uint256[] storage assetIndiceTo = assetsOfUser[recipient];
    uint32 countTransfer = 0;
    for (uint32 i = 0; i < assetIndiceFrom.length; i++) {
      uint256 assetIndex = assetIndiceFrom[i];
      if (assetIndex > 0) {
        Assets storage asset = assetsTotal[assetIndex - 1];
        if (asset.owner == msg.sender && tierIndex - 1 == asset.tI) {
          asset.owner = recipient;
          countTransfer++;
          assetIndiceTo.push(assetIndex);
          assetIndiceFrom[i] = 0;
          if (countTransfer == count) break;
        }
      }
    }
    require(countTransfer == count, "Not enough nodes.");
    countOfAssetUser[msg.sender] -= count;
    countOfAssetUser[recipient] += count;

    emit AssetTransfered(msg.sender, recipient, count);
  }

  function burnAssets(uint32[] memory indice) public onlyOwner {
    require(!availableFunctions["burnAssets"], "Disabled");
    uint32 count = 0;
    for (uint32 i = 0; i < indice.length; i++) {
      uint256 assetIndex = indice[i];
      if (assetIndex > 0) {
        Assets storage asset = assetsTotal[assetIndex];
        if (asset.owner != address(0)) {
          uint256[] storage assetIndice = assetsOfUser[asset.owner];
          for (uint32 j = 0; j < assetIndice.length; j++) {
            if (assetIndex == assetIndice[j]) {
              assetIndice[j] = 0;
              break;
            }
          }
          countOfAssetUser[asset.owner]--;
          asset.owner = address(0);
          Tier storage tier = tierArr[asset.tI];
          countOfTier[tier.name]--;
          count++;
        }
        // return a percentage of price to the owner
      }
    }
    countAssetTotal -= count;
  }

  function withdrawToken(address tokenAdd, uint256 amount) public onlyOwner {
    require(
      IERC20Upgradeable(tokenAdd).balanceOf(address(this)) >= amount,
      "Withdraw: Insufficent balance."
    );
    IERC20Upgradeable(tokenAdd).transfer(address(msg.sender), amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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

        (bool success,) = recipient.call{value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{value : value}(data);
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

pragma solidity ^0.8.11;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
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
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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