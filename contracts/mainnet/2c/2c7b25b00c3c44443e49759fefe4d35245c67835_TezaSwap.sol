/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () {
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

contract TezaSwap is Ownable {
    uint256 public balance;
    uint256 public exchangeRate=1077476;
    event Bought(uint256 amount);
    event Sold(uint256 amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    IBEP20 private immutable token;


    function setExchangeRate(uint256 amount) public onlyOwner {
        require(amount <= 10**7, "Exchange Rate too high");
        exchangeRate = amount;
    }

    function setExchangeRateForce(uint256 amount) public onlyOwner {
        exchangeRate = amount;
    }

    function getExchangeRate() public view returns (uint256) {
        return exchangeRate;
    }

    constructor(address _BEP20Address) {
        token = IBEP20(_BEP20Address);
    }

    function buy() payable public {
        uint256 amountTobuy = (msg.value*exchangeRate);
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some BNB");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        payable(owner()).transfer(msg.value);//transfer bnb out to owner
        token.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function withdraw(uint amount, address payable destAddr) public onlyOwner{
        require(amount <= balance, "Insufficient funds");
        destAddr.transfer(amount);
        balance -= amount;
        emit TransferSent(msg.sender, destAddr, amount);
    }

    function transferERC20(IBEP20 _token, address to, uint256 amount) public onlyOwner{
        uint256 erc20balance = _token.balanceOf(address(this));
        require(amount <= erc20balance, "balance is low");
        _token.transfer(to, amount);
        emit TransferSent(msg.sender, to, amount);
    }
}