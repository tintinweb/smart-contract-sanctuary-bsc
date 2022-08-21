/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: RXFNDTN

pragma solidity ^0.7.4;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░██████╗░░░███████╗░░██╗░░░██╗░░ //  CONTRACT:
// ░░██╔══██╗░░██╔════╝░░╚██╗░██╔╝░░ //  AIRDROP for REX CLASSIC users
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
 * Participants of REX CLASSIC may claim a certain amount of new REX tokens
 * This contract manages the airdrop.
 *
 * For this, the contract basically provides two mappings:
 *   mapping(address => uint256) public claimableAmount;  (-> an address has a certain claimable amount)
 *   mapping(address => bool) public addressHasClaimed;   (-> a flag for saving that address has claimed)
 *
 * INIT:
 * After contract deployment, the deployer fills the mapping "claimableAmount" via "initClaimables()"
 * Afterwards, the deployer shall "revokeAccess"
 *
 * USAGE:
 * After initializing, users will be able to
 *   1) use external "claimAirdropTokens()" to claim LIQUID REX
 *      (calling REX_CONTRACT to mint the REX tokens)
 *   2) use external "claimAirdropStake(days)" to claim a REX STAKE, providing the desired staking duration in days
 *      (calling REX_CONTRACT to "createStake")
 *
 * BONUS:
 * Claiming REX as a STAKE (above option 2) gets the claimer MORE tokens (BONUS)
 * The bonus depends on the chosen DURATION of the STAKE
 *
 * TIMELINE:
 * The claim must be done between REX DAY 2 and REX DAY 222
 * The "REX DAY" is fetched from REX main contract (see interface below)
 *
 * There are several getter-functions (for a website or app) to check,
 * whether an address is eligible (in that specific moment) to claim , has claimed, or - generally - is in the claiming list
 *
 * The contract counts the number of addresses that claimed liquid REX ("claimCount")
 * and staked REX ("stakeCount") and the "totalAirdropAdresses"
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

interface IREXToken {

    function currentRxDay()
        external view
        returns (uint32);

    function mintSupply(
        address _donatorAddress,
        uint256 _amount
    ) external;

    function createStake(
        address _staker,
        uint256 _amount,
        uint32 _days,
        string calldata _description,
        bool _irrevocable
    ) external;

}

