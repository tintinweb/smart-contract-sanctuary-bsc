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
// File: sort/sortList.sol



pragma solidity ^0.8.0;

contract sortList {
    struct Node{
        //data
        address wallerAddress;
        uint256 value;
        //link list
        uint32 preBig;
        uint32 pre;
        uint32 next;
        uint32 nextBig;
        uint32 countBig;
        uint32 ID;
    }
    mapping(address => uint32) public mapAddress2ID;

    mapping(uint32 => Node) public mapNode;
    uint32 public topNode;//MAX
    uint32 public buttonNode;//MIN
    uint32 public lenIndex;
    uint32 public delCount;
    uint32 public square = 6;

    constructor() {
        //Start Init TOP Button
        topNode = ~uint32(0);
        buttonNode = 2;
        mapNode[topNode] = Node(address(0),~uint256(0),0,0,buttonNode,buttonNode,1,topNode);
        mapNode[buttonNode] = Node(address(0),0,topNode,topNode,0,0,0,buttonNode);
        lenIndex = 2;
        delCount = 2;
    }
    //Update or insert node
    function update(address _wallerAddress,uint256 _value) public virtual returns (Node memory) {
        require(_wallerAddress != address(0) && _value > 0,"Can not update wallet 0 AND Can not update value == 0");
        Node memory curentNode;
        uint32 curentNodeID;
        if(mapAddress2ID[_wallerAddress] != 0){//update node
            curentNodeID = mapAddress2ID[_wallerAddress];
            curentNode = mapNode[curentNodeID];
            mapNode[curentNodeID].value = _value;//update data
            unlink(curentNode.ID);
        }else{//add new node
            lenIndex++;
            curentNodeID = lenIndex;
            mapAddress2ID[_wallerAddress] = curentNodeID; 
            curentNode = Node(_wallerAddress,_value,0,0,0,0,0,curentNodeID);
            mapNode[curentNodeID] = curentNode;
            //c
            if(square*square+100 < lenIndex - delCount){
                square++;
            }
        }
        sort(curentNode.ID);//re sort curentNode
        return curentNode;
    }

    //delete node from list and map (when unstake)
    function del(address _wallerAddress) public virtual returns (uint32) {
        require(mapAddress2ID[_wallerAddress] != 0,"This address is not exit");
        uint32 curentNodeID = mapAddress2ID[_wallerAddress];
        //delete data
        unlink(curentNodeID);
        delete mapNode[curentNodeID];
        delete mapAddress2ID[_wallerAddress];
        delCount++;
        return curentNodeID;
    }

    function sort(uint32 cunrentNodeID) internal {
        Node memory curentNode = mapNode[cunrentNodeID];
        Node memory checkNode = mapNode[topNode];
        while (curentNode.value <= checkNode.value && checkNode.ID != buttonNode){
            checkNode = mapNode[checkNode.nextBig];
        }
        insertSort_Range(curentNode.ID,checkNode.preBig,checkNode.ID);
    }

    function insertSort_Range(uint32 curentNodeID,uint32 startNodeID, uint32 endNodeID) internal {
        //Require (Start node >= curent Node && endNode < cunrentNode)
        //Requice startNode.countBig > 0
        Node memory curentNode = mapNode[curentNodeID];
        Node memory startNode = mapNode[startNodeID];
        Node memory checkNode = startNode;
        //Tang countBig va tinh chia khoang
        checkNode.countBig++;
        uint32 countBig = checkNode.countBig;
        mapNode[startNode.ID] = checkNode;
        uint32 bigPont = ~uint32(0);
        bool bigInserting = false;
        if(countBig>square*3/2){
            bigPont = square*3/4;
            if(bigPont<countBig/2){
                bigPont = countBig/2;
            }
            bigInserting = true;
        }
        uint32 count = 1;
        //Sort
        bool inserting = true;
        while ((inserting || bigInserting) && checkNode.ID != endNodeID){
            checkNode = mapNode[checkNode.next];
            if(inserting && curentNode.value > checkNode.value){
                link(curentNode.ID ,checkNode.ID);
                inserting = false;
            }
            if(bigInserting){
                count++;
                if(count>=bigPont){
                    linkBig(startNode.ID,count,checkNode.ID,countBig-count);
                    bigInserting = false;
                }
            }
            
        }
    }

    function linkBig(uint32 bigTopNodeID,uint32 bigtopCount,uint32 newBigNodeID,uint32 newBigCount) internal{
        Node memory bigTopNode = mapNode[bigTopNodeID];
        Node memory newBigNode = mapNode[newBigNodeID];
        uint32 bigBotomNodeID = bigTopNode.nextBig;

        newBigNode.countBig = newBigCount;
        newBigNode.preBig = bigTopNode.ID;
        newBigNode.nextBig = bigBotomNodeID;
        mapNode[newBigNode.ID] = newBigNode;

        bigTopNode.countBig = bigtopCount;
        bigTopNode.nextBig = newBigNode.ID;
        mapNode[bigTopNode.ID] = bigTopNode;

        mapNode[bigBotomNodeID].preBig = newBigNode.ID;
    }

    //unlink node and link pre 2 next node
    function unlink(uint32 curentNodeID) internal virtual {
        Node memory curentNode = mapNode[curentNodeID];
        uint32 preID = curentNode.pre;
        Node memory nextNode = mapNode[curentNode.next];
        mapNode[preID].next = nextNode.ID;
        nextNode.pre = preID;
        //xu ly nextBig preBig...
        if(curentNode.countBig > 0){
            if(nextNode.countBig == 0){
                nextNode.countBig = curentNode.countBig-1;
                nextNode.nextBig = curentNode.nextBig;
                mapNode[curentNode.nextBig].preBig = nextNode.ID;
            }
            nextNode.preBig = curentNode.preBig;
            mapNode[curentNode.preBig].nextBig = nextNode.ID;
            //reset next big of curent node
            curentNode.countBig = 0;
            curentNode.nextBig = 0;
            curentNode.preBig = 0;
            mapNode[curentNode.ID] = curentNode;
        }
        //Ghi nextNode vao storge
        mapNode[nextNode.ID] = nextNode;
    }

    function link(uint32 curentNodeID, uint32 nextNodeID) internal virtual {
        Node memory curentNode = mapNode[curentNodeID];
        uint32 preNodeID = mapNode[nextNodeID].pre;
        mapNode[preNodeID].next = curentNode.ID;
        curentNode.pre = preNodeID;
        curentNode.next = nextNodeID;
        mapNode[curentNode.ID] = curentNode;
        mapNode[nextNodeID].pre = curentNode.ID;
    }

    function getCount() public view returns(uint32 res){
        res = lenIndex-delCount;
    }
    
}
// File: WhiteLotus.sol



