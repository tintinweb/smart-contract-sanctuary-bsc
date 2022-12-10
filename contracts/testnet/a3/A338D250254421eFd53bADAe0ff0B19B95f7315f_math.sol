/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// File: V2BNB/test.sol


pragma solidity ^0.8.17;

contract math {

    uint256[] public winningArray;


function sortFixedArray(uint256[6] memory array) public pure returns (uint256[6] memory sortedArray) {
        
        sortedArray = array;
        uint ceiling;
        uint last;
        uint highIndex;

        for (uint i = 0; i < 6;) {
            last = sortedArray[5];
           
            if (sortedArray[i] > 1 && sortedArray[i] > ceiling) {
                ceiling = sortedArray[i];
                highIndex = i;
            }
            unchecked { i++; }
        }
        sortedArray[5] = ceiling;
        if (highIndex < 5) {
            sortedArray[highIndex] = last;
        }
        sortedArray[5] = ceiling;
        ceiling = 0;
        
        for (uint k = 0; k < 5;) {
            last = sortedArray[4];

            if (sortedArray[k] > 1 && sortedArray[k] > ceiling) {
                ceiling = sortedArray[k];
                highIndex = k;
            }
            unchecked { k++; }
        }
        sortedArray[4] = ceiling;
        if (highIndex < 4) {
            sortedArray[highIndex] = last;
        }
        sortedArray[4] = ceiling;
        ceiling = 0;

        for (uint l = 0; l < 4;) {
            last = sortedArray[3];

            if (sortedArray[l] > 1 && sortedArray[l] > ceiling) {
                ceiling = sortedArray[l];
                highIndex = l;
            }
            unchecked { l++; }
        }
        sortedArray[3] = ceiling;
        if (highIndex < 3) {
            sortedArray[highIndex] = last;
        }
        sortedArray[3] = ceiling;
        ceiling = 0;

        for (uint n = 0; n < 3;) {
            last = sortedArray[2];

            if (sortedArray[n] > 1 && sortedArray[n] > ceiling) {
                ceiling = sortedArray[n];
                highIndex = n;
            }
            unchecked { n++; }
        }
        sortedArray[2] = ceiling;
        if (highIndex < 2) {
            sortedArray[highIndex] = last;
        }
        sortedArray[2] = ceiling;
        ceiling = 0;

        for (uint p = 0; p < 2;) {
            last = sortedArray[1];

            if (sortedArray[p] > 1 && sortedArray[p] > ceiling) {
                ceiling = sortedArray[p];
                highIndex = p;
            }
            unchecked { p++; }
        }
        sortedArray[1] = ceiling;
        if (highIndex < 1) {
            sortedArray[highIndex] = last;
        }
        sortedArray[1] = ceiling;

        return (sortedArray);
    }

    function setWinningArray(uint256[6] memory array) public {
        winningArray = sortFixedArray(array);
    }
}