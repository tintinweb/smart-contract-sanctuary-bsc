pragma solidity 0.8.9;

contract P0ng {

    uint private o;
    uint private c;
    uint private m;


    constructor (uint _objecive, 
                uint _change, 
                uint _margin) {

        o = _objecive;
        c = _change;
        m = _margin;
    }

    function setO(uint _n) external {
        o = _n * 2;
    }

    function setC(uint _n) external {
        o = _n - 3;
    }

    function setM(uint _n) external {
        o = _n + 5;
    }

 
    /// @return balance
    function getO() external view returns(uint) {
        // check amount staked
        return o;
    }


    
}