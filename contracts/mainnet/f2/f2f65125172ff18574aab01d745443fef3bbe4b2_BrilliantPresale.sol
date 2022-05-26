/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BrilliantPresale is Ownable {

    using SafeMath for uint256;

    struct UserInfo {
        address buyer;
        uint256 brilliantAmount;
    }

    IERC20 public BRLT = IERC20(0x9b173d57cAC08Aa65E74e207a1F2fE9468DFcF84);
    IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address public treasury;
    address public Recipient = 0xC0837E6EF18639471B947B4a5a724eEdef44156a;

    uint256 public tokenRatePerEth = 3; // 1 * (10 ** decimals) BRLT per eth

    uint256 public minETHLimit = 10 ether;
    uint256 public maxETHLimit = 1500 ether;

    uint256 public softCap = 20000 ether;
    uint256 public hardCap = 80000 ether;
    uint256 public totalRaisedETH = 0; // total ETH raised by sale
    uint256 public totaltokenSold = 0;

    uint256 public startTime = 1652861000;
    uint256 public endTime = 1652861600;
    bool public claimOpened;
    bool public contractPaused = true; // circuit breaker

    mapping(address => uint256) private _totalPaid;
    mapping(address => UserInfo) public userinfo;

    event Deposited(uint amount);
    event Claimed(address receiver, uint amount);

    modifier checkIfPaused() {
        require(contractPaused == false, "contract is paused");
        _;
    }

    constructor(address _treasury) {
        require(_treasury != address(0), "treasury address is not 0");
        treasury = _treasury;
    }

    function setPresaleToken(address tokenaddress) external onlyOwner {
        require( tokenaddress != address(0) );
        BRLT = IERC20(tokenaddress);
    }

    function setRecipient(address recipient) external onlyOwner {
        Recipient = recipient;
    }

    function setTokenRatePerEth(uint256 rate) external onlyOwner {
        tokenRatePerEth = rate;
    }

    function setMinEthLimit(uint256 amount) external onlyOwner {
        minETHLimit = amount;    
    }

    function setMaxEthLimit(uint256 amount) external onlyOwner {
        maxETHLimit = amount;    
    }
    
    function updateCap(uint256 _hardcap, uint256 _softcap) external onlyOwner {
        softCap = _softcap;
        hardCap = _hardcap;
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        require(_startTime > block.timestamp, 'past timestamp');
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        require(_endTime > startTime, 'should be bigger than start time');
        endTime = _endTime;
    }

    function openClaim() external onlyOwner {
        require(!claimOpened, 'Already opened');
        require(block.timestamp < endTime, 'Presale not over yet');
        claimOpened = true;
    }

    function togglePause() external onlyOwner returns (bool){
        contractPaused = !contractPaused;
        return contractPaused;
    }

    function deposit(uint256 _amount) public checkIfPaused {
        require(block.timestamp > startTime, 'Sale has not started');
        require(block.timestamp < endTime, 'Sale has ended');
        require(totalRaisedETH <= hardCap, 'HardCap exceeded');
        require(
                _totalPaid[msg.sender].add(_amount) <= maxETHLimit
                && _totalPaid[msg.sender].add(_amount) >= minETHLimit,
                "Investment Amount Invalid."
        );

        uint256 tokenAmount = getTokensPerEth(_amount);
        
        if (userinfo[msg.sender].buyer == address(0)) {
            UserInfo memory l;
            l.buyer = msg.sender;
            l.brilliantAmount = tokenAmount;
            userinfo[msg.sender] = l;
        }
        else {
            userinfo[msg.sender].brilliantAmount += tokenAmount;
        }

        totalRaisedETH = totalRaisedETH.add(_amount);
        totaltokenSold = totaltokenSold.add(tokenAmount);
        _totalPaid[msg.sender] = _totalPaid[msg.sender].add(_amount);
        
        BUSD.transferFrom(msg.sender, treasury, _amount);
        emit Deposited(_amount);
    }

    function claim() public {
        UserInfo storage l = userinfo[msg.sender];
        require(l.buyer == msg.sender, "You are not allowed to claim");
        require(claimOpened, "Claim not open yet");
        uint amount = l.brilliantAmount;
        l.brilliantAmount = 0;
        require(amount <= BRLT.balanceOf(address(this)), "Insufficient balance");
        BRLT.transfer(msg.sender, amount);
        emit Claimed(msg.sender, amount);
    }

    function getUnsoldTokens(address token, address to) external onlyOwner {
        require(block.timestamp > endTime, "You cannot get tokens until the presale is closed.");
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)) );
    }

    function getUserRemainingAllocation(address account) external view returns ( uint256 ) {
        return maxETHLimit.sub(_totalPaid[account]);
    }

    function getTokensPerEth(uint256 amount) internal view returns(uint256) {
        return amount.mul(tokenRatePerEth/10).div(10**(uint256(18).sub(BRLT.decimals())));
    }
}