pragma solidity ^0.8.0;


contract WhiteLotus is sortList {
    mapping(uint32 => bool) public mapWhiteLotus;
    uint32 public MinWhiteLotusID;
    uint32 public MaxCount;
    uint32 public count;
    bool manualRun;

    constructor() {
        MaxCount = 44;
        count = 0;
        mapWhiteLotus[topNode] = true;
        MinWhiteLotusID = topNode;
        manualRun = false;
    }

    function UpdateWhiteLotusMaxCount(uint32 _NewMaxCount) public {
        if(_NewMaxCount<count){
            MaxCount = _NewMaxCount;
            fitNumOfWL();
        }else if(_NewMaxCount>count){
            MaxCount = _NewMaxCount;
            addMoreWL();
        }
    }
    //add them WL voi dieu kien: 1.count dang nho hon MAX 2.Lien sau MinWL chua duoc add vao WL
    function addMoreWL() private {
        if(count<MaxCount){
            Node memory MinWL = mapNode[MinWhiteLotusID];
            MinWL = mapNode[MinWL.next];
            uint32 i = count+1;
            while(i<=MaxCount && MinWL.ID != buttonNode){
                mapWhiteLotus[MinWL.ID] = true;
                MinWL = mapNode[MinWL.next];
                i++;
            }
            count = i-1;
            MinWhiteLotusID = MinWL.pre;
        }
    }
    //Xoa WL khoi danh sach voi dieu kien: 1.count dang lon hon MAX. 2.Lien sau MinWL chua duoc add vao WL 3. Lien truoc da duoc add vao WL het roi
    function fitNumOfWL() private {
        if(count>MaxCount){
            Node memory MinWL = mapNode[MinWhiteLotusID];
            uint32 i = count;
            while(i>MaxCount && MinWL.ID != topNode){
                delete mapWhiteLotus[MinWL.ID];
                MinWL =  mapNode[MinWL.pre];
                i--;
            }
            count = MaxCount;
            MinWhiteLotusID = MinWL.ID;
        }
    }

    function isWhiteLotus(address add) public view returns(bool){
        return mapWhiteLotus[mapAddress2ID[add]];
    }

    function getAllWhiteLotus() public view returns(address[] memory lstAdd,uint32[] memory lstID,uint256[] memory Value){
        lstAdd = new address[](count);
        lstID = new uint32[](count);
        Value = new uint256[](count);
        uint32 lstIndex = count-1;
        Node memory MinWL = mapNode[MinWhiteLotusID];
        while(MinWL.ID != topNode){
            lstAdd[lstIndex] = MinWL.wallerAddress;
            lstID[lstIndex] = MinWL.ID;
            Value[lstIndex] = MinWL.value;
            MinWL = mapNode[MinWL.pre];
            if(lstIndex>0){
                lstIndex--;
            }else{
                break;
            }
        }
        
    }
    function getAllAddress(address start,uint32 len) public view returns(address[] memory){
        uint32 startID;
        if(start == address(0)){
            startID = mapNode[topNode].next;
        }else{
            startID = mapAddress2ID[start];
        }
        require(startID > 0,"Address not fount");
        if(len == 0)len = getCount();
        address[] memory lstAdd = new address[](len);
        Node memory cNode = mapNode[startID];
        uint i = 0;
        while(cNode.ID != buttonNode && i < len){
            lstAdd[i] = cNode.wallerAddress;
            cNode = mapNode[cNode.next];
            i++;
        }
        return lstAdd;
    }
    function getAllNode(address start,uint32 len) public view returns(Node[] memory){
        uint32 startID;
        if(start == address(0)){
            startID = topNode;
        }else{
            startID = mapAddress2ID[start];
        }
        require(startID > 0,"Address not fount");
        if(len == 0)len = getCount();
        Node[] memory lstNode = new Node[](len);
        Node memory cNode = mapNode[startID];
        uint i = 0;
        while(cNode.ID != 0 && i < len){
            lstNode[i] = cNode;
            cNode = mapNode[cNode.next];
            i++;
        }
        return lstNode;
    }
    function setmanualRun(bool status) public {
        manualRun = status;
    }
    function getNode(address add) public view returns(Node memory){
        return mapNode[mapAddress2ID[add]];
    }

    //======================================================OVERRIDE FUNCTION============================================================
    function update(address _wallerAddress,uint256 _value) public override returns (Node memory) {
        if(manualRun)return Node(address(0),0,0,0,0,0,0,0);
        return sortList.update(_wallerAddress,_value);
    }
    function del(address _wallerAddress) public override returns (uint32 delNodeID) {
        if(manualRun)return delNodeID;
        delNodeID = sortList.del(_wallerAddress);
        if(mapWhiteLotus[delNodeID]){
            delete mapWhiteLotus[delNodeID];
            count--;
            addMoreWL();
        }
    }

    function unlink(uint32 curentNodeID) internal override {
        sortList.unlink(curentNodeID);
        //neu node nay la WL thi` xoa khoi danh sach va ha count
        if(mapWhiteLotus[curentNodeID]){
            mapWhiteLotus[curentNodeID] = false;
            count--;
            //Neu no dang la node Min thi` thay node Min moi
            if(MinWhiteLotusID == curentNodeID){
                MinWhiteLotusID = mapNode[curentNodeID].pre;
            }
        }
    }

    function link(uint32 curentNodeID, uint32 nextNodeID) internal override {
        sortList.link(curentNodeID,nextNodeID);
        //neu nextNode la WL thi` node nay cung la WL
        if(mapWhiteLotus[nextNodeID]){
            mapWhiteLotus[curentNodeID] = true;
            count++;
            fitNumOfWL();
        }else if(count < MaxCount){
            addMoreWL();
        }
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










contract VICDAOMain is BEPPausable, VICDAOMainInterface {
    
    address public VIMContract;
    address public NELUMContract;
    address public dNELUMContract;

    uint32 MINdNELUM;
    
    address[] public lsVoteContract;
    address[] public lsStakeContract;

    WhiteLotus WL;
    
    constructor() payable{
        VIMContract = 0x5bcd91C734d665Fe426A5D7156f2aD7d37b76e30;
        NELUMContract = 0xbC846B8A1cAaA95cDD18FAA28d4Fd16791007801;
        dNELUMContract = 0x307cE5700c4c32bC91aa566F7abb07Fde7C7501e;
        MINdNELUM = 1000;
        WL = new WhiteLotus();
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
            WL.update(holder,value);
        }else{
            WL.del(holder);
        }
    }

    function setManualRunSort(bool status) external onlyOwner{
        WL.setmanualRun(status);
    }

    function UpdateWhiteLotusMaxCount(uint32 NewMax) external onlyOwner{
        WL.UpdateWhiteLotusMaxCount(NewMax);
    }

    //Ham nay chi de test voi con tract test, neu chay tren contract chinh se bi sai duu lieu
    uint32 indextest;
    function insertManyHolder(uint32 num) external onlyOwner{
        for(uint32 i=0;i<num;i++){
            indextest = indextest+1;
            address _wallerAddress = address(uint160(uint(keccak256(abi.encodePacked(indextest, blockhash(block.number))))));
            WL.update(_wallerAddress, indextest);
        }
    }

    function checkWhiteLotus(address _address) external virtual override  view returns(bool)
    {
        return WL.isWhiteLotus(_address);
    }

    function getAllNodeAddress(address start,uint32 len) external override view returns(address[] memory)
    {
        return WL.getAllAddress(start,len);
    }
    function getAllNode(address start,uint32 len) public view returns(WhiteLotus.Node[] memory){
        return WL.getAllNode(start,len);
    }

    function getAllWhiteLotus() public view returns(address[] memory lstAdd,uint32[] memory lstID,uint256[] memory Value){
        return WL.getAllWhiteLotus();
    }

    function getAllWhiteLotusAddress() public view returns(address[] memory){
        (address[] memory lstAdd,,) = WL.getAllWhiteLotus();
        return lstAdd;
    }

    function getHolder(address _address) external view returns(WhiteLotus.Node memory)
    {
        return WL.getNode(_address);
    }

    function getNumHolder() external override view returns(uint32)
    {
        return WL.getCount();
    }
}