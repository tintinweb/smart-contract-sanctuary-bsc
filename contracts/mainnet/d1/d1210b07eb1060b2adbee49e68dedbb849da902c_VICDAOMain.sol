/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// File: HolderLinkerList.sol



pragma solidity ^0.8.0;

contract HolderLinkerList {

    bool private constant _PREV = false;
    bool private constant _NEXT = true;
    constructor() payable{
    }
    uint256 public nodeMin;
    uint256 public nodeMax;

    struct BaseStructure {
        address wallerAddress;
        uint256 dNULEM;
    }

    struct List {
        uint256 size;
        mapping(uint256 => mapping(bool => uint256)) list;
    }

    List _list;

    // Mapping from token ID to the structures
    mapping(uint256 => BaseStructure) private _structureMap;
    uint256 public progressiveId = 0;

    /*
     * @dev Utility function to create a structure
     */
    function addStructure(BaseStructure memory structure) public returns (uint256) {
        progressiveId = progressiveId + 1;
        _structureMap[progressiveId] = structure;
        return (progressiveId);
    }

    function updateStructure(uint256 node, uint256 dNELUM) public {
        _structureMap[node].dNULEM = dNELUM;
        sort(node);
    }

    function getStructure(uint256 index) public view returns (BaseStructure memory structure) {
        return (_structureMap[index]);
    }

    function getValue(uint256 index) public view returns (uint256  res) {
        return (_structureMap[index].dNULEM);
    }

    function getHolderAddress(uint256 index) public view returns (address  res) {
        return (_structureMap[index].wallerAddress);
    }

    function insert(uint256 _node) public{
        if (_list.size == 0)
        {
            nodeMin = _node;
            nodeMax = _node;
        }
        else
        {
            _createLink(_node, nodeMin, _NEXT);
            nodeMin = _node;
        }
        _list.size++;
        sort(_node);
    }

    function sort(uint256 node) public{
        if (_list.size > 1 && node <= _list.size)
        {
            uint256 next = getNextNode(node);
            uint256 pre = getPreviousNode(node);
            _createLink(next, pre, _PREV);
            if (pre == 0)
                nodeMin = next;
            if (next == 0)
                nodeMax = pre;
            _resetLink(node);
            uint256 currenntNode = nodeMin;
            while(getValue(currenntNode) <= getValue(node) && getNextNode(currenntNode) != 0)
            {
                currenntNode = getNextNode(currenntNode);
            }
            if (getValue(currenntNode) <= getValue(node))
            {
                _createLink(node, currenntNode, _PREV);
                nodeMax = node;
            }
            else 
            {
                next = currenntNode;
                pre = getPreviousNode(currenntNode);
                _createLink(node, next, _NEXT);
                _createLink(node, pre, _PREV);
                if (next == nodeMin)
                    nodeMin = node;
            }
        }
    }

    function _createLink(uint256 _node, uint256 _link, bool _direction) private {
        _list.list[_link][!_direction] = _node;
        _list.list[_node][_direction] = _link;
    }

    function _resetLink(uint256 _node) private {
        _list.list[_node][_PREV] = 0;
        _list.list[_node][_NEXT] = 0;
    }

    function getNextNode(uint256 _node) public view returns (uint256) {
        return _list.list[_node][_NEXT];
    }


    function getPreviousNode(uint256 _node) public view returns (uint256) {
        return _list.list[_node][_PREV];
    }

    function getNodeMin() public view returns (uint256 res) {
        return nodeMin;
    }

    function getNodeMax() public view returns (uint256 res) {
        return nodeMax;
    }

    function getListSize() public view returns (uint256 res) {
        return _list.size;
    }
    function getprogressiveId() public view returns (uint256 res) {
        return progressiveId;
    }

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





contract VICDAOMain is BEPPausable {
    event fortuneDrawDone(address _address, uint256 ticket);

    uint256 public daylyRewardStakeVIM;
    uint256 public daylyRewardStakeNELUM;

    address private admin;
    address public VIMContract;
    address public NELUMContract;
    address public dNELUMContract;

    address public rewardSource;
    uint256 private StakeId;
    uint256 private unStakeNum;
    uint256 public minAmount;
    uint256 public timeWithdraw;
    uint256 public whiteLotusCount;
    uint256 public tokenOfTicket;
    bool public stopStake;
    struct Stake{
        uint256 id;
        address user;
        uint256 amount;
        uint256 stakeAt;
        uint256 unStakeAt;
        uint256 lastTimeClaim;
        bool withdrawed;
        address tokenContract;
    }

    struct StakeByDate{
        uint256 date;
        uint256 totalVIMStake;
        uint256 totalNULEMStake;
    }

    struct Holder{
        address wallerAddress;
        uint256 dNULEM;
        bool isWhiteLotus;
        uint256 nodeIndex;
        uint256[] lsStakeId;
        uint256 ticketNum;
        uint256[] tickets;
    }

    Stake[] private allStake;
    mapping(address => Holder) mapHolder;
    mapping(address => mapping(uint256 => uint256)) mapStakeByDate;
    mapping(address => uint256) lastTimeUpdateStake;
    address[] lsTicketAddress;
    uint256 stopStakeAt;
    bool private test;
    HolderLinkerList holderLinkerList = new HolderLinkerList();
    constructor() payable{
        unStakeNum = 0;
        daylyRewardStakeVIM = 10000;
        daylyRewardStakeNELUM = 10000;
        rewardSource = 0x2602fB43b4e434c2e157E75E19B796cb011826c7;
        VIMContract = 0x5bcd91C734d665Fe426A5D7156f2aD7d37b76e30;
        NELUMContract = 0xA6d28d583b1DDE9fd113eA70ff765D8f67F0B914;
        dNELUMContract = 0xb541a128F2F8a4574973c65e446052ACE9D2000e;
        minAmount = 1000;
        lastTimeUpdateStake[VIMContract] = 0;
        lastTimeUpdateStake[NELUMContract] = 0;
        timeWithdraw = 10;
        whiteLotusCount = 44;
        test = false;
        tokenOfTicket = 100;
        stopStake = false;
        stopStakeAt = 0;
    }

    function setStopStake(bool _stop) external onlyOwner{
        stopStake = _stop;
        if (stopStake)
            stopStakeAt = block.timestamp;
        else 
            stopStakeAt = 0;
    } 
 
    function setDaylyRewardStakeVIM(uint256 _daylyRewardStakeVIM) external onlyOwner{
        daylyRewardStakeVIM = _daylyRewardStakeVIM;
    }
     function setDaylyRewardStakeNELUM(uint256 _daylyRewardStakeNELUM) external onlyOwner{
        daylyRewardStakeNELUM = _daylyRewardStakeNELUM;
    }
    function setRewardSource(address _rewardSource) external onlyOwner{
        rewardSource = _rewardSource;
    }
    function setMinAmout(uint256 _minAmount) external onlyOwner{
        minAmount = _minAmount;
    }
    function setNELUMContract(address _NELUMContract) external onlyOwner{
        NELUMContract = _NELUMContract;
    }
    function setdNELUMContract(address _dNELUMContract) external onlyOwner{
        dNELUMContract = _dNELUMContract;
    }
    function setTimeWithdraw(uint256 _timeWithdraw) external onlyOwner{
        timeWithdraw = _timeWithdraw;
    }
    function setWhiteLotusCount(uint256 _whiteLotusCount) external onlyOwner{
        whiteLotusCount = _whiteLotusCount;
    }

    function adminwithdraw(uint256 amountVim, uint256 amountNELUM, address _address) external onlyOwner{
        IBEP20(VIMContract).transfer(_address, amountVim * 10**18);
        IBEP20(NELUMContract).transfer(_address, amountNELUM * 10 **18);
    }


    function stake(uint256 amount, address tokenAddress) external whenNotPaused{
        require(!stopStake, "stake stoped");
        require(amount >= minAmount,"amount >= minAmount");
        require(tokenAddress == VIMContract || tokenAddress == NELUMContract,"Can not stake this token");
        if (!test)
        {
            require(IBEP20(tokenAddress).allowance(msg.sender,address(this)) >= amount,"The token allowed is not enough. You need approve more token");
            require(IBEP20(tokenAddress).balanceOf(msg.sender) >= amount * 10**18,"The token is not enough.");
            IBEP20(tokenAddress).transferFrom(msg.sender,address(this),amount * 10**18);
            IBEP20(dNELUMContract).approve(address(this), amount * 10**18);
            IBEP20(dNELUMContract).transferFrom(address(this), msg.sender, amount * 10**18);
        }

        uint256 date = block.timestamp/86400*86400;

        Stake memory newstake = Stake(allStake.length, msg.sender, amount, block.timestamp, 0, date, false, tokenAddress);  
        allStake.push(newstake);
        if(mapHolder[msg.sender].nodeIndex == 0)
        {

            uint256 newNode = holderLinkerList.addStructure(HolderLinkerList.BaseStructure(msg.sender, amount));
            holderLinkerList.insert(newNode);

            mapHolder[msg.sender].nodeIndex = newNode;
            mapHolder[msg.sender].wallerAddress = msg.sender;
        }
        Holder storage holder = mapHolder[msg.sender];
        holder.dNULEM += amount;
        holder.lsStakeId.push(allStake.length - 1);
        holderLinkerList.updateStructure(holder.nodeIndex, holder.dNULEM);
        updateWhiteLutos();

        uint256 x = holder.dNULEM / tokenOfTicket - holder.ticketNum;
        for(uint256 i = 0; i < x; i++)
        {
            lsTicketAddress.push(holder.wallerAddress);
            holder.tickets.push(lsTicketAddress.length - 1);
        }
        holder.ticketNum += x;

        uint256 stakeByDate = mapStakeByDate[tokenAddress][date];
        if (stakeByDate > 0 )
        {
            mapStakeByDate[tokenAddress][date] += amount;
        }
        else 
        {
            if (lastTimeUpdateStake[tokenAddress] == 0)
                mapStakeByDate[tokenAddress][date] = amount;
            else
            {
                uint256 totalStake = mapStakeByDate[tokenAddress][lastTimeUpdateStake[tokenAddress]];
                lastTimeUpdateStake[tokenAddress] += 86400;
                while(lastTimeUpdateStake[tokenAddress] <= date)
                {
                    mapStakeByDate[tokenAddress][lastTimeUpdateStake[tokenAddress]] = totalStake;
                    lastTimeUpdateStake[tokenAddress] += 86400;
                }
                mapStakeByDate[tokenAddress][date] += amount;
            }
        }
        lastTimeUpdateStake[tokenAddress] = date;
    }

    function updateWhiteLutos() private {
        uint256 node = holderLinkerList.getNodeMax();
        address holderAddress = address(0);
        uint256 x = 0;
        while (holderLinkerList.getPreviousNode(node) != 0)
        {
            holderAddress = holderLinkerList.getHolderAddress(node);
            if (x < whiteLotusCount)
                mapHolder[holderAddress].isWhiteLotus = true;
            else 
                mapHolder[holderAddress].isWhiteLotus = false;
            x++;
            node = holderLinkerList.getPreviousNode(node);
        }
        holderAddress = holderLinkerList.getHolderAddress(node);
         if (x < whiteLotusCount)
                mapHolder[holderAddress].isWhiteLotus = true;
            else 
                mapHolder[holderAddress].isWhiteLotus = false;
    }


    function unStake(uint256 stakeId) external whenNotPaused{
        Stake storage unStakeObj = allStake[stakeId];
        require(unStakeObj.user == msg.sender, "stake not belong use");
        require(unStakeObj.unStakeAt == 0, "Can not unstake this");
        if (!test)
        {
            require(IBEP20(dNELUMContract).allowance(msg.sender,address(this)) >= unStakeObj.amount * 10**18,"The dLUNEM allowed is not enough. You need approve more dLUNEM");
            require(IBEP20(dNELUMContract).balanceOf(msg.sender) >= unStakeObj.amount * 10**18,"The dLUNEM is not enough.");
            IBEP20(dNELUMContract).transferFrom(msg.sender, address(this), unStakeObj.amount * 10**18);
        }

        unStakeObj.unStakeAt = block.timestamp;
        unStakeNum++;

        Holder storage holder = mapHolder[msg.sender];
        holder.dNULEM -= unStakeObj.amount;
        holderLinkerList.updateStructure(holder.nodeIndex, holder.dNULEM);
        updateWhiteLutos();

        uint256 x = holder.ticketNum - holder.dNULEM / tokenOfTicket;
        if (x > 0)
        {
            for(uint256 i = 0; i < holder.tickets.length; i++)
            {
                if (lsTicketAddress[holder.tickets[i]]==holder.wallerAddress)
                {
                    lsTicketAddress[holder.tickets[i]] = address(0);
                    x--;
                    holder.ticketNum--;
                }
                if (x <= 0)
                break;
            }
        }
       

        uint256 date = block.timestamp/86400*86400;

        address tokenAddress = unStakeObj.tokenContract;
        uint256 totalStake = mapStakeByDate[tokenAddress][lastTimeUpdateStake[tokenAddress]];
        lastTimeUpdateStake[tokenAddress] += 86400;
        while(lastTimeUpdateStake[tokenAddress] <= date)
        {
            mapStakeByDate[tokenAddress][lastTimeUpdateStake[tokenAddress]] = totalStake;
            lastTimeUpdateStake[tokenAddress] += 86400;
        }
        mapStakeByDate[tokenAddress][date] -= unStakeObj.amount;
        if (mapStakeByDate[tokenAddress][date] < 0)
            mapStakeByDate[tokenAddress][date] = 0;
        lastTimeUpdateStake[tokenAddress] = date;
    }


    function withdraw(uint256 stakeId) external whenNotPaused{
        Stake storage withdrawObj = allStake[stakeId];
        require(withdrawObj.user == msg.sender, "stake not belong use");
        require(withdrawObj.withdrawed == false, "stake withdrawed");
        require(withdrawObj.unStakeAt > 0 , "Can not withdraw this");
        require(withdrawObj.unStakeAt + 86400 * timeWithdraw <= block.timestamp , "Can not withdraw this now");
        withdrawObj.withdrawed = true;
        if (!test)
            IBEP20(withdrawObj.tokenContract).transfer(withdrawObj.user, withdrawObj.amount * 10**18);
    }

    function claim(uint stakeId) external whenNotPaused{
        uint256 date = block.timestamp/86400*86400;
        Stake storage claimObj = allStake[stakeId];
        require(claimObj.amount > 0, "stake id not exist");
        require(claimObj.user == msg.sender, "stake not belong use");
        require(claimObj.lastTimeClaim < date, "Can not claim now");
        require(claimObj.unStakeAt == 0, "Can not claim this stake");
        uint256 totalReward = 0;
        uint256 dailyreward = 0;
        address tokenAddress = claimObj.tokenContract;

        if (tokenAddress == VIMContract)
            dailyreward = daylyRewardStakeVIM;
        if (tokenAddress == NELUMContract)
            dailyreward = daylyRewardStakeNELUM;

        uint256 totalStake = mapStakeByDate[tokenAddress][lastTimeUpdateStake[tokenAddress]];
        lastTimeUpdateStake[tokenAddress] += 86400;
        while(lastTimeUpdateStake[tokenAddress] <= date)
        {
            mapStakeByDate[tokenAddress][lastTimeUpdateStake[tokenAddress]] = totalStake;
            lastTimeUpdateStake[tokenAddress] += 86400;
        }
        lastTimeUpdateStake[tokenAddress] = date;

        if (stopStake)
            date = stopStakeAt;
        while(claimObj.lastTimeClaim < date)
        {
            claimObj.lastTimeClaim += 86400;
            uint256 stakeByDate = mapStakeByDate[claimObj.tokenContract][claimObj.lastTimeClaim - 86400];
            totalReward += dailyreward * 10**18 * claimObj.amount / stakeByDate;
        }
        if (!test)
        {
            if (totalReward > 0)
                IBEP20(NELUMContract).transferFrom(rewardSource,claimObj.user,totalReward);
        }
    }

    function forTuneDraw() external whenNotPaused{
        while(true)
        {
            uint256 randomTicket = random(0, lsTicketAddress.length - 1, block.timestamp);
            address add = lsTicketAddress[randomTicket];
            if (add != address(0))
            {
                emit fortuneDrawDone(add, randomTicket);
                break;
            }
        }
    }


    function random(
        uint256 from,
        uint256 to,
        uint256 salty
    ) private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number +
                        salty
                )
            )
        );
        return (seed % (to - from)) + from;
    }

    function getStakeDate(uint256 timestamp, address tokenContract) external view returns(uint256 totalAmount)
    {
        uint256 date = timestamp/86400*86400;
        uint256 stakeByDate = mapStakeByDate[tokenContract][date];
        return (stakeByDate);
    }

    function getStake(uint256 stakeid) external view returns(Stake memory res)
    {
        res = allStake[stakeid];
        return (res);
    }

    function getAllStake(address _address) external view returns(Stake[] memory _res)
    {
        
        Holder memory holder = mapHolder[_address];
        uint256 length = holder.lsStakeId.length;
        Stake[] memory res = new Stake[](length);
        for(uint256 i = 0; i < length; i++)
        {
            res[i] = allStake[holder.lsStakeId[i]];
        }
        return (res);
    }

    function getStakeCount() external view returns(uint256 res)
    {
        return (allStake.length - unStakeNum);
    }

    function getAllHolder() external view returns(Holder[] memory lsholder)
    {
        Holder[] memory lsHolder = new Holder[](holderLinkerList.getListSize());
        uint256 node = holderLinkerList.getNodeMax();
        uint256 x = 0;
        address holderAddress = address(0);
        while (holderLinkerList.getPreviousNode(node) != 0)
        {
            holderAddress = holderLinkerList.getHolderAddress(node);
            lsHolder[x] = mapHolder[holderAddress];
            x++;
            node = holderLinkerList.getPreviousNode(node);
        }
        holderAddress = holderLinkerList.getHolderAddress(node);
        lsHolder[x] = mapHolder[holderAddress];
        return (lsHolder);
    }

    function getHolder(address _address) external view returns(Holder memory holder)
    {
        return (mapHolder[_address]);
    }

    function getTicket(uint256 id) external view returns(address  _address)
    {
        return (lsTicketAddress[id]);
    }

    function getVimStake() external view returns(uint256 _res)
    {
        return (mapStakeByDate[VIMContract][lastTimeUpdateStake[VIMContract]]);
    }

    function getNELUMStake() external view returns(uint256 _res)
    {
        return (mapStakeByDate[NELUMContract][lastTimeUpdateStake[VIMContract]]);
    }

    function getNumHolder() external view returns(uint256 _res)
    {
        return (holderLinkerList.getListSize());
    }
}