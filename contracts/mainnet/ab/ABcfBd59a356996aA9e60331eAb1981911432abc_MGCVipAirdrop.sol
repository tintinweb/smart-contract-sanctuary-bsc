/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

pragma solidity ^0.8.10;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; 
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


contract MGCVipAirdrop is Ownable {
    uint256 perUintAmount = 2000 * 10 ** 18;
    address mgctoken = 0x7773FeAF976599a9d6A3a7B5dc43d02AC166F255;

    mapping(address => uint32) public userList;


    function withdraw() public {
        require(userList[msg.sender] > 0, "Not in user list or has been withdraw");
        require(perUintAmount > 0, "Not open");
        IERC20(mgctoken).transfer(msg.sender, userList[msg.sender] * perUintAmount);
        userList[msg.sender] = 0;
        emit Withdrawn(msg.sender, perUintAmount);
    }

    // Withdraw ETH that gets stuck in contract by accident
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function emergencyWithdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function setPerUintAmount(uint256 amount) external onlyOwner {
        perUintAmount = amount;
    }

    function getBalance(address account) public view returns (uint256) {
        return userList[account] * perUintAmount;
    }

    function appendUser(address[] memory accounts, uint32[] memory numbers) public onlyOwner {
        require(accounts.length == numbers.length, "Error array length");
        for (uint256 i = 0; i < accounts.length; i++) {
            userList[accounts[i]] = numbers[i];
        }
    }

    //event
    event Withdrawn(address indexed user ,uint256 perUintAmount);

}