/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

/***
 *    ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███╗   ███╗ █████╗ ██████╗ ███████╗
 *    ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔══██╗██╔════╝
 *    ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝██╔████╔██║███████║██║  ██║█████╗  
 *    ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║  ██║██╔══╝  
 *    ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝███████╗
 *    ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 *    ███████╗ ██████╗ ██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
 *    ██╔════╝██╔════╝██╔═══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
 *    █████╗  ██║     ██║   ██║███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
 *    ██╔══╝  ██║     ██║   ██║╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
 *    ███████╗╚██████╗╚██████╔╝███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
 *    ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
 *                                                                                  
 */                                                                                                   
// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;

// Interface of a token BEP20 - ERC20 - TRC20 - .... All functions of the standard interface are declared, even if not used
interface TOKEN20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Interface to access Powermade contract data
interface Powermade {
    // get the owner 
    function ownerWallet() external returns (address owner);
}

// Interface for the external custom threshold/eligibility for the package and/or for the commissions
interface ExternalEligibilityContract {
    // Function use to check the eligibility (eg. custom Token/NFT/other thresholds or other logics) 
    function isEligibleExt(address user_address, address other_address, uint16 packageID, uint param1, int param2, uint8 sourceID) external view returns (bool is_eligible);
}

// Custom token threshold for the Powermade packages on registrations
contract PowermadeTokenThreshold is ExternalEligibilityContract {

    Powermade public powermadeContract;
    TOKEN20 public powermadeToken;
    uint private package_buy_threshold_amount_PWD;
    uint[] private levels_commissions_thresholds_PWD;
    
    // Modifier to be used with functions that can be called only by The Owner of the Powermade Main contract
    modifier onlyPowermadeOwner()
    {
        require(msg.sender == Powermade(powermadeContract).ownerWallet(), "Denied");
        _;
    }

    // Constructor called when deploying
    constructor(address _powermadeAddress, address _powermadeToken) public {
        powermadeContract = Powermade(_powermadeAddress);
        powermadeToken = TOKEN20(_powermadeToken);
        levels_commissions_thresholds_PWD = [0, 0, 0, 0, 0];
        package_buy_threshold_amount_PWD = 0;
    }


    // Implementation of the ExternalEligibilityContract interface (only used parameters)
    function isEligibleExt(address user_address, address, uint16, uint param1, int, uint8 sourceID) external view returns (bool is_eligible) {
        if (sourceID == 1) {        // Case Package Buy
            return (powermadeToken.balanceOf(user_address) >= package_buy_threshold_amount_PWD);
        } else if (sourceID == 2) {     // Case sponsor commission (direct)
            return true;
        } else if (sourceID == 3) {     // Case level commission. param1 is the distributed level
            return (powermadeToken.balanceOf(user_address) >= levels_commissions_thresholds_PWD[param1-1]);
        } else {
            return true;
        }
    }

    // Set the threshold in token for the Buy Package operation (when configured)
    function setPackagePWDthreshold(uint threshold_pwd_wei) external onlyPowermadeOwner {
        package_buy_threshold_amount_PWD = threshold_pwd_wei;
    }

    // Set the thresholds in token for the Commission Levels and Pay Commissions operation (when configured)
    // THE THRESHOLD FOR A LEVEL MUST BE EQUAL OR GREATER THAN THE THRESHOLD OF THE PREVIOUS LEVEL! 
    // Otherwise the dynamic compression won't work as intended
    function setCommissionLevelsPWDthresholds(uint[] calldata thresholds_pwd_wei) external onlyPowermadeOwner {
        require(thresholds_pwd_wei.length == 5, "Length");
        require(thresholds_pwd_wei[1] >= thresholds_pwd_wei[0] && thresholds_pwd_wei[2] >= thresholds_pwd_wei[1] && thresholds_pwd_wei[3] >= thresholds_pwd_wei[2] && thresholds_pwd_wei[4] >= thresholds_pwd_wei[3], "Monotonicity");
        levels_commissions_thresholds_PWD = thresholds_pwd_wei;
    }

    // Get the current PWD threshold used for the Packages
    function getPackagePWDthreshold() external view returns (uint) {
        return package_buy_threshold_amount_PWD;
    }

    // Get the current PWD thresholds used for the commission distribution
    function getCommissionLevelsPWDthresholds() external view returns (uint[] memory) {
        return levels_commissions_thresholds_PWD;
    }

}