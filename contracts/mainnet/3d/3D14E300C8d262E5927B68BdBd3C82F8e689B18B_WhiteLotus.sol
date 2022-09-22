/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

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
    function update(address _wallerAddress,uint256 _value) internal virtual returns (Node memory) {
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
    function del(address _wallerAddress) internal virtual returns (uint32) {
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







contract WhiteLotus is sortList, WhiteLotusInterface, BEPOwnable {
    mapping(uint32 => bool) public mapWhiteLotus;
    uint32 public MinWhiteLotusID;
    uint32 public MaxCount;
    uint32 public count;
    bool manualRun;
    address public VICDAOMainContract;

    constructor() {
        MaxCount = 44;
        count = 0;
        mapWhiteLotus[topNode] = true;
        MinWhiteLotusID = topNode;
        manualRun = false;
        VICDAOMainContract = 0x091EbDAef88a62029cf249bb9aE7e07BbF00EfFE;
    }

    function setVICDAOMainContract(address _VICDAOMainContract) external onlyOwner{
        VICDAOMainContract = _VICDAOMainContract;
    }

    function UpdateWhiteLotusMaxCount(uint32 _NewMaxCount) external override {
        require(msg.sender == VICDAOMainContract || msg.sender == owner(), "only VICDAOMainContract can call this function");
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

    function isWhiteLotus(address add) external override view returns(bool){
        return mapWhiteLotus[mapAddress2ID[add]];
    }

    function getAllWhiteLotus() external override view returns(address[] memory lstAdd,uint32[] memory lstID,uint256[] memory Value){
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
    function getAllAddress(address start,uint32 len) external override view returns(address[] memory){
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
    function setmanualRun(bool status) external override {
        require(msg.sender == VICDAOMainContract || msg.sender == owner(), "only VICDAOMainContract can call this function");
        manualRun = status;
    }
    function getNode(address add) public view returns(Node memory){
        return mapNode[mapAddress2ID[add]];
    }

    //======================================================OVERRIDE FUNCTION============================================================

    function updateNode(address[] memory _wallerAddress) external {
        require(msg.sender == VICDAOMainContract || msg.sender == owner(), "only VICDAOMainContract can call this function");
        address dNELUMContract = 0x572071333A74915d31B68B9b37fa01c07bB0c446;
        for (uint256 i = 0; i < _wallerAddress.length; i++){
            uint256 dNELUM = IBEP20(dNELUMContract).balanceOf(_wallerAddress[i]);
            uint256 value = dNELUM / (10**uint256(18));//bo so thap phan
            sortList.update(_wallerAddress[i], value);
        }
    }
    function updateNode(address _wallerAddress,uint256 _value) external override {
        require(msg.sender == VICDAOMainContract || msg.sender == owner(), "only VICDAOMainContract can call this function");
        if (!manualRun)
            sortList.update(_wallerAddress,_value);
    }
    function delNode(address _wallerAddress) external override returns (uint32 delNodeID) {
        require(msg.sender == VICDAOMainContract || msg.sender == owner(), "only VICDAOMainContract can call this function");
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

    function getNodeCount() external override view returns(uint32 res){
        return  getCount();
    }
}