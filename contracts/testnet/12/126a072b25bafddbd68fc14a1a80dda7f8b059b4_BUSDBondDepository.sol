// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

import './WaltsWorldBondDepository.sol';

contract BUSDBondDepository is WaltsWorldBondDepository {
    constructor (        
        address _WALT,
        address _principle,
        address _treasury, 
        address _DAO, 
        address _bondCalculator
        ) WaltsWorldBondDepository(_WALT, _principle, _treasury, _DAO, _bondCalculator) 
    {}
}