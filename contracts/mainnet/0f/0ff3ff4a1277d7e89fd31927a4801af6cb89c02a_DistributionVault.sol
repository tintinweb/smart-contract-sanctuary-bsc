/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

//SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract DistributionVault {

    using SafeMath for uint256;

    // These are owner by default
    address public projectBankReceiver;
    address public alphaPayReceiver;
    address public lottoPayReceiver;
    address public devPayReceiver;
    address public mktMngrPayReceiver;
    address public webMngrPayReceiver;    

    bool public liveStatus;
    
    address public owner;

    constructor() {

        owner = msg.sender;

    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    receive()   external payable{ }
    fallback()  external payable{ }

    // Transfer percentages
    uint256 public alphaPay = 50;       //50%
    uint256 public lottoPay = 20;       //20%
    uint256 public devPay = 4;          //4%
    uint256 public projectBankPay = 20;    //20%  - Gas / Giveaways / Burning Alpha ... etc. 
    uint256 public mktMngrPay = 2;
    uint256 public webMngrPay = 2;
    uint256 public payDenominator = 100; 


    // switch Live status
    function setLiveStatus(bool _status) public onlyOwner  {
        liveStatus = _status; 
    }

    // Set pay receivers
    function setPayReceivers(
            address _projectBankReceiver, 
            address _alphaPayReceiver, 
            address _lottoPayReceiver, 
            address _devPayReceiver,
            address _mktMngrPayReceiver,
            address _webMngrPayReceiver  

            ) 
            external onlyOwner {
        projectBankReceiver = _projectBankReceiver;
        alphaPayReceiver = _alphaPayReceiver;
        lottoPayReceiver = _lottoPayReceiver;
        devPayReceiver = _devPayReceiver;
        mktMngrPayReceiver = _mktMngrPayReceiver;
        webMngrPayReceiver = _webMngrPayReceiver;
    }

    function setPayAmounts(
        uint256 _alphaPay, 
        uint256 _lottoPay, 
        uint256 _devPay, 
        uint256 _mktMngrPay, 
        uint256 _webMngrPay,
        uint256 _projectBankPay, 
        uint256 _payDenominator
        ) 
        external onlyOwner {
        alphaPay = _alphaPay;
        lottoPay = _lottoPay;
        devPay = _devPay;
        projectBankPay = _projectBankPay;
        mktMngrPay = _mktMngrPay;
        webMngrPay = _webMngrPay;
        payDenominator = _payDenominator; 

    }
    
    function sendPay() external onlyOwner {
        require(liveStatus, "Vault not Live");
        uint256 contractETHBalance = (address(this).balance) / payDenominator;
        payable(projectBankReceiver).transfer(contractETHBalance.mul(projectBankPay)); 
        payable(alphaPayReceiver).transfer(contractETHBalance.mul(alphaPay));
        payable(lottoPayReceiver).transfer(contractETHBalance.mul(lottoPay));
        payable(devPayReceiver).transfer(contractETHBalance.mul(devPay)); 
        payable(mktMngrPayReceiver).transfer(contractETHBalance.mul(mktMngrPay)); 
        payable(webMngrPayReceiver).transfer(contractETHBalance.mul(webMngrPay)); 
        
    }

    function depositToVault() public payable{
        require(liveStatus, "Vault not Live");
        require(msg.value >= ((1 ether) / 1000), "You must send at least .001 ETHER");
    }
   
    function clearStuckBalance() public onlyOwner {
        uint256 contractEthBalance = address(this).balance;
        payable(devPayReceiver).transfer(contractEthBalance);
    } 

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    
}