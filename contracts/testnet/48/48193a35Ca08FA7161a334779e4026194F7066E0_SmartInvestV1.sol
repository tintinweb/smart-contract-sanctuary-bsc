pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./Bep20.sol";
import "./VToken.sol";

/*
* @notice Integrates with Venus lending protocol
*/
contract SmartInvestV1 {
    
    uint256 public totalTreasury;
    address public constant vTOKEN_ADDRESS = 0x08e0A5575De71037aE36AbfAfb516595fE68e5e4; // BSC testnet Venus vTokens (vBUSD)
    address public constant BASE_BEP20 = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47; //underlying asset: BUSD
    
    function invest(uint256 amount) public {
        
        BEP20 underlying = BEP20(BASE_BEP20);     // get a handle for the underlying asset
        VToken vToken = VToken(vTOKEN_ADDRESS);   // get a handle for the corresponding vToken Contract
        underlying.approve(address(vToken), 0);     // security: reset allowance
        underlying.approve(address(vToken), amount); // approve the transfer
        assert(vToken.mint(amount) == 0);            // mint the vTokens and assert there is no error
    }
    
    function redeem(uint256 amount) public {
        VToken vToken = VToken(vTOKEN_ADDRESS);
        require(vToken.redeemUnderlying(amount) == 0, "something went wrong");
    }
    
    function getBalance() public returns (uint256){
        VToken vToken = VToken(vTOKEN_ADDRESS);
        uint tokens = vToken.balanceOfUnderlying(msg.sender);
        return tokens;
    }
    
    // function exchangeRateCurrent() public {
    //     VBep20 vToken = VToken(vTOKEN_ADDRESS);
    //     uint exchangeRateMantissa = vToken.exchangeRateCurrent();
    // }
    
}


// const vTokenDecimals = 8; // all vTokens have 8 decimal places
// const underlying = new web3.eth.Contract(bep20Abi, busdAddress);
// const vToken = new web3.eth.Contract(vTokenAbi, vBusdAddress);
// const underlyingDecimals = await underlying.methods.decimals().call();
// const exchangeRateCurrent = await vToken.methods.exchangeRateCurrent().call();
// const mantissa = 18 + parseInt(underlyingDecimals) - vTokenDecimals;
// const onevTokenInUnderlying = exchangeRateCurrent / Math.pow(10, mantissa);
// console.log('1 vBUSD can be redeemed for', oneVTokenInUnderlying, 'BUSD');

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract VToken {
    // No implementation, just the function signature. This is just so Solidity can work out how to call it.
    
    /*
    * @notice   The mint function transfers an asset into the protocol, which begins accumulating interest
    * based on the current Supply Rate for The user receives a quantity of vTokens equal to the
    * underlying tokens tokens supplied, divided by the current Exchange Rate.
    * msg.sender: The account which shall supply the asset, and own the minted vTokens.
    * @param    mintAmount The amount of the asset to be supplied, in units of the underlying asset.
    * @return   status 0 on success, otherwise an Error code
    */
    function mint(uint mintAmount) public returns (uint) {}
    
    /*
    * @notice   The redeem underlying function converts vTokens into a specified quantity of the underlying asset, 
    * and returns them to the user. The amount of vTokens redeemed is equal to the quantity of underlying tokens received, 
    * divided by the current Exchange Rate. The amount redeemed must be less than the user's Account Liquidity 
    * and the market's available liquidity.
    * msg.sender: The account to which redeemed funds shall be transferred.
    * @param    redeemAmount The amount of underlying to be redeemed.
    * @return   status 0 on success, otherwise an Error code
    */
    function redeemUnderlying(uint redeemAmount) public returns (uint) {}
    
    /*
    * @notice   The user's underlying balance, representing their assets in the protocol,
    * is equal to the user's vToken balance multiplied by the Exchange Rate.
    * @param    account The account to get the underlying balance of.
    * @return   The amount of underlying currently owned by the account.
    */
    function balanceOfUnderlying(address account) public returns (uint) {}
    
    
    // function exchangeRateCurrent() returns (uint) {}
    //exchangeRate = (getCash() + totalBorrows() - totalReserves()) / totalSupply()
}

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract BEP20 {

    mapping (address => uint) public  balanceOf;
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
    function approve(address spender, uint256 amount) public returns (bool) {}

    // funds goes as `msg.value`
    function deposit() public payable {}

    function transfer(address dst, uint amount) public returns (bool) {}
}