// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract Token {
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    uint256 public totalSupply;

    address public taxWalletMarketing;
    address public taxWalletLiquidity;
    address public taxWalletTeam;

    address public contractOwner;

    // 500 for 5%
    uint256 public taxRateMarketing;
    uint256 public taxRateLiquidity;
    uint256 public taxRateTeam;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "Richard Heart";
        symbol = "RCH";
        totalSupply = 100000000 * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;

        taxWalletMarketing = address(0x7209C04b60187668521BbbFf65eC7D520fd9Bd7C);
        taxWalletLiquidity = address(0x1E34272Ff1Cb8FA93B7964b5c2F11aa1F94Aeb9f);
        taxWalletTeam = address(0x2e59eb9f956721b0715a85c1F751Cc0485ac16E5);
        taxRateMarketing = 100;
        taxRateLiquidity = 200;
        taxRateTeam = 300;

        contractOwner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        return _transfer(msg.sender, _to, _value);
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_to != address(0));

        uint256 taxMarketing = 0;
        uint256 taxLiquidity = 0;
        uint256 taxTeam = 0;

        if (taxRateMarketing > 0) {
            taxMarketing = (_value * taxRateMarketing) / (10000);
            balanceOf[taxWalletMarketing] += taxMarketing;
            emit Transfer(_from, taxWalletMarketing, taxMarketing);
        }
        if (taxRateLiquidity > 0) {
            taxLiquidity = (_value * taxRateLiquidity) / (10000);
            balanceOf[taxWalletLiquidity] += taxLiquidity;
            emit Transfer(_from, taxWalletLiquidity, taxLiquidity);
        }
        if (taxRateTeam > 0) {
            taxTeam = (_value * taxRateLiquidity) / (10000);
            balanceOf[taxWalletTeam] += taxTeam;
            emit Transfer(_from, taxWalletTeam, taxTeam);
        }

        uint256 valueWithoutTax = _value - taxMarketing - taxLiquidity - taxTeam;

        balanceOf[_from] = balanceOf[_from] - valueWithoutTax;
        balanceOf[_to] = balanceOf[_to] + valueWithoutTax;
        emit Transfer(_from, _to, valueWithoutTax);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value, "No allowance");
        require(balanceOf[_from] >= _value, "Insuficiant balance");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function myBalance() public view returns (uint256) {
        return balanceOf[msg.sender];
    }

    function setTaxWallets(
        address _taxWalletMarketing,
        address _taxWalletLiquidity,
        address _taxWalletTeam
    ) public {
        require(contractOwner == msg.sender, "only the owner can change the tax wallet");
        taxWalletMarketing = _taxWalletMarketing;
        taxWalletLiquidity = _taxWalletLiquidity;
        taxWalletTeam = _taxWalletTeam;
    }

    function setTaxRate(
        uint256 _taxRateMarketing,
        uint256 _taxRateLiquidity,
        uint256 _taxRateTeam
    ) public {
        require(contractOwner == msg.sender, "only the owner can change the tax rate");
        taxRateMarketing = _taxRateMarketing;
        taxRateLiquidity = _taxRateLiquidity;
        taxRateTeam = _taxRateTeam;
    }

    function getTaxRateMarketing() public view returns (uint256) {
        return taxRateMarketing;
    }

    function getTaxRateLiquidity() public view returns (uint256) {
        return taxRateLiquidity;
    }

    function getTaxRateTeam() public view returns (uint256) {
        return taxRateTeam;
    }
}