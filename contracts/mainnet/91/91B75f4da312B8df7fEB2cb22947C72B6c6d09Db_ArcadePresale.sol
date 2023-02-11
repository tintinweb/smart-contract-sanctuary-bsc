/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
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

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

contract ArcadePresale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public presaleCap = 500000 * 10**18;

    uint256 public currentlyRaised = 0;

    bool public presaleOpen = false;

    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    address public devWallet = 0xD7Ced3bD37D3Db19eBe50dfCA6e3ae001D0561d0;

    address[] presalers;

    mapping(address => bool) boughtAlready;

    mapping(address => uint256) presaleAmountBought;

    function startPresale() public onlyOwner {
        presaleOpen = true;
    }

    function stopPresale() public onlyOwner {
        presaleOpen = false;
    }

    function changePresaleCap(uint256 val) public onlyOwner {
        presaleCap = val;
    }

    function checkPresalers() public view onlyOwner returns (address[] memory) {
        return presalers;
    }

    function checkPresalersUsingIndex(uint256 num) public view onlyOwner returns (address) {
        return presalers[num];
    }

    function checkPresalerAndHisAllocation(uint256 num) public view onlyOwner returns (address, uint256) {
        return (presalers[num], presaleAmountBought[presalers[num]]);
    }
    
    function buyPresale(uint256 _amount) public nonReentrant returns (bool) {
        require(presaleOpen, "Presale not open.");
        require(currentlyRaised < presaleCap, "Presale cap reached.");
        require(_amount >= 100 * 10**18, "Minimum buy 100 BUSD.");

        if(!boughtAlready[msg.sender]) {
            presalers.push(msg.sender);
            boughtAlready[msg.sender] = true;
        }

        currentlyRaised += _amount;

        presaleAmountBought[msg.sender] = presaleAmountBought[msg.sender] + _amount;

        return true;
    }

    function checkUserAllocation(address addr) public view returns (uint256) {
        return presaleAmountBought[addr];
    }

    function checkIfAlreadyBought(address addr) public view returns (bool) {
        return boughtAlready[addr];
    }

    function checkHowManyPresalers() public view returns (uint256) {
        return presalers.length;
    }

    function checkRaisedAmount() public view returns (uint256) {
        return currentlyRaised;
    }

}