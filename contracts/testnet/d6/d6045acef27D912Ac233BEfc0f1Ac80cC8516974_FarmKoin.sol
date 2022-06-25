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

contract FarmKoin is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 decimalfactor;
    uint256 public Max_Token;
    bool mintAllowed = true;
    address public treasuryOneAddress = 0x2A99fD5855B15097e17F3c8518119450160A734d;
    address public treasuryTwoAddress = 0x49845dBe012D12B334940cEf90D71ecc4B1145EE;
    address public treasuryThreeAddress = 0xceFA208cA0F97E640A53F1817bb3584296aa28ff;
    address public treasuryFourAddress = 0xf47cA017923519603F164E05177a420187253713;
    address public developmentAddress = 
        0x6CD962eC89cae61e78b46E9EfA3FC2d3aC543d37;
    address public marketingAddress =
        0x0a06aE1e16Ff7c8bd56f4205210416FB4546AE81;
    address public publicSaleAddress = 0x7Ff7030Eb08D375D6b6B181203F4183E81873D5d; // centralise    

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
        Max_Token = 100_000_000 * decimalfactor;

        mint(treasuryOneAddress, 10_000_000 * decimalfactor); 
        mint(treasuryTwoAddress, 10_000_000 * decimalfactor); 
        mint(treasuryThreeAddress, 10_000_000 * decimalfactor); 
        mint(treasuryFourAddress, 10_000_000 * decimalfactor); 
        mint(developmentAddress, 5_000_000 * decimalfactor);
        mint(marketingAddress, 5_000_000 * decimalfactor);
        mint(publicSaleAddress, 25_000_000 * decimalfactor);

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