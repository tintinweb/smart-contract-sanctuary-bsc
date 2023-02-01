/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

// SPDX-License-Identifier: MIT

/*

Punk community Rabbit NFT （PR）

NFT Mint https://tinyurl.com/PunkRabbitNFT

Telegrm：https://t.me/punk_community

Twitter：https://twitter.com/Punk__DAO

Punk community file：https://punkcommunity.gitbook.io/punk

.______    __    __  .__   __.  __  ___    .______          ___      .______   .______    __  .___________.   .__   __.  _______ .___________.
|   _  \  |  |  |  | |  \ |  | |  |/  /    |   _  \        /   \     |   _  \  |   _  \  |  | |           |   |  \ |  | |   ____||           |
|  |_)  | |  |  |  | |   \|  | |  '  /     |  |_)  |      /  ^  \    |  |_)  | |  |_)  | |  | `---|  |----`   |   \|  | |  |__   `---|  |----`
|   ___/  |  |  |  | |  . `  | |    <      |      /      /  /_\  \   |   _  <  |   _  <  |  |     |  |        |  . `  | |   __|      |  |     
|  |      |  `--'  | |  |\   | |  .  \     |  |\  \----./  _____  \  |  |_)  | |  |_)  | |  |     |  |        |  |\   | |  |         |  |     
| _|       \______/  |__| \__| |__|\__\    | _| `._____/__/     \__\ |______/  |______/  |__|     |__|        |__| \__| |__|         |__|     


*/
pragma solidity ^0.4.16;

contract TokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 6;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;  
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);


    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }


    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);    
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
}

/*


Punk community Rabbit NFT （PR）

NFT Mint https://tinyurl.com/PunkRabbitNFT

Telegrm：https://t.me/punk_community

Twitter：https://twitter.com/Punk__DAO

Punk community file：https://punkcommunity.gitbook.io/punk

.______    __    __  .__   __.  __  ___    .______          ___      .______   .______    __  .___________.   .__   __.  _______ .___________.
|   _  \  |  |  |  | |  \ |  | |  |/  /    |   _  \        /   \     |   _  \  |   _  \  |  | |           |   |  \ |  | |   ____||           |
|  |_)  | |  |  |  | |   \|  | |  '  /     |  |_)  |      /  ^  \    |  |_)  | |  |_)  | |  | `---|  |----`   |   \|  | |  |__   `---|  |----`
|   ___/  |  |  |  | |  . `  | |    <      |      /      /  /_\  \   |   _  <  |   _  <  |  |     |  |        |  . `  | |   __|      |  |     
|  |      |  `--'  | |  |\   | |  .  \     |  |\  \----./  _____  \  |  |_)  | |  |_)  | |  |     |  |        |  |\   | |  |         |  |     
| _|       \______/  |__| \__| |__|\__\    | _| `._____/__/     \__\ |______/  |______/  |__|     |__|        |__| \__| |__|         |__|     


*/