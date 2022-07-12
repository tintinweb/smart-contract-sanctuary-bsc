// SPDX-License-Identifier: UNLICENSED
// ALL RIGHTS RESERVED

// Unicrypt by SDDTech reserves all rights on this code. You may NOT copy these contracts.


// This contract generates Token01 contracts and registers them in the TokenFactory.
// Ideally you should not interact with this contract directly, and use the Unicrypt token app instead so warnings can be shown where necessary.

pragma solidity ^0.8.0;


import "./IERC20.sol";
import "./Ownable.sol";

import "./TaxToken.sol";

import "./IMintFactory.sol";
import "./TokenFees.sol";

contract MintGenerator is Ownable {
    
    IMintFactory public MINT_FACTORY;
    ITokenFees public TOKEN_FEES;
    
    constructor(address _mintFactory, address _tokenFees) public {
        MINT_FACTORY = IMintFactory(_mintFactory);
        TOKEN_FEES = ITokenFees(_tokenFees);
    }
    
    /**
     * @notice Creates a new Token contract and registers it in the TokenFactory.sol.
     */
    
    function createToken (
      TaxToken.ConstructorParams calldata params
      ) public payable returns (address){
          // Charge Gas Token fee for contract creation
        require(msg.value == TOKEN_FEES.getTokenFee(), 'FEE NOT MET');
        payable(TOKEN_FEES.getTokenFeeAddress()).transfer(TOKEN_FEES.getTokenFee());

        TaxToken newToken = new TaxToken(params, address(MINT_FACTORY));
        MINT_FACTORY.registerToken(msg.sender, address(newToken));
        return address(newToken);
    }
}