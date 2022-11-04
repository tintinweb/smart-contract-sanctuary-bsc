// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
}

// SPDX-License-Identifier: MIT
// Creator: 9571  by 2022/11/04
pragma solidity ^0.8.9;


import "./access/Ownable.sol";

contract notary is Ownable {

    //公证 MAP
    mapping(string => NotarizationItem) private MapSave; //信息 Map 结构

    mapping(string => address) private Maplog; //存储日志 只有 owner 能查看

    uint public  Num;

  //公证信息结构
  struct NotarizationItem {
    string    ver;   //数据版本    
    string    note;  //数据文本
    string    file;  //文件信息
    uint      timeValue;  //创建时间
    uint      timeExpired; //数据过期时间 如果大于这个时间无法打开
    uint      timeLock; //数据过期时间 如果大于这个时间无法打开//数据锁定时间 如果小于这个时间无法打开
    uint      status; //数据状态
   }
  
    //输出日志 添加信息 添加序列号
    event Msg(string Msg,uint Num);

    //获得数据值
    function getValue (string memory hashKey)  public view returns(NotarizationItem memory  ) {

    NotarizationItem storage value = MapSave[hashKey];
    NotarizationItem memory  tmp;

        //返回数据已经添加过标志
        if(value.status==1)
        {
            //判断时间是否过期
            if(value.timeExpired!=0)
            {
                if(value.timeExpired>block.timestamp)
                {
                    //判断是否过锁定期
                    if(block.timestamp>value.timeLock)
                    {
                     return value;
                    }
                }
            }else{
                   //判断是否过锁定期
                    if(block.timestamp>value.timeLock)
                   {
                     return value;
                   }
            }

        }
      //所有标志位没有提前触发 返回空标志位
      return tmp;
    }

    //管理员查询指定数据
    function getLog(string memory hashKey)  public view onlyOwner returns(address) {
      return Maplog[hashKey];
    }

    //添加数据值
    function addValue (string memory hashKey,string  memory ver,string memory note,string memory file,uint timeExpired,uint timeLock)  public returns(NotarizationItem memory) {

        //获得哈希表数据
        NotarizationItem storage value = MapSave[hashKey];

        //返回数据已经添加过标志
        if(value.status==1)
        {
          return value;
        }

        //进行数据添加

        //添加数据表
        MapSave[hashKey] = NotarizationItem({
            ver : ver, 
            note : note, 
            file :file, 
            timeValue :block.timestamp, 
            timeExpired :timeExpired,  //数据过期时间
            timeLock :timeLock,        //数据锁定时间
            status : 1 
            });

        //记录日志 最初调用者
        Maplog[hashKey] =  tx.origin; 

        Num++;
        emit Msg(hashKey,Num);

        //返回对应数值选项
        return  value;
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}