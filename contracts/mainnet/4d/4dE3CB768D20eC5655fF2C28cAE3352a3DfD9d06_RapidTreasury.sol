/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IRdfiTreasury {
    function deposit() external payable;
}

contract RapidTreasury is Auth, IRdfiTreasury {
    using SafeMath for uint256;
    mapping(address => uint256) public shareHolders;
    mapping(address => uint256) shareHolderIndices;
    address[] founders;
    uint256 public totalShares = 0;
    uint256 public foundersBalance = 0;
    uint256 public treasuryBalance = 0;
    uint256 index = 0;
    address public rDFi = 0x9fdcc07A32A9e2E6EF0D319333331F98dFb47943;
    event Withdrawal(string reason);

    constructor() Auth(msg.sender) {}

    receive() external payable {}

    /**
    Every deposit pays the founders 50% and 
    keeps 50% in the treasury for adhoc activities 
    such as listings, marketing, dev etc.
     */
    function deposit() external payable {
        uint256 balanceToAdd = msg.value.div(2);
        foundersBalance += balanceToAdd;
        treasuryBalance += balanceToAdd;

        if (foundersBalance >= 1 * 10**18) {
            for (uint256 j = 0; j < founders.length; j++) {
                uint256 value = shareHolders[founders[j]].div(totalShares).mul(
                    foundersBalance
                );
                (bool founderPaid, ) = payable(founders[j]).call{value: value}(
                    ""
                );

                if (founderPaid) foundersBalance -= value;
            }
        }
    }

    function addFounder(address addr, uint256 share) external onlyOwner {
        require(shareHolders[addr] == 0, "Founder already exists");
        founders.push(addr);
        shareHolderIndices[addr] = index;
        index += 1;
        shareHolders[addr] = share;
        totalShares += share;
    }

    function removeFounder(address addr) external onlyOwner {
        require(shareHolders[addr] != 0, "Founder does not exists");
        delete founders[shareHolderIndices[addr]];
        totalShares -= shareHolders[addr];
        shareHolders[addr] = 0;
    }

    function emergencyWithdraw() external onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        if (success) {
            foundersBalance = 0;
            treasuryBalance = 0;
        }
    }

    function emergencyWithdrawTokens(address token) external onlyOwner {
        IBEP20 tokenIB20 = IBEP20(token);
        tokenIB20.transfer(msg.sender, tokenIB20.balanceOf(address(this)));
    }

    /**
    Pay project dev items directly from the treasury.
    Reasons can be:
    1 - Marketing
    2 - Dev
    3 - Misc
     */
    function withdrawForProjectDevelopment(
        uint256 amount,
        address receiver,
        string memory reason
    ) external authorized {
        (bool success, ) = payable(receiver).call{value: amount}("");
        if (success) {
            treasuryBalance -= amount;
            emit Withdrawal(reason);
        }
    }

    /**
    Pay project dev items directly from the treasury.
    Reasons can be:
    1 - Marketing
    2 - Dev
    3 - Misc
     */
    function withdrawRdfiForProjectDevelopment(
        uint256 amount,
        address receiver,
        string memory reason
    ) external authorized {
        IBEP20 tokenIB20 = IBEP20(rDFi);
        bool success = tokenIB20.transfer(receiver, amount);
        if (success) emit Withdrawal(reason);
    }
}