/**
 *Submitted for verification at BscScan.com on 2022-12-14
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

pragma solidity ^0.8.13;

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
    function ownerWallet() external view returns (address owner);
    // Get the token used by the Affiliation system (BUSD)
    function token_addr() external view returns (address token_address);
}


contract RoyaltySplitterV1 {

    Powermade public powermadeContract;                         // The PowermadeAffiliation contract
    bool public locked_mode;                                    // If locked there is no option to change the recipients after the deployment
    
    struct LastDistributionData {
        uint last_distribution_balance;                         // Balance before last distribution
        uint cumulative_balance;                                // Total distributed since deploy
        uint distribution_ts;                                   // Last Distribution Timestamp
    }

    struct RoyaltyReceiver {
        address recipient;                                      // The address of the user (cannot be address(0))
        uint16 percentage;                                      // The percentage associated to the user (partition) - divider is 1000
        uint expiration_ts;                                     // Expiration timestamp for a limited time royalty. If 0, no expiration
        uint cumulative_balance_threshold;                      // Stop sending royalty to the recipient after this cumulated balance. If 0, disabled.
        address after_threshold_recipient;                      // Address to use for the royalty after the expiration. Mandatory (and not address(0)) if expiration is set
    }

    LastDistributionData public last_distribution;                      // Last distribution data
    mapping(address => uint) public total_distributed_recipient;        // Total distributed for each recipient
    RoyaltyReceiver[] public royalty_receivers;                         // The array of the royalty recipients and configuration

    // Events
    event RecipientSet(RoyaltyReceiver royalty_receiver);
    event RoyaltyDistributed(address indexed caller, uint8 indexed index, address indexed to, uint amount, bool after_expiration);


    // Modifier to be used with functions that can be called only by The Owner of the Powermade Main contract
    modifier onlyPowermadeOwner()
    {
        require(msg.sender == powermadeContract.ownerWallet(), "Denied");
        _;
    }


    // Constructor called when deploying
    constructor(address _powermadeAddress, address[] memory _recipients, uint16[] memory _percentages, uint[] memory _expirations_ts, uint[] memory _cumulative_balance_thresholds, address[] memory _after_threshold_recipients, bool _locked_mode) {
        powermadeContract = Powermade(_powermadeAddress);
        _set_recipients(_recipients, _percentages, _expirations_ts, _cumulative_balance_thresholds, _after_threshold_recipients);
        locked_mode = _locked_mode;
    }


    // Fallback function for methods
    fallback() external {
        revert('FBE');
    }

    // Fallback function for payments
    receive() external payable {
        // Prevent users from using the fallback function to send money
        revert('FBE');
    }


    // Internal function used to set the recipients
    function _set_recipients(address[] memory _recipients, uint16[] memory _percentages, uint[] memory _expirations_ts, uint[] memory _cumulative_balance_thresholds, address[] memory _after_threshold_recipients) internal {
        require(_recipients.length == _percentages.length && _recipients.length == _expirations_ts.length && _recipients.length == _cumulative_balance_thresholds.length && _recipients.length == _after_threshold_recipients.length, "Size Error");
        distribute();                   // Trigger distribution first
        delete royalty_receivers;       // Reset array
        uint16 percentage_sum = 0;
        for (uint8 i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0), "Recipient not valid");
            require(_percentages[i] > 0 && _percentages[i] <= 1000, "Percentage error");
            percentage_sum += _percentages[i];
            if (_expirations_ts[i] > 0 || _cumulative_balance_thresholds[i] > 0) {
                require(_after_threshold_recipients[i] != address(0), "After Expiration Recipient Error");
                if (_expirations_ts[i] > 0) {
                    require(_expirations_ts[i] > block.timestamp + 24 hours, "Timestamp error");
                }
            } else {
                require(_after_threshold_recipients[i] == address(0), "After Expiration Recipient Error");
            }
            
            // Add the data to the local variable
            RoyaltyReceiver memory receiver;
            receiver.recipient = _recipients[i];
            receiver.percentage = _percentages[i];
            receiver.expiration_ts = _expirations_ts[i];
            receiver.cumulative_balance_threshold = _cumulative_balance_thresholds[i];
            receiver.after_threshold_recipient = _after_threshold_recipients[i];
            // Store the data
            royalty_receivers.push(receiver);
            emit RecipientSet(receiver);
        }
        // But if sum is not correct, revert
        require(percentage_sum == 1000, "Percentage Sum not 1000");
    }


    // Set/update recipients when in unlocked mode (that is set during deployment only)
    function setRecipients(address[] memory _recipients, uint16[] memory _percentages, uint[] memory _expirations_ts, uint[] memory _cumulative_balance_thresholds, address[] memory _after_threshold_recipients) external onlyPowermadeOwner {
        require(!locked_mode, "Lock active");
        _set_recipients(_recipients, _percentages, _expirations_ts, _cumulative_balance_thresholds, _after_threshold_recipients);
    }


    // Distribute to all the royalty receivers. Can be triggered by everyone
    function distribute() public {
        // At least 1h between distributions
        require(block.timestamp - last_distribution.distribution_ts >= 1 hours, "Wait distribution deadtime");
        address affiliation_token_used = powermadeContract.token_addr();
        uint current_balance = TOKEN20(affiliation_token_used).balanceOf(address(this));
        if (current_balance > 0) {
            // Process the distribution (each recipient)
            for (uint8 i = 0; i < royalty_receivers.length; i++) {
                uint balance_to_use = current_balance * royalty_receivers[i].percentage / 1000;     // Default is full part
                // Calculate process balance
                if (royalty_receivers[i].cumulative_balance_threshold > 0 && royalty_receivers[i].cumulative_balance_threshold > last_distribution.cumulative_balance && royalty_receivers[i].cumulative_balance_threshold < (last_distribution.cumulative_balance + current_balance)) {
                    uint new_balance_to_use = balance_to_use * (royalty_receivers[i].cumulative_balance_threshold - last_distribution.cumulative_balance) / current_balance;
                    // Send the remainder to the after_threshold_recipient
                    _do_royalty_transfer(affiliation_token_used, royalty_receivers[i].after_threshold_recipient, balance_to_use - new_balance_to_use, i, true);
                    // Set new balance to use for the next steps
                    balance_to_use = new_balance_to_use;
                } else if (royalty_receivers[i].cumulative_balance_threshold > 0 && royalty_receivers[i].cumulative_balance_threshold <= last_distribution.cumulative_balance) {
                    // Over threshold. Send all to after_threshold_recipient and continue the for cycle
                    _do_royalty_transfer(affiliation_token_used, royalty_receivers[i].after_threshold_recipient, balance_to_use, i, true);
                    continue;
                }
                if (royalty_receivers[i].expiration_ts > 0) {
                    // Check if expired
                    if (last_distribution.distribution_ts >= royalty_receivers[i].expiration_ts) {
                        // Already expired and everything distributed, so we will distribute to the after_threshold_recipient
                        _do_royalty_transfer(affiliation_token_used, royalty_receivers[i].after_threshold_recipient, balance_to_use, i, true);
                    } else {
                        if (block.timestamp <= royalty_receivers[i].expiration_ts) {
                            // Full distribution of the amount to the recipient
                            _do_royalty_transfer(affiliation_token_used, royalty_receivers[i].recipient, balance_to_use, i, false);
                        } else {
                            uint recipient_amount = balance_to_use * (royalty_receivers[i].expiration_ts - last_distribution.distribution_ts) / (block.timestamp - last_distribution.distribution_ts);
                            uint remaining_amount = balance_to_use - recipient_amount;
                            _do_royalty_transfer(affiliation_token_used, royalty_receivers[i].recipient, recipient_amount, i, false);   // Transfer to eligible recipient
                            _do_royalty_transfer(affiliation_token_used, royalty_receivers[i].after_threshold_recipient, remaining_amount, i, true);   // Transfer to after_threshold_recipient the remaining
                        }
                    }
                } else {
                    // No expiration proportion
                    _do_royalty_transfer(affiliation_token_used, royalty_receivers[i].recipient, balance_to_use, i, false);
                }
            }
            // Update data
            last_distribution.last_distribution_balance = current_balance;
            last_distribution.distribution_ts = block.timestamp;
            last_distribution.cumulative_balance += current_balance;
        }
        // Here the balance should be 0, everything distributed
    }


    // Do a royalty transfer to a recipient
    function _do_royalty_transfer(address token, address recipient, uint amount, uint8 index, bool after_expiration) private {
        if (amount > 0) {
            TOKEN20(token).transfer(recipient, amount);       // Transfer
            emit RoyaltyDistributed(msg.sender, index, recipient, amount, after_expiration);    // Emit event
            total_distributed_recipient[recipient] += amount;   // Update data
        }
    }


    // Withdraw other tokens from the contract (in case of other tokens sent to the contract by mistake)
    // Withdraw of the token used by the network is not possible
    function withdrawToken(address token, uint amount, address destination) external onlyPowermadeOwner {
        require(token != powermadeContract.token_addr(), "Token not allowed");
        bool success = TOKEN20(token).transfer(destination, amount);      // Do the token transfer. The source is the contract itself
        require(success, "T20Err");
    }


}