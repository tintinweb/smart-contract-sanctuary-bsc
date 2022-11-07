/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Podium2022 {
    address public owner;
    address public coinAddress;
    bool public registriesOn;
    address[] public ownersAddress;
    address[] public winners;
    uint public predictionsLength;
    string public winnerPrediction;
    mapping (address => string[]) private predictionsByOwner;

    event NewPrediction(address wallet, string positions);

    constructor(address _coinAddress) {
        owner = msg.sender;
        coinAddress = _coinAddress;
        registriesOn = true;
    }

    function newPrediction(string memory _positions, address toWallet) public {
        require(registriesOn, "Registration is over");

        if (predictionsByOwner[toWallet].length == 0){
            ownersAddress.push(toWallet);
        } else {
            bool positionsExists = false;
            for(uint i = 0; i < predictionsByOwner[toWallet].length; i++) {
                if(compareStrings(predictionsByOwner[toWallet][i], _positions)) {
                    positionsExists = true;
                }
            }
            require(positionsExists == false, "Prediction already exists in your wallet");
        }
        predictionsByOwner[toWallet].push(_positions);
        predictionsLength++;

        emit NewPrediction(toWallet, _positions);
    }

    function transferReward(address payable _receiver) external {
        require(msg.sender == owner, "Not owner");
        uint totalBalance = IBEP20(coinAddress).balanceOf(address(this));
        IBEP20(coinAddress).transfer(_receiver, totalBalance);
    }

    function setRegistriesOn(bool _val) external {
        require(msg.sender == owner, "Not owner");
        registriesOn = _val;
    }

    function setWinnerPrediction(string memory _finalPositions) public {
        require(msg.sender == owner, "Not owner");
        winnerPrediction = _finalPositions;
        for(uint i = 0; i < ownersAddress.length; i++) {
            for(uint j = 0; j < predictionsByOwner[ownersAddress[i]].length; j++) {
                if(compareStrings(predictionsByOwner[ownersAddress[i]][j], _finalPositions)) {
                    winners.push(ownersAddress[i]);
                }
            }
        }

        if(winners.length > 0) {
            uint winnersBalance = IBEP20(coinAddress).balanceOf(address(this)) / winners.length;
            for(uint i = 0; i < winners.length; i++) {
                IBEP20(coinAddress).transfer(winners[i], winnersBalance);
            }
        }
    }

    function getPredictionsByOwner(address _wallet) public view returns (string[] memory) {
        return predictionsByOwner[_wallet];
    }

    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}