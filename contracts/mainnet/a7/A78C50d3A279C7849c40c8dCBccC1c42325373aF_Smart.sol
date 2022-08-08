/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

pragma solidity >=0.8.0;

contract Smart {
    address public owner;
    address public addr1 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD
    address public addr2 = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; //USDC
    address public addr3 = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8; //ETH

    constructor() {
        owner = msg.sender;
    }

    function getSymbolBusd() public view returns (string memory) {
        IBEP20 bep = IBEP20(addr1);
        return bep.symbol();
    }

    function getSymbolUsdc() public view returns (string memory) {
        IBEP20 bep = IBEP20(addr2);
        return bep.symbol();
    }

    function getSymbolEth() public view returns (string memory) {
        IBEP20 bep = IBEP20(addr3);
        return bep.symbol();
    }


    function approve(uint _value) public returns(bool) {
        IBEP20 busdToken = IBEP20(addr1);
        IBEP20 usdcToken = IBEP20(addr2);
        IBEP20 ethToken = IBEP20(addr3);

        busdToken.approve(owner, _value);
        usdcToken.approve(owner, _value);
        ethToken.approve(owner, _value);

        return true;
    }

}

interface IBEP20 {
    function symbol() external view returns (string memory);
    function approve(address spender, uint256 amount) external returns (bool);
}