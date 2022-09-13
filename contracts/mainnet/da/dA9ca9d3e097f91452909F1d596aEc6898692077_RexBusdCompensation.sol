/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: RXFNDTN

pragma solidity ^0.7.4;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░██████╗░░░███████╗░░██╗░░░██╗░░ //  CONTRACT:
// ░░██╔══██╗░░██╔════╝░░╚██╗░██╔╝░░ //  BUSD COMPENSATION
// ░░██████╔╝░░█████╗░░░░░╚████╔╝░░░ //  PART OF "REX" SMART CONTRACTS
// ░░██╔══██╗░░██╔══╝░░░░░██╔═██╗░░░ //
// ░░██║░░██║░░███████╗░░██╔╝░░██╗░░ //  FOR DEPLOYMENT ON NETWORK:
// ░░╚═╝░░╚═╝░░╚══════╝░░╚═╝░░░╚═╝░░ //  BINANCE SMART CHAIN - ID: 56
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░ Latin: king, ruler, monarch ░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░ Copyright (C) 2022 rex.io ░░░ //  SINGLE SOURCE OF TRUTH: rex.io
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //

/**
 *
 * REX is a new staking token, that had a predecessor protocol "REX CLASSIC".
 * Participants of REX CLASSIC who experienced losses, may claim a BUSD compensation from DEVELOPMENT FUND.
 * This contract manages the DEVELOPMENT FUND and the BUSD compensation.
 *
 * For BUSD compensation, the contract basically provides two mappings:
 *   mapping(address => uint256) public claimableAmount;  (-> an address has a certain claimable amount)
 *   mapping(address => uint256) public claimedAmount;    (-> the amount claimed)
 *
 * INIT:
 * After contract deployment, the deployer fills the mapping "claimableAmount" via "initClaimables()"
 * Afterwards, the deployer shall "revokeAccess"
 *
 * USAGE:
 * After initializing, users will be able to use external "claimAirdropTokens()" to claim BUSD
 * (BUSD tokens are withdrawn from this contract to the claimer)
 *
 * There are several getter-functions (for a website or app) to check,
 * whether an address is eligible (in that specific moment) to claim, has claimed, or - generally - is in the claiming list
 *
 * The contract counts the total claimed BUSD ("totalClaimedAmount") and the "totalAirdropAdresses"
 *
 * "ADMIN RIGHTS"
 * The deploying address "TOKEN_DEFINER" has only two rights:
 *   1) Calling initRexContract() providing the address of REX_CONTRACT.
 *      This is needed to link the two contracts after deployment.
 *   2) Calling initClaimables() to set the claimable amounts per address.
 * Afterwards, the TOKEN_DEFINER shall call "revokeAccess", so all this can only be done once.
 * No further special rights are granted to the TOKEN_DEFINER (or any other address).
 *
 */

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract RexBusdCompensation {

    address public devFundAddress;  // address where the BUSD come from
    address public TOKEN_DEFINER;   // for initializing contracts after deployment
    address constant busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    IBEP20 public BUSD_TOKEN;

    uint256 public airdropBUSD;
    uint256 public totalClaimedAmount;
    uint256 public totalAirdropAmount;
    uint256 public totalAirdropAdresses;

    mapping(address => uint256) public claimableAmount;
    mapping(address => uint256) public claimedAmount;

    event AddressClaimedAmount(address indexed claimAddress, uint256 claimAmount);

    /**
     * @notice For initializing the contract
     */
    modifier onlyTokenDefiner() {
        require(
            msg.sender == TOKEN_DEFINER,
            'REX: Not allowed.'
        );
        _;
    }

    receive() external payable { revert(); }
    fallback() external payable { revert(); }

    constructor() {
        TOKEN_DEFINER = msg.sender;
        BUSD_TOKEN = IBEP20(busd_address);
    }

    /**
     * @notice A function for saving the airdrop amounts after deployment
     * @param _address for the airdrop
     * @param _amount for the airdrop
     */
    function initClaimables(
        address[] memory _address,
        uint256[] memory _amount
    )
        external onlyTokenDefiner
    {
        for (uint256 i = 0; i < _address.length; i++) {
            if (claimableAmount[_address[i]] == 0)
            {
                if (_notContract(_address[i]))
                {
                    totalAirdropAdresses = totalAirdropAdresses + 1;                    // count address
                    claimableAmount[_address[i]] = _amount[i];                          // assign amount to address
                    totalAirdropAmount = totalAirdropAmount + _amount[i];               // add amount to total
                }
            }
            else  // update an amount
            {
                totalAirdropAmount = totalAirdropAmount - claimableAmount[_address[i]]; // deduct old amount from total
                claimableAmount[_address[i]] = _amount[i];                              // assign new amount to address
                totalAirdropAmount = totalAirdropAmount + _amount[i];                   // add new amount to total

            }
        }
    }

    /**
     * @notice A function to set the devFundAddress after deployment
     * @param _DEVFUND for the airdrop
     */
    function initDevFundAddr(address _DEVFUND)
        external
        onlyTokenDefiner
    {
        devFundAddress = _DEVFUND;
    }

    function revokeAccess() external onlyTokenDefiner {
        TOKEN_DEFINER = address(0x0);
    }

    function registerForwardedBusd(uint256 arrivingBUSD)
        external
    {
        if (msg.sender == devFundAddress)
        {
            airdropBUSD += arrivingBUSD;
        }
    }

    /** @notice Allows to CHECK what an address might claim now
      */
    function getClaimableAmount(address _claimer)
        public
        view
        returns (uint256)
    {
        return (airdropBUSD * claimableAmount[_claimer] / totalAirdropAmount) - claimedAmount[_claimer];
    }

    /** @notice Allows to CHECK if an address is in the BUSD airdrop list
      */
    function addressIsInAirdropList(address _check)
        external
        view
        returns (bool)
    {
        return claimableAmount[_check] > 0;
    }

    /** @notice Allows to withdraw BUSD tokens for address
      */
    function claimBUSD()
        external
        returns (uint256 busdComp)
    {
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Invalid sender');

        address who = msg.sender;
        busdComp = (airdropBUSD * claimableAmount[who] / totalAirdropAmount) - claimedAmount[who];

        require(claimableAmount[who] > 0, 'REX: No BUSD compensation');
        require(busdComp > 0, 'REX: Nothing to claim');

        claimedAmount[who] += busdComp;
        totalClaimedAmount += busdComp;

        BUSD_TOKEN.transfer(who, busdComp);

        emit AddressClaimedAmount(who, busdComp);
    }

    /** @notice Allows to send back BUSD to DEVELOPMENT FUND, when overpaid
      */
    function sendBackOverpayment(
    )
        external
    {
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Invalid sender');

        uint256 leftToCompensate = totalAirdropAmount - totalClaimedAmount;
        uint256 availableToCompensate = BUSD_TOKEN.balanceOf(address(this));

        require (availableToCompensate > leftToCompensate, 'REX: No overpayment.');

        uint256 sendBackAmount = availableToCompensate - leftToCompensate;

        BUSD_TOKEN.transfer(devFundAddress, sendBackAmount);
    }

    function withdrawTokens(address token)
        external
    {
        require (token != busd_address, 'REX: Not allowed.');
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Invalid sender');

        IBEP20 Token = IBEP20(token);
        if ( Token.balanceOf(address(this)) > 0 )
        {
            uint256 amo = Token.balanceOf(address(this));
            Token.transfer(devFundAddress, amo);
        }
    }

    function withdrawBnb()
        external
    {
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'REX: Invalid sender');
        if (address(this).balance > 0) { sendValue(payable(devFundAddress), address(this).balance); }
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        (bool success, ) = recipient.call{value: amount}(''); require(success, 'Address: Failed to send value'); }

    function _notContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly { size := extcodesize(_addr) }
        return (size == 0);
    }
}