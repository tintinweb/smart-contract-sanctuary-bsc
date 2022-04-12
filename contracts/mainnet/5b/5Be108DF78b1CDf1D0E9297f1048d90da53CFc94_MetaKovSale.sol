// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "../interfaces/IPair.sol";
import "../helpers/Ownable.sol";
import "../utils/SafeBEP20.sol";
import "../utils/SafeMath.sol";

contract MetaKovSale is Ownable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;
    
    event MKVTransferred(address _holder, uint256 _amount);
    
    struct Investments {
        address _investor;
        uint256 _mkvAmount;
        uint256 _busdAmount;
        bool    _isBNB;
    }
    
    struct Investment {
        address _investor;
        uint256 _mkvAmount;
        uint256 _mkvClaimed;
        uint256 _mkvStaked;
        uint256 _busdAmount;
        uint _lastClaimed;
        uint _lastInvested;
    }
    
    mapping (address => Investments[]) public _investors;
    mapping (address => Investment) public _invested;
    mapping (address => uint256) public _totalInvestment;
    
    Investments[] public _allInvestments;
    
    uint256 public _bnbRaised;
    uint256 public _busdRaised;
    uint256 public _mkvSold;
    uint256 public _mkvSell;
    
    IPair public _bnbPair;
    uint256 public MIN_INVEST = 10 * 1e18;
    IBEP20 public MKV;
    IBEP20 public BUSD;
    uint256 public _mkvRate = 0.50 * 1e18;
    uint256 public _lockedInterval = 30 days;
    uint256 public _initialReturn = 25;
    bool public _isSaleLive = false;
    
    modifier onlyWhenSaleIsLive {
        require(_isSaleLive, "[!] Seed Sale For MKV Token is not Live");
        _;
    }
    
    constructor(IPair bnbPair, IBEP20 _mkv, IBEP20 _busd) {
        _bnbPair = bnbPair;
        MKV = _mkv;
        BUSD = _busd;
        _isSaleLive = true;
    }
    
    function changeSaleState() external onlyOwner {
        _isSaleLive = !_isSaleLive;
    }
    
    function changeMinInvest(uint256 value) external onlyOwner {
        MIN_INVEST = value;
    }
    
    function changeMKVRate(uint256 value) external onlyOwner {
        _mkvRate = value;
    }
    
    function changeMKV(IBEP20 mkv) external onlyOwner {
        MKV = mkv;
    }
    
    function changeBUSD(IBEP20 busd) external onlyOwner {
        BUSD = busd;
    }
    
    function changeInterval(uint256 value) external onlyOwner {
        _lockedInterval = value;
    }
    
    function getTotalInvestment() external view returns (uint) {
        return _allInvestments.length;
    }
    
    function getInvestments(address _holder) external view returns (uint) {
        return _investors[_holder].length;
    }
    
    function _getBNBRate() internal view returns (uint256) {
        (uint256 res1, uint256 res2, ) = _bnbPair.getReserves();
        return res2.mul(1e18).div(res1);
    }
    
    function getBNBRate() external view returns (uint256) {
        return _getBNBRate();
    }
    
    function _getMKVValue(uint256 _busdValue) internal view returns (uint256) {
        return (_busdValue.mul(1e18).div(_mkvRate));
    }
    
    function getMKVValue(uint256 _busdValue) external view returns (uint256) {
        return _getMKVValue(_busdValue);
    }
    
    function _transferMKV(uint256 _busdValue, address _mkvHolder, bool _isBNB) internal onlyWhenSaleIsLive {
        uint256 _mkvToSend = _getMKVValue(_busdValue);
        uint256 _mkvSent = _mkvToSend.mul(_initialReturn).div(1e2);
        MKV.safeTransfer(_mkvHolder, _mkvSent);
        uint256 mkvStaked = _mkvToSend.sub(_mkvSent);
        
        _totalInvestment[_mkvHolder] = _totalInvestment[_mkvHolder].add(_busdValue);
        Investments memory _investment = Investments(
            _mkvHolder,
            _mkvToSend,
            _busdValue,
            _isBNB
        );
        _invested[_mkvHolder]._investor = _mkvHolder;
        _invested[_mkvHolder]._mkvAmount = _invested[_mkvHolder]._mkvAmount.add(_mkvToSend);
        _invested[_mkvHolder]._mkvClaimed = _invested[_mkvHolder]._mkvClaimed.add(_mkvSent);
        _invested[_mkvHolder]._mkvStaked = _invested[_mkvHolder]._mkvStaked.add(mkvStaked);
        _invested[_mkvHolder]._busdAmount = _invested[_mkvHolder]._busdAmount.add(_busdValue);
        _invested[_mkvHolder]._lastClaimed = block.timestamp;
        _invested[_mkvHolder]._lastInvested = block.timestamp;
        
        _investors[_mkvHolder].push(_investment);
        _allInvestments.push(_investment);
        
        if(_isBNB){
            _bnbRaised = _bnbRaised.add(_busdValue.mul(1e18).div(_getBNBRate()));
        }
        else {
            _busdValue = _busdRaised.add(_busdValue);
        }
        _mkvSold = _mkvSold.add(_mkvToSend);
        _mkvSell = _mkvSell.add(_mkvSent);
        
        emit MKVTransferred(_mkvHolder, _mkvToSend);
    }
    
    function checkInvestValue(uint256 value) internal view {
        bool _returned = (value >= MIN_INVEST);
        require(_returned, "[!] Check minimum and maximum amount to invest");
    }
    
    function investBNB() external payable {
        uint256 bnbInvesting = msg.value;
        checkInvestValue(bnbInvesting.mul(_getBNBRate()).div(1e18));
        _transferMKV((bnbInvesting.mul(_getBNBRate()).div(1e18)), msg.sender, true);
    }
    
    function investBUSD(uint256 _amount) external {
        uint256 busdInvesting = _amount;
        checkInvestValue(busdInvesting);
        BUSD.safeTransferFrom(msg.sender, address(this), _amount);
        _transferMKV(busdInvesting, msg.sender, false);
    }
    
    function claimBNB() external onlyOwner {
        payable(msg.sender).transfer(payable(address(this)).balance);
    }
    
    function claimBUSD() external onlyOwner {
        BUSD.safeTransfer(msg.sender, BUSD.balanceOf(address(this)));
    }

    function claimRaised(address seedOwner) external onlyOwner {
        payable(seedOwner).transfer(payable(address(this)).balance);
        BUSD.safeTransfer(seedOwner, BUSD.balanceOf(address(this)));
    }
    
    // Section for locked assets claim after MIN Interval Period of Time with return % of the staked Assets
    
    function _canClaimInvestor(address _investor) internal view returns (bool) {
        uint lastClaimed = _invested[_investor]._lastClaimed;
        return lastClaimed.add(_lockedInterval) <= block.timestamp;
    }
    
    function canClaimInvestor(address _investor) external view returns (bool) {
        return _canClaimInvestor(_investor);
    }
    
    function _hasStakedAssets(address _investor) internal view returns (bool) {
        uint256 mkvStaked = _invested[_investor]._mkvStaked;
        return mkvStaked > 0;
    }
    
    function initClaimFor(address _investor) internal {
        uint256 invested = _invested[_investor]._mkvAmount;
        uint256 toClaim = invested.mul(_initialReturn).div(1e2);
        uint256 staked = _invested[_investor]._mkvStaked;
        MKV.safeTransfer(_investor, toClaim);
        if(toClaim > staked) {
            _invested[_investor]._mkvStaked = 0;
        }
        else {
            _invested[_investor]._mkvStaked = _invested[_investor]._mkvStaked.sub(toClaim);
        }
        _invested[_investor]._mkvClaimed = _invested[_investor]._mkvClaimed.add(toClaim);
        _invested[_investor]._lastClaimed = block.timestamp;
        _mkvSell = _mkvSell.add(toClaim);
        emit MKVTransferred(_investor, toClaim);
    }
    
    function claimLockedAssets() external {
        require(_canClaimInvestor(msg.sender), "[~] Cannot claim in locked time interval");
        require(_hasStakedAssets(msg.sender), "[!] No Staked MKV Found");
        initClaimFor(msg.sender);
    }
    
    function initClaimFromOwner(address _investor) external onlyOwner {
        initClaimFor(_investor);
    }
    
    // Emergency and Seed Sale Remaining Tokens
    
    function transferAnyMKV(address _owner, uint256 _amount) external onlyOwner {
        MKV.safeTransfer(_owner, _amount);
    }
    
    function transferUnSoldMKV(address _owner) external onlyOwner {
        MKV.safeTransfer(_owner, MKV.balanceOf(address(this)).sub(_mkvSold.sub(_mkvSell)));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import './Context.sol';

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
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
  function renounceOwnership() external onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) external onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "../interfaces/IBEP20.sol";
import "./SafeMath.sol";
import "../helpers/AddressHelper.sol";

library SafeBEP20 {
    using SafeMath for uint256;
    using Address2 for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
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

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract Context {
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library Address2 {
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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