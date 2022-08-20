//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract Staking is Ownable {
    uint256 oneDay = 24 * 3600;
    uint8 public totalStakers;

    // address noeToken = 0x42b2958B1E021660337988459181333309564545;      //mainnet
    address noeToken = 0xB985E24Ad8c0F17B49bbdfa973A34FD068717AA3;      // testnet

    struct StakeInfo {
        uint256 startTS;
        uint256 amount;
        uint256 claimed;
        uint256 apr;
        uint256 lockTerm;
    }
    
    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);
    
    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public addressStaked;
    mapping(address => bool) public whiteList;


    constructor() {
        totalStakers = 0;
    }    

    function transferToken(address to,uint256 amount) external onlyOwner{
        require(IERC20(noeToken).transfer(to, amount), "Token transfer failed!");  
    }

    function claimReward() external returns (bool){
        require(addressStaked[_msgSender()] == true, "You are not participated");
        // require(stakeInfos[_msgSender()].startTS + stakeInfos[_msgSender()].lockTerm < block.timestamp, "Stake Time is not over yet");
        require(stakeInfos[_msgSender()].claimed == 0, "Already claimed");

        uint256 stakeAmount = stakeInfos[_msgSender()].amount;
        uint256 totalTokens = stakeAmount;

        if ((stakeInfos[_msgSender()].startTS + stakeInfos[_msgSender()].lockTerm * oneDay) < block.timestamp) {
            totalTokens += (stakeAmount * stakeInfos[_msgSender()].apr / 100);
        } else {
            totalTokens += (stakeAmount * stakeInfos[_msgSender()].apr / 100) * (block.timestamp - stakeInfos[_msgSender()].startTS) / (stakeInfos[_msgSender()].lockTerm * oneDay);
            totalTokens = totalTokens * 75 / 100;
        }
        stakeInfos[_msgSender()] = StakeInfo({
            startTS: stakeInfos[_msgSender()].startTS,
            amount: stakeInfos[_msgSender()].amount,
            claimed: totalTokens,
            apr: stakeInfos[_msgSender()].apr,
            lockTerm: stakeInfos[_msgSender()].lockTerm
        });
        IERC20(noeToken).transfer(_msgSender(), totalTokens);
        addressStaked[_msgSender()] = false;

        emit Claimed(_msgSender(), totalTokens);

        return true;
    }

    function getTokenExpiry() external view returns (uint256) {
        require(addressStaked[_msgSender()] == true, "You are not participated");
        return stakeInfos[_msgSender()].startTS + oneDay * stakeInfos[_msgSender()].lockTerm;
    }

    function addwhiteList(address one, bool flag) external onlyOwner{
        whiteList[one] = flag;
    }

    function addwhiteLists(address[] memory addresslist) external onlyOwner{
        for (uint256 i = 0; i < addresslist.length; i++) {
            whiteList[addresslist[i]] = true;
        }
    }

    function stakeToken(uint256 stakeAmount, uint256 apr, uint256 lockTerm) external payable {
        require(stakeAmount > 0, "Stake amount should be correct");
        require(addressStaked[_msgSender()] == false, "You already participated");
        require(IERC20(noeToken).balanceOf(_msgSender()) >= stakeAmount, "Insufficient Balance");

        if (apr == 8) {
            require(stakeAmount <= 250000*10**18, "exceed bronze amount");
        } else if (apr == 20) {
            require(stakeAmount <= 500000*10**18, "exceed silver amount");
        } else if (apr == 45) {
            require(stakeAmount <= 1000000*10**18, "exceed golden amount");
        } else if (apr == 69) {
            // require(stakeAmount <= 1000000*10**18, "exceed private amount");
            require(whiteList[_msgSender()] == true, "no permission of premium");
        } else {
            require(stakeAmount < 0, "unknown apr");
        }

            IERC20(noeToken).transferFrom(_msgSender(), address(this), stakeAmount);
            totalStakers++;
            addressStaked[_msgSender()] = true;

            stakeInfos[_msgSender()] = StakeInfo({
                startTS: block.timestamp,
                amount: stakeAmount,
                claimed: 0,
                apr: apr,
                lockTerm: lockTerm
            });
        
        emit Staked(_msgSender(), stakeAmount);
    }
}