/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Auth {
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

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

interface IBEP20 {
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
    event Burn(address indexed owner, address indexed to, uint value);
}

contract GFITools is Context, Auth {
    using SafeMath for uint256;

    bool public isActive;
    address public token;
    address public usdt;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    mapping(address => uint256) public bnbBalance;
    mapping(address => uint256) public usdtBalance;
    mapping(address => uint256) public burnAmount;

    constructor (address _token, address _usdt) Auth(msg.sender) {
        token = _token;
        usdt = _usdt;
    }

    function setIsActive(bool _isActive) external authorized 
    {
        isActive = _isActive;
    }

    function setToken(address _token) external authorized 
    {
        token = _token;
    }

    function withdraw(address _to) public authorized 
    {
        uint balance = address(this).balance;
        require(balance > 0, "Balance should be more then zero");
        payable(_to).transfer(balance);
    }

    function takeOutTokenInCase(address _token, uint256 _amount, address _to) public authorized {
        IBEP20(_token).transfer(_to, _amount);
    }

    function bnbRecharge() public payable
    {
        require(isActive, "Contract is not active");
        require(msg.value > 0, "Value sent must more than zero");

        bnbBalance[address(msg.sender)] = bnbBalance[address(msg.sender)].add(msg.value);
    }

    function usdtRecharge(uint256 amount) public
    {
        require(isActive, "Contract is not active");
        require(amount > 0, "Amount sent must more than zero");

        IBEP20(usdt).approve(address(this), amount);
        IBEP20(usdt).transferFrom(address(msg.sender), address(this), amount);
        usdtBalance[address(msg.sender)] = usdtBalance[address(msg.sender)].add(amount);
    }

    function tokenBurn(uint256 amount) public
    {
        require(isActive, "Contract is not active");
        require(amount > 0, "Amount sent must more than zero");

        IBEP20(token).approve(DEAD, amount);
        IBEP20(token).transferFrom(address(msg.sender), DEAD, amount);
        burnAmount[address(msg.sender)] = burnAmount[address(msg.sender)].add(amount);
    }

}