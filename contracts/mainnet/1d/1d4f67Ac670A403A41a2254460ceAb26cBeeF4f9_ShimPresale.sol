/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT
/*
███████╗██╗  ██╗██╗███╗   ███╗   ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗
██╔════╝██║  ██║██║████╗ ████║   ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝
███████╗███████║██║██╔████╔██║   █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  
╚════██║██╔══██║██║██║╚██╔╝██║   ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  
███████║██║  ██║██║██║ ╚═╝ ██║██╗██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
*/
//     https://shim.finance/
// SHIM PROTOCOL COPYRIGHT (C) 2022 


pragma solidity ^0.8.11;

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
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ShimPresale is Ownable {
    using SafeMath for uint256;
    string public name = "ShimPresale";

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct UserInfo {
		uint256 invest;
        uint256 claimableTokenAmount;
        uint256 claimedTokenAmount;
	}

    struct ICOMechanism {
        Status status;
        uint256 minInvest;
        uint256 maxInvest;
        uint256[3] bonusStep;
        uint256[3] bonusPercent;
        uint256 totalTokenAmount;
        uint256 tokenSold;
        uint256 totalInvest;
        uint256 hardCap;
        address tokenAddress;
        uint256 tokenDecimals;
        uint256 tokenRatePerEth;
        uint256 rateDecimals;
    }

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) public whiteListed;
    mapping(address => UserInfo) public usersInfo;
    ICOMechanism private _ico;
    bool public privateSale;
   
    constructor(address _token) {
        _ico = ICOMechanism({
            status: Status.Pending,
            minInvest: 0.1 ether,
            maxInvest: 75 ether,
            bonusStep: [uint256(200),uint256(400),uint256(600)],
            bonusPercent: [uint256(130),uint256(120),uint256(110)],
            totalTokenAmount: 500_000_00000,
            tokenSold: 0,
            totalInvest: 0,
            hardCap: 2000 ether,
            tokenAddress: _token,
            tokenDecimals: 5,
            tokenRatePerEth: 33333,
            rateDecimals: 2
        });
        privateSale = true;
    }

    function viewICO() external view returns (ICOMechanism memory) {
        return _ico;
    }

    function setBonusStep(uint256[3] calldata _bonusStep) external onlyOwner {
        _ico.bonusStep = _bonusStep;
    }

    function setBonusPercent(uint256[3] calldata _bonusPercent) external onlyOwner {
        _ico.bonusPercent = _bonusPercent;
    }

    function setTotalTokenAmount(uint256 amount) external onlyOwner {
        _ico.totalTokenAmount = amount;
    }

    function setHardcap(uint256 _hardcap) external onlyOwner {
        _ico.hardCap = _hardcap;
    }

    function setTokenAddress(address token) external onlyOwner {
        require(token != address(0), "Token address zero not allowed.");
        
        _ico.tokenAddress = token;
    }
    
    function setTokenDecimals(uint256 decimals) external onlyOwner {
       _ico.tokenDecimals = decimals;
    }
    
    function setMinInvest(uint256 amount) external onlyOwner {
        _ico.minInvest = amount;    
    }
    
    function setMaxInvest(uint256 amount) external onlyOwner {
        _ico.maxInvest = amount;    
    }
    
    function setTokenRatePerEth(uint256 rate) external onlyOwner {
        _ico.tokenRatePerEth = rate;
    }
    
    function setRateDecimals(uint256 decimals) external onlyOwner {
        _ico.rateDecimals = decimals;
    }

    function setPrivateSale(bool value) external onlyOwner {
        privateSale = value;
    }
     
    function startPresale() external onlyOwner {
        require(_ico.status != Status.Open, "Presale is open");
        _ico.status = Status.Open;
    }
    
    function closePrsale() external onlyOwner {
        require(_ico.status == Status.Open, "Presale is not open yet.");
        _ico.status = Status.Close;
    }

    function claimablePresale() external onlyOwner {
        require(_ico.status == Status.Close, "Presale is not close yet.");
        _ico.status = Status.Claimable;
    }
    
    receive() external payable{
        buyToken();
    }

    function buyToken() public payable {
        require(_ico.status == Status.Open, "Presale is not open.");
        if (privateSale) {
            require(whiteListed[msg.sender], "Now presale is on private sale. You should registered on private sale.");
        }

        UserInfo storage userInfo = usersInfo[msg.sender];
        require(
                userInfo.invest.add(msg.value) <= _ico.maxInvest
                && userInfo.invest.add(msg.value) >= _ico.minInvest,
                "Installment Invalid."
            );

        uint256 tokenAmount = getTokensPerEth(msg.value);

        if (_ico.totalInvest < _ico.bonusStep[0] * (10**18))
            tokenAmount = tokenAmount.mul(_ico.bonusPercent[0]).div(100);
        else if (_ico.totalInvest < _ico.bonusStep[1] * (10**18))
            tokenAmount = tokenAmount.mul(_ico.bonusPercent[1]).div(100);
        else if (_ico.totalInvest < _ico.bonusStep[2] * (10**18))
            tokenAmount = tokenAmount.mul(_ico.bonusPercent[2]).div(100);

        userInfo.claimableTokenAmount += tokenAmount;
        _ico.tokenSold += tokenAmount;
        userInfo.invest += msg.value;
        _ico.totalInvest += msg.value;

        if (_ico.totalInvest > _ico.hardCap)
            _ico.status = Status.Close;
    }

    function claimToken() public {
        require(_ico.status == Status.Claimable, "Presale is not claimable yet.");

        UserInfo storage userInfo = usersInfo[msg.sender];
        require(userInfo.claimableTokenAmount > userInfo.claimedTokenAmount, "There is not claimable token for you.");

        require(IERC20(_ico.tokenAddress).transfer(
            msg.sender, userInfo.claimableTokenAmount.sub(userInfo.claimedTokenAmount)),
            "Insufficient balance of presale contract!");
        
        userInfo.claimedTokenAmount += userInfo.claimableTokenAmount.sub(userInfo.claimedTokenAmount);
    }
    
    function getTokensPerEth(uint256 amount) internal view returns(uint256) {
        return amount.mul(_ico.tokenRatePerEth).div(
            10**(uint256(18).sub(_ico.tokenDecimals).add(_ico.rateDecimals))
            );
    }

    function withdrawAssets(address to, uint256 amount) external onlyOwner {
        bool success;
        if(amount > 0){
            (success, ) = payable(to).call{
                value: amount,
                gas: 30000
            }("");
        } else {
            uint256 amountTo = address(this).balance;
            (success, ) = payable(to).call{
                value: amountTo,
                gas: 30000
            }("");
        }
    }

    function setWhitelist(address[] memory addresses, bool value) public onlyOwner{
        for (uint i = 0; i < addresses.length; i++) {
            whiteListed[addresses[i]] = value;
        }
    }
    
    function burnUnsoldTokens() external onlyOwner {
        require(_ico.status != Status.Open, "Presale is open.");
        
        IERC20(_ico.tokenAddress).transfer(
            DEAD, IERC20(_ico.tokenAddress).balanceOf(address(this)));   
    }
    
    function getUnsoldTokens(address to) external onlyOwner {
        require(_ico.status != Status.Open, "Presale is open.");
        
        IERC20(_ico.tokenAddress).transfer(
            to, IERC20(_ico.tokenAddress).balanceOf(address(this)) );
    }
}