contract RexAirdrop {

    using RexSafeMath for uint256;
    using RexSafeMath32 for uint32;

    address public TOKEN_DEFINER;   // for initializing contracts after deployment

    IREXToken public REX_CONTRACT;

    uint32 constant LAST_CLAIM_DAY = 222;

    uint256 public claimCount;
    uint256 public stakeCount;
    uint256 public totalAirdropAdresses;

    mapping(address => uint256) public claimableAmount;
    mapping(address => bool) public addressHasClaimed;

    event AddressClaimedDayAmount(address indexed claimAddress, uint32 indexed claimDay, uint256 claimAmount);
    event AddressStakedDayAmountDuration(address indexed stakerAddress, uint32 indexed stakeDay, uint256 stakeAmount, uint32 stakingDays);

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
    }

    function initContract(address _rex) external onlyTokenDefiner {
        REX_CONTRACT = IREXToken(_rex);
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
            if (claimableAmount[_address[i]] == 0 && _notContract(_address[i])) {   // if not counted before and receiver not contract
                totalAirdropAdresses = totalAirdropAdresses + 1;                    // count address
                claimableAmount[_address[i]] = _amount[i];                          // assign amount to address
            }
        }
    }

    function revokeAccess() external onlyTokenDefiner {
        TOKEN_DEFINER = address(0x0);
    }

    /** @notice Allows to CHECK if an address might claim airdrop now
      */
    function addressCanClaimNow(address _claimer)
        external
        view
        returns (bool)
    {
        return claimableAmount[_claimer] > 0
          && !addressHasClaimed[_claimer]
          && _currentRxDay() >= 2
          && _currentRxDay() <= LAST_CLAIM_DAY;
    }

    /** @notice Allows to CHECK if an address might claim and stake airdrop now
      */
    function addressCanStakeNow(address _check)
        external
        view
        returns (bool)
    {
        return claimableAmount[_check] >= 1000000
          && !addressHasClaimed[_check]
          && _currentRxDay() >= 2
          && _currentRxDay() <= LAST_CLAIM_DAY;
    }

    /** @notice Allows to CHECK if an address is in the airdrop list
      */
    function addressIsInAirdropList(address _check)
        external
        view
        returns (bool)
    {
        return claimableAmount[_check] > 0;
    }

    /** @notice Allows to MINT tokens for airdrop address
      */
    function claimAirdropTokens()
        external
        returns (uint256 _payout)
    {
        require(_currentRxDay() >= 2, 'REX: Too early.');
        require(_currentRxDay() <= LAST_CLAIM_DAY, 'REX: Too late.');
        require(!addressHasClaimed[msg.sender], 'REX: Address has already claimed.');
        require(claimableAmount[msg.sender] > 0, 'REX: Nothing to claim.');

        addressHasClaimed[msg.sender] = true;
        claimCount = claimCount.add(1);
        _payout = claimableAmount[msg.sender];
        REX_CONTRACT.mintSupply(msg.sender, _payout);
        emit AddressClaimedDayAmount(msg.sender, _currentRxDay(), _payout);
    }

    /** @notice Allows to STAKE tokens received from airdrop
      */
    function claimAirdropStake(
        uint32 _stakingDays
    )
        external
        returns (uint256 _amount)
    {
        require(_currentRxDay() >= 2, 'REX: Too early.');
        require(_currentRxDay() <= LAST_CLAIM_DAY, 'REX: Too late.');
        require(_stakingDays >= 30 && _stakingDays <= 3653, 'REX: Stake duration not in range.');
        require(!addressHasClaimed[msg.sender], 'REX: Address has already claimed.');
        require(claimableAmount[msg.sender] > 0, 'REX: Nothing to claim.');

        addressHasClaimed[msg.sender] = true;
        stakeCount = stakeCount.add(1);
        _amount = claimableAmount[msg.sender];

          // BONUS for staking duration: 30 days: +10% - linear rising to: 600 days + 50%
          // y = m*x+b; where M = 0.0701754385964912 and B = 7.89473684211
          // cap BONUS at 600 days
        uint32 _stakingDaysCapped = _stakingDays > 600 ? 600 : _stakingDays;
        uint256 PERCENT_MORE_x_1E16 = ( uint256(_stakingDaysCapped).mul(701754385964912) ).add(78947368421100000);
        _amount = _amount.add( _amount.mul(PERCENT_MORE_x_1E16).div(100).div(1E16) );
        require(_amount >= 1000000, 'REX: Stake too small.');

        REX_CONTRACT.createStake(msg.sender, _amount, _stakingDays, unicode'0', true);
        emit AddressStakedDayAmountDuration(msg.sender, _currentRxDay(), _amount, _stakingDays);
    }

    /** @notice Shows current day of RexToken
      * @dev Fetched from REX_CONTRACT
      * @return Iteration day since REX inception
      */
    function _currentRxDay() public view returns (uint32) {
        return REX_CONTRACT.currentRxDay();
    }

    function _notContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly { size := extcodesize(_addr) }
        return (size == 0);
    }
}

library RexSafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'REX: addition overflow');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'REX: subtraction overflow');
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'REX: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'REX: division by zero');
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'REX: modulo by zero');
        return a % b;
    }
}

library RexSafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, 'REX: addition overflow');
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a, 'REX: subtraction overflow');
        uint32 c = a - b;
        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, 'REX: multiplication overflow');

        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0, 'REX: division by zero');
        uint32 c = a / b;
        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0, 'REX: modulo by zero');
        return a % b;
    }
}