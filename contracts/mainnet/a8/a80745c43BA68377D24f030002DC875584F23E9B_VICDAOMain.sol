/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// File: VicDaoMainInterface.sol


pragma solidity ^0.8.0;
interface VICDAOMainInterface{
    function getdNELUMContract() external view returns(address res);
    function getNELUMContract() external view returns(address res);
    function getVIMContract() external view returns(address res);
    function checkWhiteLotus(address _address) external view returns(bool);
    function mint_dNELUM_On_Stake(address toAddress, uint256 amount) external;
    function burn_dNELUM_On_UnStake(address toAddress, uint256 amount) external;
    function updateHolder(address toAddress) external;
    function onUserUnstake(address toAddress) external;
    function getAllNodeAddress(address start,uint32 len) external view returns(address[] memory);
    function getNumHolder() external view returns(uint32);
}
// File: dNELUMTokenInterface.sol


pragma solidity ^0.8.0;
interface dNELUMTokenInterface{
    function onUserStake(address receiver, uint256 amount) external;
    function onUserUnStake(address receiver, uint256 amount) external;
    

}
// File: VicDaoVote.sol


pragma solidity ^0.8.0;
interface VicDaoVote{
    function checkVoteApprove(uint256 id) external;
    function onFundsTranferred(uint256 id) external;
    function onUserUnstake(address usser) external;
    function getFunds (uint256 id) external view returns (uint256 res);
    function getCreatorReward (uint256 id) external view returns (uint256 res);
    function getVoteRewaed (uint256 id) external view returns (uint256 res);
    function getFundsTranferred(uint256 id) external view returns (bool); 
    function getStatus(uint256 id) external view returns (int); 


}
// File: WhiteLotusInterface.sol


pragma solidity ^0.8.0;
interface WhiteLotusInterface{  
    function updateNode(address _wallerAddress,uint256 _value) external;
    function delNode(address _wallerAddress) external returns (uint32 delNodeID);
    function setmanualRun(bool status) external;
    function UpdateWhiteLotusMaxCount(uint32 _NewMaxCount) external;
    function isWhiteLotus(address add) external view returns(bool);
    function getAllAddress(address start,uint32 len) external view returns(address[] memory);
    function getAllWhiteLotus() external view returns(address[] memory lstAdd,uint32[] memory lstID,uint256[] memory Value);
    function getNodeCount() external view returns(uint32 res);
}
// File: IBEP20.sol


pragma solidity ^0.8.0;

