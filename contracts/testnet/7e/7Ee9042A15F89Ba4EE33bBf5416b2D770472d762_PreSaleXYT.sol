/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
    address public constant XYTToken = 0x9d53605E0D84f0666FaEE9Ad7CbD53c0AA44aBD6;
    address public constant USDToken = 0xA3bEeb84d4937C9CB106A7f801DBE3D9B088C31A;
    uint256 public constant SERFEE = 5000000000000000; // 0.005 bnb
    uint256 public constant PRICE =  1000000000000000000; // 1 usdt
    uint256 public constant MINAMOUNT = 50000000000000000000; // 50 usdt
    uint256 public constant MAXAMOUNT = 200000000000000000000; // 200 usdt
    uint256 public constant SENDPERCENT = 3; // 0.03
    uint256 public constant SENDINTERVAL = 10 ; // 10min
    uint256 public starttime;
    uint256 public endtime;
    uint256 public sendtime; // Time of each distribution
    address public teamAddr;
    mapping(address => uint256) public xytAmount;
    mapping(uint256 => address) public addrList;
    uint256 public totalXytAmount = 0;
    uint256 public length = 0;

    event CreatePreSaleXYT(address user, uint256 usdtAmount, uint256 xytAmount);

    function createPreSale(
        uint256 _starttime, 
        uint256 _endtime,
        uint256 _sendtime, 
        address _teamAddr
    ) public onlyOwner {
        require(_teamAddr !=  address(0), "_teamAddr is invalid");
        starttime = _starttime;
        endtime = _endtime;
        sendtime = _sendtime;
        teamAddr = _teamAddr;
    }

    function preSale(uint256 _payAmount) external returns(bool) {
        // check time
        uint256 nowtime = block.timestamp;
        require(nowtime >= starttime && nowtime <= endtime, "The current time is not within the specified range");
        // check payAmount
        require(_payAmount >= MINAMOUNT && _payAmount <= MAXAMOUNT, "The payment amount is not within the specified range");
        // check msg.sender
        require(xytAmount[msg.sender] == 0, "Each address can only be paid once");
        // transfer usdt and bnb
        require(teamAddr != address(0), "The team address is invalid");
        IERC20(USDToken).transfer(teamAddr, _payAmount);
        payable (address(this)).transfer(SERFEE);
        // calculate XYT quantity
        uint256 quantity = _payAmount.div(PRICE).mul(10**18);
        xytAmount[msg.sender] = xytAmount[msg.sender].add(quantity);
        addrList[length] = msg.sender;
        length += 1;
        totalXytAmount = totalXytAmount.add(quantity);
        // event log
        emit CreatePreSaleXYT(msg.sender, _payAmount, quantity);
        return true;
    }

    function sendXYT() public onlyOwner returns(bool){
        require(sendtime != 0, "Please config the send params");
        // check time
        require(block.timestamp > sendtime, "It is not time for distribution");
        // check BNB balance
        require(msg.sender.balance > 1000000000000000000, "Insufficient BNB balance");
        // check XYT balance
        uint256 XYTBalance = IERC20(XYTToken).balanceOf(msg.sender);
        uint256 totalSendNum = totalXytAmount.mul(SENDPERCENT.div(100));
        require(XYTBalance >= totalSendNum, "Insufficient XYT balance");
        // issue XYT
        address userAddr;
        uint256 sendAmount;
        for(uint256 i=0; i < length; i++){
            userAddr = addrList[i];
            sendAmount = xytAmount[userAddr].mul(SENDPERCENT.div(100));
            IERC20(XYTToken).transfer(userAddr, sendAmount);
            xytAmount[userAddr] = xytAmount[userAddr].sub(sendAmount);
        }
        // set next issuetime ( + 1 minute)
        sendtime = sendtime.add(SENDINTERVAL.mul(3600));
        return true;
    }

    function withdrawAll(address payable _to) public onlyOwner returns(bool) {
        require(owner() == _to, "only owner can operate");
        _to.transfer(address(this).balance);
        return true;
    }
}