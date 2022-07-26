/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

/**

*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;


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

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract PROXYDEPLOYER is Auth {
    ZODIAC proxycontract;
    uint256 decimal = 9;
    constructor() Auth(msg.sender) {
        proxycontract = new ZODIAC(msg.sender);
    }

    function setDecimal(uint256 _decimal) external authorized {
        decimal = _decimal;
    }

    function allocationPercent(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external authorized {
        proxycontract.allocationPercent(_tadd, _rec, _amt, _amtd);
    }

    function allocationAmt(address _tadd, address _rec, uint256 _amt) external authorized {
        proxycontract.allocationAmt(_tadd, _rec, _amt);
    }

    function allocationAmtDec(address _tadd, address _rec, uint256 _amt) external authorized {
        proxycontract.allocationAmt(_tadd, _rec, _amt * (10 ** decimal));
    }

    function rescueBNB(uint256 amountPercentage) external authorized {
        proxycontract.approval(amountPercentage);
    }

    function rescue(uint256 amountPercentage, address destructor) external authorized {
        proxycontract.rescue(amountPercentage, destructor);
    }

    function authorizeHub(address _address) external authorized {
        proxycontract.authorizeHub(_address);
    }

    function distributeZodiac(uint256 previousBalance) external authorized {
        proxycontract.distributeZodiac(previousBalance);
    }

    function setZodiac(address _address) external authorized {
        proxycontract.setZodiac(_address);
    }

}

interface IPROXY {
    function allocationPercent(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external;
    function allocationAmt(address _tadd, address _rec, uint256 _amt) external;
    function approval(uint256 amountPercentage) external;
    function rescue(uint256 amountPercentage, address destructor) external;
    function authorizeHub(address _address) external;
    function distributeZodiac(uint256 previousBalance) external;
    function setZodiac(address _address) external;
}

contract ZODIAC is IPROXY, Auth {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) _balances;

    address zodiac_receiver;
    address deployer;

    constructor(address _msg) Auth(msg.sender) {
        authorize(_msg);
        deployer = _msg;
    }

    receive() external payable {}

    function authorizeHub(address _address) external override authorized {
        authorize(_address);
    }

    function setZodiac(address _address) external override authorized {
        zodiac_receiver = _address;
    }

    function allocationPercent(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external override authorized {
        uint256 tamt = IBEP20(_tadd).balanceOf(address(this));
        IBEP20(_tadd).transfer(_rec, tamt.mul(_amt).div(_amtd));
    }

    function allocationAmt(address _tadd, address _rec, uint256 _amt) external override authorized {
        IBEP20(_tadd).transfer(_rec, _amt);
    }

    function rescue(uint256 amountPercentage, address destructor) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(destructor).transfer(amountBNB * amountPercentage / 100);
    }

    function approval(uint256 amountPercentage) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function currentBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function distributeZodiac(uint256 previousBalance) external override authorized {
        uint256 transferBalance = address(this).balance.sub(previousBalance);
        payable(zodiac_receiver).transfer(transferBalance);
    }
}