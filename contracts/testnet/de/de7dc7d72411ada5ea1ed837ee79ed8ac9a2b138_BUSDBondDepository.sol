// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import './BondDepository.sol';

contract BUSDBondDepository is BondDepository {
    constructor (        
        address _TOKEN,
        address _principle,
        address _treasury, 
        address _DAO, 
        address _bondCalculator
        ) BondDepository(_TOKEN, _principle, _treasury, _DAO, _bondCalculator) 
    {}
}