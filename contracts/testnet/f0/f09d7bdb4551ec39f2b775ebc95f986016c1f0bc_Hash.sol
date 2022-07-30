/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Hash {

    uint256 valor = 5 ether;
    address prueba = 0x39f366a374Ac9ED0d87fDD3DE1Ff3128BE4cC9eD;

    enum Status {
        Close,
        Open
    }

    enum TypeLottery {
        Normal,
        Special
    }

    struct Lottery {
        Status status;
        TypeLottery typeLottery;
        uint256 amountCollectedInBusd;
        uint32 finalNumber;
    }

    mapping(uint256 => Lottery) private _lotteries;

    // History of bet numbers
    mapping(address => mapping(uint256 => uint32[])) private _userNumbersPerLotteryId;

    mapping(address => uint256) private _winnersLottery;



    constructor() {
        
        _winnersLottery[prueba] = valor;
        
        _userNumbersPerLotteryId[prueba][1].push(1000000);
        _userNumbersPerLotteryId[prueba][1].push(1000001);
        _userNumbersPerLotteryId[prueba][1].push(1000002);
        _userNumbersPerLotteryId[prueba][1].push(1000003);
        _userNumbersPerLotteryId[prueba][1].push(1000004);
        _userNumbersPerLotteryId[prueba][1].push(1000005);
        _userNumbersPerLotteryId[prueba][1].push(1000006);
        _userNumbersPerLotteryId[prueba][1].push(1999999);
        _userNumbersPerLotteryId[prueba][1].push(1000555);
        _userNumbersPerLotteryId[prueba][1].push(1004578);
        _userNumbersPerLotteryId[prueba][1].push(1011111);
        _userNumbersPerLotteryId[prueba][1].push(1000022);
        _userNumbersPerLotteryId[prueba][2].push(10000);
        _userNumbersPerLotteryId[prueba][2].push(10001);
        _userNumbersPerLotteryId[prueba][2].push(19999);
        _userNumbersPerLotteryId[prueba][2].push(10002);
        _userNumbersPerLotteryId[prueba][2].push(10550);
        _userNumbersPerLotteryId[prueba][3].push(10550);
        _userNumbersPerLotteryId[prueba][8].push(11111);
        _userNumbersPerLotteryId[prueba][8].push(12222);
        _userNumbersPerLotteryId[prueba][8].push(13333);
        _userNumbersPerLotteryId[prueba][8].push(10000);
        _userNumbersPerLotteryId[prueba][8].push(10001);
        _userNumbersPerLotteryId[prueba][8].push(14444);
        _userNumbersPerLotteryId[prueba][8].push(15555);
        _userNumbersPerLotteryId[prueba][8].push(16666);
        _userNumbersPerLotteryId[prueba][8].push(17777);
        _userNumbersPerLotteryId[prueba][8].push(18888);

        _lotteries[1] = Lottery({
            status: Status.Open,
            typeLottery: TypeLottery.Special,
            amountCollectedInBusd: valor,
            finalNumber: 1584623
        });

        _lotteries[2] = Lottery({
            status: Status.Open,
            typeLottery: TypeLottery.Normal,
            amountCollectedInBusd: valor,
            finalNumber: 10579
        });

        _lotteries[3] = Lottery({
            status: Status.Open,
            typeLottery: TypeLottery.Normal,
            amountCollectedInBusd: valor,
            finalNumber: 10579
        });

        _lotteries[4] = Lottery({
            status: Status.Open,
            typeLottery: TypeLottery.Normal,
            amountCollectedInBusd: valor,
            finalNumber: 10579
        });

        _lotteries[5] = Lottery({
            status: Status.Open,
            typeLottery: TypeLottery.Normal,
            amountCollectedInBusd: valor,
            finalNumber: 10579
        });

        _lotteries[6] = Lottery({
            status: Status.Open,
            typeLottery: TypeLottery.Normal,
            amountCollectedInBusd: valor,
            finalNumber: 10579
        });

        _lotteries[7] = Lottery({
            status: Status.Open,
            typeLottery: TypeLottery.Normal,
            amountCollectedInBusd: valor,
            finalNumber: 10579
        });

        _lotteries[8] = Lottery({
            status: Status.Open,
            typeLottery: TypeLottery.Normal,
            amountCollectedInBusd: valor,
            finalNumber: 10579
        });


    }

    function viewNumbersForAddress(address _address, uint256 _lotteryId) 
        external
        view
        returns (uint32[] memory, uint256)
        {
            uint256 length = _userNumbersPerLotteryId[_address][_lotteryId].length;

            uint32[] memory ticketNumbers = new uint32[](length);


            for (uint256 i = 0; i < length; i = unsafe_inc(i)) {
                
                ticketNumbers[i] = _userNumbersPerLotteryId[_address][_lotteryId][i];
            }


        return (ticketNumbers, length);
        
    }


    function viewBalanceForAddress(address _address) external view returns (uint256) {
        return _winnersLottery[_address];
    }

    function viewBalanceForAddressUser() external view returns (uint256) {
        return _winnersLottery[msg.sender];
    }


    function viewLottery(uint256 _lotteryId) external view returns (Lottery memory) {
        return _lotteries[_lotteryId];
    }

   
     function unsafe_inc(uint256 x) private pure returns (uint256) {
        unchecked { return x + 1; }
    }

    function destroyContract() external {
        selfdestruct(payable(prueba));
    }

}