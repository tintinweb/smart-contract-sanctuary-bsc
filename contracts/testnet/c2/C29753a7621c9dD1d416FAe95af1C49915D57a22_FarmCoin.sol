// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
}

contract FarmCoin is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 decimalfactor;
    uint256 public Max_Token;
    bool mintAllowed = true;

    //  team address for TESTING
    address public developmentTeam = 0xD4cB7d966123c4B1E92b1aE129B9D92390F98fB9;
    address public treasuryTeam = 0x2A99fD5855B15097e17F3c8518119450160A734d;
    address public marketingTeam = 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955;
    address public ownderAddressForPublicSale =
        0xD8b534adA8CEd5D559eD507488f8485f0cAE5CA2;

    // team addresses
    // address public developmentTeam = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    // address public treasuryTeam = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    // address public marketingTeam = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
    // address public ownderAddressForPublicSale = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        string memory SYMBOL,
        string memory NAME,
        uint8 DECIMALS
    ) {
        symbol = SYMBOL;
        name = NAME;
        decimals = DECIMALS;
        decimalfactor = 10**uint256(decimals);
        Max_Token = 100_0000_000 * decimalfactor;
        mint(ownderAddressForPublicSale, 25_00_000_00 * decimalfactor);
        mint(developmentTeam, 5_00_000_00 * decimalfactor);
        mint(treasuryTeam, 40_00_000_00 * decimalfactor);

        mint(marketingTeam, 5_0_000_000 * decimalfactor);
        mint(address(this), 25_0_000_000 * decimalfactor);

        // team values for production

        // // testing with smaller timestamps for testing
        // createTeam(1,developmentTeam,60, 2_000_000_000*decimalfactor,10000,0);
        // createTeam(2,treasuryTeam,120,2_500_000_000*decimalfactor,1000,60);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(_to != address(0));
        require(balanceOf[_from] >= _value, "Not enough tokens");
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Allowance error");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        mintAllowed = true;
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    function mint(address _to, uint256 _value) public returns (bool success) {
        require(Max_Token >= (totalSupply + _value));
        require(mintAllowed, "Max supply reached");
        if (Max_Token == (totalSupply + _value)) {
            mintAllowed = false;
        }
        require(msg.sender == owner, "Only Owner Can Mint");
        balanceOf[_to] += _value;
        totalSupply += _value;
        require(balanceOf[_to] >= _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }
}