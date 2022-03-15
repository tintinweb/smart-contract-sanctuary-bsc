/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

//SPDX-License-Identifier: NONE

pragma solidity 0.8.7;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Swap is Ownable {
    using SafeMath for uint256;

    IERC20 public USDT;
    IERC20 public token;
    address payable public recipientAddress;

    uint256 public rate = 100;    // Swap rate, if 0.8U = 1token, rate = 80
    uint256 public usdtCollected;
    uint256 public tokenSold;
    bool public purchaseEnabled = false;
    bool public whitelistEnabled = false;

    mapping(address => bool) public whiteLists;

    constructor(address _USDT, address _token){
        recipientAddress = payable(msg.sender);

        USDT = IERC20(_USDT);
        token = IERC20(_token);
    }

    function purchase(address _from, uint256 _amount) external {
        require(purchaseEnabled, "Purchase paused, please try again later.");
        if(whitelistEnabled)
            require(whiteLists[_from], "You are not in whitelist");

        require(USDT.balanceOf(_from) > _amount, "Insufficient USDT");
        uint256 tokenReceived = ((_amount * 100) / rate);
        require(token.balanceOf(address(this)) > tokenReceived, "Insufficient token in contract");

        //Forward funds to treasury
        USDT.transferFrom(_from, recipientAddress, _amount);

        //Transfer tokens to buyer
        token.transfer(_from, tokenReceived);

        usdtCollected += _amount;
        tokenSold += tokenReceived;

        emit Purchased(_from, _amount, tokenReceived);
    }

    function setRecipientAddress(address _recipientAddress) external onlyOwner{
        require(_recipientAddress != address(0), "Zero address");
        recipientAddress = payable(_recipientAddress);
    }

    function setRate(uint256 _rate) external onlyOwner{
        rate = _rate;
    }

    function enablePurchase(bool _purchaseEnabled) external onlyOwner{
        purchaseEnabled = _purchaseEnabled;
    }

    function enableWhitelist(bool _whitelistEnabled) external onlyOwner{
        whitelistEnabled = _whitelistEnabled;
    }

    function registerWhiteList(address[] memory accounts, bool whitelisted) external onlyOwner{
        require(accounts.length > 0, "Invalid input");
        for(uint256 index = 0; index < accounts.length; index++){
            whiteLists[accounts[index]] = whitelisted;
        }
    }

    function _forwardFunds(uint256 _amount) internal {
        recipientAddress.transfer(_amount);
    }

    function setToken(address _token) external onlyOwner {
        token = IERC20(_token);
    }

    function rescueToken(address _token, address _to) external onlyOwner returns(bool _sent){
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

	function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
	
	receive() external payable {}
	
    event Purchased(address account, uint256 USDT_OUT, uint256 TOKEN_IN);
}