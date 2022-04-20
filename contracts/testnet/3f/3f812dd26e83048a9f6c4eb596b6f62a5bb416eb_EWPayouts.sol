/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

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
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract EWPayouts is Auth {
    using SafeMath for uint256;

    constructor() {
        owner = msg.sender;
        authorizations[owner] = true;
    }

    uint256 public devTotalShare = 6;
    uint256 public researcherTotalShare = 6;
    uint256 public trackerTotalShare = 6;
    uint256 public ambassadorTotalShare = 40;

    uint256 public devCount = 2;
    uint256 public researcherCount = 2;
    uint256 public trackerCount = 3;
    uint256 public ambassadorCount = 10;

    uint256 public devShare = 3;
    uint256 public researcherShare = 3;
    uint256 public trackerShare = 2;
    uint256 public ambassadorShare = 4;

    uint256 public headexecutiveShare = 7;
    uint256 public eliteWhalesShare = 35;

    uint256 public devSharePayout = 0;
    uint256 public researcherSharePayout = 0;
    uint256 public trackerSharePayout = 0;
    uint256 public ambassadorSharePayout = 0;
    uint256 public headexecutiveSharePayout = 0;
    uint256 public eliteWhalesSharePayout = 0;

    uint256 private dcounter = 0;
    uint256 private rcounter = 0;
    uint256 private tcounter = 0;
    uint256 private acounter = 0;

    receive() external payable { }

    function calculatePayout() external authorized {
        uint256 contractBNBBalance = address(this).balance;
        devSharePayout = (contractBNBBalance * devShare) / 100;
        researcherSharePayout = (contractBNBBalance * researcherShare) / 100;
        trackerSharePayout = (contractBNBBalance * trackerShare) / 100;
        ambassadorSharePayout = (contractBNBBalance * ambassadorShare) / 100;
        headexecutiveSharePayout = (contractBNBBalance * headexecutiveShare) / 100;
        eliteWhalesSharePayout = (contractBNBBalance * eliteWhalesShare) / 100;
        dcounter = 0;
        rcounter = 0;
        tcounter = 0;
        acounter = 0;
    }

    function paydevShare(address _wallet) external authorized {
        require(dcounter < devCount);
        payable(_wallet).transfer(devSharePayout);
        dcounter++;
    }

    function payresearcherShare(address _wallet) external authorized {
        require(rcounter < researcherCount);
        payable(_wallet).transfer(researcherSharePayout);
        rcounter++;
    }

    function paytrackerShare(address _wallet) external authorized {
        require(tcounter < trackerCount);
        payable(_wallet).transfer(trackerSharePayout);
        tcounter++;
    }

    function payambassadorShare(address _wallet) external authorized {
        require(acounter < ambassadorCount);
        payable(_wallet).transfer(ambassadorSharePayout);
        acounter++;
    }

    function payheadexecutiveShare(address _wallet) external authorized {
        payable(_wallet).transfer(headexecutiveSharePayout);
    }

    function payeliteWhalesShare(address _wallet) external authorized {
        payable(_wallet).transfer(eliteWhalesSharePayout);
    }
    
    function setTotalShare(uint256 _devTotalShare, uint256 _researcherTotalShare, uint256 _trackerTotalShare, uint256 _ambassadorTotalShare, uint256 _headexecutiveShare, uint256 _eliteWhalesShare) external authorized {
        devTotalShare = _devTotalShare;
        researcherTotalShare = _researcherTotalShare;
        trackerTotalShare = _trackerTotalShare;
        ambassadorTotalShare = _ambassadorTotalShare;
        headexecutiveShare = _headexecutiveShare;
        eliteWhalesShare = _eliteWhalesShare;

        devShare = devTotalShare / devCount;
        researcherShare = researcherTotalShare / researcherCount;
        trackerShare = trackerTotalShare / trackerCount;
        ambassadorShare = ambassadorTotalShare / ambassadorCount;
    }

    function setdevCount(uint256 _devCount) external authorized {
        devCount = _devCount;
        devShare = devTotalShare / devCount;
    }

    function setresearcherCount(uint256 _researcherCount) external authorized {
        researcherCount = _researcherCount;
        researcherShare = researcherTotalShare / researcherCount;
    }

    function settrackerCount(uint256 _trackerCount) external authorized {
        trackerCount = _trackerCount;
        trackerShare = trackerTotalShare / trackerCount;
    }

    function setambassadorCount(uint256 _ambassadorCount) external authorized {
        ambassadorCount = _ambassadorCount;
        ambassadorShare = ambassadorTotalShare / ambassadorCount;
    }

    function depositBNB() payable public {    
    // nothing to do here
    }

    function retrieveBNB(address _wallet) external authorized {
        uint256 contractBNBBalance = address(this).balance;
        payable(_wallet).transfer(contractBNBBalance);
    }
}