/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

pragma solidity ^0.4.18;

contract SniperContract {
    string word = "Hello World!";

    function getWord() constant returns (string)  {
        return word;
    }

    function setWord(string newWord) returns (string) {
        word = newWord;
        return word;
    }
}