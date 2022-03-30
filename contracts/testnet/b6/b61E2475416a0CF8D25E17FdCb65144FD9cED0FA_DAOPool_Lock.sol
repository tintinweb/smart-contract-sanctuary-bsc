// SPDX-License-Identifier: MIT

/*
 **
 **
 **
 **
 ** DAO POOL LOCKED Contract
 */

 pragma solidity 0.8.7;

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
 
     IERC20 public  tokenx; // Project Token
     address public token_address; // this Token
 
     address private Dev_address = 0x4a1fAC92414Ce682D32c6BD91c4853139384C0B1;
     address private Dead_address = 0x000000000000000000000000000000000000dEaD;
    

     event TransferTokenEvent(address indexed adrx, uint256 clientAmount,uint256 projectId);
     event RemoveFromLockEvent(address indexed adrx, uint256 clientAmount,uint256 projectId);
     event RemoveFromLockFeeEvent(address indexed addrs, uint256 clientAmount, uint256 feeDevAmount, uint256 projectId);
     event ChangeDevAddressEvent(
         address indexed OldAddress,
         address indexed NewAddress
     );
     event ChangeMinTokenDEvent(uint256 OldMinD, uint256 NewMinD);
     event ChangeMaxTokenDEvent(uint256 OldMaxD, uint256 NewMaxD);
     event ChangeProjectIdEvent(uint256 OldProjectId, uint256 NewProjectId);
     mapping(address => uint256)  TokenLockedClient;
     mapping(address => uint256)  ClientTimer;
     mapping(address => uint)     ClientRank;

     mapping(uint => uint256)  Rank;

     uint256 public   projectId       = 1;
     uint256 private  lockedDay       = 604800;// sec ( 7 day )
     uint256 public   lockedToken     = 0;
     uint256 public   lockedClient    = 0;
     uint256 private  minTokenD       = 0;
     uint256 private  maxTokenD       = 0;

   
  
     constructor(address _token_address) {

         tokenx = IERC20(address(_token_address));
         token_address = _token_address;
         minTokenD = 1 * 10**tokenx.decimals();
         maxTokenD = 100000000 * 10**tokenx.decimals();

         Rank[1] = 5000 * 10**tokenx.decimals();
         Rank[2] = 7500 * 10**tokenx.decimals();
         Rank[3] = 13000 * 10**tokenx.decimals();
         Rank[4] = 21000 * 10**tokenx.decimals();
         Rank[5] = 32000 * 10**tokenx.decimals();
         Rank[6] = 40000 * 10**tokenx.decimals();
     }


    function TransferToken(uint256 amount) public {
         require(
             maxTokenD >= (lockedToken + amount),
             "Top-up limit is exceeded"
         );
         require(
             tokenx.balanceOf(_msgSender()) >= amount,
             "Your balance not Enough"
         );
         uint256 allowance = tokenx.allowance(_msgSender(), address(this));
         require(allowance >= minTokenD, "Check the token allowance token minimal");
         require(allowance >= amount, "Check the token allowance");
         require(amount >= minTokenD, "Your Token not Enough");
         return _TransferToken(_msgSender(), amount);
    }
 
     function _TransferToken(address _adrt, uint256 _amount) private {
         require(_amount > 0);
         uint256 balancebefore = tokenx.balanceOf(address(this));
         tokenx.transferFrom(_adrt, address(this), _amount);
         uint256 balanceafter = tokenx.balanceOf(address(this));
         _amount = balanceafter - balancebefore;
         if(TokenLockedClient[_adrt] == 0){
             lockedClient = lockedClient.add(1);
         }
         TokenLockedClient[_adrt] = TokenLockedClient[_adrt].add(_amount);
         lockedToken = lockedToken.add(_amount);
         ClientTimer[_adrt] = block.timestamp;
         ClientRank[_adrt] = _CalcRank(TokenLockedClient[_adrt]);

         emit TransferTokenEvent(_adrt, _amount, projectId);
        
     }
 
     function RemovefromLocked(uint256 amount) public {
         require(TokenLockedClient[_msgSender()] > 0, "You Have not Locked");
         require(
             TokenLockedClient[_msgSender()] >= amount,
             "You Have not Enough Token"
         );
         _RemovefromLocked(_msgSender(), amount);
     }
 
     function _RemovefromLocked(address _adrt, uint256 _amount) private {
        
         uint256 diff_time = TimeDifferential(_adrt);
         TokenLockedClient[_adrt] = TokenLockedClient[_adrt]
                 .sub(_amount);
         lockedToken = lockedToken.sub(_amount);
         if (diff_time < lockedDay) {
             uint256 clientAmount = _amount.mul(900).div(1000);
             uint256 feeDevAmount = _amount.sub(clientAmount).div(2);
             tokenx.transfer(_adrt, clientAmount);
             tokenx.transfer(Dev_address, feeDevAmount);
             tokenx.transfer(Dead_address, feeDevAmount);
             emit RemoveFromLockFeeEvent(_adrt, clientAmount, feeDevAmount, projectId);      
         } else {
             tokenx.transfer(_adrt, _amount);
             emit RemoveFromLockEvent(_adrt, _amount, projectId);
         }
         if(TokenLockedClient[_adrt] == 0){
             lockedClient = lockedClient.sub(1);
         }
         ClientRank[_adrt] = _CalcRank(TokenLockedClient[_adrt]);

     }

    function _CalcRank(uint256 amount) private view returns (uint) {
        if(amount > 0){
            if (amount >= Rank[1] && amount < Rank[2]) {//Copper
                return 1;
            }else if (amount >= Rank[2]  && amount < Rank[3]) { //Bronze
                return 2;
            }else if (amount >= Rank[3] && amount < Rank[4]) {//Silver
                return 3;
            }else if (amount >= Rank[4] && amount < Rank[5]) {//Golden
               return 4;
            }else if (amount >= Rank[5] && amount < Rank[6]) {//Titanium
                return 5;
            }else if (amount >= Rank[6] ) {//Platinium
                return 6;
            }
        }
        return 0;
    }

     function ChangeProjectId(uint256 newProjectId) external onlyOwner returns (uint256){
         require(newProjectId > 0, "Can't set Zero Value");
         return _ChangeProjectId(newProjectId);
     }
 
     function _ChangeProjectId(uint256 _newProjectId) private returns (uint256) {
         emit ChangeProjectIdEvent(projectId, _newProjectId);
         projectId = _newProjectId;
         return projectId;
     }


	 
     function TokencLockedCheckView(address adr) public view returns (uint256) {
         return TokenLockedClient[adr];
     }

     function GetMinTokenD() public view returns (uint256) {
         return minTokenD;
     }

     function GetMaxTokenD() public view returns (uint256) {
         return maxTokenD;
     }

     function GetClientRank(address adr) public view returns (uint) {
         return ClientRank[adr];
     }
 
     function ChangeMinTokenDValue(uint256 newMinD) external onlyOwner returns (uint256){
         require(newMinD >= 0, "Can't set Zero Value");
         return _ChangeMinTokenDValue(newMinD);
     }
 
     function _ChangeMinTokenDValue(uint256 _newMinD) private returns (uint256) {
         emit ChangeMinTokenDEvent(minTokenD, _newMinD);
         minTokenD = _newMinD;
         return minTokenD;
     }

    function ChangeMaxTokenDValue(uint256 newMaxD) external onlyOwner returns (uint256){
         require(newMaxD >= 0, "Can't set Zero Value");
         return _ChangeMaxTokenDValue(newMaxD);
     }
 
     function _ChangeMaxTokenDValue(uint256 _newMaxD) private returns (uint256) {
         emit ChangeMaxTokenDEvent(maxTokenD, _newMaxD);
         maxTokenD = _newMaxD;
         return maxTokenD;
     }

 
     function TimeDifferential(address _addr) public view returns(uint256){
         uint256 now_tim = block.timestamp;
         uint256 diff = now_tim - ClientTimer[_addr];
         return diff;
     }

     function GetDevAddres() public view returns(address){
         return Dev_address;
     }
 
     function ChangeDevAddress(address adrs) external onlyOwner returns(bool) {
         return _ChangeDevAddress(adrs);
     }
 
     function _ChangeDevAddress(address _adrs) private returns(bool) {
         emit ChangeDevAddressEvent(Dev_address, _adrs);
         Dev_address = _adrs;
         return true;
     }

     function GetContract(address adrs) public view returns (
        string memory projectname, 
        string memory symbol , 
        address token, 
        address admin, 
        uint256[12] memory data) 
        {
        
            projectname = tokenx.name();               
            symbol = tokenx.symbol();  
            token =	token_address;                    
            admin =	owner(); 

            
            data[0]  = tokenx.decimals();              
            data[1]	 = tokenx.totalSupply(); 
            data[2]  = lockedToken;                         
            data[3]  = getTime();                          
            data[4]  = getUnlockTime();               
            data[5]  = TokencLockedCheckView(adrs);
            data[6]  = TimeDifferential(adrs);
            data[7]  = tokenx.allowance(adrs, address(this));
            data[8]  = lockedClient;
            data[9]  = minTokenD;
            data[10] = maxTokenD;
            data[11] = ClientRank[adrs];
        }

     
 }




 contract DAOPool_Launchpad is Context, Ownable {
 
     using SafeMath for uint256;
     using Address for address;
 
     IERC20 public  tokenx; // Project Token
     address public token_address; // this Token
 
     address private Dev_address = 0x4a1fAC92414Ce682D32c6BD91c4853139384C0B1;
     address private Dead_address = 0x000000000000000000000000000000000000dEaD;

     event TransferTokenEvent(address indexed adrx, uint256 clientAmount, uint256 projectId);
     event WithdrawTokenEvent(address indexed adrx, uint256 clientAmount, uint256 projectId);
     event ChangeDevAddressEvent(
         address indexed OldAddress,
         address indexed NewAddress
     );
     event ChangeTargetAddressEvent(
         address indexed OldAddress,
         address indexed NewAddress
     );

     event ChangeMinTokenDEvent(uint256 OldMinD, uint256 NewMinD);
     event ChangeMaxTokenDEvent(uint256 OldMaxD, uint256 NewMaxD);
     event ChangeEnableTokenTransferEvent(bool OldEnable, bool NewEnable);
     event ChangeEnableTokenWithdrawEvent(bool OldEnable, bool NewEnable);
     event ChangeProjectIdEvent(uint256 OldProjectId, uint256 NewProjectId);
     event ChangeStatusEvent(uint stat);
     mapping(address => uint256)  TokenLockedClient;

     uint256 public   lockedToken     = 0;
     uint256 public   lockedClient    = 0;
     uint256 private  minTokenD       = 0;
     uint256 private  maxTokenD       = 0;
     uint256 public   projectId       = 1;

     uint    public   status          = 0;

     bool    private  lockTransfer    = false;
     bool    private  lockWithdraw    = true;


     constructor(address _token_address) {
         tokenx          = IERC20(address(_token_address));
         token_address   = _token_address;
         minTokenD       = 1 * 10**tokenx.decimals();
         maxTokenD       = 1000 * 10**tokenx.decimals();

         status = 0; // 0 - Upcoming, 1 - Active, 2 - Finished
     }

     function TransferToken(uint256 amount) public {
         require(
             lockTransfer == false,
             "Launchpad transaction is disabled"
         );
         require(
             maxTokenD >= (lockedToken + amount),
             "Top-up limit is exceeded"
         );
         require(
             tokenx.balanceOf(_msgSender()) >= amount,
             "Your balance not Enough"
         );
         uint256 allowance = tokenx.allowance(_msgSender(), address(this));
         require(allowance >= minTokenD, "Check the token allowance token minimal");
         require(allowance >= amount, "Check the token allowance");
         require(amount >= minTokenD, "Your Token not Enough");

         return _TransferToken(_msgSender(), amount);
     }

     function _TransferToken(address _adrt, uint256 _amount) private {
         require(_amount > 0);
         uint256 balancebefore = tokenx.balanceOf(address(this));
         tokenx.transferFrom(_adrt, address(this), _amount);
         uint256 balanceafter = tokenx.balanceOf(address(this));
         _amount = balanceafter - balancebefore;
         if(TokenLockedClient[_adrt] == 0){
             lockedClient = lockedClient.add(1);
         }
         TokenLockedClient[_adrt] = TokenLockedClient[_adrt].add(_amount);
         lockedToken = lockedToken.add(_amount);
         emit TransferTokenEvent(_adrt, _amount, projectId);
     }
 
     function WithdrawToken(uint256 amount) public {
          require(
             lockWithdraw == false,
             "Withdrawal is temporarily disabled"
         );
         require(TokenLockedClient[_msgSender()] > 0, "You Have not Locked");
         require(
             TokenLockedClient[_msgSender()] >= amount,
             "You Have not Enough Token"
         );
         _WithdrawToken(_msgSender(), amount);
     }
 
     function _WithdrawToken(address _adrt, uint256 _amount) private {
         TokenLockedClient[_adrt] = TokenLockedClient[_adrt]
                 .sub(_amount);
         lockedToken = lockedToken.sub(_amount);
         tokenx.transfer(_adrt, _amount);
         if(TokenLockedClient[_adrt] == 0){
             lockedClient = lockedClient.sub(1);
         }

         emit WithdrawTokenEvent(_adrt, _amount, projectId);
     }


     function ChangeProjectId(uint256 newProjectId) external onlyOwner returns (uint256){
         require(newProjectId > 0, "Can't set Zero Value");
         return _ChangeProjectId(newProjectId);
     }
 
     function _ChangeProjectId(uint256 _newProjectId) private returns (uint256) {
         emit ChangeProjectIdEvent(projectId, _newProjectId);
         projectId = _newProjectId;
         return projectId;
     }



	function TokencLockedCheckView(address adr) public view returns (uint256) {
         return TokenLockedClient[adr];
     }

    function ChangeEnableTokenTransfer(bool enable) external onlyOwner returns(bool) {
         return _ChangeEnableTokenTransfer(enable);
    }

    function ChangeEnableTokenWithdraw(bool enable) external onlyOwner returns(bool) {
         return _ChangeEnableTokenWithdraw(enable);
    }

    function _ChangeEnableTokenTransfer(bool _enable) private returns (bool) {
         emit ChangeEnableTokenTransferEvent(lockTransfer, _enable);
         lockTransfer = _enable;
         return lockTransfer;
     }

     function _ChangeEnableTokenWithdraw(bool _enable) private returns (bool) {
         emit ChangeEnableTokenWithdrawEvent(lockWithdraw, _enable);
         lockWithdraw = _enable;
         return lockWithdraw;
     }


     function GetMinTokenD() public view returns (uint256) {
         return minTokenD;
     }

      function GetMaxTokenD() public view returns (uint256) {
         return maxTokenD;
     }
 
     function ChangeMinTokenDValue(uint256 newMinD) external onlyOwner returns (uint256){
         require(newMinD >= 0, "Can't set Zero Value");
         return _ChangeMinTokenDValue(newMinD);
     }
 
     function _ChangeMinTokenDValue(uint256 _newMinD) private returns (uint256) {
         emit ChangeMinTokenDEvent(minTokenD, _newMinD);
         minTokenD = _newMinD;
         return minTokenD;
     }

    function ChangeMaxTokenDValue(uint256 newMaxD) external onlyOwner returns (uint256){
         require(newMaxD >= 0, "Can't set Zero Value");
         return _ChangeMaxTokenDValue(newMaxD);
     }
 
     function _ChangeMaxTokenDValue(uint256 _newMaxD) private returns (uint256) {
         emit ChangeMaxTokenDEvent(maxTokenD, _newMaxD);
         maxTokenD = _newMaxD;
         return maxTokenD;
     }

     function GetDevAddres() public view returns(address){
         return Dev_address;
     }

     function ChangeStatus(uint stat) external onlyOwner returns(bool) {
         return _ChangeStatus(stat);
     }

     function _ChangeStatus(uint _stat) private returns(bool) {
         emit ChangeStatusEvent(_stat);
         status = _stat;
         return true;
     }

 
     function ChangeDevAddress(address adrs) external onlyOwner returns(bool) {
         return _ChangeDevAddress(adrs);
     }
 
     function _ChangeDevAddress(address _adrs) private returns(bool) {
         emit ChangeDevAddressEvent(Dev_address, _adrs);
         Dev_address = _adrs;
         return true;
     }


     function GetContract(address adrs) public view returns (
        string memory projectname, 
        string memory symbol , 
        address token, 
        address admin, 
        uint256[11] memory data) 
        {
        
            projectname = tokenx.name();               
            symbol = tokenx.symbol();  
            token =	token_address;                    
            admin =	owner(); 

            data[0]  = tokenx.decimals();              
            data[1]	 = tokenx.totalSupply(); 
            data[2]  = lockedToken;                         
            data[3]  = getTime();                          
            data[4]  = getUnlockTime();               
            data[5]  = TokencLockedCheckView(adrs);
            data[6]  = tokenx.allowance(adrs, address(this));
            data[7]  = lockedClient;
            data[8]  = minTokenD;
            data[9]  = maxTokenD;
            data[10] = status; 
        }

     
 }