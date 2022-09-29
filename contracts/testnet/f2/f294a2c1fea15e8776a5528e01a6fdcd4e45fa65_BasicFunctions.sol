/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.9.0;

contract BasicFunctions {

    //setting things up
    string coinName = "EPIC Coin";

    uint public myBalance = 1000;


    struct Coin {
        string name;
        string symbol;
        uint supply;
    }

    mapping (address => Coin) internal myCoins;

    //function (string memory var`1, int var2) public view/pure returns(bool) {}
    function guessNumber(uint guess) public pure returns (bool) {
        if (guess == 5) {
            return true;
        } else {
            return false;
        }
    }   


    //returns a string
    function getMyCoinName() public view returns(string memory) {
        return coinName;
    }

    //that can only be called externally
    function multiplyBalance(uint multiplier) external {
        myBalance = myBalance * multiplier;
    }
        //that uses a for loop and multiplies params and string comparison
        function findCoinIndex(string[] memory _myCoins, string memory _find, uint _startFrom) public pure returns (uint) {
            for (uint i = _startFrom; i < _myCoins.length; i++) {
                string memory coin = _myCoins[i];
                if (keccak256(abi.encodePacked(coin)) == keccak256(abi.encodePacked(_find))) {
                    return i;
            }
        }
        return 9999;
    }

    function addCoin(string memory name, string memory symbol, uint supply) external {
        myCoins[msg.sender] = Coin(name, symbol, supply);

    }

    //function get a coin from myCoin mapping
    function getMyCoin() public view returns (Coin memory) {
        return myCoins[msg.sender];
    }


    }