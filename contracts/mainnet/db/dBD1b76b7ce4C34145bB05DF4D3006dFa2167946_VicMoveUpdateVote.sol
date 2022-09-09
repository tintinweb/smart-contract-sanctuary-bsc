/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// File: VICDAOMainInterface.sol


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
// File: VicMoveUpdateVote.sol


// OpenZeppelin Contracts v4.4.1 (finance/VestingWallet.sol)
pragma solidity ^0.8.0;






contract VicMoveUpdateVote is BEPPausable , VicDaoVote {

    event ProposalCreate(address _address, uint256 id);
    event ProposalCancel(address _address, uint256 id);
    event ProposalApprove(uint256 id);
    event ProposalReject(uint256 id);
    event ProposalGetFundsTranfer(uint256 id, uint256 funds, uint256 reward1, uint256 reward2);

    struct Proposal{
        uint256 id;
        string title;
        string description;
        uint256 funds;
        uint256 creatorReward;
        uint256 voteReward;
        uint256 startAt;
        uint256 endAt;
        int status; // -1; 0 ;1; 2 || reject; voteing; approve; Canceled
        address creator;
        address fundsReceiver;
        uint256 totalYes;
        uint256 totalNo;
        bool fundsTranferred;
        address[] usersvote;
    }

    struct Vote{
        uint256 proposalId;
        address user;
        int yesNo;// -1; 0 ;1
        uint256 dNULEM;
    }

    Proposal[] lsProposal;
    mapping(address => mapping(uint256 => Vote)) mapUserVote;
    bool private test;
    address public VICDAOMainContract;

    constructor() payable{
       test = true;
       VICDAOMainContract = 0xa2F4C0D8C74fF083696991cd58d687C76C368326;
    }

    receive() external payable {}
    function setVICDAOMainContract(address payable _VICDAOMainContract) external onlyOwner{
        VICDAOMainContract = _VICDAOMainContract;
    }

    function tranferResources(uint256 bnb, uint256 amountNELUM, address _address) external onlyOwner{
        address NELUMContract = VICDAOMainInterface(payable(VICDAOMainContract)).getNELUMContract();
        payable(_address).transfer(bnb * 10 ** 18); 
        IBEP20(NELUMContract).transfer(_address, amountNELUM * 10 **18);
    }
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    function createProposal(string memory title, string memory description, uint256 funds, address  fundsReceiver, uint256 creatorReward, uint256 voteReward, uint256 startAt, uint256 endAt) external whenNotPaused{

        bool isWhiteLotus = VICDAOMainInterface(payable(VICDAOMainContract)).checkWhiteLotus(msg.sender);
        require(isWhiteLotus, "only whitelotus can create proposal");
        Proposal memory proposal;
        proposal.title = title;
        proposal.description = description;
        proposal.funds = funds;
        proposal.fundsReceiver = fundsReceiver;
        proposal.creatorReward = creatorReward;
        proposal.voteReward = voteReward;
        proposal.startAt = startAt;
        proposal.endAt = endAt;
        proposal.creator = msg.sender;
        proposal.status = 0;
        proposal.totalYes = 0;
        proposal.totalNo = 0;
        proposal.fundsTranferred = false;
        proposal.id = lsProposal.length;
        lsProposal.push(proposal);
        emit ProposalCreate(msg.sender, lsProposal.length-1);
    }

     function cancleProposal(uint256 proposalId) external whenNotPaused{
        Proposal storage proposal = lsProposal[proposalId];
        require(proposal.creator == msg.sender || owner() == msg.sender, "you can not cancle this proposal");
        require(proposal.startAt <= block.timestamp && proposal.endAt >= block.timestamp, "can not cancle this proposal");
        proposal.status = 2;
        emit ProposalCancel(msg.sender, proposalId);

    }

    function voteProposal(uint256 proposalId, int yesNo) external whenNotPaused{
        require(yesNo == 0 || yesNo == -1 || yesNo == 1, "yesNo = 0/-1/1");
        Proposal storage proposal = lsProposal[proposalId];
        require(proposal.status == 0, "can not vote this proposal");
        require(proposal.creator != address(0), "proposal not exist");
        require(proposal.creator != msg.sender, "creator can not vote");
        require(proposal.startAt <= block.timestamp && proposal.endAt >= block.timestamp, "can not vote this proposal");

        Vote storage preVote = mapUserVote[msg.sender][proposalId]; 
        if (preVote.user == address(0))
        {
            // new vote;
            Vote memory newVote;
            newVote.proposalId = proposalId;
            newVote.user = msg.sender;
            address dNELUMContract = VICDAOMainInterface(payable(VICDAOMainContract)).getdNELUMContract();
            uint256 dNULEM = IBEP20(dNELUMContract).balanceOf(msg.sender);
            newVote.dNULEM = dNULEM;
            newVote.yesNo = yesNo;
            // this case only 1 or -1
            if (yesNo == 1){
                proposal.totalYes += newVote.dNULEM;
            } else if (yesNo == -1){
                proposal.totalNo += newVote.dNULEM;
            }
            proposal.usersvote.push(msg.sender);
            mapUserVote[msg.sender][proposalId] = newVote;
        } else {
            address dNELUMContract = VICDAOMainInterface(payable(VICDAOMainContract)).getdNELUMContract();
            uint256 newdNULEM = IBEP20(dNELUMContract).balanceOf(msg.sender);
            //revert vote
            if (preVote.yesNo == 1){
                proposal.totalYes -= preVote.dNULEM;
            } 
            if (preVote.yesNo == -1){
                proposal.totalNo -= preVote.dNULEM;
            }
            preVote.dNULEM = 0;
            preVote.yesNo = 0;

            if (yesNo == 1) // vote yes
            {
                proposal.totalYes += newdNULEM;
                preVote.dNULEM = newdNULEM;
                preVote.yesNo = 1;
            } else if (yesNo == -1){ // vote no
                proposal.totalNo += newdNULEM;
                preVote.dNULEM = newdNULEM;
                preVote.yesNo = -1;
            }
        }
    }

    function onUserUnstake(address user) external virtual override{
        for(uint256 i = 0; i < lsProposal.length; i++){
            Proposal storage proposal = lsProposal[i];
            if (proposal.startAt <= block.timestamp && proposal.endAt >= block.timestamp && proposal.status == 0){
                Vote storage userVote = mapUserVote[user][proposal.id]; 
                if (userVote.user == user){
                     address dNELUMContract = VICDAOMainInterface(payable(VICDAOMainContract)).getdNELUMContract();
                     uint256 newdNULEM = IBEP20(dNELUMContract).balanceOf(user);
                     if (newdNULEM < userVote.dNULEM){
                         if (userVote.yesNo == 1){
                             proposal.totalYes = proposal.totalYes - userVote.dNULEM + newdNULEM;
                         } else if (userVote.yesNo == -1){
                             proposal.totalNo = proposal.totalYes - userVote.dNULEM + newdNULEM;
                         }
                         userVote.dNULEM = newdNULEM;
                     }
                }
            }
        }
    } 


    function checkVoteApprove(uint256 proposalId) external virtual override{
        Proposal memory proposal = lsProposal[proposalId];
        require(proposal.endAt < block.timestamp, "proposal not end");
        if (proposal.status == 0) {
            if (proposal.totalYes > proposal.totalNo){
                lsProposal[proposalId].status = 1;     
                emit ProposalApprove(proposalId);

            } else {
                lsProposal[proposalId].status = -1;        
                emit ProposalReject(proposalId);
                

            }
        }
    }


    function onFundsTranferred(uint256 proposalid) external  virtual override {
        Proposal memory proposal = lsProposal[proposalid];
        require(proposal.fundsTranferred == false,"fundsTranferred true");
        require(proposal.status == 1,"status != 1");

        payable(proposal.fundsReceiver).transfer(proposal.funds * 10 ** 18); 
        address NELUMContract = VICDAOMainInterface(payable(VICDAOMainContract)).getNELUMContract();

        // send reward to creator
        uint256 reward = proposal.creatorReward * 10 ** 18;
        if (reward > 0 && reward <= IBEP20(NELUMContract).balanceOf(address(this)) )
            IBEP20(NELUMContract).transfer(proposal.creator, reward);

        // cal totalVoteOk
        uint256 totalVoteOk = 0;
        for (uint256 i = 0; i < proposal.usersvote.length; i++){
            address user = proposal.usersvote[i];
            Vote memory userVote = mapUserVote[user][proposalid];
            if (userVote.yesNo == 1)
            {
                bool isWhiteLotus = VICDAOMainInterface(payable(VICDAOMainContract)).checkWhiteLotus(user);
                if (isWhiteLotus)
                    totalVoteOk = totalVoteOk + userVote.dNULEM * 12 /10; // white lotus reward * 1.2;   
                else 
                    totalVoteOk += userVote.dNULEM;
            }
        }      
        // send reward to user vote ok
        for (uint256 i = 0; i < proposal.usersvote.length; i++){
            address user = proposal.usersvote[i];
            Vote memory userVote = mapUserVote[user][proposalid];
            if (userVote.yesNo == 1)
            {
                reward = 0;
                bool isWhiteLotus = VICDAOMainInterface(payable(VICDAOMainContract)).checkWhiteLotus(user);
                if (isWhiteLotus)
                    reward = proposal.voteReward * 10**18 * userVote.dNULEM * 12 /10 / totalVoteOk; // white lotus reward * 1.2;   
                else 
                    reward = proposal.voteReward * 10**18 * userVote.dNULEM / totalVoteOk;
                if (reward > 0 && reward <= IBEP20(NELUMContract).balanceOf(address(this)) )
                    IBEP20(NELUMContract).transfer(user, reward);
            }
        }    

        lsProposal[proposalid].fundsTranferred = true;
        emit ProposalGetFundsTranfer(proposalid, proposal.funds, proposal.creatorReward, proposal.voteReward);

    }

    function getFundsTranferred(uint256 id) external view virtual override  returns (bool res) { 
        return lsProposal[id].fundsTranferred;
    }

    function getStatus(uint256 id) external view virtual override  returns (int res) { 
        return lsProposal[id].status;
    }

    function getFunds(uint256 proposalid) external  view virtual override  returns (uint256 res) {
        return lsProposal[proposalid].funds;
    }

    function getCreatorReward(uint256 proposalid) external view virtual override  returns (uint256 res) {
        return lsProposal[proposalid].creatorReward;
    }

    function getVoteRewaed(uint256 proposalid) external view virtual override  returns (uint256 res) {
        return lsProposal[proposalid].voteReward;
    }

    function getAllProposal() external view returns (Proposal[] memory res) {
        return lsProposal;
    }

    function getProposal(uint256 proposalid) external view returns (Proposal memory res) {
        return lsProposal[proposalid];
    }

    function getAllProposal(uint256 from, uint256 to) external view returns (Proposal[] memory res) {
        if (to >= lsProposal.length)
            to = lsProposal.length;
        Proposal[] memory ls = new Proposal[](to - from);
        uint256 x = 0;
        for(uint256 i = from; i < to; i++){
            ls[x] = lsProposal[i];
            x++;
        }
        return ls;
    }

    function getUserVote(address user) external view returns (Vote[] memory res) {
        Vote[] memory lsVote = new Vote[](lsProposal.length);
        for (uint256 i = 0; i < lsProposal.length; i++){
            if (mapUserVote[user][i].user == user){
                lsVote[i] = mapUserVote[user][i];
            }
        }
        return lsVote;
    }

    function getUserVote(address user, uint256 from, uint256 to) external view returns (Vote[] memory res) {
        if (to >= lsProposal.length)
            to = lsProposal.length;
        Vote[] memory lsVote = new Vote[](to - from);
        uint256 x = 0;
        for (uint256 i = 0; i < lsProposal.length; i++){
            if (mapUserVote[user][i].user == user){
                if (i>= from && i < to){
                    lsVote[x] = mapUserVote[user][i];
                    x++;
                }
            }
        }
        return lsVote;
    }

    function getVote(uint256 proposalid, uint256 from, uint256 to) external  view returns (Vote[] memory res){
        Proposal memory proposal = lsProposal[proposalid];

        if (to > proposal.usersvote.length)
            to = proposal.usersvote.length;
        Vote[] memory lsVote = new Vote[](to - from);
        for(uint256 i = from; i < to; i++){
            lsVote[i] = mapUserVote[proposal.usersvote[i]][proposalid];
        }
        return lsVote;
    }

    function getVoteCount(uint256 proposalid) external  view returns (uint256 res){
        Proposal memory proposal = lsProposal[proposalid];
        return proposal.usersvote.length;
    }

    function getProposalCount() external  view returns (uint256 res){
        return lsProposal.length;
    }

}