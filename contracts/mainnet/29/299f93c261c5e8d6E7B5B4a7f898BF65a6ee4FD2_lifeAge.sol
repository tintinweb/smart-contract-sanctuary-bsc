/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = 0;
        if (b > 0 && a > 0) {
            c = a / b;
        }
        return c;
    }
}

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function getAgeLive(address adduser) external view returns (uint256);
}

contract lifeAge {
    using SafeMath for uint256;
    address private myceo;
    address private _token;
    address private addOracle;
    uint256 ageout = 0;
    mapping(address => uint256) private AgeAddress;

    constructor(address token_) {
        myceo = msg.sender;
        _token = token_;
    }

    function OracleSet(address oadd) external {
        require(myceo == msg.sender, "error right");
        addOracle = oadd;
    }

    function outAge(uint256 getnum) external {
        uint256 numgetover = AgeAddress[msg.sender];
        uint256 numlive = 0;

        IERC20 mainContract = IERC20(addOracle);
        numlive = mainContract.getAgeLive(msg.sender);
        if (numlive > 0 && (numlive - numgetover) >= getnum) {
            numgetover = numgetover.add(getnum);
            AgeAddress[msg.sender] = numgetover;

            IERC20 tokenContract = IERC20(_token);
            tokenContract.transfer(msg.sender, getnum);
            ageout = ageout.add(getnum);
        }
    }

    function getAge(address adds) external view returns (uint256) {
        return AgeAddress[adds];
    }

    function getAgeAll() external view returns (uint256) {
        return ageout;
    }

    function getToken() external view returns (address) {
        return _token;
    }
}