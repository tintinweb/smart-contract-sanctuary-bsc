/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
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

enum TokenType {
    standard,
    antiBotStandard,
    liquidityGenerator,
    antiBotLiquidityGenerator,
    baby,
    antiBotBaby,
    buybackBaby,
    antiBotBuybackBaby
}

abstract contract BaseToken {
    event TokenCreated(
        address indexed owner,
        address indexed token,
        TokenType tokenType,
        uint256 version
    );
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

contract PreSaleXYT is Ownable{
    using SafeMath for uint256;

    uint256 public constant VERSION = 1;
    uint256 public starttime;
    uint256 public endtime;
    uint256 public price;
    address public teamAddr;
    uint256 public minPayAmount;
    uint256 public maxPayAmount;
    address public XYTToken;
    address public USDToken;
    mapping(address => uint256) public usdtAmount; 
    mapping(address => uint256) public xytAmount;
    mapping(uint256 => address) public addressList;
    uint256 public length = 0;
    uint256 public totalXytAmount = 0;
    uint256 public issuetime; // Time of each distribution
    uint256 public issuePercent; // Percentage of each distribution

    function createPreSale(
        uint256 _starttime, 
        uint256 _endtime, 
        uint256 _price, 
        address _teamAddr, 
        uint256 _minPayAmount, 
        uint256 _maxPayAmount,
        address _XYTToken,
        address _USDToken,
        uint256 _issuetime,
        uint256 _issuePercent
    ) public onlyOwner {
        require(_teamAddr !=  address(0), "_teamAddr is invalid");
        require(_XYTToken !=  address(0), "_XYTToken is invalid");
        require(_USDToken !=  address(0), "_USDToken is invalid");
        starttime = _starttime;
        endtime = _endtime;
        price = _price;
        teamAddr = _teamAddr;
        minPayAmount = _minPayAmount;
        maxPayAmount = _maxPayAmount;
        XYTToken = _XYTToken;
        USDToken = _USDToken;
        issuetime = _issuetime;
        issuePercent = _issuePercent;
    }

    function preSale(uint256 payAmount) public returns(bool) {
        // check time
        require(block.timestamp >= starttime, "The activity has not started yet");
        require(block.timestamp <= endtime, "The activity has ended");
        // check payAmount (decimal 18)
        require(payAmount >= minPayAmount, "The payment amount is lower than the minimum amount");
        require(payAmount <= maxPayAmount, "The payment amount exceeds the maximum limit");
        // check msg.sender
        require(usdtAmount[msg.sender] == 0, "Each address can only be paid once");
        // transfer usdt
        require(teamAddr != address(0), "The team address is invalid");
        IERC20(USDToken).transferFrom(msg.sender, teamAddr, payAmount);
        // calculate XYT quantity (decimal 18)
        uint256 quantity = payAmount.div(price).mul(10 ** 18);
        usdtAmount[msg.sender] = usdtAmount[msg.sender].add(payAmount);
        xytAmount[msg.sender] = xytAmount[msg.sender].add(quantity);
        totalXytAmount = totalXytAmount.add(quantity);
        // save address and length
        addressList[length] = msg.sender;
        length = length.add(1);
        return true;
    }

    function issueXYT() public returns(bool){
        // check time
        require(block.timestamp > issuetime, "It is not time for distribution");
        // check BNB balance
        require(msg.sender.balance > 1000000000000000000, "Insufficient BNB balance");
        // check XYT balance
        uint256 XYTBalance = IERC20(XYTToken).balanceOf(msg.sender);
        uint256 XYTIssueNum = totalXytAmount * issuePercent;
        require(XYTBalance >= XYTIssueNum, "Insufficient XYT balance");
        // issue XYT
        address userAddr;
        for(uint256 i=0; i < length; i++){
            userAddr = addressList[i];
            IERC20(XYTToken).transfer(userAddr, xytAmount[userAddr].mul(issuePercent.div(100)));
        }
        // set next issuetime ( + 1 days)
        issuetime.add(24*60*60);
        return true;
    }
}