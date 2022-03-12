/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity =0.6.6;


// safe math
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// erc20
interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, 'MEC: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// MEC
contract MEC is IERC20, Ownable {
    using SafeMath for uint256;

    string constant public name = 'MEC';
    string constant public symbol = 'MEC';
    uint8 constant public decimals = 18;
    uint256 constant public totalSupply = 50000000 * 10**uint256(decimals);
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    address public collectionAddress;  // collection address
    address public burnAddress;        // black hole address
    address public lpAddress;          // lp bonus address
    address public unionAddress;       // labor union bonus address
    uint256 public burnRatio = 5;  // 5%
    uint256 public lpRatio = 3;    // 3%
    uint256 public unionRatio = 2; // 2%


    constructor(
        address _owner,
        address _collectionAddress,
        address _burnAddress,
        address _lpAddress,
        address _unionAddress
    ) public {
        owner = _owner;
        collectionAddress = _collectionAddress;
        burnAddress = _burnAddress;
        lpAddress = _lpAddress;
        unionAddress = _unionAddress;

        balances[collectionAddress] = totalSupply;
        emit Transfer(address(0), collectionAddress, totalSupply);
    }

    function balanceOf(address _address) external view override returns (uint256) {
        return balances[_address];
    }

    function approve(address _spender, uint256 _value) external override returns (bool) {
        require(_spender != address(0), 'MEC: zero address error');
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256) {
        return allowed[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function _transferFull(address _from, address _to, uint256 _value) private {
        uint256 _burnAmount = _value.mul(burnRatio).div(100);
        uint256 _lpAmount = _value.mul(lpRatio).div(100);
        uint256 _unionAmount = _value.mul(unionRatio).div(100);
        uint256 _toAmount = _value.sub(_burnAmount).sub(_lpAmount).sub(_unionAmount);

        _transfer(_from, burnAddress, _burnAmount);
        _transfer(_from, lpAddress, _lpAmount);
        _transfer(_from, unionAddress, _unionAmount);
        _transfer(_from, _to, _toAmount);
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        require(balances[msg.sender] >= _value, 'MEC: balance error');
        _transferFull(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool) {
        require(balances[_from] >= _value, 'MEC: balance error');
        require(allowed[_from][msg.sender] >= _value, 'MEC: allowed error');
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transferFull(_from, _to, _value);
        return true;
    }


    function setBurnAddress(address _burnAddress) public onlyOwner {
        burnAddress = _burnAddress;
    }
    function setLpAddress(address _lpAddress) public onlyOwner {
        lpAddress = _lpAddress;
    }
    function setUnionAddress(address _unionAddress) public onlyOwner {
        unionAddress = _unionAddress;
    }

    function setBurnRatio(uint256 _burnRatio) public onlyOwner {
        burnRatio = _burnRatio;
    }
    function setLpRatio(uint256 _lpRatio) public onlyOwner {
        lpRatio = _lpRatio;
    }
    function setUnionRatio(uint256 _unionRatio) public onlyOwner {
        unionRatio = _unionRatio;
    }


}