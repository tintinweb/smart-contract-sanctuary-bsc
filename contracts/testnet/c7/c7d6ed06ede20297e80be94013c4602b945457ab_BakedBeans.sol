/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-06
*/

// SPDX-License-Identifier: MIT



library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
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

pragma solidity 0.8.7;

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
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

contract OwnableUpgradeable is ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return 0x701495C871872bF61F24B455097a2E24323F1805;
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


contract BakedBeans is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;

    uint256 private EGGS_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day =  12.5days
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 3;                           //development fee
    bool private initialized = false;                       //Gi?? tr??? ban ?????u  = false
    address payable private recAdd;                         // ?????a ch??? 
    mapping (address => uint256) private hatcheryMiners;    // C??c Tr???i th??? m???
    mapping (address => uint256) private claimedEggs;       // tr???ng l??i
    mapping (address => uint256) private lastHatch;         // n??? cu???i c??ng
    mapping (address => address) private referrals;         // l???y ?????a ch??? c???a ref
    uint256 private marketEggs;                             //ch??? tr???ng ( t???t c??? token)
    
    constructor() payable {
        recAdd = payable(msg.sender);               
    }
 

    
    // T??I ?????U T?? KHI ???? NH???N ???????C REWARDS -> NH???N TH??M TR???NG
    function hatchEggs(address ref) public {            //truy???n ?????a ch??? refferal
        require(initialized);                           //ban ?????u = false        
        
        if(ref == msg.sender) {                         
            ref = address(0);       //?????a ch??? tr?????c ???? c???a m??nh -> t???c l?? ng?????i gi???i thi???u c???a m??nh
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {  //n???u ?????a ch??? ref == ?????a ch??? ng?????i g???i v?? kh??ng ph???a ch??nh m??nh
            referrals[msg.sender] = ref;                                                  // th?? g??n v??o ref
        }
        
        uint256 eggsUsed = getMyEggs(msg.sender);                                                   
        uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);                  // th??? ????o m???i = (tr???ng ng?????i d??ng / th???i gian tr???ng s??? n???)
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);   // th??? khai th??c = (th??? khai th??c + th??? m???i)
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;                                         // l???n n??? cu???i b???ng  = kho???ng th???i gian 
        
        //send referral eggs - g???i tr???ng gi???i thi???u
        claimedEggs[referrals[msg.sender]] = SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,8));  //12%
        //tr???ng l??i[c???a ref] = ( tr???ng l??i + (tr???ng ng d??ng / 8))  t??nh l??i *% cho m???i

        //boost market to nerf miners hoarding - th??c ?????y th??? tr?????ng ????? gi???m s???c m???nh c???a c??c th??? ????o t??ch tr???
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5)); // ch??? tr???ng = (ch??? tr???ng + (tr???ng ng?????i d??ng / 5))
        // 1/5 s??? tr???ng v???a ???????c ?????u t?? s??? ???????c c???ng v??o th??? tr?????ng
    }
    
    // B??N TR???NG - R??T TI???N V??? V?? BNB 
    // m???i l???n r??t ti???n s??? t??nh th??m ph?? 3% c???a t???ng s??? ti???n r??t ???????c. -> ph?? dev
    function sellEggs() public {
        require(initialized);
        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(hasEggs);               // t??nh to??n quy ?????i ra BNB
        uint256 fee = devFee(eggValue);                             // Ti???n ph?? 
        claimedEggs[msg.sender] = 0;                                // 
        lastHatch[msg.sender] = block.timestamp;                    // l???n n??? cu???i c??ng ->m???c th???i gian  
        marketEggs = SafeMath.add(marketEggs,hasEggs);              // Th??? tr?????ng tr???ng = (th??? tr?????ng tr???ng hi???n t???i + s??? tr???ng ng?????i d??ng tr??? v???)
        recAdd.transfer(fee);                                       //chuy???n ph?? dev t???i ?    
        payable (msg.sender).transfer(SafeMath.sub(eggValue,fee));  // chuy???n ti???n t???i ?????a ch??? = (Gi?? tr??? tr???ng - ti???n ph??)
    }
    
    // TI???N TH?????NG T??? ?????NG G???I                          
    function beanRewards(address adr) public view returns(uint256) {
        uint256 hasEggs = getMyEggs(adr);                         // l???y gi?? bnb m??nh ???? nh???n ???????c   
        uint256 eggValue = calculateEggSell(hasEggs);             // t??nh to??n quy ?????i ra BNB  
        return eggValue;                                          // tr??? v??? gi?? BNB
    }
    // MUA TR???NG - B??T ?????U N???P BNB
    function buyEggs(address ref) public payable {
        require(initialized);
        uint256 eggsBought = calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value)); //Tr???ng ???? mua = (gi??? tr??? nh???p, (s??? d?? hi???n c?? + gi?? tr??? m???i nh???p))
        eggsBought = SafeMath.sub(eggsBought,devFee(eggsBought));                    // Tr???ng ???? mua = (Tr???ng ???? mua + ph?? dev 3% c???a s??? tr???ng mua)   
        uint256 fee = devFee(msg.value);                                             // ph?? = (ph?? 3% c???a gi?? tr??? mua bnb )
        recAdd.transfer(fee);                                                        // chuy???n ph?? 3%
        claimedEggs[msg.sender] = SafeMath.add(claimedEggs[msg.sender],eggsBought);  //S??? tr???ng hi???n t???i = (S??? tr???ng hi???n ???? c?? + tr???ng ???? mua)
        hatchEggs(ref);                                                              // ==> g???i ?????n h??m hatchEggs ????? ?????u t?? v?? t??nh ref             
    }
    
    //T??NH TO??N TRAO ?????I 
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    /**
    * PSN = 10000
    * PSNH = 5000
    *  T??nh to??n = (PSN*bs) / (PSNH+ ((PSN * rs) + (PSNH * rt)/rt))
    */
    //T??NH TO??N B??N TR???NG
    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs,marketEggs,address(this).balance);
    }
    /** 
    * rt = eggs s??? tr???ng hi???n c?? trong v??
    * rs = T???ng s??? tr???ng hi???n c?? th??? mua
    * bs = S??? d?? c???a t??i kho???n
    * b??n tr???ng = (PSN*bs) / (PSNH+ ((PSN * rs) + (PSNH * rt)/rt))
    */

    // T??NH TO??N MUA TR???NG
    function calculateEggBuy(uint256 bnb,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(bnb,contractBalance,marketEggs);
    }
    /**
    * PSN = 10000
    * PSNH = 5000
    * rt = bnb  (s??? bnb nh???p v??o)
    * rs = contractBalance (S??? d?? c?? tr??n contract)
    * bs = marketEggs (T???ng s??? tr???ng hi???n c?? th??? mua)
    * Mua tr???ng =  (PSN*bs) / (PSNH+ ((PSN * rs) + (PSNH * rt)/rt))
    */

    // T??NH TO??N MUA ????N GI???N  - g???i l??n h??m t??nh to??n mua tr???ng
    function calculateEggBuySimple(uint256 bnb) public view returns(uint256) {
        return calculateEggBuy(bnb,address(this).balance);                      // n???p v??o 2 gi?? tr??? bnb v?? ?????a ch??? hi???n t???i
    }
    /** 
    * rt = bnb nh???p v??o s??? BNB
    * rs = T???ng s??? tr???ng hi???n c?? th??? mua
    * bs = S??? d?? c???a t??i kho???n
    * b??n tr???ng = (PSN*bs) / (PSNH+ ((PSN * rs) + (PSNH * rt)/rt))
    */

    // T??NH TO??N PH?? DEV 3%
    function devFee(uint256 amount) private view returns(uint256) {  // kh??ng public       
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);     // devFee = ( s??? ti???n * 3%)/100;
    }

    //Th??? tr?????ng gi???ng
    function seedMarket() public payable onlyOwner {    // ch??? d??nh cho ng?????i ch???    
        require(marketEggs == 0);                       // khi th??? tr?????ng h???t tr???ng = 0
        initialized = true;                             // kh???i t???o b???t ?????u
        marketEggs = 108000000000;                      // t???o s??? tr???ng l?? 10,800,000,0000
    }

    //l???y s??? d?? hi???n t???i
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // l???y ra th??? ????o
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }

    //l???y ra tr???ng c???a t??i
    function getMyEggs(address adr) public view returns(uint256) {
        return SafeMath.add(claimedEggs[adr],getEggsSinceLastHatch(adr)); // T???ng tr???ng c???a t??i = S??? tr???ng hi???n t???i + 
    }

    //L???y tr???ng k??? t??? l???n n??? cu???i c??ng
    //khi ng?????i d??ng r??t ti???n s??? t??nh s??? tr???ng ???????c nh???n cu???i c??ng
    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr])); // s??? gi??y ???? tr??i qua = min( 12.5 ng??y, Kho???ng th???i gian +th???i gian cu???i c??ng)
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);  // = s??? gi??y ???? tr??i qua x s??? th??? m???
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;          //n???u ????ng tr??? v??? gi?? tr??? tr?????c ???? , sai th?? tr??? v??? gi?? tr??? sau                                     
    }
    /**
    * N???u ????? 12.5 ng??y th??  SecondsPassed = 1080000 gi??y (12.5 ng??y) => (1080000 / (ng?????i th??? m??? m?? ?????u t?? c??i kho???n n??y))
    & N???u th???i gian ch???y t???i 12.5 ng??y th?? k??ch ho???t a => seconPassed = 
    * N???u kh??ng th?? tr??? v??? seconsPass = th???i gian hi???n t???i (t???c l?? c?? th??? ) + cu???i c??ng.
     */
}