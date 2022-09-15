/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

pragma solidity ^0.4.23;



contract Consts {
    string constant TOKEN_NAME = "ResurgeCoinTeszt";
    string constant TOKEN_SYMBOL = "RSCT";
    uint8 constant TOKEN_DECIMALS = 6;
    uint256 constant TOKEN_AMOUNT = 1000000;
}

contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {
    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract FreezableToken is StandardToken, Ownable {
    mapping (address => bool) public freezeAddresses;

    event FreezableAddressAdded(address indexed addr);
    event FreezableAddressRemoved(address indexed addr);

    function addFreezableAddresses(address[] addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addFreezableAddress(addrs[i])) {
                success = true;
            }
        }
    }

    function addFreezableAddress(address addr) public onlyOwner returns(bool success) {
        if (!freezeAddresses[addr]) {
            freezeAddresses[addr] = true;
            emit FreezableAddressAdded(addr);
            success = true;
        }
    }

    function removeFreezableAddresses(address[] addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeFreezableAddress(addrs[i])) {
                success = true;
            }
        }
    }

    function removeFreezableAddress(address addr) public onlyOwner returns(bool success) {
        if (freezeAddresses[addr]) {
            freezeAddresses[addr] = false;
            emit FreezableAddressRemoved(addr);
            success = true;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(!freezeAddresses[_from]);
        require(!freezeAddresses[_to]);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!freezeAddresses[msg.sender]);
        require(!freezeAddresses[_to]);
        return super.transfer(_to, _value);
    }
}

contract TransferableToken is StandardToken, Ownable {
    bool public isLock;

    mapping (address => bool) public transferableAddresses;

    constructor() public {
        isLock = true;
        transferableAddresses[msg.sender] = true;
    }

    event Unlock();
    event TransferableAddressAdded(address indexed addr);
    event TransferableAddressRemoved(address indexed addr);

    function unlock() public onlyOwner {
        isLock = false;
        emit Unlock();
    }

    function isTransferable(address addr) public view returns(bool) {
        return !isLock || transferableAddresses[addr];
    }

    function addTransferableAddresses(address[] addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addTransferableAddress(addrs[i])) {
                success = true;
            }
        }
    }

    function addTransferableAddress(address addr) public onlyOwner returns(bool success) {
        if (!transferableAddresses[addr]) {
            transferableAddresses[addr] = true;
            emit TransferableAddressAdded(addr);
            success = true;
        }
    }

    function removeTransferableAddresses(address[] addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeTransferableAddress(addrs[i])) {
                success = true;
            }
        }
    }

    function removeTransferableAddress(address addr) public onlyOwner returns(bool success) {
        if (transferableAddresses[addr]) {
            transferableAddresses[addr] = false;
            emit TransferableAddressRemoved(addr);
            success = true;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(isTransferable(_from));
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(isTransferable(msg.sender));
        return super.transfer(_to, _value);
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}
contract BurnableToken is BasicToken, Pausable {

    event Burn(address indexed burner, uint256 value);
    function burn(uint256 _value) whenNotPaused public {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
}

contract MainToken is Consts, FreezableToken, TransferableToken, PausableToken, MintableToken, BurnableToken {
    string public constant name = TOKEN_NAME; 
    string public constant symbol = TOKEN_SYMBOL; 
    uint8 public constant decimals = TOKEN_DECIMALS; 

    uint256 public constant INITIAL_SUPPLY = TOKEN_AMOUNT * (10 ** uint256(decimals));

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}