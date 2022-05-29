/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract DoubleColorBall {
    address payable public manager;
    mapping (address => uint) money;
    mapping (address => uint[7]) number;
    mapping (address => uint[7]) prizeNumber;
    constructor() {
        manager = payable(msg.sender);
    }
    
    function bet(uint8 one, uint8 two, uint8 three, uint8 four, uint8 five, uint8 six, uint8 blue) public payable
    {
        require(0 < blue && blue < 17, "blue ball range 1-16");
        require(msg.value > 0, "no value");
        number[msg.sender] = [one, two, three, four, five, six, blue];
        uint256 fee = devFee(msg.value);
        manager.transfer(fee);
        money[msg.sender] = msg.value - fee;
        prizeNumber[msg.sender] = lottery();

        uint redNumber;
        for (uint a = 0; a < 6; a++) {
            for (uint b = 0; b < 6; b++) {
                require(0 < number[msg.sender][b] && number[msg.sender][b] < 34, "red ball range 1-33");
                for (uint c = b + 1; c < 6; c++) {
                    require(number[msg.sender][b] != number[msg.sender][c], "duplicate number");
                }
                if (prizeNumber[msg.sender][a] == number[msg.sender][b]) {
                    redNumber++;
                }
            }
        }

        uint blueNumber;
        if (prizeNumber[msg.sender][6] == number[msg.sender][6]) {
            blueNumber = 1;
        }

        uint256 prize = 0;
        if (redNumber == 6 && blueNumber == 1) {
            prize = address(this).balance * 75 / 100;
        } else if (redNumber == 6) {
            prize = address(this).balance * 25 / 100;
        } else if (redNumber == 5 && blueNumber == 1) {
            prize = address(this).balance * 10 / 100;
        } else if (redNumber == 5 || (redNumber == 4 && blueNumber == 1)) {
            prize = address(this).balance * 5 / 100;
        } else if (redNumber == 4 || (redNumber == 3 && blueNumber == 1)) {
            prize = address(this).balance * 3 / 100;
        } else if (blueNumber == 1) {
            prize = address(this).balance * 1 / 100;
        }

        if (prize > 0) {
            fee = devFee(prize);
            manager.transfer(fee);
            payable(msg.sender).transfer(prize - fee);
        }
    }
   
    function lottery() internal view returns(uint[7] memory)
    {
        uint[33] memory x;
        for (uint i = 0; i < x.length; i++) {
            x[i] = i + 1;        
        }
       
        uint randNonce = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        uint random1 = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, randNonce))) % 33;
        if (random1 != 32) {
            randNonce = random1;
            random1 = x[randNonce];
            x[randNonce] =  x[32];
        }
        uint random2 = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, random1))) % 32;
        if (random2 != 31) {
            randNonce = random2;
            random2 = x[randNonce];
            x[randNonce] =  x[31];
        }
        uint random3 = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, random2))) % 31;
        if (random3 != 30) {
           randNonce = random3;
            random3 = x[randNonce];
            x[randNonce] =  x[30];
        }
        uint random4 = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, random3))) % 30;
        if (random4 != 29) {
            randNonce = random4;
            random4 = x[randNonce];
            x[randNonce] =  x[29];
        }
        uint random5 = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, random4))) % 29;
        if (random5 != 28) {
            randNonce = random5;
            random5 = x[randNonce];
            x[randNonce] =  x[28];
        }
        uint random6 = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, random5))) % 28;
        if (random6 != 27) {
            randNonce = random6;
            random6 = x[randNonce];
            x[randNonce] =  x[27];
        }
        uint randomBlue = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, random6))) % 16;
        if (randomBlue == 0) {
            randomBlue = 16;
        }

        return [random1, random2, random3, random4, random5, random6, randomBlue];

    }

    function getPrizePool() public view returns(uint256) {
        return address(this).balance;
    }

    function getPrizeNumber() public view returns(uint[7] memory) {
        return prizeNumber[msg.sender];
    }

    function getBetNumber() public view returns(uint[7] memory) {
        return number[msg.sender];
    }

    function getBetMoney() public view returns(uint) {
        return money[msg.sender];
    }

    function devFee(uint256 amount) private pure returns(uint256){
        return amount * 3 / 100;
    }
}