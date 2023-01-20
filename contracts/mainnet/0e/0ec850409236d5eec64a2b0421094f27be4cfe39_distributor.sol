/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

pragma solidity ^0.8.0;

// Token lock contract
// SPDX-License-Identifier: MIT

// ERC20 interface
interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}




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



abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
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

// Token lock contract
contract distributor is Auth {
    // ERC20 token contract
    constructor () Auth(msg.sender) {
    }

    ERC20 public token;

    using SafeMath for uint256;

    function setToken(address _tokenAddress) public onlyOwner {
        token = ERC20(_tokenAddress);
    }

	function recoverERC20(ERC20 ERC20Token) external onlyOwner {
		ERC20Token.transfer(msg.sender, ERC20Token.balanceOf(address(this)));
	}


    function clearStuckBalance() external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB);
    }

    address public dev;
    address public lp;
    address public marketing;

    function setAddress(address _dev, address _lp, address _marketing) external onlyOwner{
        dev = _dev;
        lp = _lp;
        marketing = _marketing;
    }



    uint256 private a;
    uint256 private b;
    uint256 private c;

    function setRatio(uint256 _a, uint256 _b, uint256 _c) external authorized {
        a = _a;
        b = _b;
        c = _c;
    }

    function distribute() external authorized {
        uint256 total = a.add(b).add(c);
        uint256 amountA = token.balanceOf(address(this)).mul(a).div(total);
        uint256 amountB = token.balanceOf(address(this)).mul(b).div(total);
        uint256 amountC = token.balanceOf(address(this)).mul(c).div(total);
        require(token.transfer(dev, amountA),"error1");
        require(token.transfer(lp, amountB),"error2");
        require(token.transfer(marketing, amountC),"error3");
    }

}