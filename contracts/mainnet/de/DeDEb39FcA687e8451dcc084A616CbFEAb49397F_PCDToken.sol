/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

pragma solidity >=0.6.8;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract PCDToken is Ownable {
  using Address for address;
  using SafeMath for uint;
  address[] public nodes;
  uint256 public favor;
  address public PCDToken;
  uint256 public PCDvalue;
  mapping(address =>bool)public isVote;
  address public getPcdAddress;
    constructor () public {
        PCDToken=0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c;
        //PCDToken=0xB942Fd0f1222C17e1DF8Efabef33c0612734D81e;
    }
    function addNode(address addr)public onlyOwner{
       nodes.push(addr);
    }
    //投票赞成提现PCD
    function vode()public{
        //您已经投票，一个地址只能投票一次
        require(!isVote[_msgSender()],"You have voted");
        uint node;
        //在21个基金会成员中检索当前投票人
        for(uint i=0;i<nodes.length;i++){
           if(_msgSender() == nodes[i]){
               node=1;//已经匹配是基金会成员
           }
        }
        //必须是基金会成员才能进行投票
        require(node==1,"Not a member of the foundation");
        favor++;//赞成票+1
        isVote[_msgSender()]=true;//表示已经投票过，不能重复投票
    }
    //任何人都可以申请提现PCD金额
   function withdrawPCDvalue(uint _pcd)public{
        PCDvalue=_pcd;
        getPcdAddress=_msgSender();
   }
   function withdrawPCD()public{
    require(getPcdAddress !=address(0),"Applicant cannot be blank");
    require(_msgSender()==getPcdAddress,"Must be applicant");
     uint node=nodes.length.mul(80).div(100);//80%基金会人数  
    require(favor >= node,"Insufficient votes");//投票数量必须大于等于所有成员80%
    ERC20(PCDToken).transfer(getPcdAddress,PCDvalue);//提现PCD
    PCDvalue=0;
    favor=0;
    for(uint i=0;i<nodes.length;i++){
        isVote[nodes[i]]=false;//所有基金会成员状态设置为可以再次投票
        }
   }
}


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}