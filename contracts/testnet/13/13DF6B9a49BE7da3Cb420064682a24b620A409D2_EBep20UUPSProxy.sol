// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ComptrollerInterface.sol";
import "./InterestRateModel.sol";

contract EBep20UUPSProxy {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"
    constructor(address contractLogic 
                // address underlying_,
                // ComptrollerInterface comptroller_,
                // InterestRateModel interestRateModel_,
                // uint initialExchangeRateMantissa_,
                // string memory name_,
                // string memory symbol_,
                // uint8 decimals_,
                // address payable admin_
                ) {
        // save the code address
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, contractLogic)
        }
        // bytes memory constructData = abi.encodeWithSignature("initialize(address,address,address,uint256,string,string,uint8,address)",
        //                                                     underlying_,
        //                                                     comptroller_,
        //                                                     interestRateModel_,
        //                                                     initialExchangeRateMantissa_,
        //                                                     name_,
        //                                                     symbol_,
        //                                                     decimals_,
        //                                                     admin_);

        // (bool success, bytes memory result ) = contractLogic.delegatecall(constructData); // solium-disable-line
        // require(success, "Construction failed");
    }

    fallback() external payable {
        assembly { // solium-disable-line
            let contractLogic := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(sub(gas(), 10000), contractLogic, 0x0, calldatasize(), 0, 0)
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
            case 0 {
                revert(0, retSz)
            }
            default {
                return(0, retSz)
            }
        }
    }
}

pragma solidity ^0.8.13;

abstract contract ComptrollerInterfaceG1 {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata vTokens) external virtual returns (uint[] memory);
    function exitMarket(address eToken) external virtual returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address eToken, address minter, uint mintAmount) external virtual returns (uint);
    function mintVerify(address eToken, address minter, uint mintAmount, uint mintTokens) external virtual;

    function redeemAllowed(address eToken, address redeemer, uint redeemTokens) external virtual returns (uint);
    function redeemVerify(address eToken, address redeemer, uint redeemAmount, uint redeemTokens) external virtual;

    function borrowAllowed(address eToken, address borrower, uint borrowAmount) external virtual returns (uint);
    function borrowVerify(address eToken, address borrower, uint borrowAmount) external virtual;

    function repayBorrowAllowed(
        address eToken,
        address payer,
        address borrower,
        uint repayAmount) external virtual returns (uint);
    function repayBorrowVerify(
        address eToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external virtual ;

    function liquidateBorrowAllowed(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external virtual returns (uint);
    function liquidateBorrowVerify(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external virtual;

    function seizeAllowed(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external virtual returns (uint);
    function seizeVerify(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external virtual;

    function transferAllowed(address eToken, address src, address dst, uint transferTokens) external virtual returns (uint);
    function transferVerify(address eToken, address src, address dst, uint transferTokens) external virtual;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address vTokenBorrowed,
        address vTokenCollateral,
        uint repayAmount) external view virtual returns (uint, uint);
}

abstract contract ComptrollerInterfaceG2 is ComptrollerInterfaceG1 {
}

abstract contract ComptrollerInterface is ComptrollerInterfaceG2 {
}

interface IComptroller {
    function liquidationIncentiveMantissa() external view returns (uint);
    /*** Treasury Data ***/
    function treasuryAddress() external view returns (address);
    function treasuryPercent() external view returns (uint);
}

pragma solidity ^0.8.13;

/**
  * @title Evry.Finance's InterestRateModel Interface
  * @author Evry.Finance
  */
abstract contract InterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection)
    bool public constant isInterestRateModel = true;

    /**
      * @notice Calculates the current borrow interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @return The borrow rate per block (as a percentage, and scaled by 1e18)
      */
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view virtual returns (uint);

    /**
      * @notice Calculates the current supply interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @param reserveFactorMantissa The current reserve factor the market has
      * @return The supply rate per block (as a percentage, and scaled by 1e18)
      */
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view virtual returns (uint);

}