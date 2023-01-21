/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.4.24;

library SafeMath {
    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract SparkContract {

    using SafeMath for uint256;

    // ERC20 BASIC DATA
    mapping(address => uint256) internal balances;
    uint256 internal totalSupply_ = 100000 * 10**18;
    string public constant name = "Spark Token";
    string public constant symbol = "SPARK";
    uint8 public constant decimals = 18;

    // ERC20 DATA
    mapping(address => mapping(address => uint256)) internal allowed;

    // BURN CONTROLLER DATA
    bool public burnDisabled = false;

    // burn decimals is only set for informational purposes.
    // 1 burnRate = .000001 
    uint8 public constant burnDecimals = 6;

    // burnRate is measured in 100th of a basis point (parts per 1,000,000)
    // ex: a burn rate of 200 = 0.02% 
    uint256 public constant burnParts = 1000000;
    uint256 public burnRate = 10000;
    address public burnRecipient = address(0);
    address owner = msg.sender;
    address team = 0xE82875D37E791e820184091456B2e05be859582F;
    address stakingPool = 0x078Ba63B94EB9643db950344F2B8f431E4590dC5;

    /**
     * EVENTS
     */

    // ERC20 BASIC EVENTS
    event Transfer(address indexed from, address indexed to, uint256 value);

    // ERC20 EVENTS
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // PAUSABLE EVENTS
    event DisableBurn();
    event EnableBurn();

    // BURN EVENTS
    event BurnCollected(address indexed from, address indexed to, uint256 value);
    event BurnRateSet(
        uint256 indexed burnRate
    );
    event BurnRecipientSet(
        address indexed BurnRecipient
    );

    /**
     * FUNCTIONALITY
     */

    constructor() public {
        balances[owner] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
        disableBurn();
    }

    // ERC20 BASIC FUNCTIONALITY

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "cannot transfer to address zero");
        require(_value <= balances[msg.sender], "insufficient funds");

        _transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _addr) public view returns (uint256) {
        return balances[_addr];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (uint256) {
        uint256 _burn;
        uint256 _principle;
        if (burnDisabled == true) {
            _principle = _value;
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_principle);
            emit Transfer(_from, _to, _principle);
        }
        if (burnDisabled == false) {
            if (_from == team || _to == stakingPool) {
                _principle = _value;
                balances[_from] = balances[_from].sub(_value);
                balances[_to] = balances[_to].add(_principle);
                emit Transfer(_from, _to, _principle);
            } else {
                _burn = getBurnFor(_value);
                _principle = _value.sub(_burn);
                balances[_from] = balances[_from].sub(_value);
                balances[_to] = balances[_to].add(_principle);
                emit Transfer(_from, _to, _principle);
                emit Transfer(_from, burnRecipient, _burn);
                if (_burn > 0) {
                    balances[burnRecipient] = balances[burnRecipient].add(_burn);
                    emit BurnCollected(_from, burnRecipient, _burn);
                }
            }
        }
        return _principle;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    // BURN PAUSABILITY FUNCTIONALITY

    modifier whenNotDisabled() {
        require(!burnDisabled, "whenNotDisabled");
        _;
    }

    function disableBurn() public onlyOwner {
        require(!burnDisabled, "Burn already disabled");
        burnDisabled = true;
        emit DisableBurn();
    }

    function enableBurn() public onlyOwner {
        require(burnDisabled, "Burn already enabled");
        burnDisabled = false;
        emit EnableBurn();
    }

    // BURN FUNCTIONALITY

    function getBurnFor(uint256 _value) public view returns (uint256) {
        if (burnRate == 0) {
            return 0;
        }
        return _value.mul(burnRate).div(burnParts);
    }

    // TOTAL BURNED 

    function totalBurned() public view returns (uint256) {
        return balances[address(0)];
    }
}