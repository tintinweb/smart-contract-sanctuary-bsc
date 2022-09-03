/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 < 0.9.0;


contract BasicFunctions {

    // Setting things up
    string coinName = "EPIC Coin";
    uint public myBalance = 1000;

    struct Coin {
        string name;
        string symbol;
        uint supply;
    }
    mapping (address => Coin) internal myCoins;

  
    address TOKENA;
    address TOKENB;
    address TOKENC; 

    // function (string memory _variable1, int _variable2) public view/pure returns(bool) {}
    // pure == not interacting with any variables from outside
    function guessNumber(uint _guess) public pure returns(bool) {
        if (_guess == 5) {
            return true;
        } else {
            return false;
        }
    }

    // returns string
    function getMyCoinName() public view returns(string memory) {
        return coinName;
    }
    
    function loanAmout(uint256 _amount) public pure returns(uint256) {
        return  _amount; 
    }

    // that can only be called externally
    function multiplyBalance(uint _multiplier) external {
        myBalance = myBalance * _multiplier;
    }

    // that user a for loop and multiples params and string comparison
    function findCoinIndex(string[] memory _myCoins, string memory _find, uint _startFrom) public pure returns (uint) {
        for (uint i = _startFrom; i < _myCoins.length; i++) {
            string memory coin = _myCoins[i];
            if (keccak256(abi.encodePacked(coin)) == keccak256(abi.encodePacked(_find))) {
                return i;
            }
        }

        return 9999;
    }

    // update a mapping
    function addCoin(string memory _name, string memory _symbol, uint _supply) external {
        myCoins[msg.sender] = Coin(_name, _symbol, _supply);
    }

    // function get a coin from myCoin mapping
    function getMyCoin() public view returns(Coin memory) {
        return myCoins[msg.sender];
    }
}