interface IBEP20 {
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
  function transfer(address recipient, uint256 amount) external returns (bool);

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
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: BEPContext.sol


pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract BEPContext {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor() {}

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
}
// File: BEPOwnable.sol


pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract BEPOwnable is BEPContext {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
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
    require(isOwner(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Returns true if the caller is the current owner.
   */
  function isOwner() public view returns (bool) {
    return _msgSender() == _owner;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
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
// File: BEPPausable.sol


pragma solidity ^0.8.0;

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract BEPPausable is BEPOwnable {
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}
// File: Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
// File: VicDaoMain.sol


// OpenZeppelin Contracts v4.4.1 (finance/VestingWallet.sol)
pragma solidity ^0.8.0;










contract VICDAOMain is BEPPausable, VICDAOMainInterface {
    
    address public VIMContract;
    address public NELUMContract;
    address public dNELUMContract;

    uint32 MINdNELUM;
    
    address[] public lsVoteContract;
    address[] public lsStakeContract;
    Role[] lsRole;

    struct Role{
        address add1;
        address add2;
    }

    WhiteLotusInterface WL;

    
    constructor() payable{
        VIMContract = 0x5bcd91C734d665Fe426A5D7156f2aD7d37b76e30;
        NELUMContract = 0xbC846B8A1cAaA95cDD18FAA28d4Fd16791007801;
        dNELUMContract = 0x307cE5700c4c32bC91aa566F7abb07Fde7C7501e;
        MINdNELUM = 1000;
    }

    function setWL(address _add) external onlyOwner{
        WL = WhiteLotusInterface(_add);
    }

    function pauseAndRemoveRole() public onlyOwner whenNotPaused {
        for (uint256 i = 0; i < lsRole.length; i++){
            IBEP20(lsRole[i].add1).approve(lsRole[i].add2, 0);
        }
        pause();
    }

    function setMindNELUM(uint32 _MINdNELUM) external onlyOwner{
        MINdNELUM = _MINdNELUM;
    }
    function setNELUMContract(address _NELUMContract) external onlyOwner{
        NELUMContract = _NELUMContract;
    }
    function setdNELUMContract(address _dNELUMContract) external onlyOwner{
        dNELUMContract = _dNELUMContract;
    }

    function addVoteContract(address _address) external onlyOwner{
        for(uint256 i = 0; i < lsVoteContract.length; i++){
            if (lsVoteContract[i] == _address)
                return ;
        }
        lsVoteContract.push(_address);
    }

    function removeVoteContract(address _address) external onlyOwner{
        bool found = false;
        for(uint256 i = 0; i < lsVoteContract.length; i++){
            if (lsVoteContract[i] == _address){
                found = true;
            }
            if(found && i < lsVoteContract.length - 1){
                lsVoteContract[i] = lsVoteContract[i+1];
            }
        }
        if(found){
            lsVoteContract.pop();
        }
    }

    function addStakeContract(address _address) external onlyOwner{
        for(uint256 i = 0; i < lsStakeContract.length; i++){
            if (lsStakeContract[i] == _address)
                return ;
        }
        lsStakeContract.push(_address);
    }

    function removeStakeContract(address _address) external onlyOwner{
        bool found = false;
        for(uint256 i = 0; i < lsStakeContract.length; i++){
            if (lsStakeContract[i] == _address){
                found = true;
            }
            if(found && i < lsStakeContract.length - 1){
                lsStakeContract[i] = lsStakeContract[i+1];
            }
        }
        if(found){
            lsStakeContract.pop();
        }

    }

    function addrole(address _tokenAddress, uint256 index, uint256 amount) external onlyOwner{
        address _add = lsStakeContract[index];
        IBEP20(_tokenAddress).approve(_add, amount);
        lsRole.push(Role(_tokenAddress, _add));
    }

    function mint_dNELUM_On_Stake(address toAddress, uint256 amount) external whenNotPaused virtual override{
        for(uint256 i = 0; i < lsStakeContract.length; i++){
            if (lsStakeContract[i] == msg.sender){
                dNELUMTokenInterface(payable (dNELUMContract)).onUserStake(toAddress, amount);
                return;
            }
        }
        require(false,"can not call this function");
    }

    function burn_dNELUM_On_UnStake(address toAddress, uint256 amount) external whenNotPaused virtual override{
        for(uint256 i = 0; i < lsStakeContract.length; i++){
            if (lsStakeContract[i] == msg.sender){
                dNELUMTokenInterface(payable (dNELUMContract)).onUserUnStake(toAddress, amount);
                return;
            }
        }
        require(false,"can not call this function");
    }


    function fundsTranfer(uint256 proposalid, address voteContract) whenNotPaused external{
        for(uint256 i = 0; i < lsVoteContract.length; i++){
            if (lsVoteContract[i] == voteContract){
                VicDaoVote(voteContract).checkVoteApprove(proposalid);
                if (VicDaoVote(voteContract).getStatus(proposalid) ==1 && !VicDaoVote(voteContract).getFundsTranferred(proposalid)){
                    payable(voteContract).transfer(VicDaoVote(voteContract).getFunds(proposalid) * 10 ** 18); 
                    IBEP20(NELUMContract).transfer(voteContract, VicDaoVote(voteContract).getCreatorReward(proposalid) * 10 **18);
                    IBEP20(NELUMContract).transfer(voteContract, VicDaoVote(voteContract).getVoteRewaed(proposalid) * 10 **18);
                    VicDaoVote(voteContract).onFundsTranferred(proposalid);
                }
            }
        }
    }

    function onUserUnstake(address holder) external whenNotPaused virtual override  {
        for(uint256 i = 0; i < lsVoteContract.length; i++){
            if (lsVoteContract[i] != address(0))
                VicDaoVote(lsVoteContract[i]).onUserUnstake(holder);  
        }
    }

    function getdNELUMContract() external virtual override view returns(address res){
        return (dNELUMContract);
    }

    function getNELUMContract() external virtual override view returns(address res){
        return (NELUMContract);
    }

    function getVIMContract() external virtual override view returns(address res){
        return (VIMContract);
    }

    receive() external payable {}

    //===================================WHITE LOTUS===========================================
    function updateHolder(address holder) external whenNotPaused virtual override {
        uint256 dNELUM = IBEP20(dNELUMContract).balanceOf(holder);
        uint256 value = dNELUM / (10**uint256(18));//bo so thap phan
        if(value>=MINdNELUM){
            WL.updateNode(holder,value);
        }else{
            WL.delNode(holder);
        }
    }

    function setManualRunSort(bool status) external onlyOwner{
        WL.setmanualRun(status);
    }

    function UpdateWhiteLotusMaxCount(uint32 NewMax) external onlyOwner{
        WL.UpdateWhiteLotusMaxCount(NewMax);
    }

    // //Ham nay chi de test voi con tract test, neu chay tren contract chinh se bi sai duu lieu
    // uint32 indextest;
    // function insertManyHolder(uint32 num) external onlyOwner{
    //     for(uint32 i=0;i<num;i++){
    //         indextest = indextest+1;
    //         address _wallerAddress = address(uint160(uint(keccak256(abi.encodePacked(indextest, blockhash(block.number))))));
    //         WL.update(_wallerAddress, indextest);
    //     }
    // }

    function checkWhiteLotus(address _address) external virtual override  view returns(bool)
    {
        return WL.isWhiteLotus(_address);
    }

    function getAllNodeAddress(address start,uint32 len) external override view returns(address[] memory)
    {
        return WL.getAllAddress(start,len);
    }

    function getAllWhiteLotus() public view returns(address[] memory lstAdd,uint32[] memory lstID,uint256[] memory Value){
        return WL.getAllWhiteLotus();
    }

    function getAllWhiteLotusAddress() public view returns(address[] memory){
        (address[] memory lstAdd,,) = WL.getAllWhiteLotus();
        return lstAdd;
    }

    // function getHolder(address _address) external view returns(WhiteLotus.Node memory)
    // {
    //     return WL.getNode(_address);
    // }

    function getNumHolder() external override view returns(uint32)
    {
        return WL.getNodeCount();
    }
}