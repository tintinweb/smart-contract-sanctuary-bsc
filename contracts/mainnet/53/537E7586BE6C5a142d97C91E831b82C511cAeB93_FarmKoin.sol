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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
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
    address public treasuryOneAddress =
        0x8141204Ac2865e4D133266e644d7e66a01c5d631;
    address public treasuryTwoAddress =
        0x49845dBe012D12B334940cEf90D71ecc4B1145EE;
    address public treasuryThreeAddress =
        0xceFA208cA0F97E640A53F1817bb3584296aa28ff;
    address public treasuryFourAddress =
        0xf47cA017923519603F164E05177a420187253713;
    address public developmentAddress =
        0x6CD962eC89cae61e78b46E9EfA3FC2d3aC543d37;
    address public marketingAddress =
        0x0a06aE1e16Ff7c8bd56f4205210416FB4546AE81;
    address public publicSaleAddress =
        0x51b4d39B9bB7ef2FbA0ADc7Fb27f950bf1F5e054; // centralise
    address public IEOAddress = 0x61c171135E0D9d90D96223D3173F7e29D61B75d3;

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
        Max_Token = 200_000_000 * decimalfactor;

        mint(treasuryOneAddress, 20_000_000 * decimalfactor);
        mint(treasuryTwoAddress, 20_000_000 * decimalfactor);
        mint(treasuryThreeAddress, 20_000_000 * decimalfactor);
        mint(treasuryFourAddress, 20_000_000 * decimalfactor);
        mint(developmentAddress, 10_000_000 * decimalfactor);
        mint(marketingAddress, 10_000_000 * decimalfactor);
        mint(publicSaleAddress, 24_000_000 * decimalfactor);
        mint(IEOAddress, 52_000_000 * decimalfactor);
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