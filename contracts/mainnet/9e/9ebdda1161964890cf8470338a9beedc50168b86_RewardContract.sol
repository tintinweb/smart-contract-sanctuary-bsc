/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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


contract RewardContract is Context, Ownable{
    IERC20 HouseToken;
    address tokenContract = 0xb710023F4DD3Ff78e72666473a09b25A80c19ce2;

    mapping(address => uint256) receivedTime;

    event TimeIsNotUp(address addr, uint256 time);
    event ReceiveRecord(address addr, uint256 amount);
    constructor () {
        HouseToken = IERC20(tokenContract);
    }

    function RewardFunc(address[] memory addrs,uint256[] memory amounts) public onlyOwner {
        for(uint256 i = 0; i < addrs.length; i++){
            if(addrs[i] == address(0)) continue;
            if(receivedTime[addrs[i]] + 1 days >  block.timestamp){
                emit TimeIsNotUp(addrs[i], receivedTime[addrs[i]] + 1 days);
                continue;
            }
            HouseToken.transfer(addrs[i], amounts[i]);
            receivedTime[addrs[i]] = block.timestamp;
            emit ReceiveRecord(addrs[i], amounts[i]);
        }
    }
}