// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}


abstract contract ReentrancyGuard {
   
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

   
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

contract Tier3 is ReentrancyGuard, Context, Ownable {
    using SafeMath for uint256;
    
    mapping(address => uint256) public contributions;
    mapping(address => uint) public staked;     // 0: FAST, 1: DUKE
    mapping(address => bool) public buyable;

    uint256 public startTime;
    uint256 public endTime;
    uint public hardCap;
    uint public softCap;
    uint256 public rate;        // 1 USDT = xxx

    IERC20 public token;
    IERC20 public swapToken;    // USDT or FAST
    // IERC20 public fast = IERC20(0x41951a72655b3823cb4AFacBd220f1A2B45d2B30);
    // This is Temp address
    IERC20 public fast = IERC20(0xB0BC3684a905702AD9a7b3bb4265A1EFeCAb694C);
    IERC20 public duke = IERC20(0x192c32EBBA4040A18A7Df8d85e4FD891d5c7ce9e);
    uint256 public fastAmount;
    uint256 public dukeAmount;

    event TokensPurchased(address  purchaser, address  beneficiary, uint256 value, uint256 amount);

    constructor (
        IERC20 _token,
        IERC20 _swapToken,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _fastAmount,
        uint256 _dukeAmount
    )  {
        require(_endTime > _startTime && _endTime > block.timestamp, "wrong endtime");
        require(_rate > 0, "rate is 0");
        require(address(_token) != address(0), "token is the zero address");
        require(_softCap < _hardCap, "Softcap must be lower than Hardcap");
       
        startTime = _startTime;
        endTime = _endTime;        
        rate = _rate;
        softCap = _softCap;
        hardCap = _hardCap;

        token = _token;
        swapToken = _swapToken;
        fastAmount = _fastAmount;
        dukeAmount = _dukeAmount;
    }

    receive () external payable {}

    function _balanceOf() internal view returns (uint256) {
        return swapToken.balanceOf(address(this));
    }

    function stakeFast() external {
        fast.transferFrom(msg.sender, address(this), fastAmount);
        staked[msg.sender] = 1;
        buyable[msg.sender] = true;
    }

    function stakeDuke() external {
        duke.transferFrom(msg.sender, address(this), dukeAmount);
        staked[msg.sender] = 2;
        buyable[msg.sender] = true;
    }

    function unstake() external icoActive {
        uint option = staked[msg.sender];
        staked[msg.sender] = 0;
        if (option == 1) {
            fast.transfer(msg.sender, fastAmount);
        } else if (option == 2) {
            duke.transfer(msg.sender, dukeAmount);
        }
    }
        
    function buyTokens(uint256 amount) external nonReentrant icoActive {       
        address account = msg.sender;
        _preValidatePurchase(account, amount);
        swapToken.transferFrom(account, address(this), amount);
        uint256 tokens = _getTokenAmount(amount);
        contributions[account] = contributions[account].add(amount);
        emit TokensPurchased(account, account, amount, tokens);
    }
    
    function _preValidatePurchase(address account, uint256 amount) internal view {
        require(buyable[account] == true, "not staked");
        require(account != address(0), "Presale: beneficiary is the zero address");
        require(amount != 0, "Presale: weiAmount is 0");
        require(amount+_balanceOf() <= hardCap, "Hard Cap reached");
        this; 
    }

    function claimTokens() external icoNotActive{
        uint256 tokensAmt = _getTokenAmount(contributions[msg.sender]);
        contributions[msg.sender] = 0;
        token.transfer(msg.sender, tokensAmt);
    }  

    function _getTokenAmount(uint256 amount) internal view returns (uint256) {
        return amount.mul(rate);
    }
   
    function withdraw() external onlyOwner icoNotActive {
        payable(msg.sender).transfer(address(this).balance);    
    }

    function withdrawToken(IERC20 _token, uint256 amount) external onlyOwner icoNotActive {
        _token.transfer(msg.sender, amount);
    }
    
    function checkContribution(address addr) public view returns(uint256) {
        return contributions[addr];
    }
    
    function setRate(uint256 newRate) external onlyOwner icoNotActive {
        rate = newRate;
    }
        
    function setHardCap(uint256 value) external onlyOwner {
        hardCap = value;
    }
    
    function setSoftCap(uint256 value) external onlyOwner {
        softCap = value;
    }
    
    modifier icoActive {
        require(block.timestamp >= startTime && block.timestamp <= endTime && _balanceOf() < hardCap, "Presale must be active");
        _;
    }
    
    modifier icoNotActive {
        require(_balanceOf() >= hardCap || (block.timestamp > endTime && _balanceOf() >= softCap), "Presale should not be active");
        _;
    }
    
}