/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// I'm a comment!
// SPDX-License-Identifier: MIT
// pragma solidity 0.8.7;
// pragma solidity ^0.8.0;
pragma solidity >=0.8.0 <0.9.0;


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);
}


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

abstract contract Ownable is Context {
    address public _owner;

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

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity >=0.8.0 <0.9.0;


contract MysteryBox is Ownable{
    // 代币的合约地址 测试网络Newxx地址
    address public nxxToken = 0x04575D8f29903aA7eB162AAE8777Ab9e71b598d6;

    // 最大可获得奖励
    uint256 public maxAmount = 1000 * 10 ** 18;

    // 开启盲盒单次消耗金额
    uint256 public openBoxAmount = 100 * 10 ** 18;

    // 开启盲盒单次消耗金额
    uint256 public createBoxAmount = 8000 * 10 ** 18;

    mapping(uint32 => Box) public boxMap;

    struct Box{
        // 创建者
        address creator;
        // 0为正常  1关闭
        uint8 status;
        // 盲盒中可分配金额
        uint256 mysteryBoxAmount;
        // 盲盒中本次的最大奖
        uint256 maxMysteryBoxAmount;
        // 最大奖是否被领取
        uint8 isBiggestReceive;
    }


    // 系统配置
     function setting(uint256 _minAmount, uint256 _openBoxAmount, uint256 _createBoxAmount) public onlyOwner{
        maxAmount = _minAmount;
        openBoxAmount = _openBoxAmount;
        createBoxAmount = _createBoxAmount;
      }

    // 修改盲盒数据
    function setBoxMap(uint32 boxId, address creator, uint8 status, uint256 _mysteryBoxAmount, uint256 _maxMysteryBoxAmount, uint8 _isBiggestReceive) public onlyOwner{
        boxMap[boxId] = Box(creator, status, _mysteryBoxAmount, _maxMysteryBoxAmount, _isBiggestReceive);
    }

    // 初始化盲盒 1,3,7,0,2202314845500000000000     2,8,15,0,1166226600000000000000
    function createBoxMap(uint32 boxId, uint256 _maxMysteryBoxAmount) public{
        // 操作调用者合约地址划转到当前合约地址中
        IERC20(nxxToken).transferFrom(msg.sender, address(this), createBoxAmount);
        boxMap[boxId] = Box(msg.sender, 0, createBoxAmount, _maxMysteryBoxAmount, 0);
    }

    function getBoxMap(uint32 boxId) public view returns (Box memory) {
        return boxMap[boxId];
    }


    // 用户参与盲盒抽取
    function game(uint32 boxId, uint256 _amount) public returns (uint256 rAmount ) {
        require(boxMap[boxId].status != 1, "Box is close");
        require(_amount <= maxAmount, "once Max Fiet");

        // 扣除燃烧费 = 本次实际投资资产
        IERC20(nxxToken).transferFrom(msg.sender, address(this), openBoxAmount);
        // 余额是否充足
        require(IERC20(nxxToken).balanceOf(address(this)) >= _amount, "Contract Balance Insufficient");
        // 增加到对应的资金池中
        boxMap[boxId].mysteryBoxAmount -= _amount;

        return _amount;
    }

    // 一键提现合约中的Token 代币
    function withdraw(address _token, uint256 withdraw_amount) public onlyOwner{
        uint256 amount = IERC20(_token).balanceOf(address(this));
        require(amount >= withdraw_amount, ">=1 Newxx");

        IERC20(_token).transfer(0x440fc3462d45d6D79e42ad6d79E3beef2A0f6855, withdraw_amount);
    }

 
    
    

}