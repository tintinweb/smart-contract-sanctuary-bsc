/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";
abstract contract Context {
    constructor () { }
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

// import "@openzeppelin/contracts/utils/Address.sol";
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function toPayable(address account) internal pure returns (address) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
abstract contract ReentrancyGuard {
    bool private _notEntered;
    constructor () {
        _notEntered = true;
    }
    modifier nonReentrant() {
        require(_notEntered, "ReentrancyGuard: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
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
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

contract HALOCOINPresale is ReentrancyGuard, Context{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public _token;

    address public _owner;
    address public _admin;

    uint256 public _rate;   // 1 BNB = rate * TOKEN
    uint256 public _weiRaised;
    uint256 public _totalSupply;
    uint256 public _minPurchase;
    uint256 public _maxPurchase;

    bool public _presaleStarted;

    mapping(address => uint256) public holders;

    modifier onlyOwner {
        require(address(msg.sender) == _owner, "Only owner can call this function!");
        _;
    }

    modifier onlyAdmin {
        require(address(msg.sender) == _admin, "Only admin can call this function!");
        _;
    }

    modifier whenPresaleStarted {
        require(_presaleStarted, "Presale is stopped, contact admin for starting the presale!");
        _;
    }

    modifier whenPresaleStopped {
        require(!_presaleStarted, "Presale is already started, contact admin for stopping the presale");
        _;
    }


    event TokensPurchased(address indexed buyer, address indexed beneficiary, uint256 value, uint256 amount);
    event PresaleStarted(address startedBy);
    event PresaleStoped(address stoppedBy);
    event OwnerCollectedBNB(uint256 amount);
    event OwnerCollectedTOKEN(uint256 tokens);

    constructor() {
        _admin = address(msg.sender);
        _presaleStarted = false;
    }

    function startPresale(
        IERC20 token,
        uint256 rate,
        uint256 weiRaised,
        uint256 totalSupply,
        uint256 minPurchase,
        uint256 maxPurchase,
        address owner
        ) external onlyAdmin whenPresaleStopped
    {
        require(address(token) != address(0), "Token address must not be zero address");
        require(rate != 0, "rate must not be equal to zero");
        require(totalSupply != 0, "totalSupply most not be equal to zero");
        require(minPurchase != 0, "minPurchase most not be equal to zero");
        require(maxPurchase > minPurchase, "maxPurchase must be greater than minPurchase");

     
        _token = token;
        _owner = owner;

        _rate = rate;
        _weiRaised = weiRaised;
        _totalSupply = totalSupply;
        _minPurchase = minPurchase;
        _maxPurchase = maxPurchase;
        _presaleStarted = true;

        holders[address(this)] = _totalSupply;

        emit PresaleStarted(address(msg.sender));
    }

    function stopPresale() external onlyAdmin whenPresaleStarted {
        _presaleStarted = false;
    }
    
    function buyTokens() payable public whenPresaleStarted{

        uint256 weiAmount = msg.value;
        require(weiAmount >= _minPurchase && weiAmount <= _maxPurchase, "weiAmount must be between minPurchase and maxPurchase (inclusive)");
        uint256 tokens = _getTokenAmount(weiAmount);

        _weiRaised = _weiRaised + weiAmount;
        _totalSupply = _totalSupply - tokens;
        
        payable(_owner).transfer(msg.value);

        holders[address(msg.sender)] += tokens;
        _token.transfer(address(msg.sender), tokens);

        emit TokensPurchased(address(msg.sender), address(msg.sender), weiAmount, tokens);
    }

    receive() payable external {
        require(msg.value!=0, "BNB is required!");
        buyTokens();
    }
   

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return (((weiAmount * _rate) / 10**18) * (10**9));
    }

    function TokenBalanceOf() external view onlyAdmin returns(uint256){
        return _token.balanceOf(address(this));
    }

    function collectOwnableAmount(address beneficiary) external onlyAdmin {
        require(address(this).balance > 0, "BNB balance is zero");
        uint256 amount = address(this).balance;
        payable(beneficiary).transfer(amount);

        emit OwnerCollectedBNB(amount);
    }

    function collectLeftTokens(address beneficiary) external onlyAdmin whenPresaleStopped {
        uint256 tokens = _token.balanceOf(address(this));
        _token.transfer(beneficiary, tokens);
        _totalSupply = 0;

        emit OwnerCollectedTOKEN(tokens);

    }
}