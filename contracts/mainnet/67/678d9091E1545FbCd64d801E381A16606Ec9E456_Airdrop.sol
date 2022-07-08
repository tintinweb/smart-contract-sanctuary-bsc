/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-04
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

contract Token is Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 10000000000000 * 10 ** 16;
    string public name = "XYZ";
    string public symbol = "ABC";
    uint256 public decimals = 16;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount * 10**16);
        return true;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        value = value * 10**16;
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] <= value, "allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount * 10**16);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        balances[account] = balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
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

contract Airdrop is Token {
    using Counters for Counters.Counter;
    address payable public admin;
    mapping(address => bool) public processedAirdrops;
    IBEP20 public token;
    uint256 releasetime;
    uint256 public currentAirdropAmount;
    uint256 public maxAirdropAmount;
    uint256 public _unlockTime;
    Counters.Counter private _claimdropNumber;
    Counters.Counter private _unlockedDropsNumber;
    struct Drops {
        uint256 dropId;
        IBEP20 token;
        address claimer;
        uint256 amount;
        uint256 releasetime;
        bool withdrawn;
    }
    Drops[] alldrops;
    event Claimtoken(
        uint256 dropId,
        IBEP20 token,
        address claimer,
        uint256 amount,
        uint256 unlockTime
    );
    event RewardToken(
        uint256 dropId,
        IBEP20 token,
        address claimer,
        uint256 amount
    );
    event StartAirdrop(
        address token,
        uint256 airdropamount
    );
    modifier onlyadmin() {
        if (msg.sender == admin) {}
        _;
    }

    function startAirdrop(address _token, uint256 _maxAirdropAmount) public {
        require(_maxAirdropAmount <= totalSupply);
        admin = payable(msg.sender);
        _maxAirdropAmount = _maxAirdropAmount * 10**16;
        IBEP20(_token).transferFrom(
            msg.sender,
            address(this),
            _maxAirdropAmount
        );
        balances[address(this)] = _maxAirdropAmount;
        require(_maxAirdropAmount != 0);
        require(maxAirdropAmount <= totalSupply);
        maxAirdropAmount = _maxAirdropAmount;
        emit StartAirdrop(_token, _maxAirdropAmount);
    }

    function RewardTokens() public {
        require(payable(msg.sender) != admin);
        uint256 amount = 35677500 * 10**16;
        require(
            processedAirdrops[msg.sender] == false,
            "airdrop already processed"
        );
        require(
            currentAirdropAmount + amount <= maxAirdropAmount,
            "airdropped 100% of the tokens"
        );
        processedAirdrops[msg.sender] = true;
        releasetime = block.timestamp + 31557600;
        uint256 currentdropId = _unlockedDropsNumber.current();
        alldrops.push(
            Drops(currentdropId, token, msg.sender, amount, releasetime, false)
        );
        _unlockedDropsNumber.increment();
        emit Claimtoken(currentdropId, token, msg.sender, amount, releasetime);
    }

    function ClaimReward(IBEP20 _token, uint256 dropId) public {
        Drops memory drop = alldrops[dropId];
        require(drop.claimer == msg.sender, "you are not owner of tokens!");
        require(drop.withdrawn == false, "you already withdrawn your tokens!");
        require(
            drop.releasetime < block.timestamp,
            "you must wait for unlock!"
        );
        require(msg.sender != admin, "admin cannot claim token");
        alldrops[dropId].withdrawn = true;
        _unlockedDropsNumber.increment();
        IBEP20(_token).transferFrom(address(this), msg.sender, drop.amount);
        balances[msg.sender] += drop.amount;
        balances[msg.sender] -= drop.amount;
        emit RewardToken(dropId, IBEP20(token), msg.sender, drop.amount);
    }
    function getAirDrops() public view returns (Drops[] memory){
        return alldrops;

    }
  function getamount(uint dropId) public view returns (address, uint256, uint256,uint256) {
    Drops storage drop = alldrops[dropId];
    require (drop.dropId == dropId);
    return (drop.claimer, drop.dropId, drop.amount, drop.releasetime);
}
}