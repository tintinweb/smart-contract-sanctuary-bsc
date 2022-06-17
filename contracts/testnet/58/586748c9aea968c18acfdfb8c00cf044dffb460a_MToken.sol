/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
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
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function decimals() external view returns (uint256);

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

contract MToken is Ownable {

    uint256 public price = 200 * 10 ** 18;

    address private first;
    address public collect;
    IERC20 usdt;

    mapping(address => address) _leaders;
    mapping(address => uint256) _direct;
    mapping(address => bool) _buy;

    constructor(){
        first = _msgSender();
        collect = _msgSender();
        usdt = IERC20(0x62c0D5bC317a10d2214C58018574C534567180a2);
    }

    modifier onlyActivate() {
        require(isActivate(_msgSender()), "Caller is not activated");
        _;
    }

    function isActivate(address account) public view returns (bool){
        return _leaders[account] != address(0) || account == first;
    }

    function activate(address account) public {
        require(account != address(0), "Wrong address");
        require(isActivate(account), "Leader is not activated");
        require(_leaders[account] == address(0), "Already activated");
        _leaders[_msgSender()] = account;
    }

    function buy() public onlyActivate {
        require(!_buy[_msgSender()], "Already bought");
        address _leader = _leaders[_msgSender()];
        _direct[_leader]++;
        _buy[_msgSender()] = true;
        uint256 amount;
        uint256 nowPrice = price;
        uint8 i = 0;
        while (i < 4 && _leader != address(0)) {
            if (_buy[_leader]) {
                if (i == 0 && _direct[_leader] >= 1) {
                    amount = price * 5 / 100;
                    usdt.transferFrom(_msgSender(), _leader, amount);
                } else if (i == 1 && _direct[_leader] >= 2) {
                    amount = price * 3 / 100;
                    usdt.transferFrom(_msgSender(), _leader, amount);
                } else if (i >= 2 && _direct[_leader] >= 3) {
                    amount = price * 3 / 100;
                    usdt.transferFrom(_msgSender(), _leader, amount);
                }
                nowPrice -= amount;
            }
            _leader = _leaders[_leader];
            i++;
        }
        usdt.transferFrom(_msgSender(), collect, nowPrice);
    }


    function recharge(address token, uint256 amount) public onlyActivate {
        IERC20(token).transferFrom(_msgSender(), collect, amount);
    }

    function setCollect(address account) public onlyOwner {
        require(account != address(0), "Wrong address");
        collect = account;
    }

    function setPrice(uint256 _price) public onlyOwner {
        require(price > 0, "Wrong price");
        price = _price;
    }
}