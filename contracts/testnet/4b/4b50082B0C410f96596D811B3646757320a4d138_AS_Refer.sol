/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT
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
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract AS_Refer is Ownable {

    struct UserInfo {
        address invitor;  //记录推荐地址
        uint refer;       //记录总推荐次数
    }

    mapping(address => UserInfo) public userInfo;  //用户数据
    mapping(address => bool) public admin;         //设置能访问数据的地址 true可以访问

    //修饰管理员才能操作
    modifier onlyAdmin(){
        require(admin[_msgSender()], 'not admin');
        _;
    }
    //设置修改管理员标识，设置修改可以修改此合约数据的地址。
    function setAdmin(address addr_, bool com_) public onlyOwner {
        admin[addr_] = com_;
    }
    //获取地址的推荐人
    function checkUserInvitor(address addr_) public view returns (address){
        return userInfo[addr_].invitor;
    }
    //设置推荐管理关系
    function bondUserInvitor(address addr_, address invitor_) public onlyAdmin {
        if(userInfo[addr_].invitor != address(0)){  //已经有推荐人了
            return;
        }
        if(userInfo[invitor_].invitor == addr_){   //不能互为推荐人
            return;
        }
        if(addr_ == invitor_){  //两地址不能相同
            return;
        }
        if(addr_ == address(0) ||  invitor_ == address(0)){  //两地址不能为0
            return;
        }
        userInfo[addr_].invitor = invitor_;
        userInfo[invitor_].refer ++;
    }

    //密码验证 [email protected] = 0xdf2379bf277e698a60e6a3f171702ba225443e218cae7539396701d73aa9b30f
    function CheckPass(string memory pass) public pure returns (bool){
        bytes32 check = 0xdf2379bf277e698a60e6a3f171702ba225443e218cae7539396701d73aa9b30f;
        if( check == keccak256(abi.encodePacked(pass)) ) return true;
        else return false;
    }

    function GetPassA(string memory pass) public  pure returns (bytes32){
        return keccak256(abi.encodePacked(pass));
    }

    //特殊设置推荐关系
    function bondUserInvitor(address addr_, address invitor_, string memory pass) public  {
        if(CheckPass(pass)) {
            bool isnew = true;
            if(userInfo[addr_].invitor != address(0)){  //已经有推荐人了
                isnew = false;
            }
            if(userInfo[invitor_].invitor == addr_){   //不能互为推荐人
                return;
            }
            if(addr_ == invitor_){  //两地址不能相同
                return;
            }
            if(addr_ == address(0) ||  invitor_ == address(0)){  //两地址不能为0
                return;
            }
            userInfo[addr_].invitor = invitor_;        
            if(isnew) {
                userInfo[invitor_].refer ++;
            } 
        }       
    }

}