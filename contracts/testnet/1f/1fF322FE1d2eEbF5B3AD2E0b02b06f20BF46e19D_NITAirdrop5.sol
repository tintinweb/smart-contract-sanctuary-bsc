/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
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

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract NITAirdrop5 is Ownable {
    using Counters for Counters.Counter;
    address payable public admin;
    mapping(address => bool) public processedAirdrops;
    IBEP20 public token;
    uint256 private currentAirdropAmount;
    uint256 public AirdropAmount;
    Counters.Counter private _claimdropNumber;
    Counters.Counter private _DropsNumber;
    uint256 Supplyamount;
    struct Drops {
        uint256 dropId;
        IBEP20 token;
        address claimer;
        uint256 amount;
        bool withdrawn;
    }
    Drops[] alldrops;
    event ClaimAirdrop(
        uint256 dropId,
        IBEP20 token,
        address claimer,
        uint256 amount
    );
    modifier onlyadmin() {
        if (msg.sender == admin) {}
        _;
    }

    constructor(
        address _tokenAddr,
        uint256 _AirdropAmount,
        uint256 _Supplyamount
    ) {
        require(_tokenAddr != address(0));
        token = IBEP20(_tokenAddr);
        admin = payable(msg.sender);
        AirdropAmount = _AirdropAmount;
        Supplyamount = _Supplyamount;
    }

    function claimairdrop() public {
        require(payable(msg.sender) != admin);
        require(
            processedAirdrops[msg.sender] == false,
            "airdrop already processed"
        );
        require(
            currentAirdropAmount + Supplyamount <= AirdropAmount,
            "airdropped 100% of the tokens"
        );
        processedAirdrops[msg.sender] = true;
        uint256 currentdropId = _DropsNumber.current();
        alldrops.push(
            Drops(currentdropId, token, msg.sender, Supplyamount, false)
        );
        _DropsNumber.increment();
        token.transfer(msg.sender, (Supplyamount * 10**18));
        emit ClaimAirdrop(currentdropId, token, msg.sender, Supplyamount);
    }

    function getamount(uint256 dropId)
        public
        view
        returns (
            address,
            uint256,
            uint256
        )
    {
        Drops storage drop = alldrops[dropId];
        require(drop.dropId == dropId);
        return (drop.claimer, drop.dropId, drop.amount);
    }

    function updateSupplyamount(uint256 _Supplyamount) public onlyOwner {
        Supplyamount = _Supplyamount;
    }

    function updateTokenAddress(IBEP20 newtoken) public onlyOwner {
        token = newtoken;
    }

    function updateairdropAmount(uint256 _AirdropAmount) public onlyOwner {
        AirdropAmount = _AirdropAmount;
    }
}