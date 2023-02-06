/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

pragma solidity ^0.6.12;

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
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract KTBK is IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    address private creator = msg.sender;

    uint256 public totalSupply;
    string  public name;
    uint8   public decimals;
    string  public symbol;

    //buy
    uint256 public superNodeRate = 4;
    address public superNodeAddr = 0xDA0Db38231abD72d660413456e3da7bea5c66ddF;

    uint256 public operateRate = 3;
    address public operateAddr = 0x65CDf9ECf5898812c53b99C8bAC1dd8F1F64C5b2;

    uint256 public holdingRate = 2;
    address public holdingAddr = 0xf7eb88729e87cB060c4E55120DA588e7794DEF6f;

    //sell
    uint256 public lpRate = 4;
    address public lpAddr = 0x38fCe7591D35957C9e0c59fa33658baa4AC81217;

    uint256 public technologyRate = 2;
    address public technologyAddr = 0xE6012126e4dFba4fF16E2417778229F4b723208b;

    uint256 public destroyRate = 2;
    address public destroyAddr = 0x0000000000000000000000000000000000000000;

    uint256 public fundRate = 1;
    address public fundAddr = 0x0Fc8a2819287FAc68c569aE0f316427CFC7f8199;

    address public routerAddr;

    bool public destroyFlag = true;
    uint256 public destroyMax = 189000000 ether;
    uint256 public destroyAlready = 0;

    address public minerContract = 0x9400a1180ea913dBd74624e6089f583E52df7f7f;

    constructor () public {
        totalSupply = 210000000 * 10 ** uint256(18);
        balances[msg.sender] = totalSupply;

        name = "KTBK";
        decimals = 18;
        symbol = "KTBK";
    }

    function getDestroyFlag() public view returns (bool){
        return destroyFlag;
    }

    function getDestroyAlready() public view returns (uint256){
        return destroyAlready;
    }

    function setMinerContract(address _addr) public onlyOwner {
        minerContract = _addr;
    }

    function syncDestroyAlready(uint256 _amount) public {
        require(msg.sender == minerContract || msg.sender == owner());
        destroyAlready += _amount;
    }

    function setRouter(address _routerAddr) public {
        require(msg.sender == creator);
        routerAddr = _routerAddr;
    }

    function transfer(address _to, uint256 _value) override public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 lastValue = _value;
        if (msg.sender == routerAddr) {
            //buy
            balances[superNodeAddr] += _value * superNodeRate / 100;
            balances[operateAddr] += _value * operateRate / 100;
            balances[holdingAddr] += _value * holdingRate / 100;

            emit Transfer(msg.sender, superNodeAddr, _value * superNodeRate / 100);
            emit Transfer(msg.sender, operateAddr, _value * operateRate / 100);
            emit Transfer(msg.sender, holdingAddr, _value * holdingRate / 100);

            lastValue = _value * 91 / 100;
        }

        balances[msg.sender] -= _value;
        balances[_to] += lastValue;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        uint256 lastValue = _value;
        if (_to == routerAddr) {
            //sell
            balances[lpAddr] += _value * lpRate / 100;
            balances[technologyAddr] += _value * technologyRate / 100;
            balances[fundAddr] += _value * fundRate / 100;

            emit Transfer(_from, lpAddr, _value * lpRate / 100);
            emit Transfer(_from, technologyAddr, _value * technologyRate / 100);
            emit Transfer(_from, fundAddr, _value * fundRate / 100);
            //destroy
            uint256 destroyValue = 0;
            if (destroyFlag) {
                destroyValue = _value * destroyRate / 100;
                if (destroyAlready.add(destroyValue) < destroyMax) {
                    destroyAlready += destroyValue;
                    lastValue = _value * 91 / 100;
                } else {
                    destroyValue = destroyMax.sub(destroyAlready);
                    lastValue = _value.sub(_value * lpRate / 100).sub(_value * technologyRate / 100).sub(_value * fundRate / 100)
                    .sub(destroyValue);
                    destroyAlready = destroyMax;
                    destroyFlag = false;
                }
                emit Transfer(_from, destroyAddr, destroyValue);
            }
        }

        balances[_to] += lastValue;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) override public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) override public returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) override public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
}