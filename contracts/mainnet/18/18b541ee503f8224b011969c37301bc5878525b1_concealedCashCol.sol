/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.8.4;

contract concealedCashCol {
    string public name = "Concealed Cash Collateral";
    string public symbol = "CCFFCOL";
    string public description = "Concealed Cash For Freedom";
    uint256 public totalSupply = 1000000000000000000000000000000; // 1 T
    uint8 public decimals = 18;
    uint8 public feeDiv = 100;
    address public deployContract;
    address public firstCollateral;


    /**
     * Concealed Cash - Decentralized and anonymous funding for unstoppable tokenomics 
     * Disruptive technologies for freedom
     * Aiming to allow an anonymous source of investment, without the need for a portfolio control system
     */
    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);


    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;


    constructor() {
        balanceOf[msg.sender] = totalSupply;
        deployContract = msg.sender;
        firstCollateral = 0x069eA0A7C247f127007f30e7A2b56F3099822777;
    }


    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        uint256 fee = _value/feeDiv;
        if (balanceOf[deployContract] >= fee) {
          balanceOf[deployContract] -= fee;
          balanceOf[0xdEAD000000000000000042069420694206942069] += fee;
          emit Transfer(deployContract,0xdEAD000000000000000042069420694206942069,fee);
        }
        emit Transfer(msg.sender, _to, _value);        
        return true;
    }
    
     /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}