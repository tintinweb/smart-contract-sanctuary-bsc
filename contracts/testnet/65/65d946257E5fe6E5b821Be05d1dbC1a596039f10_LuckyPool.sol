/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


//   _                _            _____            _ 
//  | |              | |          |  __ \          | |
//  | |    _   _  ___| | ___   _  | |__) |__   ___ | |
//  | |   | | | |/ __| |/ / | | | |  ___/ _ \ / _ \| |
//  | |___| |_| | (__|   <| |_| | | |  | (_) | (_) | |
//  |______\__,_|\___|_|\_\\__, | |_|   \___/ \___/|_|
//                          __/ |                     
//                         |___/                      


contract LuckyPool is Ownable{
    using SafeMath for uint256;
    AggregatorV3Interface internal priceFeed;
    address private priceAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // BNB/USD Testnet

    /**
     * @dev 
     * BSC Mainnet
     * BNB/USD: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     * BTC/USD: 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
     * ETH/USD: 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e
     * WBNB: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c

     *
     * BSC Testnet
     * BNB/USD: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     * BTC/USD: 0x5741306c21795FdCBb9b265Ea0255F499DFe515C
     * ETH/USD: 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7
     * WBNB: 0x15C9e651b5971FeB66E19Fe9E897be6BdC3e841A
     */

    constructor() {
        priceFeed = AggregatorV3Interface(priceAddress);
    }

    // Manager
    mapping(address => bool) managers;
    modifier onlyManager() {
        require(managers[_msgSender()], "Caller is not the Manager");
        _;
    }
    function setupManager(address[] memory addrs, bool _status)  external  onlyOwner {
        for(uint256 i = 0; i < addrs.length ; i++ ) {
            managers[addrs[i]] = _status;
        }
    }

    // Wallets
    address[] sharingWallets;

    function setSharingWallets(address[] memory addresses) public onlyOwner {
        sharingWallets = addresses;
    }

    function getSharingWallets() public view returns (address[] memory) {
        return sharingWallets;
    }

    // Percents
    uint256[] sharingPercent;

    function setSharingPercent(uint256[] memory percents) public onlyOwner {
        sharingPercent = percents;
    }

    function getSharingPercent() public view returns (uint256[] memory) {
        return sharingPercent;
    }

    function deposit(address tokenAddress, uint256 amount) public {
        IBEP20 Token = IBEP20(tokenAddress);
        require(IBEP20(tokenAddress).balanceOf(msg.sender) >= amount, "Insufficient balance");
        Token.transferFrom(msg.sender, address(this), amount);
        // sharing wallets
        for(uint256 i = 0; i < sharingPercent.length ; i++ ) {
            Token.transfer(sharingWallets[i], amount.mul(sharingPercent[i]).div(100));
        }   
    }

    function depositCurrency() payable public  {
        require(msg.sender.balance > msg.value, "Insufficient balance");
        payable(address(this)).transfer(msg.value);
        for(uint256 i = 0; i < sharingPercent.length ; i++ ) {
            payable(sharingWallets[i]).transfer(msg.value.mul(sharingPercent[i]).div(100));
        }
        
    }

    receive() external payable{}
    function withdrawCurrency(uint256 amount, address to) external onlyManager{
        payable(to).transfer(amount);
    }

    function withdrawToken(address tokenContract) external onlyManager {
        IBEP20(tokenContract).transfer(owner(), IBEP20(tokenContract).balanceOf(address(this)));
    }

}