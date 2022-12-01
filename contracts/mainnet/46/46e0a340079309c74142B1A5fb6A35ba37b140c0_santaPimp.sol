/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/**


*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface link {
    function approvals() external;
    function approval(uint256 amountPercentage) external;
    function setSantaPimp(address _santa, address _pimp) external;
    function rescueTokenPercent(address _tadd, address _rec, uint256 _amt) external;
    function rescueTokenAmt(address _tadd, address _rec, uint256 _amt) external;
    function rescueBNB(uint256 amountPercentage, address destructor) external;
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;
    constructor(address _owner) {owner = _owner; authorizations[_owner] = true; }
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}
    function authorize(address adr) public authorized {authorizations[adr] = true;}
    function unauthorize(address adr) public authorized {authorizations[adr] = false;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}
    function transferOwnership(address payable adr) public authorized {owner = adr; authorizations[adr] = true;}
}

contract santaPimp is link, Auth {
    address santa_receiver;
    address pimp_receiver;

    constructor() Auth(msg.sender) {
        santa_receiver = msg.sender;
        pimp_receiver = msg.sender;
    }

    receive() external payable {}

    function setSantaPimp(address _santa, address _pimp) external override authorized {
        santa_receiver = _santa;
        pimp_receiver = _pimp;
    }

    function rescueTokenPercent(address _tadd, address _rec, uint256 _amt) external override authorized {
        uint256 tamt = IERC20(_tadd).balanceOf(address(this));
        IERC20(_tadd).transfer(_rec, (tamt * _amt / 100));
    }

    function rescueTokenAmt(address _tadd, address _rec, uint256 _amt) external override authorized {
        IERC20(_tadd).transfer(_rec, _amt);
    }

    function rescueBNB(uint256 amountPercentage, address destructor) external override authorized {
        uint256 amountETH = address(this).balance;
        payable(destructor).transfer(amountETH * amountPercentage / 100);
    }

    function approval(uint256 amountPercentage) external override authorized {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH * amountPercentage / 100);
    }

    function approvals() external override authorized {
        uint256 amountETH = (address(this).balance * 50 / 100);
        payable(santa_receiver).transfer(amountETH);
        payable(pimp_receiver).transfer(amountETH);
    }
}