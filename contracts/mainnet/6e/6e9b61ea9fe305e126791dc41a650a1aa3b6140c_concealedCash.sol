/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.7.4;

contract concealedCash {
    string public name = "Concealed Cash";
    string public symbol = "CCFF";
    string public description = "Concealed Cash For Freedon";
    uint256 public totalSupply = 1000000000000000000; // 1 B
    uint8 public decimals = 9;


    /**
     * Concealed Cash - Decentralized and anonymous funding for unstoppable tokenomics 
     * Unknown devs - We see famous developers as a weakness
     * No Project Owners or CEOs
     * No Site
     * No Repository
     *  - Only visible source codes in block explorers of corresponding networks
     * No Social Media Project
     *  - Much more interesting is the disclosure on social networks by the volunteers' accounts
     *  - Metatag ConcealedCashToken
     * Bridges to multiple networks, for fast migration between networks and protocols when needed 
     * Disruptive technologies for freedom
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
    }


    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
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