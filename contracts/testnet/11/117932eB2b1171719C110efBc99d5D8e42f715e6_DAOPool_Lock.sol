// SPDX-License-Identifier: MIT

/*
 **
 **
 **
 **
 ** DAO POOL LOCKED Contract
 */

 pragma solidity 0.8.0;

 import "./SafeMath.sol";
 import "./Context.sol";
 import "./IERC20.sol";
 
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
         return
             functionCallWithValue(
                 target,
                 data,
                 value,
                 "Address: low-level call with value failed"
             );
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
         require(
             address(this).balance >= value,
             "Address: insufficient balance for call"
         );
         require(isContract(target), "Address: call to non-contract");
 
         // solhint-disable-next-line avoid-low-level-calls
         (bool success, bytes memory returndata) = target.call{value: value}(
             data
         );
         return _verifyCallResult(success, returndata, errorMessage);
     }
 
     /**
      * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
      * but performing a static call.
      *
      * _Available since v3.3._
      */
     function functionStaticCall(address target, bytes memory data)
         internal
         view
         returns (bytes memory)
     {
         return
             functionStaticCall(
                 target,
                 data,
                 "Address: low-level static call failed"
             );
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
     function functionDelegateCall(address target, bytes memory data)
         internal
         returns (bytes memory)
     {
         return
             functionDelegateCall(
                 target,
                 data,
                 "Address: low-level delegate call failed"
             );
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
 
         // solhint-disable-next-line avoid-low-level-calls
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
 
 contract Ownable is Context {
     address private _owner;
     address private _previousOwner;
     uint256 private _lockTime;
 
     event OwnershipTransferred(
         address indexed previousOwner,
         address indexed newOwner
     );
 
     constructor() {
         address msgSender = _msgSender();
         _owner = msgSender;
         emit OwnershipTransferred(address(0), msgSender);
     }
 
     function owner() public view returns (address) {
         return _owner;
     }
 
     modifier onlyOwner() {
         require(_owner == _msgSender(), "Ownable: caller is not the owner");
         _;
     }
 
     function renounceOwnership() public virtual onlyOwner {
         emit OwnershipTransferred(_owner, address(0));
         _owner = address(0);
     }
 
     function transferOwnership(address newOwner) public virtual onlyOwner {
         require(
             newOwner != address(0),
             "Ownable: new owner is the zero address"
         );
         emit OwnershipTransferred(_owner, newOwner);
         _owner = newOwner;
     }
 
     function getUnlockTime() public view returns (uint256) {
         return _lockTime;
     }
 
     function getTime() public view returns (uint256) {
         return block.timestamp;
     }
 
     function lock(uint256 time) public virtual onlyOwner {
         _previousOwner = _owner;
         _owner = address(0);
         _lockTime = block.timestamp + time;
         emit OwnershipTransferred(_owner, address(0));
     }
 
     function unlock() public virtual {
         require(
             _previousOwner == msg.sender,
             "You don't have permission to unlock"
         );
         require(block.timestamp > _lockTime, "Contract is locked until 7 days");
         emit OwnershipTransferred(_owner, _previousOwner);
         _owner = _previousOwner;
     }
 }
 
 contract DAOPool_Lock is Context, Ownable {
     using SafeMath for uint256;
     using Address for address;
 
     address public token_address;
 
     address private _Dev_address = 0x978475818F1F2Cc59D99cc54De15B58E59388930;
     address public Dev_address = _Dev_address;
 
     event RemoveFromLockEvent(address indexed adrx, uint256 amount);
     event RemoveFromLockWithFeeEvent(address indexed addrs, uint256 Useramout, uint256 FeeForDev);
     event ChangeDevAddressEvent(
         address indexed OldAddress,
         address indexed NewAddress
     );
     event ChangeMustPayEvent(uint256 OldMustPay, uint256 NewMustPay);
     mapping(address => uint256)  TokenLockedPerson;
     mapping(address => uint256)  Persontimer;
 
     uint256 public lockedToken = 0;
     uint256 private _lockedToken = 0;
 
     uint256 private _LockedToken_fee = 0;
 
     uint256 private day = 604800; // 300 sec, change it to day = in seconds
 
     uint256 private tokenPersonLocked = 0; // what is this?
     uint256 public MustPay = 0;
 
     IERC20 public tokenx;
 
     constructor(address _token_address) {
         tokenx = IERC20(address(_token_address));
         token_address = _token_address;
         MustPay = 1 * 10**tokenx.decimals();
     }
 
     function TransferToken(uint256 amount) public {
         uint256 howmuch = HowMuchTokenMustPay();
         require(
             tokenx.balanceOf(_msgSender()) >= amount,
             "Your balance not Enough"
         );
         uint256 allowance = tokenx.allowance(msg.sender, address(this));
         require(allowance >= howmuch, "Check the token allowance tokenmustpay");
         require(allowance >= amount, "Check the token allowance");
         require(amount >= howmuch, "Your Token not Enough");
         return _TransferToken(_msgSender(), amount);
     }
 
     function _TransferToken(address _adrt, uint256 _amount) private {
         require(_amount > 0);
         uint256 balancebefore = tokenx.balanceOf(address(this));
         tokenx.transferFrom(_adrt, address(this), _amount);
         uint256 balanceafter = tokenx.balanceOf(address(this));
         _amount = balanceafter - balancebefore;
         TokenLockedPerson[_adrt] = TokenLockedPerson[_adrt].add(_amount);
         lockedToken = lockedToken.add(_amount);
         Persontimer[_adrt] = block.timestamp;
     }
 
     function RemovefromLocked(uint256 amount) public {
         require(TokenLockedPerson[_msgSender()] > 0, "Not enough locked tokens");
         require(
             TokenLockedPerson[_msgSender()] >= amount,
             "You Have not Enough Token"
         );
         _RemovefromLocked(amount);
     }
 
     function _RemovefromLocked(uint256 _amount) private {
         uint256 diff_time = TimeDifferential(_msgSender());
         TokenLockedPerson[_msgSender()] = TokenLockedPerson[_msgSender()]
                 .sub(_amount);
         lockedToken = lockedToken.sub(_amount);
         if (diff_time < day) {
             uint256 _personAmount = _amount.mul(900).div(1000);
             uint256 _Dev_fee = _amount.sub(_personAmount);
             tokenx.transfer(_msgSender(), _personAmount);
             tokenx.transfer(_Dev_address, _Dev_fee);
             emit RemoveFromLockWithFeeEvent(_msgSender(), _personAmount, _Dev_fee);
         } else {
             tokenx.transfer(_msgSender(), _amount);
             emit RemoveFromLockEvent(_msgSender(), _amount);
         }
     }
 
     function TokencLockedCheckView(address adr) public view returns (uint256) {
         return TokenLockedPerson[adr];
     }
 
     function HowMuchTokenMustPay() public view returns (uint256) {
         return MustPay;
     }
 
     function ChangeMustpayValue(uint256 newMustPay) external onlyOwner returns (uint256){
         require(newMustPay >= 0, "Can't set Zero Value");
         return _ChangeMustpayValue(newMustPay);
     }
 
     function _ChangeMustpayValue(uint256 _newMustPay) private returns (uint256) {
         emit ChangeMustPayEvent(MustPay, _newMustPay);
         MustPay = _newMustPay;
         return MustPay;
     }
 
     function TimeDifferential(address _addr) public view returns(uint256){
         uint256 now_tim = block.timestamp;
         uint256 diff = now_tim - Persontimer[_addr];
         return diff;
     }
 
     function ChangeDevAddress(address adrs) external onlyOwner returns(bool) {
         return _ChangeDevAddress(adrs);
     }
 
     function _ChangeDevAddress(address _adrs) private returns(bool) {
         emit ChangeDevAddressEvent(_Dev_address, _adrs);
         _Dev_address = _adrs;
         return true;
     }
 }