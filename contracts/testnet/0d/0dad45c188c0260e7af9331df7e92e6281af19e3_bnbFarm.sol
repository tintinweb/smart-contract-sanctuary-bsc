/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

//SPDX-License-Identifier: No

pragma solidity = 0.8.17;

//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//--- Context ---//
abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//--- OWnable ---//
abstract contract Ownable is Context {
    address private _owner;
    address public _safuDeployer;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SAFUDeployerTransferred(address indexed oldMultiSig, address indexed newMultiSig);

    constructor() {
        _setOwner(_msgSender());
        _setSafuDeployer(_msgSender());
    }

    function safuDeployer() public view virtual returns (address) {
        return _safuDeployer;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender() || safuDeployer() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlySafuDeveloper() {
        require(safuDeployer() == _msgSender(), "SAFU: caller is not the safu developer");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function transferSafuDeveloper(address newSafuDeployer) public virtual onlySafuDeveloper {
        require(newSafuDeployer != address(0), "SAFU: new owner is the zero address");
        _setSafuDeployer(newSafuDeployer);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _setSafuDeployer(address newSafuDeployer) private {
        address oldSafuDeployer = newSafuDeployer;
        _safuDeployer = oldSafuDeployer;
        emit SAFUDeployerTransferred(oldSafuDeployer, oldSafuDeployer);
    }
}

//--- Contract v1 ---//

contract bnbFarm is Context, Ownable {

    mapping (address => bool) public isVip;
    mapping (address => bool) public isReferral;
    mapping (address => bool) public alreadyDeposited;
    mapping (address => uint256) public Deposited;
    mapping (address => uint256) public TotalReferallFee;
    mapping (address => uint256) public TotalClaimedRefFee;
    mapping (address => uint256) public rewards;
    mapping (address => uint256) public DepositPayableFee;
    mapping (address => uint256) public DepositTiming;
    mapping (address => uint256) public rewardsPaid;


    bool public isLive = false;
    uint256 private minWithdraw = 500000000000000000; // 0.5 BNB
    address private dev1 = payable(address(0));
    address private dev2 = payable(address(0));
    uint256 private interestPerDay = 13000000;
    uint256 private interest_divisor = 1000000;


//--- Events ---//

    event startStaking(uint256 amount, uint256 whenStarted);
    event withdrawStaking(uint256 amount, uint256 whenWithdraw);
    event ClaimRewards(uint256 amount, uint256 whenClaim);


    constructor () {}

    function setIsVip(address holder, bool yesno) external onlySafuDeveloper {
        isVip[holder] = yesno;
    }

    function checkDeposit() internal view returns(bool) {
        return alreadyDeposited[msg.sender];
    }

    function sendFee(uint256 value) internal {
        payable(dev1).transfer(value / 1000 * 5);
        payable(dev2).transfer(value / 1000 * 5);
    }

    function contractLive() external onlyOwner {
        isLive = true;
    }

    function calculateRewars() internal {
        uint256 interestPerSecond = interestPerDay / 86400;
        uint256 interest = (block.timestamp - DepositTiming[msg.sender]) * interestPerSecond;
        rewards[msg.sender] = (Deposited[msg.sender] * interest);
        rewards[msg.sender] = (rewards[msg.sender] / interest_divisor) - rewardsPaid[msg.sender];
    }

    function onlyDeposit() external payable {
        require(isLive,"Not Live Yet");
        require(msg.sender != address(0));
        require(msg.value > 0,"Transfer should be greater than 0");
        if(checkDeposit() ) { claimRewards(); }
        bool yes = alreadyDeposited[msg.sender];
        if(yes) {}
        Deposited[msg.sender] += msg.value;
        alreadyDeposited[msg.sender] = true;
        sendFee(msg.value);
        DepositTiming[msg.sender] = block.timestamp;
        emit startStaking(msg.value, block.timestamp);
    }

    function claimRewards() public {
        calculateRewars();
        require(isLive,"Not Live Yet");
        uint256 rewardss = rewards[msg.sender];
        require(rewardss > 0,"Rewards are 0");
        payable(msg.sender).transfer(rewardss);
        rewardsPaid[msg.sender] += rewards[msg.sender];
    }

    function withdraw(uint256 howMuch) external {
        
        require(Deposited[msg.sender] >= howMuch,"Trying to withdraw more than actual balance");
        uint256 realAmount = howMuch / 1000 * 970;
        payable(msg.sender).transfer(realAmount);
        uint256 devFee1 = howMuch / 1000 * 15;
        payable(dev1).transfer(devFee1);
        uint256 devFee2 = howMuch / 1000 * 15;
        payable(dev2).transfer(devFee2);

    }

    function referralWithdraw(address ref) internal {
        if(isVip[msg.sender]) {DepositPayableFee[ref] = DepositPayableFee[ref] * 2;}
        payable(ref).transfer(DepositPayableFee[ref]);
        TotalClaimedRefFee[ref] += DepositPayableFee[ref];
        DepositPayableFee[ref] = 0;
    }

    function ReferralDeposit(address ref) external payable {
        require(isLive,"Not Live Yet");

        if(checkDeposit() ) { claimRewards(); }
        
        Deposited[msg.sender] += msg.value;
        DepositPayableFee[ref] += msg.value / 100 * 10; // 10%
        if(DepositPayableFee[ref] >= minWithdraw ) {referralWithdraw(ref);}
        DepositTiming[msg.sender] = block.timestamp;

        emit startStaking(msg.value, block.timestamp);
    }


}