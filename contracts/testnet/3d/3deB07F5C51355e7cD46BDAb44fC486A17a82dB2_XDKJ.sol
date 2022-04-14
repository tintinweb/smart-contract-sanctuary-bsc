// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./ERC20Detailed.sol";


contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = msg.sender;
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(now > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract XDKJ is Ownable, ERC20, ERC20Detailed {
    using SafeMath for uint256;

    mapping (address => bool) internal whiteList;
    uint MAXHOLD;

    constructor () public ERC20Detailed("XDKJ", "XDKJ", 18) {
        _mint(msg.sender, 10000000 * (10 ** uint256(decimals())));
        MAXHOLD = 1000 * (10 ** uint256(decimals()));
    }

    function isWhite(address addr) public view returns (bool){
        return whiteList[addr];
    }

    function setWhite(address addr) external onlyOwner returns (bool){
        whiteList[addr] = true;
        return true;
    }
    function unsetWhite(address addr) external onlyOwner returns (bool){
        whiteList[addr] = false;
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal{
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        if(!isWhite(recipient)){
            require(_balances[recipient] <= MAXHOLD, "hold overflow");
        }
        emit Transfer(sender, recipient, amount);
    }

}