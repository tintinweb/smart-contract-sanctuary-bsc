pragma solidity >= 0.8.11;

contract TestRandom {

    address public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 private lastBalance = 0;

    function play() public onlyBaseFee {
        // only 5 Gwei gas fee is accepted. So gambler cant choice his nonce in block.
    }

    function safeRandom() public view returns(uint256,uint256,uint256) {
        uint256 random = wbnbWeiBalance();
        uint256 random2 = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, lastBalance)));
        uint256 hardify = uint(keccak256(abi.encodePacked(address(this), msg.sender)));

        return (random,random2,hardify);
    }

    function getGasLeft() public view returns(uint){
        return gasleft();
    }

    function wbnbWeiBalance() public view returns(uint256) {
        return wbnb.balance % 1 ether;
    }
    // block hash kullan
    // miner -> coinbase çek rastgeledir oda
    // kazanç üst limit koyki miner çekemesin
    // pancake router lp okuma olabilir her saniye işle
    // 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c wbnb adresinin bnb balanceı - wbnb balanceı değil

    modifier onlyBaseFee {
        require(tx.gasprice == 5 gwei, "only base fee accepted");
        _;
    }
}