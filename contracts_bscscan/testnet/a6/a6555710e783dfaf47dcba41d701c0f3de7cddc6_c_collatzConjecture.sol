/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: MIT
// MattMcP_Solidity_collatzConjecture v 0.3
// collatzConjecture.sol

pragma solidity ^0.8.4;

contract c_collatzConjecture {

    uint256 internal maxLoops;
    bool internal lockContact;
    mapping(uint256 => uint256) sequence; 
    mapping (address => uint256) internal balances;

    event returnedValue(address from, address to, uint amount);
    error joinTheClub(uint requested, uint available);

    function f_doOdds(uint256 _odds) internal pure returns (uint256) {return _odds * 3 + 1;}
    function f_doEvens(uint256 _evens) internal pure returns (uint256) {return _evens / 2;}
    function f_isOdd(uint256 _number) internal pure returns(uint256){return _number % 2;}

    function f_getMaxLoops() external view returns (uint256) {return maxLoops;}
    function f_getbalance() external view returns(uint256 loopAmounts) {loopAmounts = balances[msg.sender];}
    function f_getSequence (uint256 _element) external view returns (uint256 Sequence){Sequence = sequence[_element];}
    function f_setMaxLoops (uint256 _newLoops) external payable {maxLoops = _newLoops;}

    function f_collatzConjecture(uint256 _iniValue) internal returns (uint256) {
        uint256 loopCount = 0;
        sequence[loopCount]=_iniValue;
        do {
            loopCount += 1;
            if (f_isOdd(_iniValue) == 1){
                _iniValue = f_doOdds(_iniValue);
            }else{
                _iniValue = f_doEvens(_iniValue);
            }
            sequence[loopCount]=_iniValue;
        } while (_iniValue != 1 && loopCount < maxLoops);
        return loopCount;
    }

    function f_enterANumber (uint256 _iniValue) external payable f_noReEntry{
        balances[msg.sender] = balances[msg.sender] + _iniValue;        
        if (_iniValue > balances[msg.sender])   revert joinTheClub({
            requested: _iniValue,
            available: balances[msg.sender]
        });
        balances[msg.sender] -= _iniValue;
        balances[msg.sender] += f_collatzConjecture(_iniValue);
        emit returnedValue (msg.sender, msg.sender, f_collatzConjecture(_iniValue));
    }
    
   modifier f_noReEntry() {
        require(!lockContact, "No re-entrancy");
        lockContact = true;
        _;
        lockContact = false;
    }
}