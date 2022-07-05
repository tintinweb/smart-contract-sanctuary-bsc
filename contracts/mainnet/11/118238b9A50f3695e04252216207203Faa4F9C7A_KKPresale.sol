/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

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
 
     function _msgSender() internal view virtual returns (address) {
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

contract KKPresale is Ownable {

    using SafeMath for uint256;

    IERC20 public KK = IERC20(0x8D6f2a7e9648d94aF853D6B340fdF6797Fc1E80A);
    address public Recipient = 0x7646eb896fa0E6F1E3D9E6Eb93495112E56Aa13a;

    uint256 public tokenRatePerEth = 10000; // 10000 * (10 ** decimals) KK per eth
    uint256 public minETHLimit = 0.01 ether;
    uint256 public minInviteETHLimit = 0.01 ether;
    uint256 public maxETHLimit = 10 ether;

    uint256 public hardCap = 4000 ether;
    uint256 public totalRaisedBNB = 0; // total BNB raised by sale
    uint256 public totaltokenSold = 0;

    uint256 public startTime;
    uint256 public endTime;
    bool public contractPaused; // circuit breaker
 
    mapping(address => uint256) public usersInvestments;
    mapping(address => address[]) public userInviters;

    constructor(uint256 _startTime, uint256 _endTime) {
        startTime = _startTime;
	endTime = _endTime;
    }
    
    event parentInfo(
        address indexed childAddress,
        address indexed parentAddress
    );

    struct UserInfo {
        uint256 referTime;
        address parent;
        bool isShare;
        uint256 referIdoNum;
        bool shareRefund;
        uint256 idoAmount;
        bool idoRefund;
        uint256 buyAmount;
	uint256 rewardAmount;
    }
    mapping(address => UserInfo) public userInfo;

    modifier checkIfPaused() {
        require(contractPaused == false, "contract is paused");
        _;
    }

    function setPresaleToken(address tokenaddress) external onlyOwner {
        require( tokenaddress != address(0) );
        KK = IERC20(tokenaddress);
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

    function setMinInviteETHLimit(uint256 amount) external onlyOwner {
        minInviteETHLimit = amount;    
    }

    function setMaxEthLimit(uint256 amount) external onlyOwner {
        maxETHLimit = amount;    
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        endTime = _endTime;
    }

    function togglePause() external onlyOwner returns (bool){
        contractPaused = !contractPaused;
        return contractPaused;
    }

    receive() external payable{
        deposit();
    }

    function deposit() public payable checkIfPaused {
        require(block.timestamp > startTime, 'Sale has not started');
        require(block.timestamp < endTime, 'Sale has ended');
        require(
                usersInvestments[msg.sender].add(msg.value) <= maxETHLimit
                && usersInvestments[msg.sender].add(msg.value) >= minETHLimit,
                "Installment Invalid."
        );
        
        UserInfo storage user = userInfo[msg.sender];
        bool hasBuy=false;

	if (user.idoAmount == 0 &&user.parent != address(0x0)) {
            UserInfo storage parent = userInfo[user.parent];
            parent.referIdoNum = parent.referIdoNum + 1;
        }

        if (user.parent != address(0x0)) {
            UserInfo storage parent = userInfo[user.parent];
	    if(parent.buyAmount>= minInviteETHLimit){
               hasBuy=true;
	    }
        }

        uint256 tokenAmount = getTokensPerEth(msg.value);

	if(user.parent != address(0x0)&&hasBuy==true){

            tokenAmount =tokenAmount+tokenAmount*2/100;
	    UserInfo storage parentuser = userInfo[user.parent];
            uint256 referralAmount = 0;
            uint256 toAmount = 0;

            uint256  parentUserCount=parentuser.referIdoNum;
	    if(parentUserCount>=10){
	        referralAmount=msg.value*1/100;
	        toAmount =msg.value.sub(referralAmount);
	        parentuser.rewardAmount.add(referralAmount);
	    }else{
	        referralAmount=msg.value*5/100;
	        toAmount =msg.value.sub(referralAmount);
	        parentuser.rewardAmount.add(referralAmount);
	     }
            require(KK.transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
            totalRaisedBNB = totalRaisedBNB.add(msg.value);
            totaltokenSold = totaltokenSold.add(tokenAmount);
            usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);

            payable(Recipient).transfer(toAmount);
            payable(user.parent).transfer(referralAmount);

	}else{
	
	    require(KK.transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
            totalRaisedBNB = totalRaisedBNB.add(msg.value);
            totaltokenSold = totaltokenSold.add(tokenAmount);
            usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);
            payable(Recipient).transfer(msg.value);
	
	}
        user.buyAmount = user.buyAmount.add(tokenAmount);
        user.idoAmount = user.idoAmount.add(msg.value);
    }

   function referParent(address parentAddress) public {
        require(
            parentAddress != msg.sender,
            "Error: parent address can not equal sender!"
        );
        require(
            userInfo[msg.sender].parent == address(0),
            "Error: sender must be has no parent!"
        );
        require(
            parentAddress == owner() || userInfo[parentAddress].parent != address(0),
            "Error: parentAddress must be has parent!"
        );
        require(
            !isContract(parentAddress),
            "Error: parent address must be a address!"
        );
        userInfo[msg.sender].parent = parentAddress;
        userInfo[msg.sender].referTime = block.timestamp;
        userInviters[parentAddress].push(msg.sender);
        emit parentInfo(msg.sender, parentAddress);
    }
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }
    function getUnsoldTokens(address token, address to) external onlyOwner {
        require(block.timestamp > endTime, "You cannot get tokens until the presale is closed.");
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)) );
        payable(to).transfer(address(this).balance);
    }

    function getUserRemainingAllocation(address account) external view returns ( uint256 ) {
        return maxETHLimit.sub(usersInvestments[account]);
    }

    function getTokensPerEth(uint256 amount) internal view returns(uint256) {
        return amount.mul(tokenRatePerEth).div(10**(uint256(18).sub(KK.decimals())));
    }

    function getUserInfo(address account) public view returns (address, bool, bool, bool, uint256[7] memory){
        UserInfo storage user = userInfo[account];
        address[] storage inviters = userInviters[account];
        uint256 totalTeam = 0;
        for (uint256 i = 0; i < inviters.length; i++) {
            totalTeam = totalTeam.add(userInfo[inviters[i]].buyAmount);
        }
        uint256[7] memory d = [user.referTime, user.referIdoNum, user.idoAmount, user.buyAmount, inviters.length, totalTeam, user.rewardAmount];
        return (user.parent, user.isShare, user.shareRefund, user.idoRefund, d);
    }

}