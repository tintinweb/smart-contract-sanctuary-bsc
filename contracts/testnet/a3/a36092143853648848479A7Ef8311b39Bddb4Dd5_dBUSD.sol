pragma solidity ^0.5.16;

import "./VBep20.sol";


// Mainnet (dec 23, 2022)
// dBUSD: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,0x2E01A2a576A79702b76D6c5979437e756A9464C8,0x41A407e80747b80875BCD6340713879ccDad37Da,1000000000000000000,"dualPool BUSD","dBUSD",18,0x8988F6901e2E7B221FfEA7F137AbB11481fE67a6
// dBTCB: 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c,0x2E01A2a576A79702b76D6c5979437e756A9464C8,0x41A407e80747b80875BCD6340713879ccDad37Da,1000000000000000000,"dualPool BTCB","dBTCB",18,0x8988F6901e2E7B221FfEA7F137AbB11481fE67a6

/**
 * @title Venus's VBep20Immutable Contract
 * @notice VTokens which wrap an EIP-20 underlying and are immutable
 * @author Venus
 */
contract dBUSD is VBep20 {
    /**
     * @notice Construct a new money market
     * @param underlying_ The address of the underlying asset
     * @param comptroller_ The address of the Comptroller
     * @param interestRateModel_ The address of the interest rate model
     * @param initialExchangeRateMantissa_ The initial exchange rate, scaled by 1e18
     * @param name_ BEP-20 name of this token
     * @param symbol_ BEP-20 symbol of this token
     * @param decimals_ BEP-20 decimal precision of this token
     * @param admin_ Address of the administrator of this token
     */
    constructor(address underlying_,
                ComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_) public {
        // Creator of the contract is admin during initialization
        admin = msg.sender;

        // Initialize the market
        initialize(underlying_, comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);

        // Set the proper admin now that initialization is done
        admin = admin_;
    }
}