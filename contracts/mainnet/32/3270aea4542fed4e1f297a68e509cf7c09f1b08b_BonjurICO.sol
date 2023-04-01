/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.11;

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
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: @pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol

pragma solidity ^0.6.11;

interface readContract {
    function users(address) external view returns (bool   ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  ,uint256  );
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

pragma solidity ^0.6.11;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

pragma solidity >=0.6.0 <0.8.0;


library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

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
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

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
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    uint256[49] private __gap;
}

pragma solidity >=0.6.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract BonjurICO is ContextUpgradeable, OwnableUpgradeable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    // Info of each user.
    struct UserInfo {
        bool isExist;
        address referral;
    }
    mapping(address => UserInfo) public userInfo;
    address public owneraddress;
    address public receiver;
    uint256 public tokenbusdprice;
    AggregatorV3Interface public priceProvider;
    readContract public BonjourContract;
    IBEP20 public busdToken;
    IBEP20 public rewardToken;
    IBEP20 public oldToken;
    uint256 public totalrewardtoken;
    uint256 public referralfee;

    constructor() public {}

    function initialize(
        IBEP20 _busdToken,
        IBEP20 _rewardToken,
        IBEP20 _oldtoken,
        readContract _bonjour,
        uint256 _tokenbusdprice,
        uint256 _referralfee,
        AggregatorV3Interface pp,
        address _receiver
    ) public initializer {
        rewardToken = _rewardToken;
        busdToken = _busdToken;
        tokenbusdprice = _tokenbusdprice;
        owneraddress = _receiver;
        BonjourContract = _bonjour;
        oldToken = _oldtoken;
        receiver = _receiver;
        referralfee = _referralfee;
        priceProvider = pp;
        __Ownable_init();
    }

    function depositBUSD(uint256 _amount, address _refer) public {
        readContract bonjourReg = readContract(BonjourContract);
        (bool isExist ,  ,  ,  , , , , , , , , , , ) = bonjourReg.users(msg.sender);
        require(isExist,"User not exit in Bonjour site");
        (bool isrefExist ,  ,  ,  , , , , , , , , , , ) = bonjourReg.users(_refer);
        require(isrefExist,"Referral Wallet not exit in Bonjour site");
        if(userInfo[msg.sender].isExist){
            require(userInfo[msg.sender].referral == _refer,"Referral Mismatched");
        }else{
            require(userInfo[msg.sender].referral != msg.sender,"Both referral and user are same");
            userInfo[msg.sender].isExist = true;
            userInfo[msg.sender].referral = _refer;
        }
        require(_amount > 0, "need amount > 0");
        busdToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        busdToken.transfer(receiver, _amount);
        uint256 perToken = tokenbusdprice.mul(_amount);
        uint256 swapToken = perToken.div(1000000);
        uint256 percentamt = swapToken.mul(referralfee);
        uint256 referralamt = percentamt.div(1000000);
        rewardToken.transfer(userInfo[msg.sender].referral,referralamt);
        rewardToken.transfer(msg.sender, swapToken);
    }

    function depositBNB(address _refer) public payable {
        readContract bonjourReg = readContract(BonjourContract);
        (bool isExist ,  ,  ,  , , , , , , , , , , ) = bonjourReg.users(msg.sender);
        require(isExist,"User not exit in Bonjour site");
        (bool isrefExist ,  ,  ,  , , , , , , , , , , ) = bonjourReg.users(_refer);
        require(isrefExist,"Referral Wallet not exit in Bonjour site");
        if(userInfo[msg.sender].isExist){
            require(userInfo[msg.sender].referral == _refer,"Referral Mismatched");
        }else{
            require(userInfo[msg.sender].referral != msg.sender,"Both referral and user are same");
            userInfo[msg.sender].isExist = true;
            userInfo[msg.sender].referral = _refer;
        }
        require(msg.value > 0, "need amount > 0");
        payable(receiver).transfer(msg.value);
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 currentPrice = uint256(latestPrice);
        uint256 perBnb = currentPrice / 100000000;
        uint256 _amount = perBnb * msg.value;
        uint256 perToken = tokenbusdprice.mul(_amount);
        uint256 swapToken = perToken.div(1000000);
        uint256 percentamt = swapToken.mul(referralfee);
        uint256 referralamt = percentamt.div(1000000);
        rewardToken.transfer(userInfo[msg.sender].referral,referralamt);
        rewardToken.transfer(msg.sender, swapToken);
    }

    function getTokenfromBusd(uint256 _amount) public view returns (uint256) {
        uint256 perToken = tokenbusdprice.mul(_amount);
        return perToken.div(1000000);
    }

    function getTokenfromBnb(uint256 _amount) public view returns (uint256) {
        uint256 bnbAmount = _amount / 100000000;
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 currentPrice = uint256(latestPrice);
        uint256 perBnb = currentPrice / 100000000;
        uint256 _bnbamount = perBnb * bnbAmount;
        uint256 perToken = tokenbusdprice.mul(_bnbamount);
        return perToken.div(1000000);
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function getBnbPrice() public view returns (uint256) {
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 currentPrice = uint256(latestPrice) * 100000000;
        return currentPrice;
    }

    function safeWithDrawBNJR(uint256 _amount, address addr) public {
        require(msg.sender == owneraddress, "Not Owner");
        rewardToken.transfer(addr, _amount);
    }

    function safeWithDrawBusd(uint256 _amount, address addr) public {
        require(msg.sender == owneraddress, "Not Owner");
        busdToken.transfer(addr, _amount);
    }

    function safeWithDrawBNB(address payable _toUser, uint256 _amount)
        public
        returns (bool)
    {
        require(msg.sender == owneraddress, "only Owner Wallet");
        require(_toUser != address(0), "Invalid Address");
        (_toUser).transfer(_amount);
        return true;
    }

    function getTokenprice() public view returns (uint256) {
        return tokenbusdprice;
    }

    function settoken(uint256 price) public {
        require(msg.sender == _owner, "Not Owner");
        tokenbusdprice = price;
    }

    function setReceiver(address newreceiver) public {
        require(msg.sender == owneraddress, "Not Owner");
        receiver = newreceiver;
    }

    function setOwner(address newOwner) public {
        require(msg.sender == owneraddress, "Not Owner");
        owneraddress = newOwner;
    }

    function setrewardToken(IBEP20 _rewardToken) public {
        require(msg.sender == owneraddress, "Not Owner");
        rewardToken = _rewardToken;
    }

    function updatereferral(uint _fee) public onlyOwner {
      referralfee = _fee; //extra with 4 zero
    }

    function airdropNewTokens() public {
        uint256 oldTokenBalance = oldToken.balanceOf(msg.sender);
        require(oldTokenBalance > 0, "You don't have any old tokens to exchange");
        bool success = oldToken.transferFrom(msg.sender, address(this), oldTokenBalance);
        require(success, "Failed to transfer old tokens to contract");
        bool newTokenSuccess = rewardToken.transfer(msg.sender, oldTokenBalance);
        require(newTokenSuccess, "Failed to transfer new tokens to user");
    }
}