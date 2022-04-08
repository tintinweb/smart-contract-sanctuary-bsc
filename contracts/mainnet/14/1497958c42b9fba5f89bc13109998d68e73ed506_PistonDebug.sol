/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract PistonDebug {

    using SafeMath for uint256;

	IToken private pistonToken;
	IRace public pistonRace;
	IPriceFeed public pistonTokenPriceFeed;	
	

    constructor() {
        pistonToken = IToken(address(0xBfACD29427fF376FF3BC22dfFB29866277cA5Fb4));	
		pistonRace = IRace(address(0xbd6e5D331A09fb39D28CB76510ae9b7d7781aE68));
		pistonTokenPriceFeed = IPriceFeed(address(0x83Fe5acD13CdC965CFFCdCaC35686Dd69796897C));
    }

    //function debugEjectTest(address _addr) external view returns(uint256, uint256,uint256,uint256) { 
    function debugEjectTest(address _addr) external view returns(uint256, uint256) { 
        uint256 amountDeposits_PSTN;
        uint256 amountDeposits_BUSD;
        uint256 current_amount_BUSD;
        
        uint256 amountAvailableForEject;     

        uint256 pistonPrice = pistonTokenPriceFeed.getPrice(1);
        
        //temps
        uint256 amount_PSTN;uint256 amount_BUSD;bool ejected;				
        
        for (uint256 i = 0; i < pistonRace.userDepositsForEjectLength(_addr); i++) {
        (amount_PSTN, amount_BUSD, , ejected) = pistonRace.userDepositsForEject(_addr, i);
            if(ejected == false){
                amountDeposits_PSTN += amount_PSTN;	
                amountDeposits_BUSD += amount_BUSD;							
            }				
        }
        
        current_amount_BUSD=SafeMath.mul(pistonPrice,(SafeMath.div(amountDeposits_PSTN, 10**18)));
        
        if(SafeMath.div(current_amount_BUSD,10**18) >= amountDeposits_BUSD) {
            amountAvailableForEject= SafeMath.min(SafeMath.div(current_amount_BUSD, pistonPrice), amountDeposits_PSTN);
        } else {
            amountAvailableForEject= amountDeposits_PSTN;
        }

        //return (amountDeposits_PSTN, amountDeposits_BUSD,current_amount_BUSD,amountAvailableForEject);
				return (pistonPrice, pistonRace.userDepositsForEjectLength(_addr));
    }
		
		/*
    function debugEjectTest(address _addr) external view returns(uint256 amountForReject, uint256 amountForRejectBeforeTax, uint256 userWithdrawn, 
        uint256 userPiston, uint256 userPistonBUSD, bool ejectSuccess){
        uint256 amountAvailableForEject;
        uint256 amountDeposits_PSTN;
        uint256 amountDeposits_BUSD;
        uint256 pistonPrice = pistonTokenPriceFeed.getPrice(1);

        (uint256 withdrawn, uint256 withdrawn_BUSD) = 
        pistonRace.usersWithdrawn(_addr);

        for (uint256 i = 0; i < pistonRace.userDepositsForEjectLength(_addr); i++) {
            //get inside the loop to get values per index
            (uint256 amount_PSTN, uint256 amount_BUSD, , bool ejected) 
            = pistonRace.userDepositsForEject(_addr, i);

                if(ejected == false){
                    uint256 current_amount_BUSD = pistonPrice* amount_PSTN / 1 ether;
                    amountDeposits_PSTN += amount_PSTN;
                    amountDeposits_BUSD = amount_BUSD / pistonPrice;
                    if(current_amount_BUSD >= amount_BUSD){
                        amountAvailableForEject += SafeMath.min((amount_BUSD / pistonPrice), amount_PSTN);                
                    }
                    else if(pistonPrice * (amount_PSTN / 1 ether) <= amount_BUSD){
                        amountAvailableForEject += amount_PSTN;
                    }         
                }
            }

        userPistonBUSD = amountDeposits_BUSD; 
        userPiston = amountDeposits_PSTN;
        userWithdrawn = withdrawn;

        amountForRejectBeforeTax = amountAvailableForEject;
        uint256 ejectTaxAmount = amountAvailableForEject * 10 / 100;
        amountAvailableForEject = amountAvailableForEject - ejectTaxAmount;

        amountAvailableForEject = amountAvailableForEject - userWithdrawn;
        amountForReject = amountAvailableForEject;

        //this will simulate the require function of the actual eject method
        if(withdrawn < amountAvailableForEject && amountAvailableForEject <= amountDeposits_PSTN){
            ejectSuccess = true;
        }else{
            ejectSuccess = false;
        }
    }
	*/

	function debugTest(address _addr) external view returns (address upline, uint256 deposit_time, uint256 deposits, 
                uint256 payouts, uint256 direct_bonus, uint256 match_bonus, uint256 last_airdrop) {

        (upline, deposit_time, deposits, payouts, direct_bonus, match_bonus, last_airdrop) 
        = pistonRace.userInfo(_addr);

	}

	
}

interface IRace {
    function userInfo(address _addr) external view returns(address upline, uint256 deposit_time, uint256 deposits, uint256 payouts, uint256 direct_bonus, uint256 match_bonus, uint256 last_airdrop );
    //function userInfoTotals(address _addr) external view returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure, uint256 airdrops_total, uint256 airdrops_received);
    //function userInfoRealDeposits(address _addr) external view returns(uint256 deposits_real, uint256 deposits_real_busd);
    //function contractInfo() external view returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_bnb, uint256 _total_txs, uint256 _total_airdrops, uint256 _tokenPrice, uint256 _vaultBalance);
    function userDepositsForEject(address _addr, uint256 index) external view returns(uint256 amount_PSTN, uint256 amount_BUSD, uint256 depositTime, bool ejected);
    function userDepositsForEjectLength(address _addr) external view returns(uint256 length);
    //function usersWithdrawn(address _addr) external view returns(uint256 withdrawn, uint256 withdrawn_BUSD);
}

interface IPriceFeed {
    function getPrice(uint amount) external view returns(uint);
}

interface IToken {
		//variable readers
		function maxBuyAmount() external returns(uint256);
		function maxSellAmount() external returns(uint256);
		function maxWalletBalance() external returns(uint256);
		function totalFees() external returns(uint256);
		function extraSellFee() external returns(uint256);

		// functions

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
   */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    /**
     * @dev Adds two numbers, throws on overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}